/// <summary>
/// Codeunit Shpfy Communication Events (ID 30200).
/// </summary>
codeunit 30200 "Shpfy Communication Events"
{
    Access = Internal;

    [InternalEvent(false)]
    internal procedure OnClientSend(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
    end;

    [InternalEvent(false)]
    [NonDebuggable]
    internal procedure OnGetAccessToken(var AccessToken: Text)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnGetContent(HttpResponseMessage: HttpResponseMessage; var Response: Text)
    begin
    end;
}
