codeunit 139732 "APIV1 - Default Dimensions E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Default Dimension]
    end;

    var
        Assert: Codeunit "Assert";
        TypeHelper: Codeunit "Type Helper";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibrarySales: Codeunit "Library - Sales";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryHumanResource: Codeunit "Library - Human Resource";
        CustomerServiceNameTxt: Label 'customers';
        VendorServiceNameTxt: Label 'vendors';
        EmployeeServiceNameTxt: Label 'employees';
        ItemServiceNameTxt: Label 'items';
        DefaultDimensionsServiceNameTxt: Label 'defaultDimensions';
        EmptyResponseErr: Label 'Response should not be empty.';
        BadRequestErr: Label 'BadRequest', Locked = true;
        DimensionIdMismatchErr: Label 'The "dimensionId" and "dimensionValueId" match to different Dimension records.', Locked = true;
        BlockedDimensionErr: Label '%1 %2 is blocked.', Comment = '%1 - Dimension table caption, %2 - Dimension code';
        DimValueBlockedErr: Label '%1 %2 - %3 is blocked.', Comment = '%1 = Dimension Value table caption, %2 = Dim Code, %3 = Dim Value';

    [Test]
    procedure TestCreateDefaultDimensionWithDimensionCodeOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the customer
        // [THEN] The default dimension has been added to the customer
        LibrarySales.CreateCustomer(Customer);
        TestCreateDefaultDimensionWithDimensionCode(DATABASE::Customer, Customer."No.", Customer.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionWithDimensionCodeOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a vendor, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the vendor
        // [THEN] The default dimension has been added to the vendor
        LibraryPurchase.CreateVendor(Vendor);
        TestCreateDefaultDimensionWithDimensionCode(DATABASE::Vendor, Vendor."No.", Vendor.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionWithDimensionCodeOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Item
        // [THEN] The default dimension has been added to the Item
        LibraryInventory.CreateItem(Item);
        TestCreateDefaultDimensionWithDimensionCode(DATABASE::Item, Item."No.", Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestCreateDefaultDimensionWithDimensionCodeOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Employee
        // [THEN] The default dimension has been added to the Employee
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimensionWithDimensionCode(DATABASE::Employee, Employee."No.", Employee.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the customer
        // [THEN] The default dimension has been added to the customer
        LibrarySales.CreateCustomer(Customer);
        TestCreateDefaultDimension(DATABASE::Customer, Customer."No.", Customer.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a Vendor, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Vendor
        // [THEN] The default dimension has been added to the Vendor
        LibraryPurchase.CreateVendor(Vendor);
        TestCreateDefaultDimension(DATABASE::Vendor, Vendor."No.", Vendor.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Item
        // [THEN] The default dimension has been added to the Item
        LibraryInventory.CreateItem(Item);
        TestCreateDefaultDimension(DATABASE::Item, Item."No.", Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestCreateDefaultDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Employee
        // [THEN] The default dimension has been added to the Employee
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimension(DATABASE::Employee, Employee."No.", Employee.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithoutDimensionOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer, a dimension and a dimension value
        // [WHEN] a user issues a http request to create a default dimension without dimension id
        // [THEN] You get an error
        LibrarySales.CreateCustomer(Customer);
        TestCreateDefaultDimensionFailsWithoutDimension(DATABASE::Customer, Customer.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithoutDimensionOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a Vendor, a dimension and a dimension value
        // [WHEN] a user issues a http request to create a default dimension without dimension id
        // [THEN] You get an error
        LibraryPurchase.CreateVendor(Vendor);
        TestCreateDefaultDimensionFailsWithoutDimension(DATABASE::Vendor, Vendor.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithoutDimensionOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item, a dimension and a dimension value
        // [WHEN] a user issues a http request to create a default dimension without dimension id
        // [THEN] You get an error
        LibraryInventory.CreateItem(Item);
        TestCreateDefaultDimensionFailsWithoutDimension(DATABASE::Item, Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestCreateDefaultDimensionFailsWithoutDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] a user issues a http request to create a default dimension without dimension id
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimensionFailsWithoutDimension(DATABASE::Employee, Employee.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithMismatchingDimensionsOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the customer, with mismatching dimesnion and dimension value
        // [THEN] You get an error
        LibrarySales.CreateCustomer(Customer);
        TestCreateDefaultDimensionFailsWithMismatchingDimensions(DATABASE::Customer, Customer.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithMismatchingDimensionsOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a Vendor, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Vendor, with mismatching dimesnion and dimension value
        // [THEN] You get an error
        LibraryPurchase.CreateVendor(Vendor);
        TestCreateDefaultDimensionFailsWithMismatchingDimensions(DATABASE::Vendor, Vendor.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithMismatchingDimensionsOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Item, with mismatching dimesnion and dimension value
        // [THEN] You get an error
        LibraryInventory.CreateItem(Item);
        TestCreateDefaultDimensionFailsWithMismatchingDimensions(DATABASE::Item, Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestCreateDefaultDimensionFailsWithMismatchingDimensionsOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Employee, with mismatching dimesnion and dimension value
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimensionFailsWithMismatchingDimensions(DATABASE::Employee, Employee.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension on the customer
        // [THEN] You get an error
        LibrarySales.CreateCustomer(Customer);
        TestCreateDefaultDimensionFailsWithBlockedDimension(DATABASE::Customer, Customer.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a Vendor, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension on the Vendor
        // [THEN] You get an error
        LibraryPurchase.CreateVendor(Vendor);
        TestCreateDefaultDimensionFailsWithBlockedDimension(DATABASE::Vendor, Vendor.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension on the Item
        // [THEN] You get an error
        LibraryInventory.CreateItem(Item);
        TestCreateDefaultDimensionFailsWithBlockedDimension(DATABASE::Item, Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension on the Employee
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimensionFailsWithBlockedDimension(DATABASE::Employee, Employee.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionValueOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension value on the customer
        // [THEN] You get an error
        LibrarySales.CreateCustomer(Customer);
        TestCreateDefaultDimensionFailsWithBlockedDimensionValue(DATABASE::Customer, Customer.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionValueOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a Vendor, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension value on the Vendor
        // [THEN] You get an error
        LibraryPurchase.CreateVendor(Vendor);
        TestCreateDefaultDimensionFailsWithBlockedDimensionValue(DATABASE::Vendor, Vendor.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionValueOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension value on the Item
        // [THEN] You get an error
        LibraryInventory.CreateItem(Item);
        TestCreateDefaultDimensionFailsWithBlockedDimensionValue(DATABASE::Item, Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionValueOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension value on the Employee
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimensionFailsWithBlockedDimensionValue(DATABASE::Employee, Employee.SystemId);
    end;

    [Test]
    procedure TestDeleteDefaultDimensionOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer with a default dimension
        // [WHEN] The user posts a http request to delete the default dimension on the customer
        // [THEN] The default dimension has been deleted from the customer's default dimensions
        LibrarySales.CreateCustomer(Customer);
        TestDeleteDefaultDimension(DATABASE::Customer, Customer."No.", Customer.SystemId);
    end;

    [Test]
    procedure TestDeleteDefaultDimensionOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a Vendor with a default dimension
        // [WHEN] The user posts a http request to delete a default dimension on the Vendor
        // [THEN] The default dimension has been deleted from the vendor's default dimensions
        LibraryPurchase.CreateVendor(Vendor);
        TestDeleteDefaultDimension(DATABASE::Vendor, Vendor."No.", Vendor.SystemId);
    end;

    [Test]
    procedure TestDeleteDefaultDimensionOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item with a default dimension
        // [WHEN] The user posts a http request to delete a default dimension on the Item
        // [THEN] The default dimension has been deleted from the item's default dimensions
        LibraryInventory.CreateItem(Item);
        TestDeleteDefaultDimension(DATABASE::Item, Item."No.", Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestDeleteDefaultDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee with a default dimension
        // [WHEN] The user posts a http request to delete a default dimension on the Employee
        // [THEN] The default dimension has been deleted from the employee's default dimensions
        LibraryHumanResource.CreateEmployee(Employee);
        TestDeleteDefaultDimension(DATABASE::Employee, Employee."No.", Employee.SystemId);
    end;

    [Test]
    procedure TestGetDefaultDimensionOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer with a default dimension
        // [WHEN] The user posts a http request to get the default dimension on the customer
        // [THEN] The response contains the default dimension that has been added to the customer
        LibrarySales.CreateCustomer(Customer);
        TestGetDefaultDimension(DATABASE::Customer, Customer."No.", Customer.SystemId);
    end;

    [Test]
    procedure TestGetDefaultDimensionOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a Vendor with a default dimension
        // [WHEN] The user posts a http request to get a default dimension on the Vendor
        // [THEN] The response contains the default dimension that has been added to the Vendor
        LibraryPurchase.CreateVendor(Vendor);
        TestGetDefaultDimension(DATABASE::Vendor, Vendor."No.", Vendor.SystemId);
    end;

    [Test]
    procedure TestGetDefaultDimensionOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item with a default dimension
        // [WHEN] The user posts a http request to get a default dimension on the Item
        // [THEN] The response contains the default dimension that has been added to the Item
        LibraryInventory.CreateItem(Item);
        TestGetDefaultDimension(DATABASE::Item, Item."No.", Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestGetDefaultDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee with a default dimension
        // [WHEN] The user posts a http request to get a default dimension on the Employee
        // [THEN] The response contains the default dimension that has been added to the Employee
        LibraryHumanResource.CreateEmployee(Employee);
        TestGetDefaultDimension(DATABASE::Employee, Employee."No.", Employee.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer with a default dimension
        // [WHEN] The user posts a http request to patch the default dimension on the customer
        // [THEN] The default dimension has been updated for the customer
        LibrarySales.CreateCustomer(Customer);
        TestPatchDefaultDimension(DATABASE::Customer, Customer."No.", Customer.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a Vendor with a default dimension
        // [WHEN] The user posts a http request to patch a default dimension on the Vendor
        // [THEN] The default dimension has been updated for the vendor
        LibraryPurchase.CreateVendor(Vendor);
        TestPatchDefaultDimension(DATABASE::Vendor, Vendor."No.", Vendor.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item with a default dimension
        // [WHEN] The user posts a http request to patch a default dimension on the Item
        // [THEN] The default dimension has been updated for the item
        LibraryInventory.CreateItem(Item);
        TestPatchDefaultDimension(DATABASE::Item, Item."No.", Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestPatchDefaultDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee with a default dimension
        // [WHEN] The user posts a http request to patch a default dimension on the Employee
        // [THEN] The default dimension has been updated for the employee
        LibraryHumanResource.CreateEmployee(Employee);
        TestPatchDefaultDimension(DATABASE::Employee, Employee."No.", Employee.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionFailsWithBlockedValueOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer with a default dimension
        // [WHEN] The user posts a http request to patch the default dimension with a blocked dimension value on the customer
        // [THEN] You get an error
        LibrarySales.CreateCustomer(Customer);
        TestPatchDefaultDimensionFailsWithBlockedValue(DATABASE::Customer, Customer."No.", Customer.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionFailsWithBlockedValueOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a Vendor with a default dimension
        // [WHEN] The user posts a http request to patch a default dimension with a blocked dimension value on the Vendor
        // [THEN] You get an error
        LibraryPurchase.CreateVendor(Vendor);
        TestPatchDefaultDimensionFailsWithBlockedValue(DATABASE::Vendor, Vendor."No.", Vendor.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionFailsWithBlockedValueOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a Item with a default dimension
        // [WHEN] The user posts a http request to patch a default dimension with a blocked dimension value on the Item
        // [THEN] You get an error
        LibraryInventory.CreateItem(Item);
        TestPatchDefaultDimensionFailsWithBlockedValue(DATABASE::Item, Item."No.", Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestPatchDefaultDimensionFailsWithBlockedValueOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee with a default dimension
        // [WHEN] The user posts a http request to patch a default dimension with a blocked dimension value on the Employee
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestPatchDefaultDimensionFailsWithBlockedValue(DATABASE::Employee, Employee."No.", Employee.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionFailsWhenChangingDimensionCodeOnCustomer()
    var
        Customer: Record "Customer";
    begin
        // [FEATURE] [Customer]
        // [GIVEN] a customer with a default dimension
        // [WHEN] The user posts a http request to patch the default dimension with a blocked dimension value on the customer
        // [THEN] You get an error
        LibrarySales.CreateCustomer(Customer);
        TestPatchDefaultDimensionFailsWhenChangingDimensionCode(DATABASE::Customer, Customer."No.", Customer.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionFailsWhenChangingDimensionCodeOnVendor()
    var
        Vendor: Record "Vendor";
    begin
        // [FEATURE] [Vendor]
        // [GIVEN] a vendor with a default dimension
        // [WHEN] The user posts a http request to patch the default dimension with a blocked dimension value on the vendor
        // [THEN] You get an error
        LibraryPurchase.CreateVendor(Vendor);
        TestPatchDefaultDimensionFailsWhenChangingDimensionCode(DATABASE::Vendor, Vendor."No.", Vendor.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionFailsWhenChangingDimensionCodeOnItem()
    var
        Item: Record "Item";
    begin
        // [FEATURE] [Item]
        // [GIVEN] a item with a default dimension
        // [WHEN] The user posts a http request to patch the default dimension with a blocked dimension value on the item
        // [THEN] You get an error
        LibraryInventory.CreateItem(Item);
        TestPatchDefaultDimensionFailsWhenChangingDimensionCode(DATABASE::Item, Item."No.", Item.SystemId);
    end;

    // [Test] TODO - Remove when Employee is added
    procedure TestPatchDefaultDimensionFailsWhenChangingDimensionCodeOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a employee with a default dimension
        // [WHEN] The user posts a http request to patch the default dimension with a blocked dimension value on the employee
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestPatchDefaultDimensionFailsWhenChangingDimensionCode(DATABASE::Employee, Employee."No.", Employee.SystemId);
    end;

    local procedure TestCreateDefaultDimensionWithDimensionCode(TableNo: Integer; ParentNo: Code[20]; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        TargetURL: Text;
        DefaultDimensionJSON: Text;
        Response: Text;
        DimensionValueId: Text;
        ParentIdAsText: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionValueId := LOWERCASE(TypeHelper.GetGuidAsString(DimensionValue.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, '', Dimension.Code, DimensionValueId, '', '');
        LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);

        Assert.IsTrue(
          DefaultDimension.GET(TableNo, ParentNo, Dimension.Code), 'Default Dimension not created for the test entity.');
        Assert.AreEqual(
          DefaultDimension."Dimension Value Code", DimensionValue.Code, 'Unexpected default dimension value for the test entity.');
        Assert.AreEqual(DefaultDimension.DimensionId, Dimension.SystemId, 'Unexpected dimension Id value for the test entity.');
    end;

    local procedure TestCreateDefaultDimension(TableNo: Integer; ParentNo: Code[20]; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        TargetURL: Text;
        DefaultDimensionJSON: Text;
        Response: Text;
        ParentIdAsText: Text;
        DimensionId: Text;
        DimensionValueId: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionId := LOWERCASE(TypeHelper.GetGuidAsString(Dimension.SystemId));
        DimensionValueId := LOWERCASE(TypeHelper.GetGuidAsString(DimensionValue.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, DimensionId, '', DimensionValueId, '', '');
        LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);

        Assert.IsTrue(
          DefaultDimension.GET(TableNo, ParentNo, Dimension.Code), 'Default Dimension not created for the test entity.');
        Assert.AreEqual(
          DefaultDimension."Dimension Value Code", DimensionValue.Code, 'Unexpected default dimension value for the test entity.');
    end;

    local procedure TestCreateDefaultDimensionFailsWithoutDimension(TableNo: Integer; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        TargetURL: Text;
        DefaultDimensionJSON: Text;
        Response: Text;
        ParentIdAsText: Text;
        DimensionValueId: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionValueId := LOWERCASE(TypeHelper.GetGuidAsString(DimensionValue.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, '', '', DimensionValueId, '', '');

        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);
        Assert.ExpectedError(BadRequestErr);
    end;

    local procedure TestCreateDefaultDimensionFailsWithMismatchingDimensions(TableNo: Integer; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        Dimension2: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        DimensionValue2: Record "Dimension Value";
        TargetURL: Text;
        DefaultDimensionJSON: Text;
        Response: Text;
        ParentIdAsText: Text;
        DimensionId: Text;
        DimensionValue2Id: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LibraryDimension.CreateDimension(Dimension2);
        LibraryDimension.CreateDimensionValue(DimensionValue2, Dimension2.Code);
        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionId := LOWERCASE(TypeHelper.GetGuidAsString(Dimension.SystemId));
        DimensionValue2Id := LOWERCASE(TypeHelper.GetGuidAsString(DimensionValue2.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, DimensionId, '', DimensionValue2Id, '', '');

        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);
        Assert.ExpectedError(DimensionIdMismatchErr);
    end;

    local procedure TestCreateDefaultDimensionFailsWithBlockedDimension(TableNo: Integer; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        TargetURL: Text;
        DefaultDimensionJSON: Text;
        Response: Text;
        ParentIdAsText: Text;
        DimensionId: Text;
        DimensionValueId: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        Dimension.VALIDATE(Blocked, TRUE);
        Dimension.MODIFY(TRUE);
        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionId := LOWERCASE(TypeHelper.GetGuidAsString(Dimension.SystemId));
        DimensionValueId := LOWERCASE(TypeHelper.GetGuidAsString(DimensionValue.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, DimensionId, '', DimensionValueId, '', '');

        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);
        Assert.ExpectedError(STRSUBSTNO(BlockedDimensionErr, Dimension.TABLECAPTION(), Dimension.Code));
    end;

    local procedure TestCreateDefaultDimensionFailsWithBlockedDimensionValue(TableNo: Integer; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        TargetURL: Text;
        DefaultDimensionJSON: Text;
        Response: Text;
        ParentIdAsText: Text;
        DimensionId: Text;
        DimensionValueId: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValue.VALIDATE(Blocked, TRUE);
        DimensionValue.MODIFY(TRUE);
        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionId := LOWERCASE(TypeHelper.GetGuidAsString(Dimension.SystemId));
        DimensionValueId := LOWERCASE(TypeHelper.GetGuidAsString(DimensionValue.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, DimensionId, '', DimensionValueId, '', '');

        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);
        Assert.ExpectedError(STRSUBSTNO(DimValueBlockedErr, DimensionValue.TABLECAPTION(), Dimension.Code, DimensionValue.Code));
    end;

    local procedure TestDeleteDefaultDimension(TableNo: Integer; ParentNo: Code[20]; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        TargetURL: Text;
        Response: Text;
        SubpageWithIdTxt: Text;
        ParentIdAsText: Text;
        DimensionId: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DefaultDimension.VALIDATE("Table ID", TableNo);
        DefaultDimension.VALIDATE("No.", ParentNo);
        DefaultDimension.VALIDATE("Dimension Code", Dimension.Code);
        DefaultDimension.VALIDATE("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.INSERT(TRUE);

        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionId := LOWERCASE(TypeHelper.GetGuidAsString(Dimension.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + STRSUBSTNO('(%1,%2)', ParentIdAsText, DimensionId);
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        DefaultDimension.SetRange("Table ID", TableNo);
        DefaultDimension.SetRange("No.", ParentNo);
        DefaultDimension.SetRange("Dimension Code", Dimension.Code);
        Assert.IsTrue(DefaultDimension.IsEmpty(), 'Default dimension was not deleted.');
    end;

    local procedure TestGetDefaultDimension(TableNo: Integer; ParentNo: Code[20]; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        TargetURL: Text;
        Response: Text;
        SubpageWithIdTxt: Text;
        ParentIdAsText: Text;
        DimensionId: Text;
        DimensionValueId: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DefaultDimension.VALIDATE("Table ID", TableNo);
        DefaultDimension.VALIDATE("No.", ParentNo);
        DefaultDimension.VALIDATE("Dimension Code", Dimension.Code);
        DefaultDimension.VALIDATE("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.INSERT(TRUE);

        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionId := LOWERCASE(TypeHelper.GetGuidAsString(Dimension.SystemId));
        DimensionValueId := LOWERCASE(TypeHelper.GetGuidAsString(DimensionValue.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + STRSUBSTNO('(%1,%2)', ParentIdAsText, DimensionId);
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        VerifyDefaultDimensionResponseBody(Response, ParentIdAsText, DimensionId, '', DimensionValueId, '', '');
    end;

    local procedure TestPatchDefaultDimension(TableNo: Integer; ParentNo: Code[20]; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        DimensionValue2: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        TargetURL: Text;
        DefaultDimensionJSON: Text;
        Response: Text;
        SubpageWithIdTxt: Text;
        ParentIdAsText: Text;
        DimensionId: Text;
        DimensionValue2Id: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LibraryDimension.CreateDimensionValue(DimensionValue2, Dimension.Code);
        DefaultDimension.VALIDATE("Table ID", TableNo);
        DefaultDimension.VALIDATE("No.", ParentNo);
        DefaultDimension.VALIDATE("Dimension Code", Dimension.Code);
        DefaultDimension.VALIDATE("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.INSERT(TRUE);

        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionId := LOWERCASE(TypeHelper.GetGuidAsString(Dimension.SystemId));
        DimensionValue2Id := LOWERCASE(TypeHelper.GetGuidAsString(DimensionValue2.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + STRSUBSTNO('(%1,%2)', ParentIdAsText, DimensionId);
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody('', '', '', DimensionValue2Id, '', 'Same Code');
        LibraryGraphMgt.PatchToWebService(TargetURL, DefaultDimensionJSON, Response);

        DefaultDimension.GET(TableNo, ParentNo, Dimension.Code);
        Assert.AreEqual(DefaultDimension."Dimension Value Code", DimensionValue2.Code, '');
        Assert.AreEqual(DefaultDimension."Value Posting", DefaultDimension."Value Posting"::"Same Code", '');
    end;

    local procedure TestPatchDefaultDimensionFailsWithBlockedValue(TableNo: Integer; ParentNo: Code[20]; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        DimensionValue2: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        TargetURL: Text;
        DefaultDimensionJSON: Text;
        Response: Text;
        SubpageWithIdTxt: Text;
        ParentIdAsText: Text;
        DimensionId: Text;
        DimensionValue2Id: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LibraryDimension.CreateDimensionValue(DimensionValue2, Dimension.Code);
        DimensionValue2.VALIDATE(Blocked, TRUE);
        DimensionValue2.MODIFY(TRUE);
        DefaultDimension.VALIDATE("Table ID", TableNo);
        DefaultDimension.VALIDATE("No.", ParentNo);
        DefaultDimension.VALIDATE("Dimension Code", Dimension.Code);
        DefaultDimension.VALIDATE("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.INSERT(TRUE);

        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionId := LOWERCASE(TypeHelper.GetGuidAsString(Dimension.SystemId));
        DimensionValue2Id := LOWERCASE(TypeHelper.GetGuidAsString(DimensionValue2.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + STRSUBSTNO('(%1,%2)', ParentIdAsText, DimensionId);
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody('', '', '', DimensionValue2Id, '', 'Same Code');

        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, DefaultDimensionJSON, Response);
        Assert.ExpectedError(STRSUBSTNO(DimValueBlockedErr, DimensionValue.TABLECAPTION(), Dimension.Code, DimensionValue2.Code));
    end;

    local procedure TestPatchDefaultDimensionFailsWhenChangingDimensionCode(TableNo: Integer; ParentNo: Code[20]; ParentId: Guid)
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        Dimension2: Record "Dimension";
        DefaultDimension: Record "Default Dimension";
        TargetURL: Text;
        DefaultDimensionJSON: Text;
        Response: Text;
        SubpageWithIdTxt: Text;
        ParentIdAsText: Text;
        DimensionId: Text;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimension(Dimension2);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DefaultDimension.VALIDATE("Table ID", TableNo);
        DefaultDimension.VALIDATE("No.", ParentNo);
        DefaultDimension.VALIDATE("Dimension Code", Dimension.Code);
        DefaultDimension.VALIDATE("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.INSERT(TRUE);

        ParentIdAsText := LOWERCASE(TypeHelper.GetGuidAsString(ParentId));
        DimensionId := LOWERCASE(TypeHelper.GetGuidAsString(Dimension.SystemId));
        COMMIT();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + STRSUBSTNO('(%1,%2)', ParentIdAsText, DimensionId);
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody('', '', Dimension2.Code, '', '', '');

        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, DefaultDimensionJSON, Response);
    end;

    local procedure CreateDefaultDimensionRequestBody(ParentId: Text; DimensionId: Text; DimensionCode: Text; DimensionValueId: Text; DimensionValueCode: Text; ValuePosting: Text): Text
    var
        DefaultDimensionJSON: Text;
    begin
        IF ParentId <> '' THEN
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'parentId', ParentId);
        IF DimensionId <> '' THEN
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'dimensionId', DimensionId);
        IF DimensionCode <> '' THEN
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'dimensionCode', DimensionCode);
        IF DimensionValueId <> '' THEN
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'dimensionValueId', DimensionValueId);
        IF DimensionValueCode <> '' THEN
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'dimensionValueCode', DimensionValueCode);
        IF ValuePosting <> '' THEN
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'postingValidation', ValuePosting);
        EXIT(DefaultDimensionJSON)
    end;

    local procedure VerifyDefaultDimensionResponseBody(Response: Text; ParentId: Text; DimensionId: Text; DimensionCode: Text; DimensionValueId: Text; DimensionValueCode: Text; ValuePosting: Text)
    var
    begin
        Assert.AreNotEqual('', Response, EmptyResponseErr);
        IF ParentId <> '' THEN
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'parentId', ParentId);
        IF DimensionId <> '' THEN
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'dimensionId', DimensionId);
        IF DimensionCode <> '' THEN
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'dimensionCode', DimensionCode);
        IF DimensionValueId <> '' THEN
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'dimensionValueId', DimensionValueId);
        IF DimensionValueCode <> '' THEN
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'dimensionValueCode', DimensionValueCode);
        IF ValuePosting <> '' THEN
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'postingValidation', ValuePosting);
    end;

    local procedure GetEntityPageNo(TableNo: Integer): Integer
    begin
        CASE TableNo OF
            DATABASE::Customer:
                EXIT(PAGE::"APIV1 - Customers");
            DATABASE::Vendor:
                EXIT(PAGE::"APIV1 - Vendors");
            DATABASE::Item:
                EXIT(PAGE::"APIV1 - Items");
            DATABASE::Employee:
                EXIT(PAGE::"APIV1 - Employees");
        END;
        EXIT(-1);
    end;

    local procedure GetServiceName(TableNo: Integer): Text
    begin
        CASE TableNo OF
            DATABASE::Customer:
                EXIT(CustomerServiceNameTxt);
            DATABASE::Vendor:
                EXIT(VendorServiceNameTxt);
            DATABASE::Item:
                EXIT(ItemServiceNameTxt);
            DATABASE::Employee:
                EXIT(EmployeeServiceNameTxt);
        END;
        EXIT('');
    end;
}

























































































