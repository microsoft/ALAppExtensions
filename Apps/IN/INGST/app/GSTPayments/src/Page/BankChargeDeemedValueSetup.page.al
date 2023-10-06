// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using System.Integration.Excel;

page 18243 "Bank Charge Deemed Value Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Bank Charge Deemed Value Setup";
    Caption = 'Bank Charge Deemed Value Setup';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Bank Charge Code"; Rec."Bank Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code to identify the set of bank charges.';
                }
                field("Lower Limit"; Rec."Lower Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the lower limit for calculation of bank charges.';
                }
                field("Upper Limit"; Rec."Upper Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the upper limit for calculation of bank charges.';
                }
                field(Formula; Rec.Formula)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a formula that determines the calculation of bank charges.';
                }
                field("Min. Deemed Value"; Rec."Min. Deemed Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the minimum deemed value to warrant the calculation of bank charges.';
                }
                field("Max. Deemed Value"; Rec."Max. Deemed Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum deemed value till which calculation of bank charges will be triggered.';
                }
                field("Deemed %"; Rec."Deemed %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant Deemed rate for the particular combination of Formula. Do not enter percent sign, only the number. For example if the Deemed rate is 10%, enter 10 into this field.';
                }
                field("Fixed Amount"; Rec."Fixed Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the fixed bank charges for the particular combination of formula.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(EditInExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit in Excel';
                Image = Excel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Send the data in the page to an Excel file for analysis or editing';

                trigger OnAction()
                var
                    EditinExcel: Codeunit "Edit in Excel";
                begin
                    EditinExcel.EditPageInExcel(
                        'Bank Charges',
                        Page::"Bank Charge Deemed Value Setup");
                end;
            }
        }
    }
}
