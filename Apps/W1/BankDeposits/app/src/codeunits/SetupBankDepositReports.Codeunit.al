// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 1697 "Setup Bank Deposit Reports"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
    begin
        SetupNumberSeries();
        SetupJournalTemplateAndBatch();
        SetupReportSelections();
    end;

    internal procedure SetupNumberSeries()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if not SalesReceivablesSetup.Get() then begin
            SalesReceivablesSetup.Init();
            SalesReceivablesSetup.Insert();
        end;

        InitBaseSeries(SalesReceivablesSetup."Bank Deposit Nos.", BankDepositNoSeriesCodeTxt, BankDepositNoSeriesDescriptionTxt, BankDepositNoSeriesStartingNoTxt, BankDepositNoSeriesEndingNoTxt, '', '', 1);
        SalesReceivablesSetup.Modify();
    end;

    internal procedure SetupReportSelections()
    var
        ReportSelections: Record "Report Selections";
    begin
        InsertReportSelections(ReportSelections.Usage::"Bank Deposit", '1', Report::"Bank Deposit");
        InsertReportSelections(ReportSelections.Usage::"Bank Deposit Test", '1', Report::"Bank Deposit Test Report");
    end;

    internal procedure SetupJournalTemplateAndBatch()
    var
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        CashReceiptGenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if not SourceCodeSetup.Get() then begin
            SourceCodeSetup.Init();
            SourceCodeSetup.Insert();
        end;
        SourceCodeSetup."Bank Deposit" := BankDepositNoSeriesCodeTxt;
        SourceCodeSetup.Modify();

        GenJournalTemplate.SetRange(Type, "Gen. Journal Template Type"::"Bank Deposits");
        if not GenJournalTemplate.FindFirst() then begin
            GenJournalTemplate.Name := BankDepositNoSeriesCodeTxt;
            GenJournalTemplate.Description := BankDepositJournalTemplateDescriptionTxt;
            GenJournalTemplate."Bal. Account Type" := "Gen. Journal Account Type"::"Bank Account";
            GenJournalTemplate."Source Code" := SourceCodeSetup."Bank Deposit";
            GenJournalTemplate.Type := "Gen. Journal Template Type"::"Bank Deposits";
            GenJournalTemplate."Copy to Posted Jnl. Lines" := true;
            GenJournalTemplate."Copy VAT Setup to Jnl. Lines" := true;
            CashReceiptGenJournalTemplate.SetRange(Type, "Gen. Journal Template Type"::"Cash Receipts");
            if CashReceiptGenJournalTemplate.FindFirst() then
                GenJournalTemplate."No. Series" := CashReceiptGenJournalTemplate."No. Series";
            GenJournalTemplate.Insert(true);

            GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
            GenJournalBatch.DeleteAll();
            GenJournalBatch.Name := BankDepositNoSeriesCodeTxt;
            GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
            GenJournalBatch.Description := BankDepositJournalBatchDescriptionTxt;
            GenJournalBatch."Bal. Account Type" := "Gen. Journal Account Type"::"Bank Account";
            GenJournalBatch."No. Series" := GenJournalTemplate."No. Series";
            GenJournalBatch."Copy to Posted Jnl. Lines" := true;
            GenJournalBatch."Copy VAT Setup to Jnl. Lines" := true;
            GenJournalBatch.Insert(true);
        end;
    end;

    local procedure InsertReportSelections(ReportUsage: Enum "Report Selection Usage"; ReportSequence: Code[10]; ReportId: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        if not ReportSelections.Get(ReportUsage, ReportSequence) then begin
            ReportSelections.Init();
            ReportSelections.Usage := ReportUsage;
            ReportSelections.Sequence := ReportSequence;
            ReportSelections."Report ID" := ReportId;
            ReportSelections."Use for Email Attachment" := true;
            ReportSelections."Use for Email Body" := false;
            if ReportSelections.Insert() then;
        end;
    end;

    procedure InitBaseSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; "Starting No.": Code[20]; "Ending No.": Code[20]; "Last Number Used": Code[20]; "Warning at No.": Code[20]; "Increment-by No.": Integer)
    begin
        InitBaseSeries(SeriesCode, "Code", Description, "Starting No.", "Ending No.", "Last Number Used", "Warning at No.", "Increment-by No.", false);
    end;

    internal procedure InitBaseSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; "Starting No.": Code[20]; "Ending No.": Code[20]; "Last Number Used": Code[20]; "Warning at No.": Code[20]; "Increment-by No.": Integer; "Allow Gaps": Boolean)
    begin
        InsertSeries(
          SeriesCode, Code, Description,
          "Starting No.", "Ending No.", "Last Number Used", "Warning at No.", "Increment-by No.", true, "Allow Gaps");
    end;

    local procedure InsertSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; "Starting No.": Code[20]; "Ending No.": Code[20]; "Last Number Used": Code[20]; "Warning No.": Code[20]; "Increment-by No.": Integer; "Manual Nos.": Boolean; "Allow Gaps": Boolean)
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(Code) then
            exit;

        NoSeries.Init();
        NoSeries.Code := Code;
        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := "Manual Nos.";
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine.Validate("Starting No.", "Starting No.");
        NoSeriesLine.Validate("Ending No.", "Ending No.");
        NoSeriesLine.Validate("Last No. Used", "Last Number Used");
        if "Warning No." <> '' then
            NoSeriesLine.Validate("Warning No.", "Warning No.");
        NoSeriesLine.Validate("Increment-by No.", "Increment-by No.");
        NoSeriesLine.Validate("Allow Gaps in Nos.", "Allow Gaps");
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Insert(true);

        SeriesCode := Code;
    end;

    var
        BankDepositNoSeriesCodeTxt: Label 'BNKDEPOSIT', Locked = true;
        BankDepositJournalTemplateDescriptionTxt: Label 'Bank Deposit Journals';
        BankDepositJournalBatchDescriptionTxt: Label 'Bank Deposit Journal';
        BankDepositNoSeriesDescriptionTxt: Label 'Bank Deposit';
        BankDepositNoSeriesStartingNoTxt: Label 'BD00001';
        BankDepositNoSeriesEndingNoTxt: Label 'BD99999';
}