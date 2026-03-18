// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Tests;

using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Document;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Item;
using Microsoft.Service.Test;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Ledger;
using Microsoft.Test.Sustainability;

codeunit 148218 "Sustainability Service Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryJob: Codeunit "Library - Job";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryService: Codeunit "Library - Service";
        LibraryResource: Codeunit "Library - Resource";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        IsInitialized: Boolean;
        AccountCodeLbl: Label 'AccountCode%1', Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPostedWithShipAndInvoiceForItem()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service document is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e Per Unit".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 200);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(10, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e Per Unit", CO2ePerUnit);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * ServiceLine.Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * ServiceLine.Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPostedWithShipAndInvoiceForResource()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CO2ePerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service document is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e Per Unit".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 200);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandInt(20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e Per Unit", CO2ePerUnit);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * ServiceLine.Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * ServiceLine.Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPostedWithShipAndConsume()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value Entry should be created when the Service document is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e Per Unit".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 200);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandInt(20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e Per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Consume", ServiceLine.Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * ServiceLine.Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * ServiceLine.Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPostedWithShipAndConsumeForResource()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CO2ePerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value Entry should be created when the Service document is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e Per Unit".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 200);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandInt(20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e Per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Consume", ServiceLine.Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * ServiceLine.Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * ServiceLine.Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPartiallyPostedWithShipAndInvoice()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service document is partially posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e Per Unit".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e Per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Invoice", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -CO2ePerUnit * Quantity, ServiceLine.TableCaption()));
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPartiallyPostedWithShipAndInvoiceForResource()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service document is partially posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Generate "Quantity".
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Invoice", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -CO2ePerUnit * Quantity, ServiceLine.TableCaption()));
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPartiallyPostedWithShipAndConsume()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service document is partially posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Consume", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -CO2ePerUnit * Quantity, ServiceLine.TableCaption()));
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPartiallyPostedWithShipAndConsumeForResource()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service document is partially posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e" and "Quantity".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Consume", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -CO2ePerUnit * Quantity, ServiceLine.TableCaption()));
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPartiallyPostedWithShip()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service document is partially posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Ship", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));

        // [WHEN] Post the Service Order with Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, false, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -CO2ePerUnit * Quantity, ServiceLine.TableCaption()));
    end;

    [Test]
    procedure SustainabilityValueEntryShouldNotBeCreatedWhenServiceDocumentIsPartiallyPostedWithShipForResource()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should not be created when the Service document is partially posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit" and "Quantity".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Ship", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, false);

        // [THEN] Verify Sustainability Value entry must not be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityValueEntry, 0);

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));

        // [WHEN] Post the Service Order with Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, false, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            0,
            0,
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -CO2ePerUnit * Quantity, ServiceLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure SustainabilityValueEntryShouldBeCreatedWhenUndoConsumptionIsPosted()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Undo Consumption is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit" and "Quantity".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Consume", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -CO2ePerUnit * Quantity, ServiceLine.TableCaption()));

        // [WHEN] Undo Consumption Lines.
        LibraryService.UndoConsumptionLinesByServiceOrderNo(ServiceHeader."No.");

        // [THEN] Verify Sustainability Value entry must be created When Undo Consumption is posted.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityValueEntry, 2);

        SustainabilityValueEntry.CalcSums("CO2e Amount (Expected)", "CO2e Amount (Actual)");
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure SustainabilityValueEntryShouldBeCreatedWhenUndoConsumptionIsPostedForResource()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Undo Consumption is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit" and "Quantity".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Consume", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -CO2ePerUnit * Quantity, ServiceLine.TableCaption()));

        // [WHEN] Undo Consumption Lines.
        LibraryService.UndoConsumptionLinesByServiceOrderNo(ServiceHeader."No.");

        // [THEN] Verify Sustainability Value entry must be created When Undo Consumption is posted.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityValueEntry, 2);

        SustainabilityValueEntry.CalcSums("CO2e Amount (Expected)", "CO2e Amount (Actual)");
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure SustainabilityValueEntryShouldBeCreatedWhenUndoShipmentIsPosted()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Undo Shipment is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit" and "Quantity".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Ship", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));

        // [WHEN] Undo Consumption Lines.
        LibraryService.UndoShipmentLinesByServiceOrderNo(ServiceHeader."No.");

        // [THEN] Verify Sustainability Value entry must be created When Undo Consumption is posted.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityValueEntry, 4);

        SustainabilityValueEntry.CalcSums("CO2e Amount (Expected)", "CO2e Amount (Actual)");
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure SustainabilityValueEntryShouldNotBeCreatedWhenUndoShipmentIsPostedForResource()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should not be created when the Undo Shipment is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit" and "Quantity".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Ship", Quantity);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, false);

        // [THEN] Verify Sustainability Value entry must not be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityValueEntry, 0);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));

        // [WHEN] Undo Consumption Lines.
        LibraryService.UndoShipmentLinesByServiceOrderNo(ServiceHeader."No.");

        // [THEN] Verify Sustainability Value entry must not be created When Undo Consumption is posted.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityValueEntry, 0);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceInvoiceIsPosted()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service Invoice is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit" and "Quantity".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Invoice.
        CreateServiceInvoiceWithServiceLine(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Item."No.");
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Modify();

        // [WHEN] Post the Service Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        SustainabilityValueEntry.SetRange("Document No.", ServiceInvoiceHeader."No.");
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            -CO2ePerUnit * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * Quantity, SustainabilityValueEntry.TableCaption()));
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceInvoiceIsPostedForResource()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service Invoice is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per Unit" and "Quantity".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 500);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Invoice.
        CreateServiceInvoiceWithServiceLineForResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Resource."No.");
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e per Unit", CO2ePerUnit);
        ServiceLine.Modify();

        // [WHEN] Post the Service Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        SustainabilityValueEntry.SetRange("Document No.", ServiceInvoiceHeader."No.");
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            -Quantity * CO2ePerUnit,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -Quantity * CO2ePerUnit, SustainabilityValueEntry.TableCaption()));
    end;

    [Test]
    procedure TotalCO2eEmissionMustBeAutoFlowFromItem()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        PurchaseHeader: Record "Purchase Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        CountryRegion: Record "Country/Region";
        EmissionFee: array[3] of Record "Emission Fee";
        Item: Record Item;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 580158] Verify Total CO2e Emission must be auto flow from Item.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Emission and Quantity.
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission :=
            (EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor") / Quantity;

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", Quantity, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create a Service Invoice.
        CreateServiceInvoiceWithServiceLine(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Item."No.");
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Modify();

        // [WHEN] Post the Service Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
        SustainabilityValueEntry.SetRange("Document No.", ServiceInvoiceHeader."No.");
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            -ExpectedCO2eEmission * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -ExpectedCO2eEmission * Quantity, SustainabilityValueEntry.TableCaption()));
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceCreditMemoIsPosted()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceCreditMemoHeader: Record "Service Cr.Memo Header";
        PurchaseHeader: Record "Purchase Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        CountryRegion: Record "Country/Region";
        EmissionFee: array[3] of Record "Emission Fee";
        Item: Record Item;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service Credit Memo is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Emission and Quantity.
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission :=
            (EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor") / Quantity;

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", Quantity, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create a Service Credit Memo.
        CreateServiceCrMemoWithServiceLine(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Item."No.");
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Modify();

        // [WHEN] Post the Service Credit Memo.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        FindServiceCreditMemoHeader(ServiceCreditMemoHeader, ServiceHeader."No.");
        SustainabilityValueEntry.SetRange("Document No.", ServiceCreditMemoHeader."No.");
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCO2eEmission * Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), ExpectedCO2eEmission * Quantity, SustainabilityValueEntry.TableCaption()));
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceCreditMemoIsPostedForResource()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceCreditMemoHeader: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quantity: Decimal;
    begin
        // [SCENARIO 580158] Verify Sustainability Value entry should be created when the Service Credit Memo is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Quantity.
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Credit Memo.
        CreateServiceCrMemoWithServiceLineForResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Resource."No.");
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", LibraryRandom.RandInt(100));
        ServiceLine.Modify();

        // [WHEN] Post the Service Credit Memo.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        FindServiceCreditMemoHeader(ServiceCreditMemoHeader, ServiceHeader."No.");
        SustainabilityValueEntry.SetRange("Document No.", ServiceCreditMemoHeader."No.");
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            Quantity,
            SustainabilityValueEntry."Valued Quantity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            Quantity,
            SustainabilityValueEntry."Invoiced Quantity",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Total CO2e",
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), ServiceLine."Total CO2e", SustainabilityValueEntry.TableCaption()));
    end;

    [Test]
    procedure ServiceShipmentHeaderAndServiceInvoiceHeaderIsCreatedWithSustainabilityAccount()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Service Shipment Header and Service Invoice Header is created with Sustainability Account.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, false);

        // [THEN] Verify Service Shipment Line must be created with Sustainability Account.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));

        // [WHEN] Post the Service Order with Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, false, false, true);

        // [THEN] Verify Service Invoice Line must be created with Sustainability Account.
        VerifyServiceInvoiceLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -TotalCO2e / 2,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -TotalCO2e / 2, ServiceLine.TableCaption()));
    end;

    [Test]
    procedure ServiceShipmentHeaderAndServiceInvoiceHeaderIsCreatedWithSustainabilityAccountForResource()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Service Shipment Header and Service Invoice Header is created with Sustainability Account.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, false);

        // [THEN] Verify Service Shipment Line must be created with Sustainability Account.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            0,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), 0, ServiceLine.TableCaption()));

        // [WHEN] Post the Service Order with Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, false, false, true);

        // [THEN] Verify Service Invoice Line must be created with Sustainability Account.
        VerifyServiceInvoiceLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -TotalCO2e / 2,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -TotalCO2e / 2, ServiceLine.TableCaption()));
    end;

    [Test]
    procedure ServiceShipmentHeaderIsCreatedWithSustainabilityAccountForConsumption()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Service Shipment Header is created with Sustainability Account For Consumption.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Validate("Qty. to Consume", LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Service Shipment Line must be created with Sustainability Account.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -TotalCO2e / 2,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -TotalCO2e / 2, ServiceLine.TableCaption()));
    end;

    [Test]
    procedure ServiceShipmentHeaderIsCreatedWithSustainabilityAccountForConsumptionForResource()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Service Shipment Header is created with Sustainability Account For Consumption.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Validate("Qty. to Consume", LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Service Shipment Line must be created with Sustainability Account.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [THEN] Verify Posted Total CO2e in Service Line.
        ServiceLine.Get(ServiceLine."Document Type", ServiceHeader."No.", ServiceLine."Line No.");
        Assert.AreEqual(
            -TotalCO2e / 2,
            ServiceLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceLine.FieldCaption("Posted Total CO2e"), -TotalCO2e / 2, ServiceLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ReverseServiceShipmentLineIsCreatedWhenUndoConsumptionIsPosted()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Reverse Service Shipment Line is created when Undo Consumption is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Validate("Qty. to Consume", LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Service Shipment Line must be created with Sustainability Account.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [WHEN] Undo Consumption Lines.
        LibraryService.UndoConsumptionLinesByServiceOrderNo(ServiceHeader."No.");

        // [THEN] Verify Reverse Service Shipment Line is created When Undo Consumption is posted.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, -TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ReverseServiceShipmentLineIsCreatedWhenUndoConsumptionIsPostedForResource()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Reverse Service Shipment Line is created when Undo Consumption is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Validate("Qty. to Consume", LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Service Shipment Line must be created with Sustainability Account.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [WHEN] Undo Consumption Lines.
        LibraryService.UndoConsumptionLinesByServiceOrderNo(ServiceHeader."No.");

        // [THEN] Verify Reverse Service Shipment Line is created When Undo Consumption is posted.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, -TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ReverseServiceShipmentLineIsCreatedWhenUndoShipmentIsPosted()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Reverse Service Shipment Line is created when Undo Shipment is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, false);

        // [THEN] Verify Service Shipment Line must be created with Sustainability Account.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [WHEN] Undo Shipment Lines.
        LibraryService.UndoShipmentLinesByServiceOrderNo(ServiceHeader."No.");

        // [THEN] Verify Reverse Service Shipment Line is created When Undo Shipment is posted.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, -TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ReverseServiceShipmentLineIsCreatedWhenUndoShipmentIsPostedForResource()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Reverse Service Shipment Line is created when Undo Shipment is posted.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Resource."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, false);

        // [THEN] Verify Service Shipment Line must be created with Sustainability Account.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, TotalCO2e);

        // [WHEN] Undo Shipment Lines.
        LibraryService.UndoShipmentLinesByServiceOrderNo(ServiceHeader."No.");

        // [THEN] Verify Reverse Service Shipment Line is created When Undo Shipment is posted.
        VerifyServiceShipmentLine(ServiceHeader, ServiceLine, -TotalCO2e);
    end;

    [Test]
    procedure PostedServiceCrMemoIsPostedWithSustainabilityAccount()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        CountryRegion: Record "Country/Region";
        EmissionFee: array[3] of Record "Emission Fee";
        Item: Record Item;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 580158] Verify Posted Service Cr.Memo is posted with Sustainability Account.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Emission and Quantity.
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission :=
            (EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor") / Quantity;

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", Quantity, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create a Service Credit Memo.
        CreateServiceCrMemoWithServiceLine(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Item."No.");
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Modify();

        // [WHEN] Post the Service Credit Memo.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Service Credit Memo Line must be created with Sustainability Account.
        VerifyServiceCreditMemoLine(ServiceHeader, ServiceLine, ExpectedCO2eEmission * Quantity);
    end;

    [Test]
    procedure PostedServiceCrMemoIsPostedWithSustainabilityAccountForResource()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Resource: Record Resource;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quantity: Decimal;
    begin
        // [SCENARIO 580158] Verify Posted Service Cr.Memo is posted with Sustainability Account.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Quantity.
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Credit Memo.
        CreateServiceCrMemoWithServiceLineForResource(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Resource."No.");
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", LibraryRandom.RandInt(100));
        ServiceLine.Modify();

        // [WHEN] Post the Service Credit Memo.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Service Credit Memo Line must be created with Sustainability Account.
        VerifyServiceCreditMemoLine(ServiceHeader, ServiceLine, ServiceLine."Total CO2e");
    end;

    [Test]
    procedure VerifyTotalCO2eInPostedServiceCreditMemoStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceCreditMemoHeader: Record "Service Cr.Memo Header";
        PurchaseHeader: Record "Purchase Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        CountryRegion: Record "Country/Region";
        EmissionFee: array[3] of Record "Emission Fee";
        Item: Record Item;
        PostedServiceCreditMemo: TestPage "Posted Service Credit Memo";
        ServiceCreditMemoStatistics: TestPage "Service Credit Memo Statistics";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 580158] Verify Total CO2e in Posted Service Credit Memo Statistics.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Emission and Quantity.
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission :=
            (EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor") / Quantity;

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", Quantity, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create a Service Credit Memo.
        CreateServiceCrMemoWithServiceLine(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Item."No.");
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Modify();

        // [GIVEN] Post the Service Credit Memo.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [GIVEN] Find the Service Credit Memo Header.
        FindServiceCreditMemoHeader(ServiceCreditMemoHeader, ServiceHeader."No.");

        // [WHEN] Open Posted Service Credit Memo Page and Go to Service Statistics.
        ServiceCreditMemoStatistics.Trap();
        PostedServiceCreditMemo.OpenEdit();
        PostedServiceCreditMemo.GoToRecord(ServiceCreditMemoHeader);
        PostedServiceCreditMemo.ServiceStatistics.Invoke();

        // [THEN] Verify Total CO2e in "Service Credit Memo Statistics".
        ServiceCreditMemoStatistics."Total CO2e".AssertEquals(Quantity * ExpectedCO2eEmission);
    end;

    [Test]
    procedure VerifyTotalCO2eInPostedServiceInvoiceStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        PostedServiceInvoice: TestPage "Posted Service Invoice";
        ServiceInvoiceStatistics: TestPage "Service Invoice Statistics";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Total CO2e in Posted Service Invoice Statistics.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Invoice.
        CreateServiceInvoiceWithServiceLine(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Item."No.");
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Modify();

        // [GIVEN] Post the Service Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [GIVEN] Find the Service Invoice Header.
        FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");

        // [WHEN] Open Posted Service Invoice Page and Go to Service Statistics.
        ServiceInvoiceStatistics.Trap();
        PostedServiceInvoice.OpenEdit();
        PostedServiceInvoice.GoToRecord(ServiceInvoiceHeader);
        PostedServiceInvoice.ServiceStatistics.Invoke();

        // [THEN] Verify Total CO2e in "Service Invoice Statistics".
        ServiceInvoiceStatistics."Total CO2e".AssertEquals(-TotalCO2e);
    end;

    [Test]
    procedure VerifyTotalCO2eAndPostedTotalCO2eInServiceOrderStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        ServiceOrder: TestPage "Service Order";
        ServiceOrderStatistics: TestPage "Service Order Statistics";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify "Total CO2e" and "Posted Total CO2e" in Service Order Statistics.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", LibraryRandom.RandIntInRange(20, 20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Modify();

        // [GIVEN] Post the Service Order with Ship.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, false);

        // [WHEN] Open Service Order Page and Go to Service Order Statistics.
        ServiceOrderStatistics.Trap();
        ServiceOrder.OpenEdit();
        ServiceOrder.GoToRecord(ServiceHeader);
        ServiceOrder.ServiceOrderStatistics.Invoke();

        // [THEN] Verify Total CO2e in "Service Order Statistics".
        ServiceOrderStatistics."Total CO2e".AssertEquals(TotalCO2e);
        ServiceOrderStatistics."Posted Total CO2e".AssertEquals(0);
        ServiceOrderStatistics.Close();
        ServiceOrder.Close();

        // [GIVEN] Post the Service Order with Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, false, false, true);

        // [WHEN] Open Service Order Page and Go to Service Order Statistics.
        ServiceOrderStatistics.Trap();
        ServiceOrder.OpenEdit();
        ServiceOrder.GoToRecord(ServiceHeader);
        ServiceOrder.ServiceOrderStatistics.Invoke();

        // [THEN] Verify Total CO2e in "Service Order Statistics".
        ServiceOrderStatistics."Total CO2e".AssertEquals(TotalCO2e);
        ServiceOrderStatistics."Posted Total CO2e".AssertEquals(-TotalCO2e / 2);
        ServiceOrderStatistics.Close();
        ServiceOrder.Close();
    end;

    [Test]
    procedure VerifyTotalCO2eInServiceInvoiceStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        ServiceInvoice: TestPage "Service Invoice";
        ServiceStatistics: TestPage "Service Statistics";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Total CO2e in Service Invoice Statistics.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 500);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Invoice.
        CreateServiceInvoiceWithServiceLine(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Item."No.");
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Modify();

        // [WHEN] Open Service Invoice Page and Go to Service Statistics.
        ServiceStatistics.Trap();
        ServiceInvoice.OpenEdit();
        ServiceInvoice.GoToRecord(ServiceHeader);
        ServiceInvoice.ServiceStatistics.Invoke();

        // [THEN] Verify Total CO2e in "Service Invoice Statistics".
        ServiceStatistics."Total CO2e".AssertEquals(TotalCO2e);
        ServiceStatistics."Posted Total CO2e".AssertEquals(0);
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPostedWithShipAndConsumeForJob()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Job: Record Job;
        JobTask: Record "Job Task";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value Entry should be created when the Service document is posted with Ship and Consume for Job.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e Per Unit".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 200);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);
        Job.Get(JobTask."Job No.");

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, Job."Sell-to Customer No.", '', Item."No.", LibraryRandom.RandInt(20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e Per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Consume", ServiceLine.Quantity);
        ServiceLine.Validate("Job No.", JobTask."Job No.");
        ServiceLine.Validate("Job Task No.", JobTask."Job Task No.");
        ServiceLine.Validate("Job Line Type", ServiceLine."Job Line Type"::Billable);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * ServiceLine.Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * ServiceLine.Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure SustainabilityValueEntryShouldBeCreatedWhenServiceDocumentIsPostedWithShipAndConsumeForResourceForJob()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Job: Record Job;
        JobTask: Record "Job Task";
        Resource: Record Resource;
        CO2ePerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify Sustainability Value Entry should be created when the Service document is posted with Ship and Consume for Resource for Job.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e Per Unit".
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 200);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);
        Job.Get(JobTask."Job No.");

        // [GIVEN] Create a Resource.
        LibraryResource.CreateResourceNew(Resource);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithResource(ServiceHeader, ServiceLine, Job."Sell-to Customer No.", '', Resource."No.", LibraryRandom.RandInt(20));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e Per Unit", CO2ePerUnit);
        ServiceLine.Validate("Qty. to Consume", ServiceLine.Quantity);
        ServiceLine.Validate("Job No.", JobTask."Job No.");
        ServiceLine.Validate("Job Task No.", JobTask."Job Task No.");
        ServiceLine.Validate("Job Line Type", ServiceLine."Job Line Type"::Billable);
        ServiceLine.Modify();

        // [WHEN] Post the Service Order with Ship and Consume.
        LibraryService.PostServiceOrder(ServiceHeader, true, true, false);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -CO2ePerUnit * ServiceLine.Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -CO2ePerUnit * ServiceLine.Quantity, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceShipmentHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure VerifySystemMustThrowAnErrorIfTotalCO2eIsZero()
    var
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580158] Verify System must throw an error if Total CO2e is zero.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := 0;

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Post a Positive Adjustment.
        LibraryInventory.PostPositiveAdjustment(Item, '', '', '', LibraryRandom.RandIntInRange(200, 300), WorkDate(), LibraryRandom.RandInt(10));

        // [GIVEN] Create a Service Invoice.
        CreateServiceInvoiceWithServiceLine(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), Item."No.");
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 10));
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("Total CO2e", TotalCO2e);
        ServiceLine.Modify();

        // [WHEN] Post the Service Invoice.
        asserterror LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify System must throw an error if Total CO2e is zero.
        Assert.ExpectedError(CO2eMustNotBeZeroErr);
    end;

    [Test]
    procedure VerifySustValueEntryForServiceOrderWithLotTrackedItemAndSpecificCarbon()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        Item: Record Item;
        CO2ePerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        LotNo: array[2] of Code[50];
        ExpectedCO2eOnLot: array[2] of Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 546875] Verify Sustainability Value entry should be created when the Service document is posted with Ship and Invoice for Lot Tracked Item.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e Per Unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 200);
        Quantity := LibraryRandom.RandIntInRange(10, 20);

        // [GIVEN] Create an Item.
        LibraryItemTracking.CreateLotItem(Item);
        LibrarySustainability.CreateItemWithSpecificCarbonTrackingMethod(Item);
        AddInventoryForLotTrackedItem(Item, LotNo, ExpectedCO2eOnLot, AccountCode, Quantity);

        // [GIVEN] Create a Service Header.
        CreateServiceOrderWithItem(ServiceHeader, ServiceLine, LibrarySales.CreateCustomerNo(), '', Item."No.", Quantity);
        ServiceLine.Validate("Sust. Account No.", AccountCode);
        ServiceLine.Validate("CO2e Per Unit", CO2ePerUnit);
        ServiceLine.Modify();

        // [GIVEN] Create Item Tracking for Service Line.
        CreateServiceLineItemTracking(ServiceLine, '', LotNo[2], ServiceLine.Quantity);

        // [WHEN] Post the Service Order with Ship and Invoice.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // [THEN] Verify Sustainability Value entry must be created.
        SustainabilityValueEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -ExpectedCO2eOnLot[1],
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -ExpectedCO2eOnLot[1], SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", FindServiceInvoiceHeader(ServiceHeader."No."));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sustainability Service Tests");
        LibrarySustainability.CleanUpBeforeTesting();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sustainability Service Tests");

        LibrarySales.SetCreditWarningsToNoWarnings();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateLocalData();
        LibrarySales.SetExtDocNo(false);

        LibraryERMCountryData.CompanyInfoSetVATRegistrationNo();
        IsInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sustainability Service Tests");
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

    local procedure CreateAndPostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"; ItemNo: Code[20]; Quantity: Decimal; CountryRegionCode: Code[10]; AccountCode: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegionCode;
        PurchaseHeader.Modify();

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, ItemNo, Quantity);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure CreateEmissionFeeWithEmissionScope(var EmissionFee: array[3] of Record "Emission Fee"; EmissionScope: Enum "Emission Scope"; CountryRegionCode: Code[10])
    begin
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[1],
            "Emission Type"::CH4,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[2],
            "Emission Type"::CO2,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
        EmissionFee[2].Validate("Carbon Fee", LibraryRandom.RandDecInDecimalRange(0.5, 2, 1));
        EmissionFee[2].Modify();

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[3],
            "Emission Type"::N2O,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
    end;

    local procedure CreateServiceOrderWithItem(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; CustomerNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal)
    var
        ServiceItemLine: Record "Service Item Line";
        ServiceItem: Record "Service Item";
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, CustomerNo);
        ServiceHeader.Validate("Location Code", LocationCode);
        ServiceHeader.Modify(true);

        LibraryService.CreateServiceItem(ServiceItem, ServiceHeader."Customer No.");
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");

        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, ItemNo);
        UpdateServiceLine(ServiceLine, ServiceItemLine."Line No.", Quantity, LibraryRandom.RandDecInRange(1000, 2000, 2));
    end;

    local procedure CreateServiceOrderWithResource(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; CustomerNo: Code[20]; LocationCode: Code[10]; ResourceNo: Code[20]; Quantity: Decimal)
    var
        ServiceItemLine: Record "Service Item Line";
        ServiceItem: Record "Service Item";
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, CustomerNo);
        ServiceHeader.Validate("Location Code", LocationCode);
        ServiceHeader.Modify(true);

        LibraryService.CreateServiceItem(ServiceItem, ServiceHeader."Customer No.");
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");

        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Resource, ResourceNo);
        UpdateServiceLine(ServiceLine, ServiceItemLine."Line No.", Quantity, LibraryRandom.RandDecInRange(1000, 2000, 2));
    end;

    local procedure CreateServiceInvoiceWithServiceLine(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; CustomerNo: Code[20]; ItemNo: Code[20])
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, CustomerNo);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, ItemNo);
    end;

    local procedure CreateServiceInvoiceWithServiceLineForResource(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; CustomerNo: Code[20]; ResourceNo: Code[20])
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, CustomerNo);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Resource, ResourceNo);
    end;

    local procedure CreateServiceCrMemoWithServiceLine(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; CustomerNo: Code[20]; ItemNo: Code[20])
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo", CustomerNo);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, ItemNo);
    end;

    local procedure CreateServiceCrMemoWithServiceLineForResource(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; CustomerNo: Code[20]; ResourceNo: Code[20])
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo", CustomerNo);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Resource, ResourceNo);
    end;

    local procedure UpdateServiceLine(var ServiceLine: Record "Service Line"; ServiceItemLineNo: Integer; Quantity: Decimal; UnitPrice: Decimal)
    begin
        ServiceLine.Validate("Service Item Line No.", ServiceItemLineNo);
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Validate("Unit Price", UnitPrice);
        ServiceLine.Modify(true);
    end;

    local procedure FindServiceShipmentHeader(OrderNo: Code[20]): Code[20]
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
    begin
        ServiceShipmentHeader.SetRange("Order No.", OrderNo);
        ServiceShipmentHeader.FindLast();

        exit(ServiceShipmentHeader."No.");
    end;

    local procedure FindServiceShipmentLine(var ServiceShipmentLine: Record "Service Shipment Line"; DocumentNo: Code[20])
    begin
        ServiceShipmentLine.SetRange("Document No.", DocumentNo);
        ServiceShipmentLine.FindLast();
    end;

    local procedure FindServiceInvoiceHeader(OrderNo: Code[20]): Code[20]
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        ServiceInvoiceHeader.SetRange("Order No.", OrderNo);
        ServiceInvoiceHeader.FindLast();

        exit(ServiceInvoiceHeader."No.");
    end;

    local procedure FindServiceInvoiceLine(var ServiceInvoiceLine: Record "Service Invoice Line"; DocumentNo: Code[20])
    begin
        ServiceInvoiceLine.SetRange("Document No.", DocumentNo);
        ServiceInvoiceLine.FindLast();
    end;

    local procedure FindServiceInvoiceHeader(var ServiceInvoiceHeader: Record "Service Invoice Header"; PreAssignedNo: Code[20])
    begin
        ServiceInvoiceHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        ServiceInvoiceHeader.FindFirst();
    end;

    local procedure FindServiceCreditMemoHeader(var ServiceCreditMemoHeader: Record "Service Cr.Memo Header"; PreAssignedNo: Code[20])
    begin
        ServiceCreditMemoHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        ServiceCreditMemoHeader.FindFirst();
    end;

    local procedure FindServiceCreditMemoLine(var ServiceCreditMemoLine: Record "Service Cr.Memo Line"; DocumentNo: Code[20])
    begin
        ServiceCreditMemoLine.SetRange("Document No.", DocumentNo);
        ServiceCreditMemoLine.FindLast();
    end;

    local procedure CreateJobWithJobTask(var JobTask: Record "Job Task")
    var
        Job: Record Job;
    begin
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);
    end;

    local procedure VerifyServiceShipmentLine(ServiceHeader: Record "Service Header"; ServiceLine: Record "Service Line"; TotalCO2e: Decimal)
    var
        ServiceShipmentLine: Record "Service Shipment Line";
    begin
        FindServiceShipmentLine(ServiceShipmentLine, FindServiceShipmentHeader(ServiceHeader."No."));

        Assert.AreEqual(
            ServiceLine."Sust. Account No.",
            ServiceShipmentLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, ServiceShipmentLine.FieldCaption("Sust. Account No."), ServiceLine."Sust. Account No.", ServiceShipmentLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Sust. Account Name",
            ServiceShipmentLine."Sust. Account Name",
            StrSubstNo(ValueMustBeEqualErr, ServiceShipmentLine.FieldCaption("Sust. Account Name"), ServiceLine."Sust. Account Name", ServiceShipmentLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Sust. Account Category",
            ServiceShipmentLine."Sust. Account Category",
            StrSubstNo(ValueMustBeEqualErr, ServiceShipmentLine.FieldCaption("Sust. Account Category"), ServiceLine."Sust. Account Category", ServiceShipmentLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Sust. Account Subcategory",
            ServiceShipmentLine."Sust. Account Subcategory",
            StrSubstNo(ValueMustBeEqualErr, ServiceShipmentLine.FieldCaption("Sust. Account Subcategory"), ServiceLine."Sust. Account Subcategory", ServiceShipmentLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."CO2e per Unit",
            ServiceShipmentLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, ServiceShipmentLine.FieldCaption("CO2e per Unit"), ServiceLine."CO2e per Unit", ServiceShipmentLine.TableCaption()));
        Assert.AreEqual(
            TotalCO2e / 2,
            ServiceShipmentLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceShipmentLine.FieldCaption("Total CO2e"), TotalCO2e / 2, ServiceShipmentLine.TableCaption()));
    end;

    local procedure VerifyServiceInvoiceLine(ServiceHeader: Record "Service Header"; ServiceLine: Record "Service Line"; TotalCO2e: Decimal)
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
    begin
        FindServiceInvoiceLine(ServiceInvoiceLine, FindServiceInvoiceHeader(ServiceHeader."No."));

        Assert.AreEqual(
            ServiceLine."Sust. Account No.",
            ServiceInvoiceLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, ServiceInvoiceLine.FieldCaption("Sust. Account No."), ServiceLine."Sust. Account No.", ServiceInvoiceLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Sust. Account Name",
            ServiceInvoiceLine."Sust. Account Name",
            StrSubstNo(ValueMustBeEqualErr, ServiceInvoiceLine.FieldCaption("Sust. Account Name"), ServiceLine."Sust. Account Name", ServiceInvoiceLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Sust. Account Category",
            ServiceInvoiceLine."Sust. Account Category",
            StrSubstNo(ValueMustBeEqualErr, ServiceInvoiceLine.FieldCaption("Sust. Account Category"), ServiceLine."Sust. Account Category", ServiceInvoiceLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Sust. Account Subcategory",
            ServiceInvoiceLine."Sust. Account Subcategory",
            StrSubstNo(ValueMustBeEqualErr, ServiceInvoiceLine.FieldCaption("Sust. Account Subcategory"), ServiceLine."Sust. Account Subcategory", ServiceInvoiceLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."CO2e per Unit",
            ServiceInvoiceLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, ServiceInvoiceLine.FieldCaption("CO2e per Unit"), ServiceLine."CO2e per Unit", ServiceInvoiceLine.TableCaption()));
        Assert.AreEqual(
            TotalCO2e / 2,
            ServiceInvoiceLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceInvoiceLine.FieldCaption("Total CO2e"), TotalCO2e / 2, ServiceInvoiceLine.TableCaption()));
    end;

    local procedure VerifyServiceCreditMemoLine(ServiceHeader: Record "Service Header"; ServiceLine: Record "Service Line"; TotalCO2e: Decimal)
    var
        ServiceCreditMemoHeader: Record "Service Cr.Memo Header";
        ServiceCreditMemoLine: Record "Service Cr.Memo Line";
    begin
        FindServiceCreditMemoHeader(ServiceCreditMemoHeader, ServiceHeader."No.");
        FindServiceCreditMemoLine(ServiceCreditMemoLine, ServiceCreditMemoHeader."No.");

        Assert.AreEqual(
            ServiceLine."Sust. Account No.",
            ServiceCreditMemoLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, ServiceCreditMemoLine.FieldCaption("Sust. Account No."), ServiceLine."Sust. Account No.", ServiceCreditMemoLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Sust. Account Name",
            ServiceCreditMemoLine."Sust. Account Name",
            StrSubstNo(ValueMustBeEqualErr, ServiceCreditMemoLine.FieldCaption("Sust. Account Name"), ServiceLine."Sust. Account Name", ServiceCreditMemoLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Sust. Account Category",
            ServiceCreditMemoLine."Sust. Account Category",
            StrSubstNo(ValueMustBeEqualErr, ServiceCreditMemoLine.FieldCaption("Sust. Account Category"), ServiceLine."Sust. Account Category", ServiceCreditMemoLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."Sust. Account Subcategory",
            ServiceCreditMemoLine."Sust. Account Subcategory",
            StrSubstNo(ValueMustBeEqualErr, ServiceCreditMemoLine.FieldCaption("Sust. Account Subcategory"), ServiceLine."Sust. Account Subcategory", ServiceCreditMemoLine.TableCaption()));
        Assert.AreEqual(
            ServiceLine."CO2e per Unit",
            ServiceCreditMemoLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, ServiceCreditMemoLine.FieldCaption("CO2e per Unit"), ServiceLine."CO2e per Unit", ServiceCreditMemoLine.TableCaption()));
        Assert.AreEqual(
            TotalCO2e,
            ServiceCreditMemoLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ServiceCreditMemoLine.FieldCaption("Total CO2e"), TotalCO2e, ServiceCreditMemoLine.TableCaption()));
    end;

    local procedure AddInventoryForLotTrackedItem(var Item: Record Item; var LotNo: array[2] of Code[50]; var ExpectedCO2eOnLot: array[2] of Decimal; AccountCode: Code[20]; Quantity: Decimal)
    var
        Index: Integer;
    begin
        for Index := 1 to ArrayLen(LotNo) do
            LotNo[Index] := LibraryUtility.GenerateGUID();

        for Index := 1 to ArrayLen(ExpectedCO2eOnLot) do
            ExpectedCO2eOnLot[Index] := LibraryRandom.RandDecInRange(200, 600, 2);
        LibrarySustainability.PostPositiveAdjustmentWithItemTracking(Item, '', AccountCode, '', Quantity, WorkDate(), '', LotNo[1], ExpectedCO2eOnLot[1]);
        LibrarySustainability.PostPositiveAdjustmentWithItemTracking(Item, '', AccountCode, '', Quantity, WorkDate(), '', LotNo[2], ExpectedCO2eOnLot[2]);
    end;

    local procedure CreateServiceLineItemTracking(ServiceLine: Record "Service Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ReservEntry: Record "Reservation Entry";
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateAssemblyHeaderItemTracking(ReservEntry, ServiceLine, ItemTrackingSetup, QtyBase);
    end;

    local procedure CreateAssemblyHeaderItemTracking(var ReservEntry: Record "Reservation Entry"; ServiceLine: Record "Service Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ServiceLine);
        LibraryItemTracking.ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;


    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}