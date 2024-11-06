namespace Microsoft.Bank.Deposit;

using System.Environment;
using System.Upgrade;
using Microsoft.Foundation.Reporting;
using System.Reflection;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.Check;
using Microsoft.Bank.Reports;

codeunit 1714 "Upgrade Bank Deposits"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDefBankDeposits: Codeunit "Upg. Tag Def. Bank Deposits";
        Localization: Text;
    begin
        Localization := EnvironmentInformation.GetApplicationFamily();
        if (Localization <> 'NA') and (Localization <> 'US') and (Localization <> 'MX') and (Localization <> 'CA') then
            exit;
        if UpgradeTag.HasUpgradeTag(UpgTagDefBankDeposits.GetNADepositsUpgradeTag()) then
            exit;
        UpgradeNADepositsIntoBankDeposits();
        UpgradeNABankRecWorksheetsIntoBankReconciliations();
#if not CLEAN24
        SetDepositsPageMgtPages();
#endif
        SetReportSelections();
        UpgradeTag.SetUpgradeTag(UpgTagDefBankDeposits.GetNADepositsUpgradeTag());
    end;

    local procedure SetReportSelections()
    var
        ReportSelections: Record "Report Selections";
    begin
        SelectReport(ReportSelections.Usage::"B.Stmt", Report::"Bank Account Statement");
        SelectReport(ReportSelections.Usage::"B.Recon.Test", Report::"Bank Acc. Recon. - Test");
    end;

    local procedure SelectReport(UsageValue: Enum "Report Selection Usage"; ReportID: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange(Usage, UsageValue);

        case true of
            ReportSelections.IsEmpty():
                begin
                    ReportSelections.Reset();
                    ReportSelections.InsertRecord(UsageValue, '1', ReportID);
                    exit;
                end;
            ReportSelections.Count = 1:
                begin
                    ReportSelections.FindFirst();
                    if ReportSelections."Report ID" <> ReportID then begin
                        ReportSelections.Validate("Report ID", ReportID);
                        ReportSelections.Modify();
                        exit;
                    end;
                end;
            else
                exit;
        end;
    end;

#if not CLEAN24
    local procedure SetDepositsPageMgtPages()
    var
        DepositsPageMgt: Codeunit "Deposits Page Mgt.";
    begin
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositsPage, Page::"Bank Deposits");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositPage, Page::"Bank Deposit");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositListPage, Page::"Bank Deposit List");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositReport, Report::"Bank Deposit");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositTestReport, Report::"Bank Deposit Test Report");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::PostedBankDepositListPage, Page::"Posted Bank Deposit List");
    end;
#endif

    local procedure UpgradeNADepositsIntoBankDeposits()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        DepositHeaderRecRef: RecordRef;
        BankDepositHeaderRecRef: RecordRef;
        PreviousDepositNoFieldRef: FieldRef;
        PreviousDepositNo: Code[20];
        DepositsTableId: Integer;
    begin
        DepositsTableId := 10140;
        DepositHeaderRecRef.Open(DepositsTableId, false);
        if DepositHeaderRecRef.IsEmpty() then
            exit;
        DepositHeaderRecRef.FindSet();
        BankDepositHeaderRecRef.Open(Database::"Bank Deposit Header", false);
        repeat
            PreviousDepositNoFieldRef := DepositHeaderRecRef.Field(BankDepositHeader.FieldNo("No."));
            PreviousDepositNo := PreviousDepositNoFieldRef.Value();
            if not BankDepositHeader.Get(PreviousDepositNo) then begin
                BankDepositHeaderRecRef.Init();
                TransferFields(BankDepositHeaderRecRef, DepositHeaderRecRef);
                BankDepositHeaderRecRef.Insert();
            end;
        until DepositHeaderRecRef.Next() = 0;
    end;

    local procedure TransferFields(var TargetRecRef: RecordRef; var SourceRecRef: RecordRef)
    var
        Field: Record Field;
        SourceFieldRef: FieldRef;
        TargetFieldRef: FieldRef;
    begin
        Field.SetRange(TableNo, SourceRecRef.Number());
        repeat
            if TryGetFieldRef(SourceRecRef, SourceFieldRef, Field."No.") and TryGetFieldRef(TargetRecRef, TargetFieldRef, Field."No.") then
                TargetFieldRef.Value(SourceFieldRef.Value());
        until Field.Next() = 0;
    end;

    [TryFunction()]
    local procedure TryGetFieldRef(var RecordRef: RecordRef; var FieldRef: FieldRef; FieldNo: Integer)
    begin
        FieldRef := RecordRef.Field(FieldNo);
    end;


    local procedure UpgradeNABankRecWorksheetsIntoBankReconciliations()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankRecHeaderRecRef: RecordRef;
        BankRecHeaderStatementNoFieldRef: FieldRef;
        BankRecHeaderBankAccountNoFieldRef: FieldRef;
        StatementNo: Code[20];
        BankAccountNo: Code[20];
        BankRecHeaderTableId: Integer;
    begin
        BankRecHeaderTableId := 10120;
        BankRecHeaderRecRef.Open(BankRecHeaderTableId, false);
        if BankRecHeaderRecRef.IsEmpty() then
            exit;
        BankRecHeaderRecRef.FindSet();
        repeat
            BankRecHeaderStatementNoFieldRef := BankRecHeaderRecRef.Field(BankAccReconciliation.FieldNo("Statement No."));
            BankRecHeaderBankAccountNoFieldRef := BankRecHeaderRecRef.Field(BankAccReconciliation.FieldNo("Bank Account No."));
            StatementNo := BankRecHeaderStatementNoFieldRef.Value();
            BankAccountNo := BankRecHeaderBankAccountNoFieldRef.Value();
            if not BankAccReconciliation.Get(BankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccountNo, StatementNo) then
                TransferBankReconciliation(BankRecHeaderRecRef, BankAccountNo, StatementNo);
        until BankRecHeaderRecRef.Next() = 0;
    end;

    local procedure TransferBankReconciliation(var BankRecHeaderRecRef: RecordRef; BankAccountNo: Code[20]; StatementNo: Code[20])
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        BankRecLineRecRef: RecordRef;
        BankRecLineFieldRef: FieldRef;
        BankRecLineTableId, StatementLineNo : Integer;
    begin
        BankRecLineTableId := 10121;
        BankAccReconciliation."Statement Type" := BankAccReconciliation."Statement Type"::"Bank Reconciliation";
        BankAccReconciliation."Bank Account No." := BankAccountNo;
        BankAccReconciliation."Statement No." := StatementNo;

        BankAccReconciliation."Statement Ending Balance" := GetRecRefFieldFromFieldName(BankRecHeaderRecRef, 'Statement Balance').Value();
        BankAccReconciliation."Statement Date" := GetRecRefFieldFromFieldName(BankRecHeaderRecRef, 'Statement Date').Value();
        BankAccReconciliation."Dimension Set ID" := GetRecRefFieldFromFieldName(BankRecHeaderRecRef, 'Dimension Set ID').Value();
        BankAccReconciliation.Insert();

        UnmatchBankLedgerEntries(BankAccountNo, StatementNo);

        BankRecLineRecRef.Open(BankRecLineTableId, false);
        BankRecLineFieldRef := BankRecLineRecRef.Field(BankAccReconciliationLine.FieldNo("Bank Account No."));
        BankRecLineFieldRef.SetRange(BankAccountNo);
        BankRecLineFieldRef := BankRecLineRecRef.Field(BankAccReconciliationLine.FieldNo("Statement No."));
        BankRecLineFieldRef.SetRange(StatementNo);
        TransferCheckLines(BankRecLineRecRef, StatementLineNo, BankAccountNo, StatementNo);
        TransferDepositAndAdjustmentLines(BankRecLineRecRef, StatementLineNo, BankAccountNo, StatementNo);
    end;

    local procedure TransferDepositAndAdjustmentLines(var BankRecLineRecRef: RecordRef; var StatementLineNo: Integer; BankAccountNo: Code[20]; StatementNo: Code[20])
    var
        StatementAmount: Decimal;
    begin
        GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Record Type').SetFilter('%1|%2', 1, 2);
        if BankRecLineRecRef.IsEmpty() then
            exit;
        BankRecLineRecRef.FindSet();
        repeat
            StatementAmount := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Cleared Amount').Value();
            InsertBankReconciliationLine(BankAccountNo, StatementNo, StatementAmount, BankRecLineRecRef, StatementLineNo);
        until BankRecLineRecRef.Next() = 0;
    end;

    local procedure GetRecRefFieldFromFieldName(var RecRef: RecordRef; FieldName: Text[30]): FieldRef
    begin
        exit(RecRef.Field(GetFieldNo(RecRef.Number(), FieldName)));
    end;

    local procedure GetFieldNo(TableId: Integer; FieldName: Text[30]): Integer
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableId);
        Field.SetRange(FieldName, FieldName);
        Field.FindFirst();
        exit(Field."No.");
    end;

    local procedure TransferCheckLines(var BankRecLineRecRef: RecordRef; var StatementLineNo: Integer; BankAccountNo: Code[20]; StatementNo: Code[20])
    var
        StatementAmount: Decimal;
    begin
        GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Record Type').SetRange(0);
        if BankRecLineRecRef.IsEmpty() then
            exit;
        BankRecLineRecRef.FindSet();
        repeat
            StatementAmount := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Cleared Amount').Value();
            StatementAmount *= -1; // check lines are positive in NA's BankRecLine, although Bank entries are negative
            InsertBankReconciliationLine(BankAccountNo, StatementNo, StatementAmount, BankRecLineRecRef, StatementLineNo);
        until BankRecLineRecRef.Next() = 0;
    end;

    local procedure InsertBankReconciliationLine(BankAccountNo: Code[20]; StatementNo: Code[20]; StatementAmount: Decimal; var BankRecLineRecRef: RecordRef; var StatementLineNo: Integer)
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        MatchBankRecLines: Codeunit "Match Bank Rec. Lines";
        BankLedgerEntryNo: Integer;
    begin
        if not GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Cleared').Value() then
            exit;
        StatementLineNo += 10000;
        BankAccReconciliationLine."Bank Account No." := BankAccountNo;
        BankAccReconciliationLine."Statement No." := StatementNo;
        BankAccReconciliationLine."Statement Line No." := StatementLineNo;
        BankAccReconciliationLine."Transaction Date" := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Posting Date').Value();
        BankAccReconciliationLine.Description := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Description').Value();
        BankAccReconciliationLine."Statement Amount" := StatementAmount;
        BankAccReconciliationLine."Statement Type" := BankAccReconciliationLine."Statement Type"::"Bank Reconciliation";
        BankAccReconciliationLine."Shortcut Dimension 1 Code" := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Shortcut Dimension 1 Code').Value();
        BankAccReconciliationLine."Shortcut Dimension 2 Code" := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Shortcut Dimension 2 Code').Value();
        BankAccReconciliationLine."Dimension Set ID" := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Dimension Set ID').Value();
        BankAccReconciliationLine."Applied Entries" := 0;
        BankAccReconciliationLine.Insert();
        BankAccReconciliationLine.Validate("Applied Amount", 0);
        BankLedgerEntryNo := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Bank Ledger Entry No.').Value();
        if BankLedgerEntryNo <> 0 then
            if BankAccountLedgerEntry.Get(BankLedgerEntryNo) then
                if ShouldMatch(BankAccountLedgerEntry) then begin
                    BankAccountLedgerEntry.SetRecFilter();
                    BankAccReconciliationLine.SetRecFilter();
                    MatchBankRecLines.MatchManually(BankAccReconciliationLine, BankAccountLedgerEntry);
                end;
    end;

    local procedure ShouldMatch(BankAccountLedgerEntry: Record "Bank Account Ledger Entry"): Boolean
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
    begin
        if not BankAccountLedgerEntry.Open then
            exit(false);
        if BankAccountLedgerEntry."Statement No." <> '' then
            exit(false);
        if BankAccountLedgerEntry."Statement Line No." <> 0 then
            exit(false);
        CheckLedgerEntry.ReadIsolation := CheckLedgerEntry.ReadIsolation::ReadCommitted;
        CheckLedgerEntry.SetRange("Bank Account Ledger Entry No.", BankAccountLedgerEntry."Entry No.");
        CheckLedgerEntry.SetRange(Open, true);
        if not CheckLedgerEntry.FindSet() then
            exit(true);
        repeat
            if CheckLedgerEntry."Statement No." <> '' then
                exit(false);
            if CheckLedgerEntry."Statement Line No." <> 0 then
                exit(false);
            if CheckLedgerEntry."Statement Status" <> CheckLedgerEntry."Statement Status"::Open then
                exit(false);
        until CheckLedgerEntry.Next() = 0;
        exit(true);
    end;


    local procedure UnmatchBankLedgerEntries(BankAccountNo: Code[20]; StatementNo: Code[20])
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        CheckLedgerEntry: Record "Check Ledger Entry";
    begin
        if (BankAccountNo = '') or (StatementNo = '') then
            exit;
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccountNo);
        BankAccountLedgerEntry.SetRange("Statement No.", StatementNo);
        BankAccountLedgerEntry.SetRange(Open, true);
        if not BankAccountLedgerEntry.IsEmpty() then begin
            BankAccountLedgerEntry.FindSet();
            repeat
                BankAccountLedgerEntry."Statement Status" := BankAccountLedgerEntry."Statement Status"::Open;
                BankAccountLedgerEntry."Statement No." := '';
                BankAccountLedgerEntry."Statement Line No." := 0;
                Clear(CheckLedgerEntry);
                CheckLedgerEntry.SetRange("Bank Account Ledger Entry No.", BankAccountLedgerEntry."Entry No.");
                if not CheckLedgerEntry.IsEmpty() then begin
                    CheckLedgerEntry.FindSet();
                    repeat
                        CheckLedgerEntry."Statement Status" := CheckLedgerEntry."Statement Status"::Open;
                        CheckLedgerEntry."Statement No." := '';
                        CheckLedgerEntry."Statement Line No." := 0;
                        CheckLedgerEntry.Modify();
                    until CheckLedgerEntry.Next() = 0;
                end;
                BankAccountLedgerEntry.Modify();
            until BankAccountLedgerEntry.Next() = 0;
        end;
        Clear(CheckLedgerEntry);
        CheckLedgerEntry.SetRange("Bank Account No.", BankAccountNo);
        CheckLedgerEntry.SetRange("Statement No.", StatementNo);
        CheckLedgerEntry.SetRange(Open, true);
        if CheckLedgerEntry.IsEmpty() then
            exit;
        CheckLedgerEntry.ModifyAll("Statement Status", CheckLedgerEntry."Statement Status"::Open);
        CheckLedgerEntry.ModifyAll("Statement No.", '');
        CheckLedgerEntry.ModifyAll("Statement Line No.", 0);
    end;


}