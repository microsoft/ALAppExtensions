// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 10853 "Payment Step Ledger List FR"
{
    Caption = 'Payment Step Ledger List';
    CardPageID = "Payment Step Ledger FR";
    Editable = false;
    PageType = List;
    SourceTable = "Payment Step Ledger FR";

    layout
    {
        area(content)
        {
            repeater(Control1120000)
            {
                ShowCaption = false;
                field("Payment Class"; Rec."Payment Class")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment class.';
                }
                field(Line; Rec.Line)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ledger line''s entry number.';
                }
                field(Sign; Rec.Sign)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the posting will result in a debit or credit entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description to be used on the general ledger entry.';
                }
                field("Accounting Type"; Rec."Accounting Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account to post the entry to.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account to post the entry to.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number to post the entry to.';
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the customer posting group used when the entry is posted.';
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the vendor posting group used when the entry is posted.';
                }
                field(Root; Rec.Root)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the root for the G/L accounts group used, when you have selected either G/L Account / Month, or G/L Account / Week.';
                }
                field("Detail Level"; Rec."Detail Level")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how payment lines will be posted.';
                }
                field(Application; Rec.Application)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how to apply entries.';
                }
                field("Memorize Entry"; Rec."Memorize Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that entries created in this step will be memorized, so the next application can be performed against newly posted entries.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that will be assigned to the ledger entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the method to assign a document number to the ledger entry.';
                }
            }
        }
    }

    actions
    {
    }
}

