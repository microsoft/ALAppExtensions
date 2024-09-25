namespace Microsoft.PowerBIReports;

using Microsoft.Purchases.RoleCenters;

pageextension 36961 "Purchasing Manager Role Center" extends "Purchasing Manager Role Center"
{
    actions
    {
        addfirst(Sections)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = AnalysisView;
                ToolTip = 'Power BI reports for purchases';
                action("Purchases Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Overview";
                }
                action("Purchases Decomposition (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Decomposition (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Decomposition";
                }
                action("Daily Purchases (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Daily Purchases (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Daily Purchases";
                }
                action("Purchases Moving Averages (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Moving Averages (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Moving Averages";
                }
                action("Purchases Moving Annual Total (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Moving Annual Total (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Moving Annual Total";
                }
                action("Purchases Period-Over-Period (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Period-Over-Period (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Period-Over-Period";
                }
                action("Purchases Year-Over-Year (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Year-Over-Year (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Year-Over-Year";
                }
                action("Purchases by Item (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Item (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases by Item";
                }
                action("Purchases by Purchaser (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Purchaser (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases by Purchaser";
                }
                action("Purchases by Vendor (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Vendor (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases by Vendor";
                }
                action("Purchases by Location (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Location (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases by Location";
                }
                action("Purch. Actual vs. Budget Qty. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Actual vs. Budget Qty. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purch. Actual vs. Budget Qty.";
                }
                action("Purch. Actual vs. Budget Amt. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Actual vs. Budget Amt. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purch. Actual vs. Budget Amt.";
                }
            }
        }
    }
}

