// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 5679 "WebDAV Client Impl."
{
    Access = Internal;

    var
        WebDAVOperationResponse: Codeunit "WebDAV Operation Response";
        Authorization: Interface "WebDAV Authorization";
        Uri: Text;

    procedure Initialize(InitUri: Text; InitAuthorization: Interface "WebDAV Authorization")
    begin
        Uri := InitUri;
        Authorization := InitAuthorization;
    end;

    procedure MakeCollection(CollectionName: Text): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.MkCol(Uri, CollectionName);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        exit(true);
    end;

    procedure Delete(MemberName: Text): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Delete(Uri, MemberName);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        exit(true);
    end;

    procedure Put(Content: InStream): Boolean
    var
        HttpContent: HttpContent;
    begin
        HttpContent.WriteFrom(Content);
        exit(Put(HttpContent));
    end;

    procedure Put(Content: Text): Boolean
    var
        HttpContent: HttpContent;
    begin
        HttpContent.WriteFrom(Content);
        exit(Put(HttpContent));
    end;

    procedure Put(Content: HttpContent): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Put(Uri, Content);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        exit(true);
    end;

    procedure Move(Destination: Text): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Move(Uri, Destination);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        exit(true);
    end;

    procedure Copy(Destination: Text): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Copy(Uri, Destination);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        exit(true);
    end;

    procedure GetFilesAndCollections(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    var
        WebDAVContentParser: Codeunit "WebDAV Content Parser";
        ResponseContent: Text;
    begin
        ResponseContent := GetPropfindResponse(Recursive);

        WebDAVContentParser.Initialize(Uri, false, false);
        WebDAVContentParser.Parse(ResponseContent, WebDAVContent);

        exit(true);
    end;

    procedure GetCollections(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    var
        WebDAVContentParser: Codeunit "WebDAV Content Parser";
        ResponseContent: Text;
    begin
        ResponseContent := GetPropfindResponse(Recursive);

        WebDAVContentParser.Initialize(Uri, false, true);
        WebDAVContentParser.Parse(ResponseContent, WebDAVContent);
        exit(true);
    end;

    procedure GetFiles(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    var
        WebDAVContentParser: Codeunit "WebDAV Content Parser";
        ResponseContent: Text;
    begin
        ResponseContent := GetPropfindResponse(Recursive);

        WebDAVContentParser.Initialize(Uri, true, false);
        WebDAVContentParser.Parse(ResponseContent, WebDAVContent);

        exit(true);
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

        WebDAVOperationResponse.TryGetResponseAsText(ResponseContent);
    end;

    procedure GetFileContent(var ResponseInStream: InStream): Boolean
    var
        WebDAVRequestHelper: Codeunit "WebDAV Request Helper";
    begin
        WebDAVRequestHelper.SetAuthorization(Authorization);
        WebDAVOperationResponse := WebDAVRequestHelper.Get(Uri);

        if not WebDAVOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        if WebDAVOperationResponse.TryGetResponseAsStream(ResponseInStream) then
            exit(true);
    end;

    procedure GetFileContentAsText(var ResponseText: Text): Boolean
    var
        ResponseInStream: InStream;
    begin
        GetFileContent(ResponseInStream);
        ResponseInStream.Read(ResponseText);
        exit(true);
    end;

    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(WebDAVOperationResponse.GetDiagnostics());
    end;

    [TryFunction]
    procedure TryGetResponseAsText(var Response: Text)
    begin
        WebDAVOperationResponse.TryGetResponseAsText(Response);
    end;

    [TryFunction]
    internal procedure TryGetResponseAsStream(var ResponseInStream: InStream)
    begin
        WebDAVOperationResponse.TryGetResponseAsStream(ResponseInStream);
    end;
}