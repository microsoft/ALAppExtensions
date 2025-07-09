namespace Microsoft.PowerBIReports;

using Microsoft.SubscriptionBilling;

pageextension 8013 "Sub. Billing Role Center" extends "Sub. Billing Role Center"
{
    actions
    {
        addfirst(Sections)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = AnalysisView;
                ToolTip = 'Power BI reports for subscription billing';
                action("Subscription Billing Report (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Subscription Billing Report (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Subscription Billing Report";
                    ToolTip = 'The Subscription Billing Report offers a consolidated view of all subscription report pages, conveniently embedded into a single page for easy access.';
                }
                action("Subscription Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Subscription Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Subscription Overview";
                    ToolTip = 'The Subscription Overview provides a comprehensive view of subscription performance, offering insights into metrics such as Monthly Recurring Revenue, Total Contract Value, Churn and top-performing customers or vendors.';
                }
                action("Revenue YoY (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue YoY (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue YoY";
                    ToolTip = 'The Revenue YoY report compares Monthly Recurring Revenue performance across a year-over-year period.';
                }
                action("Revenue Analysis (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue Analysis (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue Analysis";
                    ToolTip = 'The Revenue Analysis report breaks down Monthly Recurring Revenue by various dimension such as billing rhythm, contract type or customer.';
                }
                action("Revenue Development (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue Development (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue Development";
                    ToolTip = 'The Revenue Development report shows the change in monthly recurring revenue and helps to identify its various sources such as churn, downgrades, new subscriptions or upgrades.';
                }
                action("Churn Analysis (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Churn Analysis (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Churn Analysis";
                    ToolTip = 'The Churn Analysis report breaks down churn by various dimensions such as contract term, contract type or product.';
                }
                action("Revenue by Item (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue by Item (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue by Item";
                    ToolTip = 'The Revenue by Item report breaks down subscription performance by item category, highlighting metrics such as Monthly Recurring Revenue, Monthly Recurring Cost, Monthly Net Profit Amount and Monthly Net Profit %. This report provides detailed insights into which categories and items are driving subscription revenue and profitability.';
                }
                action("Revenue by Customer (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue by Customer (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue by Customer";
                    ToolTip = 'The Revenue by Customer report breaks down subscription performance by customer and item, highlighting metrics such as Monthly Recurring Revenue, Monthly Recurring Cost, Monthly Net Profit Amount and Monthly Net Profit %. This report provides detailed insights into which customers and items are driving subscription revenue and profitability.';
                }
                action("Revenue by Salesperson (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue by Salesperson (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue by Salesperson";
                    ToolTip = 'The Revenue by Salesperson report breaks down subscription performance by Salesperson, highlighting metrics such as Monthly Recurring Revenue, Monthly Recurring Cost, Monthly Net Profit Amount and Churn.';
                }
                action("Total Contract Value YoY (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Contract Value YoY (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Total Contract Value YoY";
                    ToolTip = 'The Total Contract Value YoY report compares the Total Contract Value and Active Customers across a year-over-year period.';
                }
                action("Total Contract Value Analysis (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Contract Value Analysis (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Total Contract Value Analysis";
                    ToolTip = 'The Total Contract Value Analysis report breaks down Total Contract Value by various dimension such as billing rhythm, contract type or customer.';
                }
                action("Customer Deferrals (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer Deferrals (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Customer Deferrals";
                    ToolTip = 'The Customer Deferrals report provides an overview of deferred vs. released subscription sales amount.';
                }
                action("Vendor Deferrals (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor Deferrals (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Vendor Deferrals";
                    ToolTip = 'The Vendor Deferrals report provides an overview of deferred vs. released subscription cost amount.';
                }
                action("Sales and Cost forecast (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales and Cost forecast (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales and Cost forecast";
                    ToolTip = 'The Sales and Cost forecast report provides the forecast of Monthly Recurring Revenue and Monthly Recurring Cost for the future months and years. This report provides detailed insights into which salespersons and customers are driving future subscription performance.';
                }
                action("Billing Schedule (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Billing Schedule (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Billing Schedule";
                    ToolTip = 'The Billing Schedule report provides a forecast of vendor and customer invoiced amounts according to the contractual billing rhythm. It helps to identify future development of incoming and outgoing cash from billed subscriptions.';
                }
            }
        }
    }
}

