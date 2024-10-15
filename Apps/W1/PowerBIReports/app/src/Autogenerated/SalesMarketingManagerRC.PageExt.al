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
                action("Sales Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Overview";
                }
                action("Daily Sales (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Daily Sales (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Daily Sales";
                }
                action("Sales Moving Average (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Moving Average (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Moving Average";
                }
                action("Sales Moving Annual Total (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Moving Annual Total (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Moving Annual Total";
                }
                action("Sales Period-Over-Period (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Period-Over-Period (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Period-Over-Period";
                }
                action("Sales Month-To-Date (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Month-To-Date (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Month-To-Date";
                }
                action("Sales by Item (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales by Item (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales by Item";
                }
                action("Sales by Customer (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales by Customer (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales by Customer";
                }
                action("Sales by Salesperson (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales by Salesperson (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales by Salesperson";
                }
                action("Sales Actual vs. Budget Qty. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Actual vs. Budget Qty. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Actual vs. Budget Qty.";
                }
                action("Sales Actual vs. Budget Amt. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Actual vs. Budget Amt. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Sales Actual vs. Budget Amt.";
                }
            }
        }
    }
}

