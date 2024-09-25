namespace Microsoft.PowerBIReports;

using Microsoft.Sales.RoleCenters;

pageextension 36954 "Order Processor Role Center" extends "Order Processor Role Center"
{
    actions
    {
        addlast(Reporting)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = PowerBI;
                ToolTip = 'Power BI reports for sales';
                action("Sales Overview")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Overview';
                    Image = "PowerBI";
                    RunObject = page "Sales Overview";
                    Tooltip = 'Open a Power BI Report that provides a comprehensive view of sales performance, offering insights into metrics such as Total Sales, Gross Profit Margin, Number of New Customers, and top-performing customers and salespeople.';
                }
                action("Daily Sales")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Daily Sales';
                    Image = "PowerBI";
                    RunObject = page "Daily Sales";
                    Tooltip = 'Open a Power BI Report that offers a detailed analysis of sales amounts by weekday. The tabular report highlights trends by using conditional formatting to display figures in a gradient from low to high.';
                }
                action("Sales Moving Average")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Moving Average';
                    Image = "PowerBI";
                    RunObject = page "Sales Moving Average";
                    Tooltip = 'Open a Power BI Report that visualizes the 30-day moving average of sales amounts over time. This helps identify trends by smoothing out fluctuations and highlighting overall patterns.';
                }
                action("Sales Moving Annual Total")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Moving Annual Total';
                    Image = "PowerBI";
                    RunObject = page "Sales Moving Annual Total";
                    Tooltip = 'Open a Power BI Report that provides a rolling 12-month view of sales figures, tracking the current year to the previous year''s performance. ';
                }
                action("Sales Period-Over-Period")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Period-Over-Period';
                    Image = "PowerBI";
                    RunObject = page "Sales Period-Over-Period";
                    Tooltip = 'Open a Power BI Report that compares sales performance across different periods, such as month-over-month or year-over-year.';
                }
                action("Sales Month-To-Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Month-To-Date';
                    Image = "PowerBI";
                    RunObject = page "Sales Month-To-Date";
                    Tooltip = 'Open a Power BI Report that tracks the accumulation of sales amounts throughout the current month, providing insights into progress and performance up to the present date.';
                }
                action("Sales by Item")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales by Item';
                    Image = "PowerBI";
                    RunObject = page "Sales by Item";
                    Tooltip = 'Open a Power BI Report that breaks down sales performance by item category, highlighting metrics such as Sales Amount, Gross Profit Margin, and Gross Profit as a Percent of the Grand Total. This report provides detailed insights into which categories and items are driving revenue and profitability.';
                }
                action("Sales by Customer")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales by Customer';
                    Image = "PowerBI";
                    RunObject = page "Sales by Customer";
                    Tooltip = 'Open a Power BI Report that breaks down sales performance highlighting key metrics such as Sales Amount, Cost Amount, Gross Profit and Gross Profit Margin by customer. This report provides detailed insights into which customer and items driving revenue and profitability.';
                }
                action("Sales by Salesperson")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales by Salesperson';
                    Image = "PowerBI";
                    RunObject = page "Sales by Salesperson";
                    Tooltip = 'Open a Power BI Report that breaks down salesperson performance by customer and item. Highlighting metrics such as Sales Amount, Sales Quantity, Gross Profit and Gross Profit Margin.';
                }
                action("Sales Actual vs. Budget Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Actual vs. Budget Quantity';
                    Image = "PowerBI";
                    RunObject = page "Sales Actual vs. Budget Qty.";
                    Tooltip = 'Open a Power BI Report that provides a comparative analysis of sales quantity to budget quantity. Featuring variance and variance percentage metrics that provide a clear view of actual performance compared to budgeted targets.';
                }
                action("Sales Actual vs. Budget Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Actual vs. Budget Amount';
                    Image = "PowerBI";
                    RunObject = page "Sales Actual vs. Budget Amt.";
                    Tooltip = 'Open a Power BI Report that provides a comparative analysis of sales amounts to budget amount. Featuring variance and variance percentage metrics that provide a clear view of actual performance compared to budgeted targets.';
                }
            }
        }
    }
}

