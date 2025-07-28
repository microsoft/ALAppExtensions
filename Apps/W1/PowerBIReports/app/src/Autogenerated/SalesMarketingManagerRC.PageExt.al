namespace Microsoft.PowerBIReports;

using Microsoft.CRM.RoleCenters;

pageextension 36960 "Sales & Marketing Manager RC" extends "Sales & Marketing Manager RC"
{
    actions
    {
        addfirst(Sections)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = AnalysisView;
                ToolTip = 'Power BI reports for sales';
                action("Sales Report (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Report (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Report";
                    Tooltip = 'Open a Power BI Report that offers a consolidated view of all sales report pages, conveniently embedded into a single page for easy access.';
                }
                action("Sales Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Overview";
                    Tooltip = 'Open a Power BI Report that provides a comprehensive view of sales performance, offering insights into metrics such as Total Sales, Gross Profit Margin, Number of New Customers, and top-performing customers and salespeople.';
                }
                action("Daily Sales (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Daily Sales (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Daily Sales";
                    Tooltip = 'Open a Power BI Report that offers a detailed analysis of sales amounts by weekday. The tabular report highlights trends by using conditional formatting to display figures in a gradient from low to high.';
                }
                action("Sales Moving Average (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Moving Average (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Moving Average";
                    Tooltip = 'Open a Power BI Report that visualizes the 30-day moving average of sales amounts over time. This helps identify trends by smoothing out fluctuations and highlighting overall patterns.';
                }
                action("Sales Moving Annual Total (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Moving Annual Total (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Moving Annual Total";
                    Tooltip = 'Open a Power BI Report that provides a rolling 12-month view of sales figures, tracking the current year to the previous year''s performance. ';
                }
                action("Sales Period-Over-Period (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Period-Over-Period (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Period-Over-Period";
                    Tooltip = 'Open a Power BI Report that compares sales performance across different periods, such as month-over-month or year-over-year.';
                }
                action("Sales Month-To-Date (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Month-To-Date (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Month-To-Date";
                    Tooltip = 'Open a Power BI Report that tracks the accumulation of sales amounts throughout the current month, providing insights into progress and performance up to the present date.';
                }
                action("Sales by Item (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales by Item (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales by Item";
                    Tooltip = 'Open a Power BI Report that breaks down sales performance by item category, highlighting metrics such as Sales Amount, Gross Profit Margin, and Gross Profit as a Percent of the Grand Total. This report provides detailed insights into which categories and items are driving revenue and profitability.';
                }
                action("Sales by Customer (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales by Customer (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales by Customer";
                    Tooltip = 'Open a Power BI Report that breaks down sales performance highlighting key metrics such as Sales Amount, Cost Amount, Gross Profit and Gross Profit Margin by customer. This report provides detailed insights into which customer and items driving revenue and profitability.';
                }
                action("Sales by Salesperson (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales by Salesperson (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales by Salesperson";
                    Tooltip = 'Open a Power BI Report that breaks down salesperson performance by customer and item. Highlighting metrics such as Sales Amount, Sales Quantity, Gross Profit and Gross Profit Margin.';
                }
                action("Sales Actual vs. Budget Qty. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Actual vs. Budget (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Actual vs. Budget Qty.";
                    Tooltip = 'Open a Power BI Report that provides a comparative analysis of sales quantity to budget amounts/quantities. Featuring variance and variance percentage metrics that provide a clear view of actual performance compared to budgeted targets.';
                }
#if not CLEAN26
                action("Sales Actual vs. Budget Amt. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Actual vs. Budget Amt. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Actual vs. Budget Amt.";
                    Tooltip = 'Open a Power BI Report that provides a comparative analysis of sales amounts to budget amount. Featuring variance and variance percentage metrics that provide a clear view of actual performance compared to budgeted targets.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The Power BI report has been changed/removed and this is no longer required.';
                    ObsoleteTag = '26.0';
                    Visible = false;
                }
#endif
                action("Sales Demographics (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Demographics (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Demographics";
                    Tooltip = 'Open the Power BI report that shows sales data segmented by demographic factors including sales metrics by item category, sales by customer posting group, sales by document type and the number of customers by location.';
                }
                action("Sales Decomposition (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Decomposition (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Decomposition";
                    Tooltip = 'Open the Power BI report that breaks down sales figures to understand contributing factors including location names, item categories, and countries and regions.';
                }
                action("Key Sales Influencers (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Key Sales Influencers (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Key Sales Influencers";
                    Tooltip = 'Open the Power BI report that identifies and analyzes the main factors influencing sales performance, highlighting the most impactful variables and trends based on the sales data like items, customers and dimensions.';
                }
                action("Opportunity Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Opportunity Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Opportunity Overview";
                    Tooltip = 'Open the Power BI report that provides a comprehensive view of sales opportunities, including the number of opportunities, estimated values, sales cycle, and a breakdown of potential value by location.';
                }
                action("Sales Quote Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Quote Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Quote Overview";
                    Tooltip = 'Open the Power BI report that provides detailed information on sales quotes, including the number of quotes, total value, profit rates, and sales quote amount over time.';
                }
                action("Return Order Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Return Order Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Return Order Overview";
                    Tooltip = 'Open the Power BI report that tracks and analyzes return orders, providing insights into return amounts, quantities,  reasons for return, and the financial impact on the organization.';
                }
            }
        }
    }
}

