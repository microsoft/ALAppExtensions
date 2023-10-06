// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using System.Integration.Excel;

page 18202 "GST Component Dist. List"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "GST Component Distribution";
    Caption = 'GST Component Dist. List';
    CardPageId = "GST Component Dist. Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies GST component code for input service distribution ledgers.';
                }
                field("Distribution Component Code"; Rec."Distribution Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies distribution component code for input service distribution ledgers.';
                }
                field("Intrastate Distribution"; Rec."Intrastate Distribution")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether intrastate distribution is applicable or not.';
                }
                field("Interstate Distribution"; Rec."Interstate Distribution")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether interstate distribution is applicable or not.';
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
                        'GST Component Distribution',
                        Page::"GST Component Dist. List");
                end;
            }
        }
    }
}
