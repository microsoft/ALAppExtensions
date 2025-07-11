namespace Microsoft.Bank.Reconciliation;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.Dimension;

table 7250 "Bank Acc. Rec. AI Proposal"
{
    TableType = Temporary;
    Extensible = false;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account";
        }
        field(2; "Statement No."; Code[20])
        {
            Caption = 'Statement No.';
            TableRelation = "Bank Acc. Reconciliation"."Statement No." where("Bank Account No." = field("Bank Account No."));
        }
        field(3; "Statement Line No."; Integer)
        {
            Caption = 'Statement Line No.';
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(5; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; Difference; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Amount to Apply';
        }
        field(20; "Statement Type"; Enum "Bank Acc. Rec. Stmt. Type")
        {
            Caption = 'Statement Type';
        }
        field(40; "G/L Account No."; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if not GLAccount.Get("G/L Account No.") then
                    exit;

                "AI Proposal" := StrSubstNo(PostPaymentProposalTxt, "G/L Account No.", GLAccount.Name);
            end;
        }
        field(41; "Bank Account Ledger Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Bank Account Ledger Entry No.';
            TableRelation = "Bank Account Ledger Entry";

            trigger OnValidate()
            var
                BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
            begin
                if not BankAccountLedgerEntry.Get("Bank Account Ledger Entry No.") then
                    exit;

                "AI Proposal" := StrSubstNo(ApplyToLedgerEntryTxt, Format(BankAccountLedgerEntry."Posting Date"), BankAccountLedgerEntry.Description, Format(BankAccountLedgerEntry."Remaining Amount"));
            end;
        }
        field(42; "AI Proposal"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Proposal';
        }
        field(50; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template";
        }
        field(51; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
    }
    keys
    {
        key(Key1; "Statement Type", "Bank Account No.", "Statement No.", "Statement Line No.", "Bank Account Ledger Entry No.")
        {
            Clustered = true;
        }
    }

    local procedure GetCurrencyCode(): Code[10]
    var
        BankAccount: Record "Bank Account";
    begin
        if "Bank Account No." = BankAccount."No." then
            exit(BankAccount."Currency Code");

        if BankAccount.Get("Bank Account No.") then
            exit(BankAccount."Currency Code");

        exit('');
    end;

    var
        PostPaymentProposalTxt: label '%1 (%2)', Comment = '%1 - G/L Account number, %2 - G/L Account name';
        ApplyToLedgerEntryTxt: label '%1; %2; %3', Comment = '%1 - bank accout ledger entry date, %2 bank account ledger entry description, , %3 bank account ledger entry amount';
}