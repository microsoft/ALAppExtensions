// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;
using System.Telemetry;

codeunit 6272 "Sustainability Excise Post Mgt"
{
    Permissions =
        tabledata "Sust. Excise Taxes Trans. Log" = i,
        tabledata "Item Ledger Entry" = rm,
        tabledata "Value Entry" = r,
        tabledata "Purch. Inv. Line" = rm,
        tabledata "Sales Invoice Line" = rm;

    procedure InsertExciseTaxesTransactionLog(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        SustExciseTaxesTransactionLog: Record "Sust. Excise Taxes Trans. Log";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SustainabilityLedgerEntryAddedLbl: Label 'Sustainability Excise Taxes Transaction Log Added', Locked = true;
    begin
        SustExciseTaxesTransactionLog.Init();
        FeatureTelemetry.LogUsage('0000PNM', SustainabilityLbl, SustainabilityLedgerEntryAddedLbl);
        FeatureTelemetry.LogUptake('0000PNL', SustainabilityLbl, Enum::"Feature Uptake Status"::"Used");

        // AutoIncrement requires the PK to be empty.
        SustExciseTaxesTransactionLog."Entry No." := 0;
        SustExciseTaxesTransactionLog.CopyFromSustainabilityExciseJnlLine(SustainabilityExciseJnlLine);
        CopyDataFromBatch(SustExciseTaxesTransactionLog, SustainabilityExciseJnlLine);

        UpdateDataFromLogType(SustExciseTaxesTransactionLog);
        SustExciseTaxesTransactionLog.Insert(true);
    end;

    procedure ResetFilters(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    begin
        SustainabilityExciseJnlLine.Reset();
        SustainabilityExciseJnlLine.FilterGroup(2);
        SustainabilityExciseJnlLine.SetRange("Journal Template Name", SustainabilityExciseJnlLine."Journal Template Name");
        SustainabilityExciseJnlLine.SetRange("Journal Batch Name", SustainabilityExciseJnlLine."Journal Batch Name");
        SustainabilityExciseJnlLine.FilterGroup(0);
    end;

    internal procedure GetStartPostingProgressMessage(): Text
    begin
        exit(PostingSustainabilityJournalLbl);
    end;

    internal procedure GetCheckJournalLineProgressMessage(LineNo: Integer): Text
    begin
        exit(StrSubstNo(CheckSustainabilityJournalLineLbl, LineNo));
    end;

    internal procedure GetProgressingLineMessage(LineNo: Integer): Text
    begin
        exit(StrSubstNo(ProcessingLineLbl, LineNo));
    end;

    internal procedure GetJnlLinesPostedMessage(): Text
    begin
        exit(JnlLinesPostedLbl);
    end;

    internal procedure GetPostConfirmMessage(): Text
    begin
        exit(RegisterConfirmLbl);
    end;

    local procedure CopyDataFromBatch(var SustExciseTaxesTransactionLog: Record "Sust. Excise Taxes Trans. Log"; SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        SustExciseJournalBatch: Record "Sust. Excise Journal Batch";
    begin
        SustExciseJournalBatch.Get(SustainabilityExciseJnlLine."Journal Template Name", SustainabilityExciseJnlLine."Journal Batch Name");

        SustExciseTaxesTransactionLog.Validate("Log Type", SustExciseJournalBatch.Type);
    end;

    local procedure UpdateDataFromLogType(SustExciseTaxesTransactionLog: Record "Sust. Excise Taxes Trans. Log")
    begin
        if SustExciseTaxesTransactionLog."Source Document No." = '' then
            exit;

        case SustExciseTaxesTransactionLog."Log Type" of
            SustExciseTaxesTransactionLog."Log Type"::CBAM:
                UpdateCBAMReportedForLogTypeCBAM(SustExciseTaxesTransactionLog);
            SustExciseTaxesTransactionLog."Log Type"::EPR:
                UpdateEPRReportedForLogTypeEPR(SustExciseTaxesTransactionLog);
        end;
    end;

    local procedure UpdateCBAMReportedForLogTypeCBAM(SustExciseTaxesTransactionLog: Record "Sust. Excise Taxes Trans. Log")
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetLoadFields("Document No.", "Line No.", "CBAM Reported");
        PurchInvLine.Get(SustExciseTaxesTransactionLog."Source Document No.", SustExciseTaxesTransactionLog."Source Document Line No.");

        PurchInvLine.Validate("CBAM Reported", true);
        PurchInvLine.Modify();
    end;

    local procedure UpdateEPRReportedForLogTypeEPR(SustExciseTaxesTransactionLog: Record "Sust. Excise Taxes Trans. Log")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ItemLedgerEntry.SetLoadFields("EPR Reported");
        ItemLedgerEntry.Get(SustExciseTaxesTransactionLog."Item Ledger Entry No.");
        ItemLedgerEntry.Validate("EPR Reported", true);
        ItemLedgerEntry.Modify();

        ValueEntry.SetLoadFields("Item Ledger Entry No.", "Document Type", Adjustment, "Document No.", "Document Line No.");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        ValueEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange(Adjustment, false);
        if ValueEntry.FindSet() then
            repeat
                UpdateEPRReportedForLogTypeEPR(ValueEntry);
            until ValueEntry.Next() = 0;
    end;

    local procedure UpdateEPRReportedForLogTypeEPR(ValueEntry: Record "Value Entry")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetLoadFields("EPR Reported");
        if not SalesInvoiceLine.Get(ValueEntry."Document No.", ValueEntry."Document Line No.") then
            exit;

        SalesInvoiceLine.Validate("EPR Reported", true);
        SalesInvoiceLine.Modify();
    end;

    var
        PostingSustainabilityJournalLbl: Label 'Posting Sustainability Excise Journal Lines: \ #1', Comment = '#1 = sub-process progress message';
        CheckSustainabilityJournalLineLbl: Label 'Checking Sustainability Excise Journal Line: %1', Comment = '%1 = Line No.';
        ProcessingLineLbl: Label 'Processing Line: %1', Comment = '%1 = Line No.';
        JnlLinesPostedLbl: Label 'The journal lines were successfully posted.';
        RegisterConfirmLbl: Label 'Do you want to register the journal lines?';
        SustainabilityLbl: Label 'Sustainability', Locked = true;
}