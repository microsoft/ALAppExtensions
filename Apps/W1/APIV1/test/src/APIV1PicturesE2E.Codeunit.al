codeunit 139742 "APIV1 - Pictures E2E"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Image]
    end;

    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryHumanResource: Codeunit "Library - Human Resource";
        LibraryInventory: Codeunit "Library - Inventory";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        EmployeeAPINameTxt: Label 'employees';
        VendorAPINameTxt: Label 'vendors';
        CustomerAPINameTxt: Label 'customers';
        PictureAPINameTxt: Label 'picture';
        ItemAPINameTxt: Label 'items';

    [Normal]
    [Scope('OnPrem')]
    procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureValueCustomer()
    var
        Customer: Record Customer;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO] Get value picture from Customer Record

        // [GIVEN] a customer with image attached
        CreateTestCustomerWithImage(Customer, TempBlobExpected);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureValueURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId);
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);

        // [THEN] An image is returned that matches original image
        ValidateImageValue(TempBlobExpected, TempBlobResponse);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureMetadataCustomer()
    var
        Customer: Record Customer;
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO] Get a picture metadata from Customer Record

        // [GIVEN] a customer with image attached
        CreateTestCustomerWithImage(Customer, TempBlobExpected);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureSubPageURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);

        // [THEN] Image metadata matches the information of the image
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureValueCustomerWithoutPicture()
    var
        Customer: Record Customer;
        TempBlobResponse: Codeunit "Temp Blob";
        TargetURL: Text;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO] Get value picture from Customer Record when no image exist

        // [GIVEN] a customer without image
        LibrarySales.CreateCustomer(Customer);
        Commit();

        // [WHEN] A request for the image is executed
        // [THEN] 204 - No body is returned
        TargetURL := GeneratePictureValueURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId);
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 204);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureMetadataCustomerWithoutPicture()
    var
        Customer: Record Customer;
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO] Get a picture metadata from Customer Record when no image is present

        // [GIVEN] a customer with image attached
        LibrarySales.CreateCustomer(Customer);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureSubPageURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);

        // [THEN] Image metadata matches the information of the image
        ValidateNoImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureUploadCustomer()
    var
        Customer: Record Customer;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO] Set Picture on a customer without picture

        // [GIVEN] a customer with image attached
        LibrarySales.CreateCustomer(Customer);
        GetRedImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to patch the image is executed
        TargetURL := GeneratePictureValueURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId);
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlobExpected, 'PATCH', Response, 204);

        // [THEN] An image is returned that matches original image and metadata is updated
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);
        ValidateImageValue(TempBlobExpected, TempBlobResponse);

        TargetURL := GeneratePictureSubPageURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureReplaceCustomer()
    var
        Customer: Record Customer;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobOriginal: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO] Replace the Picture on a customer

        // [GIVEN] a customer with image attached
        CreateTestCustomerWithImage(Customer, TempBlobOriginal);
        GetBlueImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to replace the image is executed
        TargetURL := GeneratePictureValueURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId);
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlobExpected, 'PATCH', Response, 204);

        // [THEN] An image is returned that matches new and metadata is updated
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);
        ValidateImageValue(TempBlobExpected, TempBlobResponse);

        TargetURL := GeneratePictureSubPageURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureDeleteCustomer()
    var
        Customer: Record Customer;
        TempBlobOriginal: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO] Replace the Picture on a customer

        // [GIVEN] a customer with image attached
        CreateTestCustomerWithImage(Customer, TempBlobOriginal);
        GetBlueImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to delete the image is executed
        TargetURL := GeneratePictureSubPageURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId, Customer.SystemId);
        LibraryGraphMgt.DeleteFromWebServiceAndCheckResponseCode(TargetURL, '', Response, 204);

        // [THEN] An image is deleted and metadata is updated
        TargetURL := GeneratePictureSubPageURL(CustomerAPINameTxt, PAGE::"APIV1 - Customers", Customer.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateNoImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureValueVendor()
    var
        Vendor: Record Vendor;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO] Get value picture from Vendor Record

        // [GIVEN] a Vendor with image attached
        CreateTestVendorWithImage(Vendor, TempBlobExpected);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureValueURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId);
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);

        // [THEN] An image is returned that matches original image
        ValidateImageValue(TempBlobExpected, TempBlobResponse);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureMetadataVendor()
    var
        Vendor: Record Vendor;
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO] Get a picture metadata from Vendor Record

        // [GIVEN] a Vendor with image attached
        CreateTestVendorWithImage(Vendor, TempBlobExpected);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureSubPageURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);

        // [THEN] Image metadata matches the information of the image
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureValueVendorWithoutPicture()
    var
        Vendor: Record Vendor;
        TempBlobResponse: Codeunit "Temp Blob";
        TargetURL: Text;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO] Get value picture from Vendor Record when no image exist

        // [GIVEN] a Vendor without image
        LibraryPurchase.CreateVendor(Vendor);
        Commit();

        // [WHEN] A request for the image is executed
        // [THEN] 204 - No body is returned
        TargetURL := GeneratePictureValueURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId);
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 204);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureMetadataVendorWithoutPicture()
    var
        Vendor: Record Vendor;
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO] Get a picture metadata from Vendor Record when no image is present

        // [GIVEN] a Vendor with image attached
        LibraryPurchase.CreateVendor(Vendor);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureSubPageURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);

        // [THEN] Image metadata matches the information of the image
        ValidateNoImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureUploadVendor()
    var
        Vendor: Record Vendor;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO] Set Picture on a Vendor without picture

        // [GIVEN] a Vendor with image attached
        LibraryPurchase.CreateVendor(Vendor);
        GetRedImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to patch the image is executed
        TargetURL := GeneratePictureValueURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId);
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlobExpected, 'PATCH', Response, 204);

        // [THEN] An image is returned that matches original image and metadata is updated
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);
        ValidateImageValue(TempBlobExpected, TempBlobResponse);

        TargetURL := GeneratePictureSubPageURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureReplaceVendor()
    var
        Vendor: Record Vendor;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobOriginal: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO] Replace the Picture on a Vendor

        // [GIVEN] a Vendor with image attached
        CreateTestVendorWithImage(Vendor, TempBlobOriginal);
        GetBlueImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to replace the image is executed
        TargetURL := GeneratePictureValueURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId);
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlobExpected, 'PATCH', Response, 204);

        // [THEN] An image is returned that matches new and metadata is updated
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);
        ValidateImageValue(TempBlobExpected, TempBlobResponse);

        TargetURL := GeneratePictureSubPageURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureDeleteVendor()
    var
        Vendor: Record Vendor;
        TempBlobOriginal: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO] Replace the Picture on a Vendor

        // [GIVEN] a Vendor with image attached
        CreateTestVendorWithImage(Vendor, TempBlobOriginal);
        GetBlueImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to delete the image is executed
        TargetURL := GeneratePictureSubPageURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId, Vendor.SystemId);
        LibraryGraphMgt.DeleteFromWebServiceAndCheckResponseCode(TargetURL, '', Response, 204);

        // [THEN] An image is deleted and metadata is updated
        TargetURL := GeneratePictureSubPageURL(VendorAPINameTxt, PAGE::"APIV1 - Vendors", Vendor.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateNoImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureValueEmployee()
    var
        Employee: Record Employee;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
    begin
        // [FEATURE] [Employee]
        // [SCENARIO] Get value picture from Employee Record

        // [GIVEN] an Employee with image attached
        CreateTestEmployeeWithImage(Employee, TempBlobExpected);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureValueURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId);
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);

        // [THEN] An image is returned that matches original image
        ValidateImageValue(TempBlobExpected, TempBlobResponse);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureMetadataEmployee()
    var
        Employee: Record Employee;
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Employee]
        // [SCENARIO] Get a picture metadata from Employee Record

        // [GIVEN] a Employee with image attached
        CreateTestEmployeeWithImage(Employee, TempBlobExpected);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureSubPageURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);

        // [THEN] Image metadata matches the information of the image
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureValueEmployeeWithoutPicture()
    var
        Employee: Record Employee;
        TempBlobResponse: Codeunit "Temp Blob";
        TargetURL: Text;
    begin
        // [FEATURE] [Employee]
        // [SCENARIO] Get value picture from Employee Record when no image exist

        // [GIVEN] a Employee without image
        LibraryHumanResource.CreateEmployee(Employee);
        Commit();

        // [WHEN] A request for the image is executed
        // [THEN] 204 - No body is returned
        TargetURL := GeneratePictureValueURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId);
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 204);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureMetadataEmployeeWithoutPicture()
    var
        Employee: Record Employee;
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Employee]
        // [SCENARIO] Get a picture metadata from Employee Record when no image is present

        // [GIVEN] a Employee with image attached
        LibraryHumanResource.CreateEmployee(Employee);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureSubPageURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);

        // [THEN] Image metadata matches the information of the image
        ValidateNoImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureUploadEmployee()
    var
        Employee: Record Employee;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Employee]
        // [SCENARIO] Set Picture on a Employee without picture

        // [GIVEN] a Employee with image attached
        LibraryHumanResource.CreateEmployee(Employee);
        GetRedImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to patch the image is executed
        TargetURL := GeneratePictureValueURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId);
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlobExpected, 'PATCH', Response, 204);

        // [THEN] An image is returned that matches original image and metadata is updated
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);
        ValidateImageValue(TempBlobExpected, TempBlobResponse);

        TargetURL := GeneratePictureSubPageURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureReplaceEmployee()
    var
        Employee: Record Employee;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobOriginal: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Employee]
        // [SCENARIO] Replace the Picture on a Employee

        // [GIVEN] a Employee with image attached
        CreateTestEmployeeWithImage(Employee, TempBlobOriginal);
        GetBlueImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to replace the image is executed
        TargetURL := GeneratePictureValueURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId);
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlobExpected, 'PATCH', Response, 204);

        // [THEN] An image is returned that matches new and metadata is updated
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);
        ValidateImageValue(TempBlobExpected, TempBlobResponse);

        TargetURL := GeneratePictureSubPageURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureDeleteEmployee()
    var
        Employee: Record Employee;
        TempBlobOriginal: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Employee]
        // [SCENARIO] Replace the Picture on a Employee

        // [GIVEN] a Employee with image attached
        CreateTestEmployeeWithImage(Employee, TempBlobOriginal);
        GetBlueImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to delete the image is executed
        TargetURL := GeneratePictureSubPageURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId, Employee.SystemId);
        LibraryGraphMgt.DeleteFromWebServiceAndCheckResponseCode(TargetURL, '', Response, 204);

        // [THEN] An image is deleted and metadata is updated
        TargetURL := GeneratePictureSubPageURL(EmployeeAPINameTxt, PAGE::"APIV1 - Employees", Employee.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateNoImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureValueItem()
    var
        Item: Record Item;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
    begin
        // [FEATURE] [Item]
        // [SCENARIO] Get value picture from Item Record

        // [GIVEN] a Item with image attached
        CreateTestItemWithImage(Item, TempBlobExpected);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureValueURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId);
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);

        // [THEN] An image is returned that matches original image
        ValidateImageValue(TempBlobExpected, TempBlobResponse);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureMetadataItem()
    var
        Item: Record Item;
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Item]
        // [SCENARIO] Get a picture metadata from Item Record

        // [GIVEN] a Item with image attached
        CreateTestItemWithImage(Item, TempBlobExpected);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureSubPageURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);

        // [THEN] Image metadata matches the information of the image
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureValueItemWithoutPicture()
    var
        Item: Record Item;
        TempBlobResponse: Codeunit "Temp Blob";
        TargetURL: Text;
    begin
        // [FEATURE] [Item]
        // [SCENARIO] Get value picture from Item Record when no image exist

        // [GIVEN] a Item without image
        LibraryInventory.CreateItem(Item);
        Commit();

        // [WHEN] A request for the image is executed
        // [THEN] 204 - No body is returned
        TargetURL := GeneratePictureValueURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId);
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 204);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetPictureMetadatItemWithoutPicture()
    var
        Item: Record Item;
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Item]
        // [SCENARIO] Get a picture metadata from Item Record when no image is present

        // [GIVEN] a Item with image attached
        LibraryInventory.CreateItem(Item);
        Commit();

        // [WHEN] A request for the image is executed
        TargetURL := GeneratePictureSubPageURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);

        // [THEN] Image metadata matches the information of the image
        ValidateNoImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureUploadItem()
    var
        Item: Record Item;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Item]
        // [SCENARIO] Set Picture on a Item without picture

        // [GIVEN] a Item with image attached
        LibraryInventory.CreateItem(Item);
        GetRedImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to patch the image is executed
        TargetURL := GeneratePictureValueURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId);
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlobExpected, 'PATCH', Response, 204);

        // [THEN] An image is returned that matches original image and metadata is updated
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);
        ValidateImageValue(TempBlobExpected, TempBlobResponse);

        TargetURL := GeneratePictureSubPageURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureReplaceItem()
    var
        Item: Record Item;
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobOriginal: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Item]
        // [SCENARIO] Replace the Picture on a Item

        // [GIVEN] a Item with image attached
        CreateTestItemWithImage(Item, TempBlobOriginal);
        GetBlueImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to replace the image is executed
        TargetURL := GeneratePictureValueURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId);
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlobExpected, 'PATCH', Response, 204);

        // [THEN] An image is returned that matches new and metadata is updated
        LibraryGraphMgt.GetBinaryFromWebServiceAndCheckResponseCode(TempBlobResponse, TargetURL, 'application/octet-stream', 200);
        ValidateImageValue(TempBlobExpected, TempBlobResponse);

        TargetURL := GeneratePictureSubPageURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateImageMetadata(Response);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPictureDeleteItem()
    var
        Item: Record Item;
        TempBlobOriginal: Codeunit "Temp Blob";
        TempBlobExpected: Codeunit "Temp Blob";
        TargetURL: Text;
        Response: Text;
    begin
        // [FEATURE] [Item]
        // [SCENARIO] Replace the Picture on a Item

        // [GIVEN] a Item with image attached
        CreateTestItemWithImage(Item, TempBlobOriginal);
        GetBlueImageTempBlob(TempBlobExpected);
        Commit();

        // [WHEN] A request to delete the image is executed
        TargetURL := GeneratePictureSubPageURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId, Item.SystemId);
        LibraryGraphMgt.DeleteFromWebServiceAndCheckResponseCode(TargetURL, '', Response, 204);

        // [THEN] An image is deleted and metadata is updated
        TargetURL := GeneratePictureSubPageURL(ItemAPINameTxt, PAGE::"APIV1 - Items", Item.SystemId, '');
        LibraryGraphMgt.GetFromWebServiceAndCheckResponseCode(Response, TargetURL, 200);
        ValidateNoImageMetadata(Response);
    end;

    local procedure CreateTestItemWithImage(var Item: Record Item; var TempBlob: Codeunit "Temp Blob")
    var
        ImageInStream: InStream;
    begin
        LibraryInventory.CreateItem(Item);
        GetRedImageTempBlob(TempBlob);
        TempBlob.CreateInStream(ImageInStream);
        Item.Picture.ImportStream(ImageInStream, Item."No." + '.jpg');
        Item.Modify(true);
    end;

    local procedure CreateTestVendorWithImage(var Vendor: Record Vendor; var TempBlob: Codeunit "Temp Blob")
    var
        ImageInStream: InStream;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        GetRedImageTempBlob(TempBlob);
        TempBlob.CreateInStream(ImageInStream);
        Vendor.Image.ImportStream(ImageInStream, Vendor."No." + '.jpg');
        Vendor.Modify(true);
    end;

    local procedure CreateTestEmployeeWithImage(var Employee: Record Employee; var TempBlob: Codeunit "Temp Blob")
    var
        ImageInStream: InStream;
    begin
        LibraryHumanResource.CreateEmployee(Employee);
        GetRedImageTempBlob(TempBlob);
        TempBlob.CreateInStream(ImageInStream);
        Employee.Image.ImportStream(ImageInStream, Employee."No." + '.jpg');
        Employee.Modify(true);
    end;

    local procedure CreateTestCustomerWithImage(var Customer: Record Customer; var TempBlob: Codeunit "Temp Blob")
    var
        ImageInStream: InStream;
    begin
        LibrarySales.CreateCustomer(Customer);
        GetRedImageTempBlob(TempBlob);
        TempBlob.CreateInStream(ImageInStream);
        Customer.Image.ImportStream(ImageInStream, Customer."No." + '.jpg');
        Customer.Modify(true);
    end;

    local procedure GetRedImageTempBlob(var TempBlob: Codeunit "Temp Blob")
    var
        Base64Convert: Codeunit "Base64 Convert";
        OutStream: OutStream;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        Base64Convert.FromBase64(GetImageRedBase64Text(), OutStream);
    end;

    local procedure GetBlueImageTempBlob(var TempBlob: Codeunit "Temp Blob")
    var
        Base64Convert: Codeunit "Base64 Convert";
        OutStream: OutStream;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        Base64Convert.FromBase64(GetImageBlueBase64Text(), OutStream);
    end;

    local procedure GetImageRedBase64Text(): Text
    begin
        exit(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwgAADsIBFShKgAAAAAxJREFUGFdjeCujAgADJwEuFWu+6QAAAABJRU5ErkJggg==');
    end;

    local procedure GetImageBlueBase64Text(): Text
    begin
        exit(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwgAADsIBFShKgAAAAAxJREFUGFdjsPc4AwACHQFUQMUSiAAAAABJRU5ErkJggg==');
    end;

    local procedure GeneratePictureSubPageURL(APIName: Text; APIPageNumber: Integer; ID: Text; SubPageID: Text): Text
    var
        TargetURL: Text;
    begin
        Assert.IsFalse(IsNullGuid(ID), 'ID must not be blank');
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(ID, APIPageNumber, APIName, PictureAPINameTxt);
        if SubPageID <> '' then
            if not IsNullGuid(SubPageID) then
                TargetURL := LibraryGraphMgt.AppendSubpageToTargetURL(SubPageID, TargetURL, PictureAPINameTxt, '');

        exit(TargetURL);
    end;

    local procedure GeneratePictureValueURL(APIName: Text; APIPageNumber: Integer; ID: Text): Text
    var
        TargetURL: Text;
    begin
        TargetURL := GeneratePictureSubPageURL(APIName, APIPageNumber, ID, '');
        TargetURL := LibraryGraphMgt.AppendSubpageToTargetURL(ID, TargetURL, PictureAPINameTxt, 'content');
        exit(TargetURL);
    end;

    [Normal]
    local procedure ValidateImageMetadata(Response: Text)
    var
        MetaDataJSON: Variant;
        Height: Text;
        Width: Text;
    begin
        LibraryGraphMgt.GetObjectFromJSONResponseByName(Response, 'value', MetaDataJSON, 1);
        LibraryGraphMgt.GetObjectIDFromJSON(MetaDataJSON, 'height', Height);
        LibraryGraphMgt.GetObjectIDFromJSON(MetaDataJSON, 'width', Width);

        Assert.AreEqual('1', Height, 'Height was not set to correct value');
        Assert.AreEqual('1', Width, 'Height was not set to correct value');
    end;

    [Normal]
    local procedure ValidateNoImageMetadata(Response: Text)
    var
        MetaDataJSON: Variant;
        Height: Text;
        Width: Text;
    begin
        LibraryGraphMgt.GetObjectFromJSONResponseByName(Response, 'value', MetaDataJSON, 1);
        LibraryGraphMgt.GetObjectIDFromJSON(MetaDataJSON, 'height', Height);
        LibraryGraphMgt.GetObjectIDFromJSON(MetaDataJSON, 'width', Width);

        Assert.AreEqual('0', Height, 'Height was not set to correct value');
        Assert.AreEqual('0', Width, 'Height was not set to correct value');
    end;

    local procedure ValidateImageValue(TempBlobExpected: Codeunit "Temp Blob"; TempBlobResponse: Codeunit "Temp Blob")
    var
        Customer: Record Customer;
        Base64Convert: Codeunit "Base64 Convert";
        ImageInStream: InStream;
        ImageOutStream: OutStream;
        ExpectedInStream: InStream;
    begin
        TempBlobExpected.CreateInStream(ImageInStream);
        Customer.Init();
        Customer.Image.ImportStream(ImageInStream, '');
        TempBlobExpected.CreateOutStream(ImageOutStream);
        Customer.Image.ExportStream(ImageOutStream);

        TempBlobResponse.CreateInStream(ExpectedInStream);
        Assert.AreEqual(
          Base64Convert.ToBase64(ImageInStream), Base64Convert.ToBase64(ExpectedInStream),
          'Recieved image is not the same as uploaded image');
    end;
}

