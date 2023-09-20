/// <summary>Provides functionality to easily work with the HttpClient object.</summary>
codeunit 2350 "AL Rest Client"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        RestClientImpl: Codeunit "Rest Client Impl.";
        DefaultHttpClientHandler: Codeunit "Http Client Handler";
        HttpAuthenticationAnonymous: Codeunit "Http Authentication Anonymous";
        IsInitialized: Boolean;

    #region Initialization
    /// <summary>Initializes the Rest Client with the default Http Client Handler and anonymous Http authentication.</summary>
    procedure Initialize()
    begin
        Initialize(DefaultHttpClientHandler, HttpAuthenticationAnonymous);
    end;

    /// <summary>Initializes the Reest Client with the given Http Client Handler</summary>
    /// <param name="HttpClientHandler">The Http Client Handler to use.</param>
    /// <remarks>The anynomous Http Authentication will be used.</remarks>
    procedure Initialize(HttpClientHandler: Interface "Http Client Handler")
    var
        HttpAuthenticationAnonymous: Codeunit "Http Authentication Anonymous";
    begin
        Initialize(HttpClientHandler, HttpAuthenticationAnonymous);
    end;

    /// <summary>Initializes the Rest Client with the given Http Authentication.</summary>
    /// <param name="HttpAuthentication">The authentication to use.</param>
    /// <remarks>The default Http Client Handler will be used.</remarks>
    procedure Initialize(HttpAuthentication: Interface "Http Authentication")
    begin
        Initialize(DefaultHttpClientHandler, HttpAuthentication);
    end;

    /// <summary>Initializes the Rest Client with the given Http Client Handler and Http Authentication.</summary>
    /// <param name="HttpClientHandler">The Http Client Handler to use.</param>
    /// <param name="HttpAuthentication">The authentication to use.</param>
    procedure Initialize(HttpClientHandler: Interface "Http Client Handler"; HttpAuthentication: Interface "Http Authentication")
    begin
        RestClientImpl.Initialize(HttpClientHandler, HttpAuthentication);
        IsInitialized := true;
    end;

    /// <summary>Sets a new value for an existing default header of the Http Client object, or addds the header if it does not already exist.</summary>
    /// <param name="Name">The name of the request header.</param>
    /// <param name="Value">The header of request header.</param>
    /// <remarks>Default request headers will be added to every request that is sent with this Rest Client instance
    /// The Rest Client will be initialized if it was not initialized before.</remarks>
    procedure SetDefaultRequestHeader(Name: Text; Value: Text)
    begin
        if not IsInitialized then
            Initialize();

        RestClientImpl.SetDefaultRequestHeader(Name, Value);
    end;

    /// <summary>Sets a new value for an existing default header of the Http Client object, or addds the header if it does not already exist.</summary>
    /// <param name="Name">The name of the request header.</param>
    /// <param name="Value">The header of request header.</param>
    /// <remarks>Default request headers will be added to every request that is sent with this Rest Client instance
    /// The Rest Client will be initialized if it was not initialized before.</remarks>
    procedure SetDefaultRequestHeader(Name: Text; Value: SecretText)
    begin
        if not IsInitialized then
            Initialize();

        RestClientImpl.SetDefaultRequestHeader(Name, Value);
    end;

    /// <summary>Sets the base address of the Rest Client.</summary>
    /// <remarks>The base address will be used for every request that is sent with this Rest Client instance.
    /// Calls to the Get, Post, Patch, Put and Delete methods must  use a relative path which will be appended to the base address.
    /// The Rest Client will be initialized if it was not initialized before.</remarks>
    /// <param name="Url">The base address to use.</param>
    procedure SetBaseAddress(Url: Text)
    begin
        if not IsInitialized then
            Initialize();

        RestClientImpl.SetBaseAddress(Url);
    end;

    /// <summary>Gets the base address of the Rest Client.</summary>
    /// <returns>The base address of the Rest Client.</returns>
    procedure GetBaseAddress() Url: Text
    begin
        Url := RestClientImpl.GetBaseAddress();
    end;

    /// <summary>Sets the timeout of the Rest Client.</summary>
    /// <param name="Timeout">The timeout to use.</param>
    /// <remarks>The timeout will be used for every request that is sent with this Rest Client instance.
    /// The Rest Client will be initialized if it was not initialized before.</remarks>
    procedure SetTimeOut(Timeout: Duration)
    begin
        if not IsInitialized then
            Initialize();

        RestClientImpl.SetTimeOut(Timeout);
    end;

    /// <summary>Gets the timeout of the Rest Client.</summary>
    /// <returns>The timeout of the Rest Client.</returns>
    procedure GetTimeOut() Timeout: Duration
    begin
        Timeout := RestClientImpl.GetTimeOut();
    end;

    /// <summary>Adds a certificate to the Rest Client.</summary>
    /// <param name="Certificate">The Base64 encoded certificate</param>
    /// <remarks>The certificate will be used for every request that is sent with this Rest Client instance.
    /// The Rest Client will be initialized if it was not initialized before.</remarks>
    procedure AddCertificate(Certificate: Text)
    begin
        if not IsInitialized then
            Initialize();
        RestClientImpl.AddCertificate(Certificate);
    end;

    /// <summary>Adds a certificate to the Rest Client.</summary>
    /// <param name="Certificate">The Base64 encoded certificate</param>
    /// <param name="Password">The password of the certificate</param>
    /// <remarks>The certificate will be used for every request that is sent with this Rest Client instance.
    /// The Rest Client will be initialized if it was not initialized before.</remarks>

    procedure AddCertificate(Certificate: Text; Password: SecretText)
    begin
        if not IsInitialized then
            Initialize();
        RestClientImpl.AddCertificate(Certificate, Password);
    end;

    /// <summary>Sets the user agent header of the Rest Client.</summary>
    /// <remarks>Use this function to overwrite the default User-Agent header.
    /// The default user agent header is "Dynamics 365 Business Central - |[Publisher]| [App Name]/[App Version]".
    /// The Rest Client will be initialized if it was not initialized before.</remarks>
    /// <param name="Value">The user agent header to use.</param>
    procedure SetUserAgentHeader(Value: Text)
    begin
        if not IsInitialized then
            Initialize();

        RestClientImpl.SetUserAgentHeader(Value);
    end;

    /// <summary>Sets the authorization header of the Rest Client.</summary>
    /// <remarks>Use this function to set the authorization header.
    /// The Rest Client will be initialized if it was not initialized before.</remarks>
    /// <param name="Value">The authorization header to use.</param>
    procedure SetAuthorizationHeader(Value: SecretText)
    begin
        SetDefaultRequestHeader('Authorization', Value);
    end;
    #endregion

    #region BasicMethods
    /// <summary>Sends a GET request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <returns>The response message object</returns>
    procedure Get(RequestUri: Text) HttpResponseMessage: Codeunit "Http Response Message"
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::GET, RequestUri);
    end;

    /// <summary>Sends a POST request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send.</param>
    /// <returns>The response message object</returns>
    procedure Post(RequestUri: Text; Content: Codeunit "Http Content") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::POST, RequestUri, Content);
    end;

    /// <summary>Sends a PATCH request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send.</param>
    /// <returns>The response message object</returns>
    procedure Patch(RequestUri: Text; Content: Codeunit "Http Content") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::PATCH, RequestUri, Content);
    end;

    /// <summary>Sends a PUT request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send.</param>
    /// <returns>The response message object</returns>
    procedure Put(RequestUri: Text; Content: Codeunit "Http Content") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::PUT, RequestUri, Content);
    end;

    /// <summary>Sends a DELETE request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <returns>The response message object</returns>
    procedure Delete(RequestUri: Text) HttpResponseMessage: Codeunit "Http Response Message";
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::DELETE, RequestUri);
    end;

    #endregion

    #region BasicMethodsAsJson
    /// <summary>Sends a GET request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure GetAsJson(RequestUri: Text) JsonToken: JsonToken
    var
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::GET, RequestUri);
        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        JsonToken := HttpResponseMessage.GetContent().AsJson();
    end;

    /// <summary>Sends a POST request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send as a JsonObject.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure PostAsJson(RequestUri: Text; Content: JsonObject) Response: JsonToken
    begin
        Response := PostAsJson(RequestUri, Content.AsToken());
    end;

    /// <summary>Sends a POST request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send as a JsonArray.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure PostAsJson(RequestUri: Text; Content: JsonArray) Response: JsonToken
    begin
        Response := PostAsJson(RequestUri, Content.AsToken());
    end;

    /// <summary>Sends a POST request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send as a JsonToken.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure PostAsJson(RequestUri: Text; Content: JsonToken) Response: JsonToken
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        HttpContent: Codeunit "Http Content";
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::POST, RequestUri, HttpContent.Create(Content));

        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        Response := HttpResponseMessage.GetContent().AsJson();
    end;

    /// <summary>Sends a PATCH request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send as a JsonObject.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure PatchAsJson(RequestUri: Text; Content: JsonObject) Response: JsonToken
    begin
        Response := PatchAsJson(RequestUri, Content.AsToken());
    end;

    /// <summary>Sends a PATCH request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send as a JsonArray.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure PatchAsJson(RequestUri: Text; Content: JsonArray) Response: JsonToken
    begin
        Response := PatchAsJson(RequestUri, Content.AsToken());
    end;

    /// <summary>Sends a PATCH request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send as a JsonToken.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure PatchAsJson(RequestUri: Text; Content: JSonToken) Response: JsonToken
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        HttpContent: Codeunit "Http Content";
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::PATCH, RequestUri, HttpContent.Create(Content));

        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        Response := HttpResponseMessage.GetContent().AsJson();
    end;

    /// <summary>Sends a PUT request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send as a JsonObject.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure PutAsJson(RequestUri: Text; Content: JsonObject) Response: JsonToken
    begin
        Response := PutAsJson(RequestUri, Content.AsToken());
    end;

    /// <summary>Sends a PUT request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send as a JsonArray.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure PutAsJson(RequestUri: Text; Content: JsonArray) Response: JsonToken
    begin
        Response := PutAsJson(RequestUri, Content.AsToken());
    end;

    /// <summary>Sends a PUT request to the specified Uri and returns the response content as JsonToken.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// The function also fails in case the response does not contain a success status code or a valid JSON content.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send as a JsonToken.</param>
    /// <returns>The response content as JsonToken</returns>
    procedure PutAsJson(RequestUri: Text; Content: JSonToken) Response: JsonToken
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        HttpContent: Codeunit "Http Content";
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::PUT, RequestUri, HttpContent.Create(Content));

        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        Response := HttpResponseMessage.GetContent().AsJson();
    end;
    #endregion

    #region GenericSendMethods
    /// <summary>Sends a request with the specific Http method and an empty content to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="Method">The HTTP method to use.</param>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <returns>The response message object</returns>
    procedure Send(Method: Enum "Http Method"; RequestUri: Text) HttpResponseMessage: Codeunit "Http Response Message"
    var
        EmptyHttpContent: Codeunit "Http Content";
    begin
        HttpResponseMessage := Send(Method, RequestUri, EmptyHttpContent);
    end;

    /// <summary>Sends a request with the specific Http method and the given content to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="Method">The HTTP method to use.</param>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send.</param>
    /// <returns>The response message object</returns>
    procedure Send(Method: Enum "Http Method"; RequestUri: Text; Content: Codeunit "Http Content") HttpResponseMessage: Codeunit "Http Response Message"
    var
        HttpRequestMessage: Codeunit "Http Request Message";
    begin
        HttpRequestMessage.SetHttpMethod(Method);
        if RequestUri.StartsWith('http://') or RequestUri.StartsWith('https://') then
            HttpRequestMessage.SetRequestUri(RequestUri)
        else
            HttpRequestMessage.SetRequestUri(RestClientImpl.GetBaseAddress() + RequestUri);
        HttpRequestMessage.SetContent(Content);

        HttpResponseMessage := Send(HttpRequestMessage);
    end;

    /// <summary>Sends the given request message and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.</remarks>
    /// <param name="HttpRequestMessage">The request message to send.</param>
    /// <returns>The response message object</returns>
    procedure Send(var HttpRequestMessage: Codeunit "Http Request Message") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        if not IsInitialized then
            Initialize();

        if not RestClientImpl.SendRequest(HttpRequestMessage, HttpResponseMessage) then
            Error(HttpResponseMessage.GetErrorMessage());
    end;
    #endregion
}