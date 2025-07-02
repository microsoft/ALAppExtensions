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
                action("Purchases Report (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Report (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Report";
                    Tooltip = 'Open a Power BI Report that offers a consolidated view of all purchases report pages, conveniently embedded into a single page for easy access.';
                }
                action("Purchases Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Overview";
                    Tooltip = 'Open a Power BI Report that provides high level insights into procurement performance, highlighting metrics such as Outstanding Quantities, Quantity Received not Invoiced and Invoice Quantity. ';
                }
                action("Purchases Decomposition (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Decomposition (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Decomposition";
                    Tooltip = 'Open a Power BI Report that visually breaks down Purchase Amount into its contributing factors, allowing users to explore and analyze data hierarchies in detail.';
                }
                action("Daily Purchases (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Daily Purchases (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Daily Purchases";
                    Tooltip = 'Open a Power BI Report that offers a detailed analysis of purchase amounts by weekday. The tabular report highlights purchasing trends by using conditional formatting to display purchase figures in a gradient from low to high.';
                }
                action("Purchases Moving Averages (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Moving Averages (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Moving Averages";
                    Tooltip = 'Open a Power BI Report that visualizes the 30-day moving average of purchase amounts over time. This helps identify trends by smoothing out fluctuations and highlighting overall patterns.';
                }
                action("Purchases Moving Annual Total (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Moving Annual Total (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Moving Annual Total";
                    Tooltip = 'Open a Power BI Report that provides a rolling 12-month view of procurement figures, tracking current year to the previous year''s performance. ';
                }
                action("Purchases Period-Over-Period (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Period-Over-Period (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Period-Over-Period";
                    Tooltip = 'Open a Power BI Report that compares procurement performance across different periods, such as month-over-month or year-over-year. Completed up to here';
                }
                action("Purchases Year-Over-Year (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Year-Over-Year (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases Year-Over-Year";
                    Tooltip = 'Open a Power BI Report that compares purchase amounts across multiple years. This report is essential for long-term planning and making informed decisions based on historical purchasing data.';
                }
                action("Purchases by Item (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Item (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases by Item";
                    Tooltip = 'Open a Power BI Report that breaks down procurement performance by item, highlighting metrics such as Purchase Amount, Purchase Quantity. The Treemap visualizes the relative size and contribution of each item to the whole, making it easy to identify the largest or smallest purchases at a glance.';
                }
                action("Purchases by Purchaser (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Purchaser (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases by Purchaser";
                    Tooltip = 'Open a Power BI Report that breaks down purchase amounts by individual purchasers, using a Treemap to visually compare spending contributions by item. A bar chart complements this, displaying purchase amounts for each purchaser. Making it easy to identify top spenders and track procurement patterns.';
                }
                action("Purchases by Vendor (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Vendor (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases by Vendor";
                    Tooltip = 'Open a Power BI Report that shows purchase amounts and quantities by vendor. Featuring a Treemap for item spending contributions and a bar chart for purchase amounts by item category, offering a clear view of vendor performance and spending patterns.';
                }
                action("Purchases by Location (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Location (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchases by Location";
                    Tooltip = 'Open a Power BI Report that displays purchase amounts and quantities by location. Including a Treemap to highlight item spending contributions and a bar chart to show purchase amounts by item category.';
                }
                action("Purch. Actual vs. Budget Qty. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Actual vs. Budget Qty. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purch. Actual vs. Budget Qty.";
                    Tooltip = 'Open a Power BI Report that offers a comparative analysis of purchase quantities against budgeted quantities. It includes variance and variance percentage metrics to clearly show how actual purchases align with budgeted targets.';
                }
                action("Purch. Actual vs. Budget Amt. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Actual vs. Budget Amt. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purch. Actual vs. Budget Amt.";
                    Tooltip = 'Open a Power BI Report that offers a comparative analysis of purchase amounts against budgeted amounts. It includes variance and variance percentage metrics to clearly show how actual purchases align with budgeted targets.';
                }
            }
        }
    }
}

