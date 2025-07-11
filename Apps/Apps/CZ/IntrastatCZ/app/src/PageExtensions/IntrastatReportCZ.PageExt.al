// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 31344 "Intrastat Report CZ" extends "Intrastat Report"
{
    layout
    {
        addlast(General)
        {
            field("Statement Type CZ"; Rec."Statement Type CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the statement type of the Intrastat Report.';

                trigger OnValidate()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }
    actions
    {
        addafter(CreateFile)
        {
            action("Intrastat - Invoice Check CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat - Invoice Checklist';
                Ellipsis = true;
                Image = PrintChecklistReport;
                ToolTip = 'Open the report for intrastat - invoice checklist.';

                trigger OnAction()
                var
                    IntrastatReportLine: Record "Intrastat Report Line";
                begin
                    IntrastatReportLine.SetRange("Intrastat No.", Rec."No.");
                    Report.Run(Report::"Intrastat - Invoice Check CZ", true, false, IntrastatReportLine);
                end;
            }
        }
    }
}