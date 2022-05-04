/// <summary>
/// Codeunit Shpfy Communication Events (ID 30200).
/// </summary>
codeunit 30200 "Shpfy Communication Events"
{
    Access = Internal;

    [InternalEvent(false)]
    internal procedure OnClientSend(HttpRequestMsg: HttpRequestMessage; var HttpResponseMsg: HttpResponseMessage)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnGetAccessToken(var AccessToken: Text)
    begin
    end;

}
