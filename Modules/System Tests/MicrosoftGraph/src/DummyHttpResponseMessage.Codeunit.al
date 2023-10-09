codeunit 135144 "Dummy - HttpResponseMessage" implements IHttpResponseMessage
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure IsBlockedByEnvironment(): Boolean;
    begin
    end;

    procedure IsSuccessStatusCode(): Boolean;
    begin
    end;

    procedure HttpStatusCode(): Integer;
    begin
    end;

    procedure ReasonPhrase(): Text;
    begin
    end;

    procedure Content(): HttpContent;
    begin
    end;

    procedure Headers(): HttpHeaders;
    begin
    end;
}