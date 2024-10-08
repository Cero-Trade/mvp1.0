import Error "mo:base/Error";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";

// types
import ENV "../env";

module HttpServiceInterface {
  public let canister: HttpService = actor (ENV.CANISTER_ID_HTTP_SERVICE);
  public let apiUrl: Text = ENV.VITE_API_URL;
  public let headerName = "http_service_canister";

  public func tokenAuth(token: Text): { name: Text; value: Text; } {
    { name = "token"; value = token; }
  };

  public type HttpError = {
    status : Nat;
    body : Text;
  };

  public func httpError(http_error: HttpError): Error {
    Error.reject("Http status: " # Nat.toText(http_error.status) # "\n" # "Http body: " # http_error.body)
  };

  public type Result<S, E> = {
    #ok : S;
    #err : E;
  };

  public type Timestamp = Nat64;

  //1. Type that describes the Request arguments for an HTTPS outcall
  //See: https://internetcomputer.org/docs/current/references/ic-interface-spec/#ic-http_request
  public type HttpRequestArgs = {
    url : Text;
    max_response_bytes : ?Nat64;
    headers : [HttpHeader];
    body : ?[Nat8];
    method : HttpMethod;
    transform : ?TransformRawResponseFunction;
  };

  public type HttpHeader = {
    name : Text;
    value : Text;
  };

  public type HttpMethod = {
    #get;
    #post;
    #head;
  };

  public type HttpResponsePayload = {
    status : Nat;
    headers : [HttpHeader];
    body : [Nat8];
  };

  //2. HTTPS outcalls have an optional "transform" key. These two types help describe it.
  //"The transform function may, for example, transform the body in any way, add or remove headers,
  //modify headers, etc. "
  //See: https://internetcomputer.org/docs/current/references/ic-interface-spec/#ic-http_request


  //2.1 This type describes a function called "TransformRawResponse" used in line 14 above
  //"If provided, the calling canister itself must export this function."
  //In this minimal example for a `GET` request, you declare the type for completeness, but
  //you do not use this function. You will pass "null" to the HTTP request.
  public type TransformRawResponseFunction = {
    function : shared query TransformArgs -> async HttpResponsePayload;
    context : Blob;
  };

  //2.2 These types describes the arguments the transform function needs
  public type TransformArgs = {
    response : HttpResponsePayload;
    context : Blob;
  };

  public type CanisterHttpResponsePayload = {
    status : Nat;
    headers : [HttpHeader];
    body : [Nat8];
  };

  public type TransformContext = {
    function : shared query TransformArgs -> async HttpResponsePayload;
    context : Blob;
  };



  //3. Declaring the management canister which you use to make the HTTPS outcall
  public type IC = actor {
    http_request : HttpRequestArgs -> async HttpResponsePayload;
  };

  public type HttpService = actor {
    get: ({ url: Text; port: ?Text; uid: ?Principal; headers: [HttpHeader]; }) -> async Text;
    post: ({ url: Text; port: ?Text; uid: ?Principal; headers: [HttpHeader]; bodyJson: Text }) -> async Text;
  };
}