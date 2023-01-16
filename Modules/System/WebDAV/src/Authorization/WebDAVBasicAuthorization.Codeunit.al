codeunit 5680 "WebDAV Basic Authorization"
{
    Access = Public;

    procedure GetWebDAVBasicAuth(Username: Text; Password: Text): Interface "WebDAV Authorization"
    var
        WebDAVBasicAuthImpl: Codeunit "WebDAV Basic Auth. Impl.";
    begin
        WebDAVBasicAuthImpl.SetUserNameAndPassword(Username, Password);
        Exit(WebDAVBasicAuthImpl);
    end;

}