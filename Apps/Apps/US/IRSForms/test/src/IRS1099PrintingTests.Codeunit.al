// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;

codeunit 148017 "IRS 1099 Printing Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit Assert;
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        IRS1099FormStatementLineEmptyErr: Label 'There are no form statement lines for the selected form and period.';

    trigger OnRun()
    begin
        // [FEATURE] [1099] [UT]
    end;

    [Test]
    procedure UT_IRS1099Print_NoStatementLinesErr()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
    begin
        // [SCENARIO 495389] User gets error when trying to run report with empty statement lines
        Initialize();

#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] IRS 1099 Document exists for Vendor in period
        CreateIRS1099Document(IRS1099FormDocHeader);

        // [GIVEN] Form Box No exists in period
        Commit();

        // [GIVEN] IRS 1099 Document Line exists for Vendor in period
        CreateIRS1099DocLine(IRS1099FormDocHeader, IRS1099FormDocLine, LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), IRS1099FormDocHeader."Form No."), LibraryRandom.RandDec(1000, 2));

        // [WHEN] Run Print report
        asserterror Report.Run(Report::"IRS 1099 Print", false, false, IRS1099FormDocHeader);

        // [THEN] Error is shown that no statement lines exist
        Assert.ExpectedError(IRS1099FormStatementLineEmptyErr);

        // Tear down
        IRS1099FormDocHeader.Delete(true);
#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure UT_IRS1099Print_SavingReportWorks()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099PrintParams: Record "IRS 1099 Print Params";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        FormBoxNo: Code[20];
    begin
        // [SCENARIO 495389] SaveContentForDocument works for document
        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] IRS 1099 Document exists for Vendor in period
        CreateIRS1099Document(IRS1099FormDocHeader);

        // [GIVEN] Form Box No exists in period
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), IRS1099FormDocHeader."Form No.");

        // [GIVEN] IRS 1099 Document Line exists for Vendor in period
        CreateIRS1099DocLine(IRS1099FormDocHeader, IRS1099FormDocLine, FormBoxNo, LibraryRandom.RandDec(1000, 2));

        // [GIVEN] No Statement Line exists for Vendor in period
        CreateStatementLine(IRS1099FormDocHeader, FormBoxNo);

        Commit();

        // [WHEN] Use Save content for document
        IRS1099PrintParams := CreatePrintParams();
        IRSFormsFacade.SaveContentForDocument(IRS1099FormDocHeader, IRS1099PrintParams, false);

        // [THEN] Content has beed saved
        VerifyFileContentExists(IRS1099FormDocHeader, IRS1099PrintParams."Report Type");

        // Tear down
        IRS1099FormDocHeader.Delete(true);
#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure UT_IRS1099Print_BankAccountNo()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        VendorBankAccount: Record "Vendor Bank Account";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        FormBoxNo: Code[20];
    begin
        // [SCENARIO 495389] Bank Account No for Vendor is shown correctly in report
        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] IRS 1099 Document exists for Vendor in period
        CreateIRS1099Document(IRS1099FormDocHeader);

        // [GIVEN] Vendor Bank Account exists for this vendor with Bank Account No = "XXX"
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, IRS1099FormDocHeader."Vendor No.");
        VendorBankAccount."Bank Account No." := LibraryUtility.GenerateGUID();
        VendorBankAccount.Modify(true);

        // [GIVEN] Update Preffered Bank Account for Vendor
        SetPreferredBankAccount(IRS1099FormDocHeader."Vendor No.", VendorBankAccount.Code);

        // [GIVEN] Form Box No exists in period
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), IRS1099FormDocHeader."Form No.");

        // [GIVEN] IRS 1099 Document Line exists for Vendor in period
        CreateIRS1099DocLine(IRS1099FormDocHeader, IRS1099FormDocLine, FormBoxNo, LibraryRandom.RandDec(1000, 2));

        // [GIVEN] No Statement Line exists for Vendor in period
        CreateStatementLine(IRS1099FormDocHeader, FormBoxNo);

        Commit();

        // [WHEN] Run report
        LibraryReportDataset.RunReportAndLoad(Report::"IRS 1099 Print", IRS1099FormDocHeader, '');

        // [THEN] Vendor Bank Account No in report is "XXX"
        LibraryReportDataset.AssertElementWithValueExists('Vendor_BankAccountNo', VendorBankAccount."Bank Account No.");

        // Tear down
        IRS1099FormDocHeader.Delete(true);
#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    local procedure Initialize()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRSReportingPeriod.DeleteAll(true);
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 Document Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 Document Tests");

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 Document Tests");
    end;

    local procedure CreateIRS1099Document(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    var
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
    begin
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);

        IRS1099FormDocHeader."Period No." := PeriodNo;
        IRS1099FormDocHeader."Vendor No." := VendNo;
        IRS1099FormDocHeader."Form No." := FormNo;
        IRS1099FormDocHeader.Insert();
    end;

    local procedure CreateIRS1099DocLine(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; var IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line"; FormBoxNo: Code[20]; Amount: Decimal)
    var
        NewLineNo: Integer;
    begin
        IRS1099FormDocLine.SetRange("Document ID", IRS1099FormDocHeader.ID);
        if IRS1099FormDocLine.FindLast() then
            NewLineNo := IRS1099FormDocLine."Line No." + 1
        else
            NewLineNo := 1;
        IRS1099FormDocLine.Init();
        IRS1099FormDocLine."Line No." := NewLineNo;
        IRS1099FormDocLine."Document ID" := IRS1099FormDocHeader.ID;
        IRS1099FormDocLine."Form Box No." := FormBoxNo;
        IRS1099FormDocLine.Amount := Amount;
        IRS1099FormDocLine.Insert();
    end;

    local procedure CreatePrintParams() IRS1099PrintParams: Record "IRS 1099 Print Params"
    begin
        IRS1099PrintParams."Report Type" := IRS1099PrintParams."Report Type"::"Copy 2";
        IRS1099PrintParams.Insert();
    end;

    local procedure CreateStatementLine(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; FormBoxNo: Code[20])
    var
        IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        NewLineNo: Integer;
    begin
        IRS1099FormStatementLine.SetRange("Period No.", IRS1099FormDocHeader."Period No.");
        IRS1099FormStatementLine.SetRange("Form No.", IRS1099FormDocHeader."Form No.");
        if IRS1099FormStatementLine.FindLast() then
            NewLineNo := IRS1099FormStatementLine."Line No." + 1
        else
            NewLineNo := 1;
        IRS1099FormStatementLine.Init();
        IRS1099FormStatementLine."Period No." := IRS1099FormDocHeader."Period No.";
        IRS1099FormStatementLine."Form No." := IRS1099FormDocHeader."Form No.";
        IRS1099FormStatementLine."Line No." := NewLineNo;
        IRS1099FormStatementLine.Description := LibraryUtility.GenerateGUID();
        IRS1099FormStatementLine."Row No." := LibraryUtility.GenerateGUID();
        IRS1099FormDocLine.SetRange("Form Box No.", FormBoxNo);
        IRS1099FormStatementLine.Validate("Filter Expression", IRS1099FormDocLine.GetFilters());
        IRS1099FormStatementLine.Insert();
    end;

    local procedure SetPreferredBankAccount(VendorNo: Code[20]; BankAccountNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(VendorNo);
        Vendor."Preferred Bank Account Code" := BankAccountNo;
        Vendor.Modify();
    end;

    local procedure VerifyFileContentExists(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; ReportType: Enum "IRS 1099 Form Report Type")
    var
        IRS1099FormReport: Record "IRS 1099 Form Report";
    begin
        IRS1099FormReport.SetRange("Document ID", IRS1099FormDocHeader.ID);
        IRS1099FormReport.SetRange("Report Type", ReportType);
        IRS1099FormReport.FindFirst();
        IRS1099FormReport.CalcFields("File Content");
        Assert.IsTrue(IRS1099FormReport."File Content".HasValue(), 'File content should exist for the document and report type.');
    end;
}
