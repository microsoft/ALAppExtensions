/// <summary>
/// Stores detailed information about failed api call
/// </summary>
codeunit 9111 "SharePoint Diagnostics"
{
    Access = Public;

    var
        ErrorMessage, ResponseReasonPhrase : Text;

        HttpStatusCode, RetryAfter : Integer;

        IsSuccessStatusCode: Boolean;

    /// <summary>
    /// Gets reponse details
    /// </summary>
    /// <returns>HttpResponseMessage.IsSuccessStatusCode</returns>
    procedure GetIsSuccessStatusCode(): Boolean
    begin
        exit(IsSuccessStatusCode);
    end;

    /// <summary>
    /// Gets reponse details
    /// </summary>
    /// <returns>HttpResponseMessage.StatusCode</returns>
    procedure GetHttpStatusCode(): Integer
    begin
        exit(HttpStatusCode);
    end;

    /// <summary>
    /// Gets reponse details
    /// </summary>
    /// <returns>Retry-after header value</returns>
    procedure GetHttpRetryAfter(): Integer
    begin
        exit(RetryAfter);
    end;

    /// <summary>
    /// Gets reponse details
    /// </summary>
    /// <returns>Error message</returns>
    procedure GetErrorMessage(): Text
    begin
        exit(ErrorMessage);
    end;

    /// <summary>
    /// Gets reponse details
    /// </summary>
    /// <returns>HttpResponseMessage.ResponseReasonPhrase</returns>
    procedure GetResponseReasonPhrase(): Text
    begin
        exit(ResponseReasonPhrase);
    end;

    internal procedure SetParameters(NewIsSuccesss: Boolean; NewHttpStatusCode: Integer; NewResponseReasonPhrase: Text; NewRetryAfter: Integer; NewErrorMessage: Text)
    begin
        IsSuccessStatusCode := NewIsSuccesss;
        HttpStatusCode := NewHttpStatusCode;
        ResponseReasonPhrase := NewResponseReasonPhrase;
        RetryAfter := NewRetryAfter;
        ErrorMessage := NewErrorMessage;
    end;
}