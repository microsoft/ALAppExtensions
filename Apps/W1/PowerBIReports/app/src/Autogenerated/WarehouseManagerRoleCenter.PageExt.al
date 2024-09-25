namespace Microsoft.PowerBIReports;

using Microsoft.Warehouse.RoleCenters;

pageextension 36962 "Warehouse Manager Role Center" extends "Warehouse Manager Role Center"
{
    actions
    {
        addfirst(Sections)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = AnalysisView;
                ToolTip = 'Power BI reports for inventory';
                action("Inventory Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory Overview";
                }
                action("Inventory by Item (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory by Item (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory by Item";
                }
                action("Inventory by Location (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory by Location (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory by Location";
                }
                action("Purchase and Sales Quantity (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase and Sales Quantity (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchase and Sales Quantity";
                }
                action("Item Availability (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Availability (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Item Availability";
                }
                action("Gross Requirement (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gross Requirement (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Gross Requirement";
                }
                action("Scheduled Receipt (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Scheduled Receipt (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Scheduled Receipt";
                }
                action("Inventory by Lot (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory by Lot (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory by Lot";
                }
                action("Inventory by Serial No. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory by Serial No. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory by Serial No.";
                }
                action("Bin Contents (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bin Contents (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Bin Contents";
                }
                action("Bin Contents by Item Tracking (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bin Contents by Item Tracking (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Bin Contents by Item Tracking";
                }
            }
        }
    }
}

