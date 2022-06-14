codeunit 9101 "SP Client Impl."
{
    //Access = Internal;

    var
        UriBuilder: Codeunit "SP Uri Builder";
        RequestManager: Codeunit "SP Request Manager";
        Authorization: Interface "SP IAuthorization";

    procedure Initialize(BaseUrl: Text; Auth: Interface "SP IAuthorization")
    var
        DefaultRequestManager: Codeunit "SP Request Manager";
    begin
        UriBuilder.Initialize(BaseUrl, 'Web');
        UriBuilder.ResetPath();
        Authorization := Auth;
        RequestManager := DefaultRequestManager;
    end;

    procedure Initialize(BaseUrl: Text; Namespace: Text; Auth: Interface "SP IAuthorization")
    begin
        UriBuilder.Initialize(BaseUrl, Namespace);
        UriBuilder.ResetPath();
        Authorization := Auth;
    end;

    local procedure GetRequestDigest(BaseUrl: Text): Text
    var
        OperationResponse: Codeunit "SP Operation Response";
        _UriBuilder: Codeunit "SP Uri Builder";
        Context: JsonToken;
        Result: Text;
    begin
        _UriBuilder.Initialize(BaseUrl, 'contextinfo');
        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Post(_UriBuilder);
        OperationResponse.GetResultAsText(Result);
        Context.ReadFrom(Result);
        Context.AsObject().Get('d', Context);
        Context.AsObject().Get('GetContextWebInformation', Context);
        Context.AsObject().Get('FormDigestValue', Context);

        exit(Context.AsValue().AsText());
    end;

    #region Lists
    procedure GetLists(var SPList: Record "SP List")
    var
        SPListParser: Codeunit "SP List";
        OperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        UriBuilder.ResetPath();
        UriBuilder.SetObject('lists');

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Get(UriBuilder);
        OperationResponse.GetResultAsText(Result);
        SPListParser.Parse(Result, SPList);
    end;

    procedure GetListItems(ListTitle: Text; var SPListItem: Record "SP List Item")
    var
        SPListItemParser: Codeunit "SP List Item";
        OperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/GetByTitle('Test')/items
        UriBuilder.ResetPath();
        UriBuilder.SetObject('lists');
        UriBuilder.SetMethod('GetByTitle', ListTitle);
        UriBuilder.SetObject('items');

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Get(UriBuilder);
        OperationResponse.GetResultAsText(Result);
        SPListItemParser.Parse(Result, SPListItem);
    end;

    procedure GetListItemAttachments(ListTitle: Text; ListItemId: Integer; var SPListItemAttachment: Record "SP List Item Attachment")
    var
        SPListItemAttachmentParser: Codeunit "SP List Item Attachment";
        OperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item+id})/AttachmentFiles/
        UriBuilder.ResetPath();
        UriBuilder.SetObject('lists');
        UriBuilder.SetMethod('GetByTitle', ListTitle);
        UriBuilder.SetMethod('Items', ListItemId);
        UriBuilder.SetObject('AttachmentFiles');

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Get(UriBuilder);
        OperationResponse.GetResultAsText(Result);
        SPListItemAttachmentParser.Parse(Result, SPListItemAttachment);
    end;


    procedure GetListItemAttachmentContent(ListTitle: Text; ListItemId: Integer; FileName: Text)
    var
        OperationResponse: Codeunit "SP Operation Response";
        FileInStream: InStream;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        UriBuilder.ResetPath();
        UriBuilder.SetObject('lists');
        UriBuilder.SetMethod('GetByTitle', ListTitle);
        UriBuilder.SetMethod('Items', ListItemId);
        UriBuilder.SetMethod('AttachmentFiles', FileName);
        UriBuilder.SetObject('$value');

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Get(UriBuilder);
        OperationResponse.GetResultAsStream(FileInStream);
        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    procedure GetListItemAttachmentContent(OdataId: Text)
    var
        OperationResponse: Codeunit "SP Operation Response";
        FileInStream: InStream;
        FileName: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        UriBuilder.ResetPath(OdataId);
        UriBuilder.SetObject('$value');
        FileName := UriBuilder.GetMethodParameter('AttachmentFiles');

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Get(UriBuilder);
        OperationResponse.GetResultAsStream(FileInStream);

        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; var SPListItemAttachment: Record "SP List Item Attachment")
    var
        OperationResponse: Codeunit "SP Operation Response";
        SPHttpContent: Codeunit "SP Http Content";
        SPListItemAttachmentParser: Codeunit "SP List Item Attachment";
        FileName: Text;
        FileInStream: InStream;
        Result: Text;
    begin
        if not UploadIntoStream('', '', '', FileName, FileInStream) then
            exit;

        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        UriBuilder.ResetPath();
        UriBuilder.SetObject('lists');
        UriBuilder.SetMethod('GetByTitle', ListTitle);
        UriBuilder.SetMethod('Items', ListItemId);
        UriBuilder.SetObject('AttachmentFiles');
        UriBuilder.SetMethod('add', 'FileName', '''' + FileName + '''');

        SPHttpContent.FromFileInStream(FileInStream);
        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Post(UriBuilder, SPHttpContent);
        OperationResponse.GetResultAsText(Result);
        SPListItemAttachmentParser.ParseSingle(Result, SPListItemAttachment);
    end;


    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SPListItemAttachment: Record "SP List Item Attachment")
    var
        OperationResponse: Codeunit "SP Operation Response";
        SPHttpContent: Codeunit "SP Http Content";
        SPListItemAttachmentParser: Codeunit "SP List Item Attachment";
        Result: Text;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        UriBuilder.ResetPath();
        UriBuilder.SetObject('lists');
        UriBuilder.SetMethod('GetByTitle', ListTitle);
        UriBuilder.SetMethod('Items', ListItemId);
        UriBuilder.SetObject('AttachmentFiles');
        UriBuilder.SetMethod('add', 'FileName', '''' + FileName + '''');

        SPHttpContent.FromFileInStream(FileInStream);
        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Post(UriBuilder, SPHttpContent);
        OperationResponse.GetResultAsText(Result);
        SPListItemAttachmentParser.ParseSingle(Result, SPListItemAttachment);
    end;



    procedure CreateList(ListTitle: Text; ListDescription: Text)
    var
        SPHttpContent: Codeunit "SP Http Content";
        OperationResponse: Codeunit "SP Operation Response";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        UriBuilder.ResetPath();
        UriBuilder.SetObject('lists');

        Metadata.Add('type', 'SP.List');
        Request.Add('__metadata', Metadata);
        Request.Add('AllowContentTypes', true);
        Request.Add('BaseTemplate', 100);
        Request.Add('ContentTypesEnabled', true);
        Request.Add('Description', ListDescription);
        Request.Add('Title', ListTitle);


        SPHttpContent.FromJson(Request);
        SPHttpContent.SetRequestDigest(GetRequestDigest(UriBuilder.GetHost()));

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Post(UriBuilder, SPHttpContent);
        OperationResponse.GetResultAsText(Result);
    end;

    procedure CreateListItem(ListTitle: Text; ListItemEntityTypeFullName: Text; ListItemTitle: Text)
    var
        SPHttpContent: Codeunit "SP Http Content";
        OperationResponse: Codeunit "SP Operation Response";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        UriBuilder.ResetPath();
        UriBuilder.SetObject('lists');
        UriBuilder.SetMethod('GetByTitle', ListTitle);
        UriBuilder.SetObject('items');

        Metadata.Add('type', ListItemEntityTypeFullName);
        Request.Add('__metadata', Metadata);
        Request.Add('Title', ListItemTitle);


        SPHttpContent.FromJson(Request);
        SPHttpContent.SetRequestDigest(GetRequestDigest(UriBuilder.GetHost()));

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Post(UriBuilder, SPHttpContent);
        OperationResponse.GetResultAsText(Result);
    end;


    #endregion


    #region Folders



    procedure GetSubFoldersByServerRelativeUrl(ServerRelativeUrl: Text; var SPFolder: Record "SP Folder")
    var
        SPFolderParser: Codeunit "SP Folder";
        OperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        UriBuilder.ResetPath();
        UriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        UriBuilder.SetObject('Folders');

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Get(UriBuilder);
        OperationResponse.GetResultAsText(Result);
        SPFolderParser.Parse(Result, SPFolder);
    end;


    procedure GetFolderFilesByServerRelativeUrl(ServerRelativeUrl: Text; var SPFile: Record "SP File" temporary)
    var
        SPFileParser: Codeunit "SP File";
        OperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        UriBuilder.ResetPath();
        UriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        UriBuilder.SetObject('Files');

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Get(UriBuilder);
        OperationResponse.GetResultAsText(Result);
        SPFileParser.Parse(Result, SPFile);
    end;


    procedure GetFileContent(OdataId: Text; FileName: Text)
    var
        OperationResponse: Codeunit "SP Operation Response";
        FileInStream: InStream;
    begin
        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        UriBuilder.ResetPath(OdataId);
        UriBuilder.SetObject('$value');

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Get(UriBuilder);
        OperationResponse.GetResultAsStream(FileInStream);

        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;


    procedure GetDocumentLibraryRootFolder(OdataID: Text; var SPFolder: Record "SP Folder")
    var
        SPFolderParser: Codeunit "SP Folder";
        OperationResponse: Codeunit "SP Operation Response";
        Result: Text;
    begin
        UriBuilder.ResetPath(OdataID);
        UriBuilder.SetObject('rootfolder');

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Get(UriBuilder);
        OperationResponse.GetResultAsText(Result);
        SPFolderParser.ParseSingle(Result, SPFolder);
    end;


    procedure CreateFolder(ServerRelativeUrl: Text)
    var
        SPHttpContent: Codeunit "SP Http Content";
        OperationResponse: Codeunit "SP Operation Response";
        Request, Metadata : JsonObject;
        Result: Text;
    begin
        UriBuilder.ResetPath();
        UriBuilder.SetObject('folders');

        Metadata.Add('type', 'SP.Folder');
        Request.Add('__metadata', Metadata);
        Request.Add('ServerRelativeUrl', ServerRelativeUrl);


        SPHttpContent.FromJson(Request);
        SPHttpContent.SetRequestDigest(GetRequestDigest(UriBuilder.GetHost()));

        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Post(UriBuilder, SPHttpContent);
        OperationResponse.GetResultAsText(Result);
    end;



    procedure AddFileToFolder(ServerRelativeUrl: Text)
    var
        OperationResponse: Codeunit "SP Operation Response";
        SPHttpContent: Codeunit "SP Http Content";
        FileName: Text;
        FileInStream: InStream;
        Result: Text;
    begin
        if not UploadIntoStream('', '', '', FileName, FileInStream) then
            exit;

        //GET https://{site_url}/_api/web/lists/getbytitle('{list_title}')/items({item_id})/AttachmentFiles('{file_name}')/$value
        UriBuilder.ResetPath();
        UriBuilder.SetMethod('GetFolderByServerRelativeUrl', ServerRelativeUrl);
        UriBuilder.SetObject('Files');
        UriBuilder.SetMethod('add', 'url', '''' + FileName + '''');

        SPHttpContent.FromFileInStream(FileInStream);
        RequestManager.SetAuthorization(Authorization);
        OperationResponse := RequestManager.Post(UriBuilder, SPHttpContent);
        OperationResponse.GetResultAsText(Result);
    end;
    #endregion

}