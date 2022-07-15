codeunit 132970 "SharePoint Client Test"
{
    Subtype = Test;

    var
        SharePointTestLibrary: Codeunit "SharePoint Test Library";
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        DummySharePointAuthorization: Codeunit "Dummy SharePoint Authorization";
        SharePointClient: Codeunit "SharePoint Client";
        BaseUrl: Text;
        IsInitialized: Boolean;

    [Test]
    procedure TestGetLists()
    var
        TempSharePointList: Record "SharePoint List" temporary;
    begin
        // [Scenario] GetLists operation succeds and records are returned
        Initialize();

        SharePointClient.GetLists(TempSharePointList);

        Assert.AreEqual(2, TempSharePointList.Count(), 'Expected 2 records');
        TempSharePointList.FindFirst();

        Assert.AreEqual('100', TempSharePointList."Base Template", StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Base Template")));
        Assert.AreEqual('0', TempSharePointList."Base Type", StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Base Type")));
        Assert.AreEqual('2022-05-23T12:16:04Z', Format(TempSharePointList.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Created")));
        Assert.AreEqual('My Test Documents', TempSharePointList.Description, StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Description")));
        Assert.AreEqual('{854D7F21-1C6A-43AB-A081-20404894B449}', Format(TempSharePointList.Id), StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Id")));
        Assert.AreEqual(false, TempSharePointList."Is Catalog", StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Is Catalog")));
        Assert.AreEqual('SP.Data.My_x0020_Test_x0020_DocumentsListItem', TempSharePointList."List Item Entity Type", StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("List Item Entity Type")));
        Assert.AreEqual('Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')', TempSharePointList.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointList.OdataId.EndsWith('_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')'), StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("OdataId")));
        Assert.AreEqual('SP.List', TempSharePointList.OdataType, StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("OdataType")));
        Assert.AreEqual('Test Documents', TempSharePointList.Title, StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Title")));
    end;

    [Test]
    procedure TestGetListItemByListId()
    var
        TempSharePointListItem: Record "SharePoint List Item" temporary;
        Guid: Guid;
    begin
        // [Scenario] GetListItems by list Id operation succeds and records are returned
        Initialize();

        Evaluate(Guid, '{854D7F21-1C6A-43AB-A081-20404894B449}');
        SharePointClient.GetListItems(Guid, TempSharePointListItem);

        Assert.AreEqual(2, TempSharePointListItem.Count(), 'Expected 2 records');
        TempSharePointListItem.FindFirst();

        Assert.AreEqual(true, TempSharePointListItem.Attachments, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Attachments)));
        Assert.AreEqual('0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510', TempSharePointListItem."Content Type Id", StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Content Type Id")));
        Assert.AreEqual('2022-05-23T12:16:29Z', Format(TempSharePointListItem.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Created")));
        Assert.AreEqual(0, TempSharePointListItem."File System Object Type", StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("File System Object Type")));
        Assert.AreEqual('{27C78F81-F4D9-4EE9-85BD-5D57ADE1B5F4}', Format(TempSharePointListItem.Guid), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Guid")));
        Assert.AreEqual(1, TempSharePointListItem.Id, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Id)));
        Assert.AreEqual('{854D7F21-1C6A-43AB-A081-20404894B449}', Format(TempSharePointListItem."List Id"), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("List Id")));
        Assert.AreEqual('Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)', TempSharePointListItem.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(OdataEditLink)));
        Assert.AreEqual('Test List Item', TempSharePointListItem.Title, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Title)));

    end;

    [Test]
    procedure TestGetListItemByListTitle()
    var
        TempSharePointListItem: Record "SharePoint List Item" temporary;
    begin
        // [Scenario] GetListItems by list title operation succeds and records are returned
        Initialize();

        SharePointClient.GetListItems('Test Documents', TempSharePointListItem);

        Assert.AreEqual(2, TempSharePointListItem.Count(), 'Expected 2 records');
        TempSharePointListItem.FindFirst();

        Assert.AreEqual(true, TempSharePointListItem.Attachments, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Attachments)));
        Assert.AreEqual('0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510', TempSharePointListItem."Content Type Id", StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Content Type Id")));
        Assert.AreEqual('2022-05-23T12:16:29Z', Format(TempSharePointListItem.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Created")));
        Assert.AreEqual(0, TempSharePointListItem."File System Object Type", StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("File System Object Type")));
        Assert.AreEqual('{27C78F81-F4D9-4EE9-85BD-5D57ADE1B5F4}', Format(TempSharePointListItem.Guid), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Guid")));
        Assert.AreEqual(1, TempSharePointListItem.Id, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Id)));
        Assert.AreEqual('{854D7F21-1C6A-43AB-A081-20404894B449}', Format(TempSharePointListItem."List Id"), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("List Id")));
        Assert.AreEqual('Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)', TempSharePointListItem.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(OdataEditLink)));
        Assert.AreEqual('Test List Item', TempSharePointListItem.Title, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Title)));
    end;

    [Test]
    procedure TestGetListItemAttachmentsByListId()
    var
        TempSharePointListItemAtch: Record "SharePoint List Item Atch" temporary;
        Guid: Guid;
    begin
        // [Scenario] GetListItemAttachment by list id operation succeds and records are returned
        Initialize();
        Evaluate(Guid, '{854D7F21-1C6A-43AB-A081-20404894B449}');

        SharePointClient.GetListItemAttachments(Guid, 1, TempSharePointListItemAtch);

        Assert.AreEqual(2, TempSharePointListItemAtch.Count(), 'Expected 2 records');
        TempSharePointListItemAtch.FindFirst();

        Assert.AreEqual('Test Picture.jpg', TempSharePointListItemAtch."File Name", StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("File Name")));
        Assert.AreEqual('{854D7F21-1C6A-43AB-A081-20404894B449}', Format(TempSharePointListItemAtch."List Id"), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("List Id")));
        Assert.AreEqual(1, TempSharePointListItemAtch."List Item Id", StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("List Item Id")));
        Assert.AreEqual('Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test%20Picture.jpg'')', TempSharePointListItemAtch.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointListItemAtch.OdataId.EndsWith('_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test Picture.jpg'')'), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataId")));
        Assert.AreEqual('SP.Attachment', TempSharePointListItemAtch.OdataType, StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataType")));
        Assert.IsTrue(TempSharePointListItemAtch."Server Relative Url".EndsWith('/Lists/Asset Documents/Attachments/1/Test Picture.jpg'), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("Server Relative Url")));
    end;

    [Test]
    procedure TestGetListItemAttachmentsByListTitle()
    var
        TempSharePointListItemAtch: Record "SharePoint List Item Atch" temporary;
    begin
        // [Scenario] GetListItemAttachments by list title operation succeds and records are returned
        Initialize();

        SharePointClient.GetListItemAttachments('Test Documents', 1, TempSharePointListItemAtch);

        Assert.AreEqual(2, TempSharePointListItemAtch.Count(), 'Expected 2 records');
        TempSharePointListItemAtch.FindFirst();

        Assert.AreEqual('Test Picture.jpg', TempSharePointListItemAtch."File Name", StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("File Name")));
        Assert.AreEqual('{854D7F21-1C6A-43AB-A081-20404894B449}', Format(TempSharePointListItemAtch."List Id"), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("List Id")));
        Assert.AreEqual(1, TempSharePointListItemAtch."List Item Id", StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("List Item Id")));
        Assert.AreEqual('Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test%20Picture.jpg'')', TempSharePointListItemAtch.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointListItemAtch.OdataId.EndsWith('_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test Picture.jpg'')'), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataId")));
        Assert.AreEqual('SP.Attachment', TempSharePointListItemAtch.OdataType, StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataType")));
        Assert.IsTrue(TempSharePointListItemAtch."Server Relative Url".EndsWith('/Lists/Asset Documents/Attachments/1/Test Picture.jpg'), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("Server Relative Url")));
    end;

    [Test]
    procedure TestCreateListItemAttachmentByListId()
    var
        TempSharePointListItemAtch: Record "SharePoint List Item Atch" temporary;
        Guid: Guid;
        FileInStream: InStream;
    begin
        // [Scenario] CreateListItemAttachment by list id operation succeds and records are returned
        Initialize();
        Evaluate(Guid, '{854D7F21-1C6A-43AB-A081-20404894B449}');
        InitDummyFile(FileInStream);

        SharePointClient.CreateListItemAttachment(Guid, 1, 'Sample_file.txt', FileInStream, TempSharePointListItemAtch);

        Assert.AreEqual(1, TempSharePointListItemAtch.Count(), 'Expected 1 record');
        TempSharePointListItemAtch.FindFirst();

        Assert.AreEqual('Sample_file.txt', TempSharePointListItemAtch."File Name", StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("File Name")));
        Assert.AreEqual('{854D7F21-1C6A-43AB-A081-20404894B449}', Format(TempSharePointListItemAtch."List Id"), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("List Id")));
        Assert.AreEqual(1, TempSharePointListItemAtch."List Item Id", StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("List Item Id")));
        Assert.AreEqual('Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Sample_file.txt'')', TempSharePointListItemAtch.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointListItemAtch.OdataId.EndsWith('_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Sample_file.txt'')'), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataId")));
        Assert.AreEqual('SP.Attachment', TempSharePointListItemAtch.OdataType, StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataType")));
        Assert.IsTrue(TempSharePointListItemAtch."Server Relative Url".EndsWith('/Lists/Asset Documents/Attachments/1/Sample_file.txt'), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("Server Relative Url")));
    end;

    [Test]
    procedure TestCreateListItemAttachmentByListTitle()
    var
        TempSharePointListItemAtch: Record "SharePoint List Item Atch" temporary;
        FileInStream: InStream;
    begin
        // [Scenario] CreateListItemAttachment by list title operation succeds and records are returned
        Initialize();
        InitDummyFile(FileInStream);

        SharePointClient.CreateListItemAttachment('Test Documents', 1, 'Sample_file.txt', FileInStream, TempSharePointListItemAtch);

        Assert.AreEqual(1, TempSharePointListItemAtch.Count(), 'Expected 1 record');
        TempSharePointListItemAtch.FindFirst();

        Assert.AreEqual('Sample_file.txt', TempSharePointListItemAtch."File Name", StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("File Name")));
        Assert.AreEqual('{854D7F21-1C6A-43AB-A081-20404894B449}', Format(TempSharePointListItemAtch."List Id"), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("List Id")));
        Assert.AreEqual(1, TempSharePointListItemAtch."List Item Id", StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("List Item Id")));
        Assert.AreEqual('Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Sample_file.txt'')', TempSharePointListItemAtch.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointListItemAtch.OdataId.EndsWith('_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Sample_file.txt'')'), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataId")));
        Assert.AreEqual('SP.Attachment', TempSharePointListItemAtch.OdataType, StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("OdataType")));
        Assert.IsTrue(TempSharePointListItemAtch."Server Relative Url".EndsWith('/Lists/Asset Documents/Attachments/1/Sample_file.txt'), StrSubstNo('Different %1 value expected', TempSharePointListItemAtch.FieldCaption("Server Relative Url")));
    end;

    [Test]
    procedure TestCreateListItemByListId()
    var
        TempSharePointListItem: Record "SharePoint List Item" temporary;
        Guid: Guid;
    begin
        // [Scenario] CreateListItem by list Id operation succeds and records are returned
        Initialize();

        Evaluate(Guid, '{854D7F21-1C6A-43AB-A081-20404894B449}');
        SharePointClient.CreateListItem(Guid, 'SP.Data.My_x0020_Test_x0020_DocumentsListItem', 'Test List Item', TempSharePointListItem);

        Assert.AreEqual(1, TempSharePointListItem.Count(), 'Expected 1 rezord');
        TempSharePointListItem.FindFirst();

        Assert.AreEqual(false, TempSharePointListItem.Attachments, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Attachments)));
        Assert.AreEqual('0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510', TempSharePointListItem."Content Type Id", StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Content Type Id")));
        Assert.AreEqual('2022-07-15T08:31:30Z', Format(TempSharePointListItem.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Created")));
        Assert.AreEqual(0, TempSharePointListItem."File System Object Type", StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("File System Object Type")));
        Assert.AreEqual('{17BF42F2-2560-4452-B0CB-DF674AC734F1}', Format(TempSharePointListItem.Guid), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Guid")));
        Assert.AreEqual(3, TempSharePointListItem.Id, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Id)));
        Assert.AreEqual('{854D7F21-1C6A-43AB-A081-20404894B449}', Format(TempSharePointListItem."List Id"), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("List Id")));
        Assert.AreEqual('Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)', TempSharePointListItem.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(OdataEditLink)));
        Assert.AreEqual('Test Item', TempSharePointListItem.Title, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Title)));
    end;

    [Test]
    procedure TestCreateListItemByListTitle()
    var
        TempSharePointListItem: Record "SharePoint List Item" temporary;
    begin
        // [Scenario] CreateListItem by list title operation succeds and records are returned
        Initialize();

        SharePointClient.CreateListItem('Test Documents', 'SP.Data.My_x0020_Test_x0020_DocumentsListItem', 'Test List Item', TempSharePointListItem);

        Assert.AreEqual(1, TempSharePointListItem.Count(), 'Expected 1 rezord');
        TempSharePointListItem.FindFirst();

        Assert.AreEqual(false, TempSharePointListItem.Attachments, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Attachments)));
        Assert.AreEqual('0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510', TempSharePointListItem."Content Type Id", StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Content Type Id")));
        Assert.AreEqual('2022-07-15T08:31:30Z', Format(TempSharePointListItem.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Created")));
        Assert.AreEqual(0, TempSharePointListItem."File System Object Type", StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("File System Object Type")));
        Assert.AreEqual('{17BF42F2-2560-4452-B0CB-DF674AC734F1}', Format(TempSharePointListItem.Guid), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("Guid")));
        Assert.AreEqual(3, TempSharePointListItem.Id, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Id)));
        Assert.AreEqual('{854D7F21-1C6A-43AB-A081-20404894B449}', Format(TempSharePointListItem."List Id"), StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption("List Id")));
        Assert.AreEqual('Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)', TempSharePointListItem.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(OdataEditLink)));
        Assert.AreEqual('Test Item', TempSharePointListItem.Title, StrSubstNo('Different %1 value expected', TempSharePointListItem.FieldCaption(Title)));
    end;

    [Test]
    procedure TestCreateList()
    var
        TempSharePointList: Record "SharePoint List" temporary;
    begin
        // [Scenario] CreateListItem by list title operation succeds and records are returned
        Initialize();

        SharePointClient.CreateList('Test Sample List Title', 'Test Sample List Description', TempSharePointList);

        Assert.AreEqual(1, TempSharePointList.Count(), 'Expected 1 record');
        TempSharePointList.FindFirst();

        Assert.AreEqual('100', TempSharePointList."Base Template", StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Base Template")));
        Assert.AreEqual('0', TempSharePointList."Base Type", StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Base Type")));
        Assert.AreEqual('2022-07-15T11:45:34Z', Format(TempSharePointList.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Created")));
        Assert.AreEqual('Test Sample List Description', TempSharePointList.Description, StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Description")));
        Assert.AreEqual('{B3CF160F-D953-49D3-BF3E-5704DEE4559E}', Format(TempSharePointList.Id), StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Id")));
        Assert.AreEqual(false, TempSharePointList."Is Catalog", StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Is Catalog")));
        Assert.AreEqual('SP.Data.Test_x0020_Sample_x0020_List_x0020_TitleListItem', TempSharePointList."List Item Entity Type", StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("List Item Entity Type")));
        Assert.AreEqual('Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')', TempSharePointList.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointList.OdataId.EndsWith('_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')'), StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("OdataId")));
        Assert.AreEqual('SP.List', TempSharePointList.OdataType, StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("OdataType")));
        Assert.AreEqual('Test Sample List Title', TempSharePointList.Title, StrSubstNo('Different %1 value expected', TempSharePointList.FieldCaption("Title")));
    end;

    [Test]
    procedure TestGetDocumentLibraryRootFolder()
    var
        TempSharePointFolder: Record "SharePoint Folder" temporary;
        ParentUrl: Text;
    begin
        // [Scenario] GetDocumentLibraryRootFolder operation succeds and records are returned
        Initialize();

        ParentUrl := BaseUrl.Substring(StrPos(BaseUrl, '/')).TrimEnd('/');
        SharePointClient.GetDocumentLibraryRootFolder('https://' + BaseUrl + '/_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')', TempSharePointFolder);

        Assert.AreEqual(1, TempSharePointFolder.Count(), 'Expected 1 record');
        TempSharePointFolder.FindFirst();

        Assert.AreEqual('Test Documents', TempSharePointFolder.Name, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption(Name)));
        Assert.AreEqual('2022-05-23T12:16:04Z', Format(TempSharePointFolder.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("Created")));
        Assert.AreEqual(true, TempSharePointFolder.Exists, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption(Exists)));
        Assert.AreEqual(2, TempSharePointFolder."Item Count", StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("Item Count")));
        Assert.AreEqual('Web/GetFolderByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test%20Documents'')', TempSharePointFolder.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointFolder.OdataId.EndsWith('_api/Web/GetFolderByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test Documents'')'), StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("OdataId")));
        Assert.AreEqual('SP.Folder', TempSharePointFolder.OdataType, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("OdataType")));
        Assert.IsTrue(TempSharePointFolder."Server Relative Url".EndsWith('/Lists/Test Documents'), StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("Server Relative Url")));
    end;

    [Test]
    procedure TestGetSubFoldersByServerRelativeUrl()
    var
        TempSharePointFolder: Record "SharePoint Folder" temporary;
        ParentUrl: Text;
    begin
        // [Scenario] GetSubFoldersByServerRelativeUrl operation succeds and records are returned
        Initialize();

        ParentUrl := BaseUrl.Substring(StrPos(BaseUrl, '/')).TrimEnd('/');
        SharePointClient.GetSubFoldersByServerRelativeUrl(ParentUrl + '/Lists/Test%20Documents', TempSharePointFolder);

        Assert.AreEqual(1, TempSharePointFolder.Count(), 'Expected 1 record');
        TempSharePointFolder.FindFirst();

        Assert.AreEqual('Attachments', TempSharePointFolder.Name, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption(Name)));
        Assert.AreEqual('2022-05-23T12:16:04Z', Format(TempSharePointFolder.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("Created")));
        Assert.AreEqual(true, TempSharePointFolder.Exists, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption(Exists)));
        Assert.AreEqual(0, TempSharePointFolder."Item Count", StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("Item Count")));
        Assert.AreEqual('Web/GetFolderByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test%20Documents/Attachments'')', TempSharePointFolder.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointFolder.OdataId.EndsWith('_api/Web/GetFolderByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test Documents/Attachments'')'), StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("OdataId")));
        Assert.AreEqual('SP.Folder', TempSharePointFolder.OdataType, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("OdataType")));
        Assert.IsTrue(TempSharePointFolder."Server Relative Url".EndsWith('/Lists/Test Documents/Attachments'), StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("Server Relative Url")));
    end;

    [Test]
    procedure TestGetFolderFilesByServerRelativeUrl()
    var
        TempSharePointFile: Record "SharePoint File" temporary;
        ParentUrl: Text;
    begin
        // [Scenario] GetFolderFilesByServerRelativeUrl operation succeds and records are returned
        Initialize();

        ParentUrl := BaseUrl.Substring(StrPos(BaseUrl, '/')).TrimEnd('/');
        SharePointClient.GetFolderFilesByServerRelativeUrl(ParentUrl + '/Lists/Test%20Documents/Attachments/1', TempSharePointFile);

        Assert.AreEqual(2, TempSharePointFile.Count(), 'Expected 2 record');
        TempSharePointFile.FindFirst();

        Assert.AreEqual('document.pdf', TempSharePointFile.Name, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption(Name)));
        Assert.AreEqual('2022-07-14T22:14:33Z', Format(TempSharePointFile.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("Created")));
        Assert.AreEqual(true, TempSharePointFile.Exists, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption(Exists)));
        Assert.AreEqual('Web/GetFileByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test%20Documents/Attachments/1/document.pdf'')', TempSharePointFile.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointFile.OdataId.EndsWith('_api/Web/GetFileByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test Documents/Attachments/1/document.pdf'')'), StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("OdataId")));
        Assert.AreEqual('SP.File', TempSharePointFile.OdataType, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("OdataType")));
        Assert.IsTrue(TempSharePointFile."Server Relative Url".EndsWith('/Lists/Test Documents/Attachments/1/document.pdf'), StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("Server Relative Url")));
        Assert.AreEqual(25555, TempSharePointFile.Length, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption(Length)));
    end;

    [Test]
    procedure CreateFolder()
    var
        TempSharePointFolder: Record "SharePoint Folder" temporary;
        ParentUrl: Text;
    begin
        // [Scenario] CreateFolder operation succeds and records are returned
        Initialize();

        ParentUrl := BaseUrl.Substring(StrPos(BaseUrl, '/')).TrimEnd('/');
        SharePointClient.CreateFolder(ParentUrl + '/folders', TempSharePointFolder);

        Assert.AreEqual(1, TempSharePointFolder.Count(), 'Expected 1 record');
        TempSharePointFolder.FindFirst();

        Assert.AreEqual('TestSubfolder', TempSharePointFolder.Name, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption(Name)));
        Assert.AreEqual('2022-07-15T20:40:25Z', Format(TempSharePointFolder.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("Created")));
        Assert.AreEqual(true, TempSharePointFolder.Exists, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption(Exists)));
        Assert.AreEqual(0, TempSharePointFolder."Item Count", StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("Item Count")));
        Assert.AreEqual('Web/GetFolderByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test%20Documents/Attachments/TestSubfolder'')', TempSharePointFolder.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointFolder.OdataId.EndsWith('_api/Web/GetFolderByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test Documents/Attachments/TestSubfolder'')'), StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("OdataId")));
        Assert.AreEqual('SP.Folder', TempSharePointFolder.OdataType, StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("OdataType")));
        Assert.IsTrue(TempSharePointFolder."Server Relative Url".EndsWith('/Lists/Test Documents/Attachments/TestSubfolder'), StrSubstNo('Different %1 value expected', TempSharePointFolder.FieldCaption("Server Relative Url")));
    end;

    [Test]
    procedure AddFileToFolder()
    var
        TempSharePointFile: Record "SharePoint File" temporary;
        FileInStream: InStream;
        ParentUrl: Text;
    begin
        // [Scenario] AddFileToFolder operation succeds and records are returned
        Initialize();
        InitDummyFile(FileInStream);

        ParentUrl := BaseUrl.Substring(StrPos(BaseUrl, '/')).TrimEnd('/');
        SharePointClient.AddFileToFolder(ParentUrl + '/Lists/Test%20Documents/Attachments', 'SampleTestFile.jpg', FileInStream, TempSharePointFile);

        Assert.AreEqual(1, TempSharePointFile.Count(), 'Expected 1 record');
        TempSharePointFile.FindFirst();

        Assert.AreEqual('SampleTestFile.jpg', TempSharePointFile.Name, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption(Name)));
        Assert.AreEqual('2022-07-15T21:13:18Z', Format(TempSharePointFile.Created, 0, 9), StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("Created")));
        Assert.AreEqual(true, TempSharePointFile.Exists, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption(Exists)));
        Assert.AreEqual('Web/GetFileByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')', TempSharePointFile.OdataEditLink, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("OdataEditLink")));
        Assert.IsTrue(TempSharePointFile.OdataId.EndsWith('_api/Web/GetFileByServerRelativePath(decodedurl=''' + ParentUrl + '/Lists/Test Documents/Attachments/SampleTestFile.jpg'')'), StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("OdataId")));
        Assert.AreEqual('SP.File', TempSharePointFile.OdataType, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("OdataType")));
        Assert.IsTrue(TempSharePointFile."Server Relative Url".EndsWith('/Lists/Test Documents/Attachments/SampleTestFile.jpg'), StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption("Server Relative Url")));
        Assert.AreEqual(44087, TempSharePointFile.Length, StrSubstNo('Different %1 value expected', TempSharePointFile.FieldCaption(Length)));
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        BindSubscription(SharePointTestLibrary);
        BaseUrl := GenerateRandomUri();
        SharePointClient.Initialize(BaseUrl, DummySharePointAuthorization);
        IsInitialized := true;
    end;

    local procedure GenerateRandomUri(): Text
    begin
        exit(StrSubstNo('%1.sharepoint.com/sites/%2', Any.AlphabeticText(20), Any.AlphabeticText(10)));
    end;

    local procedure InitDummyFile(var FileInStream: InStream)
    var
        TempBlob: Codeunit "Temp Blob";
        FileOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(FileOutStream);
        FileOutStream.WriteText('Dummy test file content');
        TempBlob.CreateInStream(FileInStream);
    end;
}