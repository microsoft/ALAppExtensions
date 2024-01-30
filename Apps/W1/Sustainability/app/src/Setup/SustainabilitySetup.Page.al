namespace Microsoft.Sustainability.Setup;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;

page 6221 "Sustainability Setup"
{
    AdditionalSearchTerms = 'Emission Setup';
    ApplicationArea = Basic, Suite;
    Caption = 'Sustainability Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Sustainability Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Emission Unit of Measure Code"; Rec."Emission Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure code that is used to register emission.';
                }
                field("Emission Decimal Places"; Rec."Emission Decimal Places")
                {
                    ToolTip = 'Specifies the number of decimal places that are shown for emission amounts. The default setting, 2:2, specifies that all amounts are shown with a minimum of 2 decimal places and a maximum of 2 decimal places. You can also enter a fixed number, such as 2, which also means that amounts are shown with two decimals.';
                }
                field("Country/Region Mandatory"; Rec."Country/Region Mandatory")
                {
                    ToolTip = 'Specifies if country/region is mandatory.';
                }
                field("Resp. Center Mandatory"; Rec."Resp. Center Mandatory")
                {
                    ToolTip = 'Specifies if responsibility center is mandatory.';
                }
            }
            group(Calculations)
            {
                Caption = 'Calculations';
                field("Fuel/El. Decimal Places"; Rec."Fuel/El. Decimal Places")
                {
                    ToolTip = 'Specifies the number of decimal places that are shown for fuel/elictricity amounts. The default setting, 2:2, specifies that all amounts are shown with a minimum of 2 decimal places and a maximum of 2 decimal places. You can also enter a fixed number, such as 2, which also means that amounts are shown with two decimals.';
                }
                field("Distance Decimal Places"; Rec."Distance Decimal Places")
                {
                    ToolTip = 'Specifies the number of decimal places that are shown for distance amounts. The default setting, 2:2, specifies that all amounts are shown with a minimum of 2 decimal places and a maximum of 2 decimal places. You can also enter a fixed number, such as 2, which also means that amounts are shown with two decimals.';
                }
                field("Custom Amt. Decimal Places"; Rec."Custom Amt. Decimal Places")
                {
                    ToolTip = 'Specifies the number of decimal places that are shown for custom amounts. The default setting, 2:2, specifies that all amounts are shown with a minimum of 2 decimal places and a maximum of 2 decimal places. You can also enter a fixed number, such as 2, which also means that amounts are shown with two decimals.';
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Emission Reporting UOM Code"; Rec."Emission Reporting UOM Code")
                {
                    ToolTip = 'Specifies the unit of measure code that is used to report emission.';
                }
                field("Reporting UOM Factor"; Rec."Reporting UOM Factor")
                {
                    ToolTip = 'Specifies the unit of measure factor that is used to register emission.';
                }
                field("Emission Rounding Precission"; Rec."Emission Rounding Precission")
                {
                    ToolTip = 'Specifies the size of the interval to be used when rounding emission amounts.';
                }
                field("Emission Rounding Type"; Rec."Emission Rounding Type")
                {
                    ToolTip = 'Specifies how the program will round emission amount.';
                }
                field("CSRD Reporting Link"; Rec."CSRD Reporting Link")
                {
                    ToolTip = 'Specifies the Corporate Sustainability Reporting Directive link to report emission.';
                    Visible = false;
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
            group("CalculationsGr")
            {
                Caption = 'Calculations';
                action(SustainAccountCategory)
                {
                    Caption = 'Sustainability Account Categories';
                    Image = Category;
                    RunObject = Page "Sustain. Account Categories";
                    ToolTip = 'View or add sustainability account categories.';
                }
            }
            group("Sustainability Journal Templates")
            {
                Caption = 'Journal Templates';
                action(SustainabilityJournalTemplate)
                {
                    Caption = 'Sustainability Journal Template';
                    Image = Template;
                    RunObject = Page "Sustainability Jnl. Templates";
                    ToolTip = 'Set up templates for the journals that you use for sustainability reporting tasks. Templates allow you to work in a journal window that is designed for a specific purpose.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = 'Calculations';
                actionref(SustainAccountCategory_Promoted; SustainAccountCategory) { }
            }
            group(Category_Category5)
            {
                Caption = 'Journal Templates';
                actionref(SustainabilityJournalTemplate_Promoted; SustainabilityJournalTemplate) { }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}