codeunit 148187 "Sust. Certificate Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryResource: Codeunit "Library - Resource";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryManufacturing: Codeunit "Library - Manufacturing";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        FieldShouldNotBeEnabledErr: Label '%1 should not be enabled in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldBeEnabledErr: Label '%1 should be enabled in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldBeVisibleErr: Label '%1 should be visible in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldNotBeVisibleErr: Label '%1 should not be visible in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        ConfirmationForClearEmissionInfoQst: Label 'Changing the Replenishment System to %1 will clear sustainability emission value. Do you want to continue?', Comment = '%1 = Replenishment System';

    [Test]
    procedure VerifyHasValueFieldShouldThrowErrorWhenValueIsUpdated()
    var
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Value" field should throw error When "Has Value" field is false.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [WHEN] Update "Value" in Sustainability Certificate.
        asserterror SustainabilityCertificate.Validate(Value, LibraryRandom.RandInt(10));

        // [VERIFY] Expecting a testfield error When the "Value" field is validated.
        Assert.ExpectedTestFieldError(SustainabilityCertificate.FieldCaption("Has Value"), '');
    end;

    [Test]
    procedure VerifySustCertNoFieldShouldThrowErrorWhenSustCertNameIsUpdated()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Sust. Cert. Name" field should throw error When "Sust. Cert. No." field is blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [WHEN] Update "Sust. Cert. Name" in Item.
        asserterror Item.Validate("Sust. Cert. Name", LibraryRandom.RandText(10));

        // [VERIFY] Expecting a testfield error When the "Sust. Cert. Name" field is validated.
        Assert.ExpectedTestFieldError(Item.FieldCaption("Sust. Cert. No."), '');
    end;

    [Test]
    procedure VerifyTypeFieldShouldThrowErrorWhenSustCertNoIsUpdated()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Sust. Cert. No." field should throw error When Item type is not Inventory.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item with Type "Non-Inventory".
        LibraryInventory.CreateItem(Item);
        Item.Validate(Type, Item.Type::"Non-Inventory");
        Item.Modify();

        // [WHEN] Update "Sust. Cert. No." in Item.
        asserterror Item.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");

        // [VERIFY] Expecting a testfield error When the "Sust. Cert. No." field is validated.
        Assert.ExpectedTestFieldError(Item.FieldCaption(Type), Format(Item.Type::Inventory));
    end;

    [Test]
    procedure VerifySustCertNoFieldShouldThrowErrorWhenItemTypeIsUpdatedToNonInventory()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Sust. Cert. No." field should throw error When Item type is changed to "Non-Inventory".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item with Type "Inventory".
        LibraryInventory.CreateItem(Item);
        Item.Validate(Type, Item.Type::Inventory);
        Item.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");
        Item.Modify();

        // [WHEN] Update Type in an Item.
        asserterror Item.Validate(Type, Item.Type::"Non-Inventory");

        // [VERIFY] Expecting a testfield error When Item type is changed to "Non-Inventory".
        Assert.ExpectedTestFieldError(Item.FieldCaption("Sust. Cert. No."), Format(' '));
    end;

    [Test]
    procedure VerifySustCertNoFieldShouldThrowErrorWhenItemTypeIsUpdatedToService()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Sust. Cert. No." field should throw error When Item type is changed to "Service".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item with Type "Inventory".
        LibraryInventory.CreateItem(Item);
        Item.Validate(Type, Item.Type::Inventory);
        Item.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");
        Item.Modify();

        // [WHEN] Update Type in an Item.
        asserterror Item.Validate(Type, Item.Type::"Service");

        // [VERIFY] Expecting a testfield error When Item type is changed to "Service".
        Assert.ExpectedTestFieldError(Item.FieldCaption("Sust. Cert. No."), Format(' '));
    end;

    [Test]
    procedure VerifySustCertNameShouldBeUpdatedInItem()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Sust. Cert. Name" field should be updated in Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [WHEN] Update "Type" and "Sust. Cert. No." in an Item.
        Item.Validate(Type, Item.Type::Inventory);
        Item.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");
        Item.Modify();

        // [VERIFY] Verify "Sust. Cert. Name" field should be updated in an Item.
        Assert.AreEqual(
            SustainabilityCertificate.Name,
            Item."Sust. Cert. Name",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Sust. Cert. Name"), SustainabilityCertificate.Name, Item.TableCaption()));
    end;

    [Test]
    procedure VerifySustCertNameShouldBeUpdatedInVendor()
    var
        Vendor: Record Vendor;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Sust. Cert. Name" field should be updated in Vendor.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Vendor);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [WHEN] Update "Sust. Cert. No." in Vendor.
        Vendor.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");
        Vendor.Modify();

        // [VERIFY] Verify "Sust. Cert. Name" field should be updated in Vendor.
        Assert.AreEqual(
            SustainabilityCertificate.Name,
            Vendor."Sust. Cert. Name",
            StrSubstNo(ValueMustBeEqualErr, Vendor.FieldCaption("Sust. Cert. Name"), SustainabilityCertificate.Name, Vendor.TableCaption()));
    end;

    [Test]
    procedure VerifySustCertNoShouldThrowErrorIfCertificateTypeIsVendor()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Sust. Cert. no." field should throw error If Certificate type is Vendor.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Vendor);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [WHEN] Update "Sust. Cert. No." in an Item.
        asserterror Item.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");
    end;

    [Test]
    procedure VerifySustCertNoShouldThrowErrorIfCertificateTypeIsItem()
    var
        Vendor: Record Vendor;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Sust. Cert. no." field should throw error If Certificate type is Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [WHEN] Update "Sust. Cert. No." in Vendor.
        asserterror Vendor.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");
    end;

    [Test]
    procedure VerifyCarbonCreditPerUOMShouldThrowErrorIfGHGCreditIsFalseInItem()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Carbon Credit Per UOM" field should throw an error If "GHG Credit" is false in an Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [WHEN] Update "Carbon Credit Per UOM" in an Item.
        asserterror Item.Validate("Carbon Credit Per UOM", LibraryRandom.RandInt(10));

        // [SCENARIO 496566] Verify "Carbon Credit Per UOM" field should throw an error If "GHG Credit" is false in an Item.
        Assert.ExpectedTestFieldError(Item.FieldCaption("GHG Credit"), '');
    end;

    [Test]
    procedure VerifyGHGCreditShouldThrowErrorIfCarbonCreditPerUOMContainsValueInItem()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify "Carbon Credit Per UOM" field should throw an error If "GHG Credit" is false in an Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);
        Item.Validate("GHG Credit", true);
        Item.Validate("Carbon Credit Per UOM", LibraryRandom.RandInt(10));
        Item.Modify(true);

        // [WHEN] Update "GHG Credit" to false in an Item.
        asserterror Item.Validate("GHG Credit", false);

        // [VERIFY] Verify "Carbon Credit Per UOM" field should throw an error If "GHG Credit" is false in an Item.
        Assert.ExpectedTestFieldError(Item.FieldCaption("Carbon Credit Per UOM"), Format('0'));
    end;

    [Test]
    procedure VerifyCarbonCreditPerUOMShouldNotBeEnabledIfGHGCreditIsFalse()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
        ItemCard: TestPage "Item Card";
    begin
        // [SCENARIO 496566] Verify "Carbon Credit Per UOM" should not be enabled If "GHG Credit" is false.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);
        Item.Validate("GHG Credit", false);
        Item.Modify(true);

        // [WHEN] Open Item Card.
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify "Carbon Credit Per UOM" should not be enabled If "GHG Credit" is false.
        Assert.AreEqual(
            false,
            ItemCard."Carbon Credit Per UOM".Enabled(),
            StrSubstNo(FieldShouldNotBeEnabledErr, Item.FieldCaption("Carbon Credit Per UOM"), Item.TableCaption()));
    end;

    [Test]
    procedure VerifyCarbonCreditPerUOMShouldBeEnabledIfGHGCreditIsTrue()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
        ItemCard: TestPage "Item Card";
    begin
        // [SCENARIO 496566] Verify "Carbon Credit Per UOM" should be enabled If "GHG Credit" is true.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);
        Item.Validate("GHG Credit", true);
        Item.Modify(true);

        // [WHEN] Open Item Card.
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify "Carbon Credit Per UOM" should be enabled If "GHG Credit" is true.
        Assert.AreEqual(
            true,
            ItemCard."Carbon Credit Per UOM".Enabled(),
            StrSubstNo(FieldShouldBeEnabledErr, Item.FieldCaption("Carbon Credit Per UOM"), Item.TableCaption()));
    end;

    [Test]
    procedure VerifyPurchaseLineShouldThrowErrorWhenCarbonCreditPerUOMIsZeroIfGHGCreditIsEnabled()
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
    begin
        // [SCENARIO 496566] Verify Purchase Line should throw error When "Carbon Credit Per UOM" is Zero If "GHG Credit" is enabled in Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item with "GHG Credit".
        LibraryInventory.CreateItem(Item);
        Item.Validate("GHG Credit", true);
        Item.Modify(true);

        // [GIVEN] Create Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // Create a Purchase Line.
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Insert();

        // [WHEN] Update Item No. in Purchase Line.
        asserterror PurchaseLine.Validate("No.", Item."No.");

        // [VERIFY] Verify Purchase Line should throw error When "Carbon Credit Per UOM" is Zero If "GHG Credit" is enabled in Item.
        Assert.ExpectedTestFieldError(Item.FieldCaption("Carbon Credit Per UOM"), '');
    end;

    [Test]
    procedure VerifySustLedgerEntryShouldBeCreatedWhenGHGCreditIsEnabled()
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvNo: Code[20];
    begin
        // [SCENARIO 496566] Verify Sustainability Ledger Entry should be created When "GHG Credit" is enabled in Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item with "GHG Credit".
        LibraryInventory.CreateItem(Item);
        Item.Validate("GHG Credit", true);
        Item.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");
        Item.Validate("Carbon Credit Per UOM", LibraryRandom.RandInt(10));
        Item.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            Item."No.",
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger Entry should be created When "GHG Credit" is enabled in Item.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvNo);
        Assert.RecordCount(SustainabilityLedgerEntry, 1);

        SustainabilityLedgerEntry.SetRange("Document Type", SustainabilityLedgerEntry."Document Type"::"GHG Credit");
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(
                ValueMustBeEqualErr,
                SustainabilityLedgerEntry.FieldCaption("Emission CH4"),
                0,
                SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(
                ValueMustBeEqualErr,
                SustainabilityLedgerEntry.FieldCaption("Emission N2O"),
                0,
                SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -(PurchaseLine."Qty. per Unit of Measure" * Item."Carbon Credit Per UOM" * PurchaseLine."Qty. to Invoice"),
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(
                ValueMustBeEqualErr,
                SustainabilityLedgerEntry.FieldCaption("Emission CO2"),
                -(PurchaseLine."Qty. per Unit of Measure" * Item."Carbon Credit Per UOM"),
                SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeKnockedOffWhenCancelCreditMemoIsPostedIfHGCreditIsEnabled()
    var
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        NoSeriesLine: Record "No. Series Line";
        PurchaseHeader: Record "Purchase Header";
        SustCertificateArea: Record "Sust. Certificate Area";
        SustainabilityAccount: Record "Sustainability Account";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
    begin
        // [SCENARIO 496566] Verify Sustainability Ledger entry should be Kocked Off when the Cancel Credit Memo is posted If "GHG Credit" is enabled in Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create "No. Series Line" with WorkDate.
        PurchasesPayablesSetup.Get();
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, PurchasesPayablesSetup."Posted Credit Memo Nos.", '', '');
        NoSeriesLine.Validate("Starting Date", WorkDate());
        NoSeriesLine.Modify();

        // [GIVEN] Create Sustainability Certificate Area.
        LibrarySustainability.InsertSustainabilityCertificateArea(SustCertificateArea);

        // [GIVEN] Create Sustainability Certificate Standard.
        LibrarySustainability.InsertSustainabilityCertificateStandard(SustCertificateStandard);

        // [GIVEN] Create Sustainability Certificate.
        LibrarySustainability.InsertSustainabilityCertificate(
            SustainabilityCertificate,
            SustCertificateArea."No.",
            SustCertificateStandard."No.",
            SustainabilityCertificate.Type::Item);

        // [GIVEN] Create an Item with "GHG Credit".
        LibraryInventory.CreateItem(Item);
        Item.Validate("GHG Credit", true);
        Item.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");
        Item.Validate("Carbon Credit Per UOM", LibraryRandom.RandInt(10));
        Item.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            Item."No.",
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", 0);
        PurchaseLine.Validate("Emission N2O", 0);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Post a Purchase Document.
        PostAndVerifyCancelCreditMemo(PurchaseHeader);

        // [VERIFY] Verify Sustainability Ledger entry should be Kocked Off when the Cancel Credit Memo is posted If "GHG Credit" is enabled in Item.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O");
        Assert.RecordCount(SustainabilityLedgerEntry, 2);

        Assert.AreEqual(
           0,
           SustainabilityLedgerEntry."Emission CO2",
           StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifyDefaultSustAccountShouldbeVisibleOnGLAccountCardIfGLAccountEmissionsIsEnabled()
    var
        GLAccount: Record "G/L Account";
        SustainabilitySetup: Record "Sustainability Setup";
        GLAccountCard: TestPage "G/L Account Card";
        GLAccountNo: Code[20];
    begin
        // [SCENARIO 537413] Verify "Default Sust. Account" should be visible on "G/L Account Card" page If "G/L Account Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a G/L Account.
        GLAccountNo := LibraryERM.CreateGLAccountNoWithDirectPosting();

        // [GIVEN] Get a G/L Account.
        GLAccount.Get(GLAccountNo);

        // [WHEN] Open "G/L Account Card".
        GLAccountCard.OpenView();
        GLAccountCard.GoToRecord(GLAccount);

        // [VERIFY] Verify "Default Sust. Account" should not be visible on "G/L Account Card" page If "G/L Account Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            GLAccountCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, GLAccountCard."Default Sust. Account".Caption(), GLAccountCard.Caption()));

        // [GIVEN] Close "G/L Account Card".
        GLAccountCard.Close();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "G/L Account Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("G/L Account Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "G/L Account Card".
        GLAccountCard.OpenView();
        GLAccountCard.GoToRecord(GLAccount);

        // [VERIFY] Verify "Default Sust. Account" should be visible on "G/L Account Card" page If "G/L Account Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            GLAccountCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, GLAccountCard."Default Sust. Account".Caption(), GLAccountCard.Caption()));
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeVisibleOnItemCardIfItemEmissionsIsEnabled()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCard: TestPage "Item Card";
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be visible on "Item Card" page If "Item Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [WHEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify Default Sust. fields should not be visible on "Item Card" page If "Item Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ItemCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ItemCard."Default Sust. Account".Caption(), ItemCard.Caption()));
        Assert.AreEqual(
            false,
            ItemCard."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ItemCard."Default CO2 Emission".Caption(), ItemCard.Caption()));
        Assert.AreEqual(
            false,
            ItemCard."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ItemCard."Default CH4 Emission".Caption(), ItemCard.Caption()));
        Assert.AreEqual(
            false,
            ItemCard."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ItemCard."Default N2O Emission".Caption(), ItemCard.Caption()));

        // [GIVEN] Close "Item Card".
        ItemCard.Close();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify Default Sust. fields should be visible on "Item Card" page If "Item Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            ItemCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ItemCard."Default Sust. Account".Caption(), ItemCard.Caption()));
        Assert.AreEqual(
            true,
            ItemCard."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ItemCard."Default CO2 Emission".Caption(), ItemCard.Caption()));
        Assert.AreEqual(
            true,
            ItemCard."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ItemCard."Default CH4 Emission".Caption(), ItemCard.Caption()));
        Assert.AreEqual(
            true,
            ItemCard."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ItemCard."Default N2O Emission".Caption(), ItemCard.Caption()));
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeVisibleOnItemCategoryCardIfItemEmissionsIsEnabled()
    var
        ItemCategory: Record "Item Category";
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCategoryCard: TestPage "Item Category Card";
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be visible on "Item Category Card" page If "Item Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Item Category.
        LibraryInventory.CreateItemCategory(ItemCategory);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Item Category Card".
        ItemCategoryCard.OpenView();
        ItemCategoryCard.GoToRecord(ItemCategory);

        // [VERIFY] Verify Default Sust. fields should not be visible on "Item Category Card" page If "Item Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ItemCategoryCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ItemCategoryCard."Default Sust. Account".Caption(), ItemCategoryCard.Caption()));

        // [GIVEN] Close "Item Category Card".
        ItemCategoryCard.Close();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Item Category Card".
        ItemCategoryCard.OpenView();
        ItemCategoryCard.GoToRecord(ItemCategory);

        // [VERIFY] Verify Default Sust. fields should be visible on "Item Category Card" page If "Item Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            ItemCategoryCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ItemCategoryCard."Default Sust. Account".Caption(), ItemCategoryCard.Caption()));
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeVisibleOnItemChargesIfItemChargeEmissionsIsEnabled()
    var
        ItemCharge: Record "Item Charge";
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCharges: TestPage "Item Charges";
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be visible on "Item Charges" page If "Item Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Item Charge.
        LibraryInventory.CreateItemCharge(ItemCharge);

        // [WHEN] Open "Item Charges".
        ItemCharges.OpenView();
        ItemCharges.GoToRecord(ItemCharge);

        // [VERIFY] Verify Default Sust. fields should not be visible on "Item Charges" page If "Item Charge Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ItemCharges."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ItemCharges."Default Sust. Account".Caption(), ItemCharges.Caption()));
        Assert.AreEqual(
            false,
            ItemCharges."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ItemCharges."Default CO2 Emission".Caption(), ItemCharges.Caption()));
        Assert.AreEqual(
            false,
            ItemCharges."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ItemCharges."Default CH4 Emission".Caption(), ItemCharges.Caption()));
        Assert.AreEqual(
            false,
            ItemCharges."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ItemCharges."Default N2O Emission".Caption(), ItemCharges.Caption()));

        // [GIVEN] Close "Item Charges".
        ItemCharges.Close();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Charge Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Charge Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Item Charges".
        ItemCharges.OpenView();
        ItemCharges.GoToRecord(ItemCharge);

        // [VERIFY] Verify Default Sust. fields should be visible on "Item Charges" page If "Item Charge Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            ItemCharges."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ItemCharges."Default Sust. Account".Caption(), ItemCharges.Caption()));
        Assert.AreEqual(
            true,
            ItemCharges."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ItemCharges."Default CO2 Emission".Caption(), ItemCharges.Caption()));
        Assert.AreEqual(
            true,
            ItemCharges."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ItemCharges."Default CH4 Emission".Caption(), ItemCharges.Caption()));
        Assert.AreEqual(
            true,
            ItemCharges."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ItemCharges."Default N2O Emission".Caption(), ItemCharges.Caption()));
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeVisibleOnResourceCardIfResourceEmissionsIsEnabled()
    var
        Resource: Record Resource;
        SustainabilitySetup: Record "Sustainability Setup";
        ResourceCard: TestPage "Resource Card";
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be visible on "Resource Card" page If "Resource Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create an Resource.
        LibraryResource.CreateResource(Resource, '');

        // [WHEN] Open "Resource Card".
        ResourceCard.OpenView();
        ResourceCard.GoToRecord(Resource);

        // [VERIFY] Verify Default Sust. fields should not be visible on "Resource Card" page If "Resource Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ResourceCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ResourceCard."Default Sust. Account".Caption(), ResourceCard.Caption()));
        Assert.AreEqual(
            false,
            ResourceCard."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ResourceCard."Default CO2 Emission".Caption(), ResourceCard.Caption()));
        Assert.AreEqual(
            false,
            ResourceCard."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ResourceCard."Default CH4 Emission".Caption(), ResourceCard.Caption()));
        Assert.AreEqual(
            false,
            ResourceCard."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ResourceCard."Default N2O Emission".Caption(), ResourceCard.Caption()));

        // [GIVEN] Close "Resource Card".
        ResourceCard.Close();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Resource Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Resource Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Resource Card".
        ResourceCard.OpenView();
        ResourceCard.GoToRecord(Resource);

        // [VERIFY] Verify Default Sust. fields should be visible on "Resource Card" page If "Resource Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            ResourceCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ResourceCard."Default Sust. Account".Caption(), ResourceCard.Caption()));
        Assert.AreEqual(
            true,
            ResourceCard."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ResourceCard."Default CO2 Emission".Caption(), ResourceCard.Caption()));
        Assert.AreEqual(
            true,
            ResourceCard."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ResourceCard."Default CH4 Emission".Caption(), ResourceCard.Caption()));
        Assert.AreEqual(
            true,
            ResourceCard."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, ResourceCard."Default N2O Emission".Caption(), ResourceCard.Caption()));
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeVisibleOnMachineCenterCardIfWorkMachineCenterEmissionsIsEnabled()
    var
        MachineCenter: Record "Machine Center";
        SustainabilitySetup: Record "Sustainability Setup";
        MachineCenterCard: TestPage "Machine Center Card";
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be visible on "Machine Center Card" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenter(MachineCenter, '', LibraryRandom.RandDec(10, 1));

        // [WHEN] Open "Machine Center Card".
        MachineCenterCard.OpenView();
        MachineCenterCard.GoToRecord(MachineCenter);

        // [VERIFY] Verify Default Sust. fields should not be visible on "Machine Center Card" page If "Work/Machine Center Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            MachineCenterCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, MachineCenterCard."Default Sust. Account".Caption(), MachineCenterCard.Caption()));
        Assert.AreEqual(
            false,
            MachineCenterCard."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, MachineCenterCard."Default CO2 Emission".Caption(), MachineCenterCard.Caption()));
        Assert.AreEqual(
            false,
            MachineCenterCard."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, MachineCenterCard."Default CH4 Emission".Caption(), MachineCenterCard.Caption()));
        Assert.AreEqual(
            false,
            MachineCenterCard."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, MachineCenterCard."Default N2O Emission".Caption(), MachineCenterCard.Caption()));

        // [GIVEN] Close "Machine Center Card".
        MachineCenterCard.Close();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Machine Center Card".
        MachineCenterCard.OpenView();
        MachineCenterCard.GoToRecord(MachineCenter);

        // [VERIFY] Verify Default Sust. fields should be visible on "Machine Center Card" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            MachineCenterCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, MachineCenterCard."Default Sust. Account".Caption(), MachineCenterCard.Caption()));
        Assert.AreEqual(
            true,
            MachineCenterCard."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, MachineCenterCard."Default CO2 Emission".Caption(), MachineCenterCard.Caption()));
        Assert.AreEqual(
            true,
            MachineCenterCard."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, MachineCenterCard."Default CH4 Emission".Caption(), MachineCenterCard.Caption()));
        Assert.AreEqual(
            true,
            MachineCenterCard."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, MachineCenterCard."Default N2O Emission".Caption(), MachineCenterCard.Caption()));
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeVisibleOnWorkCenterCardIfWorkMachineCenterEmissionsIsEnabled()
    var
        WorkCenter: Record "Work Center";
        SustainabilitySetup: Record "Sustainability Setup";
        WorkCenterCard: TestPage "Work Center Card";
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be visible on "Work Center Card" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenter(WorkCenter);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Work Center Card".
        WorkCenterCard.OpenView();
        WorkCenterCard.GoToRecord(WorkCenter);

        // [VERIFY] Verify Default Sust. fields should not be visible on "Work Center Card" page If "Work/Machine Center Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            WorkCenterCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, WorkCenterCard."Default Sust. Account".Caption(), WorkCenterCard.Caption()));
        Assert.AreEqual(
            false,
            WorkCenterCard."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, WorkCenterCard."Default CO2 Emission".Caption(), WorkCenterCard.Caption()));
        Assert.AreEqual(
            false,
            WorkCenterCard."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, WorkCenterCard."Default CH4 Emission".Caption(), WorkCenterCard.Caption()));
        Assert.AreEqual(
            false,
            WorkCenterCard."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, WorkCenterCard."Default N2O Emission".Caption(), WorkCenterCard.Caption()));

        // [GIVEN] Close "Work Center Card".
        WorkCenterCard.Close();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Work Center Card".
        WorkCenterCard.OpenView();
        WorkCenterCard.GoToRecord(WorkCenter);

        // [VERIFY] Verify Default Sust. fields should be visible on "Work Center Card" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            WorkCenterCard."Default Sust. Account".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, WorkCenterCard."Default Sust. Account".Caption(), WorkCenterCard.Caption()));
        Assert.AreEqual(
            true,
            WorkCenterCard."Default CO2 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, WorkCenterCard."Default CO2 Emission".Caption(), WorkCenterCard.Caption()));
        Assert.AreEqual(
            true,
            WorkCenterCard."Default CH4 Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, WorkCenterCard."Default CH4 Emission".Caption(), WorkCenterCard.Caption()));
        Assert.AreEqual(
            true,
            WorkCenterCard."Default N2O Emission".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, WorkCenterCard."Default N2O Emission".Caption(), WorkCenterCard.Caption()));
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeClearWhenSustAccountIsRemovedFromItem()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCard: TestPage "Item Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be clear on "Item Card" page When "Default Sust. Account" is changed to blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);
        ItemCard."Default Sust. Account".SetValue(AccountCode);
        ItemCard."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));
        ItemCard."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));
        ItemCard."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [WHEN] Clear "Default Sust. Account".
        ItemCard."Default Sust. Account".SetValue('');

        // [VERIFY] Verify Default Sust. fields should be clear on "Item Card" page When "Default Sust. Account" is changed to blank.
        ItemCard."Default Sust. Account".AssertEquals('');
        ItemCard."Default CO2 Emission".AssertEquals(0);
        ItemCard."Default CH4 Emission".AssertEquals(0);
        ItemCard."Default N2O Emission".AssertEquals(0);
        ItemCard.Close();
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeClearWhenSustAccountIsRemovedFromItemCharge()
    var
        ItemCharge: Record "Item Charge";
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCharges: TestPage "Item Charges";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be clear on "Item Charges" page When "Default Sust. Account" is changed to blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create an Item Charge.
        LibraryInventory.CreateItemCharge(ItemCharge);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Charge Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Charge Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Item Charges".
        ItemCharges.OpenView();
        ItemCharges.GoToRecord(ItemCharge);
        ItemCharges."Default Sust. Account".SetValue(AccountCode);
        ItemCharges."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));
        ItemCharges."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));
        ItemCharges."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [WHEN] Clear "Default Sust. Account".
        ItemCharges."Default Sust. Account".SetValue('');

        // [VERIFY] Verify Default Sust. fields should be clear on "Item Charges" page When "Default Sust. Account" is changed to blank.
        ItemCharges."Default Sust. Account".AssertEquals('');
        ItemCharges."Default CO2 Emission".AssertEquals(0);
        ItemCharges."Default CH4 Emission".AssertEquals(0);
        ItemCharges."Default N2O Emission".AssertEquals(0);
        ItemCharges.Close();
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeClearWhenSustAccountIsRemovedFromResource()
    var
        Resource: Record Resource;
        SustainabilitySetup: Record "Sustainability Setup";
        ResourceCard: TestPage "Resource Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be clear on "Resource Card" page When "Default Sust. Account" is changed to blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResource(Resource, '');

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Resource Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Resource Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Resource Card".
        ResourceCard.OpenView();
        ResourceCard.GoToRecord(Resource);
        ResourceCard."Default Sust. Account".SetValue(AccountCode);
        ResourceCard."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));
        ResourceCard."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));
        ResourceCard."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [WHEN] Clear "Default Sust. Account".
        ResourceCard."Default Sust. Account".SetValue('');

        // [VERIFY] Verify Default Sust. fields should be clear on "Resource Card" page When "Default Sust. Account" is changed to blank.
        ResourceCard."Default Sust. Account".AssertEquals('');
        ResourceCard."Default CO2 Emission".AssertEquals(0);
        ResourceCard."Default CH4 Emission".AssertEquals(0);
        ResourceCard."Default N2O Emission".AssertEquals(0);
        ResourceCard.Close();
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeClearWhenSustAccountIsRemovedFromMachineCenter()
    var
        MachineCenter: Record "Machine Center";
        SustainabilitySetup: Record "Sustainability Setup";
        MachineCenterCard: TestPage "Machine Center Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be clear on "Machine Center Card" page When "Default Sust. Account" is changed to blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenter(MachineCenter, '', LibraryRandom.RandDec(10, 1));

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Machine Center Card".
        MachineCenterCard.OpenView();
        MachineCenterCard.GoToRecord(MachineCenter);
        MachineCenterCard."Default Sust. Account".SetValue(AccountCode);
        MachineCenterCard."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));
        MachineCenterCard."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));
        MachineCenterCard."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [WHEN] Clear "Default Sust. Account".
        MachineCenterCard."Default Sust. Account".SetValue('');

        // [VERIFY] Verify Default Sust. fields should be clear on "Machine Center Card" page When "Default Sust. Account" is changed to blank.
        MachineCenterCard."Default Sust. Account".AssertEquals('');
        MachineCenterCard."Default CO2 Emission".AssertEquals(0);
        MachineCenterCard."Default CH4 Emission".AssertEquals(0);
        MachineCenterCard."Default N2O Emission".AssertEquals(0);
        MachineCenterCard.Close();
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldbeClearWhenSustAccountIsRemovedFromWorkCenter()
    var
        WorkCenter: Record "Work Center";
        SustainabilitySetup: Record "Sustainability Setup";
        WorkCenterCard: TestPage "Work Center Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be clear on "Work Center Card" page When "Default Sust. Account" is changed to blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenter(WorkCenter);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Work Center Card".
        WorkCenterCard.OpenView();
        WorkCenterCard.GoToRecord(WorkCenter);
        WorkCenterCard."Default Sust. Account".SetValue(AccountCode);
        WorkCenterCard."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));
        WorkCenterCard."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));
        WorkCenterCard."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [WHEN] Clear "Default Sust. Account".
        WorkCenterCard."Default Sust. Account".SetValue('');

        // [VERIFY] Verify Default Sust. fields should be clear on "Work Center Card" page When "Default Sust. Account" is changed to blank.
        WorkCenterCard."Default Sust. Account".AssertEquals('');
        WorkCenterCard."Default CO2 Emission".AssertEquals(0);
        WorkCenterCard."Default CH4 Emission".AssertEquals(0);
        WorkCenterCard."Default N2O Emission".AssertEquals(0);
        WorkCenterCard.Close();
    end;

    [Test]
    procedure VerifyDefaultSustAccountMustHaveAValueWhenDefaultEmissionIsUpdatedOnItem()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCard: TestPage "Item Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero on Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [WHEN] Update "Default CO2 Emission" in Item.
        asserterror ItemCard."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(ItemCard."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default CH4 Emission" in Item.
        asserterror ItemCard."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(ItemCard."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default N2O Emission" in Item.
        asserterror ItemCard."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(ItemCard."Default Sust. Account".Caption(), Format(''));
        ItemCard.Close();
    end;

    [Test]
    procedure VerifyDefaultSustAccountMustHaveAValueWhenDefaultEmissionIsUpdatedOnItemCharge()
    var
        ItemCharge: Record "Item Charge";
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCharges: TestPage "Item Charges";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero on Item Charge.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create an Item Charge.
        LibraryInventory.CreateItemCharge(ItemCharge);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Charge Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Charge Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Item Charges".
        ItemCharges.OpenView();
        ItemCharges.GoToRecord(ItemCharge);

        // [WHEN] Update "Default CO2 Emission" in Item Charge.
        asserterror ItemCharges."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(ItemCharges."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default CH4 Emission" in Item Charge.
        asserterror ItemCharges."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(ItemCharges."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default N2O Emission" in Item Charge.
        asserterror ItemCharges."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(ItemCharges."Default Sust. Account".Caption(), Format(''));
        ItemCharges.Close();
    end;

    [Test]
    procedure VerifyDefaultSustAccountMustHaveAValueWhenDefaultEmissionIsUpdatedOnResource()
    var
        Resource: Record Resource;
        SustainabilitySetup: Record "Sustainability Setup";
        ResourceCard: TestPage "Resource Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero on Resource.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResource(Resource, '');

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Resource Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Resource Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Resource Card".
        ResourceCard.OpenView();
        ResourceCard.GoToRecord(Resource);

        // [WHEN] Update "Default CO2 Emission" in Resource.
        asserterror ResourceCard."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(ResourceCard."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default CH4 Emission" in Resource.
        asserterror ResourceCard."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(ResourceCard."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default N2O Emission" in Resource.
        asserterror ResourceCard."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(ResourceCard."Default Sust. Account".Caption(), Format(''));
        ResourceCard.Close();
    end;

    [Test]
    procedure VerifyDefaultSustAccountMustHaveAValueWhenDefaultEmissionIsUpdatedOnMachineCenter()
    var
        MachineCenter: Record "Machine Center";
        SustainabilitySetup: Record "Sustainability Setup";
        MachineCenterCard: TestPage "Machine Center Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero on Machine Center.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenter(MachineCenter, '', LibraryRandom.RandDec(10, 1));

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Machine Center Card".
        MachineCenterCard.OpenView();
        MachineCenterCard.GoToRecord(MachineCenter);

        // [WHEN] Update "Default CO2 Emission" in Machine Center.
        asserterror MachineCenterCard."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(MachineCenterCard."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default CH4 Emission" in Machine Center.
        asserterror MachineCenterCard."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(MachineCenterCard."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default N2O Emission" in Machine Center.
        asserterror MachineCenterCard."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(MachineCenterCard."Default Sust. Account".Caption(), Format(''));
        MachineCenterCard.Close();
    end;

    [Test]
    procedure VerifyDefaultSustAccountMustHaveAValueWhenDefaultEmissionIsUpdatedOnWorkCenter()
    var
        WorkCenter: Record "Work Center";
        SustainabilitySetup: Record "Sustainability Setup";
        WorkCenterCard: TestPage "Work Center Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero on Work Center.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenter(WorkCenter);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Open "Work Center Card".
        WorkCenterCard.OpenView();
        WorkCenterCard.GoToRecord(WorkCenter);

        // [WHEN] Update "Default CO2 Emission" in Work Center.
        asserterror WorkCenterCard."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(WorkCenterCard."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default CH4 Emission" in Work Center.
        asserterror WorkCenterCard."Default CH4 Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(WorkCenterCard."Default Sust. Account".Caption(), Format(''));

        // [WHEN] Update "Default N2O Emission" in Work Center.
        asserterror WorkCenterCard."Default N2O Emission".SetValue(LibraryRandom.RandInt(10));

        // [VERIFY] Verify "Default Sust. Account" should throw error if it's blank When Default Emission Is non-Zero.
        Assert.ExpectedTestFieldError(WorkCenterCard."Default Sust. Account".Caption(), Format(''));
        WorkCenterCard.Close();
    end;

    [Test]
    procedure VerifyDefaultSustAccountMustBePopulateFromItemCategoryInItem()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCard: TestPage "Item Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify "Default Sust. Account" must be pouplated from Item Category in Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create an Item Category with "Default Sust. Account".
        LibraryInventory.CreateItemCategory(ItemCategory);
        ItemCategory.Validate("Default Sust. Account", AccountCode);
        ItemCategory.Modify(true);

        // [WHEN] Create an Item with Item Category.
        LibraryInventory.CreateItem(Item);
        Item.Validate("Item Category Code", ItemCategory.Code);
        Item.Modify(true);

        // [GIVEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify "Default Sust. Account" must be pouplated from Item Category in Item.
        ItemCard."Default Sust. Account".AssertEquals(AccountCode);
        ItemCard.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyDefaultEmissionFieldShouldBeClearWhenReplenishmentSystemIsNonPurchaseOnItem()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCard: TestPage "Item Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify Default Emissions field should be clear when Replenishment System is set to non-purchase on item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create an Item With Default Sust fields.
        LibraryInventory.CreateItem(Item);
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("Default CH4 Emission", LibraryRandom.RandInt(10));
        Item.Validate("Default CO2 Emission", LibraryRandom.RandInt(10));
        Item.Validate("Default N2O Emission", LibraryRandom.RandInt(10));
        Item.Modify(true);

        // [GIVEN] Save Confirmation Message.
        LibraryVariableStorage.Enqueue(StrSubstNo(ConfirmationForClearEmissionInfoQst, Item."Replenishment System"::"Prod. Order"));

        // [GIVEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [WHEN] Update "Replenishment System" to non-purchase in Item.
        ItemCard."Replenishment System".SetValue(Item."Replenishment System"::"Prod. Order");

        // [VERIFY] Verify Default Emissions field should be clear when Replenishment System is set to non-purchase on item.
        ItemCard."Default CH4 Emission".AssertEquals(0);
        ItemCard."Default CO2 Emission".AssertEquals(0);
        ItemCard."Default N2O Emission".AssertEquals(0);
        ItemCard.Close();
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldBeFlowInPurchaseLineFromItem()
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilitySetup: Record "Sustainability Setup";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify Default Sust fields should be poupulate to Purchase line from Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create an Item With Default Sust fields.
        LibraryInventory.CreateItem(Item);
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("Default CH4 Emission", LibraryRandom.RandInt(10));
        Item.Validate("Default CO2 Emission", LibraryRandom.RandInt(10));
        Item.Validate("Default N2O Emission", LibraryRandom.RandInt(10));
        Item.Modify(true);

        // [GIVEN] Create Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Insert();

        // [WHEN] Update "No." in Purchase Line.
        PurchaseLine.Validate("No.", Item."No.");
        PurchaseLine.Modify(true);

        // [VERIFY] Verify Default Sust fields should be poupulate to Purchase line from Item.
        Assert.AreEqual(
            Item."Default Sust. Account",
            PurchaseLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Sust. Account No."), Item."Default Sust. Account", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), 0, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), 0, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), 0, PurchaseLine.TableCaption()));

        // [WHEN] Update Quantity in Purchase Line.
        PurchaseLine.Validate(Quantity, LibraryRandom.RandInt(10));
        PurchaseLine.Modify(true);

        // [VERIFY] Verify Default Sust fields should be poupulate to Purchase line from Item.
        Assert.AreEqual(
            Item."Default Sust. Account",
            PurchaseLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Sust. Account No."), Item."Default Sust. Account", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            PurchaseLine.Quantity * Item."Default CH4 Emission",
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), PurchaseLine.Quantity * Item."Default CH4 Emission", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            PurchaseLine.Quantity * Item."Default CO2 Emission",
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), PurchaseLine.Quantity * Item."Default CO2 Emission", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            PurchaseLine.Quantity * Item."Default N2O Emission",
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), PurchaseLine.Quantity * Item."Default N2O Emission", PurchaseLine.TableCaption()));
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldBeFlowInPurchaseLineFromGLAccount()
    var
        GLAccount: Record "G/L Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilitySetup: Record "Sustainability Setup";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537413] Verify Default Sust fields should be poupulate to Purchase line from G/L Account.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a G/L Account With Default Sust fields.
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount.Validate("Direct Posting", true);
        GLAccount.Validate("Default Sust. Account", AccountCode);
        GLAccount.Modify(true);

        // [GIVEN] Create Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
        PurchaseLine.Insert();

        // [WHEN] Update "No." in Purchase Line.
        PurchaseLine.Validate("No.", GLAccount."No.");
        PurchaseLine.Modify(true);

        // [VERIFY] Verify Default Sust fields should be poupulate to Purchase line from Item.
        Assert.AreEqual(
            GLAccount."Default Sust. Account",
            PurchaseLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Sust. Account No."), GLAccount."Default Sust. Account", PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), 0, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), 0, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Emission CH4"), 0, PurchaseLine.TableCaption()));
    end;

    local procedure CreateSustainabilityAccount(var AccountCode: Code[20]; var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer): Record "Sustainability Account"
    begin
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, i);
        AccountCode := StrSubstNo(AccountCodeLbl, i);
        exit(LibrarySustainability.InsertSustainabilityAccount(
            AccountCode, '', CategoryCode, SubcategoryCode, Enum::"Sustainability Account Type"::Posting, '', true));
    end;

    local procedure CreateSustainabilitySubcategory(var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        CreateSustainabilityCategory(CategoryCode, i);

        SubcategoryCode := StrSubstNo(SubcategoryCodeLbl, i);
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, 1, 2, 3, false);
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(
            CategoryCode, CategoryCode, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity",
            true, true, true, '', false);
    end;

    local procedure UpdateReasonCodeinPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    var
        ReasonCode: Record "Reason Code";
    begin
        LibraryERM.CreateReasonCode(ReasonCode);

        PurchaseHeader.Validate("Reason Code", ReasonCode.Code);
        PurchaseHeader.Modify();
    end;

    local procedure PostAndVerifyCancelCreditMemo(PurchaseHeader: Record "Purchase Header")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvHeader.Get(PostedDocNumber);
        CorrectPostedPurchInvoice.CancelPostedInvoice(PurchInvHeader);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := true;
    end;
}