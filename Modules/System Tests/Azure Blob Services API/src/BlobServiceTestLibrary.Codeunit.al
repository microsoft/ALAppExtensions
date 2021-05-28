codeunit 88154 "Blob Service Test Library"
{
    Access = Internal;

    procedure ClearStorageAccount(TestContext: Codeunit "Blob Service API Test Context")
    var
        Container: Record "Container";
        OperationObject: Codeunit "Blob API Operation Object";
    begin
        // [SCENARIO] This is a helper; it'll remove all containters from the Storage Account (assumes that some other functions are working)
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);
        BlobServicesAPI.ListContainers(OperationObject, Container);

        if not Container.Find('-') then
            exit;

        repeat
            OperationObject.SetContainerName(Container.Name);
            BlobServicesAPI.DeleteContainer(OperationObject);
            Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Cleanup / Delete Container', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        until Container.Next() = 0;
    end;

    procedure CreateContainer(TestContext: Codeunit "Blob Service API Test Context")
    var
        ContainerName: Text;
    begin
        // [SCENARIO] A new containter is created in the Storage Account

        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure ListContainers(TestContext: Codeunit "Blob Service API Test Context")
    var
        Container: Record "Container";
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerNames: List of [Text];
        ContainerName: Text;
        Count1: Integer;
        Count2: Integer;
    begin
        // [SCENARIO] Existing containters are listed from the Storage Account

        // [GIVEN] A list of Container Names
        HelperLibrary.GetListOfContainerNames(ContainerNames);

        // [GIVEN] A Storage Account exists
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        // [THEN] Create the Containers in the Storage Account
        foreach ContainerName in ContainerNames do begin
            OperationObject.SetContainerName(ContainerName);
            BlobServicesAPI.CreateContainer(OperationObject);
            Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Create Container', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        end;

        // [THEN] List the Containers in the Storage Account
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);
        BlobServicesAPI.ListContainers(OperationObject, Container);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'List Container', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Compare number of returned containers with number of expected containers
        Count1 := Container.Count();
        Count2 := ContainerNames.Count();
        Assert.AreEqual(Count1, Count2, 'Number of returned Containers does not match the ones created.');

        // [THEN] Cleanup / Delete the Containers from the Storage Account
        foreach ContainerName in ContainerNames do begin
            OperationObject.SetContainerName(ContainerName);
            BlobServicesAPI.DeleteContainer(OperationObject);
            Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Cleanup / Delete Container', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        end;
    end;

    procedure GetBlobServiceProperties(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        Document: XmlDocument;
    begin
        // [SCENARIO] Get Blob Service Properties

        // [GIVEN] A Storage Account exists
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        // [THEN] Retrieve properties via GetBlobServiceProperties
        Document := BlobServicesAPI.GetBlobServiceProperties(OperationObject);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get Blob Service Properties', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.IsTrue(StrPos(Format(Document), 'StorageServiceProperties') > 0, StrSubstNo(OperationFailedErr, 'Get Blob Service Properties', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
    end;

    procedure SetBlobServiceProperties(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        Document: XmlDocument;
    begin
        // [SCENARIO] Set Blob Service Properties

        // [GIVEN] A Storage Account exists
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        // [GIVEN] Default properties
        Document := HelperLibrary.GetDefaultBlobServiceProperties(false);

        // [THEN] Set properties (unchanged)
        BlobServicesAPI.SetBlobServiceProperties(OperationObject, Document);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Service Properties', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
    end;

    procedure PreflightBlobRequest(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        Document: XmlDocument;
        AccessControlRequestMethod: Enum "Http Request Type";
    begin

        // [SCENARIO] Preflight Blob Request

        // [GIVEN] A Storage Account exists        
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        // [THEN] Set properties (CORS)
        Document := HelperLibrary.GetDefaultBlobServiceProperties(true);

        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        BlobServicesAPI.SetBlobServiceProperties(OperationObject, Document);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Service Properties (CORS)', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // In the emulator the change is immeadiate, but on a real account it takes up to 60 seconds to be applied
        if OperationObject.GetStorageAccountName() <> 'devstoreaccount1' then
            Sleep(1000 * 60);

        // [THEN] Test with updated settings
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        BlobServicesAPI.PreflightBlobRequest(OperationObject, '127.0.0.1', enum::"Http Request Type"::PUT);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Preflight Blob Request (CORS)', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Set back to defaults
        Document := HelperLibrary.GetDefaultBlobServiceProperties(false);

        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        BlobServicesAPI.SetBlobServiceProperties(OperationObject, Document);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Service Properties', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
    end;

    procedure GetBlobServiceStats(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        Document: XmlDocument;
    begin
        // [SCENARIO] Get Blob Service Stats

        // [GIVEN] A Storage Account exists
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        Document := BlobServicesAPI.GetBlobServiceStats(OperationObject);

        Assert.IsTrue(StrPos(Format(Document), 'StorageServiceStats') > 0, StrSubstNo(OperationFailedErr, 'Get Blob Service Stats', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
    end;

    procedure GetAccountInformation(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ReturnValue: Text;
    begin
        // [SCENARIO] Get Account Information

        // [GIVEN] A Storage Account exists
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        BlobServicesAPI.GetAccountInformation(OperationObject);
        ReturnValue := BlobAPIValueHelper.GetSkuNameFromResponseHeaders(OperationObject);
        Assert.IsTrue(StrLen(ReturnValue) > 0, StrSubstNo(OperationFailedErr, 'Get Account Information', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        ReturnValue := BlobAPIValueHelper.GetAccountKindFromResponseHeaders(OperationObject);
        Assert.IsTrue(StrLen(ReturnValue) > 0, StrSubstNo(OperationFailedErr, 'Get Account Information', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
    end;

    procedure GetUserDelegationKeyExpectedError(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        StartDateTime: DateTime;
        ExpiryDateTime: DateTime;
        ReturnValue: Text;
    begin
        // [SCENARIO] Get User Delegation Key
        // As of today (2021-04-05) this is not implemented yet in Azurite; only test against real Storage Account

        // [GIVEN] A Storage Account exists
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject);

        StartDateTime := CurrentDateTime();
        ExpiryDateTime := CurrentDateTime() + 60000;
        ReturnValue := BlobServicesAPI.GetUserDelegationKey(OperationObject, ExpiryDateTime, StartDateTime);
        Assert.AreEqual(GetLastErrorText, 'Only works with Azure AD authentication, which is not implemented yet', 'Not as expected');
    end;

    procedure GetContainerProperties(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        ReturnValue: Text;
    begin
        // [SCENARIO] Get Container Properties

        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Get Container Properties
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        BlobServicesAPI.GetContainerProperties(OperationObject);
        ReturnValue := BlobAPIValueHelper.GetLeaseStateFromResponseHeaders(OperationObject);
        Assert.AreEqual(ReturnValue.ToLower(), 'available', StrSubstNo(OperationFailedErr, 'Get Container Properties', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        // TODO: maybe check more properties from the result

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure SetContainerMetadata(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
    begin
        // [SCENARIO] Set Container Metadata

        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Set Container Metadata
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        BlobAPIValueHelper.SetMetadataNameValueHeader(OperationObject, 'Dummy01', 'DummyValue01');
        BlobAPIValueHelper.SetMetadataNameValueHeader(OperationObject, 'Dummy02', 'DummyValue02');
        BlobServicesAPI.SetContainerMetadata(OperationObject);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Container Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure GetContainerMetadata(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        ReturnValue: Text;
    begin
        // [SCENARIO] Get Container Metadata

        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Set Container Metadata
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        BlobAPIValueHelper.SetMetadataNameValueHeader(OperationObject, 'Dummy01', 'DummyValue01');
        BlobAPIValueHelper.SetMetadataNameValueHeader(OperationObject, 'Dummy02', 'DummyValue02');
        BlobServicesAPI.SetContainerMetadata(OperationObject);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Container Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Get Container Metadata
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        BlobServicesAPI.GetContainerMetadata(OperationObject);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get Container Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        ReturnValue := BlobAPIValueHelper.GetMetaValueFromResponseHeaders(OperationObject, 'Dummy01');
        Assert.AreEqual(ReturnValue, 'DummyValue01', StrSubstNo(OperationFailedErr, 'Get Container Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        ReturnValue := BlobAPIValueHelper.GetMetaValueFromResponseHeaders(OperationObject, 'Dummy02');
        Assert.AreEqual(ReturnValue, 'DummyValue02', StrSubstNo(OperationFailedErr, 'Get Container Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure GetContainerACL(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        Document: XmlDocument;
    begin
        // [SCENARIO] Get Container ACL

        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Get Container ACL
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        Document := BlobServicesAPI.GetContainerACL(OperationObject);
        Assert.IsTrue(StrPos(Format(Document), 'SignedIdentifiers') > 0, StrSubstNo(OperationFailedErr, 'Get Container ACL', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure SetContainerACL(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        Document1: XmlDocument;
        Document2: XmlDocument;
    begin
        // [SCENARIO] Set Container ACL

        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Set Container ACL
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        Document1 := HelperLibrary.GetSampleContainerACL();
        BlobServicesAPI.SetContainerACL(OperationObject, Document1);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Container ACL', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Get Container ACL
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        Document2 := BlobServicesAPI.GetContainerACL(OperationObject);
        Assert.IsTrue(StrPos(Format(Document2), 'SignedIdentifiers') > 0, StrSubstNo(OperationFailedErr, 'Get Container ACL', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.IsTrue(StrPos(Format(Document2), '<Start>2020-09-28T08:49:37.0000000Z</Start>') > 0, StrSubstNo(OperationFailedErr, 'Get Container ACL', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure LeaseContainerAcquireAndRelease(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        LeaseId: Guid;
        EmptyGuid: Guid;

    begin
        // [SCENARIO] Acquire a lease for a container
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Acquire Lease
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);
        LeaseId := BlobServicesAPI.ContainerLeaseAcquire(OperationObject, 60);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Acquire Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreNotEqual(LeaseId, EmptyGuid, StrSubstNo(OperationFailedErr, 'Acquire Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);
        BlobServicesAPI.ContainerLeaseRelease(OperationObject, LeaseId);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Release Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure DeleteContainerWithoutLease(TestContext: Codeunit "Blob Service API Test Context")
    var
        ContainerName: Text;
    begin
        // [SCENARIO] An existing containter is deleted from the Storage Account

        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure DeleteContainerWithLease(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        LeaseId: Guid;
        EmptyGuid: Guid;

    begin
        // [SCENARIO] Delete a leased container
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Acquire Lease
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);
        LeaseId := BlobServicesAPI.ContainerLeaseAcquire(OperationObject, 60);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Acquire Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreNotEqual(LeaseId, EmptyGuid, StrSubstNo(OperationFailedErr, 'Acquire Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName, LeaseId);
    end;

    procedure ListBlobs(TestContext: Codeunit "Blob Service API Test Context")
    var
        ContainerContent: Record "Container Content";

        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        BlobNames: List of [Text];
    begin
        // [SCENARIO] List Blob from a container
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        HelperLibrary.GetListOfBlobNames(BlobNames);
        // [THEN] Upload some BlockBlobs to the Container
        foreach BlobName in BlobNames do
            PutBlockBlobTextImpl(TestContext, ContainerName, BlobName);

        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);
        BlobServicesAPI.ListBlobs(OperationObject, ContainerContent);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'List Blobs', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreEqual(ContainerContent.Count(), BlobNames.Count, 'Number of returned Blobs does not match the ones created.');

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure SetBlobProperties(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
    begin
        // [SCENARIO] Get a blob from a container
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Set blob properties
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        OperationObject.AddOptionalHeader('x-ms-blob-content-type', 'text/plain; charset=UTF-16');
        BlobServicesAPI.SetBlobProperties(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set blob properties', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure GetBlobProperties(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        ReturnValue: Text;
    begin
        // [SCENARIO] Get a blob from a container
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Get blob properties
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.GetBlobProperties(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get blob properties', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        ReturnValue := BlobAPIValueHelper.GetHeaderValueFromResponseHeaders(OperationObject, 'x-ms-blob-type');
        Assert.AreEqual(ReturnValue, 'BlockBlob', 'Return Value not as expected');

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure SetBlobMetadata(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
    begin
        // [SCENARIO] Set blob metadata
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Set blob metadata
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobAPIValueHelper.SetMetadataNameValueHeader(OperationObject, 'Dummy01', 'DummyValue01');
        BlobAPIValueHelper.SetMetadataNameValueHeader(OperationObject, 'Dummy02', 'DummyValue02');
        BlobServicesAPI.SetBlobMetadata(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure GetBlobMetadata(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        ReturnValue: Text;
    begin
        // [SCENARIO] Get blob metadata
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Set blob metadata
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);

        BlobAPIValueHelper.SetMetadataNameValueHeader(OperationObject, 'Dummy01', 'DummyValue01');
        BlobAPIValueHelper.SetMetadataNameValueHeader(OperationObject, 'Dummy02', 'DummyValue02');
        BlobServicesAPI.SetBlobMetadata(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Get blob Metadata
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);

        BlobServicesAPI.GetBlobMetadata(OperationObject);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get blob Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        ReturnValue := BlobAPIValueHelper.GetMetaValueFromResponseHeaders(OperationObject, 'Dummy01');
        Assert.AreEqual(ReturnValue, 'DummyValue01', StrSubstNo(OperationFailedErr, 'Get blob Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        ReturnValue := BlobAPIValueHelper.GetMetaValueFromResponseHeaders(OperationObject, 'Dummy02');
        Assert.AreEqual(ReturnValue, 'DummyValue02', StrSubstNo(OperationFailedErr, 'Get blob Metadata', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure SetBlobTags(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        Tags: Dictionary of [Text, Text];
    begin
        // Does not work in Azurite-emulator

        // [SCENARIO] Set blob tags
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Set blob tags
        Tags.Add('Dummy01', 'DummyValue01');
        Tags.Add('Dummy02', 'DummyValue02');
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);

        BlobServicesAPI.SetBlobTags(OperationObject, Tags);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Tags', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure GetBlobTags(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        Document: XmlDocument;
        Tags: Dictionary of [Text, Text];
    begin
        // Does not work in Azurite-emulator

        // [SCENARIO] Set blob tags
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Set blob tags
        Tags.Add('Dummy01', 'DummyValue01');
        Tags.Add('Dummy02', 'DummyValue02');
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);

        BlobServicesAPI.SetBlobTags(OperationObject, Tags);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Tags', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Get blob tags        
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);

        Document := BlobServicesAPI.GetBlobTags(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get Blob Tags', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreEqual(StrPos(Format(Document), 'DummyValue01') > 0, true, 'Return Value not as expected');
        Assert.AreEqual(StrPos(Format(Document), 'DummyValue02') > 0, true, 'Return Value not as expected');

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure FindBlobsByTags(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        Document: XmlDocument;
        Tags: Dictionary of [Text, Text];
    begin
        // Does not work in Azurite-emulator

        // [SCENARIO] Set blob tags
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] Multiple blobs with tags
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Set blob tags
        Tags.Add('Dummy01', 'DummyValue01');
        Tags.Add('Dummy02', 'DummyValue02');
        Tags.Add('Dummy03', 'DummyValue03');
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);

        BlobServicesAPI.SetBlobTags(OperationObject, Tags);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Tags', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Set blob tags
        Clear(Tags);
        Tags.Add('Dummy01', 'DummyValue01');
        Tags.Add('Dummy02', 'DummyValue02');
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);

        BlobServicesAPI.SetBlobTags(OperationObject, Tags);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Tags', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Set blob tags
        Clear(Tags);
        Tags.Add('Dummy02', 'DummyValue02');
        Tags.Add('Dummy03', 'DummyValue03');
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);

        BlobServicesAPI.SetBlobTags(OperationObject, Tags);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Set Blob Tags', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Find Blobs by Tags
        Clear(Tags);
        Tags.Add('Dummy02', '= DummyValue02');
        Tags.Add('Dummy03', '= DummyValue03');
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);

        Document := BlobServicesAPI.FindBlobsByTags(OperationObject, Tags);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Find Blobs by Tags', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure DeleteBlobWithoutLease(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
    begin
        // [SCENARIO] Set blob tags
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Delete blob
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.DeleteBlob(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Delete Blob', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure DeleteBlobWithLease(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        LeaseId: Guid;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] Set blob tags
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Acquire Lease
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        LeaseId := BlobServicesAPI.BlobLeaseAcquire(OperationObject, 60);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Acquire Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreNotEqual(LeaseId, EmptyGuid, StrSubstNo(OperationFailedErr, 'Acquire Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Delete blob
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobAPIValueHelper.SetLeaseIdHeader(OperationObject, LeaseId);
        BlobServicesAPI.DeleteBlob(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Delete Blob', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure UndeleteBlob(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
    begin
        // Does not work in Azurite-emulator

        // [SCENARIO] Set blob tags
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Delete blob
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.DeleteBlob(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Delete Blob', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Undelete blob
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.UndeleteBlob(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Undelete Blob', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure LeaseBlobAcquireAndRelease(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        LeaseId: Guid;
        EmptyGuid: Guid;
        BlobName: Text;
    begin
        // [SCENARIO] Acquire a lease for a container
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [THEN] Upload a BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Acquire Lease
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        LeaseId := BlobServicesAPI.BlobLeaseAcquire(OperationObject, 60);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Acquire Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreNotEqual(LeaseId, EmptyGuid, StrSubstNo(OperationFailedErr, 'Acquire Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.BlobLeaseRelease(OperationObject, LeaseId);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Release Lease', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure SnapshotBlob(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
    begin
        // [SCENARIO] Snapshot Blob
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Snapshot blob
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.SnapshotBlob(OperationObject);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Snapshot Blob', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure CopyBlob(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        OperationObject2: Codeunit "Blob API Operation Object";
        Operation: Enum "Blob Service API Operation";
        ContainerName: Text;
        ContainerName2: Text;
        BlobName: Text;
        BlobName2: Text;
        SourceName: Text;
    begin
        // [SCENARIO] Copy Blob
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);
        ContainerName2 := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);
        BlobName2 := HelperLibrary.GetBlobName();

        // [THEN] Copy blob        
        // Prepare "source" operation object (for URI generation)
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        OperationObject.SetOperation(Operation::GetBlob);
        SourceName := OperationObject.ConstructUri();

        // Call Copy Blob
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject2, ContainerName2, BlobName2);

        BlobServicesAPI.CopyBlob(OperationObject2, SourceName);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject2), true, StrSubstNo(OperationFailedErr, 'Copy Blob', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject2)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure CopyBlobFromUrl(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        OperationObject2: Codeunit "Blob API Operation Object";
        Operation: Enum "Blob Service API Operation";
        ContainerName: Text;
        ContainerName2: Text;
        BlobName: Text;
        BlobName2: Text;
    begin
        // [SCENARIO] Copy Blob from URL
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);
        ContainerName2 := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);
        BlobName2 := HelperLibrary.GetBlobName();

        // [THEN] Copy blob        
        // Prepare "source" operation object (for URI generation)
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        OperationObject.SetOperation(Operation::GetBlob);

        // Call Copy Blob
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject2, ContainerName2, BlobName2);

        BlobServicesAPI.CopyBlob(OperationObject2, OperationObject.ConstructUri());

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject2), true, StrSubstNo(OperationFailedErr, 'Copy Blob from URL', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject2)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure GetBlobBlockBlobText(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        TargetText: Text;
    begin
        // [SCENARIO] Get a blob from a container
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        // [THEN] Upload BlockBlob to the Container
        BlobName := PutBlockBlobTextImpl(TestContext, ContainerName);

        // [THEN] Get blob from Container
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.GetBlobAsText(OperationObject, TargetText);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get Blob', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreEqual(HelperLibrary.GetSampleTextBlobContent(), TargetText, 'Content is not identical.');

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure PutBlockUncommited(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        BlobContent: Text;
        BlockID: Text;
    begin
        // [SCENARIO] Put Block Uncommited
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        BlobName := HelperLibrary.GetBlobName();

        // [GIVEN] Sample Content
        BlobContent := HelperLibrary.GetSampleTextBlobContent();

        // [GIVEN] A BlockId (Base64-Guid)
        BlockID := BlobAPIValueHelper.GetBase64BlockId();

        // [THEN] Put Block
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.PutBlock(OperationObject, BlobContent);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Block', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure GetBlockList(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        BlobContent: Text;
        BlockID: Text;
        BlockID2: Text;
        BlockListType: Enum "Block List Type";
        CommitedBlocks: Dictionary of [Text, Integer];
        UncommitedBlocks: Dictionary of [Text, Integer];
    begin
        // [SCENARIO] Get Block List
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        BlobName := HelperLibrary.GetBlobName();

        // [GIVEN] Sample Content
        BlobContent := HelperLibrary.GetSampleTextBlobContent();

        // [GIVEN] A BlockId (Base64-Guid)
        BlockID := BlobAPIValueHelper.GetBase64BlockId();
        BlockID2 := BlobAPIValueHelper.GetBase64BlockId();

        // [THEN] Put Block
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.PutBlock(OperationObject, BlobContent, BlockID);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Block', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Put another Block
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.PutBlock(OperationObject, BlobContent, BlockID2);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Block', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Get Block List
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.GetBlockList(OperationObject, BlockListType::all, CommitedBlocks, UncommitedBlocks);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get Block List', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreEqual(UncommitedBlocks.Count(), 2, 'Number of returned Blocks does not match the ones created.');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID), true, 'Return value not as expected');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID2), true, 'Return value not as expected');

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure PutBlockList(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
        BlobName: Text;
        BlobContent: Text;
        BlockID: Text;
        BlockID2: Text;
        BlockListType: Enum "Block List Type";
        CommitedBlocks: Dictionary of [Text, Integer];
        UncommitedBlocks: Dictionary of [Text, Integer];
    begin
        // [SCENARIO] Put Block List
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        BlobName := HelperLibrary.GetBlobName();

        // [GIVEN] Sample Content
        BlobContent := HelperLibrary.GetSampleTextBlobContent();

        // [GIVEN] A BlockId (Base64-Guid)
        BlockID := BlobAPIValueHelper.GetBase64BlockId();
        BlockID2 := BlobAPIValueHelper.GetBase64BlockId();

        // [THEN] Put Block
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.PutBlock(OperationObject, BlobContent, BlockID);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Block', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Put another Block
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.PutBlock(OperationObject, BlobContent, BlockID2);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Block', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Get Block List
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.GetBlockList(OperationObject, BlockListType::all, CommitedBlocks, UncommitedBlocks);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get Block List', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreEqual(UncommitedBlocks.Count(), 2, 'Number of returned Blocks does not match the ones created.');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID), true, 'Return value not as expected');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID2), true, 'Return value not as expected');

        // [THEN] Put Block List
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.PutBlockList(OperationObject, CommitedBlocks, UncommitedBlocks);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Block List', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Get Block List for validation
        Clear(OperationObject);
        Clear(CommitedBlocks);
        Clear(UncommitedBlocks);
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.GetBlockList(OperationObject, BlockListType::all, CommitedBlocks, UncommitedBlocks);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get Block List', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreEqual(CommitedBlocks.Count(), 2, 'Number of returned Blocks does not match the ones created.');
        Assert.AreEqual(UncommitedBlocks.Count(), 0, 'Number of returned Blocks does not match the ones created.');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID), false, 'Return value not as expected');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID2), false, 'Return value not as expected');
        Assert.AreEqual(CommitedBlocks.ContainsKey(BlockID), true, 'Return value not as expected');
        Assert.AreEqual(CommitedBlocks.ContainsKey(BlockID2), true, 'Return value not as expected');

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;

    procedure QueryBlobContents(TestContext: Codeunit "Blob Service API Test Context")
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ApiVersion: Enum "Storage Service API Version";
        ContainerName: Text;
        BlobName: Text;
        BlobContent: Text;
        BlockID: Text;
        BlockID2: Text;
        BlockListType: Enum "Block List Type";
        CommitedBlocks: Dictionary of [Text, Integer];
        UncommitedBlocks: Dictionary of [Text, Integer];
        Result: InStream;
        SearchExpression: Text;
    begin
        // Does not work in Azurite-emulator

        // [SCENARIO] Put Block List
        // [GIVEN] A Storage Account exists
        // [GIVEN] A Container Name
        // [THEN] Create the Container in the Storage Account
        ContainerName := CreateContainerImpl(TestContext);

        // [GIVEN] A Blob Name
        BlobName := HelperLibrary.GetBlobName();

        // [GIVEN] Sample Content
        BlobContent := HelperLibrary.GetSampleTextBlobContent();

        // [GIVEN] A BlockId (Base64-Guid)
        BlockID := BlobAPIValueHelper.GetBase64BlockId();
        BlockID2 := BlobAPIValueHelper.GetBase64BlockId();

        // [THEN] Put Block
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.PutBlock(OperationObject, BlobContent, BlockID);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Block', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Put another Block
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.PutBlock(OperationObject, BlobContent, BlockID2);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Block', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Get Block List
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.GetBlockList(OperationObject, BlockListType::all, CommitedBlocks, UncommitedBlocks);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get Block List', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreEqual(UncommitedBlocks.Count(), 2, 'Number of returned Blocks does not match the ones created.');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID), true, 'Return value not as expected');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID2), true, 'Return value not as expected');

        // [THEN] Put Block List
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.PutBlockList(OperationObject, CommitedBlocks, UncommitedBlocks);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Block List', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Get Block List for validation
        Clear(OperationObject);
        Clear(CommitedBlocks);
        Clear(UncommitedBlocks);
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        BlobServicesAPI.GetBlockList(OperationObject, BlockListType::all, CommitedBlocks, UncommitedBlocks);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Get Block List', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        Assert.AreEqual(CommitedBlocks.Count(), 2, 'Number of returned Blocks does not match the ones created.');
        Assert.AreEqual(UncommitedBlocks.Count(), 0, 'Number of returned Blocks does not match the ones created.');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID), false, 'Return value not as expected');
        Assert.AreEqual(UncommitedBlocks.ContainsKey(BlockID2), false, 'Return value not as expected');
        Assert.AreEqual(CommitedBlocks.ContainsKey(BlockID), true, 'Return value not as expected');
        Assert.AreEqual(CommitedBlocks.ContainsKey(BlockID2), true, 'Return value not as expected');

        // [THEN] Query Blob Contents
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        OperationObject.SetApiVersion(ApiVersion::"2020-02-10");
        SearchExpression := 'SELECT * FROM BlobStorage';
        BlobServicesAPI.QueryBlobContents(OperationObject, SearchExpression, Result);

        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Query Blob Contents', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));

        // [THEN] Cleanup / Delete the Container from the Storage Account
        DeleteContainerImpl(TestContext, ContainerName);
    end;
    // TODO: Check that there is no manual ApiVersion setting in this codeunit

    procedure CreateContainerImpl(TestContext: Codeunit "Blob Service API Test Context"): Text
    var
        OperationObject: Codeunit "Blob API Operation Object";
        ContainerName: Text;
    begin
        // [GIVEN] A Container Name
        ContainerName := HelperLibrary.GetContainerName();

        // [GIVEN] A Storage Account exists
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        // [THEN] Create the Container in the Storage Account
        BlobServicesAPI.CreateContainer(OperationObject);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Create Container', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
        exit(ContainerName);
    end;

    procedure DeleteContainerImpl(TestContext: Codeunit "Blob Service API Test Context"; ContainerName: Text)
    var
        OperationObject: Codeunit "Blob API Operation Object";
    begin
        // [THEN] Cleanup / Delete the Container from the Storage Account
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        BlobServicesAPI.DeleteContainer(OperationObject);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Cleanup / Delete Container', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
    end;

    procedure DeleteContainerImpl(TestContext: Codeunit "Blob Service API Test Context"; ContainerName: Text; LeaseId: Guid)
    var
        OperationObject: Codeunit "Blob API Operation Object";
    begin
        // [THEN] Cleanup / Delete the Container from the Storage Account
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName);

        BlobAPIValueHelper.SetLeaseIdHeader(OperationObject, LeaseId);
        BlobServicesAPI.DeleteContainer(OperationObject);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Cleanup / Delete Container', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
    end;

    procedure PutBlockBlobTextImpl(TestContext: Codeunit "Blob Service API Test Context"; ContainerName: Text): Text
    var
        BlobName: Text;
    begin
        BlobName := HelperLibrary.GetBlobName();
        PutBlockBlobTextImpl(TestContext, ContainerName, BlobName);
        exit(BlobName);
    end;

    procedure PutBlockBlobTextImpl(TestContext: Codeunit "Blob Service API Test Context"; ContainerName: Text; BlobName: Text)
    var
        OperationObject: Codeunit "Blob API Operation Object";
        SampleContent: Text;
    begin
        HelperLibrary.InitializeRequestFromContext(TestContext, OperationObject, ContainerName, BlobName);
        SampleContent := HelperLibrary.GetSampleTextBlobContent();
        BlobServicesAPI.PutBlobBlockBlobText(OperationObject, BlobName, SampleContent);
        Assert.AreEqual(BlobAPIValueHelper.GetHttpResponseIsSuccessStatusCode(OperationObject), true, StrSubstNo(OperationFailedErr, 'Put Blob', BlobAPIValueHelper.GetHttpResponseStatusCode(OperationObject)));
    end;

    var
        BlobServicesAPI: Codeunit "Blob Services API";
        BlobAPIValueHelper: Codeunit "Blob API Value Helper";
        Assert: Codeunit "Library Assert";
        HelperLibrary: Codeunit "Blob Service API Test Help Lib";
        OperationFailedErr: Label 'Operation "%1" failed. Status Code: %2', Comment = '%1 = Operation, %2 = Status Code';
}