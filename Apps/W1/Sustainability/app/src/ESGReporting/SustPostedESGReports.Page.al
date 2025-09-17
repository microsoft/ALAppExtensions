// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Sustainability.Reports;

page 6256 "Sust. Posted ESG Reports"
{
    Caption = 'Posted ESG Reports';
    Editable = false;
    PageType = List;
    UsageCategory = History;
    ApplicationArea = Basic, Suite;
    SourceTableView = order(descending);
    CardPageId = "Sust. Posted ESG Report";
    SourceTable = "Sust. Posted ESG Report Header";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
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
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Country/Region Code of the ESG reporting name.';
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
    actions
    {
        area(Reporting)
        {
            action("CSRD Preparation Report")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'CSRD Preparation Report';
                Image = "Report";
                RunObject = Report "Sust. CSRD Preparation";
                ToolTip = 'Executes the CSRD Preparation Report action.';
            }
        }
    }
}