/// <summary>Holder object for the HTTP response data.</summary>
codeunit 2353 "AL Http Response Message"
{
    var
        ALHttpContent: Codeunit "AL Http Content";
        HttpResponseMessage: HttpResponseMessage;
        ErrorMessage: Text;
        Initialized: Boolean;
        HasResponse: Boolean;
        NotInitializedErr: Label 'The Http Response Message has not been initialized';

    internal procedure Initialize()
    begin
        Clear(HttpResponseMessage);
        HasResponse := false;
        Initialized := true;
    end;

    /// <summary>Indicates whether the HTTP response message has a success status code.</summary>
    /// <returns>True if the HTTP response message has a success status code; otherwise, false.</returns>
    /// <remarks>Any value in the HTTP status code range 2xx is considered to be successful.</remarks>
    procedure IsSuccessStatusCode() Result: Boolean
    begin
        AssertInitialized();
        if HasResponse then
            Result := HttpResponseMessage.IsSuccessStatusCode;
    end;

    /// <summary>Gets the HTTP status code of the response message.</summary>
    /// <returns>The HTTP status code.</returns>
    procedure HttpStatusCode() ReturnValue: Integer
    begin
        AssertInitialized();
        if HasResponse then
            ReturnValue := HttpResponseMessage.HttpStatusCode
    end;

    /// <summary>Gets the reason phrase which typically is sent by servers together with the status code.</summary>
    /// <returns>The reason phrase sent by the server.</returns>
    procedure ReasonPhrase() ReturnValue: Text
    begin
        AssertInitialized();
        if HasResponse then
            ReturnValue := HttpResponseMessage.ReasonPhrase;
    end;

    /// <summary>Gets the HTTP content sent back by the server.</summary>
    /// <returns>The content of the HTTP response message.</returns>
    procedure Content() ReturnValue: Codeunit "AL Http Content"
    begin
        AssertInitialized();
        if HasResponse then
            ReturnValue := ALHttpContent;
    end;

    /// <summary>Sets the HTTP response message.</summary>
    /// <param name="ResponseMessage">The HTTP response message.</param>
    procedure SetResponseMessage(var ResponseMessage: HttpResponseMessage)
    begin
        AssertInitialized();
        HttpResponseMessage := ResponseMessage;
        ALHttpContent := ALHttpContent.Create(ResponseMessage.Content);
        HasResponse := true;
    end;

    /// <summary>Gets the HTTP response message.</summary>
    /// <returns>The HTTPResponseMessage object.</returns>
    procedure GetResponseMessage() ReturnValue: HttpResponseMessage
    begin
        AssertInitialized();
        ReturnValue := HttpResponseMessage;
    end;

    /// <summary>Sets an error message when the request failed.</summary>
    /// <param name="Value">The error message.</param>
    procedure SetErrorMessage(Value: Text)
    begin
        AssertInitialized();
        ErrorMessage := Value;
    end;

    /// <summary>Gets the error message when the request failed.</summary>
    /// <returns>The error message.</returns>
    procedure GetErrorMessage() ReturnValue: Text
    begin
        AssertInitialized();

        if ErrorMessage <> '' then
            ReturnValue := ErrorMessage
        else
            ReturnValue := GetLastErrorText();
    end;

    local procedure AssertInitialized()
    begin
        if not Initialized then
            Error(NotInitializedErr);
    end;
}