// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Sustainability.Reports;

page 6257 "Sust. Posted ESG Report"
{
    Caption = 'Posted ESG Report';
    InsertAllowed = false;
    Editable = false;
    PageType = Document;
    SourceTable = "Sust. Posted ESG Report Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a no. of the ESG reporting name.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ESG reporting name.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the ESG reporting name.';
                }
                field("Standard"; Rec."Standard")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Standard of the ESG reporting name.';
                }
                field("Period Name"; Rec."Period Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a period of the ESG reporting name.';
                }
                field("Period Starting Date"; Rec."Period Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a period starting date of the ESG reporting name.';
                }
                field("Period Ending Date"; Rec."Period Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a period ending date of the ESG reporting name.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Country/Region Code of the ESG reporting name.';
                }
            }
            part(PostedESGReportLines; "Sust. Posted ESG Report Sub.")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No." = field("No.");
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
    actions
    {
        area(Reporting)
        {
            action("CSRD Preparation Report")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'CSRD Preparation Report';
                Image = "Report";
                ToolTip = 'Executes the CSRD Preparation Report action.';

                trigger OnAction()
                var
                    PostedESGReportHeader: Record "Sust. Posted ESG Report Header";
                begin
                    PostedESGReportHeader.SetRange("No.", Rec."No.");

                    Report.RunModal(Report::"Sust. CSRD Preparation", true, false, PostedESGReportHeader);
                end;
            }
        }
    }
}