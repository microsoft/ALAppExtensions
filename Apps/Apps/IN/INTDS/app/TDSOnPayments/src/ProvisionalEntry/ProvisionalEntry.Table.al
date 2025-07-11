// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxBase;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Inventory.Location;
using Microsoft.Finance.Currency;
using Microsoft.Sales.Customer;
using Microsoft.Bank.BankAccount;
using Microsoft.FixedAssets.FixedAsset;

table 18766 "Provisional Entry"
{
    Caption = 'Provisional Entry';
    DrillDownPageID = "Provisional Entries";
    LookupPageID = "Provisional Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Party Type"; enum "GenJnl Party Type")
        {
            Caption = 'Party Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "Party Code"; Code[20])
        {
            Caption = 'Party Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Party Type" = const(Vendor)) Vendor."No."
            else
            if ("Party Type" = const(Customer)) Customer."No.";
        }
        field(9; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                      Blocked = const(false))
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset";
        }
        field(11; "TDS Section Code"; Code[10])
        {
            Caption = 'TDS Section Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "TDS Section";
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Debit Amount"; Decimal)
        {
            Caption = 'Debit Amount';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                           Blocked = const(false))
            else
            if ("Bal. Account Type" = const(Customer)) Customer
            else
            if ("Bal. Account Type" = const(Vendor)) Vendor
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Bal. Account Type" = const("Fixed Asset")) "Fixed Asset";
        }
        field(17; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Location;
        }
        field(18; "Externl Document No."; Code[35])
        {
            Caption = 'Externl Document No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(19; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "Original Invoice Posted"; Boolean)
        {
            Caption = 'Original Invoice Posted';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(21; "Original Invoice Reversed"; Boolean)
        {
            Caption = 'Original Invoice Reversed';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(22; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(23; "Applied by Vendor Ledger Entry"; Integer)
        {
            Caption = 'Applied by Vendor Ledger Entry';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(24; "Reversed After TDS Paid"; Boolean)
        {
            Caption = 'Reversed After TDS Paid';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(25; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(26; "Applied Invoice No."; Code[20])
        {
            Caption = 'Applied Invoice No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(27; "Posted Document No."; Code[20])
        {
            Caption = 'Posted Document No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(28; "Purchase Invoice No."; Code[20])
        {
            Caption = 'Purchase Invoice No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(29; "Invoice Jnl Batch Name"; Code[10])
        {
            Caption = 'Invoice Jnl Batch Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(30; "Invoice Jnl Template Name"; Code[10])
        {
            Caption = 'Invoice Jnl Template Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(31; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(32; "Amount LCY"; Decimal)
        {
            Caption = 'Amount LCY';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(33; "Applied User ID"; Code[50])
        {
            Caption = 'Applied User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(34; "Actual Invoice Posting Date"; Date)
        {
            Caption = 'Actual Invoice Posting Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(35; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Currency;
        }
        field(36; Update; Boolean)
        {
            Caption = 'Update';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure Apply(GenJournalLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        ProvisionalEntry: Record "Provisional Entry";
        PostingDateEarlierErr: Label 'Invoice Posting Date must not be earlier than Provisional Entry Posting Date.';
        AlreadyAppliedErr: Label 'Provisional Entry is already applied.';
        MultiEntryApplyErr: Label 'You canot apply more than one Provisional Entry.';
    begin
        GenJnlLine.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
        if "Purchase Invoice No." <> '' then
            Error(AlreadyAppliedErr);

        if GenJnlLine."Applied Provisional Entry" <> 0 then
            Error(MultiEntryApplyErr);

        if "Posting Date" > GenJnlLine."Posting Date" then
            Error(PostingDateEarlierErr);

        GenJnlLine.TestField("Bal. Account No.", "Bal. Account No.");
        GenJnlLine.TestField(Amount, Amount);
        GenJnlLine.TestField("Location Code", "Location Code");
        GenJnlLine.TestField("Account No.", "Party Code");
        GenJnlLine.TestField("Currency Code", "Currency Code");
        GenJnlLine."Applied Provisional Entry" := "Entry No.";
        GenJnlLine.Modify();

        if not ProvisionalEntry.Get("Entry No.") then
            exit;

        ProvisionalEntry."Purchase Invoice No." := GenJnlLine."Document No.";
        ProvisionalEntry."Invoice Jnl Batch Name" := GenJnlLine."Journal Batch Name";
        ProvisionalEntry."Invoice Jnl Template Name" := GenJnlLine."Journal Template Name";
        ProvisionalEntry."Applied User ID" := CopyStr(UserId, 1, 50);
        ProvisionalEntry.Modify();
    end;

    procedure Unapply(GenJournalLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        ProvisionalEntry: Record "Provisional Entry";
        DiffUserErr: Label 'This entry is already applied by another user.';
    begin
        if "Purchase Invoice No." <> '' then
            if UserId <> "Applied User ID" then
                Error(DiffUserErr);

        GenJnlLine.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
        ProvisionalEntry.Get("Entry No.");
        ProvisionalEntry."Purchase Invoice No." := '';
        ProvisionalEntry."Invoice Jnl Batch Name" := '';
        ProvisionalEntry."Invoice Jnl Template Name" := '';
        ProvisionalEntry."Applied User ID" := '';
        ProvisionalEntry.Modify();

        GenJnlLine."Applied Provisional Entry" := 0;
        GenJnlLine.Modify();
    end;
}
