codeunit 9143 "SharePoint Auth. - Impl."
{
    Access = Internal;

    [NonDebuggable]
    procedure CreateUserCredentials(AadTenantId: Text; ClientId: Text; Login: Text; Password: Text; Scopes: List of [Text]): Interface "SharePoint Authorization";
    var
        SharePointUserCredentials: Codeunit "SharePoint User Credentials";
    begin
        SharePointUserCredentials.SetParameters(AadTenantId, ClientId, Login, Password, Scopes);
        exit(SharePointUserCredentials);
    end;
}