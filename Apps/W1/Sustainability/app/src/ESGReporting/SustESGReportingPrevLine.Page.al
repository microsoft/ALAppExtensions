// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

page 6255 "Sust. ESG Reporting Prev. Line"
{
    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Sust. ESG Reporting Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Grouping; Rec.Grouping)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a Grouping of the ESG reporting line.';
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
                    ToolTip = 'Specifies a reporting code of the ESG reporting line.';
                }
                field("Field Type"; Rec."Field Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies what the ESG reporting line will include.';
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Source field.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = Basic, Suite;
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
                field(ColumnValue; ColumnValue)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    BlankZero = true;
                    Caption = 'Column Amount';
                    DrillDown = true;
                    ToolTip = 'Specifies the type of entries that will be included in the amounts in columns.';

                    trigger OnDrillDown()
                    begin
                        case Rec."Field Type" of
                            Rec."Field Type"::"Table Field":
                                ESGReportingHelperMgt.DrillDown(Rec);
                            Rec."Field Type"::Formula,
                            Rec."Field Type"::Text,
                            Rec."Field Type"::Title:
                                Error(DrillDownIsNotPossibleErr, Rec.FieldCaption("Field Type"), Rec."Field Type");
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcColumnValue(Rec, ColumnValue, 0);
        if Rec."Show With" = Rec."Show With"::"Opposite Sign" then
            ColumnValue := -ColumnValue;
    end;

    var
        DrillDownIsNotPossibleErr: Label 'Drilldown is not possible when %1 is %2.', Comment = '%1 = Field Caption , %2 = Field Value';

    protected var
        ESGReportingHelperMgt: Codeunit "Sust. ESG Reporting Helper Mgt";
        ColumnValue: Decimal;

    local procedure CalcColumnValue(ESGReportingLine: Record "Sust. ESG Reporting Line"; var ColumnValue: Decimal; Level: Integer)
    begin
        ESGReportingHelperMgt.CalcLineTotal(ESGReportingLine, ColumnValue, Level);
    end;

    procedure UpdateSubPage(var ESGReportingName: Record "Sust. ESG Reporting Name"; NewCountryRegionFilter: Text)
    begin
        Rec.SetRange("ESG Reporting Template Name", ESGReportingName."ESG Reporting Template Name");
        Rec.SetRange("ESG Reporting Name", ESGReportingName.Name);
        Rec.SetRange(Show, true);
        ESGReportingName.CopyFilter("Date Filter", Rec."Date Filter");

        ESGReportingHelperMgt.InitializeRequest(ESGReportingName, Rec, NewCountryRegionFilter);
        CurrPage.Update();
    end;
}