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
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySustainability: Codeunit "Library - Sustainability";
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        FieldShouldBeVisibleErr: Label '%1 should be visible in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldNotBeVisibleErr: Label '%1 should not be visible in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldNotBeEnabledErr: Label '%1 should not be enabled in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldBeEnabledErr: Label '%1 should be enabled in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';

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
    procedure VerifySustainabilityFieldsShouldBeVisibleInItemCard()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
        ItemCard: TestPage "Item Card";
    begin
        // [SCENARIO 496566] Verify Sustainability Fields should be visible in Item Card.
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

        // [GIVEN] Update "Type" and "Sust. Cert. No." in an Item.
        Item.Validate(Type, Item.Type::Inventory);
        Item.Validate("Sust. Cert. No.", SustainabilityCertificate."No.");
        Item.Modify();

        // [WHEN] Open Item Card.
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify Sustainability fields should be visible in an Item Card.
        Assert.AreEqual(
            true,
            ItemCard."Sust. Cert. No.".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, Item.FieldCaption("Sust. Cert. No."), Item.TableCaption()));
        Assert.AreEqual(
            true,
            ItemCard."Sust. Cert. Name".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, Item.FieldCaption("Sust. Cert. Name"), Item.TableCaption()));
        Assert.AreEqual(
            true,
            ItemCard."GHG Credit".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, Item.FieldCaption("GHG Credit"), Item.TableCaption()));
        Assert.AreEqual(
            true,
            ItemCard."Carbon Credit Per UOM".Visible(),
            StrSubstNo(FieldShouldBeVisibleErr, Item.FieldCaption("Carbon Credit Per UOM"), Item.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldNotBeVisibleforTypeNonInventoryInItemCard()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
        ItemCard: TestPage "Item Card";
    begin
        // [SCENARIO 496566] Verify Sustainability Fields should not be visible for Type "Non-Inventory" in Item Card.
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

        // [GIVEN] Update "Type" and "Sust. Cert. No." in an Item.
        Item.Validate(Type, Item.Type::"Non-Inventory");
        Item.Modify();

        // [WHEN] Open Item Card.
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify Sustainability fields should be not visible for Type "Non-Inventory" in an Item Card.
        Assert.AreEqual(
            false,
            ItemCard."Sust. Cert. No.".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, Item.FieldCaption("Sust. Cert. No."), Item.TableCaption()));
        Assert.AreEqual(
            false,
            ItemCard."Sust. Cert. Name".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, Item.FieldCaption("Sust. Cert. Name"), Item.TableCaption()));
        Assert.AreEqual(
            false,
            ItemCard."GHG Credit".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, Item.FieldCaption("GHG Credit"), Item.TableCaption()));
        Assert.AreEqual(
            false,
            ItemCard."Carbon Credit Per UOM".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, Item.FieldCaption("Carbon Credit Per UOM"), Item.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldNotBeVisibleforTypeServiceInItemCard()
    var
        Item: Record Item;
        SustCertificateArea: Record "Sust. Certificate Area";
        SustCertificateStandard: Record "Sust. Certificate Standard";
        SustainabilityCertificate: Record "Sustainability Certificate";
        ItemCard: TestPage "Item Card";
    begin
        // [SCENARIO 496566] Verify Sustainability Fields should not be visible for Type "Service" in Item Card.
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

        // [GIVEN] Update "Type" and "Sust. Cert. No." in an Item.
        Item.Validate(Type, Item.Type::Service);
        Item.Modify();

        // [WHEN] Open Item Card.
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify Sustainability fields should be not visible for Type "Service" in an Item Card.
        Assert.AreEqual(
            false,
            ItemCard."Sust. Cert. No.".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, Item.FieldCaption("Sust. Cert. No."), Item.TableCaption()));
        Assert.AreEqual(
            false,
            ItemCard."Sust. Cert. Name".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, Item.FieldCaption("Sust. Cert. Name"), Item.TableCaption()));
        Assert.AreEqual(
            false,
            ItemCard."GHG Credit".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, Item.FieldCaption("GHG Credit"), Item.TableCaption()));
        Assert.AreEqual(
            false,
            ItemCard."Carbon Credit Per UOM".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, Item.FieldCaption("Carbon Credit Per UOM"), Item.TableCaption()));
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
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
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

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

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

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger Entry should be created When "GHG Credit" is enabled in Item.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvNo);
        Assert.RecordCount(SustainabilityLedgerEntry, 2);

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
            -(PurchaseLine.Quantity * Item."Carbon Credit Per UOM"),
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(
                ValueMustBeEqualErr,
                SustainabilityLedgerEntry.FieldCaption("Emission CO2"),
                -(PurchaseLine.Quantity * Item."Carbon Credit Per UOM"),
                SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -PurchaseLine."Line Amount",
            SustainabilityLedgerEntry."Emission Fee",
            StrSubstNo(
                ValueMustBeEqualErr,
                SustainabilityLedgerEntry.FieldCaption("Emission Fee"),
                -PurchaseLine."Line Amount",
                SustainabilityLedgerEntry.TableCaption()));

        SustainabilityLedgerEntry.Reset();
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvNo);
        SustainabilityLedgerEntry.SetRange("Document Type", SustainabilityLedgerEntry."Document Type"::Invoice);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2PerUnit,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2PerUnit, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4PerUnit,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCO2PerUnit, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2OPerUnit,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2OPerUnit, SustainabilityLedgerEntry.TableCaption()));
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
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
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

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            Item."No.",
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Post a Purchase Document.
        PostAndVerifyCancelCreditMemo(PurchaseHeader);

        // [VERIFY] Verify Sustainability Ledger entry should be Kocked Off when the Cancel Credit Memo is posted If "GHG Credit" is enabled in Item.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O", "Emission Fee");
        Assert.RecordCount(SustainabilityLedgerEntry, 4);
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission Fee"), 0, SustainabilityLedgerEntry.TableCaption()));
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

    local procedure CreateAndPostPurchaseOrderWithSustAccount(AccountCode: Code[20]; PostingDate: Date; ItemNo: Code[20]; EmissionCO2PerUnit: Decimal; EmissionCH4PerUnit: Decimal; EmissionN2OPerUnit: Decimal): Code[2]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify();

        // Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            ItemNo,
            LibraryRandom.RandInt(10));

        // Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // Post a Purchase Document.
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
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
}