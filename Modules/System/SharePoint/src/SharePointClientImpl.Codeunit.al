// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Sharepoint;

using System.Utilities;

codeunit 9101 "SharePoint Client Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SharePointUriBuilder: Codeunit "SharePoint Uri Builder";
        SharePointRequestHelper: Codeunit "SharePoint Request Helper";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        Authorization: Interface "SharePoint Authorization";
        ReadResponseFailedErr: Label 'Could not read response.';
        IncorrectResponseErr: Label 'Incorrect response.';
        IncorrectResponseLogErr: Label 'Incorrect request digest response: %1.', Comment = '%1 = the response text', Locked = true;
        SharePointCategoryLbl: Label 'AL SharePoint', Locked = true;

    procedure Initialize(BaseUrl: Text; Auth: Interface "SharePoint Authorization")
    begin
        SharePointUriBuilder.Initialize(BaseUrl, 'Web');
        SharePointUriBuilder.ResetPath();
        Authorization := Auth;
    end;

    procedure Initialize(BaseUrl: Text; Namespace: Text; Auth: Interface "SharePoint Authorization")
    begin
        SharePointUriBuilder.Initialize(BaseUrl, Namespace);
        SharePointUriBuilder.ResetPath();
        Authorization := Auth;
    end;

    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(SharePointOperationResponse.GetDiagnostics());
    end;

    local procedure GetRequestDigest(BaseUrl: Text): Text
    var
        NewSharePointOperationResponse: Codeunit "SharePoint Operation Response";
        NewSharePointUriBuilder: Codeunit "SharePoint Uri Builder";
        Context: JsonToken;
        Result: Text;
    begin
        NewSharePointUriBuilder.Initialize(BaseUrl, 'contextinfo');
        SharePointRequestHelper.SetAuthorization(Authorization);
        NewSharePointOperationResponse := SharePointRequestHelper.Post(NewSharePointUriBuilder);
        if NewSharePointOperationResponse.GetResultAsText(Result) then begin

            Context.ReadFrom(Result);

            if not Context.AsObject().Get('d', Context) then begin
                Session.LogMessage('00001SPC', StrSubstNo(IncorrectResponseLogErr, Result), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', SharePointCategoryLbl);
                Error(IncorrectResponseErr);
            end;

            if not Context.AsObject().Get('GetContextWebInformation', Context) then begin
                Session.LogMessage('00002SPC', StrSubstNo(IncorrectResponseLogErr, Result), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', SharePointCategoryLbl);
                Error(IncorrectResponseErr);
            end;

            if not Context.AsObject().Get('FormDigestValue', Context) then begin
                Session.LogMessage('00003SPC', StrSubstNo(IncorrectResponseLogErr, Result), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', SharePointCategoryLbl);
                Error(IncorrectResponseErr);
            end;

            exit(Context.AsValue().AsText());

        end else
            Error(ReadResponseFailedErr);
    end;

    #region Lists
    procedure GetLists(var SharePointList: Record "SharePoint List"): Boolean
    var
        SharePointListParser: Codeunit "SharePoint List";
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListParser.Parse(Result, SharePointList);
        exit(true);
    end;

    procedure GetListItems(ListTitle: Text; var SharePointListItem: Record "SharePoint List Item"): Boolean
    var
        SharePointListItemParser: Codeunit "SharePoint List Item";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/GetByTitle('Test')/items
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetObject('items');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemParser.Parse(Result, SharePointListItem);
        exit(true);
    end;

    procedure GetListItems(ListId: Guid; var SharePointListItem: Record "SharePoint List Item"): Boolean
    var
        SharePointListItemParser: Codeunit "SharePoint List Item";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists(guid'{list_guid}')/items
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetObject('items');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemParser.Parse(Result, SharePointListItem);
        exit(true);
    end;

    procedure GetListItemAttachments(ListTitle: Text; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    var
        SharePointListItemAtchParser: Codeunit "SharePoint List Item Atch.";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item+id})/AttachmentFiles/
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetObject('AttachmentFiles');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.Parse(Result, SharePointListItemAtch);
        exit(true);
    end;

    procedure GetListItemAttachments(ListId: Guid; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    var
        SharePointListItemAtchParser: Codeunit "SharePoint List Item Atch.";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists(guid'{list_guid}')/items({item+id})/AttachmentFiles/
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetObject('AttachmentFiles');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.Parse(Result, SharePointListItemAtch);
        exit(true);
    end;

    procedure DownloadListItemAttachmentContent(ListTitle: Text; ListItemId: Integer; FileName: Text): Boolean
    var
        FileInStream: InStream;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetMethod('AttachmentFiles', FileName);
        SharePointUriBuilder.SetObject('$value');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsStream(FileInStream);
        DownloadFromStream(FileInStream, '', '', '', FileName);
        exit(true);
    end;

    procedure DownloadListItemAttachmentContent(ListId: Guid; ListItemId: Integer; FileName: Text): Boolean
    var
        FileInStream: InStream;
    begin
        //GET https://{site_url}/_api/web/lists(guid'{list_guid}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetMethod('AttachmentFiles', FileName);
        SharePointUriBuilder.SetObject('$value');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsStream(FileInStream);
        DownloadFromStream(FileInStream, '', '', '', FileName);
        exit(true);
    end;

    procedure DownloadListItemAttachmentContent(OdataId: Text): Boolean
    var
        FileInStream: InStream;
        FileName: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath(OdataId);
        SharePointUriBuilder.SetObject('$value');
        FileName := SharePointUriBuilder.GetMethodParameter('AttachmentFiles');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsStream(FileInStream);
        DownloadFromStream(FileInStream, '', '', '', FileName);
        exit(true);
    end;

    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointListItemAtchParser: Codeunit "SharePoint List Item Atch.";
        FileName: Text;
        FileInStream: InStream;
        Result: Text;
    begin
        if not UploadIntoStream('', '', '', FileName, FileInStream) then
            exit;

        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetObject('AttachmentFiles');
        SharePointUriBuilder.SetMethod('add', 'FileName', '''' + FileName + '''');

        SharePointHttpContent.FromFileInStream(FileInStream);
        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.ParseSingleReturnValue(Result, SharePointListItemAtch);
        exit(true);
    end;

    procedure CreateListItemAttachment(ListId: Guid; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointListItemAtchParser: Codeunit "SharePoint List Item Atch.";
        FileName: Text;
        FileInStream: InStream;
        Result: Text;
    begin
        if not UploadIntoStream('', '', '', FileName, FileInStream) then
            exit;

        //GET https://{site_url}/_api/web/lists(guid'{list_guid}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetObject('AttachmentFiles');
        SharePointUriBuilder.SetMethod('add', 'FileName', '''' + FileName + '''');

        SharePointHttpContent.FromFileInStream(FileInStream);
        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.ParseSingleReturnValue(Result, SharePointListItemAtch);
        exit(true);
    end;

    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointListItemAtchParser: Codeunit "SharePoint List Item Atch.";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetObject('AttachmentFiles');
        SharePointUriBuilder.SetMethod('add', 'FileName', '''' + FileName + '''');

        SharePointHttpContent.FromFileInStream(FileInStream);
        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.ParseSingleReturnValue(Result, SharePointListItemAtch);
        exit(true);
    end;

    procedure CreateListItemAttachment(ListId: Guid; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointListItemAtchParser: Codeunit "SharePoint List Item Atch.";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists(guid'{list_guid}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetObject('AttachmentFiles');
        SharePointUriBuilder.SetMethod('add', 'FileName', '''' + FileName + '''');

        SharePointHttpContent.FromFileInStream(FileInStream);
        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.ParseSingleReturnValue(Result, SharePointListItemAtch);
        exit(true);
    end;

    procedure CreateList(ListTitle: Text; ListDescription: Text; var SharePointList: Record "SharePoint List"): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointListParser: Codeunit "SharePoint List";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');

        Metadata.Add('type', 'SP.List');
        Request.Add('__metadata', Metadata);
        Request.Add('AllowContentTypes', true);
        Request.Add('BaseTemplate', 100);
        Request.Add('ContentTypesEnabled', true);
        Request.Add('Description', ListDescription);
        Request.Add('Title', ListTitle);

        SharePointHttpContent.FromJson(Request);
        SharePointHttpContent.SetRequestDigest(GetRequestDigest(SharePointUriBuilder.GetHost()));

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListParser.ParseSingleReturnValue(Result, SharePointList);
        exit(true);
    end;

    procedure CreateListItem(ListTitle: Text; ListItemEntityTypeFullName: Text; ListItemTitle: Text; var SharePointListItem: Record "SharePoint List Item"): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointListItemParser: Codeunit "SharePoint List Item";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetObject('items');

        Metadata.Add('type', ListItemEntityTypeFullName);
        Request.Add('__metadata', Metadata);
        Request.Add('Title', ListItemTitle);

        SharePointHttpContent.FromJson(Request);
        SharePointHttpContent.SetRequestDigest(GetRequestDigest(SharePointUriBuilder.GetHost()));

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemParser.ParseSingleReturnValue(Result, SharePointListItem);
        exit(true);
    end;

    procedure CreateListItem(ListId: Guid; ListItemEntityTypeFullName: Text; ListItemTitle: Text; var SharePointListItem: Record "SharePoint List Item"): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointListItemParser: Codeunit "SharePoint List Item";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetObject('items');

        Metadata.Add('type', ListItemEntityTypeFullName);
        Request.Add('__metadata', Metadata);
        Request.Add('Title', ListItemTitle);

        SharePointHttpContent.FromJson(Request);
        SharePointHttpContent.SetRequestDigest(GetRequestDigest(SharePointUriBuilder.GetHost()));

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemParser.ParseSingleReturnValue(Result, SharePointListItem);
        exit(true);
    end;

    #endregion

    #region Folders

    procedure GetSubFoldersByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFolder: Record "SharePoint Folder"): Boolean
    var
        SharePointFolderParser: Codeunit "SharePoint Folder";
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SharePointUriBuilder.SetObject('Folders');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFolderParser.Parse(Result, SharePointFolder);
        exit(true);
    end;

    procedure GetFolderFilesByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary; ListAllFields: Boolean): Boolean
    var
        SharePointFileParser: Codeunit "SharePoint File";
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SharePointUriBuilder.SetObject('Files');
        if ListAllFields then
            SharePointUriBuilder.AddQueryParameter('$expand', 'ListItemAllFields');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFileParser.Parse(Result, SharePointFile);
        exit(true);
    end;

    procedure DownloadFileContent(OdataId: Text; var FileInStream: InStream): Boolean
    begin
        //GET https://{site_url}/_api/web/GetFileByServerRelativeUrl('/Folder Name/{file_name}')/$value
        SharePointUriBuilder.ResetPath(OdataId);
        SharePointUriBuilder.SetObject('$value');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsStream(FileInStream);
        exit(true);
    end;

    procedure DownloadFileContent(OdataId: Text; FileName: Text): Boolean
    var
        FileInStream: InStream;
    begin
        if not DownloadFileContent(OdataId, FileInStream) then
            exit(false);

        DownloadFromStream(FileInStream, '', '', '', FileName);
        exit(true);
    end;

    procedure DownloadFileContent(OdataId: Text; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        FileInStream: InStream;
        FileOutStream: OutStream;
    begin
        if not DownloadFileContent(OdataId, FileInStream) then
            exit(false);
        TempBlob.CreateOutStream(FileOutStream);
        CopyStream(FileOutStream, FileInStream);
        exit(true);
    end;

    procedure DownloadFileContentByServerRelativeUrl(ServerRelativeUrl: Text; var FileInStream: InStream): Boolean
    begin
        //GET https://{site_url}/_api/web/GetFileByServerRelativeUrl('/Folder Name/{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFileByServerRelativeUrl', ServerRelativeUrl);
        SharePointUriBuilder.SetObject('$value');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsStream(FileInStream);
        exit(true);
    end;

    procedure DownloadFileContentByServerRelativeUrl(ServerRelativeUrl: Text; FileName: Text): Boolean
    var
        FileInStream: InStream;
    begin
        if not DownloadFileContentByServerRelativeUrl(ServerRelativeUrl, FileInStream) then
            exit(false);

        DownloadFromStream(FileInStream, '', '', '', FileName);
        exit(true);
    end;

    procedure DownloadFileContentByServerRelativeUrl(ServerRelativeUrl: Text; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        FileInStream: InStream;
        FileOutStream: OutStream;
    begin
        if not DownloadFileContentByServerRelativeUrl(ServerRelativeUrl, FileInStream) then
            exit(false);
        TempBlob.CreateOutStream(FileOutStream);
        CopyStream(FileOutStream, FileInStream);
        exit(true);
    end;

    procedure DeleteFile(OdataId: Text): Boolean
    begin
        //DELETE https://{site_url}/_api/web/GetFileByServerRelativeUrl('/Folder Name/{file_name}')
        SharePointUriBuilder.ResetPath(OdataId);

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Delete(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        exit(true);
    end;

    procedure DeleteFileByServerRelativeUrl(ServerRelativeUrl: Text): Boolean
    begin
        //DELETE https://{site_url}/_api/web/GetFileByServerRelativeUrl('/Folder Name/{file_name}')
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFileByServerRelativeUrl', ServerRelativeUrl);

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Delete(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        exit(true);
    end;

    procedure GetDocumentLibraryRootFolder(OdataID: Text; var SharePointFolder: Record "SharePoint Folder"): Boolean
    var
        SharePointFolderParser: Codeunit "SharePoint Folder";
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath(OdataID);
        SharePointUriBuilder.SetObject('rootfolder');

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Get(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFolderParser.ParseSingle(Result, SharePointFolder);
        exit(true);
    end;

    procedure CreateFolder(ServerRelativeUrl: Text; var SharePointFolder: Record "SharePoint Folder"): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointFolderParser: Codeunit "SharePoint Folder";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('folders');

        Metadata.Add('type', 'SP.Folder');
        Request.Add('__metadata', Metadata);
        Request.Add('ServerRelativeUrl', ServerRelativeUrl);

        SharePointHttpContent.FromJson(Request);
        SharePointHttpContent.SetRequestDigest(GetRequestDigest(SharePointUriBuilder.GetHost()));

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFolderParser.ParseSingleReturnValue(Result, SharePointFolder);
        exit(true);
    end;

    procedure DeleteFolder(OdataId: Text): Boolean
    begin
        //DELETE https://{site_url}/_api/web/GetFolderByServerRelativeUrl('{folder_name}')
        SharePointUriBuilder.ResetPath(OdataId);

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Delete(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        exit(true);
    end;

    procedure DeleteFolderByServerRelativeUrl(ServerRelativeUrl: Text): Boolean
    begin
        //DELETE https://{site_url}/_api/web/GetFolderByServerRelativeUrl('{folder_name}')
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);

        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Delete(SharePointUriBuilder);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        exit(true);
    end;

    procedure AddFileToFolder(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary; ListAllFields: Boolean): Boolean
    var
        SharePointFileParser: Codeunit "SharePoint File";
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        FileName: Text;
        FileInStream: InStream;
        Result: Text;
    begin
        if not UploadIntoStream('', '', '', FileName, FileInStream) then
            exit;

        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SharePointUriBuilder.SetObject('Files');
        SharePointUriBuilder.SetMethod('add', 'url', '''' + FileName + '''');
        if ListAllFields then
            SharePointUriBuilder.AddQueryParameter('$expand', 'ListItemAllFields');

        SharePointHttpContent.FromFileInStream(FileInStream);
        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFileParser.ParseSingleReturnValue(Result, SharePointFile);
        exit(true);
    end;

    procedure AddFileToFolder(ServerRelativeUrl: Text; FileName: Text; var FileInStream: InStream; var SharePointFile: Record "SharePoint File" temporary; ListAllFields: Boolean): Boolean
    var
        SharePointFileParser: Codeunit "SharePoint File";
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SharePointUriBuilder.SetObject('Files');
        SharePointUriBuilder.SetMethod('add', 'url', '''' + FileName + '''');
        if ListAllFields then
            SharePointUriBuilder.AddQueryParameter('$expand', 'ListItemAllFields');

        SharePointHttpContent.FromFileInStream(FileInStream);
        SharePointRequestHelper.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestHelper.Post(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFileParser.ParseSingleReturnValue(Result, SharePointFile);
        exit(true);
    end;

    procedure UpdateListItemMetaDataField(ListTitle: Text; ItemId: Integer; ListItemEntityTypeFullName: Text; FieldName: Text; FieldValue: Text): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        Metadata, Payload : JsonObject;
        Txt: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetMethod('items', ItemId);

        Metadata.Add('type', ListItemEntityTypeFullName);
        Payload.Add('__metadata', Metadata);
        Payload.Add(FieldName, FieldValue);

        SharePointHttpContent.FromJson(Payload);

        SharePointHttpContent.GetContent().ReadAs(Txt);

        SharePointHttpContent.SetRequestDigest(GetRequestDigest(SharePointUriBuilder.GetHost()));
        SharePointHttpContent.SetXHttpMethod('MERGE');
        SharePointHttpContent.SetIfMatch('*');

        SharePointOperationResponse := SharePointRequestHelper.Patch(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Txt);
        Message(Txt);
        exit(true);
    end;

    procedure UpdateListItemMetaDataField(ListId: Guid; ItemId: Integer; ListItemEntityTypeFullName: Text; FieldName: Text; FieldValue: Text): Boolean
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        Metadata, Payload : JsonObject;
        Txt: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetMethod('items', ItemId);

        Metadata.Add('type', ListItemEntityTypeFullName);
        Payload.Add('__metadata', Metadata);
        Payload.Add(FieldName, FieldValue);

        SharePointHttpContent.FromJson(Payload);

        SharePointHttpContent.GetContent().ReadAs(Txt);

        SharePointHttpContent.SetRequestDigest(GetRequestDigest(SharePointUriBuilder.GetHost()));
        SharePointHttpContent.SetXHttpMethod('MERGE');
        SharePointHttpContent.SetIfMatch('*');

        SharePointOperationResponse := SharePointRequestHelper.Patch(SharePointUriBuilder, SharePointHttpContent);
        if not SharePointOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);

        SharePointOperationResponse.GetResultAsText(Txt);
        exit(true);
    end;
    #endregion
}