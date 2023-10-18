// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using System.Integration.Excel;

page 18004 "GST Registration Nos."
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "GST Registration Nos.";
    Caption = 'GST Registration Nos.';
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(code; Rec.code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies GST registration code of locations situated in different states.';
                }
                field("State Code"; Rec."State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies state code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the details of GST registration code.';
                }
                field("Input Service Distributor"; Rec."Input Service Distributor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether Input Service Distributor is applicable or not.';
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
                        'GST Registration Nos.',
                        Page::"GST Registration Nos.");
                end;
            }
        }
    }
}
