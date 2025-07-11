// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

page 6256 "Sust. Posted ESG Reports"
{
    Caption = 'Posted ESG Reports';
    Editable = false;
    PageType = List;
    UsageCategory = History;
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
                field("Standard Type"; Rec."Standard Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Standard Type of the ESG reporting name.';
                }
                field(Period; Rec.Period)
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
}