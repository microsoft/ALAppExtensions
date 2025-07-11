// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

page 18771 "Provisional Entries Preview"
{
    Caption = 'Provisional Entries Preview';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    UsageCategory = Lists;
    PageType = List;
    SourceTable = "Provisional Entry";
    SourceTableView = where(Open = const(true));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the journal batch name on the ledger entry.';
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the journal template name on the ledger entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type on the ledger entry.';
                }
                field("Posted Document No."; Rec."Posted Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number which identifies the posted transaction.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the ledger entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("Party Type"; Rec."Party Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the party type of the transaction.';
                }
                field("Party Code"; Rec."Party Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant party code of the transaction.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account where the entry will be posted.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the entry will be posted.';
                }
                field("TDS Section Code"; Rec."TDS Section Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS Section code.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount of the transaction.';
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the debit amount of the transaction.';
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the credit amount of the transaction.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account where the balancing entry will be posted.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the balancing entry will be posted.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of location where the entry is posted to.';
                }
                field("Externl Document No."; Rec."Externl Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the external document no. of the transaction.';
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the posted entry is reversed.';
                }
                field("Original Invoice Posted"; Rec."Original Invoice Posted")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original invoice number.';
                }
                field("Applied Invoice No."; Rec."Applied Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied invoice number.';
                }
                field("Original Invoice Reversed"; Rec."Original Invoice Reversed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the original invoice is reversed.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who created the document.';
                }
                field("Applied by Vendor Ledger Entry"; Rec."Applied by Vendor Ledger Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied vendor ledger entry number.';
                }
                field("Reversed After TDS Paid"; Rec."Reversed After TDS Paid")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the entry is reversed after TDS payment.';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether this is an open entry or not.';
                }
            }
        }
    }
}
