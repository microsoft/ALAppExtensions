namespace Microsoft.PowerBIReports;

using Microsoft.Manufacturing.RoleCenters;

pageextension 36964 "Manufacturing Manager RC" extends "Manufacturing Manager RC"
{
    actions
    {
        addfirst(Sections)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = AnalysisView;
                ToolTip = 'Power BI reports for manufacturing';
                action("Work Center Statistics (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Work Center Statistics (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "PBI Work Center Statistics";
                    Tooltip = 'Open the Power BI report that shows your work center statistics and detailed metrics on total and effective capacity, expected and actual efficiency, actual need, cost, and allocated time.';
                }
                action("Machine Center Statistics (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Machine Center Statistics (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "PBI Machine Center Statistics";
                    Tooltip = 'Open the Power BI report that shows your machine center statistics and discover detailed metrics on total and effective capacity, expected and actual efficiency, scrap rates, and output.';
                }
                action("Machine Center Load (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Machine Center Load (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "PBI Machine Center Load";
                    Tooltip = 'Open the Power BI report that shows your machine center load and usage, including allocated time and availability for each machine center, helping you optimize resource allocation and improve operational efficiency.';
                }
                action("Prod. Order - List (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production Order - List (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Prod. Order - List";
                    Tooltip = 'Open the Power BI report that lists all production orders and analyzes detailed production order information, including status, due date, and planned versus finished quantities.';
                }
                action("Production Order Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production Order Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Production Order Overview";
                    Tooltip = 'Open the Power BI report that presents key metrics and charts including a breakdown of total actual costs, the number of production orders by status, and the completion percentages for each source item.';
                }
                action("Prod. Order Routings Gantt (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production Order Routings Gantt (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Prod. Order Routings Gantt";
                    Tooltip = 'Open the Power BI report that visualizes the schedules of each work and machine center with a Gantt chart, detailing production order routing lines.';
                }
                action("Production Order WIP (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production Order WIP (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Production Order WIP";
                    Tooltip = 'Open the Power BI report that shows inventory valuation for selected production orders in your WIP inventory.';
                }
            }
        }
        addlast(Group10)
        {
            action("Expected Capacity Need (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Expected Capacity Need (Power BI)';
                Image = "PowerBI";
                RunObject = page "Expected Capacity Need";
                Tooltip = 'Open a Power BI Report to view the total hours scheduled to be performed for each Work Centre Group and/or Work Centre broken down by production order status and production order to analyze your requirement on factory resources.';
            }

        }
        addlast(Group13)
        {
            action("Manufacturing Report (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Manufacturing Report (Power BI)';
                Image = "PowerBI";
                RunObject = page "Manufacturing Report";
                Tooltip = 'Open a Power BI Report that offers a consolidated view of all manufacturing report pages, conveniently embedded into a single page for easy access.';
            }
            action("Finished Prod. Order Breakdown (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finished Production Order Breakdown (Power BI)';
                Image = "PowerBI";
                RunObject = page "Finished Prod. Order Breakdown";
                Tooltip = 'Open a Power BI Report to view Expected Quantities and Cost vs. Actual Quantities and Costs over time, analyze the detail per item and drill down to the Production Order to track where variances are occurring.';
            }
            action("Average Productions Times (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Average Productions Times (Power BI)';
                Image = "PowerBI";
                RunObject = page "Average Productions Times";
                Tooltip = 'Open a Power BI Report to view the average time spent for Setup, Run and Stop times per unit for each manufactured Item. Expand to see the times for each production order to determine why fluctuations occurred.';
            }
            action("Released Production Orders (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Released Production Orders (Power BI)';
                Image = "PowerBI";
                RunObject = page "PowerBI Released Prod. Orders";
                Tooltip = 'Open a Power BI Report to view how your released production orders are tracking by comparing Expected Quantity vs. Finished Quantity';
            }

        }
        addlast(Group16)
        {
#if not CLEAN26
            action("Current Utilization (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Current Utilization (Power BI)';
                Image = "PowerBI";
                RunObject = page "Current Utilization";
                Tooltip = 'Open a Power BI Report to view the current Weeks Utilization % by comparing Capacity Used to Available Capacity in Hours. View all or some Work Centers to measure throughput and efficiency.';
                ObsoleteState = Pending;
                ObsoleteReason = 'The Power BI report has been changed/removed and this is no longer required.';
                ObsoleteTag = '26.0';
                Visible = false;
            }
#endif
#if not CLEAN26
            action("Historical Utilization (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Historical Utilization (Power BI)';
                Image = "PowerBI";
                RunObject = page "Historical Utilization";
                Tooltip = 'Open a Power BI Report to view the historical Utilization % by comparing Capacity Used vs. Available Capacity in Hours viewed over a timeline you can define to see trends. View all or some Work Centers.';
                ObsoleteState = Pending;
                ObsoleteReason = 'The Power BI report has been changed/removed and this is no longer required.';
                ObsoleteTag = '26.0';
                Visible = false;
            }
#endif
            action("Work Center Load (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Work Center Load (Power BI)';
                Image = "PowerBI";
                RunObject = page "PowerBI Work Center Load";
                Tooltip = 'Open a Power BI Report to view the percentage of production order time assigned vs. Available Capacity for each Work Centre Group and/or Work Centre in a specified period. Allows you to determine if a Work Centre is overloaded and requires rescheduling.';
            }
            action("Allocated Hours (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Allocated Hours (Power BI)';
                Image = "PowerBI";
                RunObject = page "Allocated Hours";
                Tooltip = 'Open a Power BI Report to view the number of hours remaining for production allocated to each Work Centre in a specified period. Allows you to determine if a Work Centre is under or overloaded and requires rescheduling.';
            }
            action("Consumption Variance (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Consumption Variance (Power BI)';
                Image = "PowerBI";
                RunObject = page "Consumption Variance";
                Tooltip = 'Open a Power BI Report to view your consumption cost variance % viewed over a timeline you can define to see trends. Analyze by each production order and filter by Work Centre to see the detail behind the overall percentages.';
            }
            action("Capacity Variance (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Capacity Variance (Power BI)';
                Image = "PowerBI";
                RunObject = page "Capacity Variance";
                Tooltip = 'Open a Power BI Report to view your capacity cost variance % viewed over a timeline you can define to see trends. Analyze by each production order and filter by Work Centre to see the detail behind the overall percentages.';
            }
            action("Production Scrap (Power BI)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Production Scrap (Power BI)';
                Image = "PowerBI";
                RunObject = page "Production Scrap";
                Tooltip = 'Open a Power BI Report to view your scrap quantities over a timeline you can define to see trends. Analyze further by Scrap Code, Location, Item Categories and by filtering for specific items.';
            }

        }
    }
}

