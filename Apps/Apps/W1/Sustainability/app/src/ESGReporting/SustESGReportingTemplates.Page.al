// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

page 6253 "Sust. ESG Reporting Templates"
{
    ApplicationArea = Basic, Suite;
    Caption = 'ESG Reporting Templates';
    PageType = List;
    SourceTable = "Sust. ESG Reporting Template";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the ESG reporting template you are about to create.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the ESG reporting template.';
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
        area(navigation)
        {
            group("Template")
            {
                Caption = 'Template';
                Image = Template;
                action("ESG Reporting Names")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'ESG Reporting Names';
                    Image = List;
                    RunObject = Page "Sust. ESG Reporting Names";
                    RunPageLink = "ESG Reporting Template Name" = field(Name);
                    ToolTip = 'Executes the ESG Reporting Names action.';
                }
            }
        }
    }
}