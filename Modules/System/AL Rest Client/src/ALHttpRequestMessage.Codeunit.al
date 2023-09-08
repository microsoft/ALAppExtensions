/// <summary>Holder object for the HTTP request data.</summary>
codeunit 2352 "AL Http Request Message"
{
    var
        HttpRequestMessage: HttpRequestMessage;
        Initialized: Boolean;
        NotInitializedErr: Label 'The Http Request Message has been initialized';

    /// <summary>Initializes the HttpRequestMessage object.</summary>
    procedure Initialize()
    begin
        Clear(HttpRequestMessage);
        Initialized := true;
    end;

    /// <summary>Sets the HTTP method or the HttpRequestMessage object.</summary>
    /// <param name="Method">The HTTP method to use. Valid options are GET, POST, PATCH, PUT, DELETE, HEAD, OPTIONS</param>
    /// <remarks>Default method is GET</remarks>
    procedure SetHttpMethod(Method: Text)
    begin
        AssertInitialized();
        HttpRequestMessage.Method := Method;
    end;

    /// <summary>Sets the HTTP method for the HttpRequestMessage object.</summary>
    /// <param name="Method">The HTTP method to use.</param>
    /// <remarks>Default method is GET</remarks>
    procedure SetHttpMethod(Method: Enum "Http Method")
    begin
        SetHttpMethod(Method.Names.Get(Method.Ordinals.IndexOf(Method.AsInteger())));
    end;

    /// <summary>Sets the Uri used for the HttpRequestMessage object.</summary>
    /// <param name="Uri">The Uri to use for the HTTP request.</param>
    /// <remarks>The valued must not be a relative URI.</remarks>
    procedure SetRequestUri(Uri: Text)
    begin
        AssertInitialized();
        HttpRequestMessage.SetRequestUri(Uri);
    end;

    /// <summary>Adds a request header to the HttpRequestMessage object.</summary>
    /// <param name="HeaderName">The name of the header to add.</param>
    /// <param name="HeaderValue">The value of the header to add.</param>
    /// <remarks>If the header already exists, it will be overwritten.</remarks>
    [NonDebuggable]
    procedure AddRequestHeader(HeaderName: Text; HeaderValue: Text)
    var
        RequestHeaders: HttpHeaders;
    begin
        AssertInitialized();
        HttpRequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains(HeaderName) then
            RequestHeaders.Remove(HeaderName);
        RequestHeaders.Add(HeaderName, HeaderValue);
    end;

    /// <summary>Sets the HttpRequestMessage that is represented by the AL HttpRequestMessage object.</summary>
    /// <param name="RequestMessage">The HttpRequestMessage to set.</param>
    procedure SetHttpRequestMessage(var RequestMessage: HttpRequestMessage)
    begin
        AssertInitialized();
        HttpRequestMessage := RequestMessage;
    end;

    /// <summary>Sets the content of the HttpRequestMessage that is represented by the AL HttpRequestMessage object.</summary>
    /// <param name="ALHttpContent">The AL Http Content object to set.</param>
    procedure SetContent(ALHttpContent: Codeunit "AL Http Content")
    begin
        AssertInitialized();
        HttpRequestMessage.Content := ALHttpContent.GetHttpContent();
    end;

    /// <summary>Gets the HttpRequestMessage that is represented by the AL HttpRequestMessage object.</summary>
    /// <returns>The HttpRequestMessage that is represented by the AL HttpRequestMessage object.</returns>
    procedure GetRequestMessage() ReturnValue: HttpRequestMessage
    begin
        AssertInitialized();
        ReturnValue := HttpRequestMessage;
    end;

    local procedure AssertInitialized()
    begin
        if not Initialized then
            Error(NotInitializedErr);
    end;
}