// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using System.Reflection;

page 31271 "Compens. Report Selections CZC"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Report Selection - Compensation';
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Compens. Report Selections CZC";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(ReportUsage2; ReportUsage2)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Usage';
                ToolTip = 'Specifies type of compensation document.';

                trigger OnValidate()
                begin
                    SetUsageFilter();
                    CurrPage.Update();
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies sequence of compensation document.';
                }
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the ID of the report that the program will print.';
                }
                field("Report Caption"; Rec."Report Caption")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies caption of report';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }


    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.NewRecord();
    end;

    trigger OnOpenPage()
    begin
        SetUsageFilter();
    end;

    var
        ReportUsage2: Enum "Compens. Report Sel. Usage CZC";

    local procedure SetUsageFilter()
    begin
        Rec.FilterGroup(2);
        case ReportUsage2 of
            ReportUsage2::"Compensation":
                Rec.SetRange(Usage, Rec.Usage::"Compensation");
            ReportUsage2::"Posted Compensation":
                Rec.SetRange(Usage, Rec.Usage::"Posted Compensation");
        end;
        Rec.FilterGroup(0);
    end;
}
