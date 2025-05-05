namespace Microsoft.PowerBIReports;

using Microsoft.SubscriptionBilling;

pageextension 36965 "Sub. Billing Role Center" extends "Sub. Billing Role Center"
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
                }
                action("Subscription Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Subscription Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Subscription Overview";
                }
                action("Revenue YoY (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue YoY (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue YoY";
                }
                action("Revenue Analysis (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue Analysis (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue Analysis";
                }
                action("Revenue Development (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue Development (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue Development";
                }
                action("Churn Analysis (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Churn Analysis (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Churn Analysis";
                }
                action("Revenue by Item (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue by Item (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue by Item";
                }
                action("Revenue by Customer (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue by Customer (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue by Customer";
                }
                action("Revenue by Salesperson (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Revenue by Salesperson (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Revenue by Salesperson";
                }
                action("Total Contract Value YoY (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Contract Value YoY (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Total Contract Value YoY";
                }
                action("Total Contract Value Analysis (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Contract Value Analysis (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Total Contract Value Analysis";
                }
                action("Customer Deferrals (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer Deferrals (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Customer Deferrals";
                }
                action("Vendor Deferrals (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor Deferrals (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Vendor Deferrals";
                }
                action("Sales and Cost forecast (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales and Cost forecast (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales and Cost forecast";
                }
                action("Billing Schedule (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Billing Schedule (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Billing Schedule";
                }
            }
        }
    }
}

