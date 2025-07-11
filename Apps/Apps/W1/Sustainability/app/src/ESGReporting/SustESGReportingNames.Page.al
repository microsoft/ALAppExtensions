// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

page 6251 "Sust. ESG Reporting Names"
{
    Caption = 'ESG Reporting Names';
    DataCaptionExpression = DataCaption();
    PageType = List;
    SourceTable = "Sust. ESG Reporting Name";

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
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Posted of the ESG reporting name.';
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
        area(processing)
        {
            action("Edit ESG Reporting")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit ESG Reporting';
                Image = SetupList;
                ToolTip = 'View or edit how to calculate your ESG reporting amount for a period.';

                trigger OnAction()
                begin
                    ESGReportingManagement.TemplateSelectionFromBatch(Rec);
                end;
            }
            action("Print")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                begin
                    ESGReportingManagement.PrintESGReportingName(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Edit ESG Reporting_Promoted"; "Edit ESG Reporting")
                {
                }
                actionref("Print_Promoted"; "Print")
                {
                }
            }
        }
    }

    trigger OnInit()
    begin
        Rec.SetRange("ESG Reporting Template Name");
    end;

    trigger OnOpenPage()
    begin
        ESGReportingManagement.OpenESGReportingBatch(Rec);
    end;

    var
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";

    local procedure DataCaption(): Text[250]
    var
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
    begin
        if not CurrPage.LookupMode then
            if Rec.GetFilter("ESG Reporting Template Name") <> '' then begin
                ESGReportingTemplate.SetFilter(Name, Rec.GetFilter("ESG Reporting Template Name"));
                if ESGReportingTemplate.FindSet() then
                    if ESGReportingTemplate.Next() = 0 then
                        exit(ESGReportingTemplate.Name + ' ' + ESGReportingTemplate.Description);
            end;
    end;
}