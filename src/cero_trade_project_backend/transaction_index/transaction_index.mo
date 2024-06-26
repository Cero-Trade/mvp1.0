import HM = "mo:base/HashMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

// canisters
import HttpService "canister:http_service";

// types
import T "../types";
import ENV "../env";

actor class TransactionIndex() = this {
  private func TransactionsCanister(cid: T.CanisterId): T.TransactionsInterface { actor (Principal.toText(cid)) };
  stable var wasm_module: Blob = "";

  stable var controllers: ?[Principal] = null;


  var transactionsDirectory: HM.HashMap<T.TransactionId, T.CanisterId> = HM.HashMap(16, Text.equal, Text.hash);
  stable var transactionsDirectoryEntries : [(T.TransactionId, T.CanisterId)] = [];

  stable var currentCanisterid: ?T.CanisterId = null;


  /// funcs to persistent collection state
  system func preupgrade() { transactionsDirectoryEntries := Iter.toArray(transactionsDirectory.entries()) };
  system func postupgrade() {
    transactionsDirectory := HM.fromIter<T.TransactionId, T.CanisterId>(transactionsDirectoryEntries.vals(), 16, Text.equal, Text.hash);
    transactionsDirectoryEntries := [];
  };

  private func _callValidation(caller: Principal) { assert Principal.fromText(ENV.CANISTER_ID_AGENT) == caller };

  /// get size of transactionsDirectory collection
  public query func length(): async Nat { transactionsDirectory.size() };

  /// register canister controllers
  public shared({ caller }) func registerControllers(): async () {
    _callValidation(caller);

    controllers := await T.getControllers(Principal.fromActor(this));
  };

  /// register wasm module to dynamic transactions canister, only admin can run it
  public shared({ caller }) func registerWasmArray(): async() {
    _callValidation(caller);

    let branch = switch(ENV.DFX_NETWORK) {
      case("ic") "main";
      case("local") "develop";
      case _ throw Error.reject("No DFX_NETWORK provided");
    };
    let wasmModule = await HttpService.get("https://raw.githubusercontent.com/Cero-Trade/mvp1.0/" # branch # "/wasm_modules/transactions.json", { headers = [] });

    let parts = Text.split(Text.replace(Text.replace(wasmModule, #char '[', ""), #char ']', ""), #char ',');
    let wasm_array = Array.map<Text, Nat>(Iter.toArray(parts), func(part) {
      switch (Nat.fromText(part)) {
        case null 0;
        case (?n) n;
      }
    });
    let nums8 : [Nat8] = Array.map<Nat, Nat8>(wasm_array, Nat8.fromNat);

    // register wasm
    wasm_module := Blob.fromArray(nums8);


    // update deployed canisters
    let deployedCanisters = Buffer.Buffer<T.CanisterId>(50);
    for (cid in transactionsDirectory.vals()) {
      if (not(Buffer.contains<T.CanisterId>(deployedCanisters, cid, Principal.equal))) {
        deployedCanisters.append(Buffer.fromArray<T.CanisterId>([cid]));
      };
    };

    if (deployedCanisters.size() == 0) {
      switch(currentCanisterid) {
        case(null) {};
        case(?cid) deployedCanisters.add(cid);
      };
    };

    for (canister_id in deployedCanisters.vals()) {
      await T.ic.install_code({
        arg = to_candid();
        wasm_module;
        mode = #upgrade;
        canister_id;
      });
    };
  };

  /// resume all deployed canisters
  public shared({ caller }) func startAllDeployedCanisters<system>(): async () {
    T.adminValidation(caller, controllers);

    let deployedCanisters = Buffer.Buffer<T.CanisterId>(50);
    for (cid in transactionsDirectory.vals()) {
      if (not(Buffer.contains<T.CanisterId>(deployedCanisters, cid, Principal.equal))) {
        deployedCanisters.append(Buffer.fromArray<T.CanisterId>([cid]));
      };
    };

    for(canister_id in deployedCanisters.vals()) {
      Cycles.add<system>(20_949_972_000);
      await T.ic.start_canister({ canister_id });
    };
  };

  /// stop all deployed canisters
  public shared({ caller }) func stopAllDeployedCanisters<system>(): async () {
    T.adminValidation(caller, controllers);

    let deployedCanisters = Buffer.Buffer<T.CanisterId>(50);
    for (cid in transactionsDirectory.vals()) {
      if (not(Buffer.contains<T.CanisterId>(deployedCanisters, cid, Principal.equal))) {
        deployedCanisters.append(Buffer.fromArray<T.CanisterId>([cid]));
      };
    };

    for(canister_id in deployedCanisters.vals()) {
      Cycles.add<system>(20_949_972_000);
      await T.ic.stop_canister({ canister_id });
    };
  };

  /// returns true if canister have storage memory,
  /// false if havent enough
  public func checkMemoryStatus() : async Bool {
    let status = switch(currentCanisterid) {
      case(null) throw Error.reject("Cant find transactions canisters registered");
      case(?cid) await T.ic.canister_status({ canister_id = cid });
    };

    status.memory_size > T.LOW_MEMORY_LIMIT
  };

  /// autonomous function, will be executed when current canister it is full
  private func _createCanister<system>(): async ?T.CanisterId {
    Debug.print(debug_show ("before registerToken: " # Nat.toText(Cycles.balance())));

    Cycles.add<system>(300_000_000_000);
    let { canister_id } = await T.ic.create_canister({
      settings = ?{
        controllers;
        compute_allocation = null;
        memory_allocation = null;
        freezing_threshold = null;
      }
    });

    Debug.print(debug_show ("later create_canister: " # Nat.toText(Cycles.balance())));

    try {
      await T.ic.install_code({
        arg = to_candid();
        wasm_module;
        mode = #install;
        canister_id;
      });

      Debug.print(debug_show ("later install_canister: " # Nat.toText(Cycles.balance())));

      return ?canister_id
    } catch (error) {
      throw Error.reject(Error.message(error));
    }
  };

  /// register [transactionsDirectory] collection
  public shared({ caller }) func registerTransaction(txInfo: T.TransactionInfo) : async T.TransactionId {
    _callValidation(caller);

    try {
      let errorText = "Error generating canister";

      /// get canister id and generate if need it
      let cid: T.CanisterId = switch(currentCanisterid) {
        case(null) {
          /// generate canister
          currentCanisterid := await _createCanister();
          switch(currentCanisterid) {
            case(null) throw Error.reject(errorText);
            case(?cid) cid;
          };
        };
        case(?cid) {
          /// validate canister capability
          let haveMemory = await checkMemoryStatus();
          if (haveMemory) { cid } else {
            /// generate canister
            currentCanisterid := await _createCanister();
            switch(currentCanisterid) {
              case(null) throw Error.reject(errorText);
              case(?cid) cid;
            };
          }
        };
      };

      // register transaction
      let txId: T.TransactionId = await TransactionsCanister(cid).registerTransaction(txInfo);

      transactionsDirectory.put(txId, cid);
      txId
    } catch (error) {
      throw Error.reject(Error.message(error));
    };
  };

  /// get transactions by tx id
  public shared({ caller }) func getTransactionsById(txIds: [T.TransactionId], txType: ?T.TxType, priceRange: ?[T.Price], mwhRange: ?[T.TokenAmount], method: ?T.TxMethod, rangeDates: ?[Text]) : async [T.TransactionInfo] {
    _callValidation(caller);

    let txs = Buffer.Buffer<T.TransactionInfo>(50);

    Debug.print(debug_show ("before getTransactionsById: " # Nat.toText(Cycles.balance())));

    // convert transactionsDirectory
    let directory: HM.HashMap<T.CanisterId, [T.TransactionId]> = HM.HashMap(50, Principal.equal, Principal.hash);
    for(txId in txIds.vals()) {
      switch(transactionsDirectory.get(txId)) {
        case (null) {};
        case(?cid) {
          let tempTxIds = switch(directory.get(cid)) {
            case(null) Buffer.Buffer<T.TransactionId>(50);
            case(?value) Buffer.fromArray<T.TransactionId>(value);
          };
          tempTxIds.add(txId);

          directory.put(cid, Buffer.toArray(tempTxIds));
        };
      };
    };

    // iterate canisters to get transactions supplied
    for((cid, txIds) in directory.entries()) {
      let transactions: [T.TransactionInfo] = await TransactionsCanister(cid).getTransactionsById(txIds, txType, priceRange, mwhRange, method, rangeDates);
      txs.append(Buffer.fromArray<T.TransactionInfo>(transactions));
    };

    Debug.print(debug_show ("later getTransactionsById: " # Nat.toText(Cycles.balance())));

    Buffer.toArray<T.TransactionInfo>(txs);
  };


  // /// used to get all transactions on cero trade
  // public shared({ caller }) func getTransactions(page: ?Nat, length: ?Nat, txType: ?T.TxType) : async {
  //   data: [T.TransactionInfo];
  //   totalPages: Nat;
  // } {
  //   _callValidation(caller);

  //   // define page based on statement
  //   let startPage = switch(page) {
  //     case(null) 1;
  //     case(?value) value;
  //   };

  //   // define length based on statement
  //   let maxLength = switch(length) {
  //     case(null) 50;
  //     case(?value) value;
  //   };

  //   let txs = Buffer.Buffer<T.TransactionInfo>(50);

  //   // calculate range of elements returned
  //   let startIndex: Nat = (startPage - 1) * maxLength;
  //   var i = 0;

  //   Debug.print(debug_show ("before getTransactions: " # Nat.toText(Cycles.balance())));

  //   // recopile and group txs
  //   let txsInCanister: HM.HashMap<T.CanisterId, [T.TransactionId]> = HM.HashMap(16, Principal.equal, Principal.hash);

  //   var cidTemp: ?T.CanisterId = null;
  //   let txIdsTemp = Buffer.Buffer<T.TransactionId>(50);

  //   for((txId, cid) in transactionsDirectory.entries()) {
  //     if (i >= startIndex and i < startIndex + maxLength) {
  //       if (cidTemp != ?cid) txIdsTemp.clear();
  //       cidTemp := ?cid;
  //       txIdsTemp.add(txId);

  //       txsInCanister.put(cid, Buffer.toArray<T.TransactionId>(txIdsTemp));
  //     };
  //     i += 1;
  //   };
  //   txIdsTemp.clear();


  //   // get transactions
  //   for((cid, txIds) in txsInCanister.entries()) {
  //     let transactions: [T.TransactionInfo] = await TransactionsCanister(cid).getTransactionsById(txIds, txType);
  //     txs.append(Buffer.fromArray<T.TransactionInfo>(transactions));
  //   };

  //   Debug.print(debug_show ("later getTransactions: " # Nat.toText(Cycles.balance())));

  //   var totalPages: Nat = i / maxLength;
  //   if (totalPages <= 0) totalPages := 1;

  //   {
  //     data = Buffer.toArray<T.TransactionInfo>(txs);
  //     totalPages;
  //   }
  // };
}
