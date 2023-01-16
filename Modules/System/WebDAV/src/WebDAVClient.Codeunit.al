codeunit 5678 "WebDAV Client"
{
    Access = Public;

    var
        WebDAVClientImpl: Codeunit "WebDAV Client Impl.";

    procedure Initialize(BaseUrl: Text; WebDAVAuthorization: Interface "WebDAV Authorization")
    begin
        WebDAVClientImpl.Initialize(BaseUrl, WebDAVAuthorization);
    end;

    // [NonDebuggable]
    procedure MakeCollection(): Boolean
    begin
        Exit(WebDAVClientImpl.MakeCollection());
    end;

    // [NonDebuggable]
    procedure Delete(): Boolean
    begin
        Exit(WebDAVClientImpl.Delete());
    end;

    // [NonDebuggable]
    procedure Move(Destination: Text): Boolean
    begin
        Exit(WebDAVClientImpl.Move(Destination));
    end;

    // [NonDebuggable]
    procedure Copy(Destination: Text): Boolean
    begin
        Exit(WebDAVClientImpl.Copy(Destination));
    end;

    // [NonDebuggable]
    procedure Put(Content: Text): Boolean
    begin
        Exit(WebDAVClientImpl.Put(Content));
    end;

    // [NonDebuggable]
    procedure Put(Content: InStream): Boolean
    begin
        Exit(WebDAVClientImpl.Put(Content));
    end;

    // [NonDebuggable]
    procedure Put(Content: HttpContent): Boolean
    begin
        Exit(WebDAVClientImpl.Put(Content));
    end;

    // [NonDebuggable]
    procedure GetContent(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    begin
        Exit(WebDAVClientImpl.GetContent(WebDAVContent, Recursive));
    end;

    // [NonDebuggable]
    procedure GetCollections(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    begin
        Exit(WebDAVClientImpl.GetCollections(WebDAVContent, Recursive));
    end;

    // [NonDebuggable]
    procedure GetFiles(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    begin
        Exit(WebDAVClientImpl.GetFiles(WebDAVContent, Recursive));
    end;

    [NonDebuggable]
    procedure GetFileContent(var ResponseInStream: InStream): Boolean
    begin
        Exit(WebDAVClientImpl.GetFileContent(ResponseInStream));
    end;

    [NonDebuggable]
    procedure GetFileContentAsText(var ResponseText: Text): Boolean
    begin
        Exit(WebDAVClientImpl.GetFileContentAsText(ResponseText));
    end;
}