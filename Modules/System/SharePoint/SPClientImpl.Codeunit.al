codeunit 9101 "SP Client Impl."
{
    Access = Internal;

    var
        SPUriBuilder: Codeunit "SP Uri Builder";
        SPRequestManager: Codeunit "SP Request Manager";
        Authorization: Interface "ISP Authorization";
        ReadResponseFailedErr: Label 'Could not read response.';

    procedure Initialize(BaseUrl: Text; Auth: Interface "ISP Authorization")
    var
        DefaultSPRequestManager: Codeunit "SP Request Manager";
    begin
        SPUriBuilder.Initialize(BaseUrl, 'Web');
        SPUriBuilder.ResetPath();
        Authorization := Auth;
        SPRequestManager := DefaultSPRequestManager;
    end;

    procedure Initialize(BaseUrl: Text; Namespace: Text; Auth: Interface "ISP Authorization")
    begin
        SPUriBuilder.Initialize(BaseUrl, Namespace);
        SPUriBuilder.ResetPath();
        Authorization := Auth;
    end;

    local procedure GetRequestDigest(BaseUrl: Text): Text
    var
        SPOperationResponse: Codeunit "SP Operation Response";
        _SPUriBuilder: Codeunit "SP Uri Builder";
        Context: JsonToken;
        Result: Text;
    begin
        _SPUriBuilder.Initialize(BaseUrl, 'contextinfo');
        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Post(_SPUriBuilder);
        if SPOperationResponse.GetResultAsText(Result) then begin
            Context.ReadFrom(Result);
            Context.AsObject().Get('d', Context);
            Context.AsObject().Get('GetContextWebInformation', Context);
            Context.AsObject().Get('FormDigestValue', Context);
            exit(Context.AsValue().AsText());
        end else
            Error(ReadResponseFailedErr);
    end;

    #region Lists
    procedure GetLists(var SPList: Record "SP List")
    var
        SPListParser: Codeunit "SP List";
        SPOperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetObject('lists');

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Get(SPUriBuilder);
        SPOperationResponse.GetResultAsText(Result);
        SPListParser.Parse(Result, SPList);
    end;

    procedure GetListItems(ListTitle: Text; var SPListItem: Record "SP List Item")
    var
        SPListItemParser: Codeunit "SP List Item";
        SPOperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/GetByTitle('Test')/items
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetObject('lists');
        SPUriBuilder.SetMethod('GetByTitle', ListTitle);
        SPUriBuilder.SetObject('items');

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Get(SPUriBuilder);
        SPOperationResponse.GetResultAsText(Result);
        SPListItemParser.Parse(Result, SPListItem);
    end;

    procedure GetListItemAttachments(ListTitle: Text; ListItemId: Integer; var SPListItemAttachment: Record "SP List Item Attachment")
    var
        SPListItemAttachmentParser: Codeunit "SP List Item Attachment";
        SPOperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item+id})/AttachmentFiles/
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetObject('lists');
        SPUriBuilder.SetMethod('GetByTitle', ListTitle);
        SPUriBuilder.SetMethod('Items', ListItemId);
        SPUriBuilder.SetObject('AttachmentFiles');

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Get(SPUriBuilder);
        SPOperationResponse.GetResultAsText(Result);
        SPListItemAttachmentParser.Parse(Result, SPListItemAttachment);
    end;


    procedure GetListItemAttachmentContent(ListTitle: Text; ListItemId: Integer; FileName: Text)
    var
        SPOperationResponse: Codeunit "SP Operation Response";
        FileInStream: InStream;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetObject('lists');
        SPUriBuilder.SetMethod('GetByTitle', ListTitle);
        SPUriBuilder.SetMethod('Items', ListItemId);
        SPUriBuilder.SetMethod('AttachmentFiles', FileName);
        SPUriBuilder.SetObject('$value');

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Get(SPUriBuilder);
        SPOperationResponse.GetResultAsStream(FileInStream);
        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    procedure GetListItemAttachmentContent(OdataId: Text)
    var
        SPOperationResponse: Codeunit "SP Operation Response";
        FileInStream: InStream;
        FileName: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SPUriBuilder.ResetPath(OdataId);
        SPUriBuilder.SetObject('$value');
        FileName := SPUriBuilder.GetMethodParameter('AttachmentFiles');

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Get(SPUriBuilder);
        SPOperationResponse.GetResultAsStream(FileInStream);

        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; var SPListItemAttachment: Record "SP List Item Attachment")
    var
        SPOperationResponse: Codeunit "SP Operation Response";
        SPHttpContent: Codeunit "SP Http Content";
        SPListItemAttachmentParser: Codeunit "SP List Item Attachment";
        FileName: Text;
        FileInStream: InStream;
        Result: Text;
    begin
        if not UploadIntoStream('', '', '', FileName, FileInStream) then
            exit;

        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetObject('lists');
        SPUriBuilder.SetMethod('GetByTitle', ListTitle);
        SPUriBuilder.SetMethod('Items', ListItemId);
        SPUriBuilder.SetObject('AttachmentFiles');
        SPUriBuilder.SetMethod('add', 'FileName', '''' + FileName + '''');

        SPHttpContent.FromFileInStream(FileInStream);
        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Post(SPUriBuilder, SPHttpContent);
        SPOperationResponse.GetResultAsText(Result);
        SPListItemAttachmentParser.ParseSingle(Result, SPListItemAttachment);
    end;


    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SPListItemAttachment: Record "SP List Item Attachment")
    var
        SPOperationResponse: Codeunit "SP Operation Response";
        SPHttpContent: Codeunit "SP Http Content";
        SPListItemAttachmentParser: Codeunit "SP List Item Attachment";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetObject('lists');
        SPUriBuilder.SetMethod('GetByTitle', ListTitle);
        SPUriBuilder.SetMethod('Items', ListItemId);
        SPUriBuilder.SetObject('AttachmentFiles');
        SPUriBuilder.SetMethod('add', 'FileName', '''' + FileName + '''');

        SPHttpContent.FromFileInStream(FileInStream);
        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Post(SPUriBuilder, SPHttpContent);
        SPOperationResponse.GetResultAsText(Result);
        SPListItemAttachmentParser.ParseSingle(Result, SPListItemAttachment);
    end;



    procedure CreateList(ListTitle: Text; ListDescription: Text)
    var
        SPHttpContent: Codeunit "SP Http Content";
        SPOperationResponse: Codeunit "SP Operation Response";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetObject('lists');

        Metadata.Add('type', 'SP.List');
        Request.Add('__metadata', Metadata);
        Request.Add('AllowContentTypes', true);
        Request.Add('BaseTemplate', 100);
        Request.Add('ContentTypesEnabled', true);
        Request.Add('Description', ListDescription);
        Request.Add('Title', ListTitle);


        SPHttpContent.FromJson(Request);
        SPHttpContent.SetRequestDigest(GetRequestDigest(SPUriBuilder.GetHost()));

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Post(SPUriBuilder, SPHttpContent);
        SPOperationResponse.GetResultAsText(Result);
    end;

    procedure CreateListItem(ListTitle: Text; ListItemEntityTypeFullName: Text; ListItemTitle: Text)
    var
        SPHttpContent: Codeunit "SP Http Content";
        SPOperationResponse: Codeunit "SP Operation Response";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetObject('lists');
        SPUriBuilder.SetMethod('GetByTitle', ListTitle);
        SPUriBuilder.SetObject('items');

        Metadata.Add('type', ListItemEntityTypeFullName);
        Request.Add('__metadata', Metadata);
        Request.Add('Title', ListItemTitle);


        SPHttpContent.FromJson(Request);
        SPHttpContent.SetRequestDigest(GetRequestDigest(SPUriBuilder.GetHost()));

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Post(SPUriBuilder, SPHttpContent);
        SPOperationResponse.GetResultAsText(Result);
    end;


    #endregion


    #region Folders



    procedure GetSubFoldersByServerRelativeUrl(ServerRelativeUrl: Text; var SPFolder: Record "SP Folder")
    var
        SPFolderParser: Codeunit "SP Folder";
        SPOperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SPUriBuilder.SetObject('Folders');

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Get(SPUriBuilder);
        SPOperationResponse.GetResultAsText(Result);
        SPFolderParser.Parse(Result, SPFolder);
    end;


    procedure GetFolderFilesByServerRelativeUrl(ServerRelativeUrl: Text; var SPFile: Record "SP File" temporary)
    var
        SPFileParser: Codeunit "SP File";
        SPOperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SPUriBuilder.SetObject('Files');

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Get(SPUriBuilder);
        SPOperationResponse.GetResultAsText(Result);
        SPFileParser.Parse(Result, SPFile);
    end;


    procedure GetFileContent(OdataId: Text; FileName: Text)
    var
        SPOperationResponse: Codeunit "SP Operation Response";
        FileInStream: InStream;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SPUriBuilder.ResetPath(OdataId);
        SPUriBuilder.SetObject('$value');

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Get(SPUriBuilder);
        SPOperationResponse.GetResultAsStream(FileInStream);

        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;


    procedure GetDocumentLibraryRootFolder(OdataID: Text; var SPFolder: Record "SP Folder")
    var
        SPFolderParser: Codeunit "SP Folder";
        SPOperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        SPUriBuilder.ResetPath(OdataID);
        SPUriBuilder.SetObject('rootfolder');

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Get(SPUriBuilder);
        SPOperationResponse.GetResultAsText(Result);
        SPFolderParser.ParseSingle(Result, SPFolder);
    end;


    procedure CreateFolder(ServerRelativeUrl: Text)
    var
        SPHttpContent: Codeunit "SP Http Content";
        SPOperationResponse: Codeunit "SP Operation Response";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetObject('folders');

        Metadata.Add('type', 'SP.Folder');
        Request.Add('__metadata', Metadata);
        Request.Add('ServerRelativeUrl', ServerRelativeUrl);


        SPHttpContent.FromJson(Request);
        SPHttpContent.SetRequestDigest(GetRequestDigest(SPUriBuilder.GetHost()));

        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Post(SPUriBuilder, SPHttpContent);
        SPOperationResponse.GetResultAsText(Result);
    end;



    procedure AddFileToFolder(ServerRelativeUrl: Text)
    var
        SPOperationResponse: Codeunit "SP Operation Response";
        SPHttpContent: Codeunit "SP Http Content";
        FileName: Text;
        FileInStream: InStream;
        Result: Text;
    begin
        if not UploadIntoStream('', '', '', FileName, FileInStream) then
            exit;

        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        SPUriBuilder.ResetPath();
        SPUriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        SPUriBuilder.SetObject('Files');
        SPUriBuilder.SetMethod('add', 'url', '''' + FileName + '''');

        SPHttpContent.FromFileInStream(FileInStream);
        SPRequestManager.SetAuthorization(Authorization);
        SPOperationResponse := SPRequestManager.Post(SPUriBuilder, SPHttpContent);
        SPOperationResponse.GetResultAsText(Result);
    end;
    #endregion

}