namespace Microsoft.PowerBIReports;

using Microsoft.Manufacturing.RoleCenters;

pageextension 36958 "Production Planner Role Center" extends "Production Planner Role Center"
{
    actions
    {
        addlast(Reporting)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = PowerBI;
                ToolTip = 'Power BI reports for manufacturing';
                action("Current Utilization")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Current Utilization';
                    Image = "PowerBI";
                    RunObject = page "Current Utilization";
                    Tooltip = 'Open a Power BI Report to view the current Weeks Utilization % by comparing Capacity Used to Available Capacity in Hours. View all or some Work Centres to measure throughput and efficiency.';
                }
                action("Historical Utilization")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Historical Utilization';
                    Image = "PowerBI";
                    RunObject = page "Historical Utilization";
                    Tooltip = 'Open a Power BI Report to view the historical Utilization % by comparing Capacity Used vs Available Capacity in Hours viewed over a timeline you can define to see trends. View all or some Work Centres.';
                }
                action("Work Center Load")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Work Center Load';
                    Image = "PowerBI";
                    RunObject = page "Work Center Load";
                    Tooltip = 'Open a Power BI Report to view the percentage of production order time assigned vs Available Capacity for each Work Centre Group and/or Work Centre in a specified period. Allows you to determine if a Work Centre is overloaded and requires rescheduling.';
                }
                action("Allocated Hours")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Allocated Hours';
                    Image = "PowerBI";
                    RunObject = page "Allocated Hours";
                    Tooltip = 'Open a Power BI Report to view the number of hours remaining for production allocated to each Work Centre in a specified period. Allows you to determine if a Work Centre is under or overloaded and requires rescheduling.';
                }
                action("Expected Capacity Need")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Expected Capacity Need';
                    Image = "PowerBI";
                    RunObject = page "Expected Capacity Need";
                    Tooltip = 'Open a Power BI Report to view the total hours scheduled to be performed for each Work Centre Group and/or Work Centre broken down by production order status and production order to analyze your requirement on factory resources.';
                }
                action("Finished Prod. Order Breakdown")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Finished Prod. Order Breakdown';
                    Image = "PowerBI";
                    RunObject = page "Finished Prod. Order Breakdown";
                    Tooltip = 'Open a Power BI Report to view Expected Quantities and Cost vs Actual Quantities and Costs over time, analyze the detail per item and drill down to the Production Order to track where variances are occurring.';
                }
                action("Consumption Variance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Consumption Variance';
                    Image = "PowerBI";
                    RunObject = page "Consumption Variance";
                    Tooltip = 'Open a Power BI Report to view your consumption cost variance % viewed over a timeline you can define to see trends. Analyze by each production order and filter by Work Centre to see the detail behind the overall percentages.';
                }
                action("Capacity Variance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Capacity Variance';
                    Image = "PowerBI";
                    RunObject = page "Capacity Variance";
                    Tooltip = 'Open a Power BI Report to view your capacity cost variance % viewed over a timeline you can define to see trends. Analyze by each production order and filter by Work Centre to see the detail behind the overall percentages.';
                }
                action("Average Productions Times")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Average Productions Times';
                    Image = "PowerBI";
                    RunObject = page "Average Productions Times";
                    Tooltip = 'Open a Power BI Report to view the average time spent for Setup, Run and Stop times per unit for each manufactured Item. Expand to see the times for each production order to determine why fluctuations occurred.';
                }
                action("Released Prod. Orders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Released Production Orders';
                    Image = "PowerBI";
                    RunObject = page "Released Production Orders";
                    Tooltip = 'Open a Power BI Report to view how your released production orders are tracking by comparing Expected Quantity vs Finished Quantity';
                }
                action("Production Scrap")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production Scrap';
                    Image = "PowerBI";
                    RunObject = page "Production Scrap";
                    Tooltip = 'Open a Power BI Report to view your scrap quantities over a timeline you can define to see trends. Analyze further by Scrap Code, Location, Item Categories and by filtering for specific items.';
                }
            }
        }
    }
}

