namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.PowerBIReports;

pageextension 6261 "Sust. PBI Reports Setup" extends "PowerBI Reports Setup"
{
    layout
    {
        addbefore(Dimensions)
        {
#if not CLEAN27
#pragma warning disable AL0801
#endif
            group(SustainabilityReport)
            {
                Caption = 'Sustainability Report';
                group(SustainabilityGeneral)
                {
                    ShowCaption = false;
                    field("Sustainability Report Name"; Format(Rec."Sustainability Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Sustainability App';
                        ToolTip = 'Specifies where you have installed the Power BI Sustainability App.';

                        trigger OnAssistEdit()
                        var
                            SetupHelper: Codeunit "Power BI Report Setup";
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Sustainability Report ID", Rec."Sustainability Report Name");
                        end;
                    }
                }
                field("Sustainability Load Date Type"; Rec."Sustainability Load Date Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date filtering type for Sustainability report filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI). Choose Start/End Date to define an interval for which to load data. Chose Relative Date to load data based on a date formula, e.g. last 6 months.';
                }
                group("Sustainability Start End Date Filters")
                {
                    ShowCaption = false;
                    Visible = Rec."Sustainability Load Date Type" = Rec."Sustainability Load Date Type"::"Start/End Date";

                    field("Sustainability Start Date"; Rec."Sustainability Start Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the start date for Sustainability report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                    }
                    field("Sustainability End Date"; Rec."Sustainability End Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the end date for Sustainability report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                    }
                }
                group("Sustainability Relative Date Filter")
                {
                    ShowCaption = false;
                    Visible = Rec."Sustainability Load Date Type" = Rec."Sustainability Load Date Type"::"Relative Date";

                    field("Sustainability Date Formula"; Rec."Sustainability Date Formula")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the date formula for Sustainability report filter. Set this if you have specified Relative Date as the Load Date Type.';
                    }
                }
            }
#if not CLEAN27
#pragma warning restore AL0801
#endif
        }
    }
}