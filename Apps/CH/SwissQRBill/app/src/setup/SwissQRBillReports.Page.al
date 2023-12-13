// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Foundation.Reporting;
using Microsoft.Sales.Reminder;
using Microsoft.Sales.Setup;
using Microsoft.Service.Setup;

page 11517 "Swiss QR-Bill Reports"
{
    Caption = 'QR-Bill Report Setup';
    PageType = List;
    SourceTable = "Swiss QR-Bill Reports";
    SourceTableTemporary = true;
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Report Type"; "Report Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document.';

                    trigger OnDrillDown()
                    begin
                        DrillDownReportSelection();
                    end;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the QR-Bill is enabled for the document.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        InitBuffer();
        FindFirst();
    end;

    local procedure DrillDownReportSelection()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange(Usage, MapReportTypeToReportUsage());
        case "Report Type" of
            "Report Type"::"Posted Sales Invoice":
                Page.RunModal(Page::"Report Selection - Sales", ReportSelections);
            "Report Type"::"Posted Service Invoice":
                Page.RunModal(Page::"Report Selection - Service", ReportSelections);
            "Report Type"::"Issued Reminder",
            "Report Type"::"Issued Finance Charge Memo":
                Page.RunModal(Page::"Report Selection - Reminder", ReportSelections);
        end;
    end;
}
