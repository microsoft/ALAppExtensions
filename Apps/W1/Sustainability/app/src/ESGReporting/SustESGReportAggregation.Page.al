// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

page 6252 "Sust. ESG Report. Aggregation"
{
    ApplicationArea = Basic, Suite;
    AutoSplitKey = true;
    Caption = 'ESG Reporting Aggregation';
    MultipleNewLines = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Sust. ESG Reporting Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrentStmtName; CurrentESGReportingName)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Name';
                Lookup = true;
                ToolTip = 'Specifies the name of the ESG reporting.';
                trigger OnLookup(var Text: Text): Boolean
                begin
                    exit(ESGReportingManagement.LookupName(Rec.GetRangeMax("ESG Reporting Template Name"), CurrentESGReportingName, Text));
                end;

                trigger OnValidate()
                begin
                    ESGReportingManagement.CheckName(CurrentESGReportingName, Rec);
                    CurrentESGReportingNameOnAfterValidate();
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field(Grouping; Rec.Grouping)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Grouping field.';
                }
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a number that identifies the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the ESG reporting line.';
                }
                field("Reporting Code"; Rec."Reporting Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Reporting Code field.';
                }
                field("Field Type"; Rec."Field Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Field Type field.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Field Type" = Rec."Field Type"::"Table Field";
                    ToolTip = 'Specifies the value of the Table No. field.';
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Source field.';
                }

                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Field Type" = Rec."Field Type"::"Table Field";
                    ToolTip = 'Specifies the value of the Field No. field.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Value field.';
                }
                field("Value Settings"; Rec."Value Settings")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Value Settings field.';
                }
                field("Account Filter"; Rec."Account Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Account Filter field.';
                }
                field("Reporting Unit"; Rec."Reporting Unit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Reporting Unit field.';
                }
                field("Row Type"; Rec."Row Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Row Type field.';
                }
                field("Row Totaling"; Rec."Row Totaling")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Row Totaling field.';
                }
                field("Calculate with"; Rec."Calculate With")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Calculate with field.';
                }
                field(Show; Rec.Show)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Show field.';
                }
                field("Show with"; Rec."Show With")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Show with field.';
                }
                field(Rounding; Rec.Rounding)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Rounding field.';
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
            group("ESG Reporting")
            {
                Caption = 'ESG Reporting';
                Image = Suggest;
                action("Preview")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview';
                    Image = View;
                    RunObject = Page "Sust. ESG Reporting Preview";
                    RunPageLink = "ESG Reporting Template Name" = field("ESG Reporting Template Name"),
                                  Name = field("ESG Reporting Name");
                    ToolTip = 'Preview the ESG reporting.';
                }
            }
        }
        area(processing)
        {
            group("Functions")
            {
                Caption = 'Functions';
                Image = "Action";
                action("Calc. and Post ESG Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Calculate and Post ESG Report';
                    Ellipsis = true;
                    Image = SettleOpenTransactions;
                    ToolTip = 'Executes the Calculate and Post ESG Report action.';
                    trigger OnAction()
                    begin
                        PostDocument();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Calc. and Post ESG Report_Promoted"; "Calc. and Post ESG Report")
                {
                }
                actionref("Preview_Promoted"; "Preview")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ESGReportingSelected: Boolean;
    begin
        OpenedFromBatch := (Rec."ESG Reporting Name" <> '') and (Rec."ESG Reporting Template Name" = '');
        if OpenedFromBatch then begin
            CurrentESGReportingName := Rec."ESG Reporting Name";
            ESGReportingManagement.OpenESGReporting(CurrentESGReportingName, Rec);
            exit;
        end;

        ESGReportingManagement.TemplateSelection(Page::"Sust. ESG Report. Aggregation", Rec, ESGReportingSelected);
        if not ESGReportingSelected then
            Error('');

        ESGReportingManagement.OpenESGReporting(CurrentESGReportingName, Rec);
    end;

    var
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        CurrentESGReportingName: Code[10];
        OpenedFromBatch: Boolean;

    local procedure CurrentESGReportingNameOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        ESGReportingManagement.SetName(CurrentESGReportingName, Rec);
        CurrPage.Update(false);
    end;

    local procedure PostDocument()
    var
        ESGReportingPostMgt: Codeunit "Sust. ESG Reporting Post. Mgt";
    begin
        ESGReportingPostMgt.PostESGReport(Rec);
    end;
}