namespace Microsoft.Test.Sustainability;

using System.TestLibraries.Utilities;
using Microsoft.Sustainability.Certificate;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Ledger;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sustainability.Setup;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Assembly.Document;
using Microsoft.Assembly.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Journal;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Inventory.Journal;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.History;
using Microsoft.Inventory.BOM;
using Microsoft.Assembly.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Planning;

codeunit 148187 "Sust. Certificate Test"
{
    Subtype = Test;
    TestType = Uncategorized;
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
        LibraryAssembly: Codeunit "Library - Assembly";
        LibrarySales: Codeunit "Library - Sales";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryJob: Codeunit "Library - Job";
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        FieldShouldNotBeEnabledErr: Label '%1 should not be enabled in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldBeEnabledErr: Label '%1 should be enabled in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldBeVisibleErr: Label '%1 should be visible in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldNotBeVisibleErr: Label '%1 should not be visible in Page %2', Comment = '%1 = Field Caption , %2 = Page Caption';
        ConfirmationForClearEmissionInfoQst: Label 'Changing the Replenishment System to %1 will clear sustainability emission value. Do you want to continue?', Comment = '%1 = Replenishment System';
        ActionShouldNotBeVisibleErr: Label 'Calculate CO2e action should not be visible in Page %1', Comment = '%1 = Page Caption';
        ActionShouldBeVisibleErr: Label 'Calculate CO2e action should be visible in Page %1', Comment = '%1 = Page Caption';
        SustLedgerEntryShouldNotBeFoundErr: Label 'Sustainability Ledger Entry should not be found';
        SustValueEntryShouldNotBeFoundErr: Label 'Sustainability Value Entry should not be found';
        SustLdgEntriesActionShouldBeVisibleErr: Label 'Sustainability Ledger Entries action should be visible in Page %1', Comment = '%1 = Page Caption';
        SustValueEntriesActionShouldBeVisibleErr: Label 'Sustainability Value Entries action should be visible in Page %1', Comment = '%1 = Page Caption';
        SustLdgEntriesActionShouldNotBeVisibleErr: Label 'Sustainability Ledger Entries action should not be visible in Page %1', Comment = '%1 = Page Caption';
        SustValueEntriesActionShouldNotBeVisibleErr: Label 'Sustainability Value Entries action should not be visible in Page %1', Comment = '%1 = Page Caption';
        CalculateTotalCO2eActionShouldNotBeVisibleErr: Label 'Calculate Total CO2e action should not be visible in Page %1', Comment = '%1 = Page Caption';
        CalculateTotalCO2eActionShouldBeVisibleErr: Label 'Calculate Total CO2e action should be visible in Page %1', Comment = '%1 = Page Caption';

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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
    procedure VerifyCalculateCO2eShouldbeVisibleOnItemCardIfItemEmissionsIsEnabled()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCard: TestPage "Item Card";
    begin
        // [SCENARIO 560219] Verify "Calculate CO2e" action should be visible on "Item Card" page If "Item Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [WHEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify "Calculate CO2e" action should not be visible on "Item Card" page If "Item Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ItemCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ItemCard.Caption()));

        // [GIVEN] Close "Item Card".
        ItemCard.Close();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify "Calculate CO2e" action should be visible on "Item Card" page If "Item Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            ItemCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldBeVisibleErr, ItemCard.Caption()));
    end;

    [Test]
    procedure VerifyCalculateCO2eShouldbeVisibleOnItemListIfItemEmissionsIsEnabled()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ItemList: TestPage "Item List";
    begin
        // [SCENARIO 560219] Verify "Calculate CO2e" action should be visible on "Item List" page If "Item Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [WHEN] Open "Item List".
        ItemList.OpenView();
        ItemList.GoToRecord(Item);

        // [VERIFY] Verify "Calculate CO2e" action should not be visible on "Item List" page If "Item Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ItemList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ItemList.Caption()));

        // [GIVEN] Close "Item List".
        ItemList.Close();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Item List".
        ItemList.OpenView();
        ItemList.GoToRecord(Item);

        // [VERIFY] Verify "Calculate CO2e" action should be visible on "Item List" page If "Item Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            ItemList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldBeVisibleErr, ItemList.Caption()));
    end;

    [Test]
    procedure VerifyCalculateCO2eShouldbeVisibleOnProductionBOMCardIfItemEmissionsIsEnabled()
    var
        CompItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        SustainabilitySetup: Record "Sustainability Setup";
        ProductionBOM: TestPage "Production BOM";
    begin
        // [SCENARIO 560219] Verify "Calculate CO2e" action should be visible on "Production BOM" page If "Item Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(CompItem);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [WHEN] Open "Production BOM".
        ProductionBOM.OpenView();
        ProductionBOM.GoToRecord(ProductionBOMHeader);

        // [VERIFY] Verify "Calculate CO2e" action should not be visible on "Production BOM" page If "Item Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ProductionBOM."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ProductionBOM.Caption()));

        // [GIVEN] Close "Production BOM".
        ProductionBOM.Close();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Production BOM".
        ProductionBOM.OpenView();
        ProductionBOM.GoToRecord(ProductionBOMHeader);

        // [VERIFY] Verify "Calculate CO2e" action should be visible on "Production BOM" page If "Item Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            ProductionBOM."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldBeVisibleErr, ProductionBOM.Caption()));
    end;

    [Test]
    procedure VerifyCalculateCO2eShouldbeVisibleOnProductionBOMListIfItemEmissionsIsEnabled()
    var
        CompItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        SustainabilitySetup: Record "Sustainability Setup";
        ProductionBOMList: TestPage "Production BOM List";
    begin
        // [SCENARIO 560219] Verify "Calculate CO2e" action should be visible on "Production BOM List" page If "Item Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(CompItem);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [WHEN] Open "Production BOM List".
        ProductionBOMList.OpenView();
        ProductionBOMList.GoToRecord(ProductionBOMHeader);

        // [VERIFY] Verify "Calculate CO2e" action should not be visible on "Production BOM List" page If "Item Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ProductionBOMList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ProductionBOMList.Caption()));

        // [GIVEN] Close "Production BOM List".
        ProductionBOMList.Close();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Production BOM List".
        ProductionBOMList.OpenView();
        ProductionBOMList.GoToRecord(ProductionBOMHeader);

        // [VERIFY] Verify "Calculate CO2e" action should be visible on "Production BOM List" page If "Item Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            ProductionBOMList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldBeVisibleErr, ProductionBOMList.Caption()));
    end;

    [Test]
    procedure VerifyCO2ePerUnitShouldbeVisibleOnProductionBOMLinesIfItemEmissionsIsEnabled()
    var
        CompItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMLine: Record "Production BOM Line";
        SustainabilitySetup: Record "Sustainability Setup";
        ProductionBOMLines: TestPage "Production BOM Lines";
    begin
        // [SCENARIO 560219] Verify "CO2e per Unit" field should be visible on "Production BOM Lines" page If "Item Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(CompItem);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [GIVEN] Find Production BOM Line.
        ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMHeader."No.");
        ProductionBOMLine.FindFirst();

        // [WHEN] Open "Production BOM Lines".
        ProductionBOMLines.OpenView();
        ProductionBOMLines.GoToRecord(ProductionBOMLine);

        // [VERIFY] Verify "CO2e per Unit" field should not be visible on "Production BOM Lines" page If "Item Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ProductionBOMLines."CO2e per Unit".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ProductionBOMLines."CO2e per Unit".Caption(), ProductionBOMLines.Caption()));

        // [GIVEN] Close "Production BOM Lines".
        ProductionBOMLines.Close();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Production BOM Lines".
        ProductionBOMLines.OpenView();
        ProductionBOMLines.GoToRecord(ProductionBOMLine);

        // [VERIFY] Verify "CO2e per Unit" field should be visible on "Production BOM Lines" page If "Item Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            ProductionBOMLines."CO2e per Unit".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, ProductionBOMLines."CO2e per Unit".Caption(), ProductionBOMLines.Caption()));
    end;

    [Test]
    procedure VerifyCO2ePerUnitShouldbeVisibleOnRoutingLinesIfWorkMachineCenterEmissionsIsEnabled()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        WorkCenter: Record "Work Center";
        SustainabilitySetup: Record "Sustainability Setup";
        RoutingLines: TestPage "Routing Lines";
    begin
        // [SCENARIO 560219] Verify "CO2e per Unit" field should be visible on "Routing Lines" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, 0));

        // [GIVEN] Find Routing Line.
        RoutingLine.SetRange("Routing No.", RoutingHeader."No.");
        RoutingLine.FindFirst();

        // [WHEN] Open "Routing Lines".
        RoutingLines.OpenView();
        RoutingLines.GoToRecord(RoutingLine);

        // [VERIFY] Verify "CO2e per Unit" field should not be visible on "Routing Lines" page If "Work/Machine Center Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            RoutingLines."CO2e per Unit".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, RoutingLines."CO2e per Unit".Caption(), RoutingLines.Caption()));

        // [GIVEN] Close "Routing Lines".
        RoutingLines.Close();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Routing Lines".
        RoutingLines.OpenView();
        RoutingLines.GoToRecord(RoutingLine);

        // [VERIFY] Verify "CO2e per Unit" field should be visible on "Routing Lines" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            RoutingLines."CO2e per Unit".Visible(),
            StrSubstNo(FieldShouldNotBeVisibleErr, RoutingLines."CO2e per Unit".Caption(), RoutingLines.Caption()));
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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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
    procedure VerifyDefaultSustFieldShouldBeVisibleOnMachineCenterCardIfWorkMachineCenterEmissionsIsEnabled()
    var
        MachineCenter: Record "Machine Center";
        SustainabilitySetup: Record "Sustainability Setup";
        MachineCenterCard: TestPage "Machine Center Card";
    begin
        // [SCENARIO 537413] Verify Default Sust. fields should be visible on "Machine Center Card" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Modify(true);

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
    procedure VerifyCalculateCO2eShouldbeVisibleOnMachineCenterCardIfWorkMachineCenterEmissionsIsEnabled()
    var
        MachineCenter: Record "Machine Center";
        SustainabilitySetup: Record "Sustainability Setup";
        MachineCenterCard: TestPage "Machine Center Card";
    begin
        // [SCENARIO 537413] Verify "Calculate CO2e" action should be visible on "Machine Center Card" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenter(MachineCenter, '', LibraryRandom.RandDec(10, 1));

        // [WHEN] Open "Machine Center Card".
        MachineCenterCard.OpenView();
        MachineCenterCard.GoToRecord(MachineCenter);

        // [VERIFY] Verify "Calculate CO2e" action should not be visible on "Machine Center Card" page If "Work/Machine Center Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            MachineCenterCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, MachineCenterCard.Caption()));

        // [GIVEN] Close "Machine Center Card".
        MachineCenterCard.Close();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Machine Center Card".
        MachineCenterCard.OpenView();
        MachineCenterCard.GoToRecord(MachineCenter);

        // [VERIFY] Verify "Calculate CO2e" action should be visible on "Machine Center Card" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            MachineCenterCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldBeVisibleErr, MachineCenterCard.Caption()));
    end;

    [Test]
    procedure VerifyCalculateCO2eShouldbeVisibleOnMachineCenterListIfWorkMachineCenterEmissionsIsEnabled()
    var
        MachineCenter: Record "Machine Center";
        SustainabilitySetup: Record "Sustainability Setup";
        MachineCenterList: TestPage "Machine Center List";
    begin
        // [SCENARIO 537413] Verify "Calculate CO2e" action should be visible on "Machine Center List" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenter(MachineCenter, '', LibraryRandom.RandDec(10, 1));

        // [WHEN] Open "Machine Center List".
        MachineCenterList.OpenView();
        MachineCenterList.GoToRecord(MachineCenter);

        // [VERIFY] Verify "Calculate CO2e" action should not be visible on "Machine Center List" page If "Work/Machine Center Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            MachineCenterList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, MachineCenterList.Caption()));

        // [GIVEN] Close "Machine Center List".
        MachineCenterList.Close();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Machine Center List".
        MachineCenterList.OpenView();
        MachineCenterList.GoToRecord(MachineCenter);

        // [VERIFY] Verify "Calculate CO2e" action should be visible on "Machine Center List" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            MachineCenterList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldBeVisibleErr, MachineCenterList.Caption()));
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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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
    procedure VerifyCalculateCO2eShouldbeVisibleOnWorkCenterCardIfWorkMachineCenterEmissionsIsEnabled()
    var
        WorkCenter: Record "Work Center";
        SustainabilitySetup: Record "Sustainability Setup";
        WorkCenterCard: TestPage "Work Center Card";
    begin
        // [SCENARIO 537413] Verify "Calculate CO2e" action should be visible on "Work Center Card" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [VERIFY] Verify "Calculate CO2e" action should not be visible on "Work Center Card" page If "Work/Machine Center Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            WorkCenterCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, WorkCenterCard.Caption()));

        // [GIVEN] Close "Work Center Card".
        WorkCenterCard.Close();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Work Center Card".
        WorkCenterCard.OpenView();
        WorkCenterCard.GoToRecord(WorkCenter);

        // [VERIFY] Verify "Calculate CO2e" action should be visible on "Work Center Card" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            WorkCenterCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldBeVisibleErr, WorkCenterCard.Caption()));
    end;

    [Test]
    procedure VerifyCalculateCO2eShouldbeVisibleOnWorkCenterListIfWorkMachineCenterEmissionsIsEnabled()
    var
        WorkCenter: Record "Work Center";
        SustainabilitySetup: Record "Sustainability Setup";
        WorkCenterList: TestPage "Work Center List";
    begin
        // [SCENARIO 537413] Verify "Calculate CO2e" action should be visible on "Work Center List" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenter(WorkCenter);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Work Center List".
        WorkCenterList.OpenView();
        WorkCenterList.GoToRecord(WorkCenter);

        // [VERIFY] Verify "Calculate CO2e" action should not be visible on "Work Center List" page If "Work/Machine Center Emissions" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            WorkCenterList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, WorkCenterList.Caption()));

        // [GIVEN] Close "Work Center List".
        WorkCenterList.Close();

        // [GIVEN] Update "Work/Machine Center Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Work Center List".
        WorkCenterList.OpenView();
        WorkCenterList.GoToRecord(WorkCenter);

        // [VERIFY] Verify "Calculate CO2e" action should be visible on "Work Center List" page If "Work/Machine Center Emissions" is enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            WorkCenterList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldBeVisibleErr, WorkCenterList.Caption()));
    end;

    [Test]
    procedure VerifyDefaultSustFieldShouldBeClearWhenSustAccountIsRemovedFromItem()
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

    [Test]
    procedure VerifySustFieldsAreVisibleOnAssemblyOrderAndPostedAssemblyOrderIfEnableValueChainTrackingIsTrue()
    var
        AssemblyHeader: Record "Assembly Header";
        CompItem: Record Item;
        ParentItem: Record Item;
        PostedAssemblyHeader: Record "Posted Assembly Header";
        AssemblyOrder: TestPage "Assembly Order";
        PostedAssemblyOrder: TestPage "Posted Assembly Order";
        AccountCode: array[2] of Code[20];
        CategoryCode: Code[20];
        CO2ePerUnit: array[2] of Decimal;
        SubcategoryCode: Code[20];
        Quantity: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are Visible on Assembly Order,
        // Lines of Assembly Order, Posted Assembly Order and Lines of Posted Assembly Order
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate Random "CO2e Per Unit" and Quantity.
        CO2ePerUnit[1] := LibraryRandom.RandIntInRange(10, 10);
        CO2ePerUnit[2] := LibraryRandom.RandIntInRange(20, 20);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Assembly Item.
        CreateAssembledItem(ParentItem, "Assembly Policy"::"Assemble-to-Order", 1, 1);
        ParentItem.Validate("Default Sust. Account", AccountCode[1]);
        ParentItem.Validate("CO2e per Unit", CO2ePerUnit[1]);
        ParentItem.Modify(true);

        // [GIVEN] Create Sustainability Account and update Sustainability Account No., "CO2e per unit" in Component item.
        CreateAndUpdateSustAccOnCompItem(ParentItem, CompItem, AccountCode[2], CO2ePerUnit[2]);

        // [GIVEN] Increase Inventory of an Item.
        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));

        // [GIVEN] Create Assembly Header.
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ParentItem."No.", '', Quantity, '');

        // [WHEN] Open Assembly Order.
        AssemblyOrder.OpenEdit();
        AssemblyOrder.GoToRecord(AssemblyHeader);

        // [THEN] Sust. Account No. is Visible on Assembly Order.
        Assert.IsTrue(
            AssemblyOrder."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                AssemblyOrder."Sust. Account No.".Caption(),
                AssemblyOrder.Caption()));

        // [THEN] CO2e per Unit is Visible on Assembly Order.
        Assert.IsTrue(
            AssemblyOrder."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                AssemblyOrder."CO2e per Unit".Caption(),
                AssemblyOrder.Caption()));

        // [THEN] Total CO2e is Visible on Assembly Order.
        Assert.IsTrue(
            AssemblyOrder."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                AssemblyOrder."Total CO2e".Caption(),
                AssemblyOrder.Caption()));

        // [THEN] Sust. Account No. is Visible on Lines of Assembly Order.
        Assert.IsTrue(
            AssemblyOrder.Lines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                AssemblyOrder.Lines."Sust. Account No.".Caption(),
                AssemblyOrder.Lines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Assembly Order.
        Assert.IsTrue(
            AssemblyOrder.Lines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                AssemblyOrder.Lines."Total CO2e".Caption(),
                AssemblyOrder.Lines.Caption()));

        // [GIVEN] Post Assembly Header.
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');

        // [GIVEN] Get Posted Assembly Header.
        GetPostedAssemblyHeader(PostedAssemblyHeader, ParentItem."No.");

        // [WHEN] Open Posted Assembly Order.
        PostedAssemblyOrder.OpenEdit();
        PostedAssemblyOrder.GoToRecord(PostedAssemblyHeader);

        // [THEN] Sust. Account No. is Visible on Posted Assembly Order.
        Assert.IsTrue(
            PostedAssemblyOrder."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedAssemblyOrder."Sust. Account No.".Caption(),
                PostedAssemblyOrder.Caption()));

        // [THEN] O2e per Unit is Visible on Posted Assembly Order.
        Assert.IsTrue(
            PostedAssemblyOrder."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedAssemblyOrder."CO2e per Unit".Caption(),
                PostedAssemblyOrder.Caption()));

        // [THEN] Total CO2e is Visible on Posted Assembly Order.
        Assert.IsTrue(
            PostedAssemblyOrder."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedAssemblyOrder."Total CO2e".Caption(),
                PostedAssemblyOrder.Caption()));

        // [THEN] Sust. Account No. is Visible on Lines of Posted Assembly Order.
        Assert.IsTrue(
            PostedAssemblyOrder.Lines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedAssemblyOrder.Lines."Sust. Account No.".Caption(),
                PostedAssemblyOrder.Lines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Posted Assembly Order.
        Assert.IsTrue(
            PostedAssemblyOrder.Lines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedAssemblyOrder.Lines."Total CO2e".Caption(),
                PostedAssemblyOrder.Lines.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnAOAndPAOAndSustEntriesAreNotCreatedIfEnableValueChainTrackingIsFalse()
    var
        AssemblyHeader: Record "Assembly Header";
        CompItem: Record Item;
        ParentItem: Record Item;
        PostedAssemblyHeader: Record "Posted Assembly Header";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        AssemblyOrder: TestPage "Assembly Order";
        PostedAssemblyOrder: TestPage "Posted Assembly Order";
        AccountCode: array[2] of Code[20];
        CategoryCode: Code[20];
        CO2ePerUnit: array[2] of Decimal;
        SubcategoryCode: Code[20];
        Quantity: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are not Visible on Assembly Order,
        // Lines of Assembly Order, Posted Assembly Order and Lines of Posted Assembly Order
        // and no Sustainability Ledger Entry or Sustainability Value Entry is created
        // if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate Random "CO2e Per Unit" and Quantity.
        CO2ePerUnit[1] := LibraryRandom.RandIntInRange(10, 10);
        CO2ePerUnit[2] := LibraryRandom.RandIntInRange(20, 20);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Assembly Item.
        CreateAssembledItem(ParentItem, "Assembly Policy"::"Assemble-to-Order", 1, 1);
        ParentItem.Validate("Default Sust. Account", AccountCode[1]);
        ParentItem.Validate("CO2e per Unit", CO2ePerUnit[1]);
        ParentItem.Modify(true);

        // [GIVEN] Create Sustainability Account and update Sustainability Account No., "CO2e per unit" in Component item.
        CreateAndUpdateSustAccOnCompItem(ParentItem, CompItem, AccountCode[2], CO2ePerUnit[2]);

        // [GIVEN] Increase Inventory of an Item.
        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));

        // [GIVEN] Create Assembly Header.
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ParentItem."No.", '', Quantity, '');

        // [WHEN] Open Assembly Order.
        AssemblyOrder.OpenEdit();
        AssemblyOrder.GoToRecord(AssemblyHeader);

        // [THEN] Sust. Account No. is not Visible on Assembly Order.
        Assert.IsFalse(
            AssemblyOrder."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                AssemblyOrder."Sust. Account No.".Caption(),
                AssemblyOrder.Caption()));

        // [THEN] CO2e per Unit is not Visible on Assembly Order.
        Assert.IsFalse(
            AssemblyOrder."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                AssemblyOrder."CO2e per Unit".Caption(),
                AssemblyOrder.Caption()));

        // [THEN] Total CO2e is not Visible on Assembly Order.
        Assert.IsFalse(
            AssemblyOrder."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                AssemblyOrder."Total CO2e".Caption(),
                AssemblyOrder.Caption()));

        // [THEN] Sust. Account No. is not Visible on Lines of Assembly Order.
        Assert.IsFalse(
            AssemblyOrder.Lines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                AssemblyOrder.Lines."Sust. Account No.".Caption(),
                AssemblyOrder.Lines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Assembly Order.
        Assert.IsFalse(
            AssemblyOrder.Lines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                AssemblyOrder.Lines."Total CO2e".Caption(),
                AssemblyOrder.Lines.Caption()));

        // [GIVEN] Post Assembly Header.
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');

        // [GIVEN] Get Posted Assembly Header.
        GetPostedAssemblyHeader(PostedAssemblyHeader, ParentItem."No.");

        // [WHEN] Open Posted Assembly Order.
        PostedAssemblyOrder.OpenEdit();
        PostedAssemblyOrder.GoToRecord(PostedAssemblyHeader);

        // [THEN] Sust. Account No. is not Visible on Posted Assembly Order.
        Assert.IsFalse(
            PostedAssemblyOrder."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedAssemblyOrder."Sust. Account No.".Caption(),
                PostedAssemblyOrder.Caption()));

        // [THEN] O2e per Unit is not Visible on Posted Assembly Order.
        Assert.IsFalse(
            PostedAssemblyOrder."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedAssemblyOrder."CO2e per Unit".Caption(),
                PostedAssemblyOrder.Caption()));

        // [THEN] Total CO2e is not Visible on Posted Assembly Order.
        Assert.IsFalse(
            PostedAssemblyOrder."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedAssemblyOrder."Total CO2e".Caption(),
                PostedAssemblyOrder.Caption()));

        // [THEN] Sust. Account No. is not Visible on Lines of Posted Assembly Order.
        Assert.IsFalse(
            PostedAssemblyOrder.Lines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedAssemblyOrder.Lines."Sust. Account No.".Caption(),
                PostedAssemblyOrder.Lines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Posted Assembly Order.
        Assert.IsFalse(
            PostedAssemblyOrder.Lines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedAssemblyOrder.Lines."Total CO2e".Caption(),
                PostedAssemblyOrder.Lines.Caption()));

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedAssemblyHeader."No.");

        // [THEN] Sustainability Ledger Entry is not found.
        Assert.IsTrue(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", ParentItem."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnSalesOrderIsEnableValueChainTrackingIsTrue()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesOrder: TestPage "Sales Order";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are Visible on Sales Order and Lines of Sales Order
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Open Sales Order.
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);

        // [THEN] Sust. Account No. is Visible on Lines of Sales Order.
        Assert.IsTrue(
            SalesOrder.SalesLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                SalesOrder.SalesLines."Sust. Account No.".Caption(),
                SalesOrder.SalesLines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Sales Order.
        Assert.IsTrue(
            SalesOrder.SalesLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                SalesOrder.SalesLines."Total CO2e".Caption(),
                SalesOrder.SalesLines.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnSalesOrderIfEnableValueChainTrackingIsFalse()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SalesOrder: TestPage "Sales Order";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        TotalCO2e: Decimal;
        PostedDocNo: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are not Visible on Sales Order and Lines of Sales Order
        // and no Sustainability Ledger Entry or Sustainability Value Entry is created
        // if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify(true);

        // [WHEN] Open Sales Order.
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);

        // [THEN] Sust. Account No. is not Visible on Lines of Sales Order.
        Assert.IsFalse(
            SalesOrder.SalesLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                SalesOrder.SalesLines."Sust. Account No.".Caption(),
                SalesOrder.SalesLines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Sales Order.
        Assert.IsFalse(
            SalesOrder.SalesLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                SalesOrder.SalesLines."Total CO2e".Caption(),
                SalesOrder.SalesLines.Caption()));

        // [GIVEN] Post a Sales Document.
        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedDocNo);

        // [THEN] Sustainability Ledger Entry is not found.
        Assert.IsTrue(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", SalesLine."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnSalesReturnOrderIfEnableValueTrackingIsTrue()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesReturnOrder: TestPage "Sales Return Order";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are Visible on Sales Return Order and Lines of Sales Return Order
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::"Return Order", LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Open Sales Return Order.
        SalesReturnOrder.OpenEdit();
        SalesReturnOrder.GoToRecord(SalesHeader);

        // [THEN] Sust. Account No. is Visible on Lines of Sales Return Order.
        Assert.IsTrue(
            SalesReturnOrder.SalesLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                SalesReturnOrder.SalesLines."Sust. Account No.".Caption(),
                SalesReturnOrder.SalesLines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Sales Return Order.
        Assert.IsTrue(
            SalesReturnOrder.SalesLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                SalesReturnOrder.SalesLines."Total CO2e".Caption(),
                SalesReturnOrder.SalesLines.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnSalesReturnOrderIfEnableValueTrackingIsFalse()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SalesReturnOrder: TestPage "Sales Return Order";
        AccountCode: Code[20];
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        PostedDocNo: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are not Visible on Sales Return Order and Lines of
        // Sales Return Order and no Sustainability Ledger Entry or Sustainability Value Entry is created
        // if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::"Return Order", LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify(true);

        // [WHEN] Open Sales Return Order.
        SalesReturnOrder.OpenEdit();
        SalesReturnOrder.GoToRecord(SalesHeader);

        // [THEN] Sust. Account No. is not Visible on Lines of Sales Return Order.
        Assert.IsFalse(
            SalesReturnOrder.SalesLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                SalesReturnOrder.SalesLines."Sust. Account No.".Caption(),
                SalesReturnOrder.SalesLines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Sales Return Order.
        Assert.IsFalse(
            SalesReturnOrder.SalesLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                SalesReturnOrder.SalesLines."Total CO2e".Caption(),
                SalesReturnOrder.SalesLines.Caption()));

        // [GIVEN] Post a Sales Document.
        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedDocNo);

        // [THEN] Sustainability Ledger Entry is not found.
        Assert.IsTrue(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", SalesLine."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnSalesInvoiceAndPostedSalesInvoiceIfEnableValueTrackingIsTrue()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedSalesInvoice: TestPage "Posted Sales Invoice";
        SalesInvoice: TestPage "Sales Invoice";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        PostedInvoiceNo: Code[20];
        SubcategoryCode: Code[20];
        TotalCO2e: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are Visible on Sales Invoice, Lines of Sales Invoice,
        // Posted Sales Invoice and Lines of Posted Sales Invoice if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Invoice, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify(true);

        // [WHEN] Open Sales Invoice.
        SalesInvoice.OpenEdit();
        SalesInvoice.GoToRecord(SalesHeader);

        // [THEN] Sust. Account No. is Visible on Lines of Sales Invoice.
        Assert.IsTrue(
            SalesInvoice.SalesLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                SalesInvoice.SalesLines."Sust. Account No.".Caption(),
                SalesInvoice.SalesLines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Sales Invoice.
        Assert.IsTrue(
            SalesInvoice.SalesLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                SalesInvoice.SalesLines."Total CO2e".Caption(),
                SalesInvoice.SalesLines.Caption()));

        // [GIVEN] Post a Sales Document.
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [GIVEN] Find Sales Invoice Header.
        SalesInvoiceHeader.SetRange("No.", PostedInvoiceNo);
        SalesInvoiceHeader.FindFirst();

        // [WHEN] Open Posted Sales Invoice.
        PostedSalesInvoice.OpenEdit();
        PostedSalesInvoice.GoToRecord(SalesInvoiceHeader);

        // [THEN] Sust. Account No. is Visible on Lines of Posted Sales Invoice.
        Assert.IsTrue(
            PostedSalesInvoice.SalesInvLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedSalesInvoice.SalesInvLines."Sust. Account No.".Caption(),
                PostedSalesInvoice.SalesInvLines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Posted Sales Invoice.
        Assert.IsTrue(
            PostedSalesInvoice.SalesInvLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedSalesInvoice.SalesInvLines."Total CO2e".Caption(),
                PostedSalesInvoice.SalesInvLines.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnSalesInvoiceAndPostedSalesInvoiceIfEnableValueTrackingIsFalse()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        PostedSalesInvoice: TestPage "Posted Sales Invoice";
        SalesInvoice: TestPage "Sales Invoice";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        PostedInvoiceNo: Code[20];
        SubcategoryCode: Code[20];
        TotalCO2e: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are not Visible on Sales Invoice, Lines of Sales Invoice,
        // Posted Sales Invoice and Lines of Posted Sales Invoice and no Sustainability Ledger Entry
        // or Sustainability Value Entry is created if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Invoice, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify(true);

        // [WHEN] Open Sales Invoice.
        SalesInvoice.OpenEdit();
        SalesInvoice.GoToRecord(SalesHeader);

        // [THEN] Sust. Account No. is not Visible on Lines of Sales Invoice.
        Assert.IsFalse(
            SalesInvoice.SalesLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                SalesInvoice.SalesLines."Sust. Account No.".Caption(),
                SalesInvoice.SalesLines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Sales Invoice.
        Assert.IsFalse(
            SalesInvoice.SalesLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                SalesInvoice.SalesLines."Total CO2e".Caption(),
                SalesInvoice.SalesLines.Caption()));

        // [GIVEN] Post a Sales Document.
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [GIVEN] Find Sales Invoice Header.
        SalesInvoiceHeader.SetRange("No.", PostedInvoiceNo);
        SalesInvoiceHeader.FindFirst();

        // [WHEN] Open Posted Sales Invoice.
        PostedSalesInvoice.OpenEdit();
        PostedSalesInvoice.GoToRecord(SalesInvoiceHeader);

        // [THEN] Sust. Account No. is not Visible on Lines of Posted Sales Invoice.
        Assert.IsFalse(
            PostedSalesInvoice.SalesInvLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedSalesInvoice.SalesInvLines."Sust. Account No.".Caption(),
                PostedSalesInvoice.SalesInvLines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Posted Sales Invoice.
        Assert.IsFalse(
            PostedSalesInvoice.SalesInvLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedSalesInvoice.SalesInvLines."Total CO2e".Caption(),
                PostedSalesInvoice.SalesInvLines.Caption()));

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");

        // [THEN] Sustainability Ledger Entry is not found.
        Assert.IsTrue(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", SalesLine."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnSalesCrMemoIfEnableValueTrackingIsTrue()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PostedSalesCrMemo: TestPage "Posted Sales Credit Memo";
        SalesCrMemo: TestPage "Sales Credit Memo";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        PostedCrMemoNo: Code[20];
        SubcategoryCode: Code[20];
        TotalCO2e: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are Visible on Sales Cr. Memo, Lines of Sales Cr. Memo,
        // Posted Sales Cr. Memo and Lines of Posted Sales Cr. Memo if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::"Credit Memo", LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify(true);

        // [WHEN] Open Sales Cr. Memo.
        SalesCrMemo.OpenEdit();
        SalesCrMemo.GoToRecord(SalesHeader);

        // [THEN] Sust. Account No. is Visible on Lines of Sales Cr. Memo.
        Assert.IsTrue(
            SalesCrMemo.SalesLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                SalesCrMemo.SalesLines."Sust. Account No.".Caption(),
                SalesCrMemo.SalesLines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Sales Cr. Memo.
        Assert.IsTrue(
            SalesCrMemo.SalesLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                SalesCrMemo.SalesLines."Total CO2e".Caption(),
                SalesCrMemo.SalesLines.Caption()));

        // [GIVEN] Post a Sales Document.
        PostedCrMemoNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [GIVEN] Find Sales Cr. Memo Header.
        SalesCrMemoHeader.SetRange("No.", PostedCrMemoNo);
        SalesCrMemoHeader.FindFirst();

        // [WHEN] Open Posted Sales Cr. Memo.
        PostedSalesCrMemo.OpenEdit();
        PostedSalesCrMemo.GoToRecord(SalesCrMemoHeader);

        // [THEN] Sust. Account No. is Visible on Lines of Posted Sales Cr. Memo.
        Assert.IsTrue(
            PostedSalesCrMemo.SalesCrMemoLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedSalesCrMemo.SalesCrMemoLines."Sust. Account No.".Caption(),
                PostedSalesCrMemo.SalesCrMemoLines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Posted Sales Cr. Memo.
        Assert.IsTrue(
            PostedSalesCrMemo.SalesCrMemoLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedSalesCrMemo.SalesCrMemoLines."Total CO2e".Caption(),
                PostedSalesCrMemo.SalesCrMemoLines.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnSalesCrMemoIfEnableValueTrackingIsFalse()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        PostedSalesCrMemo: TestPage "Posted Sales Credit Memo";
        SalesCrMemo: TestPage "Sales Credit Memo";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        PostedCrMemoNo: Code[20];
        SubcategoryCode: Code[20];
        TotalCO2e: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are not Visible on Sales Cr. Memo, Lines of Sales Cr. Memo,
        // Posted Sales Cr. Memo and Lines of Posted Sales Cr. Memo and no Sustainability Ledger Entry
        // or Sustainability Value Entry is created if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::"Credit Memo", LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify(true);

        // [WHEN] Open Sales Cr. Memo.
        SalesCrMemo.OpenEdit();
        SalesCrMemo.GoToRecord(SalesHeader);

        // [THEN] Sust. Account No. is not Visible on Lines of Sales Cr. Memo.
        Assert.IsFalse(
            SalesCrMemo.SalesLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                SalesCrMemo.SalesLines."Sust. Account No.".Caption(),
                SalesCrMemo.SalesLines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Sales Cr. Memo.
        Assert.IsFalse(
            SalesCrMemo.SalesLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                SalesCrMemo.SalesLines."Total CO2e".Caption(),
                SalesCrMemo.SalesLines.Caption()));

        // [GIVEN] Post a Sales Document.
        PostedCrMemoNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [GIVEN] Find Sales Cr. Memo Header.
        SalesCrMemoHeader.SetRange("No.", PostedCrMemoNo);
        SalesCrMemoHeader.FindFirst();

        // [WHEN] Open Posted Sales Cr. Memo.
        PostedSalesCrMemo.OpenEdit();
        PostedSalesCrMemo.GoToRecord(SalesCrMemoHeader);

        // [THEN] Sust. Account No. is not Visible on Lines of Posted Sales Cr. Memo.
        Assert.IsFalse(
            PostedSalesCrMemo.SalesCrMemoLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedSalesCrMemo.SalesCrMemoLines."Sust. Account No.".Caption(),
                PostedSalesCrMemo.SalesCrMemoLines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Posted Sales Cr. Memo.
        Assert.IsFalse(
            PostedSalesCrMemo.SalesCrMemoLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedSalesCrMemo.SalesCrMemoLines."Total CO2e".Caption(),
                PostedSalesCrMemo.SalesCrMemoLines.Caption()));

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");

        // [THEN] Sustainability Ledger Entry is not found.
        Assert.IsTrue(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", SalesLine."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnTransferOrderAndPostedTransShptIfEnableValueTrackingIsTrue()
    var
        FromLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferHeader: Record "Transfer Header";
        ToLocation: Record Location;
        PostedTransferShipment: TestPage "Posted Transfer Shipment";
        TransferOrder: TestPage "Transfer Order";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are Visible on Lines of Transfer Order,
        // Lines of Posted Transfer Shipment if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and Intransit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account", "CO2e per Unit" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("CO2e per Unit", CO2ePerUnit);
        Item.Modify(true);

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Quantity, CO2ePerUnit);

        // [WHEN] Open Transfer Order.
        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);

        // [THEN] Sust. Account No. is Visible on Lines of Transfer Order.
        Assert.IsTrue(
            TransferOrder.TransferLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                TransferOrder.TransferLines."Sust. Account No.".Caption(),
                TransferOrder.TransferLines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Transfer Order.
        Assert.IsTrue(
            TransferOrder.TransferLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                TransferOrder.TransferLines."Total CO2e".Caption(),
                TransferOrder.TransferLines.Caption()));

        // [GIVEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);

        // [GIVEN] Get Transfer Shipment Header.
        GetTransferShipmentHeader(TransferShipmentHeader, FromLocation.Code);

        // [WHEN] Open Posted Transfer Shipment.
        PostedTransferShipment.OpenEdit();
        PostedTransferShipment.GoToRecord(TransferShipmentHeader);

        // [THEN] Sust. Account No. is Visible on Lines of Posted Transfer Shipment.
        Assert.IsTrue(
            PostedTransferShipment.TransferShipmentLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedTransferShipment.TransferShipmentLines."Sust. Account No.".Caption(),
                PostedTransferShipment.TransferShipmentLines.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Posted Transfer Shipment.
        Assert.IsTrue(
            PostedTransferShipment.TransferShipmentLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                PostedTransferShipment.TransferShipmentLines."Total CO2e".Caption(),
                PostedTransferShipment.TransferShipmentLines.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnTOAndPTShptAndSustEntriesAreNotCreatedIfEnableValueTrackIsFalse()
    var
        FromLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferHeader: Record "Transfer Header";
        ToLocation: Record Location;
        PostedTransferShipment: TestPage "Posted Transfer Shipment";
        TransferOrder: TestPage "Transfer Order";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are not Visible on Lines of Transfer Order,
        // Lines of Posted Transfer Shipment and no Sustainability Ledger Entry
        // or Sustainability Value Entry is created if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and Intransit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account", "CO2e per Unit" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("CO2e per Unit", CO2ePerUnit);
        Item.Modify(true);

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Quantity, 0);

        // [WHEN] Open Transfer Order.
        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);

        // [THEN] Sust. Account No. is not Visible on Lines of Transfer Order.
        Assert.IsFalse(
            TransferOrder.TransferLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                TransferOrder.TransferLines."Sust. Account No.".Caption(),
                TransferOrder.TransferLines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Transfer Order.
        Assert.IsFalse(
            TransferOrder.TransferLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                TransferOrder.TransferLines."Total CO2e".Caption(),
                TransferOrder.TransferLines.Caption()));

        // [GIVEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);

        // [GIVEN] Get Transfer Shipment Header.
        GetTransferShipmentHeader(TransferShipmentHeader, FromLocation.Code);

        // [WHEN] Open Posted Transfer Shipment.
        PostedTransferShipment.OpenEdit();
        PostedTransferShipment.GoToRecord(TransferShipmentHeader);

        // [THEN] Sust. Account No. is not Visible on Lines of Posted Transfer Shipment.
        Assert.IsFalse(
            PostedTransferShipment.TransferShipmentLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedTransferShipment.TransferShipmentLines."Sust. Account No.".Caption(),
                PostedTransferShipment.TransferShipmentLines.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Posted Transfer Shipment.
        Assert.IsFalse(
            PostedTransferShipment.TransferShipmentLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                PostedTransferShipment.TransferShipmentLines."Total CO2e".Caption(),
                PostedTransferShipment.TransferShipmentLines.Caption()));

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", TransferShipmentHeader."No.");

        // [THEN] Sustainability Ledger Entry is not found.
        Assert.IsTrue(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", Item."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnWorkAndMachineCentersRoutingsProdBOMsComponentsAndRelProdOrdersIfEnableValueTrackingIsTrue()
    var
        CompItem: Record Item;
        MachineCenter: Record "Machine Center";
        ProdItem: Record Item;
        ProductionOrder: Record "Production Order";
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMLine: Record "Production BOM Line";
        ProductionOrderLine: Record "Prod. Order Line";
        ProductionOrderComponent: Record "Prod. Order Component";
        ProductionOrderRoutingLine: Record "Prod. Order Routing Line";
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        SustainabilitySetup: Record "Sustainability Setup";
        WorkCenter: Record "Work Center";
        MachineCenterCard: TestPage "Machine Center Card";
        MachineCenterList: TestPage "Machine Center List";
        ProductionBOM: TestPage "Production BOM";
        ProductionBOMList: TestPage "Production BOM List";
        ProductionBOMLines: TestPage "Production BOM Lines";
        ProductionBOMVersionLines: TestPage "Production BOM Version Lines";
        ProdOrderRouting: TestPage "Prod. Order Routing";
        ProdOrderComponents: TestPage "Prod. Order Components";
        ReleasedProductionOrder: TestPage "Released Production Order";
        ReleasedProductionOrders: TestPage "Released Production Orders";
        ReleasedProductionOrderLine: TestPage "Released Prod. Order Lines";
        RoutingLines: TestPage "Routing Lines";
        RoutingVersionLines: TestPage "Routing Version Lines";
        WorkCenterList: TestPage "Work Center List";
        WorkCenterCard: TestPage "Work Center Card";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quanity: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are Visible on Work Center List,
        // Work Center Card, Machine Center List, Machine Center Card, Routing Lines, Routing Version Lines,
        // Production BOM, Production BOM List, production BOM Lines, Production BOM Version Lines,
        // Prod. Order Routing, Prod. Order Components, Released Production Order, Released Prod. Order Lines.
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Update "Work/Machine Centers Emissions" in Sustainability Setup.
        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [WHEN] Open Work Center Card.
        WorkCenterCard.OpenEdit();
        WorkCenterCard.GoToRecord(WorkCenter);

        // [THEN] Default Sust. Account is Visible on Work Center Card.
        Assert.IsTrue(
            WorkCenterCard."Default Sust. Account".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                WorkCenterCard."Default Sust. Account".Caption(),
                WorkCenterCard.Caption()));

        // [THEN] Default CH4 Emission is Visible on Work Center Card.
        Assert.IsTrue(
            WorkCenterCard."Default CH4 Emission".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                WorkCenterCard."Default CH4 Emission".Caption(),
                WorkCenterCard.Caption()));

        // [THEN] Default CO2 Emission is Visible on Work Center Card.
        Assert.IsTrue(
            WorkCenterCard."Default CO2 Emission".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                WorkCenterCard."Default CO2 Emission".Caption(),
                WorkCenterCard.Caption()));

        // [THEN] Default N2O Emission is Visible on Work Center Card.
        Assert.IsTrue(
            WorkCenterCard."Default N2O Emission".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                WorkCenterCard."Default N2O Emission".Caption(),
                WorkCenterCard.Caption()));

        // [THEN] CO2e per Unit is Visible on Work Center Card.
        Assert.IsTrue(
            WorkCenterCard."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                WorkCenterCard."CO2e per Unit".Caption(),
                WorkCenterCard.Caption()));

        // [WHEN] Open Work Center List.
        WorkCenterList.OpenEdit();
        WorkCenterList.GoToRecord(WorkCenter);

        // [THEN] Calculate CO2e action is Visible on Work Center List.
        Assert.IsTrue(
            WorkCenterList."Calculate CO2e".Visible(),
            StrSubstNo(
                ActionShouldBeVisibleErr,
                WorkCenterList.Caption()));

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, 0));

        // [GIVEN] Find Routing Line.
        RoutingLine.SetRange("Routing No.", RoutingHeader."No.");
        RoutingLine.FindFirst();

        // [WHEN] Open Routing Lines.
        RoutingLines.OpenEdit();
        RoutingLines.GoToRecord(RoutingLine);

        // [THEN] CO2e per Unit is Visible on Routing Lines.
        Assert.IsTrue(
            RoutingLines."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                RoutingLines."CO2e per Unit".Caption(),
                RoutingLines.Caption()));

        // [WHEN] Open Routing Version Lines.
        RoutingVersionLines.OpenEdit();
        RoutingVersionLines.GoToRecord(RoutingLine);

        // [THEN] CO2e per Unit is Visible on Routing Version Lines.
        Assert.IsTrue(
            RoutingVersionLines."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                RoutingVersionLines."CO2e per Unit".Caption(),
                RoutingVersionLines.Caption()));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify(true);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify(true);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [WHEN] Open Production BOM.
        ProductionBOM.OpenEdit();
        ProductionBOM.GoToRecord(ProductionBOMHeader);

        // [THEN] Calculate CO2e action is Visible on Production BOM.
        Assert.IsTrue(
            ProductionBOM."Calculate CO2e".Visible(),
            StrSubstNo(
                ActionShouldBeVisibleErr,
                ProductionBOM.Caption()));

        // [WHEN] Open Production BOM List.
        ProductionBOMList.OpenEdit();
        ProductionBOMList.GoToRecord(ProductionBOMHeader);

        // [THEN] Calculate CO2e action is Visible on Production BOM List.
        Assert.IsTrue(
            ProductionBOMList."Calculate CO2e".Visible(),
            StrSubstNo(
                ActionShouldBeVisibleErr,
                ProductionBOMList.Caption()));

        // [GIVEN] Find Production BOM Line.
        ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMHeader."No.");
        ProductionBOMLine.FindFirst();

        // [WHEN] Open Production BOM Lines.
        ProductionBOMLines.OpenEdit();
        ProductionBOMLines.GoToRecord(ProductionBOMLine);

        // [THEN] CO2e per Unit is Visible on Production BOM Lines.
        Assert.IsTrue(
            ProductionBOMLines."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ProductionBOMLines."CO2e per Unit".Caption(),
                ProductionBOMLines.Caption()));

        // [WHEN] Open Production BOM Version Lines.
        ProductionBOMVersionLines.OpenEdit();
        ProductionBOMVersionLines.GoToRecord(ProductionBOMLine);

        // [THEN] CO2e per Unit is Visible on Production BOM Version Lines.
        Assert.IsTrue(
            ProductionBOMVersionLines."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ProductionBOMVersionLines."CO2e per Unit".Caption(),
                ProductionBOMVersionLines.Caption()));

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenter(MachineCenter, WorkCenter."No.", LibraryRandom.RandInt(0));

        // [WHEN] Open Machine Center List.
        MachineCenterList.OpenEdit();
        MachineCenterList.GoToRecord(MachineCenter);

        // [THEN] Calculate CO2e action is Visible on Machine Center List.
        Assert.IsTrue(
            MachineCenterList."Calculate CO2e".Visible(),
            StrSubstNo(
                ActionShouldBeVisibleErr,
                MachineCenterList.Caption()));

        // [WHEN] Open Machine Center Card.
        MachineCenterCard.OpenEdit();
        MachineCenterCard.GoToRecord(MachineCenter);

        // [THEN] Default Sust. Account is Visible on Machine Center Card.
        Assert.IsTrue(
            MachineCenterCard."Default Sust. Account".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                MachineCenterCard."Default Sust. Account".Caption(),
                MachineCenterCard.Caption()));

        // [THEN] Default CH4 Emission is Visible on Machine Center Card.
        Assert.IsTrue(
            MachineCenterCard."Default CH4 Emission".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                MachineCenterCard."Default CH4 Emission".Caption(),
                MachineCenterCard.Caption()));

        // [THEN] Default CO2 Emission is Visible on Machine Center Card.
        Assert.IsTrue(
            MachineCenterCard."Default CO2 Emission".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                MachineCenterCard."Default CO2 Emission".Caption(),
                MachineCenterCard.Caption()));

        // [THEN] Default N2O Emission is Visible on Machine Center Card.
        Assert.IsTrue(
            MachineCenterCard."Default N2O Emission".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                MachineCenterCard."Default N2O Emission".Caption(),
                MachineCenterCard.Caption()));

        // [THEN] CO2e per Unit is Visible on Machine Center Card.
        Assert.IsTrue(
            MachineCenterCard."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                MachineCenterCard."CO2e per Unit".Caption(),
                MachineCenterCard.Caption()));

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify(true);

        // [GIVEN] Generate Quantity for Prod Order Line.
        Quanity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", Quanity);

        // [WHEN] Open Released Production Order.
        ReleasedProductionOrder.OpenEdit();
        ReleasedProductionOrder.GoToRecord(ProductionOrder);

        // [THEN] Sustainability Ledger Entries action is Visible on Released Production Order.
        Assert.IsTrue(
            ReleasedProductionOrder."Sustainability Ledger Entries".Visible(),
            StrSubstNo(
                SustLdgEntriesActionShouldBeVisibleErr,
                ReleasedProductionOrder.Caption()));

        // [THEN] Sustainability Value Entries action is Visible on Released Production Order.
        Assert.IsTrue(
            ReleasedProductionOrder."Sustainability Value Entries".Visible(),
            StrSubstNo(
                SustValueEntriesActionShouldBeVisibleErr,
                ReleasedProductionOrder.Caption()));

        // [WHEN] Open Released Production Orders.
        ReleasedProductionOrders.OpenEdit();
        ReleasedProductionOrders.GoToRecord(ProductionOrder);

        // [THEN] Sustainability Ledger Entries action is Visible on Released Production Orders.
        Assert.IsTrue(
            ReleasedProductionOrders."Sustainability Ledger Entries".Visible(),
            StrSubstNo(
                SustLdgEntriesActionShouldBeVisibleErr,
                ReleasedProductionOrders.Caption()));

        // [THEN] Sustainability Value Entries action is Visible on Released Production Orders.
        Assert.IsTrue(
            ReleasedProductionOrders."Sustainability Value Entries".Visible(),
            StrSubstNo(
                SustValueEntriesActionShouldBeVisibleErr,
                ReleasedProductionOrders.Caption()));

        // [GIVEN] Find Prod Order Line.
        ProductionOrderLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderLine.FindFirst();

        // [WHEN] Open Released Production Order Line.
        ReleasedProductionOrderLine.OpenEdit();
        ReleasedProductionOrderLine.GoToRecord(ProductionOrderLine);

        // [THEN] Sust. Account No. is Visible on Released Production Order Line.
        Assert.IsTrue(
            ReleasedProductionOrderLine."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ReleasedProductionOrderLine."Sust. Account No.".Caption(),
                ReleasedProductionOrderLine.Caption()));

        // [THEN] Total CO2e is Visible on Released Production Order Line.
        Assert.IsTrue(
            ReleasedProductionOrderLine."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ReleasedProductionOrderLine."Total CO2e".Caption(),
                ReleasedProductionOrderLine.Caption()));

        // [GIVEN] Find Prod Order Routing Line.
        ProductionOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderRoutingLine.FindFirst();

        // [WHEN] Open Prod. Order Routing.
        ProdOrderRouting.OpenEdit();
        ProdOrderRouting.GoToRecord(ProductionOrderRoutingLine);

        // [THEN] Sust. Account No. is Visible on Prod. Order Routing.
        Assert.IsTrue(
            ProdOrderRouting."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ProdOrderRouting."Sust. Account No.".Caption(),
                ProdOrderRouting.Caption()));

        // [THEN] Total CO2e is Visible on Prod. Order Routing.
        Assert.IsTrue(
            ProdOrderRouting."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ProdOrderRouting."Total CO2e".Caption(),
                ProdOrderRouting.Caption()));

        // [GIVEN] Delete Prod. Order Component.
        ProductionOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProductionOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderComponent.FindFirst();

        // [WHEN] Open Prod. Order Components.
        ProdOrderComponents.OpenEdit();
        ProdOrderComponents.GoToRecord(ProductionOrderComponent);

        // [THEN] Sust. Account No. is Visible on Prod. Order Components.
        Assert.IsTrue(
            ProdOrderComponents."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ProdOrderComponents."Sust. Account No.".Caption(),
                ProdOrderComponents.Caption()));

        // [THEN] Total CO2e is Visible on Prod. Order Components.
        Assert.IsTrue(
            ProdOrderComponents."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ProdOrderComponents."Total CO2e".Caption(),
                ProdOrderComponents.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnWorkAndMachineCentersRoutingsProdBOMsComponentsAndRelProdOrdersIfEnableValueTrackIsFalse()
    var
        CompItem: Record Item;
        MachineCenter: Record "Machine Center";
        ProdItem: Record Item;
        ProductionOrder: Record "Production Order";
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMLine: Record "Production BOM Line";
        ProductionOrderLine: Record "Prod. Order Line";
        ProductionOrderComponent: Record "Prod. Order Component";
        ProductionOrderRoutingLine: Record "Prod. Order Routing Line";
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        SustainabilitySetup: Record "Sustainability Setup";
        WorkCenter: Record "Work Center";
        MachineCenterCard: TestPage "Machine Center Card";
        MachineCenterList: TestPage "Machine Center List";
        ProductionBOM: TestPage "Production BOM";
        ProductionBOMList: TestPage "Production BOM List";
        ProductionBOMLines: TestPage "Production BOM Lines";
        ProductionBOMVersionLines: TestPage "Production BOM Version Lines";
        ProdOrderRouting: TestPage "Prod. Order Routing";
        ProdOrderComponents: TestPage "Prod. Order Components";
        ReleasedProductionOrder: TestPage "Released Production Order";
        ReleasedProductionOrders: TestPage "Released Production Orders";
        ReleasedProductionOrderLine: TestPage "Released Prod. Order Lines";
        RoutingLines: TestPage "Routing Lines";
        RoutingVersionLines: TestPage "Routing Version Lines";
        WorkCenterList: TestPage "Work Center List";
        WorkCenterCard: TestPage "Work Center Card";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quanity: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are not Visible on Work Center List,
        // Work Center Card, Machine Center List, Machine Center Card, Routing Lines, Routing Version Lines,
        // Production BOM, Production BOM List, production BOM Lines, Production BOM Version Lines,
        // Prod. Order Routing, Prod. Order Components, Released Production Order, Released Prod. Order Lines.
        // if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Update "Work/Machine Centers Emissions" in Sustainability Setup.
        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [WHEN] Open Work Center Card.
        WorkCenterCard.OpenEdit();
        WorkCenterCard.GoToRecord(WorkCenter);

        // [THEN] Default Sust. Account is not Visible on Work Center Card.
        Assert.IsFalse(
            WorkCenterCard."Default Sust. Account".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                WorkCenterCard."Default Sust. Account".Caption(),
                WorkCenterCard.Caption()));

        // [THEN] Default CH4 Emission is not Visible on Work Center Card.
        Assert.IsFalse(
            WorkCenterCard."Default CH4 Emission".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                WorkCenterCard."Default CH4 Emission".Caption(),
                WorkCenterCard.Caption()));

        // [THEN] Default CO2 Emission is not Visible on Work Center Card.
        Assert.IsFalse(
            WorkCenterCard."Default CO2 Emission".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                WorkCenterCard."Default CO2 Emission".Caption(),
                WorkCenterCard.Caption()));

        // [THEN] Default N2O Emission is not Visible on Work Center Card.
        Assert.IsFalse(
            WorkCenterCard."Default N2O Emission".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                WorkCenterCard."Default N2O Emission".Caption(),
                WorkCenterCard.Caption()));

        // [THEN] CO2e per Unit is not Visible on Work Center Card.
        Assert.IsFalse(
            WorkCenterCard."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                WorkCenterCard."CO2e per Unit".Caption(),
                WorkCenterCard.Caption()));

        // [WHEN] Open Work Center List.
        WorkCenterList.OpenEdit();
        WorkCenterList.GoToRecord(WorkCenter);

        // [THEN] Calculate CO2e action is not Visible on Work Center List.
        Assert.IsFalse(
            WorkCenterList."Calculate CO2e".Visible(),
            StrSubstNo(
                ActionShouldNotBeVisibleErr,
                WorkCenterList.Caption()));

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, 0));

        // [GIVEN] Find Routing Line.
        RoutingLine.SetRange("Routing No.", RoutingHeader."No.");
        RoutingLine.FindFirst();

        // [WHEN] Open Routing Lines.
        RoutingLines.OpenEdit();
        RoutingLines.GoToRecord(RoutingLine);

        // [THEN] CO2e per Unit is not Visible on Routing Lines.
        Assert.IsFalse(
            RoutingLines."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                RoutingLines."CO2e per Unit".Caption(),
                RoutingLines.Caption()));

        // [WHEN] Open Routing Version Lines.
        RoutingVersionLines.OpenEdit();
        RoutingVersionLines.GoToRecord(RoutingLine);

        // [THEN] CO2e per Unit is not Visible on Routing Version Lines.
        Assert.IsFalse(
            RoutingVersionLines."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                RoutingVersionLines."CO2e per Unit".Caption(),
                RoutingVersionLines.Caption()));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify(true);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify(true);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [WHEN] Open Production BOM.
        ProductionBOM.OpenEdit();
        ProductionBOM.GoToRecord(ProductionBOMHeader);

        // [THEN] Calculate CO2e action is not Visible on Production BOM.
        Assert.IsFalse(
            ProductionBOM."Calculate CO2e".Visible(),
            StrSubstNo(
                ActionShouldNotBeVisibleErr,
                ProductionBOM.Caption()));

        // [WHEN] Open Production BOM List.
        ProductionBOMList.OpenEdit();
        ProductionBOMList.GoToRecord(ProductionBOMHeader);

        // [THEN] Calculate CO2e action is not Visible on Production BOM List.
        Assert.IsFalse(
            ProductionBOMList."Calculate CO2e".Visible(),
            StrSubstNo(
                ActionShouldNotBeVisibleErr,
                ProductionBOMList.Caption()));

        // [GIVEN] Find Production BOM Line.
        ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMHeader."No.");
        ProductionBOMLine.FindFirst();

        // [WHEN] Open Production BOM Lines.
        ProductionBOMLines.OpenEdit();
        ProductionBOMLines.GoToRecord(ProductionBOMLine);

        // [THEN] CO2e per Unit is not Visible on Production BOM Lines.
        Assert.IsFalse(
            ProductionBOMLines."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ProductionBOMLines."CO2e per Unit".Caption(),
                ProductionBOMLines.Caption()));

        // [WHEN] Open Production BOM Version Lines.
        ProductionBOMVersionLines.OpenEdit();
        ProductionBOMVersionLines.GoToRecord(ProductionBOMLine);

        // [THEN] CO2e per Unit is not Visible on Production BOM Version Lines.
        Assert.IsFalse(
            ProductionBOMVersionLines."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ProductionBOMVersionLines."CO2e per Unit".Caption(),
                ProductionBOMVersionLines.Caption()));

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenter(MachineCenter, WorkCenter."No.", LibraryRandom.RandInt(0));

        // [WHEN] Open Machine Center List.
        MachineCenterList.OpenEdit();
        MachineCenterList.GoToRecord(MachineCenter);

        // [THEN] Calculate CO2e action is not Visible on Machine Center List.
        Assert.IsFalse(
            MachineCenterList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, MachineCenterList.Caption()));

        // [WHEN] Open Machine Center Card.
        MachineCenterCard.OpenEdit();
        MachineCenterCard.GoToRecord(MachineCenter);

        // [THEN] Default Sust. Account is not Visible on Machine Center Card.
        Assert.IsFalse(
            MachineCenterCard."Default Sust. Account".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                MachineCenterCard."Default Sust. Account".Caption(),
                MachineCenterCard.Caption()));

        // [THEN] Default CH4 Emission is not Visible on Machine Center Card.
        Assert.IsFalse(
            MachineCenterCard."Default CH4 Emission".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                MachineCenterCard."Default CH4 Emission".Caption(),
                MachineCenterCard.Caption()));

        // [THEN] Default CO2 Emission is not Visible on Machine Center Card.
        Assert.IsFalse(
            MachineCenterCard."Default CO2 Emission".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                MachineCenterCard."Default CO2 Emission".Caption(),
                MachineCenterCard.Caption()));

        // [THEN] Default N2O Emission is not Visible on Machine Center Card.
        Assert.IsFalse(
            MachineCenterCard."Default N2O Emission".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                MachineCenterCard."Default N2O Emission".Caption(),
                MachineCenterCard.Caption()));

        // [THEN] CO2e per Unit is not Visible on Machine Center Card.
        Assert.IsFalse(
            MachineCenterCard."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                MachineCenterCard."CO2e per Unit".Caption(),
                MachineCenterCard.Caption()));

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify(true);

        // [GIVEN] Generate Quantity for Prod Order Line.
        Quanity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", Quanity);

        // [WHEN] Open Released Production Order.
        ReleasedProductionOrder.OpenEdit();
        ReleasedProductionOrder.GoToRecord(ProductionOrder);

        // [THEN] Sustainability Ledger Entries action is not Visible on Released Production Order.
        Assert.IsFalse(
            ReleasedProductionOrder."Sustainability Ledger Entries".Visible(),
            StrSubstNo(
                SustLdgEntriesActionShouldNotBeVisibleErr,
                ReleasedProductionOrder.Caption()));

        // [THEN] Sustainability Value Entries action is not Visible on Released Production Order.
        Assert.IsFalse(
            ReleasedProductionOrder."Sustainability Value Entries".Visible(),
            StrSubstNo(
                SustValueEntriesActionShouldNotBeVisibleErr,
                ReleasedProductionOrder.Caption()));

        // [WHEN] Open Released Production Orders.
        ReleasedProductionOrders.OpenEdit();
        ReleasedProductionOrders.GoToRecord(ProductionOrder);

        // [THEN] Sustainability Ledger Entries action is not Visible on Released Production Orders.
        Assert.IsFalse(
            ReleasedProductionOrders."Sustainability Ledger Entries".Visible(),
            StrSubstNo(
                SustLdgEntriesActionShouldNotBeVisibleErr,
                ReleasedProductionOrders.Caption()));

        // [THEN] Sustainability Value Entries action is not Visible on Released Production Orders.
        Assert.IsFalse(
            ReleasedProductionOrders."Sustainability Value Entries".Visible(),
            StrSubstNo(
                SustValueEntriesActionShouldNotBeVisibleErr,
                ReleasedProductionOrders.Caption()));

        // [GIVEN] Find Prod Order Line.
        ProductionOrderLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderLine.FindFirst();

        // [WHEN] Open Released Production Order Line.
        ReleasedProductionOrderLine.OpenEdit();
        ReleasedProductionOrderLine.GoToRecord(ProductionOrderLine);

        // [THEN] Sust. Account No. is not Visible on Released Production Order Line.
        Assert.IsFalse(
            ReleasedProductionOrderLine."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ReleasedProductionOrderLine."Sust. Account No.".Caption(),
                ReleasedProductionOrderLine.Caption()));

        // [THEN] Total CO2e is not Visible on Released Production Order Line.
        Assert.IsFalse(
            ReleasedProductionOrderLine."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ReleasedProductionOrderLine."Total CO2e".Caption(),
                ReleasedProductionOrderLine.Caption()));

        // [GIVEN] Find Prod Order Routing Line.
        ProductionOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderRoutingLine.FindFirst();

        // [WHEN] Open Prod. Order Routing.
        ProdOrderRouting.OpenEdit();
        ProdOrderRouting.GoToRecord(ProductionOrderRoutingLine);

        // [THEN] Sust. Account No. is not Visible on Prod. Order Routing.
        Assert.IsFalse(
            ProdOrderRouting."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ProdOrderRouting."Sust. Account No.".Caption(),
                ProdOrderRouting.Caption()));

        // [THEN] Total CO2e is not Visible on Prod. Order Routing.
        Assert.IsFalse(
            ProdOrderRouting."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ProdOrderRouting."Total CO2e".Caption(),
                ProdOrderRouting.Caption()));

        // [GIVEN] Delete Prod. Order Component.
        ProductionOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProductionOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderComponent.FindFirst();

        // [WHEN] Open Prod. Order Components.
        ProdOrderComponents.OpenEdit();
        ProdOrderComponents.GoToRecord(ProductionOrderComponent);

        // [THEN] Sust. Account No. is not Visible on Prod. Order Components.
        Assert.IsFalse(
            ProdOrderComponents."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ProdOrderComponents."Sust. Account No.".Caption(),
                ProdOrderComponents.Caption()));

        // [THEN] Total CO2e is not Visible on Prod. Order Components.
        Assert.IsFalse(
            ProdOrderComponents."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ProdOrderComponents."Total CO2e".Caption(),
                ProdOrderComponents.Caption()));
    end;

    [Test]
    [HandlerFunctions('ProductionJournalModalPageHandler,ConfirmHandlerYes,MessageHandler')]
    procedure VerifySustFieldsAreVisibleOnProductionJournalAndCapacityLedgerEntriesIfEnableValueTrackingIsTrue()
    var
        CompItem: Record Item;
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        ProdItem: Record Item;
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProductionBOMHeader: Record "Production BOM Header";
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        CapacityLedgerEntries: TestPage "Capacity Ledger Entries";
        FinishedProductionOrder: TestPage "Finished Production Order";
        FinishedProductionOrders: TestPage "Finished Production Orders";
        FinishedProdOrderLines: TestPage "Finished Prod. Order Lines";
        AccountCode: array[3] of Code[20];
        CategoryCode: Code[20];
        ExpectedCO2ePerUnit: array[2] of Decimal;
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are Visible on Production Journal, Finished Production Orders,
        // Finished Production Orders, Finished Prod. Order Lines and Capacity Ledger Entries.
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account for Work Center.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(1, 1));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode[1]);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify(true);

        // [GIVEN] Save Expected "CO2e per Unit" for Routing.
        ExpectedCO2ePerUnit[1] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, ExpectedCO2ePerUnit[1]));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Create a Sustainability Account for Comp Item.
        CreateSustainabilityAccount(AccountCode[2], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(2, 2));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode[2]);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify(true);

        // [GIVEN] Post Inventory for Component Item.
        PostInventoryForItem(CompItem."No.");

        // [GIVEN] Create a Sustainability Account for Production Item.
        CreateSustainabilityAccount(AccountCode[3], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(3, 3));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("Default Sust. Account", AccountCode[3]);
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify(true);

        // [GIVEN] Save Expected "CO2e per Unit" for Production BOM.
        ExpectedCO2ePerUnit[2] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, ExpectedCO2ePerUnit[2]);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify(true);

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(
            ProductionOrder,
            ProductionOrder.Status::Released,
            ProdItem."No.",
            LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Post Production Journal.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");
        LibraryManufacturing.OpenProductionJournal(ProductionOrder, ProdOrderLine."Line No.");

        // [THEN] Sust. Account No., CO2e per Unit and Total CO2e are Visible
        // on Production Journal in ProductionJournalModalPageHandler.

        // [GIVEN] Find Capacity Ledger Entry.
        CapacityLedgerEntry.SetRange("Document No.", ProductionOrder."No.");
        CapacityLedgerEntry.FindFirst();

        // [WHEN] Open Capacity Ledger Entries.
        CapacityLedgerEntries.OpenEdit();
        CapacityLedgerEntries.GoToRecord(CapacityLedgerEntry);

        // [THEN] Sust. Account No. is Visible on Capacity Ledger Entries.
        Assert.IsTrue(
            CapacityLedgerEntries."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                CapacityLedgerEntries."Sust. Account No.".Caption(),
                CapacityLedgerEntries.Caption()));

        // [THEN] CO2e per Unit is Visible on Capacity Ledger Entries.
        Assert.IsTrue(
            CapacityLedgerEntries."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                CapacityLedgerEntries."CO2e per Unit".Caption(),
                CapacityLedgerEntries.Caption()));

        // [THEN] Total CO2e is Visible on Capacity Ledger Entries.
        Assert.IsTrue(
            CapacityLedgerEntries."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                CapacityLedgerEntries."Total CO2e".Caption(),
                CapacityLedgerEntries.Caption()));

        // [GIVEN] Change Produstion Order Status to Finished.
        LibraryManufacturing.ChangeProdOrderStatus(ProductionOrder, ProductionOrder.Status::Finished, WorkDate(), true);

        // [GIVEN] Find Production Order.
        ProductionOrder.SetRange(Status, ProductionOrder.Status::Finished);
        ProductionOrder.SetRange("Source No.", ProdItem."No.");
        ProductionOrder.FindFirst();

        // [WHEN] Open Finished Production Order.
        FinishedProductionOrder.OpenEdit();
        FinishedProductionOrder.GoToRecord(ProductionOrder);

        // [THEN] Sustainability Ledger Entries action is Visible on Finished Production Order.
        Assert.IsTrue(
            FinishedProductionOrder."Sustainability Ledger Entries".Visible(),
            StrSubstNo(
                SustLdgEntriesActionShouldBeVisibleErr,
                FinishedProductionOrder.Caption()));

        // [THEN] Sustainability Ledger Entries action is Visible on Finished Production Order.
        Assert.IsTrue(
            FinishedProductionOrder."Sustainability Value Entries".Visible(),
            StrSubstNo(
                SustValueEntriesActionShouldBeVisibleErr,
                FinishedProductionOrder.Caption()));

        // [WHEN] Open Finished Production Orders.
        FinishedProductionOrders.OpenEdit();
        FinishedProductionOrders.GoToRecord(ProductionOrder);

        // [THEN] Sustainability Ledger Entries action is Visible on Finished Production Orders.
        Assert.IsTrue(
            FinishedProductionOrders."Sustainability Ledger Entries".Visible(),
            StrSubstNo(
                SustLdgEntriesActionShouldBeVisibleErr,
                FinishedProductionOrders.Caption()));

        // [THEN] Sustainability Ledger Entries action is Visible on Finished Production Orders.
        Assert.IsTrue(
            FinishedProductionOrders."Sustainability Value Entries".Visible(),
            StrSubstNo(
                SustValueEntriesActionShouldBeVisibleErr,
                FinishedProductionOrders.Caption()));

        // [GIVEN] Find Prod. Order Line.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");

        // [WHEN] Open Finished Prod. Order Lines.
        FinishedProdOrderLines.OpenEdit();
        FinishedProdOrderLines.GoToRecord(ProdOrderLine);

        // [THEN] Sust. Account No. is Visible on Finished Prod. Order Lines.
        Assert.IsTrue(
            FinishedProdOrderLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                FinishedProdOrderLines."Sust. Account No.".Caption(),
                FinishedProdOrderLines.Caption()));

        // [THEN] Total CO2e is Visible on Finished Prod. Order Lines.
        Assert.IsTrue(
            FinishedProdOrderLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                FinishedProdOrderLines."Sust. Account No.".Caption(),
                FinishedProdOrderLines.Caption()));
    end;

    [Test]
    [HandlerFunctions('ProductionJnlModalPageHandler,ConfirmHandlerYes,MessageHandler')]
    procedure VerifySustFieldsAreNotVisibleOnProdJnlAndCapLedgerEntriesAndSustEntriesAreNotCreatedIfEnableValueChainTrackingIsFalse()
    var
        CompItem: Record Item;
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        ProdItem: Record Item;
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProductionBOMHeader: Record "Production BOM Header";
        RoutingHeader: Record "Routing Header";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        WorkCenter: Record "Work Center";
        CapacityLedgerEntries: TestPage "Capacity Ledger Entries";
        FinishedProductionOrder: TestPage "Finished Production Order";
        FinishedProductionOrders: TestPage "Finished Production Orders";
        FinishedProdOrderLines: TestPage "Finished Prod. Order Lines";
        AccountCode: array[3] of Code[20];
        CategoryCode: Code[20];
        ExpectedCO2ePerUnit: array[2] of Decimal;
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Fields are not Visible on Production Journal, Finished Production Orders,
        // Finished Production Orders, Finished Prod. Order Lines and Capacity Ledger Entries and
        // also no Sustainability Ledger Entry or Sustainability Value Entry is created
        // if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account for Work Center.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(1, 1));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode[1]);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify(true);

        // [GIVEN] Save Expected "CO2e per Unit" for Routing.
        ExpectedCO2ePerUnit[1] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, ExpectedCO2ePerUnit[1]));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Create a Sustainability Account for Comp Item.
        CreateSustainabilityAccount(AccountCode[2], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(2, 2));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode[2]);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify(true);

        // [GIVEN] Post Inventory for Component Item.
        PostInventoryForItem(CompItem."No.");

        // [GIVEN] Create a Sustainability Account for Production Item.
        CreateSustainabilityAccount(AccountCode[3], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(3, 3));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("Default Sust. Account", AccountCode[3]);
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify(true);

        // [GIVEN] Save Expected "CO2e per Unit" for Production BOM.
        ExpectedCO2ePerUnit[2] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, ExpectedCO2ePerUnit[2]);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify(true);

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(
            ProductionOrder,
            ProductionOrder.Status::Released,
            ProdItem."No.",
            LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Post Production Journal.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");
        LibraryManufacturing.OpenProductionJournal(ProductionOrder, ProdOrderLine."Line No.");

        // [THEN] Sust. Account No., CO2e per Unit and Total CO2e are not Visible
        // on Production Journal in ProductionJournalModalPageHandler.

        // [GIVEN] Find Capacity Ledger Entry.
        CapacityLedgerEntry.SetRange("Document No.", ProductionOrder."No.");
        CapacityLedgerEntry.FindFirst();

        // [WHEN] Open Capacity Ledger Entries.
        CapacityLedgerEntries.OpenEdit();
        CapacityLedgerEntries.GoToRecord(CapacityLedgerEntry);

        // [THEN] Sust. Account No. is not Visible on Capacity Ledger Entries.
        Assert.IsFalse(
            CapacityLedgerEntries."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                CapacityLedgerEntries."Sust. Account No.".Caption(),
                CapacityLedgerEntries.Caption()));

        // [THEN] CO2e per Unit is not Visible on Capacity Ledger Entries.
        Assert.IsFalse(
            CapacityLedgerEntries."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                CapacityLedgerEntries."CO2e per Unit".Caption(),
                CapacityLedgerEntries.Caption()));

        // [THEN] Total CO2e is not Visible on Capacity Ledger Entries.
        Assert.IsFalse(
            CapacityLedgerEntries."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                CapacityLedgerEntries."Total CO2e".Caption(),
                CapacityLedgerEntries.Caption()));

        // [GIVEN] Change Produstion Order Status to Finished.
        LibraryManufacturing.ChangeProdOrderStatus(ProductionOrder, ProductionOrder.Status::Finished, WorkDate(), true);

        // [GIVEN] Find Production Order.
        ProductionOrder.SetRange(Status, ProductionOrder.Status::Finished);
        ProductionOrder.SetRange("Source No.", ProdItem."No.");
        ProductionOrder.FindFirst();

        // [WHEN] Open Finished Production Order.
        FinishedProductionOrder.OpenEdit();
        FinishedProductionOrder.GoToRecord(ProductionOrder);

        // [THEN] Sustainability Ledger Entries action is not Visible on Finished Production Order.
        Assert.IsFalse(
            FinishedProductionOrder."Sustainability Ledger Entries".Visible(),
            StrSubstNo(
                SustLdgEntriesActionShouldNotBeVisibleErr,
                FinishedProductionOrder.Caption()));

        // [THEN] Sustainability Ledger Entries action is not Visible on Finished Production Order.
        Assert.IsFalse(
            FinishedProductionOrder."Sustainability Value Entries".Visible(),
            StrSubstNo(
                SustValueEntriesActionShouldNotBeVisibleErr,
                FinishedProductionOrder.Caption()));

        // [WHEN] Open Finished Production Orders.
        FinishedProductionOrders.OpenEdit();
        FinishedProductionOrders.GoToRecord(ProductionOrder);

        // [THEN] Sustainability Ledger Entries action is not Visible on Finished Production Order.
        Assert.IsFalse(
            FinishedProductionOrders."Sustainability Ledger Entries".Visible(),
            StrSubstNo(
                SustLdgEntriesActionShouldNotBeVisibleErr,
                FinishedProductionOrders.Caption()));

        // [THEN] Sustainability Ledger Entries action is not Visible on Finished Production Order.
        Assert.IsFalse(
            FinishedProductionOrders."Sustainability Value Entries".Visible(),
            StrSubstNo(
                SustValueEntriesActionShouldNotBeVisibleErr,
                FinishedProductionOrders.Caption()));

        // [GIVEN] Find Prod. Order Line.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");

        // [WHEN] Open Finished Prod. Order Lines.
        FinishedProdOrderLines.OpenEdit();
        FinishedProdOrderLines.GoToRecord(ProdOrderLine);

        // [THEN] Sust. Account No. is not Visible on Finished Prod. Order Lines.
        Assert.IsFalse(
            FinishedProdOrderLines."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                FinishedProdOrderLines."Sust. Account No.".Caption(),
                FinishedProdOrderLines.Caption()));

        // [THEN] Total CO2e is not Visible on Finished Prod. Order Lines.
        Assert.IsFalse(
            FinishedProdOrderLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                FinishedProdOrderLines."Sust. Account No.".Caption(),
                FinishedProdOrderLines.Caption()));

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", ProductionOrder."No.");

        // [THEN] Sustainability Ledger Entry is not found.
        Assert.IsTrue(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", ProdItem."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnConsumpJnlAndOutputJnlIfEnableValueChainTrackingIsTrue()
    var
        CompItem: Record Item;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ProdItem: Record Item;
        ProductionOrder: Record "Production Order";
        ProductionBOMHeader: Record "Production BOM Header";
        RoutingHeader: Record "Routing Header";
        SustainabilityAccount: Record "Sustainability Account";
        WorkCenter: Record "Work Center";
        ConsumptionJournal: TestPage "Consumption Journal";
        OutputJournal: TestPage "Output Journal";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quanity: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability fields are Visible on Consumption Journal and Output Journal
        // if Enable Value Chain Tracking is true on Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Unit Cost Calculation", WorkCenter."Unit Cost Calculation"::Units);
        WorkCenter.Validate("Default Sust. Account", AccountCode);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify(true);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, 0));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify(true);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify(true);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify(true);

        // [GIVEN] Generate Quantity for Prod Order Line.
        Quanity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", Quanity);

        // [GIVEN] Create Item Journal Line.
        SelectItemJournal(ItemJournalBatch, ItemJournalBatch."Template Type"::Consumption);
        LibraryInventory.CreateItemJournalLine(
            ItemJournalLine,
            ItemJournalBatch."Journal Template Name",
            ItemJournalBatch.Name,
            ItemJournalLine."Entry Type"::Consumption,
            ProdItem."No.",
            LibraryRandom.RandIntInRange(100, 100));

        // [WHEN] Open Consumption Journal.
        ConsumptionJournal.OpenEdit();
        ConsumptionJournal.GoToRecord(ItemJournalLine);

        // [THEN] Sust. Account No. is Visible on Consumption Journal.
        Assert.IsTrue(
            ConsumptionJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ConsumptionJournal."Sust. Account No.".Caption(),
                ConsumptionJournal.Caption()));

        // [THEN] Total CO2e is Visible on Consumption Journal.
        Assert.IsTrue(
            ConsumptionJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ConsumptionJournal."Total CO2e".Caption(),
                ConsumptionJournal.Caption()));

        // [GIVEN] Create Item Journal Line.
        SelectItemJournal(ItemJournalBatch, ItemJournalBatch."Template Type"::Output);
        LibraryInventory.CreateItemJournalLine(
            ItemJournalLine,
            ItemJournalBatch."Journal Template Name",
            ItemJournalBatch.Name,
            ItemJournalLine."Entry Type"::Output,
            ProdItem."No.",
            LibraryRandom.RandIntInRange(100, 100));

        // [WHEN] Open Output Journal.
        OutputJournal.OpenEdit();
        OutputJournal.GoToRecord(ItemJournalLine);

        // [THEN] Sust. Account No. is Visible on Output Journal.
        Assert.IsTrue(
            OutputJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                OutputJournal."Sust. Account No.".Caption(),
                OutputJournal.Caption()));

        // [THEN] Total CO2e is Visible on Output Journal.
        Assert.IsTrue(
            OutputJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                OutputJournal."Total CO2e".Caption(),
                OutputJournal.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnConsumpJnlAndOutputJnlAndSustEntriesAreNotCreatedIfEnableValueChainTrackingIsFalse()
    var
        CompItem: Record Item;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ProdItem: Record Item;
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        ProductionBOMHeader: Record "Production BOM Header";
        RoutingHeader: Record "Routing Header";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        WorkCenter: Record "Work Center";
        ConsumptionJournal: TestPage "Consumption Journal";
        OutputJournal: TestPage "Output Journal";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quanity: Decimal;
    begin
        // [SCENARIO 561536] Verify Sustainability fields are not Visible on Consumption Journal and Output Journal
        // and no Sustainability Ledger Entry and Sustainability Value Entry is created
        // if Enable Value Chain Tracking is false on Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Unit Cost Calculation", WorkCenter."Unit Cost Calculation"::Units);
        WorkCenter.Validate("Default Sust. Account", AccountCode);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify(true);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, 0));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify(true);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify(true);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify(true);

        // [GIVEN] Generate Quantity for Prod Order Line.
        Quanity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", Quanity);

        // [GIVEN] Create Item Journal Line.
        SelectItemJournal(ItemJournalBatch, ItemJournalBatch."Template Type"::Consumption);
        LibraryInventory.CreateItemJournalLine(
            ItemJournalLine,
            ItemJournalBatch."Journal Template Name",
            ItemJournalBatch.Name,
            ItemJournalLine."Entry Type"::Consumption,
            ProdItem."No.",
            LibraryRandom.RandIntInRange(100, 100));

        // [WHEN] Open Consumption Journal.
        ConsumptionJournal.OpenEdit();
        ConsumptionJournal.GoToRecord(ItemJournalLine);

        // [THEN] Sust. Account No. is not Visible on Consumption Journal.
        Assert.IsFalse(
            ConsumptionJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ConsumptionJournal."Sust. Account No.".Caption(),
                ConsumptionJournal.Caption()));

        // [THEN] Total CO2e is not Visible on Consumption Journal.
        Assert.IsFalse(
            ConsumptionJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ConsumptionJournal."Total CO2e".Caption(),
                ConsumptionJournal.Caption()));

        // [GIVEN] Create Item Journal Line.
        SelectItemJournal(ItemJournalBatch, ItemJournalBatch."Template Type"::Output);
        LibraryInventory.CreateItemJournalLine(
            ItemJournalLine,
            ItemJournalBatch."Journal Template Name",
            ItemJournalBatch.Name,
            ItemJournalLine."Entry Type"::Output,
            ProdItem."No.",
            LibraryRandom.RandIntInRange(100, 100));

        // [WHEN] Open Output Journal.
        OutputJournal.OpenEdit();
        OutputJournal.GoToRecord(ItemJournalLine);

        // [THEN] Sust. Account No. is not Visible on Output Journal.
        Assert.IsFalse(
            OutputJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                OutputJournal."Sust. Account No.".Caption(),
                OutputJournal.Caption()));

        // [THEN] Total CO2e is not Visible on Output Journal.
        Assert.IsFalse(
            OutputJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                OutputJournal."Total CO2e".Caption(),
                OutputJournal.Caption()));

        // [GIVEN] Find Prod. Order Routing Line and Validate Sust. Account No.
        ProdOrderRoutingLine.SetRange("Routing No.", RoutingHeader."No.");
        ProdOrderRoutingLine.FindFirst();
        ProdOrderRoutingLine.Validate("Sust. Account No.", AccountCode);
        ProdOrderRoutingLine.Modify(true);

        // [GIVEN] Find Prod. Order No. and Validate Sust. Account No.
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.FindFirst();
        ProdOrderLine.Validate("Sust. Account No.", AccountCode);
        ProdOrderLine.Modify(true);

        // [GIVEN] Create And Post Output Journal Line.
        CreateAndPostOutputJournalLine(ProdItem."No.", ProdOrderRoutingLine, ProductionOrder, LibraryRandom.RandInt(0));

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", ProductionOrder."No.");

        // [THEN] Sustainability Ledger Entry is not found.
        Assert.IsTrue(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", ProdItem."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Document No.", ProdOrderRoutingLine."Prod. Order No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifyConfirmationShouldNotPopUpWhenEmissionIsEmptyOnItem()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCard: TestPage "Item Card";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 562472] Verify that the confirmation box should not pop up When Default Sust. fields is Zero.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Default Sust Account" in Item card.
        ItemCard."Default Sust. Account".SetValue(AccountCode);

        // [WHEN] Update "Replenishment System" in Item.
        ItemCard."Replenishment System".SetValue(Item."Replenishment System"::"Prod. Order");

        // [THEN] Confirmation Box should not pop up as there is no confirm Handler.
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure VerifyEmissionFieldsMustBeEnabledWhenEnableValueChainTrackingIsEnabled()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        // [SCENARIO 569462] Verify "Use Emissions In Purch. Doc.", "Item Emissions", "Resource Emissions", "Work/Machine Center Emissions" must be enabled in Sustainability Setup.
        // When "Enable Value Chain Tracking" is enabled.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update Sustainability Setup.
        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("Use Emissions In Purch. Doc.", false);
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Validate("Resource Emissions", false);
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Validate("Enable Value Chain Tracking", false);
        SustainabilitySetup.Modify();

        // [WHEN] "Enable Value Chain Tracking" set to true in Sustainability Setup.
        SustainabilitySetup.Validate("Enable Value Chain Tracking", true);

        // [THEN] Verify "Use Emissions In Purch. Doc.", "Item Emissions", "Resource Emissions", "Work/Machine Center Emissions" must be enabled in Sustainability Setup.
        Assert.AreEqual(
            true,
            SustainabilitySetup."Use Emissions In Purch. Doc.",
            StrSubstNo(FieldShouldBeEnabledErr, SustainabilitySetup.FieldCaption("Use Emissions In Purch. Doc."), SustainabilitySetup.TableCaption()));
        Assert.AreEqual(
            true,
            SustainabilitySetup."Item Emissions",
            StrSubstNo(FieldShouldBeEnabledErr, SustainabilitySetup.FieldCaption("Item Emissions"), SustainabilitySetup.TableCaption()));
        Assert.AreEqual(
            true,
            SustainabilitySetup."Resource Emissions",
            StrSubstNo(FieldShouldBeEnabledErr, SustainabilitySetup.FieldCaption("Resource Emissions"), SustainabilitySetup.TableCaption()));
        Assert.AreEqual(
            true,
            SustainabilitySetup."Work/Machine Center Emissions",
            StrSubstNo(FieldShouldBeEnabledErr, SustainabilitySetup.FieldCaption("Work/Machine Center Emissions"), SustainabilitySetup.TableCaption()));
    end;

    [Test]
    procedure VerifyCalculateTotalCO2eShouldbeVisibleOnItemCardIfItemEmissionsAndUseAllGasesAsCO2eIsEnabled()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ItemCard: TestPage "Item Card";
    begin
        // [SCENARIO 564320] Verify "Calculate Total CO2e" action should be visible on "Item Card" page If "Item Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" and "Use All Gases As CO2e" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Validate("Use All Gases As CO2e", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [WHEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify "Calculate Total CO2e" action should not be visible on "Item Card" page If "Item Emissions" and "Use All Gases As CO2e" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ItemCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ItemCard.Caption()));
        Assert.AreEqual(
            false,
            ItemCard."Calculate Total CO2e".Visible(),
            StrSubstNo(CalculateTotalCO2eActionShouldNotBeVisibleErr, ItemCard.Caption()));

        // [GIVEN] Close "Item Card".
        ItemCard.Close();

        // [GIVEN] Update "Item Emissions" and "Use All Gases As CO2e" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Validate("Use All Gases As CO2e", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [VERIFY] Verify "Calculate Total CO2e" action should be visible on "Item Card" page If "Item Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        Assert.AreEqual(
           false,
           ItemCard."Calculate CO2e".Visible(),
           StrSubstNo(ActionShouldNotBeVisibleErr, ItemCard.Caption()));
        Assert.AreEqual(
           true,
           ItemCard."Calculate Total CO2e".Visible(),
           StrSubstNo(CalculateTotalCO2eActionShouldBeVisibleErr, ItemCard.Caption()));
    end;

    [Test]
    procedure VerifyCalculateTotalCO2eShouldbeVisibleOnItemListIfItemEmissionsAndUseAllGasesAsCO2eIsEnabled()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ItemList: TestPage "Item List";
    begin
        // [SCENARIO 564320] Verify "Calculate Total CO2e" action should be visible on "Item List" page If "Item Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" and "Use All Gases As CO2e" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Validate("Use All Gases As CO2e", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [WHEN] Open "Item List".
        ItemList.OpenView();
        ItemList.GoToRecord(Item);

        // [VERIFY] Verify "Calculate Total CO2e" action should not be visible on "Item List" page If "Item Emissions" and "Use All Gases As CO2e" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ItemList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ItemList.Caption()));
        Assert.AreEqual(
            false,
            ItemList."Calculate Total CO2e".Visible(),
            StrSubstNo(CalculateTotalCO2eActionShouldNotBeVisibleErr, ItemList.Caption()));

        // [GIVEN] Close "Item List".
        ItemList.Close();

        // [GIVEN] Update "Item Emissions" and "Use All Gases As CO2e" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Validate("Use All Gases As CO2e", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Item List".
        ItemList.OpenView();
        ItemList.GoToRecord(Item);

        // [VERIFY] Verify "Calculate Total CO2e" action should be visible on "Item List" page If "Item Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        Assert.AreEqual(
           false,
           ItemList."Calculate CO2e".Visible(),
           StrSubstNo(ActionShouldNotBeVisibleErr, ItemList.Caption()));
        Assert.AreEqual(
           true,
           ItemList."Calculate Total CO2e".Visible(),
           StrSubstNo(CalculateTotalCO2eActionShouldBeVisibleErr, ItemList.Caption()));
    end;

    [Test]
    procedure VerifyCalculateTotalCO2eShouldbeVisibleOnProductionBOMCardIfItemEmissionsAndUseAllGasesAsCO2eIsEnabled()
    var
        CompItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        SustainabilitySetup: Record "Sustainability Setup";
        ProductionBOM: TestPage "Production BOM";
    begin
        // [SCENARIO 560219] Verify "Calculate Total CO2e" action should be visible on "Production BOM" page If "Item Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" and "Use All Gases As CO2e" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Validate("Use All Gases As CO2e", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(CompItem);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [WHEN] Open "Production BOM".
        ProductionBOM.OpenView();
        ProductionBOM.GoToRecord(ProductionBOMHeader);

        // [VERIFY] Verify "Calculate Total CO2e" action should not be visible on "Production BOM" page If "Item Emissions" and "Use All Gases As CO2e" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ProductionBOM."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ProductionBOM.Caption()));
        Assert.AreEqual(
            false,
            ProductionBOM."Calculate Total CO2e".Visible(),
            StrSubstNo(CalculateTotalCO2eActionShouldNotBeVisibleErr, ProductionBOM.Caption()));

        // [GIVEN] Close "Production BOM".
        ProductionBOM.Close();

        // [GIVEN] Update "Item Emissions" and "Use All Gases As CO2e" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Validate("Use All Gases As CO2e", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Production BOM".
        ProductionBOM.OpenView();
        ProductionBOM.GoToRecord(ProductionBOMHeader);

        // [VERIFY] Verify "Calculate Total CO2e" action should be visible on "Production BOM" page If "Item Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ProductionBOM."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ProductionBOM.Caption()));
        Assert.AreEqual(
           true,
           ProductionBOM."Calculate Total CO2e".Visible(),
           StrSubstNo(CalculateTotalCO2eActionShouldBeVisibleErr, ProductionBOM.Caption()));
    end;

    [Test]
    procedure VerifyCalculateTotalCO2eShouldbeVisibleOnProductionBOMListIfItemEmissionsAndUseAllGasesAsCO2eIsEnabled()
    var
        CompItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        SustainabilitySetup: Record "Sustainability Setup";
        ProductionBOMList: TestPage "Production BOM List";
    begin
        // [SCENARIO 560219] Verify "Calculate Total CO2e" action should be visible on "Production BOM List" page If "Item Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" and "Use All Gases As CO2e" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", false);
        SustainabilitySetup.Validate("Use All Gases As CO2e", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(CompItem);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [WHEN] Open "Production BOM List".
        ProductionBOMList.OpenView();
        ProductionBOMList.GoToRecord(ProductionBOMHeader);

        // [VERIFY] Verify "Calculate Total CO2e" action should not be visible on "Production BOM List" page If "Item Emissions" and "Use All Gases As CO2e" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ProductionBOMList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ProductionBOMList.Caption()));
        Assert.AreEqual(
            false,
            ProductionBOMList."Calculate Total CO2e".Visible(),
            StrSubstNo(CalculateTotalCO2eActionShouldNotBeVisibleErr, ProductionBOMList.Caption()));

        // [GIVEN] Close "Production BOM List".
        ProductionBOMList.Close();

        // [GIVEN] Update "Item Emissions" and "Use All Gases As CO2e" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Validate("Use All Gases As CO2e", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Production BOM List".
        ProductionBOMList.OpenView();
        ProductionBOMList.GoToRecord(ProductionBOMHeader);

        // [VERIFY] Verify "Calculate Total CO2e" action should be visible on "Production BOM List" page If "Item Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            ProductionBOMList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, ProductionBOMList.Caption()));
        Assert.AreEqual(
           true,
           ProductionBOMList."Calculate Total CO2e".Visible(),
           StrSubstNo(CalculateTotalCO2eActionShouldBeVisibleErr, ProductionBOMList.Caption()));
    end;

    [Test]
    procedure VerifyCalculateTotalCO2eShouldbeVisibleOnMachineCenterCardIfWorkMachineCenterEmissionsAndUseAllGasesAsCO2eIsEnabled()
    var
        MachineCenter: Record "Machine Center";
        SustainabilitySetup: Record "Sustainability Setup";
        MachineCenterCard: TestPage "Machine Center Card";
    begin
        // [SCENARIO 537413] Verify "Calculate Total CO2e" action should be visible on "Machine Center Card" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" and "Use All Gases As CO2e" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Validate("Use All Gases As CO2e", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenter(MachineCenter, '', LibraryRandom.RandDec(10, 1));

        // [WHEN] Open "Machine Center Card".
        MachineCenterCard.OpenView();
        MachineCenterCard.GoToRecord(MachineCenter);

        // [VERIFY] Verify "Calculate Total CO2e" action should not be visible on "Machine Center Card" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            MachineCenterCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, MachineCenterCard.Caption()));
        Assert.AreEqual(
            false,
            MachineCenterCard."Calculate Total CO2e".Visible(),
            StrSubstNo(CalculateTotalCO2eActionShouldNotBeVisibleErr, MachineCenterCard.Caption()));

        // [GIVEN] Close "Machine Center Card".
        MachineCenterCard.Close();

        // [GIVEN] Update "Work/Machine Center Emissions" and "Use All Gases As CO2e" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Validate("Use All Gases As CO2e", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Machine Center Card".
        MachineCenterCard.OpenView();
        MachineCenterCard.GoToRecord(MachineCenter);

        // [VERIFY] Verify "Calculate Total CO2e" action should be visible on "Machine Center Card" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            MachineCenterCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, MachineCenterCard.Caption()));
        Assert.AreEqual(
           true,
           MachineCenterCard."Calculate Total CO2e".Visible(),
           StrSubstNo(CalculateTotalCO2eActionShouldBeVisibleErr, MachineCenterCard.Caption()));
    end;

    [Test]
    procedure VerifyCalculateTotalCO2eShouldbeVisibleOnMachineCenterListIfWorkMachineCenterEmissionsAndUseAllGasesAsCO2eIsEnabled()
    var
        MachineCenter: Record "Machine Center";
        SustainabilitySetup: Record "Sustainability Setup";
        MachineCenterList: TestPage "Machine Center List";
    begin
        // [SCENARIO 537413] Verify "Calculate Total CO2e" action should be visible on "Machine Center List" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" and "Use All Gases As CO2e" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Validate("Use All Gases As CO2e", false);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenter(MachineCenter, '', LibraryRandom.RandDec(10, 1));

        // [WHEN] Open "Machine Center List".
        MachineCenterList.OpenView();
        MachineCenterList.GoToRecord(MachineCenter);

        // [VERIFY] Verify "Calculate Total CO2e" action should not be visible on "Machine Center List" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            MachineCenterList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, MachineCenterList.Caption()));
        Assert.AreEqual(
            false,
            MachineCenterList."Calculate Total CO2e".Visible(),
            StrSubstNo(CalculateTotalCO2eActionShouldNotBeVisibleErr, MachineCenterList.Caption()));

        // [GIVEN] Close "Machine Center List".
        MachineCenterList.Close();

        // [GIVEN] Update "Work/Machine Center Emissions" and "Use All Gases As CO2e" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Validate("Use All Gases As CO2e", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Machine Center List".
        MachineCenterList.OpenView();
        MachineCenterList.GoToRecord(MachineCenter);

        // [VERIFY] Verify "Calculate Total CO2e" action should be visible on "Machine Center List" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            MachineCenterList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, MachineCenterList.Caption()));
        Assert.AreEqual(
           true,
           MachineCenterList."Calculate Total CO2e".Visible(),
           StrSubstNo(CalculateTotalCO2eActionShouldBeVisibleErr, MachineCenterList.Caption()));
    end;

    [Test]
    procedure VerifyCalculateTotalCO2eShouldbeVisibleOnWorkCenterCardIfWorkMachineCenterEmissionsAndUseAllGasesAsCO2eIsEnabled()
    var
        WorkCenter: Record "Work Center";
        SustainabilitySetup: Record "Sustainability Setup";
        WorkCenterCard: TestPage "Work Center Card";
    begin
        // [SCENARIO 537413] Verify "Calculate Total CO2e" action should be visible on "Work Center Card" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenter(WorkCenter);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" and "Use All Gases As CO2e" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Validate("Use All Gases As CO2e", false);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Work Center Card".
        WorkCenterCard.OpenView();
        WorkCenterCard.GoToRecord(WorkCenter);

        // [VERIFY] Verify "Calculate Total CO2e" action should not be visible on "Work Center Card" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            WorkCenterCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, WorkCenterCard.Caption()));
        Assert.AreEqual(
            false,
            WorkCenterCard."Calculate Total CO2e".Visible(),
            StrSubstNo(CalculateTotalCO2eActionShouldNotBeVisibleErr, WorkCenterCard.Caption()));

        // [GIVEN] Close "Work Center Card".
        WorkCenterCard.Close();

        // [GIVEN] Update "Work/Machine Center Emissions" and "Use All Gases As CO2e" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Validate("Use All Gases As CO2e", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Work Center Card".
        WorkCenterCard.OpenView();
        WorkCenterCard.GoToRecord(WorkCenter);

        // [VERIFY] Verify "Calculate Total CO2e" action should be visible on "Work Center Card" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            WorkCenterCard."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, WorkCenterCard.Caption()));
        Assert.AreEqual(
           true,
           WorkCenterCard."Calculate Total CO2e".Visible(),
           StrSubstNo(CalculateTotalCO2eActionShouldBeVisibleErr, WorkCenterCard.Caption()));
    end;

    [Test]
    procedure VerifyCalculateTotalCO2eShouldbeVisibleOnWorkCenterListIfWorkMachineCenterEmissionsAndUseAllGasesAsCO2eIsEnabled()
    var
        WorkCenter: Record "Work Center";
        SustainabilitySetup: Record "Sustainability Setup";
        WorkCenterList: TestPage "Work Center List";
    begin
        // [SCENARIO 537413] Verify "Calculate Total CO2e" action should be visible on "Work Center List" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenter(WorkCenter);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Work/Machine Center Emissions" and "Use All Gases As CO2e" to false in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", false);
        SustainabilitySetup.Validate("Use All Gases As CO2e", false);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Work Center List".
        WorkCenterList.OpenView();
        WorkCenterList.GoToRecord(WorkCenter);

        // [VERIFY] Verify "Calculate Total CO2e" action should not be visible on "Work Center List" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is not enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            WorkCenterList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, WorkCenterList.Caption()));
        Assert.AreEqual(
            false,
            WorkCenterList."Calculate Total CO2e".Visible(),
            StrSubstNo(CalculateTotalCO2eActionShouldNotBeVisibleErr, WorkCenterList.Caption()));

        // [GIVEN] Close "Work Center List".
        WorkCenterList.Close();

        // [GIVEN] Update "Work/Machine Center Emissions" and "Use All Gases As CO2e" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Work/Machine Center Emissions", true);
        SustainabilitySetup.Validate("Use All Gases As CO2e", true);
        SustainabilitySetup.Modify(true);

        // [WHEN] Open "Work Center List".
        WorkCenterList.OpenView();
        WorkCenterList.GoToRecord(WorkCenter);

        // [VERIFY] Verify "Calculate Total CO2e" action should be visible on "Work Center List" page If "Work/Machine Center Emissions" and "Use All Gases As CO2e" is enabled in Sustainability Setup.
        Assert.AreEqual(
            false,
            WorkCenterList."Calculate CO2e".Visible(),
            StrSubstNo(ActionShouldNotBeVisibleErr, WorkCenterList.Caption()));
        Assert.AreEqual(
           true,
           WorkCenterList."Calculate Total CO2e".Visible(),
           StrSubstNo(CalculateTotalCO2eActionShouldBeVisibleErr, WorkCenterList.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnJobIsEnableValueChainTrackingIsTrue()
    var
        JobTask: Record "Job Task";
        JobCard: TestPage "Job Card";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are Visible on Job Card and Lines
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [WHEN] Open "Job Card".
        JobCard.OpenEdit();
        JobCard.FILTER.SetFilter("No.", JobTask."Job No.");

        // [THEN] "Total CO2e" is Visible on "Job Card".
        Assert.IsTrue(
            JobCard."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobCard."Total CO2e".Caption(),
                JobCard.Caption()));

        // [THEN] Total CO2e is Visible on Lines of Job.
        Assert.IsTrue(
            JobCard.JobTaskLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobCard.JobTaskLines."Total CO2e".Caption(),
                JobCard.JobTaskLines.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnJobIsEnableValueChainTrackingIsFalse()
    var
        JobTask: Record "Job Task";
        JobCard: TestPage "Job Card";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are not Visible on Job Card and Lines
        // if Enable Value Chain Tracking is False in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [WHEN] Open "Job Card".
        JobCard.OpenEdit();
        JobCard.FILTER.SetFilter("No.", JobTask."Job No.");

        // [THEN] "Total CO2e" is not Visible on "Job Card".
        Assert.IsFalse(
            JobCard."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobCard."Total CO2e".Caption(),
                JobCard.Caption()));

        // [THEN] Total CO2e is not Visible on Lines of Job.
        Assert.IsFalse(
            JobCard.JobTaskLines."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobCard.JobTaskLines."Total CO2e".Caption(),
                JobCard.JobTaskLines.Caption()));
    end;

    [Test]
    [HandlerFunctions('JobJournalTemplateModalPageHandler')]
    procedure VerifySustFieldsAreVisibleOnJobJournalIsEnableValueChainTrackingIsTrue()
    var
        JobTask: Record "Job Task";
        JobJournalLine: Record "Job Journal Line";
        JobJournal: TestPage "Job Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ResourceNo: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are Visible on Job Journal
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create a Resource.
        ResourceNo := LibraryJob.CreateConsumable("Job Planning Line Type"::Resource);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Resource, ResourceNo, AccountCode, Quantity, TotalCO2e);

        // [WHEN] Open "Job Journal".
        JobJournal.OpenEdit();

        // [THEN] "Sust. Account No.","Total CO2e" is Visible on "Job Journal".
        Assert.IsTrue(
            JobJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobJournal."Total CO2e".Caption(),
                JobJournal.Caption()));

        Assert.IsTrue(
            JobJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobJournal."Sust. Account No.".Caption(),
                JobJournal.Caption()));
    end;

    [Test]
    [HandlerFunctions('JobJournalTemplateModalPageHandler')]
    procedure VerifySustFieldsAreNotVisibleOnJobJournalIsEnableValueChainTrackingIsFalse()
    var
        JobTask: Record "Job Task";
        JobJournalLine: Record "Job Journal Line";
        JobJournal: TestPage "Job Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ResourceNo: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are not Visible on Job Journal
        // if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create a Resource.
        ResourceNo := LibraryJob.CreateConsumable("Job Planning Line Type"::Resource);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Resource, ResourceNo, AccountCode, Quantity, TotalCO2e);

        // [WHEN] Open "Job Journal".
        JobJournal.OpenEdit();

        // [THEN] "Sust. Account No.","Total CO2e" is not Visible on "Job Journal".
        Assert.IsFalse(
            JobJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobJournal."Total CO2e".Caption(),
                JobJournal.Caption()));

        Assert.IsFalse(
            JobJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobJournal."Sust. Account No.".Caption(),
                JobJournal.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnJobGLJournalIsEnableValueChainTrackingIsTrue()
    var
        JobTask: Record "Job Task";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        JobGLJournal: TestPage "Job G/L Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are Visible on Job GL Journal
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create and Update Job Journal Batch.
        CreateAndUpdateJobJournalBatch(GenJournalBatch);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobGLJournalLine(
            GenJournalLine,
            GenJournalBatch,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountNo(),
            LibraryERM.CreateGLAccountNo(),
            JobTask."Job No.",
            JobTask."Job Task No.",
            '',
            Quantity);

        GenJournalLine.Validate("Sust. Account No.", AccountCode);
        GenJournalLine.Validate("Total CO2e", TotalCO2e);
        GenJournalLine.Modify();

        // [WHEN] Open "Job G/L Journal".
        JobGLJournal.OpenEdit();

        // [THEN] "Sust. Account No.","Total CO2e" is Visible on "Job G/L Journal".
        Assert.IsTrue(
            JobGLJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobGLJournal."Total CO2e".Caption(),
                JobGLJournal.Caption()));

        Assert.IsTrue(
            JobGLJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobGLJournal."Sust. Account No.".Caption(),
                JobGLJournal.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnJobGLJournalIsEnableValueChainTrackingIsFalse()
    var
        JobTask: Record "Job Task";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        JobGLJournal: TestPage "Job G/L Journal";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are not Visible on Job GL Journal
        // if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create and Update Job Journal Batch.
        CreateAndUpdateJobJournalBatch(GenJournalBatch);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobGLJournalLine(
            GenJournalLine,
            GenJournalBatch,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountNo(),
            LibraryERM.CreateGLAccountNo(),
            JobTask."Job No.",
            JobTask."Job Task No.",
            '',
            Quantity);

        GenJournalLine.Validate("Sust. Account No.", AccountCode);
        GenJournalLine.Validate("Total CO2e", TotalCO2e);
        GenJournalLine.Modify();

        // [WHEN] Open "Job G/L Journal".
        JobGLJournal.OpenEdit();

        // [THEN] "Sust. Account No.","Total CO2e" is not Visible on "Job G/L Journal".
        Assert.IsFalse(
            JobGLJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobGLJournal."Total CO2e".Caption(),
                JobGLJournal.Caption()));

        Assert.IsFalse(
            JobGLJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobGLJournal."Sust. Account No.".Caption(),
                JobGLJournal.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreVisibleOnJobStatisticsIsEnableValueChainTrackingIsTrue()
    var
        JobTask: Record "Job Task";
        JobCard: TestPage "Job Card";
        JobStatistics: TestPage "Job Statistics";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are Visible on Job Statistics
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Open "Job Card".
        JobCard.OpenEdit();
        JobCard.FILTER.SetFilter("No.", JobTask."Job No.");
        JobStatistics.Trap();

        // [WHEN] Invoke "Job Statistics".
        JobCard."&Statistics".Invoke();

        // [THEN] "G/L Account (Total CO2e)", "Resource (Total CO2e)", "Item (Total CO2e)", "Total CO2e" are Visible on "Job Statistics".
        Assert.IsTrue(
            JobStatistics."G/L Account (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobStatistics."G/L Account (Total CO2e)".Caption(),
                JobStatistics.Caption()));
        Assert.IsTrue(
            JobStatistics."Resource (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobStatistics."Resource (Total CO2e)".Caption(),
                JobStatistics.Caption()));
        Assert.IsTrue(
            JobStatistics."Item (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobStatistics."Item (Total CO2e)".Caption(),
                JobStatistics.Caption()));
        Assert.IsTrue(
            JobStatistics."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobStatistics."Total CO2e".Caption(),
                JobStatistics.Caption()));
    end;

    [Test]
    procedure VerifySustFieldsAreNotVisibleOnJobStatisticsIsEnableValueChainTrackingIsFalse()
    var
        JobTask: Record "Job Task";
        JobCard: TestPage "Job Card";
        JobStatistics: TestPage "Job Statistics";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are not Visible on Job Statistics
        // if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Open "Job Card".
        JobCard.OpenEdit();
        JobCard.FILTER.SetFilter("No.", JobTask."Job No.");
        JobStatistics.Trap();

        // [WHEN] Invoke "Job Statistics".
        JobCard."&Statistics".Invoke();

        // [THEN] "G/L Account (Total CO2e)", "Resource (Total CO2e)", "Item (Total CO2e)", "Total CO2e" are not Visible on "Job Statistics".
        Assert.IsFalse(
            JobStatistics."G/L Account (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobStatistics."G/L Account (Total CO2e)".Caption(),
                JobStatistics.Caption()));
        Assert.IsFalse(
            JobStatistics."Resource (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobStatistics."Resource (Total CO2e)".Caption(),
                JobStatistics.Caption()));
        Assert.IsFalse(
            JobStatistics."Item (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobStatistics."Item (Total CO2e)".Caption(),
                JobStatistics.Caption()));
        Assert.IsFalse(
            JobStatistics."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobStatistics."Total CO2e".Caption(),
                JobStatistics.Caption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure VerifySustFieldsAreVisibleOnJobTaskStatisticsIsEnableValueChainTrackingIsTrue()
    var
        JobTask: Record "Job Task";
        GLAccount: Record "G/L Account";
        JobJournalLine: Record "Job Journal Line";
        JobTaskLines: TestPage "Job Task Lines";
        JobTaskStatistics: TestPage "Job Task Statistics";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are Visible on Job Task Statistics
        // if Enable Value Chain Tracking is true in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an "G/L Account".
        LibraryERM.CreateGLAccount(GLAccount);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::"G/L Account", GLAccount."No.", AccountCode, Quantity, -TotalCO2e);

        // [GIVEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Open Job Task Lines.
        JobTaskLines.OpenEdit();
        JobTaskLines.FILTER.SetFilter("Job No.", JobTask."Job No.");
        JobTaskStatistics.Trap();

        // [WHEN] Invoke "Job Task Statistics".
        JobTaskLines.JobTaskStatistics.Invoke();

        // [THEN] "G/L Account (Total CO2e)", "Resource (Total CO2e)", "Item (Total CO2e)", "Total CO2e" are Visible on "Job Task Statistics".
        Assert.IsTrue(
            JobTaskStatistics."G/L Account (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobTaskStatistics."G/L Account (Total CO2e)".Caption(),
                JobTaskStatistics.Caption()));
        Assert.IsTrue(
            JobTaskStatistics."Resource (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobTaskStatistics."Resource (Total CO2e)".Caption(),
                JobTaskStatistics.Caption()));
        Assert.IsTrue(
            JobTaskStatistics."Item (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobTaskStatistics."Item (Total CO2e)".Caption(),
                JobTaskStatistics.Caption()));
        Assert.IsTrue(
            JobTaskStatistics."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                JobTaskStatistics."Total CO2e".Caption(),
                JobTaskStatistics.Caption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure VerifySustFieldsAreNotVisibleOnJobTaskStatisticsIsEnableValueChainTrackingIsFalse()
    var
        JobTask: Record "Job Task";
        GLAccount: Record "G/L Account";
        JobJournalLine: Record "Job Journal Line";
        JobTaskLines: TestPage "Job Task Lines";
        JobTaskStatistics: TestPage "Job Task Statistics";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Fields are Visible on Job Task Statistics
        // if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an "G/L Account".
        LibraryERM.CreateGLAccount(GLAccount);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::"G/L Account", GLAccount."No.", AccountCode, Quantity, -TotalCO2e);

        // [GIVEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Open Job Task Lines.
        JobTaskLines.OpenEdit();
        JobTaskLines.FILTER.SetFilter("Job No.", JobTask."Job No.");
        JobTaskStatistics.Trap();

        // [WHEN] Invoke "Job Task Statistics".
        JobTaskLines.JobTaskStatistics.Invoke();

        // [THEN] "G/L Account (Total CO2e)", "Resource (Total CO2e)", "Item (Total CO2e)", "Total CO2e" are not Visible on "Job Task Statistics".
        Assert.IsFalse(
            JobTaskStatistics."G/L Account (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobTaskStatistics."G/L Account (Total CO2e)".Caption(),
                JobTaskStatistics.Caption()));
        Assert.IsFalse(
            JobTaskStatistics."Resource (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobTaskStatistics."Resource (Total CO2e)".Caption(),
                JobTaskStatistics.Caption()));
        Assert.IsFalse(
            JobTaskStatistics."Item (Total CO2e)".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobTaskStatistics."Item (Total CO2e)".Caption(),
                JobTaskStatistics.Caption()));
        Assert.IsFalse(
            JobTaskStatistics."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                JobTaskStatistics."Total CO2e".Caption(),
                JobTaskStatistics.Caption()));
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

    local procedure CreateProductionBOM(var ProductionBOMHeader: Record "Production BOM Header"; CompItem: Record Item; CO2ePerUnit: Decimal)
    var
        ProductionBOMLine: Record "Production BOM Line";
    begin
        LibraryManufacturing.CreateProductionBOMHeader(ProductionBOMHeader, CompItem."Base Unit of Measure");
        LibraryManufacturing.CreateProductionBOMLine(ProductionBOMHeader, ProductionBOMLine, '', ProductionBOMLine.Type::Item, CompItem."No.", 1);
        if CO2ePerUnit <> 0 then begin
            ProductionBOMLine.Validate("CO2e per Unit", CO2ePerUnit);
            ProductionBOMLine.Modify();
        end;
        LibraryManufacturing.UpdateProductionBOMStatus(ProductionBOMHeader, ProductionBOMHeader.Status::Certified);
    end;

    local procedure CreateRoutingWithWorkCenter(var WorkCenter: Record "Work Center"; CO2ePerUnit: Decimal): Code[20]
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
    begin
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLine, '', Format(LibraryRandom.RandInt(100)), RoutingLine.Type::"Work Center", WorkCenter."No.");
        if CO2ePerUnit <> 0 then begin
            RoutingLine.Validate("CO2e per Unit", CO2ePerUnit);
            RoutingLine.Modify();
        end;

        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify(true);

        exit(RoutingHeader."No.");
    end;

    local procedure FindProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"; ProductionOrder: Record "Production Order"; ItemNo: Code[20])
    begin
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.SetRange("Item No.", ItemNo);
        ProdOrderLine.FindFirst();
    end;

    local procedure PostInventoryForItem(ItemNo: Code[20])
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        SelectItemJournalBatch(ItemJournalBatch);
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name, ItemJournalLine."Entry Type"::Purchase, ItemNo, LibraryRandom.RandIntInRange(100, 100));
        LibraryInventory.PostItemJournalBatch(ItemJournalBatch);
    end;

    local procedure SelectItemJournalBatch(var ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        SelectItemJournalBatchByTemplateType(ItemJournalBatch, ItemJournalTemplate.Type::Item);
    end;

    local procedure SelectItemJournalBatchByTemplateType(var ItemJournalBatch: Record "Item Journal Batch"; TemplateType: Enum "Item Journal Template Type")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, TemplateType);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
    end;

    local procedure CreateAndRefreshProductionOrder(var ProductionOrder: Record "Production Order"; Status: Enum "Production Order Status"; SourceNo: Code[20]; Quantity: Decimal)
    begin
        LibraryManufacturing.CreateProductionOrder(ProductionOrder, Status, ProductionOrder."Source Type"::Item, SourceNo, Quantity);

        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, true, true, true, false);
    end;

    local procedure CreateItems(var ProdItem: Record Item; var CompItem: Record Item)
    begin
        LibraryInventory.CreateItem(CompItem);
        LibraryInventory.CreateItem(ProdItem);
        ProdItem.Validate("Costing Method", ProdItem."Costing Method"::Standard);
        ProdItem.Validate("Replenishment System", ProdItem."Replenishment System"::"Prod. Order");
        ProdItem.Modify(true);
    end;

    local procedure GetTransferShipmentHeader(var TransferShipmentHeader: Record "Transfer Shipment Header"; FromLocationCode: Code[10])
    begin
        TransferShipmentHeader.SetRange("Transfer-from Code", FromLocationCode);
        TransferShipmentHeader.FindSet();
    end;

    local procedure CreateTransferOrderWithLocation(var TransferHeader: Record "Transfer Header"; Item: Record Item; FromLocationCode: Code[10]; ToLocationCode: Code[10]; IntransitLocationCode: Code[10]; Quantity: Decimal; CO2ePerUnit: Decimal)
    var
        TransferLine: Record "Transfer Line";
    begin
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocationCode, ToLocationCode, IntransitLocationCode);

        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, Item."No.", Quantity);
        TransferLine.Validate("CO2e per Unit", CO2ePerUnit);
        TransferLine.Modify();
    end;

    local procedure CreateItemWithInventory(var Item: Record Item; FromLocationCode: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", FromLocationCode, '', LibraryRandom.RandIntInRange(100, 200));
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;

    local procedure GetPostedAssemblyHeader(var PostedAssemblyHeader: Record "Posted Assembly Header"; ItemNo: Code[20])
    begin
        PostedAssemblyHeader.SetRange("Item No.", ItemNo);
        PostedAssemblyHeader.FindSet();
    end;

    local procedure AddItemToInventory(Item: Record Item; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
#pragma warning disable AA0210
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Item);
        ItemJournalTemplate.SetRange(Recurring, false);
        ItemJournalTemplate.FindFirst();
#pragma warning restore AA0210
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();

        LibraryInventory.CreateItemJournalLine(
            ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
            ItemJournalLine."Entry Type"::"Positive Adjmt.", Item."No.", Quantity);

        LibraryInventory.PostItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name);
    end;

    local procedure CreateAndUpdateSustAccOnCompItem(ParentItem: Record Item; var CompItem: Record Item; var AccountCode: Code[20]; CO2ePerUnit: Decimal)
    var
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        CompItem.Get(GetBOMComponentItemNo(ParentItem));
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", CO2ePerUnit);
        CompItem.Modify();
    end;

    local procedure GetBOMComponentItemNo(ParentItem: Record Item): Code[20]
    var
        BOMComponent: Record "BOM Component";
    begin
        BOMComponent.SetRange("Parent Item No.", ParentItem."No.");
        BOMComponent.FindFirst();

        exit(BOMComponent."No.")
    end;

    local procedure CreateAssembledItem(var Item: Record Item; AssemblyPolicy: Enum "Assembly Policy"; NoOfComponents: Integer; QtyPer: Decimal)
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Replenishment System", Item."Replenishment System"::Assembly);
        Item.Validate("Assembly Policy", AssemblyPolicy);
        Item.Modify(true);

        CreateAssemblyList(Item, NoOfComponents, QtyPer);
    end;

    local procedure CreateAssemblyList(ParentItem: Record Item; NoOfComponents: Integer; QtyPer: Decimal)
    var
        Item: Record Item;
        AssemblyLine: Record "Assembly Line";
        BOMComponent: Record "BOM Component";
        CompCount: Integer;
    begin
        // Add components - qty per is increasing same as no of components
        for CompCount := 1 to NoOfComponents do begin
            Clear(Item);
            LibraryInventory.CreateItem(Item);
            LibraryAssembly.AddEntityDimensions(AssemblyLine.Type::Item, Item."No.");
            AddComponentToAssemblyList(BOMComponent, "BOM Component Type"::Item, Item."No.", ParentItem."No.", '', Item."Base Unit of Measure", QtyPer);
        end;
    end;

    local procedure AddComponentToAssemblyList(var BOMComponent: Record "BOM Component"; ComponentType: Enum "BOM Component Type"; ComponentNo: Code[20]; ParentItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; QuantityPer: Decimal)
    begin
        LibraryInventory.CreateBOMComponent(BOMComponent, ParentItemNo, ComponentType, ComponentNo, QuantityPer, UOM);
        BOMComponent.Validate("Variant Code", VariantCode);
        if ComponentNo = '' then
            BOMComponent.Validate(Description,
              LibraryUtility.GenerateRandomCode(BOMComponent.FieldNo(Description), DATABASE::"BOM Component"));
        BOMComponent.Modify(true);
    end;

    local procedure SelectItemJournal(var ItemJournalBatch: Record "Item Journal Batch"; TemplateType: Enum "Item Journal Template Type")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, TemplateType);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, TemplateType, ItemJournalTemplate.Name);
        LibraryInventory.ClearItemJournal(ItemJournalTemplate, ItemJournalBatch);
    end;

    local procedure CreateAndPostOutputJournalLine(ItemNo: Code[20]; ProdOrderRoutingLine: Record "Prod. Order Routing Line"; ProductionOrder: Record "Production Order"; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        CreateOutputJournalLine(ItemJournalLine, ItemNo, ProductionOrder."No.", Quantity);
        ItemJournalLine.Validate("Operation No.", ProdOrderRoutingLine."Operation No.");
        ItemJournalLine.Modify(true);
        LibraryManufacturing.PostOutputJournal();
    end;

    local procedure CreateOutputJournalLine(var ItemJournalLine: Record "Item Journal Line"; ItemNo: Code[20]; ProdOrderNo: Code[20]; OutputQty: Decimal)
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        InitItemJournalBatch(ItemJournalBatch, ItemJournalBatch."Template Type"::Output);
        ItemJournalTemplate.Get(ItemJournalBatch."Journal Template Name");
        LibraryManufacturing.CreateOutputJournal(ItemJournalLine, ItemJournalTemplate, ItemJournalBatch, ItemNo, ProdOrderNo);
        ItemJournalLine.Validate("Output Quantity", OutputQty);
        ItemJournalLine.Modify(true);
    end;

    local procedure InitItemJournalBatch(var ItemJournalBatch: Record "Item Journal Batch"; TemplateType: Enum "Item Journal Template Type")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, TemplateType);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, TemplateType, ItemJournalTemplate.Name);
        LibraryInventory.ClearItemJournal(ItemJournalTemplate, ItemJournalBatch);
    end;

    local procedure CreateJobWithJobTask(var JobTask: Record "Job Task")
    var
        Job: Record Job;
    begin
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);
    end;

    local procedure CreateJobJournalLine(var JobJournalLine: Record "Job Journal Line"; JobTask: Record "Job Task"; JobJournalLineType: Enum "Job Journal Line Type"; No: Code[20]; AccountCode: Code[20]; Quantity: Decimal; TotalCO2e: Decimal)
    begin
        LibraryJob.CreateJobJournalLineForType("Job Line Type"::" ", JobJournalLineType, JobTask, JobJournalLine);
        JobJournalLine.Validate("No.", No);
        JobJournalLine.Validate(Quantity, Quantity);
        JobJournalLine.Validate("Sust. Account No.", AccountCode);
        JobJournalLine.Validate("Total CO2e", TotalCO2e);
        JobJournalLine.Modify(true);
    end;

    local procedure CreateAndUpdateJobJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        CreateJobJournalBatch(GenJournalBatch);
        GenJournalBatch.Validate("Copy VAT Setup to Jnl. Lines", false);
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateJobJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Jobs);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateJobGLJournalLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; BalAccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BalAccountNo: Code[20]; JobNo: Code[20]; JobTaskNo: Code[20]; CurrencyCode: Code[10]; Quantity: Decimal)
    begin
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::"G/L Account", AccountNo, LibraryRandom.RandDec(100, 2));

        GenJournalLine.Validate("Bal. Account Type", BalAccountType);
        GenJournalLine.Validate("Bal. Account No.", BalAccountNo);
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Validate("Job Line Type", GenJournalLine."Job Line Type"::"Both Budget and Billable");
        GenJournalLine.Validate("Job No.", JobNo);
        GenJournalLine.Validate("Job Task No.", JobTaskNo);
        GenJournalLine.Validate("Job Quantity", Quantity);
        GenJournalLine.Modify(true);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := true;
    end;

    [ModalPageHandler]
    procedure ProductionJournalModalPageHandler(var ProductionJournal: TestPage "Production Journal")
    begin
        Assert.IsTrue(
            ProductionJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ProductionJournal."Sust. Account No.".Caption(),
                ProductionJournal.Caption()));

        Assert.IsTrue(
            ProductionJournal."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ProductionJournal."CO2e per Unit".Caption(),
                ProductionJournal.Caption()));

        Assert.IsTrue(
            ProductionJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldBeVisibleErr,
                ProductionJournal."Total CO2e".Caption(),
                ProductionJournal.Caption()));

        ProductionJournal.Post.Invoke();
    end;

    [ModalPageHandler]
    procedure ProductionJnlModalPageHandler(var ProductionJournal: TestPage "Production Journal")
    begin
        Assert.IsFalse(
            ProductionJournal."Sust. Account No.".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ProductionJournal."Sust. Account No.".Caption(),
                ProductionJournal.Caption()));

        Assert.IsFalse(
            ProductionJournal."CO2e per Unit".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ProductionJournal."CO2e per Unit".Caption(),
                ProductionJournal.Caption()));

        Assert.IsFalse(
            ProductionJournal."Total CO2e".Visible(),
            StrSubstNo(
                FieldShouldNotBeVisibleErr,
                ProductionJournal."Total CO2e".Caption(),
                ProductionJournal.Caption()));

        ProductionJournal.Post.Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    procedure JobJournalTemplateModalPageHandler(var JobJournalTemplateList: TestPage "Job Journal Template List")
    begin
        JobJournalTemplateList.OK().Invoke();
    end;
}
