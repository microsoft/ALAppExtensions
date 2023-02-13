codeunit 5679 "WebDAV Client Impl."
{
    Access = Internal;

    var

        [NonDebuggable]
        WebDAVOperationResponse: Codeunit "WebDAV Operation Response";
        [NonDebuggable]
        Authorization: Interface "WebDAV Authorization";
        [NonDebuggable]
        Uri: Text;

    [NonDebuggable]
    procedure Initialize(InitUri: Text; InitAuthorization: Interface "WebDAV Authorization")
    begin
        Uri := InitUri;
        Authorization := InitAuthorization;
    end;

    [NonDebuggable]
    procedure MakeCollection(CollectionName: Text): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.MkCol(Uri, CollectionName);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            Exit(false);

        Exit(true);
    end;

    [NonDebuggable]
    procedure Delete(MemberName: Text): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Delete(Uri, MemberName);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            Exit(false);

        Exit(true);
    end;


    [NonDebuggable]
    procedure Put(Content: InStream): Boolean
    var
        HttpContent: HttpContent;
    begin
        HttpContent.WriteFrom(Content);
        Exit(Put(HttpContent));
    end;

    [NonDebuggable]
    procedure Put(Content: Text): Boolean
    var
        HttpContent: HttpContent;
    begin
        HttpContent.WriteFrom(Content);
        Exit(Put(HttpContent));
    end;

    [NonDebuggable]
    procedure Put(Content: HttpContent): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Put(Uri, Content);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            Exit(false);

        Exit(true);
    end;

    [NonDebuggable]
    procedure Move(Destination: Text): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Move(Uri, Destination);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            Exit(false);

        Exit(true);
    end;


    [NonDebuggable]
    procedure Copy(Destination: Text): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Copy(Uri, Destination);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            Exit(false);

        Exit(true);
    end;


    [NonDebuggable]
    procedure GetFilesAndCollections(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    var
        WebDAVContentParser: Codeunit "WebDAV Content Parser";
        ResponseContent: Text;
    begin
        ResponseContent := GetPropfindResponse(Recursive);

        WebDAVContentParser.Initialize(Uri, false, false);
        WebDAVContentParser.Parse(ResponseContent, WebDAVContent);

        Exit(true);
    end;

    [NonDebuggable]
    procedure GetCollections(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    var
        WebDAVContentParser: Codeunit "WebDAV Content Parser";
        ResponseContent: Text;
    begin
        ResponseContent := GetPropfindResponse(Recursive);

        WebDAVContentParser.Initialize(Uri, false, true);
        WebDAVContentParser.Parse(ResponseContent, WebDAVContent);
        Exit(true);
    end;

    [NonDebuggable]
    procedure GetFiles(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    var
        WebDAVContentParser: Codeunit "WebDAV Content Parser";
        ResponseContent: Text;
    begin
        ResponseContent := GetPropfindResponse(Recursive);

        WebDAVContentParser.Initialize(Uri, true, false);
        WebDAVContentParser.Parse(ResponseContent, WebDAVContent);

        Exit(true);
    end;

    local procedure GetPropfindResponse(Recursive: Boolean) ResponseContent: Text;
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Propfind(Uri, Recursive);

        // TODO Success??
        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            Error('%1: %2', WebDAVOperationResponse.GetDiagnostics().GetHttpStatusCode(), WebDAVOperationResponse.GetDiagnostics().GetResponseReasonPhrase());

        WebDAVOperationResponse.GetResponseAsText(ResponseContent);
    end;

    [NonDebuggable]
    procedure GetFileContent(var ResponseInStream: InStream): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Get(Uri);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            Exit(false);

        if WebDAVOperationResponse.GetResponseAsStream(ResponseInStream) then
            Exit(true);
    end;

    [NonDebuggable]
    procedure GetFileContentAsText(var ResponseText: Text): Boolean
    var
        ResponseInStream: InStream;
    begin
        GetFileContent(ResponseInStream);
        ResponseInStream.Read(ResponseText);
        Exit(true);
    end;

    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(WebDAVOperationResponse.GetDiagnostics());
    end;

    [TryFunction]
    procedure GetResponseAsText(var Response: Text)
    begin
        WebDAVOperationResponse.GetResponseAsText(Response);
    end;

    [TryFunction]
    internal procedure GetResponseAsStream(var ResponseInStream: InStream)
    begin
        WebDAVOperationResponse.GetResponseAsStream(ResponseInStream);
    end;
}