namespace Microsoft.PowerBIReports;

using Microsoft.Projects.RoleCenters;

pageextension 36963 "Project Manager Role Center" extends "Project Manager Role Center"
{
    actions
    {
        addfirst(Sections)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = AnalysisView;
                ToolTip = 'Power BI reports for projects';
                action("Projects Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Projects Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Projects Overview";
                }
                action("Project Tasks (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Project Tasks (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Project Tasks";
                }
                action("Project Profitability (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Project Profitability (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Project Profitability";
                }
                action("Project Realization (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Project Realization (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Project Realization";
                }
                action("Project Performance to Budget (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Project Performance to Budget (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Project Performance to Budget";
                }
                action("Project Invoiced Sales by Type (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Project Invoiced Sales by Type (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Project Invoiced Sales by Type";
                }
                action("Project Invd. Sales by Cust. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Project Invd. Sales by Cust. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Project Invd. Sales by Cust.";
                }
            }
        }
    }
}

