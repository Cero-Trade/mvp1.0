import Error "mo:base/Error";

import MarketplaceTypes = "./marketplace_types";
import HM = "mo:base/HashMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";

// types
import T "../types";

actor Marketplace {

  var tokensInMarket : HM.HashMap<T.TokenId, T.TokenMarketInfo> = HM.HashMap(100, Text.equal, Text.hash);
  stable var tokensInMarketEntries : [(T.TokenId, T.TokenAmount, [(T.UID, T.UserTokenInfo)])] = [];

  /// funcs to persistent collection state
  system func preupgrade() {
    let marketplace = Buffer.Buffer<(T.TokenId, T.TokenAmount, [(T.UID, T.UserTokenInfo)])>(100);

    for ((tokenId, value) in tokensInMarket.entries()) {
      let usersxToken = Buffer.Buffer<((T.UID, T.UserTokenInfo))>(100);

      for ((key2, value2) in value.usersxToken.entries()) {
        usersxToken.add( (key2, value2) )
      };

      marketplace.add( (tokenId, value.totalQuantity, Buffer.toArray<(T.UID, T.UserTokenInfo)>(usersxToken)) );
    };

    tokensInMarketEntries := Buffer.toArray<(T.TokenId, T.TokenAmount, [(T.UID, T.UserTokenInfo)])>(marketplace)
  };

  system func postupgrade() {
    for ((key, totalQuantity, users) in tokensInMarketEntries.vals()) {
      var usersxToken = HM.HashMap<T.UID, T.UserTokenInfo>(100, Principal.equal, Principal.hash);

      for ((key2, value2) in users.vals()) {
        usersxToken.put(key2, value2);
      };

      tokensInMarket.put(key, { totalQuantity; usersxToken });
    };
  };



  // check if token is already on the market
  public func isOnMarket(tokenId : T.TokenId) : async Bool {
    switch (tokensInMarket.get(tokenId)) {
      case (null) { return false };
      case (?_) { return true };
    };
  };

  // check if user is already selling a token
  public func isSellingToken(user : T.UID, tokenId : T.TokenId) : async Bool {
      switch (tokensInMarket.get(tokenId)) {
          case (null) { return false };
          case (?info) {
              switch (info.usersxToken.get(user)) {
                  case (null) {
                      return false;
                  };
                  case (?info) {
                      return true;
                  };
              };
          };
      };
  };

  // new token in market
  public func newTokensInMarket(tokenId : T.TokenId, user : T.UID, quantity : T.TokenAmount, priceICP: T.Price) : async () {
      // user is selling a new token
      let usersxToken = HM.HashMap<T.UID, T.UserTokenInfo>(4, Principal.equal, Principal.hash);

      let userxTokenInfo = {
          quantity;
          priceICP;
      };

      usersxToken.put(user, userxTokenInfo);

      // update the market info for the token
      let tokenMarketInfo = {
          totalQuantity = quantity;
          usersxToken = usersxToken;
      };

      // add new information to the token market info
      tokensInMarket.put(tokenId, tokenMarketInfo);
  };

  // update token information
  public func updatetokenMarketInfo(user : T.UID, tokenId : T.TokenId, quantity : T.TokenAmount, priceICP: T.Price) : async () {
      switch (tokensInMarket.get(tokenId)) {
          case (null) {
              throw Error.reject("Token not found in the market");
          };
          case (?info) {
              // Update the existing sale
              switch (info.usersxToken.get(user)) {
                  case (null) {
                      throw Error.reject("User is not selling this token");
                  };
                  case (?usersxTokenInfo) {
                      // update the quantity
                      let newQuantity = usersxTokenInfo.quantity + quantity;

                      let updatedUserxToken = {
                          quantity = newQuantity;
                          priceICP;
                      };

                      info.usersxToken.put(user, updatedUserxToken);
                      // update tokens in market quantity
                      let updatedQuantity = info.totalQuantity + quantity;
                      let updatedInfo = {
                          totalQuantity = updatedQuantity;
                          usersxToken = info.usersxToken;
                      };
                      tokensInMarket.put(tokenId, updatedInfo);
                  };
              };
          };
      };
  };

  // handles new token information on market
  public func putOnSale(tokenId : T.TokenId, quantity : T.TokenAmount, user : T.UID, priceICP: T.Price) : async () {
      // Check if the user is already selling the token
      let isSelling = await isSellingToken(user, tokenId);
      if (isSelling != false) {
          // update the existing sale
          await updatetokenMarketInfo(user, tokenId, quantity, priceICP);
      } else {
          // add the new sale
          await newTokensInMarket(tokenId, user, quantity, priceICP);
      };
  };

  // check how many token id is available for sale
  public func getAvailableTokens(tokenId : T.TokenId) : async T.TokenAmount {
      switch (tokensInMarket.get(tokenId)) {
          case (null) {
              return 0;
          };
          case (?info) {
              return info.totalQuantity;
          };
      };
  };

  // check how many token id is being sold by a user
  public func getUserTokensOnSale(user : T.UID, tokenId : T.TokenId) : async T.TokenAmount {
      switch (tokensInMarket.get(tokenId)) {
          case (null) {
              return 0;
          };
          case (?info) {
              switch (info.usersxToken.get(user)) {
                  case (null) {
                      return 0;
                  };
                  case (?usersxTokenInfo) {
                      return usersxTokenInfo.quantity;
                  };
              };
          };
      };
  };

  // check price of a token on the market of a user
  public func getTokenPrice(tokenId : T.TokenId, user : T.UID) : async T.Price {
      switch (tokensInMarket.get(tokenId)) {
          case (null) {
              throw Error.reject("Token not found in the market");
          };
          case (?info) {
              switch (info.usersxToken.get(user)) {
                  case (null) {
                      throw Error.reject("User is not selling this token");
                  };
                  case (?usersxTokenInfo) {
                      return usersxTokenInfo.priceICP;
                  };
              };
          };
      };
  };

  // handles reducing token offer from the market
  public func takeOffSale(tokenId: T.TokenId, quantity: T.TokenAmount, user: T.UID): async () {

      switch (tokensInMarket.get(tokenId)) {
          case (null) {
              throw Error.reject("Token not found in the market");
          };
          case(?tokenMarket) {
              switch (tokenMarket.usersxToken.get(user)) {
                  case (null){
                      throw Error.reject("User's token not found in the market");
                  };
                  case (?userTokenInfo) {
                      let newQuantity: T.TokenAmount = userTokenInfo.quantity - quantity;
                      // if the new quantity is 0, remove the user from tokensxuser
                      if (newQuantity == 0) {
                          await deleteUserTokenfromMarket(tokenId, user);
                          let newTotalQuantity: T.TokenAmount = tokenMarket.totalQuantity - quantity;
                          // if the new total quantity is 0, remove the token from the market
                          if (newTotalQuantity == 0) {
                              await deleteTokensInMarket(tokenId);
                          } else if (newTotalQuantity > 0) {
                              // Update the total quantity in the market info
                              await reduceTotalQuantity(tokenId, quantity);
                          } else {
                              throw Error.reject("Token quantity cannot be less than 0");
                          };
                      } else if (newQuantity > 0) {
                          // Update the user's token quantity and market info
                          await reduceOffer(tokenId, quantity, user);
                          await reduceTotalQuantity(tokenId, quantity);
                      } else {
                          throw Error.reject("User's token quantity cannot be less than 0");
                      };
                  };
              };
          };
      };
  };

  // Function to delete a user's token from the market
  public func deleteUserTokenfromMarket(tokenId: T.TokenId, user: T.UID): async () {
      switch (tokensInMarket.get(tokenId)) {
          case (null){
              throw Error.reject("Token not found in the market");
          };
          case (?info) {
              switch (info.usersxToken.get(user)) {
                  case (null) {
                      throw Error.reject("User not found in the market for this token")
                  };
                  case (?_) {
                      info.usersxToken.delete(user);
                  };
              };
          };
      };
  };

  // Function to reduce the total quantity of a token in the market
  public func reduceTotalQuantity(tokenId: T.TokenId, quantity: T.TokenAmount): async () {
      switch (tokensInMarket.get(tokenId)) {
          case (null) {
              throw Error.reject("Token not found in the market");
          };
          case (?info) {
              let newTotalQuantity: Nat = info.totalQuantity - quantity;
              if (newTotalQuantity > 0) {
                  let updatedInfo = {
                      totalQuantity = Int.abs(newTotalQuantity);
                      usersxToken = info.usersxToken;
                  };
                  tokensInMarket.put(tokenId, updatedInfo);
              } else if (newTotalQuantity == 0) {
                  await deleteTokensInMarket(tokenId);
              } else {
                  throw Error.reject("Token quantity cannot be less than 0");
              };
          };
      };
  };

  // Function to reduce the offer of a token in the market
  public func reduceOffer(tokenId: T.TokenId, quantity: T.TokenAmount, user: T.UID): async () {
      switch (tokensInMarket.get(tokenId)) {
          case (null) {
              throw Error.reject("Token not found in the market");
          };
          case (?info) {
              switch (info.usersxToken.get(user)) {
                  case (null) {
                      throw Error.reject("User not found in the market for this token");
                  };
                  case (?userTokenInfo) {
                      let newUserQuantity: Nat = userTokenInfo.quantity - quantity;

                      if (newUserQuantity > 0) {
                          let newUserTokenInfo = { userTokenInfo with quantity = Int.abs(newUserQuantity) };
                          info.usersxToken.put(user, newUserTokenInfo);
                      } else if (newUserQuantity == 0) {
                          await deleteUserTokenfromMarket(tokenId, user);
                      } else {
                          throw Error.reject("User's token quantity cannot be less than 0");
                      };
                  };
              };
          };
      };
  };

  
  private func getMinMax(hashmap: HM.HashMap<T.UID, T.UserTokenInfo>): (?T.Price, ?T.Price) {
    var min : ?T.Price = null;
    var max : ?T.Price = null;

    for ((_, data) in hashmap.entries()) {
      switch (min) {
        case (null) { min := ?data.priceICP; };
        case (?m) {
          if (data.priceICP.e8s < m.e8s) {
            min := ?data.priceICP;
          };
        };
      };
      switch (max) {
        case (null) { max := ?data.priceICP; };
        case (?m) {
          if (data.priceICP.e8s > m.e8s) {
            max := ?data.priceICP;
          };
        };
      };
    };

    return (min, max);
  };

  // function to get marketplace
  public query func getMarketplace(): async [{
    tokenId: T.TokenId;
    mwh: T.TokenAmount;
    lowerPriceICP: T.Price;
    higherPriceICP: T.Price;
  }] {
    let marketplace = Buffer.Buffer<{
      tokenId: T.TokenId;
      mwh: T.TokenAmount;
      lowerPriceICP: T.Price;
      higherPriceICP: T.Price;
    }>(100);

    for ((tokenId, value) in tokensInMarket.entries()) {
      let (min, max) = getMinMax(value.usersxToken);

      marketplace.add({
        tokenId;
        mwh = value.totalQuantity;
        lowerPriceICP = switch(min) {
          case(null) { { e8s = 0 } };
          case(?value) value;
        };
        higherPriceICP = switch(max) {
          case(null) { { e8s = 0 } };
          case(?value) value;
        };
      });
    };

    Buffer.toArray<{
      tokenId: T.TokenId;
      mwh: T.TokenAmount;
      lowerPriceICP: T.Price;
      higherPriceICP: T.Price;
    }>(marketplace);
  };

  // Function to delete a token from the market
  public func deleteTokensInMarket(tokenId: T.TokenId): async () {
      tokensInMarket.delete(tokenId);
  };
};
