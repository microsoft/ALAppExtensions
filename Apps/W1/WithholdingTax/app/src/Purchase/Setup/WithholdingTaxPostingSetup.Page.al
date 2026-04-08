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
    AboutTitle = 'About Withholding Tax Posting Setup';
    AboutText = 'Configure how withholding tax amounts are calculated and posted to general ledger accounts. Define combinations of withholding tax business and product posting groups, and map vendors and items to the correct accounts to ensure accurate tax calculation and financial reporting.';

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
                    NotBlank = true;
                }
                field("Wthldg. Tax Prod. Post. Group"; Rec."Wthldg. Tax Prod. Post. Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Withholding Tax Product Posting group code.';
                    NotBlank = true;
                }
                field("Wthldg. Tax Calculation Rule"; Rec."Wthldg. Tax Calculation Rule")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculation rule for withholding tax, which is used with the amount specified in the withholding tax Minimum Invoice Amount field. This helps identify the transactions for which withholding tax isn''t deducted. For example, if you select the Less than option here and enter 100 in the withholding tax Minimum Invoice Amount field, then withholding tax isn''t deducted for those transactions with an amount less than 100.';
                }
                field("Wthldg. Tax Min. Inv. Amount"; Rec."Wthldg. Tax Min. Inv. Amount")
                {
                    AutoFormatType = 1;
                    AutoFormatExpression = '';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the threshold amount for Withholding Tax, below which there will not be any Withholding Tax deduction.';
                }
                field("Withholding Tax %"; Rec."Withholding Tax %")
                {
                    AutoFormatType = 0;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant Withholding Tax rate for the particular combination of Withholding Tax Business Posting group and Withholding Tax Product Posting group.';
                }
                field("Realized Withholding Tax Type"; Rec."Realized Withholding Tax Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the withholding tax is realized for the transaction. Choose whether the withholding is realized when the invoice is posted, when the payment is posted, or at the earliest of the two.';
                }
                field("Prepaid Wthldg. Tax Acc. Code"; Rec."Prepaid Wthldg. Tax Acc. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the G/L account number used to post prepaid (advance) withholding tax for the selected combination of Withholding Tax business posting group and product posting group.';
                }
                field("Payable Wthldg. Tax Acc. Code"; Rec."Payable Wthldg. Tax Acc. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the G/L account number used to post payable withholding tax for the selected combination of Withholding Tax business posting group and product posting group. This account is used when withholding tax becomes due and payable to the tax authority, such as upon payment posting or when the withholding obligation is finalized.';
                }
                field("Bal. Prepaid Account Type"; Rec."Bal. Prepaid Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of balancing account for withholding tax transactions.';
                }
                field("Bal. Prepaid Account No."; Rec."Bal. Prepaid Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number or bank name for sales withholding tax transactions, based on the type selected in the Bal. Prepaid Account Type field.';
                }
                field("Bal. Payable Account Type"; Rec."Bal. Payable Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of balancing account for purchase withholding tax transactions.';
                }
                field("Bal. Payable Account No."; Rec."Bal. Payable Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number or bank name for purchase withholding tax transactions. This is based on the type selected in the Bal. Payable Account Type field.';
                }
                field("Withholding Tax Report Line No. Series"; Rec."Wthldg. Tax Rep Line No Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series for the withholding tax report line.';
                }
                field("Revenue Type"; Rec."Revenue Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of revenue.';
                    ShowMandatory = true;
                }
                field("Purch. Wthldg. Tax Adj. Acc No"; Rec."Purch. Wthldg. Tax Adj. Acc No")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number on which to post purchase credit memo adjustments.';
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
                    ToolTip = 'Specifies the sequence in which the withholding tax posting setup information must be displayed in reports.';
                }
            }
        }
    }
}