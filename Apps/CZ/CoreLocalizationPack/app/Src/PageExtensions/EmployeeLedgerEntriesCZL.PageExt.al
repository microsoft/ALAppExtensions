// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.HumanResources.Payables;

pageextension 31100 "Employee Ledger Entries CZL" extends "Employee Ledger Entries"
{
    layout
    {
        addlast(Group)
        {
            field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the detail information for payment.';
                Visible = false;
            }
            field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
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
