
namespace Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Journal;
using System.Telemetry;

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
                field("Waste Unit of Measure Code"; Rec."Waste Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Waste Unit of Measure Code field.';
                }
                field("Water Unit of Measure Code"; Rec."Water Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Water Unit of Measure Code field.';
                }
                field("Disch. Into Water Unit of Meas"; Rec."Disch. Into Water Unit of Meas")
                {
                    ToolTip = 'Specifies the value of the Discharged Into Water Unit of Measure Code field.';
                }
                field("Energy Unit of Measure Code"; Rec."Energy Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Energy Unit of Measure Code field.';
                }
                field("Emission Decimal Places"; Rec."Emission Decimal Places")
                {
                    ToolTip = 'Specifies the number of decimal places that are shown for emission amounts. The default setting, 2:5, specifies that all amounts are shown with a minimum of 2 decimal places and a maximum of 5 decimal places. You can also enter a fixed number, such as 2, which also means that amounts are shown with two decimals.';
                }
                field("Country/Region Mandatory"; Rec."Country/Region Mandatory")
                {
                    ToolTip = 'Specifies if country/region is mandatory.';
                }
                field("Resp. Center Mandatory"; Rec."Resp. Center Mandatory")
                {
                    ToolTip = 'Specifies if responsibility center is mandatory.';
                }
                field("Block Change If Entry Exists"; Rec."Block Change If Entry Exists")
                {
                    ToolTip = 'Specifies if the change of critical setup change is blocked when sustainability entry exists.';
                }
                field("Enable Background Error Check"; Rec."Enable Background Error Check")
                {
                    ToolTip = 'Specifies if the background error check of sustainability journal lines is enabled.';
                }
            }
            group(Procurement)
            {
                Caption = 'Procurement';
                field("Use Emissions In Purch. Doc."; Rec."Use Emissions In Purch. Doc.")
                {
                    ToolTip = 'Specifies that you want to enable sustainability features in purchase documents. Until this field is selected, sustainability fields will not be displayed in the purchase lines. Select this field only if you intend to post your GHG emissions using purchase documents or to post purchasing carbon credits.';
                }
                field("G/L Account Emissions"; Rec."G/L Account Emissions")
                {
                    ToolTip = 'Specifies the enablement of default Sustainability Account on the G/L Account card.';
                }
                field("Item Emissions"; Rec."Item Emissions")
                {
                    ToolTip = 'Specifies the enablement of default Sustainability Account emissions on the Item card.';
                }
                field("Item Charge Emissions"; Rec."Item Charge Emissions")
                {
                    ToolTip = 'Specifies the enablement of default Sustainability Account emissions on the Item Charge (currently not operating).';
                }
                field("Resource Emissions"; Rec."Resource Emissions")
                {
                    ToolTip = 'Specifies the enablement of default Sustainability Account emissions on the Resource card.';
                }
                field("Work/Machine Center Emissions"; Rec."Work/Machine Center Emissions")
                {
                    ToolTip = 'Specifies the enablement of default Sustainability Account emissions on the Work Center and Machine Center cards.';
                }
                field("Enable Value Chain Tracking"; Rec."Enable Value Chain Tracking")
                {
                    ToolTip = 'Specifies the enablement of sustainability value entries postings through value chain operations and the visibility of these fields in operational documents and journals.';
                }
                field("Use All Gases As CO2e"; Rec."Use All Gases As CO2e")
                {
                }
            }
            group(Calculations)
            {
                Caption = 'Calculations';
                field("Fuel/El. Decimal Places"; Rec."Fuel/El. Decimal Places")
                {
                    ToolTip = 'Specifies the number of decimal places that are shown for fuel/electricity amounts. The default setting, 2:5, specifies that all amounts are shown with a minimum of 2 decimal places and a maximum of 5 decimal places. You can also enter a fixed number, such as 2, which also means that amounts are shown with two decimals.';
                }
                field("Distance Decimal Places"; Rec."Distance Decimal Places")
                {
                    ToolTip = 'Specifies the number of decimal places that are shown for distance measurements. The default setting, 2:5, specifies that all amounts are shown with a minimum of 2 decimal places and a maximum of 5 decimal places. You can also enter a fixed number, such as 2, which also means that amounts are shown with two decimals.';
                }
                field("Custom Amt. Decimal Places"; Rec."Custom Amt. Decimal Places")
                {
                    ToolTip = 'Specifies the number of decimal places that are shown for custom amounts. The default setting, 2:5, specifies that all amounts are shown with a minimum of 2 decimal places and a maximum of 5 decimal places. You can also enter a fixed number, such as 2, which also means that amounts are shown with two decimals.';
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
                field("Emission Rounding Precision"; Rec."Emission Rounding Precision")
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
                field("Energy Reporting UOM Code"; Rec."Energy Reporting UOM Code")
                {
                    ToolTip = 'Specifies the unit of measure code that is used to report Energy.';
                }
                field("Energy Reporting UOM Factor"; Rec."Energy Reporting UOM Factor")
                {
                    ToolTip = 'Specifies the unit of measure factor that is used to register Energy.';
                }
                field("Posted ESG Reporting Nos."; Rec."Posted ESG Reporting Nos.")
                {
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
            action(SustainAccountCategory)
            {
                Caption = 'Sustainability Account Categories';
                Image = Category;
                RunObject = Page "Sustain. Account Categories";
                ToolTip = 'View or add sustainability account categories.';
            }
            action(SustainabilityJournalTemplate)
            {
                Caption = 'Sustainability Journal Template';
                Image = Template;
                RunObject = Page "Sustainability Jnl. Templates";
                ToolTip = 'Set up templates for the journals that you use for sustainability reporting tasks. Templates allow you to work in a journal window that is designed for a specific purpose.';
            }
            action(EmissionFees)
            {
                Caption = 'Emission Fees';
                Image = CostBudget;
                RunObject = Page "Emission Fees";
                ToolTip = 'Set up internal carbon fees and CO2 equivalent.';
            }
        }
        area(Promoted)
        {
            actionref(SustainAccountCategory_Promoted; SustainAccountCategory) { }
            actionref(SustainabilityJournalTemplate_Promoted; SustainabilityJournalTemplate) { }
            actionref(EmissionFees_Promoted; EmissionFees) { }
        }
    }
    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SustainabilityLbl: Label 'Sustainability', Locked = true;
    begin
        FeatureTelemetry.LogUptake('0000PH2', SustainabilityLbl, Enum::"Feature Uptake Status"::Discovered);
        Rec.InitRecord();

        xSustainabilitySetup := Rec;
    end;

    trigger OnClosePage()
    var
        SessionSettings: SessionSettings;
    begin
        if IsUnitOfMeasureModified() then
            SessionSettings.RequestSessionUpdate(false);
    end;

    var
        xSustainabilitySetup: Record "Sustainability Setup";

    local procedure IsUnitOfMeasureModified(): Boolean
    begin
        exit(
          (Rec."Emission Unit of Measure Code" <> xSustainabilitySetup."Emission Unit of Measure Code") or
          (Rec."Energy Unit of Measure Code" <> xSustainabilitySetup."Energy Unit of Measure Code") or
          (Rec."Use All Gases As CO2e" <> xSustainabilitySetup."Use All Gases As CO2e"));
    end;
}