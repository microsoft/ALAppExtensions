// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;

codeunit 148015 "IRS 1099 E2E Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryIRS1099Document: Codeunit "Library IRS 1099 Document";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [1099] [UT]
    end;

    [Test]
    [HandlerFunctions('IRS1099CreateFormDocsRequestPageHandler')]
    procedure MultipleFormsMultipleVendors()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
        IRS1099CreateFormDocsReport: Report "IRS 1099 Create Form Docs";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo: Code[20];
        FormNo: array[2] of Code[20];
        FormBoxNo: array[2, 2, 2] of Code[20];
        VendNo: array[2] of Code[20];
        ExpectedAmount: array[2, 2, 2] of Decimal;
        ExpectedEntryNo: array[2, 2, 2] of Integer;
        i, j, k : Integer;
    begin
        // [SCENARIO 495389] Stan can report a single form for a single vendor

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        // [GIVEN] Forms MISC and NEC with two boxes each (MISC-01, MISC-02, NEC-01, NEC-02)
        for i := 1 to ArrayLen(FormNo) do
            FormNo[i] := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        for i := 1 to ArrayLen(VendNo) do begin
            // [GIVEN] Two vendors - "X" and "Y"
            VendNo[i] := LibraryPurchase.CreateVendorNo();
            for j := 1 to ArrayLen(FormNo, 1) do
                for k := 1 to ArrayLen(FormBoxNo, 3) do begin
                    FormBoxNo[i, j, k] := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo[j]);
                    // [GIVEN] Purchase invoice is posted for the vendor "X" and MISC-01
                    // [GIVEN] Purchase invoice is posted for the vendor "X" and MISC-02
                    // [GIVEN] Purchase invoice is posted for the vendor "X" and NEC-01
                    // [GIVEN] Purchase invoice is posted for the vendor "X" and NEC-02
                    // [GIVEN] Purchase invoice is posted for the vendor "Y" and MISC-01
                    // [GIVEN] Purchase invoice is posted for the vendor "Y" and MISC-02
                    // [GIVEN] Purchase invoice is posted for the vendor "Y" and NEC-01
                    // [GIVEN] Purchase invoice is posted for the vendor "Y" and NEC-02

                    LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo[i]);
                    PurchaseHeader.Validate("IRS 1099 Reporting Period", LibraryIRSReportingPeriod.GetReportingPeriod(WorkDate()));
                    PurchaseHeader.Validate("IRS 1099 Form No.", FormNo[j]);
                    PurchaseHeader.Validate("IRS 1099 Form Box No.", FormBoxNo[i, j, k]);
                    PurchaseHeader.Modify(true);
                    LibraryPurchase.CreatePurchaseLine(
                        PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
                    PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
                    PurchaseLine.Modify(true);

                    LibraryERM.FindVendorLedgerEntry(
                        VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice,
                        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
                    VendorLedgerEntry.CalcFields(Amount);
                    // [GIVEN] Payment is posted and applied to the invoice
                    LibraryIRS1099Document.PostPaymentAppliedToInvoice(VendNo[i], VendorLedgerEntry."Document No.", -VendorLedgerEntry.Amount);
                    ExpectedAmount[i, j, k] := -VendorLedgerEntry.Amount;
                    ExpectedEntryNo[i, j, k] := VendorLedgerEntry."Entry No.";
                end;
        end;
        Commit();
        // [WHEN] Create form documents
        IRS1099CreateFormDocsReport.InitializeRequest(PeriodNo, '', '', false);
        IRS1099CreateFormDocsReport.RunModal();

        // [THEN] Four form documents are created
        Assert.RecordCount(IRS1099FormDocHeader, ArrayLen(VendNo) * ArrayLen(FormNo));

        for i := 1 to ArrayLen(VendNo) do
            for j := 1 to ArrayLen(FormNo, 1) do begin
                IRS1099FormDocHeader.SetRange("Period No.", PeriodNo);
                IRS1099FormDocHeader.SetRange("Vendor No.", VendNo[i]);
                IRS1099FormDocHeader.SetRange("Form No.", FormNo[j]);
                IRS1099FormDocHeader.FindFirst();
                Assert.RecordCount(IRS1099FormDocHeader, 1);
                IRS1099FormDocLine.SetRange("Document ID", IRS1099FormDocHeader.ID);
                Assert.RecordCount(IRS1099FormDocLine, ArrayLen(FormBoxNo, 3));
                for k := 1 to ArrayLen(FormBoxNo, 3) do begin
                    IRS1099FormDocLine.SetRange("Form Box No.", FormBoxNo[i, j, k]);
                    IRS1099FormDocLine.FindFirst();
                    IRS1099FormDocLine.TestField(Amount, ExpectedAmount[i, j, k]);
                    IRS1099FormDocLine.SetRange("Form Box No.");
                    IRS1099FormDocLineDetail.Get(IRS1099FormDocLine."Document ID", IRS1099FormDocLine."Line No.", ExpectedEntryNo[i, j, k]);
                end;
            end;

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 E2E Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 E2E Tests");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 E2E Tests");
    end;

    [RequestPageHandler]
    procedure IRS1099CreateFormDocsRequestPageHandler(var IRS1099CreateFormDocs: TestRequestPage "IRS 1099 Create Form Docs")
    begin
        IRS1099CreateFormDocs.Ok().Invoke();
    end;
}
