// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Payables;

pageextension 31016 "Vendor Ledger Entries CZL" extends "Vendor Ledger Entries"
{
    layout
    {
        addafter("Message to Recipient")
        {
            field("Vendor Posting Group CZL"; Rec."Vendor Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the vendor''s market type to link business transactions made for the vendor with the appropriate account in the general ledger.';
            }
        }
        addlast(Control1)
        {
            field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the detail information for payment.';
                Visible = false;
            }
            field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Bank Account Code CZL"; Rec."Bank Account Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code to idenfity bank account.';
            }
            field("Bank Account No. CZL"; Rec."Bank Account No. CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the number used by the bank for the bank account.';
                Visible = false;
            }
            field("Transit No. CZL"; Rec."Transit No. CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a bank identification number of your own choice.';
                Visible = false;
            }
            field("IBAN CZL"; Rec."IBAN CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the bank account''s international bank account number.';
                Visible = false;
            }
            field("SWIFT Code CZL"; Rec."SWIFT Code CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the international bank identifier code (SWIFT) of the bank where you have the account.';
                Visible = false;
            }
        }
        addafter("Remaining Amt. (LCY)")
        {
            field(SuggestedAmountToApplyCZL; Rec.CalcSuggestedAmountToApplyCZL())
            {
                Caption = 'Suggested Amount to Apply (LCY)';
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the total Amount (LCY) suggested to apply.';
                Visible = false;

                trigger OnDrillDown()
                begin
                    Rec.DrillDownSuggestedAmountToApplyCZL();
                end;
            }
        }
    }
}
