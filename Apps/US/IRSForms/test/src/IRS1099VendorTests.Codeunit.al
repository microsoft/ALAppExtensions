// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using System.TestLibraries.Utilities;

codeunit 148011 "IRS 1099 Vendor Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryIRS1099Document: Codeunit "Library IRS 1099 Document";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";

        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        LibraryInventory: Codeunit "Library - Inventory";
        IsInitialized: Boolean;
        IRSReportingAmountCannotBeMoreThanAmountErr: Label 'IRS Reporting Amount cannot be more than Amount';
        IRSReportingAmountPositiveErr: Label 'IRS 1099 Reporting Amount must be positive';
        IRSReportingAmountNegativeErr: Label 'IRS 1099 Reporting Amount must be negative';

    trigger OnRun()
    begin
        // [FEATURE] [1099]
    end;

    [Test]
    [HandlerFunctions('IRS1099SuggestVendorsByVATBusPostGroupRequestPageHandler')]
    procedure SuggestVendorsForFormBoxSetupSunshine()
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VendorNo: array[2] of Code[20];
        i: Integer;
    begin
        // [SCENARIO 495389] Stan can suggest vendors by filters for the form box setup

        Initialize();
        // [GIVEN] Two vendors with different business groups - "X" and "Y"
        for i := 1 to ArrayLen(VendorNo) do begin
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            VendorNo[i] := LibraryPurchase.CreateVendorWithVATBusPostingGroup(VATBusinessPostingGroup.Code);
        end;
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        LibraryVariableStorage.Enqueue(VATBusinessPostingGroup.Code);
        Commit();
        // [WHEN] Suggest vendors with "X" business group
        LibraryIRS1099FormBox.SuggestVendorsForFormBoxSetup(WorkDate(), WorkDate());
        // [THEN] Verify that only one vendor with "X" business group is suggested
        LibraryIRS1099FormBox.VerifyFormBoxSetupCountForVendors(WorkDate(), WorkDate(), 1);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('IRS1099SuggestVendorsByVATBusPostGroupRequestPageHandler')]
    procedure SuggestVendorsForFormBoxSetupAddToExisting()
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        Vendor: Record Vendor;
        VendorNo: array[2] of Code[20];
        i: Integer;
    begin
        // [SCENARIO 495389] Stan can suggest vendors for the form box setup where there are existing setup added manually

        Initialize();
        // [GIVEN] Two vendors with different business groups - "X" and "Y"
        for i := 1 to ArrayLen(VendorNo) do begin
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            VendorNo[i] := LibraryPurchase.CreateVendorWithVATBusPostingGroup(VATBusinessPostingGroup.Code);
        end;
#pragma warning disable AA0210
#pragma warning disable AA0175
        Vendor.SetRange("VAT Bus. Posting Group", VATBusinessPostingGroup.Code);
        Vendor.FindFirst();
#pragma warning restore AA0210
#pragma warning restore AA0175
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        // [GIVEN] Add vendor form box setup for the first vendor manually
        LibraryIRS1099FormBox.AssignFormBoxForVendorInPeriod(VendorNo[1], WorkDate(), WorkDate(), '', '');
        LibraryVariableStorage.Enqueue(VATBusinessPostingGroup.Code);
        Commit();
        // [WHEN] Suggest all vendors to the form box setup
        LibraryIRS1099FormBox.SuggestVendorsForFormBoxSetup(WorkDate(), WorkDate());
        // [THEN] Two vendor form box setup records exist
        LibraryIRS1099FormBox.VerifyFormBoxSetupCountForVendors(WorkDate(), WorkDate(), 2);
    end;

    [Test]
    [HandlerFunctions('IRS1099PropagateVendSetupRequestPageHandler')]
    procedure PropagateVendorFormBoxSetupToVendorLedgerEntriesSunshine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        VendorNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        PeriodNo: Code[20];
    begin
        // [SCENARIO 495389] Stan can propagate vendor form box setup to vendor ledger entries

        Initialize();
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        VendorNo := LibraryPurchase.CreateVendorNo();
        // [GIVEN] Vendor ledger entry and posted purchase invoice for vendor "X"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(), 1, 1);
        LibraryERM.FindVendorLedgerEntry(
            VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice,
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
        PurchInvHeader.Get(VendorLedgerEntry."Document No.");

        // [GIVEN] Open purchase invoice for vendor "X"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);

        // [GIVEN] Vendor form box setup with MISC-01 code is assigned to vendor "X"
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);
        LibraryIRS1099FormBox.AssignFormBoxForVendorInPeriod(VendorNo, WorkDate(), WorkDate(), FormNo, FormBoxNo);
        Commit();
        LibraryVariableStorage.Enqueue(PeriodNo);
        // [WHEN] Propagate vendor form box setup to vendor ledger entries and purchase documents
        LibraryIRS1099FormBox.PropagateVendorFormBoxSetupToVendorLedgerEntries(WorkDate(), WorkDate(), VendorNo, FormNo, FormBoxNo);
        // [THEN] Vendor ledger entry has MISC-01
        VendorLedgerEntry.Find();
        VendorLedgerEntry.CalcFields(Amount);
        VendorLedgerEntry.TestField("IRS 1099 Reporting Period", PeriodNo);
        VendorLedgerEntry.TestField("IRS 1099 Form No.", FormNo);
        VendorLedgerEntry.TestField("IRS 1099 Form Box No.", FormBoxNo);
        VendorLedgerEntry.TestField("IRS 1099 Reporting Amount", VendorLedgerEntry.Amount);
        VendorLedgerEntry.TestField("IRS 1099 Subject For Reporting", true);
        // [THEN] Posted purchase invoice has MISC-01
        // Bug 560895: IRS 1099 Form Box No. is not propagated to posted purchase documents
        PurchInvHeader.Find();
        PurchInvHeader.TestField("IRS 1099 Reporting Period", PeriodNo);
        PurchInvHeader.TestField("IRS 1099 Form No.", FormNo);
        PurchInvHeader.TestField("IRS 1099 Form Box No.", FormBoxNo);
        // [THEN] Open purchase invoice has MISC-01
        PurchaseHeader.Find();
        PurchaseHeader.TestField("IRS 1099 Reporting Period", PeriodNo);
        PurchaseHeader.TestField("IRS 1099 Form No.", FormNo);
        PurchaseHeader.TestField("IRS 1099 Form Box No.", FormBoxNo);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure ChangeIRSDataInVendorLedgerEntry()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        VendorLedgerEntriesPage: TestPage "Vendor Ledger Entries";
        NewPeriodNo, FormNo, NewFormNo, FormBoxNo, NewFormBoxNo : Code[20];
        IRSAmount: Decimal;
        NewDate: Date;
    begin
        // [SCENARIO 495389] Stan can change the IRS data in the posted vendor ledger entry

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := LibraryRandom.RandDec(100, 2);
        // [GIVEN] Vendor Ledger Entry with IRS 1099 Code = MISC-01 and IRS Amount = 100
        LibraryIRS1099Document.MockVendLedgEntryWithIRSData(
            VendorLedgerEntry, WorkDate(), WorkDate(), FormNo, FormBoxNo, IRSAmount);

        NewDate := CalcDate('<1Y>', WorkDate());
        NewPeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(NewDate);
        NewFormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(NewDate);
        NewFormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(NewDate, NewFormNo);
        IRSAmount := IRSAmount / 3;
        // [GIVEN] Vendor Ledger Entries page opened and filtered by Entry No.
        VendorLedgerEntriesPage.OpenEdit();
        VendorLedgerEntriesPage.Filter.SetFilter("Entry No.", Format(VendorLedgerEntry."Entry No."));
        // [WHEN] IRS 1099 Code is changed to MISC-2 and IRS Amount is changed to 90
        VendorLedgerEntriesPage."IRS 1099 Reporting Period".SetValue(NewPeriodNo);
        VendorLedgerEntriesPage."IRS 1099 Form No.".SetValue(NewFormNo);
        VendorLedgerEntriesPage."IRS 1099 Form Box No.".SetValue(NewFormBoxNo);
        VendorLedgerEntriesPage."IRS 1099 Reporting Amount".SetValue(IRSAmount);
        VendorLedgerEntriesPage.Close();
        // [THEN] IRS 1099 Code in the Vendor Ledger Entry is MISC-2 and IRS Amount is 90
        VendorLedgerEntry.Find();
        VendorLedgerEntry.TestField("IRS 1099 Subject For Reporting", true);
        VendorLedgerEntry.TestField("IRS 1099 Reporting Period", NewPeriodNo);
        VendorLedgerEntry.TestField("IRS 1099 Form No.", NewFormNo);
        VendorLedgerEntry.TestField("IRS 1099 Form Box No.", NewFormBoxNo);
        VendorLedgerEntry.TestField("IRS 1099 Reporting Amount", IRSAmount);

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure SetIRSAmountMoreThanAmountInVendLedgEntry()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        VendorLedgerEntriesPage: TestPage "Vendor Ledger Entries";
        FormNo, FormBoxNo : Code[20];
        IRSAmount: Decimal;
    begin
        // [SCENARIO 495389] Stan cannot set the IRS Reporting Amount more than amount in Vendor Ledger Entry

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := -LibraryRandom.RandDec(100, 2);
        // [GIVEN] Vendor Ledger Entry with IRS 1099 Code = MISC-01 and Amount = -100
        LibraryIRS1099Document.MockVendLedgEntryWithIRSData(
            VendorLedgerEntry, WorkDate(), WorkDate(), FormNo, FormBoxNo, IRSAmount);
        IRSAmount := -IRSAmount * 3;
        // [GIVEN] Vendor Ledger Entries page opened and filtered by Entry No.
        VendorLedgerEntriesPage.OpenEdit();
        VendorLedgerEntriesPage.Filter.SetFilter("Entry No.", Format(VendorLedgerEntry."Entry No."));
        // [WHEN]  IRS Amount is changed to -300
        asserterror VendorLedgerEntriesPage."IRS 1099 Reporting Amount".SetValue(IRSAmount);
        // [THEN] An error message "IRS Reporting Amount cannot be more than -300" is thrown
        Assert.ExpectedError(IRSReportingAmountCannotBeMoreThanAmountErr);

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure SetPositiveIRSAmountInInvVendLedgEntry()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        VendorLedgerEntriesPage: TestPage "Vendor Ledger Entries";
        FormNo, FormBoxNo : Code[20];
        IRSAmount: Decimal;
    begin
        // [SCENARIO 495389] Stan cannot set the positive IRS Reporting Amount in the invoice Vendor Ledger Entry

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := -LibraryRandom.RandDec(100, 2);
        // [GIVEN] Vendor Ledger Entry with IRS 1099 Code = MISC-01 and Amount = -100
        LibraryIRS1099Document.MockInvVendLedgEntryWithIRSData(
            VendorLedgerEntry, WorkDate(), WorkDate(), FormNo, FormBoxNo, IRSAmount);
        IRSAmount := -IRSAmount;
        // [GIVEN] Vendor Ledger Entries page opened and filtered by Entry No.
        VendorLedgerEntriesPage.OpenEdit();
        VendorLedgerEntriesPage.Filter.SetFilter("Entry No.", Format(VendorLedgerEntry."Entry No."));
        // [WHEN]  IRS Amount is changed to 100
        asserterror VendorLedgerEntriesPage."IRS 1099 Reporting Amount".SetValue(IRSAmount);
        // [THEN] An error message "IRS Reporting Amount must be negative" is thrown
        Assert.ExpectedError(IRSReportingAmountNegativeErr);
#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure SetNegativeIRSAmountInInvVendLedgEntry()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        VendorLedgerEntriesPage: TestPage "Vendor Ledger Entries";
        FormNo, FormBoxNo : Code[20];
        IRSAmount: Decimal;
    begin
        // [SCENARIO 495389] Stan cannot set the negative IRS Reporting Amount in the credit memo Vendor Ledger Entry

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := LibraryRandom.RandDec(100, 2);
        // [GIVEN] Vendor Ledger Entry with IRS 1099 Code = MISC-01 and Amount = 100
        LibraryIRS1099Document.MockCrMemoVendLedgEntryWithIRSData(
            VendorLedgerEntry, WorkDate(), WorkDate(), FormNo, FormBoxNo, IRSAmount);
        IRSAmount := -IRSAmount;
        // [GIVEN] Vendor Ledger Entries page opened and filtered by Entry No.
        VendorLedgerEntriesPage.OpenEdit();
        VendorLedgerEntriesPage.Filter.SetFilter("Entry No.", Format(VendorLedgerEntry."Entry No."));
        // [WHEN]  IRS Amount is changed to -100
        asserterror VendorLedgerEntriesPage."IRS 1099 Reporting Amount".SetValue(IRSAmount);
        // [THEN] An error message "IRS Reporting Amount must be positive" is thrown
        Assert.ExpectedError(IRSReportingAmountPositiveErr);
#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [HandlerFunctions('IRS1099PropagateVendSetupRequestPageHandler')]
    procedure PropagateAllSelectedVendorsFromVendorFormBoxSetupToVendorLedgerEntries()
    var
        VendorNo: array[3] of Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        PeriodNo: Code[20];
    begin
        // [SCENARIO 495389] Stan can propagate all the selected vendors from vendor form box setup to vendor ledger entries
        Initialize();

        // [GIVEN] Create period
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());

        // [GIVEN] Vendor form box setup with MISC-01 code is assigned to vendor "X"
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);

        // [GIVEN] Post purchase invoice and enqueu Period No.
        PostPurchaseInvoiceForMultipleVendors(VendorNo, FormNo, FormBoxNo);
        LibraryVariableStorage.Enqueue(PeriodNo);

        // [WHEN] Propagate vendor form box setup to vendor ledger entries
        LibraryIRS1099FormBox.PropagateVendorFormBoxSetupToVendorLedgerEntries(WorkDate(), WorkDate(), PeriodNo, VendorNo[1] + '|' + VendorNo[3]);

        // [THEN] Vendor ledger entry has IRS 1099 fields filled on Vendor Ledger Entry of selected Vendors
        VerifyIRS1099FieldsOnVendorLedgerEntry(PeriodNo, FormNo, FormBoxNo, VendorNo[1] + '|' + VendorNo[3]);
    end;

    local procedure Initialize()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRSReportingPeriod.DeleteAll(true);
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 Vendor Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 Vendor Tests");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 Vendor Tests");
    end;

    local procedure PostPurchaseInvoiceForMultipleVendors(var VendorNo: array[3] of Code[20]; FormNo: Code[20]; FormBoxNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        i: Integer;
    begin
        for i := 1 to ArrayLen(VendorNo) do begin
            VendorNo[i] := LibraryPurchase.CreateVendorNo();
            LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo[i]);
            LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(), 1, 1);
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            LibraryIRS1099FormBox.AssignFormBoxForVendorInPeriod(VendorNo[i], WorkDate(), WorkDate(), FormNo, FormBoxNo);
            Commit();
        end;
    end;

    local procedure VerifyIRS1099FieldsOnVendorLedgerEntry(PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; VendorNoFilter: Text)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetFilter("Vendor No.", VendorNoFilter);
        VendorLedgerEntry.FindSet();
        repeat
            VendorLedgerEntry.CalcFields(Amount);
            VendorLedgerEntry.TestField("IRS 1099 Reporting Period", PeriodNo);
            VendorLedgerEntry.TestField("IRS 1099 Form No.", FormNo);
            VendorLedgerEntry.TestField("IRS 1099 Form Box No.", FormBoxNo);
            VendorLedgerEntry.TestField("IRS 1099 Reporting Amount", VendorLedgerEntry.Amount);
            VendorLedgerEntry.TestField("IRS 1099 Subject For Reporting", true);
        until VendorLedgerEntry.Next() = 0;
    end;

    [RequestPageHandler]
    procedure IRS1099SuggestVendorsByVATBusPostGroupRequestPageHandler(var IRS1099SuggestVendors: TestRequestPage "IRS 1099 Suggest Vendors")
    begin
        IRS1099SuggestVendors.Vendor.SetFilter("VAT Bus. Posting Group", LibraryVariableStorage.DequeueText());
        IRS1099SuggestVendors.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure IRS1099PropagateVendSetupRequestPageHandler(var IRS1099PropagateVendSetup: TestRequestPage "IRS 1099 Propagate Vend. Setup")
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRSReportingPeriod.Get(LibraryVariableStorage.DequeueText());
        IRS1099PropagateVendSetup.StartingDateControl.SetValue(IRSReportingPeriod."Starting Date");
        IRS1099PropagateVendSetup.EndingDateControl.SetValue(IRSReportingPeriod."Ending Date");
        IRS1099PropagateVendSetup.PurchaseDocumentsControl.SetValue(true);
        IRS1099PropagateVendSetup.VendorLedgerEntriesControl.SetValue(true);
        IRS1099PropagateVendSetup.OK().Invoke();
    end;
}
