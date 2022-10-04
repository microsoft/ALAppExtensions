codeunit 9143 "SharePoint Auth. - Impl."
{
    Access = Internal;

    [NonDebuggable]
    procedure CreateAuthorizationCode(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scopes: List of [Text]): Interface "SharePoint Authorization";
    var
        SharePointAuthorizationCode: Codeunit "SharePoint Authorization Code";
    begin
        SharePointAuthorizationCode.SetParameters(AadTenantId, ClientId, ClientSecret, Scopes);
        exit(SharePointAuthorizationCode);
    end;
}