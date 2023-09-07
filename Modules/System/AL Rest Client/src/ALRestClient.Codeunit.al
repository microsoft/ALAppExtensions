/// <summary>Provides functionality to easily work with the HttpClient object.</summary>
codeunit 2350 "AL Rest Client"
{
    var
        ALRestClientImpl: Codeunit "AL Rest Client Impl.";
        IsInitialized: Boolean;

    #region Initialization
    /// <summary>Initializes the AL Rest Client with anonymous authentication.</summary>
    procedure Initialize()
    var
        HttpAuthenticationAnonymous: Codeunit "Http Authentication Anonymous";
    begin
        Initialize(HttpAuthenticationAnonymous);
    end;

    /// <summary>Initializes the AL Rest Client with the given authentication.</summary>
    /// <param name="HttpAuthentication">The authentication to use.</param>
    procedure Initialize(HttpAuthentication: Interface "Http Authentication")
    begin
        ALRestClientImpl.Initialize();
        ALRestClientImpl.SetAuthentication(HttpAuthentication);
        IsInitialized := true;
    end;

    /// <summary>Sets a default request header.</summary>
    /// <remarks>Default request headers will be added to every request that is sent with this AL Rest Client instance
    /// The AL Rest Client will be initialized if it was not initialized before.</remarks>
    /// <param name="Name">The name of the request header.</param>
    /// <param name="Value">The header of request header.</param>
    procedure SetDefaultRequestHeader(Name: Text; Value: Text)
    begin
        if not IsInitialized then
            Initialize();

        ALRestClientImpl.SetDefaultRequestHeader(Name, Value);
    end;

    /// <summary>Sets the base address of the AL Rest Client.</summary>
    /// <remarks>The base address will be used for every request that is sent with this AL Rest Client instance.
    /// Calls to the Get, Post, Patch, Put and Delete methods must  use a relative path which will be appended to the base address.
    /// The AL Rest Client will be initialized if it was not initialized before.</remarks>
    /// <param name="Url">The base address to use.</param>
    procedure SetBaseAddress(Url: Text)
    begin
        if not IsInitialized then
            Initialize();

        ALRestClientImpl.SetBaseAddress(Url);
    end;

    /// <summary>Sets the user agent header of the AL Rest Client.</summary>
    /// <remarks>Use this function to overwrite the default User-Agent header.
    /// The default user agent header is "Dynamics 365 Business Central - |[Publisher]| [App Name]/[App Version]".
    /// The AL Rest Client will be initialized if it was not initialized before.</remarks>
    /// <param name="Value">The user agent header to use.</param>
    procedure SetUserAgentHeader(Value: Text)
    begin
        if not IsInitialized then
            Initialize();

        ALRestClientImpl.SetUserAgentHeader(Value);
    end;
    #endregion

    #region BasicMethods
    /// <summary>Sends a GET request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <returns>The response message object</returns>
    procedure Get(RequestUri: Text) HttpResponseMessage: Codeunit "AL Http Response Message"
    begin
        HttpResponseMessage := Send(Enum::"Http Request Type"::GET, RequestUri);
    end;

    /// <summary>Sends a POST request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send.</param>
    /// <returns>The response message object</returns>
    procedure Post(RequestUri: Text; Content: Codeunit "AL Http Content") HttpResponseMessage: Codeunit "AL Http Response Message"
    begin
        HttpResponseMessage := Send(Enum::"Http Request Type"::POST, RequestUri, Content);
    end;

    /// <summary>Sends a PATCH request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send.</param>
    /// <returns>The response message object</returns>
    procedure Patch(RequestUri: Text; Content: Codeunit "AL Http Content") HttpResponseMessage: Codeunit "AL Http Response Message"
    begin
        HttpResponseMessage := Send(Enum::"Http Request Type"::PATCH, RequestUri, Content);
    end;

    /// <summary>Sends a PUT request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send.</param>
    /// <returns>The response message object</returns>
    procedure Put(RequestUri: Text; Content: Codeunit "AL Http Content") HttpResponseMessage: Codeunit "AL Http Response Message"
    begin
        HttpResponseMessage := Send(Enum::"Http Request Type"::PUT, RequestUri, Content);
    end;

    /// <summary>Sends a DELETE request to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <returns>The response message object</returns>
    procedure Delete(RequestUri: Text) HttpResponseMessage: Codeunit "AL Http Response Message";
    begin
        HttpResponseMessage := Send(Enum::"Http Request Type"::DELETE, RequestUri);
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
        HttpResponseMessage: Codeunit "AL Http Response Message";
    begin
        HttpResponseMessage := Send(Enum::"Http Request Type"::GET, RequestUri);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        JsonToken := HttpResponseMessage.Content().AsJson();
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
        HttpResponseMessage: Codeunit "AL Http Response Message";
    begin
        HttpResponseMessage := Send(Enum::"Http Request Type"::POST, RequestUri, Content);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        Response := HttpResponseMessage.Content().AsJson();
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
        HttpResponseMessage: Codeunit "AL Http Response Message";
    begin
        HttpResponseMessage := Send(Enum::"Http Request Type"::PATCH, RequestUri, Content);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        Response := HttpResponseMessage.Content().AsJson();
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
        HttpResponseMessage: Codeunit "AL Http Response Message";
    begin
        HttpResponseMessage := Send(Enum::"Http Request Type"::PUT, RequestUri, Content);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        Response := HttpResponseMessage.Content().AsJson();
    end;
    #endregion

    #region GenericSendMethods
    /// <summary>Sends a request with the specific Http method and an empty content to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="Method">The HTTP method to use.</param>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <returns>The response message object</returns>
    procedure Send(Method: Enum "Http Request Type"; RequestUri: Text) HttpResponseMessage: Codeunit "AL Http Response Message"
    var
        EmptyALHttpContent: Codeunit "AL Http Content";
    begin
        HttpResponseMessage := Send(Method, RequestUri, EmptyALHttpContent);
    end;

    /// <summary>Sends a request with the specific Http method and the given content and content type to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.
    /// If the content is of type Codeunit (Temp Blob) or InStream, then provide the ContentType parameter as well.</remarks>
    /// <param name="Method">The HTTP method to use.</param>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send. Valid types are: Codeunit (Temp Blob), InStream, JsonObject, JsonArray, Jsontoken, XmlDocument, Text</param>
    /// <returns>The response message object</returns>
    procedure Send(Method: Enum "Http Request Type"; RequestUri: Text; Content: Variant) HttpResponseMessage: Codeunit "AL Http Response Message"
    var
        ALHttpContent: Codeunit "AL Http Content";
    begin
        HttpResponseMessage := Send(Method, RequestUri, ALHttpContent.Create(Content));
    end;

    /// <summary>Sends a request with the specific Http method and the given content and content type to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="Method">The HTTP method to use.</param>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send. Valid types are: Codeunit (Temp Blob), InStream, JsonObject, JsonArray, Jsontoken, XmlDocument, Text</param>
    /// <param name="ContentType">The content type of the content. Only required for content of type Codeunit or InStream.</param>
    /// <returns>The response message object</returns>
    procedure Send(Method: Enum "Http Request Type"; RequestUri: Text; Content: Variant; ContentType: Text) HttpResponseMessage: Codeunit "AL Http Response Message"
    var
        ALHttpContent: Codeunit "AL Http Content";
    begin
        HttpResponseMessage := Send(Method, RequestUri, ALHttpContent.Create(Content, ContentType));
    end;

    /// <summary>Sends a request with the specific Http method and the given content to the specified Uri and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.
    /// If a response was received, then the response message object contains information about the status.</remarks>
    /// <param name="Method">The HTTP method to use.</param>
    /// <param name="RequestUri">The Uri the request is sent to.</param>
    /// <param name="Content">The content to send.</param>
    /// <returns>The response message object</returns>
    procedure Send(Method: Enum "Http Request Type"; RequestUri: Text; Content: Codeunit "AL Http Content") HttpResponseMessage: Codeunit "AL Http Response Message"
    var
        HttpRequestMessage: Codeunit "AL Http Request Message";
    begin
        HttpRequestMessage.Initialize();
        HttpRequestMessage.SetHttpMethod(Method);
        if RequestUri.StartsWith('http://') or RequestUri.StartsWith('https://') then
            HttpRequestMessage.SetRequestUri(RequestUri)
        else
            HttpRequestMessage.SetRequestUri(ALRestClientImpl.GetBaseAddress() + RequestUri);
        HttpRequestMessage.SetContent(Content);

        HttpResponseMessage := Send(HttpRequestMessage);
    end;

    /// <summary>Sends the given request message and returns the response message.</summary>
    /// <remarks>The function fails with an error message if the request could not be sent or a response was not received.</remarks>
    /// <param name="HttpRequestMessage">The request message to send.</param>
    /// <returns>The response message object</returns>
    procedure Send(var HttpRequestMessage: Codeunit "AL Http Request Message") HttpResponseMessage: Codeunit "AL Http Response Message"
    begin
        if not IsInitialized then
            Initialize();

        HttpResponseMessage := ALRestClientImpl.SendRequest(HttpRequestMessage);
        if ALRestClientImpl.HasConnectionError() then
            Error(GetLastErrorText());
    end;
    #endregion
}