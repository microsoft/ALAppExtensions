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
    procedure MakeCollection(CollectionName: Text): Boolean
    begin
        Exit(WebDAVClientImpl.MakeCollection(CollectionName));
    end;

    // [NonDebuggable]
    procedure Delete(MemberName: Text): Boolean
    begin
        Exit(WebDAVClientImpl.Delete(MemberName));
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
    procedure GetFilesAndCollections(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    begin
        Exit(WebDAVClientImpl.GetFilesAndCollections(WebDAVContent, Recursive));
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

    /// <summary>
    /// Returns detailed information on last API call.
    /// </summary>
    /// <returns>Codeunit holding http resonse status, reason phrase, headers and possible error information for tha last API call</returns>
    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(WebDAVClientImpl.GetDiagnostics());
    end;

    [TryFunction]
    procedure GetResponseAsText(var Response: Text)
    begin
        WebDAVClientImpl.GetResponseAsText(Response);
    end;

    [TryFunction]
    internal procedure GetResponseAsStream(var ResponseInStream: InStream)
    begin
        WebDAVClientImpl.GetResponseAsStream(ResponseInStream);
    end;

}