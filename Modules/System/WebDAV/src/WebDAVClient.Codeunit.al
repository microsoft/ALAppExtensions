// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 5678 "WebDAV Client"
{
    Access = Public;

    var
        WebDAVClientImpl: Codeunit "WebDAV Client Impl.";

    /// <summary>
    /// Initialize.
    /// </summary>
    /// <param name="BaseUrl">Text.</param>
    /// <param name="WebDAVAuthorization">Interface "WebDAV Authorization".</param>
    procedure Initialize(BaseUrl: Text; WebDAVAuthorization: Interface "WebDAV Authorization")
    begin
        WebDAVClientImpl.Initialize(BaseUrl, WebDAVAuthorization);
    end;

    /// <summary>
    /// MakeCollection.
    /// </summary>
    /// <param name="CollectionName">Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    // [NonDebuggable]
    procedure MakeCollection(CollectionName: Text): Boolean
    begin
        exit(WebDAVClientImpl.MakeCollection(CollectionName));
    end;

    /// <summary>
    /// Delete.
    /// </summary>
    /// <param name="MemberName">Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    // [NonDebuggable]
    procedure Delete(MemberName: Text): Boolean
    begin
        exit(WebDAVClientImpl.Delete(MemberName));
    end;

    /// <summary>
    /// Move.
    /// </summary>
    /// <param name="Destination">Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    // [NonDebuggable]
    procedure Move(Destination: Text): Boolean
    begin
        exit(WebDAVClientImpl.Move(Destination));
    end;

    /// <summary>
    /// Copy.
    /// </summary>
    /// <param name="Destination">Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    // [NonDebuggable]
    procedure Copy(Destination: Text): Boolean
    begin
        exit(WebDAVClientImpl.Copy(Destination));
    end;

    /// <summary>
    /// Put.
    /// </summary>
    /// <param name="Content">Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    // [NonDebuggable]
    procedure Put(Content: Text): Boolean
    begin
        exit(WebDAVClientImpl.Put(Content));
    end;

    /// <summary>
    /// Put.
    /// </summary>
    /// <param name="Content">InStream.</param>
    /// <returns>Return value of type Boolean.</returns>
    // [NonDebuggable]
    procedure Put(Content: InStream): Boolean
    begin
        exit(WebDAVClientImpl.Put(Content));
    end;

    /// <summary>
    /// Put.
    /// </summary>
    /// <param name="Content">HttpContent.</param>
    /// <returns>Return value of type Boolean.</returns>
    // [NonDebuggable]
    procedure Put(Content: HttpContent): Boolean
    begin
        exit(WebDAVClientImpl.Put(Content));
    end;

    /// <summary>
    /// GetFilesAndCollections.
    /// </summary>
    /// <param name="WebDAVContent">VAR Record "WebDAV Content".</param>
    /// <param name="Recursive">Boolean.</param>
    /// <returns>Return value of type Boolean.</returns>
    // [NonDebuggable]
    procedure GetFilesAndCollections(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    begin
        exit(WebDAVClientImpl.GetFilesAndCollections(WebDAVContent, Recursive));
    end;

    /// <summary>
    /// GetCollections.
    /// </summary>
    /// <param name="WebDAVContent">VAR Record "WebDAV Content".</param>
    /// <param name="Recursive">Boolean.</param>
    /// <returns>Return value of type Boolean.</returns>
    // [NonDebuggable]
    procedure GetCollections(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    begin
        exit(WebDAVClientImpl.GetCollections(WebDAVContent, Recursive));
    end;

    // [NonDebuggable]
    procedure GetFiles(var WebDAVContent: Record "WebDAV Content"; Recursive: Boolean): Boolean
    begin
        exit(WebDAVClientImpl.GetFiles(WebDAVContent, Recursive));
    end;

    /// <summary>
    /// GetFileContent.
    /// </summary>
    /// <param name="ResponseInStream">VAR InStream.</param>
    /// <returns>Return value of type Boolean.</returns>
    [NonDebuggable]
    procedure GetFileContent(var ResponseInStream: InStream): Boolean
    begin
        exit(WebDAVClientImpl.GetFileContent(ResponseInStream));
    end;

    /// <summary>
    /// GetFileContentAsText.
    /// </summary>
    /// <param name="ResponseText">VAR Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    [NonDebuggable]
    procedure GetFileContentAsText(var ResponseText: Text): Boolean
    begin
        exit(WebDAVClientImpl.GetFileContentAsText(ResponseText));
    end;

    /// <summary>
    /// Returns detailed information on last API call.
    /// </summary>
    /// <returns>Codeunit holding http resonse status, reason phrase, headers and possible error information for tha last API call</returns>
    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(WebDAVClientImpl.GetDiagnostics());
    end;

    /// <summary>
    /// TryGetResponseAsText.
    /// </summary>
    /// <param name="Response">VAR Text.</param>
    /// <returns>False if an runtime error occurred. Otherwise true.</returns>
    [TryFunction]
    procedure TryGetResponseAsText(var Response: Text)
    begin
        WebDAVClientImpl.TryGetResponseAsText(Response);
    end;

    /// <summary>
    /// TryGetResponseAsStream.
    /// </summary>
    /// <param name="ResponseInStream">VAR InStream.</param>
    /// <returns>False if an runtime error occurred. Otherwise true.</returns>
    [TryFunction]
    internal procedure TryGetResponseAsStream(var ResponseInStream: InStream)
    begin
        WebDAVClientImpl.TryGetResponseAsStream(ResponseInStream);
    end;

}