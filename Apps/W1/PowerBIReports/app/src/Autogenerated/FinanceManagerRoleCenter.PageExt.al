namespace Microsoft.PowerBIReports;

using Microsoft.Finance.RoleCenters;

pageextension 36959 "Finance Manager Role Center" extends "Finance Manager Role Center"
{
    actions
    {
        addfirst(Sections)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = AnalysisView;
                ToolTip = 'Power BI reports for finance';
                action("Financial Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Financial Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Financial Overview";
                }
                action("Income Statement by Month (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Income Statement by Month (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Income Statement by Month";
                }
                action("Balance Sheet by Month (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Balance Sheet by Month (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Balance Sheet by Month";
                }
                action("Budget Comparison (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Budget Comparison (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Budget Comparison";
                }
                action("Liquidity KPIs (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Liquidity KPIs (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Liquidity KPIs";
                }
                action("Profitability (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Profitability (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Profitability";
                }
                action("Liabilities (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Liabilities (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Liabilities";
                }
                action("EBITDA (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'EBITDA (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "EBITDA";
                }
                action("Average Collection Period (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Average Collection Period (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Average Collection Period";
                }
                action("Aged Receivables (Back Dating) (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Aged Receivables (Back Dating) (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Aged Receivables (Back Dating)";
                }
                action("Aged Payables (Back Dating) (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Aged Payables (Back Dating) (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Aged Payables (Back Dating)";
                }
                action("General Ledger Entries (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Ledger Entries (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "General Ledger Entries";
                }
                action("Detailed Vendor Ledger Entries (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Detailed Vendor Ledger Entries (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Detailed Vendor Ledger Entries";
                }
                action("Detailed Cust. Ledger Entries (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Detailed Cust. Ledger Entries (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Detailed Cust. Ledger Entries";
                }
                action("Inventory Valuation Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Valuation Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory Valuation Overview";
                }
                action("Inventory Valuation by Item (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Valuation by Item (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory Valuation by Item";
                }
                action("Inventory Valuation by Loc. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Valuation by Loc. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory Valuation by Loc.";
                }
            }
        }
    }
}

