namespace Microsoft.Bank.Deposit;

using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Statement;

table 1693 "Bank Acc. Comment Line"
{
    Caption = 'Bank Account Comment Line';
    DrillDownPageID = "Bank Acc. Comment List";
    LookupPageID = "Bank Acc. Comment List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table Name"; Option)
        {
            Caption = 'Table Name';
            OptionCaption = 'Bank Rec.,Posted Bank Rec.,Bank Deposit Header,Posted Bank Deposit Header';
            OptionMembers = "Bank Rec.","Posted Bank Rec.","Bank Deposit Header","Posted Bank Deposit Header";
        }
        field(2; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            NotBlank = true;
            TableRelation = "Bank Account";
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if ("Table Name" = const("Bank Rec.")) "Bank Acc. Reconciliation"."Statement No." where("Bank Account No." = field("Bank Account No."))
            else
            if ("Table Name" = const("Posted Bank Rec.")) "Bank Account Statement"."Statement No." where("Bank Account No." = field("Bank Account No."))
            else
            if ("Table Name" = const("Bank Deposit Header")) "Bank Deposit Header"
            else
            if ("Table Name" = const("Posted Bank Deposit Header")) "Posted Bank Deposit Header";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Date; Date)
        {
            Caption = 'Date';
        }
        field(6; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(7; Comment; Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1; "Table Name", "Bank Account No.", "No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    internal procedure SetUpNewLine()
    var
        BankAccCommentLine: Record "Bank Acc. Comment Line";
    begin
        BankAccCommentLine.SetRange("Table Name", "Table Name");
        BankAccCommentLine.SetRange("Bank Account No.", "Bank Account No.");
        BankAccCommentLine.SetRange("No.", "No.");
        if BankAccCommentLine.IsEmpty() then
            Date := WorkDate();
    end;
}

