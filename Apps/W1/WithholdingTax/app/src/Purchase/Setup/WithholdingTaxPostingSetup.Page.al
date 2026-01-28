// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

page 6786 "Withholding Tax Posting Setup"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Withholding Tax Posting Setup';
    PageType = List;
    SourceTable = "Withholding Tax Posting Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;
                field("Wthldg. Tax Bus. Post. Group"; Rec."Wthldg. Tax Bus. Post. Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Withholding Tax Business Posting group code.';
                }
                field("Wthldg. Tax Prod. Post. Group"; Rec."Wthldg. Tax Prod. Post. Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Withholding Tax Product Posting group code.';
                }
                field("Wthldg. Tax Calculation Rule"; Rec."Wthldg. Tax Calculation Rule")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Withholding Tax calculation rule.';
                }
                field("Wthldg. Tax Min. Inv. Amount"; Rec."Wthldg. Tax Min. Inv. Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the threshold amount for Withholding Tax, below which there will not be any Withholding Tax deduction.';
                }
                field("Withholding Tax %"; Rec."Withholding Tax %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant Withholding Tax rate for the particular combination of Withholding Tax Business Posting group and Withholding Tax Product Posting group.';
                }
                field("Realized Withholding Tax Type"; Rec."Realized Withholding Tax Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how Withholding Tax is calculated for purchases or sales of items with this particular combination of Withholding Tax business and product posting groups.';
                }
                field("Prepaid Wthldg. Tax Acc. Code"; Rec."Prepaid Wthldg. Tax Acc. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the G/L account number to which you want to post sales Withholding for the particular combination of Withholding Tax business and product posting groups.';
                }
                field("Payable Wthldg. Tax Acc. Code"; Rec."Payable Wthldg. Tax Acc. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the G/L account number to which you want to post Purchase Withholding for the particular combination of Withholding Tax business and product posting groups.';
                }
                field("Withholding Tax Report"; Rec."Withholding Tax Report")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Withholding Tax report type for a particular Business and Product Posting group combination.';
                }
                field("Bal. Prepaid Account Type"; Rec."Bal. Prepaid Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of Balancing Account type for Sales Withholding transaction.';
                }
                field("Bal. Prepaid Account No."; Rec."Bal. Prepaid Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Account No. or Bank name (based on Bal. Prepaid Account Type) as a balancing account for Sales Withholding transactions.';
                }
                field("Bal. Payable Account Type"; Rec."Bal. Payable Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of Balancing Account type for Purchase Withholding transaction.';
                }
                field("Bal. Payable Account No."; Rec."Bal. Payable Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Account No. or Bank name (based on Bal. Prepaid Account Type) as a balancing account for Purchase Withholding transactions.';
                }
                field("Withholding Tax Report Line No. Series"; Rec."Wthldg. Tax Rep Line No Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the no. series for Withholding Report Line for a particular Withholding Business and Product Posting group combination.';
                }
                field("Revenue Type"; Rec."Revenue Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Revenue Type this combination of Withholding Business and Product Posting group belongs to.';
                }
                field("Purch. Wthldg. Tax Adj. Acc No"; Rec."Purch. Wthldg. Tax Adj. Acc No")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an account number for Purchase Credit Memo adjustments.';
                }
                field("Sales Wthldg. Tax Adj. Acc No"; Rec."Sales Wthldg. Tax Adj. Acc No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies an account number for Sales Credit Memo adjustments.';
                }
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sequence in which the Withholding Tax Posting Setup shall be displayed in reports.';
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField(Rec."Revenue Type");
    end;
}