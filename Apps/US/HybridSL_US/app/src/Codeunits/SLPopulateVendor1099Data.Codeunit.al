// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using System.Integration;

codeunit 47201 "SL Populate Vendor 1099 Data"
{
    EventSubscriberInstance = Manual;
    Permissions = tabledata "IRS 1099 Form Box" = R,
                tabledata "IRS 1099 Vendor Form Box Setup" = RIM;

    var
        DefaultPayablesAccountCode: Code[20];
        PostingDate: Date;
        NextYearPostingDate: Date;
        SLCurr1099Yr: Integer;
        SLNext1099Yr: Integer;
        Current1099YearOpen: Boolean;
        Next1099YearOpen: Boolean;
        GenJournalBatchDescriptionTxt: Label 'SL Vendor 1099 Tax Journal for ', Locked = true;
        MessageCodeAbortedTxt: Label 'ABORTED', Locked = true;
        MessageCodeCompletedTxt: Label 'COMPLETED', Locked = true;
        MessageCodeSkippedTxt: Label 'SKIPPED', Locked = true;
        MessageCodeStartTxt: Label 'START', Locked = true;
        MessageCodeProcessingTxt: Label 'PROCESSING', Locked = true;
        NoSeriesDescriptionTxt: Label 'SL Vendor 1099', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        VendorTaxBatchNameTxt: Label 'SL1099', Locked = true;
        VendorTaxNoSeriesTxt: Label 'VENDTAX', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; var HideDialog: Boolean)
    begin
        HideDialog := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeShowPostResultMessage', '', false, false)]
    local procedure OnBeforeShowPostResultMessage(var GenJnlLine: Record "Gen. Journal Line"; TempJnlBatchName: Code[10]; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    trigger OnRun()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLVendor1099MappingHelpers: Codeunit "SL Vendor 1099 Mapping Helpers";
    begin
        if not SLCompanyAdditionalSettings.GetMigrateCurrent1099YearEnabled() and not SLCompanyAdditionalSettings.GetMigrateNext1099YearEnabled() then begin
            LogMessage(MessageCodeAbortedTxt, 'SL Vendor 1099 Data Migration is not enabled on the SL Company Migration Configuration page.');
            exit;
        end;
        if not SLCompanyAdditionalSettings.GetMigrateCurrent1099YearEnabled() then
            LogMessage(MessageCodeSkippedTxt, 'SL Vendor Current 1099 Year Data Migration is not enabled on the SL Company Migration Configuration page.');
        if not SLCompanyAdditionalSettings.GetMigrateNext1099YearEnabled() then
            LogMessage(MessageCodeSkippedTxt, 'SL Vendor Next 1099 Year Data Migration is not enabled on the SL Company Migration Configuration page.');

        SLCurr1099Yr := SLVendor1099MappingHelpers.GetCurrent1099YearFromSLAPSetup();
        if SLCurr1099Yr <> 0 then begin
            Current1099YearOpen := SLVendor1099MappingHelpers.GetCurrent1099YearOpenStatus();
        end;
        SLNext1099Yr := SLVendor1099MappingHelpers.GetNext1099YearFromSLAPSetup();
        if SLNext1099Yr <> 0 then begin
            Next1099YearOpen := SLVendor1099MappingHelpers.GetNext1099YearOpenStatus();
        end;
        if not Current1099YearOpen and not Next1099YearOpen then begin
            LogMessage(MessageCodeAbortedTxt, 'Neither the SL Current 1099 Year nor the Next 1099 Year is open for data entry.');
            exit;
        end;
        if not Current1099YearOpen then
            LogMessage(MessageCodeSkippedTxt, 'SL Current 1099 Year ' + Format(SLCurr1099Yr) + ' is not open for data entry.');

        if not Next1099YearOpen then
            LogMessage(MessageCodeSkippedTxt, 'SL Next 1099 Year ' + Format(SLNext1099Yr) + ' is not open for data entry.');

        UpdateAllVendorTaxInfo();
    end;

    local procedure UpdateAllVendorTaxInfo()
    begin
        Initialize();
        LogMessage(MessageCodeCompletedTxt, 'Completed Initialization for Vendor Tax Info Update');
        if (SLCurr1099Yr <> 0) and (Current1099YearOpen) then begin
            LogMessage(MessageCodeStartTxt, 'Starting SL Vendor 1099 Data Migration for Current 1099 Tax Year ' + Format(SLCurr1099Yr));
            UpdateVendorTaxInfo(SLCurr1099Yr, PostingDate);
            LogMessage(MessageCodeCompletedTxt, 'Completed SL Vendor 1099 Data Migration for Current 1099 Tax Year ' + Format(SLCurr1099Yr));
        end;

        if (SLNext1099Yr <> 0) and (Next1099YearOpen) then begin
            LogMessage(MessageCodeStartTxt, 'Starting SL Vendor 1099 Data Migration for Next 1099 Tax Year ' + Format(SLNext1099Yr));
            UpdateVendorTaxInfo(SLNext1099Yr, NextYearPostingDate);
            LogMessage(MessageCodeCompletedTxt, 'Completed SL Vendor 1099 Data Migration for Next 1099 Tax Year ' + Format(SLNext1099Yr));
        end;

        LogMessage(MessageCodeCompletedTxt, 'Completed Vendor Tax Info Update');

        CleanUp(SLCurr1099Yr);
        CleanUp(SLNext1099Yr);
    end;

    local procedure Initialize()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        CurrentYear: Integer;
        Day31: Integer;
        Month12: Integer;
        NextYear: Integer;
        VendorTaxBatchCode: Code[10];
    begin
        SLCompanyAdditionalSettings.GetSingleInstance();
        CurrentYear := SLCurr1099Yr;
        NextYear := SLNext1099Yr;

        CreateMappingsIfNeeded();

        PostingDate := DMY2Date(31, 12, CurrentYear);
        NextYearPostingDate := DMY2Date(31, 12, NextYear);

        CreateNoSeriesIfNeeded();
        DefaultPayablesAccountCode := SLHelperFunctions.GetPostingAccountNumber('PayablesAccount');

        if (CurrentYear <> 0) and (Current1099YearOpen) then begin
            VendorTaxBatchCode := VendorTaxBatchNameTxt + Format(CurrentYear);
            CreateGeneralJournalBatchIfNeeded(VendorTaxBatchCode, '', '', CurrentYear);
        end;
        if (NextYear <> 0) and (Next1099YearOpen) then begin
            VendorTaxBatchCode := VendorTaxBatchNameTxt + Format(NextYear);
            CreateGeneralJournalBatchIfNeeded(VendorTaxBatchCode, '', '', NextYear);
        end;

        DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(SourceCodeTxt);
    end;

    local procedure CreateMappingsIfNeeded()
    begin
        Create1099Mappings(SLCurr1099Yr, Current1099YearOpen);
        Create1099Mappings(SLNext1099Yr, Next1099YearOpen);
    end;

    local procedure Create1099Mappings(TaxYear: Integer; Open1099Year: Boolean)
    var
        SLSupportedTaxYear: Record "SL Supported Tax Year";
        SLVendor1099MappingHelpers: Codeunit "SL Vendor 1099 Mapping Helpers";
    begin
        if TaxYear = 0 then
            exit;
        if not Open1099Year then
            exit;
        if SLSupportedTaxYear.Get(TaxYear) then
            exit;
        SLVendor1099MappingHelpers.InsertSupportedTaxYear(TaxYear);

        // MISC
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '1', '1M', 'MISC', 'MISC-01');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '2', '2M', 'MISC', 'MISC-02');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '3', '3M', 'MISC', 'MISC-03');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '4', '4M', 'MISC', 'MISC-04');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '5', '5M', 'MISC', 'MISC-05');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '6', '6M', 'MISC', 'MISC-06');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '8', '8M', 'MISC', 'MISC-08');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '10', '9M', 'MISC', 'MISC-09');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '14', '10M', 'MISC', 'MISC-10');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '15', '12M', 'MISC', 'MISC-12');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '13', '14M', 'MISC', 'MISC-14');
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '25', '15M', 'MISC', 'MISC-15');

        // NEC
        SLVendor1099MappingHelpers.InsertMapping(TaxYear, '7', '1N', 'NEC', 'NEC-01');

        LogMessage(MessageCodeCompletedTxt, 'Completed Box Mappings for Tax Year ' + Format(TaxYear));
    end;

    local procedure CreateNoSeriesIfNeeded()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get(VendorTaxNoSeriesTxt) then begin
            NoSeries."Code" := VendorTaxNoSeriesTxt;
            NoSeries.Description := NoSeriesDescriptionTxt;
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();

            NoSeriesLine."Series Code" := VendorTaxNoSeriesTxt;
            NoSeriesLine."Starting No." := 'VT000000';
            NoSeriesLine."Ending No." := 'VT999999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Open := true;
            NoSeriesLine.Insert();
        end;
    end;

    local procedure UpdateVendorTaxInfo(TaxYear: Integer; YearEndPostingDate: Date)
    var
        SLVendor: Record "SL Vendor";
    begin
        SLVendor.SetRange(Vend1099, 1);
        if SLVendor.FindSet() then
            repeat
                LogVendorMessage(CopyStr(SLVendor.VendId, 1, MaxStrLen(SLVendor.VendId)), MessageCodeProcessingTxt, 'Processing Tax Info for Vendor No.: ' + SLVendor.VendId.Trim() + ', ' + 'Tax Year: ' + Format(TaxYear));
                ProcessVendorTaxInfo(SLVendor, TaxYear, YearEndPostingDate);
            until SLVendor.Next() = 0;
    end;

    local procedure ProcessVendorTaxInfo(var SLVendor: Record "SL Vendor"; TaxYear: Integer; YearEndPostingDate: Date)
    var
        Vendor: Record Vendor;
        SLVendor1099MappingHelpers: Codeunit "SL Vendor 1099 Mapping Helpers";
        IRS1099Code: Code[10];
    begin
        if not Vendor.Get(SLVendor.VendId) then begin
            LogVendorMessage(SLVendor.VendId, MessageCodeAbortedTxt, 'Vendor No.: ' + SLVendor.VendId.Trim() + ' not found in Business Central.');
            exit;
        end;

        IRS1099Code := SLVendor1099MappingHelpers.GetIRS1099BoxCode(TaxYear, SLVendor.DfltBox);
        if IRS1099Code <> '' then
            if not VendorAlreadyHasIRS1099CodeAssigned(Vendor, TaxYear) then begin
                AssignIRS1099CodeToVendor(Vendor, IRS1099Code, TaxYear);
                if SLVendor.TIN.TrimEnd() <> '' then
                    Vendor.Validate("Federal ID No.", SLVendor.TIN.TrimEnd());
                if SLVendor.S4Future09 = 1 then
                    Vendor.Validate("FATCA Requirement", true);
                if SLVendor.TIN.TrimEnd() <> '' then
                    Vendor.Validate("Tax Identification Type", Vendor."Tax Identification Type"::"Legal Entity");
                if not Vendor.Modify() then begin
                    LogLastError(Vendor."No.");
                    exit;
                end;
            end else
                LogVendorSkipped(Vendor."No.", 'Vendor already has an IRS 1099 Code assigned.');

        AddVendor1099Values(Vendor, TaxYear, YearEndPostingDate);
    end;

    local procedure VendorAlreadyHasIRS1099CodeAssigned(var Vendor: Record Vendor; TaxYear: Integer): Boolean
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
    begin
        exit(IRS1099VendorFormBoxSetup.Get(TaxYear, Vendor."No."));
    end;

    local procedure AssignIRS1099CodeToVendor(var Vendor: Record Vendor; IRS1099Code: Code[10]; TaxYear: Integer): Boolean
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        if not IRSReportingPeriod.Get(Format(TaxYear)) then
            exit(false);

        IRS1099FormBox.SetRange("Period No.", IRSReportingPeriod."No.");
        IRS1099FormBox.SetRange("No.", IRS1099Code);
        if not IRS1099FormBox.FindFirst() then
            exit(false);

        IRS1099VendorFormBoxSetup.Validate("Period No.", IRSReportingPeriod."No.");
        IRS1099VendorFormBoxSetup.Validate("Vendor No.", Vendor."No.");
        IRS1099VendorFormBoxSetup.Validate("Form No.", IRS1099FormBox."Form No.");
        IRS1099VendorFormBoxSetup.Validate("Form Box No.", IRS1099Code);
        IRS1099VendorFormBoxSetup.Insert(true);
        LogVendorDefaultBoxMessage(Vendor."No.", IRS1099Code, MessageCodeCompletedTxt, 'Assigned IRS 1099 Code ' + IRS1099Code + ' to Vendor No.: ' + Vendor."No.");
        exit(true);
    end;

    local procedure AddVendor1099Values(var Vendor: Record Vendor; TaxYear: Integer; YearEndPostingDate: Date)
    var
        InvoiceGenJournalLine: Record "Gen. Journal Line";
        PaymentGenJournalLine: Record "Gen. Journal Line";
        NoSeries: Codeunit "No. Series";
        InvoiceDocumentNo: Code[20];
        InvoiceExternalDocumentNo: Code[35];
        IRS1099Code: Code[10];
        PaymentDocumentNo: Code[20];
        PaymentExternalDocumentNo: Code[35];
        VendorPayablesAccountCode: Code[20];
        VendorYear1099AmountDictionary: Dictionary of [Code[10], Decimal];
        TaxAmount: Decimal;
        InvoiceCreated: Boolean;
        PaymentCreated: Boolean;
    begin
        BuildVendor1099Entries(Vendor."No.", VendorYear1099AmountDictionary, TaxYear);
        LogVendorMessage(Vendor."No.", MessageCodeCompletedTxt, 'Built 1099 Entries for Vendor No.: ' + Vendor."No." + ' for Tax Year: ' + Format(TaxYear));
        if VendorYear1099AmountDictionary.Count() = 0 then begin
            LogVendorSkipped(Vendor."No.", 'No 1099 amounts found for Vendor: ' + Vendor."No." + ' for Tax Year: ' + Format(TaxYear));
            exit;
        end;

        VendorPayablesAccountCode := GetPostingAccountNo(Vendor);
        if VendorPayablesAccountCode = '' then begin
            LogErrorMessage(Vendor."No.", 'No Payables Account found.');
            exit;
        end;

        foreach IRS1099Code in VendorYear1099AmountDictionary.Keys() do begin
            TaxAmount := VendorYear1099AmountDictionary.Get(IRS1099Code);

            if TaxAmount > 0 then begin
                // Invoice
                InvoiceExternalDocumentNo := CopyStr(IRS1099Code + '-INV-' + Format(TaxYear), 1, MaxStrLen(InvoiceExternalDocumentNo));
                InvoiceDocumentNo := NoSeries.GetNextNo(VendorTaxNoSeriesTxt);
                InvoiceCreated := CreateGeneralJournalLine(InvoiceGenJournalLine,
                                    Vendor."No.",
                                    "Gen. Journal Document Type"::Invoice,
                                    InvoiceDocumentNo,
                                    IRS1099Code,
                                    Vendor."No.",
                                    -TaxAmount,
                                    VendorPayablesAccountCode,
                                    IRS1099Code,
                                    InvoiceExternalDocumentNo,
                                    YearEndPostingDate,
                                    TaxYear);

                if InvoiceCreated then
                    LogVendorDefaultBoxMessage(Vendor."No.", IRS1099Code, MessageCodeCompletedTxt, 'Created Invoice Journal Line for Amount: ' + Format(-TaxAmount));

                // Payment
                PaymentExternalDocumentNo := CopyStr(IRS1099Code + '-PMT-' + Format(TaxYear), 1, MaxStrLen(PaymentExternalDocumentNo));
                PaymentDocumentNo := NoSeries.GetNextNo(VendorTaxNoSeriesTxt);
                PaymentCreated := CreateGeneralJournalLine(PaymentGenJournalLine,
                                    Vendor."No.",
                                    "Gen. Journal Document Type"::Payment,
                                    PaymentDocumentNo,
                                    IRS1099Code,
                                    Vendor."No.",
                                    TaxAmount,
                                    VendorPayablesAccountCode,
                                    IRS1099Code,
                                    PaymentExternalDocumentNo,
                                    YearEndPostingDate,
                                    TaxYear);

                if PaymentCreated then
                    LogVendorDefaultBoxMessage(Vendor."No.", IRS1099Code, MessageCodeCompletedTxt, 'Created Payment Journal Line for Amount: ' + Format(TaxAmount));

                if InvoiceCreated and PaymentCreated then begin
                    InvoiceGenJournalLine.SendToPosting(Codeunit::"Gen. Jnl.-Post");
                    PaymentGenJournalLine.SendToPosting(Codeunit::"Gen. Jnl.-Post");
                    ApplyEntries(Vendor."No.", InvoiceDocumentNo, PaymentDocumentNo, InvoiceExternalDocumentNo, YearEndPostingDate);
                end;
            end;
        end;
    end;

    local procedure GetPostingAccountNo(var Vendor: Record Vendor): Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
        GLAccount: Record "G/L Account";
    begin
        if Vendor."Vendor Posting Group" = '' then
            exit(DefaultPayablesAccountCode);

        if VendorPostingGroup.Get(Vendor."Vendor Posting Group") then
            if VendorPostingGroup."Payables Account" <> '' then
                if GLAccount.Get(VendorPostingGroup."Payables Account") then
                    exit(GLAccount."No.");

        exit(DefaultPayablesAccountCode);
    end;

    local procedure BuildVendor1099Entries(VendorNo: Code[20]; var VendorYear1099AmountDictionary: Dictionary of [Code[10], Decimal]; TaxYear: Integer)
    var
        SLAPBalances: Record "SL AP_Balances";
    begin
        if not SLAPBalances.Get(VendorNo, CompanyName) then
            exit;

        ProcessBoxAmount(SLAPBalances.CYBox00, '1', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox01, '2', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox02, '3', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox03, '4', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox04, '5', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox05, '6', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox06, '7', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox07, '8', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox09, '10', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox14, '14', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox11, '15', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox13, '13', TaxYear, VendorYear1099AmountDictionary);
        ProcessBoxAmount(SLAPBalances.CYBox12, '25', TaxYear, VendorYear1099AmountDictionary);
    end;

    local procedure ProcessBoxAmount(BoxAmount: Decimal; SLBoxCode: Text[10]; TaxYear: Integer; var VendorYear1099AmountDictionary: Dictionary of [Code[10], Decimal])
    var
        SLVendor1099MappingHelpers: Codeunit "SL Vendor 1099 Mapping Helpers";
        IRS1099Code: Code[10];
        TaxAmount: Decimal;
    begin
        if BoxAmount <= 0 then
            exit;

        IRS1099Code := SLVendor1099MappingHelpers.GetIRS1099BoxCode(TaxYear, SLBoxCode);
        if IRS1099Code = '' then
            exit;

        if VendorYear1099AmountDictionary.Get(IRS1099Code, TaxAmount) then
            VendorYear1099AmountDictionary.Set(IRS1099Code, TaxAmount + BoxAmount)
        else
            VendorYear1099AmountDictionary.Add(IRS1099Code, BoxAmount);
    end;

    local procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; DocumentType: enum "Gen. Journal Document Type"; DocumentNo: Code[20];
        Description: Text[50]; AccountNo: Code[20]; Amount: Decimal; BalancingAccount: Code[20]; IRS1099Code: Code[10]; ExternalDocumentNo: Code[35]; YearEndPostingDate: Date; TaxYear: Integer): boolean
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLineCurrent: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        LineNum: Integer;
        VendorTaxBatchCode: Code[10];
    begin
        VendorTaxBatchCode := VendorTaxBatchNameTxt + Format(TaxYear);
        GenJournalBatch.Get(CreateGenJournalTemplateIfNeeded(VendorTaxBatchCode, TaxYear), VendorTaxBatchCode);

        GenJournalLineCurrent.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLineCurrent.SetRange("Journal Batch Name", GenJournalBatch.Name);
        if GenJournalLineCurrent.FindLast() then
            LineNum := GenJournalLineCurrent."Line No." + 10000
        else
            LineNum := 10000;

        GenJournalTemplate.Get(GenJournalBatch."Journal Template Name");

        Clear(GenJournalLine);
        GenJournalLine.SetHideValidation(true);
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Validate("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.Validate("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.Validate("Line No.", LineNum);
        GenJournalLine.Validate("Account Type", "Gen. Journal Account Type"::Vendor);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate("Document Date", YearEndPostingDate);
        GenJournalLine.Validate("Posting Date", YearEndPostingDate);
        GenJournalLine.Validate("Due Date", YearEndPostingDate);
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Validate("Amount (LCY)", Amount);
        GenJournalLine.Validate("Currency Code", '');
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", BalancingAccount);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::" ");
        GenJournalLine.Validate("Bal. Gen. Bus. Posting Group", '');
        GenJournalLine.Validate("Bal. Gen. Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Bus. Posting Group", '');
        GenJournalLine.Validate("Document Type", DocumentType);
        GenJournalLine.Validate("Source Code", SourceCodeTxt);
        GenJournalLine.Validate("External Document No.", ExternalDocumentNo);

        IRS1099FormBox.SetRange("Period No.", Format(TaxYear));
        IRS1099FormBox.SetRange("No.", IRS1099Code);
        if IRS1099FormBox.FindFirst() then begin
            GenJournalLine.Validate("IRS 1099 Reporting Period", IRS1099FormBox."Period No.");
            GenJournalLine.Validate("IRS 1099 Form No.", IRS1099FormBox."Form No.");
            GenJournalLine.Validate("IRS 1099 Form Box No.", IRS1099Code);
            GenJournalLine.Validate("IRS 1099 Reporting Amount", Amount);
        end;

        if GenJournalLine.Insert(true) then
            exit(true)
        else
            LogLastError(VendorNo);

        exit(false);
    end;

    local procedure CreateGenJournalTemplateIfNeeded(GenJournalBatchCode: Code[10]; TaxYear: Integer): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        GenJournalTemplate.SetRange(Recurring, false);
        if not GenJournalTemplate.FindFirst() then begin
            Clear(GenJournalTemplate);
            GenJournalTemplate.Validate(Name, GenJournalBatchCode);
            GenJournalTemplate.Validate(Type, GenJournalTemplate.Type::General);
            GenJournalTemplate.Validate(Recurring, false);
            GenJournalTemplate.Validate(Description, GenJournalBatchDescriptionTxt + Format(TaxYear));
            GenJournalTemplate.Insert(true);
        end;
        exit(GenJournalTemplate.Name);
    end;

    local procedure ApplyEntries(VendorNo: Code[20]; InvoiceDocumentNo: Code[20]; PaymentDocumentNo: Code[20]; ExternalDocumentNo: Code[35]; YearEndPostingDate: Date)
    var
        PaymentVendorLedgerEntry: Record "Vendor Ledger Entry";
        InvoiceVendorLedgerEntry: Record "Vendor Ledger Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
    begin
        PaymentVendorLedgerEntry.SetRange("Vendor No.", VendorNo);
        PaymentVendorLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Payment);
        PaymentVendorLedgerEntry.SetRange("Document No.", PaymentDocumentNo);
        PaymentVendorLedgerEntry.SetRange("Posting Date", YearEndPostingDate);
        if PaymentVendorLedgerEntry.FindFirst() then begin
            InvoiceVendorLedgerEntry.SetRange("Vendor No.", VendorNo);
            InvoiceVendorLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
            InvoiceVendorLedgerEntry.SetRange("Document No.", InvoiceDocumentNo);
            InvoiceVendorLedgerEntry.SetRange("Posting Date", YearEndPostingDate);

            if InvoiceVendorLedgerEntry.FindFirst() then begin
                PaymentVendorLedgerEntry.CalcFields(Amount);
                InvoiceVendorLedgerEntry.CalcFields(Amount);

                InvoiceVendorLedgerEntry.Validate("Applying Entry", true);
                InvoiceVendorLedgerEntry.Validate("Applies-to ID", PaymentVendorLedgerEntry."Document No.");
                InvoiceVendorLedgerEntry.CalcFields("Remaining Amount");
                InvoiceVendorLedgerEntry.Validate("Amount to Apply", InvoiceVendorLedgerEntry.Amount);
                Codeunit.Run(Codeunit::"Vend. Entry-Edit", InvoiceVendorLedgerEntry);

                VendEntrySetApplID.SetApplId(PaymentVendorLedgerEntry, InvoiceVendorLedgerEntry, PaymentVendorLedgerEntry."Document No.");

                ApplyUnapplyParameters."Account Type" := "Gen. Journal Account Type"::Vendor;
                ApplyUnapplyParameters."Account No." := VendorNo;
                ApplyUnapplyParameters."Document Type" := InvoiceVendorLedgerEntry."Document Type";
                ApplyUnapplyParameters."Document No." := InvoiceVendorLedgerEntry."Document No.";
                ApplyUnapplyParameters."Posting Date" := YearEndPostingDate;
                ApplyUnapplyParameters."External Document No." := ExternalDocumentNo;
                VendEntryApplyPostedEntries.Apply(InvoiceVendorLedgerEntry, ApplyUnapplyParameters);
            end;
        end;
    end;

    local procedure CreateGeneralJournalBatchIfNeeded(GeneralJournalBatchCode: Code[10]; NoSeriesCode: Code[20]; PostingNoSeriesCode: Code[20]; TaxYear: Integer)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        TemplateName: Code[10];
    begin
        TemplateName := CreateGenJournalTemplateIfNeeded(GeneralJournalBatchCode, TaxYear);
        GenJournalBatch.SetRange("Journal Template Name", TemplateName);
        GenJournalBatch.SetRange(Name, GeneralJournalBatchCode);
        GenJournalBatch.SetRange("No. Series", NoSeriesCode);
        GenJournalBatch.SetRange("Posting No. Series", PostingNoSeriesCode);
        if GenJournalBatch.IsEmpty() then begin
            GenJournalBatch.Init();
            GenJournalBatch.Validate("Journal Template Name", TemplateName);
            GenJournalBatch.SetupNewBatch();
            GenJournalBatch.Validate(Name, GeneralJournalBatchCode);
            GenJournalBatch.Validate(Description, GenJournalBatchDescriptionTxt + Format(TaxYear));
            GenJournalBatch."No. Series" := NoSeriesCode;
            GenJournalBatch."Posting No. Series" := PostingNoSeriesCode;
            GenJournalBatch.Insert(true);
        end;
    end;

    local procedure CleanUp(SL1099Year: Integer)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        SL1099YearJournalBatchName: Code[20];
        NextYearJournalBatchName: Code[20];
    begin
        SL1099YearJournalBatchName := VendorTaxBatchNameTxt + Format(SL1099Year);
        GenJournalLine.SetRange("Journal Batch Name", SL1099YearJournalBatchName);
        GenJournalLine.SetFilter("Account No.", '<>%1', '');
        if (not GenJournalLine.IsEmpty()) then
            exit;

        Clear(GenJournalLine);
        GenJournalLine.SetRange("Journal Batch Name", SL1099YearJournalBatchName);
        GenJournalLine.SetRange("Account No.", '');
        if not GenJournalLine.IsEmpty() then
            GenJournalLine.DeleteAll();

        GenJournalBatch.SetRange(Name, SL1099YearJournalBatchName);
        if GenJournalBatch.FindFirst() then begin
            GenJournalBatch.Delete(true);
            if (GenJournalTemplate.Get(SL1099YearJournalBatchName)) then
                GenJournalTemplate.Delete(true);
        end;
    end;

    local procedure LogLastError(VendorNo: Code[20])
    var
        SL1099MigrationLog: Record "SL 1099 Migration Log";
    begin
        SL1099MigrationLog."Vendor No." := VendorNo;
        SL1099MigrationLog.IsError := true;
        SL1099MigrationLog."Error Code" := CopyStr(GetLastErrorCode(), 1, MaxStrLen(SL1099MigrationLog."Error Code"));
        SL1099MigrationLog.SetErrorMessage(GetLastErrorCallStack());
        SL1099MigrationLog.Insert();
        ClearLastError();
    end;

    local procedure LogErrorMessage(VendorNo: Code[20]; ErrorMsg: Text)
    var
        SL1099MigrationLog: Record "SL 1099 Migration Log";
    begin
        SL1099MigrationLog."Vendor No." := VendorNo;
        SL1099MigrationLog.IsError := true;
        SL1099MigrationLog.SetErrorMessage(ErrorMsg);
        SL1099MigrationLog.Insert();
        ClearLastError();
    end;

    local procedure LogVendorSkipped(VendorNo: Code[20]; MessageText: Text[250])
    var
        SL1099MigrationLog: Record "SL 1099 Migration Log";
    begin
        SL1099MigrationLog."Vendor No." := VendorNo;
        SL1099MigrationLog.WasSkipped := true;
        SL1099MigrationLog."Message Text" := MessageText;
        SL1099MigrationLog.Insert();
    end;

    local procedure LogMessage(MessageCode: Text[100]; MessageText: Text[250])
    var
        SL1099MigrationLog: Record "SL 1099 Migration Log";
    begin
        SL1099MigrationLog."Message Code" := MessageCode;
        SL1099MigrationLog."Message Text" := MessageText;
        SL1099MigrationLog.Insert();
    end;

    local procedure LogVendorMessage(VendorNo: Code[20]; MessageCode: Text[100]; MessageText: Text[250])
    var
        SL1099MigrationLog: Record "SL 1099 Migration Log";
    begin
        SL1099MigrationLog."Vendor No." := VendorNo;
        SL1099MigrationLog."Message Code" := MessageCode;
        SL1099MigrationLog."Message Text" := MessageText;
        SL1099MigrationLog.Insert();
    end;

    local procedure LogVendorDefaultBoxMessage(VendorNo: Code[20]; IRS1099Code: Code[10]; MessageCode: Text[100]; MessageText: Text[250])
    var
        SL1099MigrationLog: Record "SL 1099 Migration Log";
    begin
        SL1099MigrationLog."Vendor No." := VendorNo;
        SL1099MigrationLog."BC IRS 1099 Code" := IRS1099Code;
        SL1099MigrationLog."Message Code" := MessageCode;
        SL1099MigrationLog."Message Text" := MessageText;
        SL1099MigrationLog.Insert();
    end;
}