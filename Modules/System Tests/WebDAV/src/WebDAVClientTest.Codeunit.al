codeunit 135690 "WebDAV Client Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        WebDAVClient: Codeunit "WebDAV Client";
        WebDAVTestLibrary: Codeunit "WebDAV Test Library";
        DummyWebDAVAuthorization: Codeunit "Dummy WebDAV Authorization";
        XmlNamespaceManager: XmlNamespaceManager;
        BaseUrl: Text;
        IsInitialized: Boolean;
        DiffValueLbl: Label 'Different %1 value expected';

    [TEST]
    procedure TestGetCollections()
    var
        WebDAVContent: Record "WebDAV Content";
        IsSuccess: Boolean;
    begin
        Initialize();

        IsSuccess := WebDAVClient.GetCollections(WebDAVContent, false);
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');
        Assert.AreEqual(4, WebDAVContent.Count, 'Expected 4 Records');

        WebDAVContent.FindFirst();
        WebDAVContent.Next(2);

        Assert.AreEqual('Folder2', WebDAVContent.Name, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Name)));
        Assert.AreEqual(0, WebDAVContent."Content Length", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Length")));
        Assert.AreEqual('', WebDAVContent."Content Type", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Type")));

        Assert.AreEqual(true, WebDAVContent."Is Collection", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Is Collection")));
        Assert.AreEqual(1, WebDAVContent.Level, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Level)));
        Assert.AreEqual(BaseUrl + '/Folder2', WebDAVContent."Full Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Full Url")));
        Assert.AreEqual('Folder2', WebDAVContent."Relative Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Relative Url")));
        Assert.AreEqual('2023-01-06T12:00:00Z', Format(WebDAVContent."Creation Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Creation Date")));
        Assert.AreEqual('2023-01-06T12:00:00Z', Format(WebDAVContent."Last Modified Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Last Modified Date")));
    end;

    [TEST]
    procedure TestGetFiles()
    var
        WebDAVContent: Record "WebDAV Content";
        IsSuccess: Boolean;
    begin
        Initialize();

        IsSuccess := WebDAVClient.GetFiles(WebDAVContent, false);
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');

        Assert.AreEqual(3, WebDAVContent.Count, 'Expected 3 records');
        WebDAVContent.FindFirst();
        WebDAVContent.Next();

        Assert.AreEqual('logo.png', WebDAVContent.Name, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Name)));
        Assert.AreEqual(4567, WebDAVContent."Content Length", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Length")));
        Assert.AreEqual('image/png', WebDAVContent."Content Type", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Type")));

        Assert.AreEqual(false, WebDAVContent."Is Collection", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Is Collection")));
        Assert.AreEqual(1, WebDAVContent.Level, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Level)));
        Assert.AreEqual(BaseUrl + '/logo.png', WebDAVContent."Full Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Full Url")));
        Assert.AreEqual('logo.png', WebDAVContent."Relative Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Relative Url")));
        Assert.AreEqual('2023-01-01T12:02:02Z', Format(WebDAVContent."Creation Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Creation Date")));
        Assert.AreEqual('2023-01-01T12:02:02Z', Format(WebDAVContent."Last Modified Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Last Modified Date")));
    end;

    [TEST]
    procedure TestFilesAndCollectionCount()
    var
        WebDAVContent: Record "WebDAV Content";
        IsSuccess: Boolean;
    begin
        Initialize();

        IsSuccess := WebDAVClient.GetFilesAndCollections(WebDAVContent, false);
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');

        Assert.AreEqual(7, WebDAVContent.Count, 'Expected 7 records');
        WebDAVContent.FindFirst();
        WebDAVContent.Next(3);

        Assert.AreEqual('response.xml', WebDAVContent.Name, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Name)));
        Assert.AreEqual(890, WebDAVContent."Content Length", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Length")));
        Assert.AreEqual('text/xml', WebDAVContent."Content Type", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Type")));

        Assert.AreEqual(false, WebDAVContent."Is Collection", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Is Collection")));
        Assert.AreEqual(1, WebDAVContent.Level, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Level)));
        Assert.AreEqual(BaseUrl + '/response.xml', WebDAVContent."Full Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Full Url")));
        Assert.AreEqual('response.xml', WebDAVContent."Relative Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Relative Url")));
        Assert.AreEqual('2023-01-01T12:03:03Z', Format(WebDAVContent."Creation Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Creation Date")));
        Assert.AreEqual('2023-01-01T12:03:03Z', Format(WebDAVContent."Last Modified Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Last Modified Date")));

        WebDAVContent.Next(3);
        Assert.AreEqual('Folder3', WebDAVContent.Name, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Name)));
        Assert.AreEqual(0, WebDAVContent."Content Length", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Length")));
        Assert.AreEqual('', WebDAVContent."Content Type", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Type")));

        Assert.AreEqual(true, WebDAVContent."Is Collection", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Is Collection")));
        Assert.AreEqual(1, WebDAVContent.Level, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Level)));
        Assert.AreEqual(BaseUrl + '/Folder3', WebDAVContent."Full Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Full Url")));
        Assert.AreEqual('Folder3', WebDAVContent."Relative Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Relative Url")));
        Assert.AreEqual('2023-01-09T12:00:00Z', Format(WebDAVContent."Creation Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Creation Date")));
        Assert.AreEqual('2023-01-09T12:00:00Z', Format(WebDAVContent."Last Modified Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Last Modified Date")));
    end;

    [TEST]
    procedure TestCollectionCountRecursive()
    var
        WebDAVContent: Record "WebDAV Content";
        IsSuccess: Boolean;
    begin
        Initialize();

        IsSuccess := WebDAVClient.GetCollections(WebDAVContent, true);
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');
        Assert.AreEqual(10, WebDAVContent.Count, 'Expected 10 Records');

        WebDAVContent.FindFirst();
        WebDAVContent.Next(2);

        Assert.AreEqual('SubFolder1', WebDAVContent.Name, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Name)));
        Assert.AreEqual(0, WebDAVContent."Content Length", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Length")));
        Assert.AreEqual('', WebDAVContent."Content Type", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Type")));

        Assert.AreEqual(true, WebDAVContent."Is Collection", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Is Collection")));
        Assert.AreEqual(2, WebDAVContent.Level, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Level)));
        Assert.AreEqual(BaseUrl + '/Folder1/SubFolder1', WebDAVContent."Full Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Full Url")));
        Assert.AreEqual('Folder1/SubFolder1', WebDAVContent."Relative Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Relative Url")));
        Assert.AreEqual('2023-01-03T12:00:00Z', Format(WebDAVContent."Creation Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Creation Date")));
        Assert.AreEqual('2023-01-03T12:00:00Z', Format(WebDAVContent."Last Modified Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Last Modified Date")));
    end;

    [TEST]
    procedure TestFileCountRecursive()
    var
        WebDAVContent: Record "WebDAV Content";
        IsSuccess: Boolean;
    begin
        Initialize();

        IsSuccess := WebDAVClient.GetFiles(WebDAVContent, true);
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');

        Assert.AreEqual(13, WebDAVContent.Count, 'Expected 13 records');
        WebDAVContent.FindFirst();
        WebDAVContent.Next(8);

        Assert.AreEqual('file1.pdf', WebDAVContent.Name, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Name)));
        Assert.AreEqual(53950, WebDAVContent."Content Length", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Length")));
        Assert.AreEqual('application/pdf', WebDAVContent."Content Type", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Type")));

        Assert.AreEqual(false, WebDAVContent."Is Collection", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Is Collection")));
        Assert.AreEqual(3, WebDAVContent.Level, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Level)));
        Assert.AreEqual(BaseUrl + '/Folder1/Subfolder2/file1.pdf', WebDAVContent."Full Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Full Url")));
        Assert.AreEqual('Folder1/Subfolder2/file1.pdf', WebDAVContent."Relative Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Relative Url")));
        Assert.AreEqual('2023-01-04T23:59:59Z', Format(WebDAVContent."Creation Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Creation Date")));
        Assert.AreEqual('2023-01-04T23:59:59Z', Format(WebDAVContent."Last Modified Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Last Modified Date")));
    end;

    [TEST]
    procedure TestFilesAndCollectionCountRecursive()
    var
        WebDAVContent: Record "WebDAV Content";
        IsSuccess: Boolean;
    begin
        Initialize();

        IsSuccess := WebDAVClient.GetFilesAndCollections(WebDAVContent, true);
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');

        Assert.AreEqual(23, WebDAVContent.Count, 'Expected 23 records');
        WebDAVContent.FindFirst();
        WebDAVContent.Next(17);

        Assert.AreEqual('SubSubFolder1', WebDAVContent.Name, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Name)));
        Assert.AreEqual(0, WebDAVContent."Content Length", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Length")));
        Assert.AreEqual('', WebDAVContent."Content Type", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Type")));

        Assert.AreEqual(true, WebDAVContent."Is Collection", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Is Collection")));
        Assert.AreEqual(3, WebDAVContent.Level, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Level)));
        Assert.AreEqual(BaseUrl + '/Folder2/SubFolder1/SubSubFolder1', WebDAVContent."Full Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Full Url")));
        Assert.AreEqual('Folder2/SubFolder1/SubSubFolder1', WebDAVContent."Relative Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Relative Url")));
        Assert.AreEqual('2023-01-07T20:00:00Z', Format(WebDAVContent."Creation Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Creation Date")));
        Assert.AreEqual('2023-01-07T20:00:00Z', Format(WebDAVContent."Last Modified Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Last Modified Date")));

        WebDAVContent.FindLast();
        WebDAVContent.Next(-2);

        Assert.AreEqual('file1.txt', WebDAVContent.Name, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Name)));
        Assert.AreEqual(21, WebDAVContent."Content Length", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Length")));
        Assert.AreEqual('text/plain', WebDAVContent."Content Type", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Content Type")));

        Assert.AreEqual(false, WebDAVContent."Is Collection", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Is Collection")));
        Assert.AreEqual(2, WebDAVContent.Level, StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption(Level)));
        Assert.AreEqual(BaseUrl + '/Folder3/file1.txt', WebDAVContent."Full Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Full Url")));
        Assert.AreEqual('Folder3/file1.txt', WebDAVContent."Relative Url", StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Relative Url")));
        Assert.AreEqual('2023-01-09T13:13:13Z', Format(WebDAVContent."Creation Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Creation Date")));
        Assert.AreEqual('2023-12-31T23:59:59Z', Format(WebDAVContent."Last Modified Date", 0, 9), StrSubstNo(DiffValueLbl, WebDAVContent.FieldCaption("Last Modified Date")));
    end;

    [TEST]
    procedure TestMakeCollection()
    var
        IsSuccess: Boolean;
    begin
        Initialize();
        IsSuccess := WebDAVClient.MakeCollection('SuccessFolder');
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');
    end;


    [TEST]
    procedure TestPut()
    var
        IsSuccess: Boolean;
    begin
        Initialize();
        IsSuccess := WebDAVClient.Put('This is a test string');
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');
    end;

    [TEST]
    procedure TestGetFileContent()
    var
        ResponseText: Text;
        IsSuccess: Boolean;
    begin
        Initialize();
        IsSuccess := WebDAVClient.GetFileContentAsText(ResponseText);
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');

        Assert.AreEqual('This is a test string.', ResponseText, 'Different value expected.');
    end;

    [TEST]
    procedure TestDelete()
    var
        IsSuccess: Boolean;
    begin
        Initialize();
        IsSuccess := WebDAVClient.Delete('Success.txt');
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');
    end;


    [TEST]
    procedure TestCopy()
    var
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        Values: List of [Text];
        Destination: Text;
        IsSuccess: Boolean;
    begin
        Initialize();
        Destination := BaseUrl + '/Destination/File.extension';
        IsSuccess := WebDAVClient.Copy(Destination);
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');

        RequestMessage := WebDAVTestLibrary.GetRequestMessage();
        RequestMessage.GetHeaders(RequestHeaders);
        Assert.AreEqual(true, RequestHeaders.Contains('Destination'), 'Destination Header expected.');

        RequestHeaders.GetValues('Destination', Values);
        Assert.AreEqual(Destination, Values.Get(1), 'Different Uri expected.');
    end;

    [TEST]
    procedure TestMove()
    var
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        Values: List of [Text];
        Destination: Text;
        IsSuccess: Boolean;
    begin
        Initialize();
        Destination := BaseUrl + '/Destination/File.extension';
        IsSuccess := WebDAVClient.Move(Destination);
        Assert.AreEqual(true, IsSuccess, 'Successfull operation expected');

        RequestMessage := WebDAVTestLibrary.GetRequestMessage();
        RequestMessage.GetHeaders(RequestHeaders);
        Assert.AreEqual(true, RequestHeaders.Contains('Destination'), 'Destination Header expected.');

        RequestHeaders.GetValues('Destination', Values);
        Assert.AreEqual(Destination, Values.Get(1), 'Different Uri expected.');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        BindSubscription(WebDAVTestLibrary);
        BaseUrl := GenerateRandomUri();
        WebDAVClient.Initialize(BaseUrl, DummyWebDAVAuthorization);
        IsInitialized := true;
    end;

    local procedure GenerateRandomUri(): Text
    begin
        exit(StrSubstNo('http://%1.%2.org/%3', Any.AlphabeticText(20), Any.AlphabeticText(10), Any.AlphabeticText(10)));
    end;

}