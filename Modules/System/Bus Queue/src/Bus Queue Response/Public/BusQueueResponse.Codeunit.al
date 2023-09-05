/// <summary>
/// Codeunit that allows to read a Bus Queue Response.
/// </summary>
codeunit 51758 "Bus Queue Response"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        BusQueueResponseImpl: Codeunit "Bus Queue Response Impl.";

    /// <summary>
    /// Gets the headers
    /// </summary>
    /// <returns>Response headers</returns>
    procedure GetHeaders(): InStream
    begin
        exit(BusQueueResponseImpl.GetHeaders());
    end;

    /// <summary>
    /// Gets the body
    /// </summary>
    /// <returns>Response body in InStream format</returns>
    procedure GetBody(): InStream
    begin
        exit(BusQueueResponseImpl.GetBody());
    end;

    /// <summary>
    /// Gets the HTTP code
    /// </summary>
    /// <returns>The HTTP code of the response</returns>
    procedure GetHTTPCode(): Integer
    begin
        exit(BusQueueResponseImpl.GetHTTPCode());
    end;

    /// <summary>
    /// Gets the reason phrase
    /// </summary>
    /// <returns>The reason phrase code of the response</returns>
    procedure GetReasonPhrase(): Text
    begin
        exit(BusQueueResponseImpl.GetReasonPhrase());
    end;

    /// <summary>
    /// Gets the RecordId
    /// </summary>
    /// <returns>The RecordId saved in the Bus Queue</returns>
    procedure GetRecordId(): RecordId
    begin
        exit(BusQueueResponseImpl.GetRecordId());
    end;

    /// <summary>
    /// Gets the SystemId
    /// </summary>
    /// <returns>The SystemId saved in the Bus Queue</returns>
    procedure GetSystemId(): Guid
    begin
        exit(BusQueueResponseImpl.GetSystemId());
    end;

    internal procedure SetBusQueueResponse(BusQueueResponse: Record "Bus Queue Response")
    begin
        BusQueueResponseImpl.SetBusQueueResponse(BusQueueResponse);
    end;
}