codeunit 135140 "Mg Client Test"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";


    [Test]
    procedure AuthTriggeredTest()
    var
        MgAuthSpy: Codeunit "Mg Auth. Spy";
        MicrosoftGraphClient: Codeunit "Microsoft Graph Client";
        MockHttpClient: Codeunit "Mock HttpClient";
        TempBlob: Codeunit "Temp Blob";
        ResponseInStream: InStream;
    begin
        MicrosoftGraphClient.SetHttpClient(MockHttpClient);
        MicrosoftGraphClient.Initialize(Enum::"Microsoft Graph API Version"::"v1.0", MgAuthSpy);
        ResponseInStream := TempBlob.CreateInStream();

        // [WHEN] When Get Method is called  
        MicrosoftGraphClient.Get('groups', ResponseInStream);

        // [THEN] Verify authorization of request is triggered
        LibraryAssert.AreEqual(true, MgAuthSpy.IsInvoked(), 'Authorization should be invoked.');
    end;

    [Test]
    procedure RequestUriTest()
    var
        MgAuthSpy: Codeunit "Mg Auth. Spy";
        MicrosoftGraphClient: Codeunit "Microsoft Graph Client";
        MockHttpClient: Codeunit "Mock HttpClient";
        TempBlob: Codeunit "Temp Blob";
        HttpRequestMessage: HttpRequestMessage;
        ResponseInStream: InStream;
    begin
        MicrosoftGraphClient.SetHttpClient(MockHttpClient);
        MicrosoftGraphClient.Initialize(Enum::"Microsoft Graph API Version"::"v1.0", MgAuthSpy);
        ResponseInStream := TempBlob.CreateInStream();

        // [WHEN] When Get Method is called  
        MicrosoftGraphClient.Get('groups', ResponseInStream);

        // [THEN] Verify request uri is build correct
        MockHttpClient.GetHttpRequestMessage(HttpRequestMessage);
        LibraryAssert.AreEqual(HttpRequestMessage.GetRequestUri(), 'https://graph.microsoft.com/v1.0/groups', 'Incorrect Request URI.');
    end;

}