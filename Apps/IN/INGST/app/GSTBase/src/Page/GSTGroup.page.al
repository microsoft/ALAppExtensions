// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using System.Integration.Excel;

page 18001 "GST Group"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "GST Group";
    Caption = 'GST Group';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code which needs to be assigned to identify a GST group, should be one unique code, both number and letters are allowed.';
                }
                field("GST Group Type"; Rec."GST Group Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST group is assigned for goods or service.';
                }
                field("GST Place Of Supply"; Rec."GST Place Of Supply")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Place of Supply. For example Bill-to Address, Ship-to Address, Location Address etc.';
                }
                field("Component Calc. Type"; Rec."Component Calc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of calculation to be considered for the specified GST Group.';
                }
                field("Cess UOM"; Rec."Cess UOM")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure code to be used for the calculation of Cess where calculation depends on amount per unit.';
                }
                field("Cess Credit"; Rec."Cess Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the credit is to be availed or not.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the GST group.';
                }
                field("Reverse Charge"; Rec."Reverse Charge")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the reverse charge is applicable for this GST group or not.';
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
                    EditinExcel.EditPageInExcel('GST Group',
                    Page::"GST Group");
                end;
            }
        }
    }
}
