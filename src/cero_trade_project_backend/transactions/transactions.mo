import HM "mo:base/HashMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Error "mo:base/Error";
import Bool "mo:base/Bool";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Nat64 "mo:base/Nat64";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";


// types
import T "../types";

shared({ caller = transactionIndexCaller }) actor class Transactions() {
  // constants
  stable let notFound: Text = "Transaction not found";


  var transactions: HM.HashMap<T.TransactionId, T.TransactionInfo> = HM.HashMap(16, Text.equal, Text.hash);
  stable var transactionsEntries : [(T.TransactionId, T.TransactionInfo)] = [];


  /// funcs to persistent collection state
  system func preupgrade() { transactionsEntries := Iter.toArray(transactions.entries()) };
  system func postupgrade() {
    transactions := HM.fromIter<T.TransactionId, T.TransactionInfo>(transactionsEntries.vals(), 16, Text.equal, Text.hash);
    transactionsEntries := [];
  };

  private func _callValidation(caller: Principal) { assert transactionIndexCaller == caller };

  /// get size of transactions collection
  public query func length(): async Nat { transactions.size() };


  /// register transaction to cero trade
  public shared({ caller }) func registerTransaction(txInfo: T.TransactionInfo): async T.TransactionId {
    _callValidation(caller);

    let txId = Nat.toText(transactions.size() + 1);
    let tx = { txInfo with transactionId = txId };

    transactions.put(txId, tx);
    txId
  };


  public query func getTransactionsById(txIds: [T.TransactionId], txType: ?T.TxType, priceRange: ?[T.Price], mwhRange: ?[T.TokenAmount], method: ?T.TxMethod): async [T.TransactionInfo] {
    let txs = Buffer.Buffer<T.TransactionInfo>(50);

    for(tx in txIds.vals()) {
      switch(transactions.get(tx)) {
        case(null) {};

        case(?txInfo) {
          // filter by mwhRange
          let filterRange: Bool = switch(mwhRange) {
            case(null) true;
            case(?range) txInfo.tokenAmount >= range[0] and txInfo.tokenAmount <= range[1];
          };

          // filter priceRange
          let filterPrice: Bool = switch(priceRange) {
            case(null) true;
            case(?range) txInfo.priceICP.e8s >= range[0].e8s and txInfo.priceICP.e8s <= range[1].e8s;
          };

          // filter by txType
          let filterType: Bool = switch(txType) {
            case(null) true;
            case(?typeTx) txInfo.txType == typeTx;
          };

          // filter by method
          let filterMethod: Bool = switch(method) {
            case(null) true;
            case(?value) txInfo.method == value;
          };

          if (filterType and filterPrice and filterRange and filterMethod) txs.add(txInfo)
        };
      };
    };

    Buffer.toArray<T.TransactionInfo>(txs);
  };
}
