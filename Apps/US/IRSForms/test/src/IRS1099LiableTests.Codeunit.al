// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;

codeunit 148019 "IRS 1099 Liable Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [1099]
    end;

    [Test]
    procedure PurchLineHas1099LiableIfHeaderHas1099Code()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        PeriodNo: Code[20];
    begin
        // [SCENARIO 561321] Purchase line has "1099 Liable" option enabled by default if "IRS 1099 Form Box No." is specified in the purchase header

        Initialize();
        // [GIVEN] MISC-01 code is specified for vendor "X"
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), WorkDate(), FormNo, FormBoxNo);
        // [GIVEN] Purchase header for vendor "X"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        // [WHEN] Create purchase line
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        // [THEN] Purchase line has "1099 Liable" option enabled
        PurchaseLine.TestField("1099 Liable");

        // Tear Down
        IRSReportingPeriod.SetRange("No.", PeriodNo);
        IRSReportingPeriod.DeleteAll(true);
    end;

    [Test]
    procedure PurchLineDoNotHave1099LiableIfHeaderDoNotHave1099Code()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO 561321] Purchase line do not have "1099 Liable" option enabled by default if "IRS 1099 Form Box No." is not specified in the purchase header

        Initialize();
        // [GIVEN] Purchase header without 1099 code
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        // [WHEN] Create purchase line
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        // [THEN] Purchase line have "1099 Liable" option disabled
        PurchaseLine.TestField("1099 Liable", false);
    end;

    [Test]
    procedure Cannot1099LiableWithoutFormBoxNoInHeader()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO 562547] Error is thrown when setting "1099 Liable" to true on purchase line when header "IRS 1099 Form Box No." is blank
        Initialize();

        // [GIVEN] Purchase header for vendor "V" without "IRS 1099 Form Box No."
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        // [GIVEN] Purchase line for item "I"
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), 1);

        // [WHEN] Set "1099 Liable" to true on purchase line
        asserterror PurchaseLine.Validate("1099 Liable", true);

        // [THEN] Error is thrown: "You cannot set the "1099 Liable" field because the "IRS 1099 Form Box No." field on the purchase header is blank."
        Assert.ExpectedError('You cannot set the "1099 Liable" field because the "IRS 1099 Form Box No." field on the purchase header is blank.');
    end;

    [Test]
    procedure Can1099LiableWithFormBoxNoInHeader()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        PeriodNo: Code[20];
    begin
        // [SCENARIO 562547] "1099 Liable" can be set to true on purchase line when header has "IRS 1099 Form Box No."
        Initialize();

        // [GIVEN] Vendor "V" with "IRS 1099 Form Box No." = "MISC-01"
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), WorkDate(), FormNo, FormBoxNo);
        // [GIVEN] Purchase header for vendor "V" with "IRS 1099 Form Box No." = "MISC-01"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        // [GIVEN] Purchase line for item "I" with "1099 Liable" = false
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), 1);
        PurchaseLine.Validate("1099 Liable", false);
        PurchaseLine.Modify(true);

        // [WHEN] Set "1099 Liable" to true on purchase line
        PurchaseLine.Validate("1099 Liable", true);

        // [THEN] "1099 Liable" is set to true without error
        PurchaseLine.TestField("1099 Liable", true);

        // Tear Down
        IRSReportingPeriod.SetRange("No.", PeriodNo);
        IRSReportingPeriod.DeleteAll(true);
    end;

    [Test]
    procedure VendLedgEntryHasIRS1099ReportingFromLiablePurchLines()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        IRSReportingPeriod: Record "IRS Reporting Period";
        VendNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        PeriodNo: Code[20];
    begin
        // [SCENARIO 561321] Vendor ledger entry contains "IRS 1099 Reporting Amount" only from purchase lines which have "1099 Liable" option enabled

        Initialize();
        // [GIVEN] MISC-01 code is specified for vendor "X"
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), WorkDate(), FormNo, FormBoxNo);
        // [GIVEN] Purchase header for vendor "X"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        // [GIVEN] Create first purchase line with amount = 100 and disabled "1099 Liable" option
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
            PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(), LibraryRandom.RandDec(100, 2), LibraryRandom.RandInt(100));
        PurchaseLine.Validate("1099 Liable", false);
        PurchaseLine.Modify(true);
        // [GIVEN] Create second purchase line with amount = 200 and disabled "1099 Liable" option
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
            PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(), LibraryRandom.RandDec(100, 2), LibraryRandom.RandInt(100));
        // [WHEN]
        LibraryERM.FindVendorLedgerEntry(
            VendLedgEntry, VendLedgEntry."Document Type"::Invoice, LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
        // [THEN] Vendor ledger entry has "IRS 1099 Reporting Amount" = -200
        VendLedgEntry.TestField("IRS 1099 Reporting Amount", -PurchaseLine."Amount Including VAT");

        // Tear down
        IRSReportingPeriod.SetRange("No.", PeriodNo);
        IRSReportingPeriod.DeleteAll(true);
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 Liable Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 Liable Tests");

        LibraryERMCountryData.CreateVATData();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 Liable Tests");
    end;
}
