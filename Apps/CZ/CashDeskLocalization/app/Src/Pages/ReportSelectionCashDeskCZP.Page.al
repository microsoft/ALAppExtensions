// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Reflection;

page 31169 "Report Selection Cash Desk CZP"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Report Selection - Cash Desk';
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Cash Desk Rep. Selections CZP";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(ReportUsage2; ReportUsage2)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Usage';
                ToolTip = 'Specifies type of cash document.';

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
                    ToolTip = 'Specifies sequence of cash document.';
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
        ReportUsage2: Enum "Cash Desk Rep. Sel. Usage CZP";

    local procedure SetUsageFilter()
    begin
        Rec.FilterGroup(2);
        case ReportUsage2 of
            ReportUsage2::"Cash Receipt":
                Rec.SetRange(Usage, Rec.Usage::"Cash Receipt");
            ReportUsage2::"Cash Withdrawal":
                Rec.SetRange(Usage, Rec.Usage::"Cash Withdrawal");
            ReportUsage2::"Posted Cash Receipt":
                Rec.SetRange(Usage, Rec.Usage::"Posted Cash Receipt");
            ReportUsage2::"Posted Cash Withdrawal":
                Rec.SetRange(Usage, Rec.Usage::"Posted Cash Withdrawal");
        end;
        Rec.FilterGroup(0);
    end;
}
