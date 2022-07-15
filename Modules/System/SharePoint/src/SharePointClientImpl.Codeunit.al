codeunit 9101 "SharePoint Client Impl."
{
    Access = Internal;

    var
        SharePointUriBuilder: Codeunit "SharePoint Uri Builder";
        SharePointRequestManager: Codeunit "SharePoint Request Manager";
        Authorization: Interface "SharePoint Authorization";
        ReadResponseFailedErr: Label 'Could not read response.';
        IncorrectResponseErr: Label 'Incorrect response.';

    procedure Initialize(BaseUrl: Text; Auth: Interface "SharePoint Authorization")
    var
        DefaultSharePointRequestManager: Codeunit "SharePoint Request Manager";
    begin
        SharePointUriBuilder.Initialize(BaseUrl, 'Web');
        SharePointUriBuilder.ResetPath();
        Authorization := Auth;
        SharePointRequestManager := DefaultSharePointRequestManager;
    end;

    procedure Initialize(BaseUrl: Text; Namespace: Text; Auth: Interface "SharePoint Authorization")
    begin
        SharePointUriBuilder.Initialize(BaseUrl, Namespace);
        SharePointUriBuilder.ResetPath();
        Authorization := Auth;
    end;

    local procedure GetRequestDigest(BaseUrl: Text): Text
    var
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        NewSharePointUriBuilder: Codeunit "SharePoint Uri Builder";
        Context: JsonToken;
        Result: Text;
    begin
        NewSharePointUriBuilder.Initialize(BaseUrl, 'contextinfo');
        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(NewSharePointUriBuilder);
        if SharePointOperationResponse.GetResultAsText(Result) then begin

            Context.ReadFrom(Result);

            if not Context.AsObject().Get('d', Context) then
                Error(IncorrectResponseErr);

            if not Context.AsObject().Get('GetContextWebInformation', Context) then
                Error(IncorrectResponseErr);

            if not Context.AsObject().Get('FormDigestValue', Context) then
                Error(IncorrectResponseErr);

            exit(Context.AsValue().AsText());

        end else
            Error(ReadResponseFailedErr);
    end;

    #region Lists
    procedure GetLists(var SharePointList: Record "SharePoint List")
    var
        SharePointListParser: Codeunit "SharePoint List";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListParser.Parse(Result, SharePointList);
    end;

    procedure GetListItems(ListTitle: Text; var SharePointListItem: Record "SharePoint List Item")
    var
        SharePointListItemParser: Codeunit "SharePoint List Item";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/GetByTitle('Test')/items
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetObject('items');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemParser.Parse(Result, SharePointListItem);
    end;

    procedure GetListItems(ListId: Guid; var SharePointListItem: Record "SharePoint List Item")
    var
        SharePointListItemParser: Codeunit "SharePoint List Item";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists(guid'{list_guid}')/items
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetObject('items');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemParser.Parse(Result, SharePointListItem);
    end;

    procedure GetListItemAttachments(ListTitle: Text; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    var
        SharePointListItemAtchParser: Codeunit "SharePoint List Item Atch.";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item+id})/AttachmentFiles/
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetObject('AttachmentFiles');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.Parse(Result, SharePointListItemAtch);
    end;

    procedure GetListItemAttachments(ListId: Guid; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    var
        SharePointListItemAtchParser: Codeunit "SharePoint List Item Atch.";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists(guid'{list_guid}')/items({item+id})/AttachmentFiles/
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetObject('AttachmentFiles');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.Parse(Result, SharePointListItemAtch);
    end;

    procedure DownloadListItemAttachmentContent(ListTitle: Text; ListItemId: Integer; FileName: Text)
    var
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        FileInStream: InStream;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetObject('lists');
        SharePointUriBuilder.SetMethod('GetByTitle', ListTitle);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetMethod('AttachmentFiles', FileName);
        SharePointUriBuilder.SetObject('$value');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsStream(FileInStream);
        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    procedure DownloadListItemAttachmentContent(ListId: Guid; ListItemId: Integer; FileName: Text)
    var
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        FileInStream: InStream;
    begin
        //GET https://{site_url}/_api/web/lists(guid'{list_guid}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('Lists', ListId);
        SharePointUriBuilder.SetMethod('Items', ListItemId);
        SharePointUriBuilder.SetMethod('AttachmentFiles', FileName);
        SharePointUriBuilder.SetObject('$value');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsStream(FileInStream);
        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    procedure DownloadListItemAttachmentContent(OdataId: Text)
    var
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        FileInStream: InStream;
        FileName: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath(OdataId);
        SharePointUriBuilder.SetObject('$value');
        FileName := SharePointUriBuilder.GetMethodParameter('AttachmentFiles');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsStream(FileInStream);

        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    var
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
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
        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.ParseSingleReturnValue(Result, SharePointListItemAtch);
    end;

    procedure CreateListItemAttachment(ListId: Guid; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    var
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
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
        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.ParseSingleReturnValue(Result, SharePointListItemAtch);
    end;

    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    var
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
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
        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.ParseSingleReturnValue(Result, SharePointListItemAtch);
    end;

    procedure CreateListItemAttachment(ListId: Guid; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    var
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
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
        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemAtchParser.ParseSingleReturnValue(Result, SharePointListItemAtch);
    end;

    procedure CreateList(ListTitle: Text; ListDescription: Text; var SharePointList: Record "SharePoint List")
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
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

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListParser.ParseSingleReturnValue(Result, SharePointList);
    end;

    procedure CreateListItem(ListTitle: Text; ListItemEntityTypeFullName: Text; ListItemTitle: Text; var SharePointListItem: Record "SharePoint List Item")
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
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

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemParser.ParseSingleReturnValue(Result, SharePointListItem);
    end;

    procedure CreateListItem(ListId: Guid; ListItemEntityTypeFullName: Text; ListItemTitle: Text; var SharePointListItem: Record "SharePoint List Item")
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
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

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointListItemParser.ParseSingleReturnValue(Result, SharePointListItem);
    end;

    #endregion

    #region Folders

    procedure GetSubFoldersByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFolder: Record "SharePoint Folder")
    var
        SharePointFolderParser: Codeunit "SharePoint Folder";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SharePointUriBuilder.SetObject('Folders');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFolderParser.Parse(Result, SharePointFolder);
    end;

    procedure GetFolderFilesByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary)
    var
        SharePointFileParser: Codeunit "SharePoint File";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SharePointUriBuilder.SetObject('Files');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFileParser.Parse(Result, SharePointFile);
    end;

    procedure DownloadFileContent(OdataId: Text; FileName: Text)
    var
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        FileInStream: InStream;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath(OdataId);
        SharePointUriBuilder.SetObject('$value');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsStream(FileInStream);

        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    procedure GetDocumentLibraryRootFolder(OdataID: Text; var SharePointFolder: Record "SharePoint Folder")
    var
        SharePointFolderParser: Codeunit "SharePoint Folder";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        Result: Text;
    begin
        SharePointUriBuilder.ResetPath(OdataID);
        SharePointUriBuilder.SetObject('rootfolder');

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Get(SharePointUriBuilder);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFolderParser.ParseSingle(Result, SharePointFolder);
    end;

    procedure CreateFolder(ServerRelativeUrl: Text; var SharePointFolder: Record "SharePoint Folder")
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
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

        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFolderParser.ParseSingleReturnValue(Result, SharePointFolder);
    end;

    procedure AddFileToFolder(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary)
    var
        SharePointFileParser: Codeunit "SharePoint File";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
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

        SharePointHttpContent.FromFileInStream(FileInStream);
        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFileParser.ParseSingleReturnValue(Result, SharePointFile);
    end;

    procedure AddFileToFolder(ServerRelativeUrl: Text; FileName: Text; var FileInStream: InStream; var SharePointFile: Record "SharePoint File" temporary)
    var
        SharePointFileParser: Codeunit "SharePoint File";
        SharePointOperationResponse: Codeunit "SharePoint Operation Response";
        SharePointHttpContent: Codeunit "SharePoint Http Content";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SharePointUriBuilder.ResetPath();
        SharePointUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SharePointUriBuilder.SetObject('Files');
        SharePointUriBuilder.SetMethod('add', 'url', '''' + FileName + '''');

        SharePointHttpContent.FromFileInStream(FileInStream);
        SharePointRequestManager.SetAuthorization(Authorization);
        SharePointOperationResponse := SharePointRequestManager.Post(SharePointUriBuilder, SharePointHttpContent);
        SharePointOperationResponse.GetResultAsText(Result);
        SharePointFileParser.ParseSingleReturnValue(Result, SharePointFile);
    end;
    #endregion

}