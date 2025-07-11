namespace Microsoft.PowerBIReports;

using Microsoft.Sustainability.RoleCenters;

pageextension 36966 "Sustainability Manager RC" extends "Sustainability Manager RC"
{
    actions
    {
        addlast(Reporting)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = PowerBI;
                ToolTip = 'Power BI reports for sustainability';
                action("Sustainability Report (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sustainability Report (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sustainability Report";
                    Tooltip = 'Open the Power BI Report page which offers a consolidated view of all Sustainability Reports.';
                }
                action("Sustainability Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sustainability Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sustainability Overview";
                    Tooltip = 'Open the Power BI Report page Sustainability Overview which shows a high level of sustainability information.';
                }
                action("Realized Emissions vs Target (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized Emissions vs. Target (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Realized Emissions vs Target";
                    Tooltip = 'Open the Power BI Report page Realized Emissions vs. Target which highlights an organization''''s emissions and compares them against the predefined targets.';
                }
                action("Realized Emissions vs Baseline (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Realized Emissions vs. Baseline (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Realized Emissions vs Baseline";
                    Tooltip = 'Open the Power BI Report page Realized Emissions vs. Bassline which showcases the differences between an organization''''s emissions and the baseline they have set.';
                }
                action("Water and Waste Analysis (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Water and Waste Analysis (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Water and Waste Analysis";
                    Tooltip = 'Open the Power BI Report page Water and Waste analysis where you can view all key information on water discharged, types and waste information.';
                }
                action("Emissions by Category and Scope (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Emissions by Category and Scope (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Emissions by Cat and Scope";
                    Tooltip = 'Open the Power BI Report page Emissions by Category and Scope to see a breakdown of your emissions.';
                }
                action("CO2e Analysis (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CO2e Analysis (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "CO2e Analysis";
                    Tooltip = 'Open the Power BI Report page CO2e Analysis to view key information on your CO2e usage.';
                }
                action("Journey to Net Zero Carbon (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Journey to Net Zero Carbon (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Journey to Net Zero Carbon";
                    Tooltip = 'Open the Power BI Report page Journey to Net Zero to view the direction towards net zero for the organization.';
                }
                action("Social Analysis (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Social Analysis (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Social Analysis";
                    Tooltip = 'Open the Power BI Report page Social Analysis to view the information on the employees of the organization.';
                }
                action("CO2e Key Influences (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CO2e Key Influences (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "CO2e Key Influences";
                    Tooltip = 'Open the Power BI Report page CO2e Key Influences to identify the key factors driving CO2e emission increases, highlighting the most impactful variables and trends based on the sustainability account categories.';
                }
                action("CO2e Decomposition Tree (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CO2e Decomposition Tree (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "CO2e Decomposition Tree";
                    Tooltip = 'Open the Power BI Report page CO2e Decomposition Tree report breaks down CO2e emission metrics into its key contributing components to help users understand what is driving changes in CO2 emissions and why.';
                }
            }
        }
    }
}

