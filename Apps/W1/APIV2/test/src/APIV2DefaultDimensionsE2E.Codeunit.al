codeunit 139832 "APIV2 - Default Dimensions E2E"
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
        TestCreateDefaultDimensionWithDimensionCode(Database::Customer, Customer."No.", Customer.SystemId);
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
        TestCreateDefaultDimensionWithDimensionCode(Database::Vendor, Vendor."No.", Vendor.SystemId);
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
        TestCreateDefaultDimensionWithDimensionCode(Database::Item, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionWithDimensionCodeOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Employee
        // [THEN] The default dimension has been added to the Employee
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimensionWithDimensionCode(Database::Employee, Employee."No.", Employee.SystemId);
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
        TestCreateDefaultDimension(Database::Customer, Customer."No.", Customer.SystemId);
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
        TestCreateDefaultDimension(Database::Vendor, Vendor."No.", Vendor.SystemId);
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
        TestCreateDefaultDimension(Database::Item, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Employee
        // [THEN] The default dimension has been added to the Employee
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimension(Database::Employee, Employee."No.", Employee.SystemId);
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
        TestCreateDefaultDimensionFailsWithMismatchingDimensions(Database::Customer, Customer.SystemId);
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
        TestCreateDefaultDimensionFailsWithMismatchingDimensions(Database::Vendor, Vendor.SystemId);
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
        TestCreateDefaultDimensionFailsWithMismatchingDimensions(Database::Item, Item.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithMismatchingDimensionsOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension on the Employee, with mismatching dimesnion and dimension value
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimensionFailsWithMismatchingDimensions(Database::Employee, Employee.SystemId);
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
        TestCreateDefaultDimensionFailsWithBlockedDimension(Database::Customer, Customer.SystemId);
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
        TestCreateDefaultDimensionFailsWithBlockedDimension(Database::Vendor, Vendor.SystemId);
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
        TestCreateDefaultDimensionFailsWithBlockedDimension(Database::Item, Item.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension on the Employee
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimensionFailsWithBlockedDimension(Database::Employee, Employee.SystemId);
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
        TestCreateDefaultDimensionFailsWithBlockedDimensionValue(Database::Customer, Customer.SystemId);
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
        TestCreateDefaultDimensionFailsWithBlockedDimensionValue(Database::Vendor, Vendor.SystemId);
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
        TestCreateDefaultDimensionFailsWithBlockedDimensionValue(Database::Item, Item.SystemId);
    end;

    [Test]
    procedure TestCreateDefaultDimensionFailsWithBlockedDimensionValueOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee, a dimension and a dimension value
        // [WHEN] The user posts a http request to create a default dimension with a blocked dimension value on the Employee
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestCreateDefaultDimensionFailsWithBlockedDimensionValue(Database::Employee, Employee.SystemId);
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
        TestDeleteDefaultDimension(Database::Customer, Customer."No.", Customer.SystemId);
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
        TestDeleteDefaultDimension(Database::Vendor, Vendor."No.", Vendor.SystemId);
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
        TestDeleteDefaultDimension(Database::Item, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestDeleteDefaultDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee with a default dimension
        // [WHEN] The user posts a http request to delete a default dimension on the Employee
        // [THEN] The default dimension has been deleted from the employee's default dimensions
        LibraryHumanResource.CreateEmployee(Employee);
        TestDeleteDefaultDimension(Database::Employee, Employee."No.", Employee.SystemId);
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
        TestGetDefaultDimension(Database::Customer, Customer."No.", Customer.SystemId);
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
        TestGetDefaultDimension(Database::Vendor, Vendor."No.", Vendor.SystemId);
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
        TestGetDefaultDimension(Database::Item, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestGetDefaultDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee with a default dimension
        // [WHEN] The user posts a http request to get a default dimension on the Employee
        // [THEN] The response contains the default dimension that has been added to the Employee
        LibraryHumanResource.CreateEmployee(Employee);
        TestGetDefaultDimension(Database::Employee, Employee."No.", Employee.SystemId);
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
        TestPatchDefaultDimension(Database::Customer, Customer."No.", Customer.SystemId);
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
        TestPatchDefaultDimension(Database::Vendor, Vendor."No.", Vendor.SystemId);
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
        TestPatchDefaultDimension(Database::Item, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee with a default dimension
        // [WHEN] The user posts a http request to patch a default dimension on the Employee
        // [THEN] The default dimension has been updated for the employee
        LibraryHumanResource.CreateEmployee(Employee);
        TestPatchDefaultDimension(Database::Employee, Employee."No.", Employee.SystemId);
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
        TestPatchDefaultDimensionFailsWithBlockedValue(Database::Customer, Customer."No.", Customer.SystemId);
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
        TestPatchDefaultDimensionFailsWithBlockedValue(Database::Vendor, Vendor."No.", Vendor.SystemId);
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
        TestPatchDefaultDimensionFailsWithBlockedValue(Database::Item, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionFailsWithBlockedValueOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a Employee with a default dimension
        // [WHEN] The user posts a http request to patch a default dimension with a blocked dimension value on the Employee
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestPatchDefaultDimensionFailsWithBlockedValue(Database::Employee, Employee."No.", Employee.SystemId);
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
        TestPatchDefaultDimensionFailsWhenChangingDimensionCode(Database::Customer, Customer."No.", Customer.SystemId);
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
        TestPatchDefaultDimensionFailsWhenChangingDimensionCode(Database::Vendor, Vendor."No.", Vendor.SystemId);
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
        TestPatchDefaultDimensionFailsWhenChangingDimensionCode(Database::Item, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestPatchDefaultDimensionFailsWhenChangingDimensionCodeOnEmployee()
    var
        Employee: Record "Employee";
    begin
        // [FEATURE] [Employee]
        // [GIVEN] a employee with a default dimension
        // [WHEN] The user posts a http request to patch the default dimension with a blocked dimension value on the employee
        // [THEN] You get an error
        LibraryHumanResource.CreateEmployee(Employee);
        TestPatchDefaultDimensionFailsWhenChangingDimensionCode(Database::Employee, Employee."No.", Employee.SystemId);
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
        ParentIdAsText := LowerCase(Format(ParentId));
        DimensionValueId := LowerCase(Format(DimensionValue.SystemId));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, GetParentType(TableNo), '', Dimension.Code, DimensionValueId, '', '');
        LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);

        Assert.IsTrue(
          DefaultDimension.Get(TableNo, ParentNo, Dimension.Code), 'Default Dimension not created for the test entity.');
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
        ParentIdAsText := LowerCase(Format(ParentId));
        DimensionId := LowerCase(Format(Dimension.SystemId));
        DimensionValueId := LowerCase(Format(DimensionValue.SystemId));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, GetParentType(TableNo), DimensionId, '', DimensionValueId, '', '');
        LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);

        Assert.IsTrue(
          DefaultDimension.Get(TableNo, ParentNo, Dimension.Code), 'Default Dimension not created for the test entity.');
        Assert.AreEqual(
          DefaultDimension."Dimension Value Code", DimensionValue.Code, 'Unexpected default dimension value for the test entity.');
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
        ParentIdAsText := LowerCase(Format(ParentId));
        DimensionId := LowerCase(Format(Dimension.SystemId));
        DimensionValue2Id := LowerCase(Format(DimensionValue2.SystemId));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, GetParentType(TableNo), DimensionId, '', DimensionValue2Id, '', '');

        asserterror LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);
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
        Dimension.Validate(Blocked, true);
        Dimension.Modify(true);
        ParentIdAsText := LowerCase(Format(ParentId));
        DimensionId := LowerCase(Format(Dimension.SystemId));
        DimensionValueId := LowerCase(Format(DimensionValue.SystemId));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, GetParentType(TableNo), DimensionId, '', DimensionValueId, '', '');

        asserterror LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);
        Assert.ExpectedError(StrSubstNo(BlockedDimensionErr, Dimension.TABLECAPTION(), Dimension.Code));
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
        DimensionValue.Validate(Blocked, true);
        DimensionValue.Modify(true);
        ParentIdAsText := LowerCase(Format(ParentId));
        DimensionId := LowerCase(Format(Dimension.SystemId));
        DimensionValueId := LowerCase(Format(DimensionValue.SystemId));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody(ParentIdAsText, GetParentType(TableNo), DimensionId, '', DimensionValueId, '', '');

        asserterror LibraryGraphMgt.PostToWebService(TargetURL, DefaultDimensionJSON, Response);
        Assert.ExpectedError(StrSubstNo(DimValueBlockedErr, DimensionValue.TABLECAPTION(), Dimension.Code, DimensionValue.Code));
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
        DefaultDimension.Validate("Table ID", TableNo);
        DefaultDimension.Validate("No.", ParentNo);
        DefaultDimension.Validate("Dimension Code", Dimension.Code);
        DefaultDimension.Validate("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.Insert(true);

        ParentIdAsText := LowerCase(Format(ParentId));
        DimensionId := LowerCase(Format(Dimension.SystemId));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + '(' + LibraryGraphMgt.StripBrackets(Format(DefaultDimension.SystemId)) + ')';
        TargetURL := LibraryGraphMgt.StrReplace(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
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
        DefaultDimension.Validate("Table ID", TableNo);
        DefaultDimension.Validate("No.", ParentNo);
        DefaultDimension.Validate("Dimension Code", Dimension.Code);
        DefaultDimension.Validate("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.Insert(true);

        ParentIdAsText := LowerCase(LibraryGraphMgt.StripBrackets(Format(ParentId)));
        DimensionId := LowerCase(LibraryGraphMgt.StripBrackets(Format(Dimension.SystemId)));
        DimensionValueId := LowerCase(LibraryGraphMgt.StripBrackets(Format(DimensionValue.SystemId)));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + '(' + LibraryGraphMgt.StripBrackets(Format(DefaultDimension.SystemId)) + ')';
        TargetURL := LibraryGraphMgt.StrReplace(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        VerifyDefaultDimensionResponseBody(Response, ParentIdAsText, GetParentType(TableNo), DimensionId, '', DimensionValueId, '', '');
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
        DefaultDimension.Validate("Table ID", TableNo);
        DefaultDimension.Validate("No.", ParentNo);
        DefaultDimension.Validate("Dimension Code", Dimension.Code);
        DefaultDimension.Validate("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.Insert(true);

        ParentIdAsText := LowerCase(Format(ParentId));
        DimensionId := LowerCase(Format(Dimension.SystemId));
        DimensionValue2Id := LowerCase(Format(DimensionValue2.SystemId));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + '(' + LibraryGraphMgt.StripBrackets(Format(DefaultDimension.SystemId)) + ')';
        TargetURL := LibraryGraphMgt.StrReplace(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody('', GetParentType(TableNo), '', '', DimensionValue2Id, '', 'Same Code');
        LibraryGraphMgt.PatchToWebService(TargetURL, DefaultDimensionJSON, Response);

        DefaultDimension.Get(TableNo, ParentNo, Dimension.Code);
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
        DimensionValue2.Validate(Blocked, true);
        DimensionValue2.Modify(true);
        DefaultDimension.Validate("Table ID", TableNo);
        DefaultDimension.Validate("No.", ParentNo);
        DefaultDimension.Validate("Dimension Code", Dimension.Code);
        DefaultDimension.Validate("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.Insert(true);

        ParentIdAsText := LowerCase(Format(ParentId));
        DimensionId := LowerCase(Format(Dimension.SystemId));
        DimensionValue2Id := LowerCase(Format(DimensionValue2.SystemId));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + '(' + LibraryGraphMgt.StripBrackets(Format(DefaultDimension.SystemId)) + ')';
        TargetURL := LibraryGraphMgt.StrReplace(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody('', GetParentType(TableNo), '', '', DimensionValue2Id, '', 'Same Code');

        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, DefaultDimensionJSON, Response);
        Assert.ExpectedError(StrSubstNo(DimValueBlockedErr, DimensionValue.TABLECAPTION(), Dimension.Code, DimensionValue2.Code));
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
        DefaultDimension.Validate("Table ID", TableNo);
        DefaultDimension.Validate("No.", ParentNo);
        DefaultDimension.Validate("Dimension Code", Dimension.Code);
        DefaultDimension.Validate("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.Insert(true);

        ParentIdAsText := LowerCase(Format(ParentId));
        DimensionId := LowerCase(Format(Dimension.SystemId));
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            ParentId, GetEntityPageNo(TableNo), GetServiceName(TableNo), DefaultDimensionsServiceNameTxt);
        SubpageWithIdTxt := DefaultDimensionsServiceNameTxt + '(' + LibraryGraphMgt.StripBrackets(Format(DefaultDimension.SystemId)) + ')';
        TargetURL := LibraryGraphMgt.StrReplace(TargetURL, DefaultDimensionsServiceNameTxt, SubpageWithIdTxt);
        DefaultDimensionJSON := CreateDefaultDimensionRequestBody('', GetParentType(TableNo), '', Dimension2.Code, '', '', '');

        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, DefaultDimensionJSON, Response);
    end;

    local procedure CreateDefaultDimensionRequestBody(ParentId: Text; ParentType: Enum "Default Dimension Parent Type"; DimensionId: Text; DimensionCode: Text; DimensionValueId: Text; DimensionValueCode: Text; ValuePosting: Text): Text
    var
        DefaultDimensionJSON: Text;
    begin
        if ParentId <> '' then
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'parentId', ParentId);
        if Format(ParentType) <> '' then
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'parentType', Format(ParentType));
        if DimensionId <> '' then
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'dimensionId', DimensionId);
        if DimensionCode <> '' then
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'dimensionCode', DimensionCode);
        if DimensionValueId <> '' then
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'dimensionValueId', DimensionValueId);
        if DimensionValueCode <> '' then
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'dimensionValueCode', DimensionValueCode);
        if ValuePosting <> '' then
            DefaultDimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DefaultDimensionJSON, 'postingValidation', ValuePosting);
        exit(DefaultDimensionJSON)
    end;

    local procedure VerifyDefaultDimensionResponseBody(Response: Text; ParentId: Text; ParentType: Enum "Default Dimension Parent Type"; DimensionId: Text; DimensionCode: Text; DimensionValueId: Text; DimensionValueCode: Text; ValuePosting: Text)
    var
    begin
        Assert.AreNotEqual('', Response, EmptyResponseErr);
        if ParentId <> '' then
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'parentId', ParentId);
        if Format(ParentType) <> '' then
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'parentType', Format(ParentType));
        if DimensionId <> '' then
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'dimensionId', DimensionId);
        if DimensionCode <> '' then
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'dimensionCode', DimensionCode);
        if DimensionValueId <> '' then
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'dimensionValueId', DimensionValueId);
        if DimensionValueCode <> '' then
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'dimensionValueCode', DimensionValueCode);
        if ValuePosting <> '' then
            LibraryGraphMgt.VerifyPropertyInJSON(Response, 'postingValidation', ValuePosting);
    end;

    local procedure GetEntityPageNo(TableNo: Integer): Integer
    begin
        CASE TableNo OF
            Database::Customer:
                exit(Page::"APIV2 - Customers");
            Database::Vendor:
                exit(Page::"APIV2 - Vendors");
            Database::Item:
                exit(Page::"APIV2 - Items");
            Database::Employee:
                exit(Page::"APIV2 - Employees");
        end;
        exit(-1);
    end;

    local procedure GetServiceName(TableNo: Integer): Text
    begin
        CASE TableNo OF
            Database::Customer:
                exit(CustomerServiceNameTxt);
            Database::Vendor:
                exit(VendorServiceNameTxt);
            Database::Item:
                exit(ItemServiceNameTxt);
            Database::Employee:
                exit(EmployeeServiceNameTxt);
        end;
        exit('');
    end;

    local procedure GetParentType(TableNo: Integer): Enum "Default Dimension Parent Type"
    var
        DefaultDimensionParentType: Enum "Default Dimension Parent Type";
    begin
        CASE TableNo OF
            Database::Customer:
                exit(DefaultDimensionParentType::Customer);
            Database::Vendor:
                exit(DefaultDimensionParentType::Vendor);
            Database::Item:
                exit(DefaultDimensionParentType::Item);
            Database::Employee:
                exit(DefaultDimensionParentType::Employee);
        end;
        exit(DefaultDimensionParentType::" ");
    end;
}