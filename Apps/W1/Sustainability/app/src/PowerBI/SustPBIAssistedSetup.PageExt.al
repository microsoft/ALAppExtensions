namespace Microsoft.Sustainability.PowerBIReports;
using Microsoft.PowerBIReports;

pageextension 6264 "Sust. PBI Assisted Setup" extends "PowerBI Assisted Setup"
{
    layout
    {
        addlast(Step5)
        {
#if not CLEAN27
#pragma warning disable AL0801
#endif

            group(SustainabilityReportSetup)
            {
                Caption = 'Sustainability';
                InstructionalText = 'Configure the Power BI Sustainability App.';

                field("Sustainability Report Name"; Format(Rec."Sustainability Report Name"))
                {
                    ApplicationArea = All;
                    Caption = 'Power BI Sustainability Report';
                    ToolTip = 'Specifies the Power BI Sustainability Report.';

                    trigger OnAssistEdit()
                    var
                        SetupHelper: Codeunit "Power BI Report Setup";
                    begin
                        SetupHelper.EnsureUserAcceptedPowerBITerms();
                        SetupHelper.LookupPowerBIReport(Rec."Sustainability Report ID", Rec."Sustainability Report Name");
                    end;
                }
                group(SustShowMoreGroup)
                {
                    ShowCaption = false;
                    Visible = not SustainabilityTabVisible;
                    field(SustShowMore; ShowMoreTxt)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        trigger OnDrillDown()
                        begin
                            SustainabilityTabVisible := not SustainabilityTabVisible;
                        end;
                    }
                }
                group(SustFastTab)
                {
                    ShowCaption = false;
                    Visible = SustainabilityTabVisible;
                    group(SustDataFiltering)
                    {
                        ShowCaption = false;
                        InstructionalText = 'Configure the volume of data that is sent to your Power BI semantic models (optional).';

                        field("Sustainability Load Date Type"; Rec."Sustainability Load Date Type")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the date type for Sustainability report filter.';
                        }
                        group(SustRepStartEndDateFilters)
                        {
                            ShowCaption = false;
                            Visible = Rec."Sustainability Load Date Type" = Rec."Sustainability Load Date Type"::"Start/End Date";

                            field("Sustainability Start Date"; Rec."Sustainability Start Date")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the start date for Sustainability report filter.';
                            }
                            field("Sustainability End Date"; Rec."Sustainability End Date")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the end date for Sustainability report filter.';
                            }
                        }
                        group(SustRepRelativeDateFilter)
                        {
                            ShowCaption = false;
                            Visible = Rec."Sustainability Load Date Type" = Rec."Sustainability Load Date Type"::"Relative Date";

                            field("Sustainability Date Formula"; Rec."Sustainability Date Formula")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the date formula for Sustainability report filter.';
                            }
                        }
                    }
                    field(SustShowLess; ShowLessTxt)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            SustainabilityTabVisible := not SustainabilityTabVisible;
                        end;
                    }
                }
            }
#if not CLEAN27
#pragma warning restore AL0801
#endif
        }
    }

    var
        SustainabilityTabVisible: Boolean;
        ShowMoreTxt: Label 'Show More';
        ShowLessTxt: Label 'Show Less';
}