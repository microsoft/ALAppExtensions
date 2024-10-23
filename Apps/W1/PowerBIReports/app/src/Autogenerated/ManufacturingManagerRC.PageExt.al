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
                action("Current Utilization (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Current Utilization (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Current Utilization";
                }
                action("Historical Utilization (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Historical Utilization (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Historical Utilization";
                }
                action("Work Center Load (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Work Center Load (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Work Center Load";
                }
                action("Allocated Hours (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Allocated Hours (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Allocated Hours";
                }
                action("Expected Capacity Need (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Expected Capacity Need (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Expected Capacity Need";
                }
                action("Finished Prod. Order Breakdown (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Finished Prod. Order Breakdown (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Finished Prod. Order Breakdown";
                }
                action("Consumption Variance (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Consumption Variance (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Consumption Variance";
                }
                action("Capacity Variance (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Capacity Variance (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Capacity Variance";
                }
                action("Average Productions Times (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Average Productions Times (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Average Productions Times";
                }
                action("Released Production Orders (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Released Production Orders (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Released Production Orders";
                }
                action("Production Scrap (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production Scrap (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Production Scrap";
                }
            }
        }
    }
}

