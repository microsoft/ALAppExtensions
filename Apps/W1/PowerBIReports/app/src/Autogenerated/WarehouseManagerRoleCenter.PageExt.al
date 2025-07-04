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
                action("Inventory Report (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Report (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory Report";
                    Tooltip = 'Open a Power BI Report that offers a consolidated view of all inventory report pages, conveniently embedded into a single page for easy access.';
                }
                action("Inventory Overview (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Overview (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory Overview";
                    Tooltip = 'Open a Power BI Report that offers a dashboard view of inventory, featuring key elements such as inventory by location, a comparison of inventory balance versus projected available balance, and key metrics like scheduled receipt quantities and gross requirements.';
                }
                action("Inventory by Item (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory by Item (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory by Item";
                    Tooltip = 'Open a Power BI Report that provides inventory quantities by item, offering insights into the sources of supply and demand. Helping organizations understand item-level inventory status, manage stock effectively, and make informed decisions about the state of supply and demand.';
                }
                action("Inventory by Location (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory by Location (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory by Location";
                    Tooltip = 'Open a Power BI Report that shows inventory quantities by item and by location. ';
                }
                action("Purchase and Sales Quantity (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase and Sales Quantity (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Purchase and Sales Quantity";
                    Tooltip = 'Open a Power BI Report that offers insight into inventory movements by visualizing Net Quantity Purchased and Net Quantity Sold across time. The table matrix breaks down purchases and sales by item and item category code, targeting insights into supply from purchases and demand from sales. ';
                }
                action("Item Availability (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Availability (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Item Availability";
                    Tooltip = 'Open a Power BI Report that visualizes Quantity on Hand versus Projected Available Balance over time, helping track inventory trends. A table matrix breaks down this data by item, offering metrics such as Inventory, Projected Available Balance, Gross Requirements, Scheduled Receipts, Planned Order Receipts, and Planned Order Releases. Providing a comprehensive view of item availability, aiding in effective inventory management and planning.';
                }
                action("Gross Requirement (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gross Requirement (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Gross Requirement";
                    Tooltip = 'Open a Power BI Report that visualizes Gross Requirements against Projected Available Balance over time, offering a clear view of inventory demands. A table matrix breaks down this data by item, showcasing key metrics like Gross Requirement, Projected Available Balance, and quantities from demand documents (sales orders and purchase return orders). ';
                }
                action("Scheduled Receipt (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Scheduled Receipt (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Scheduled Receipt";
                    Tooltip = 'Open a Power BI Report that visualizes Scheduled Receipt against Projected Available Balance over time, offering a clear view of inventory supply. A table matrix breaks this down by item, showcasing key metrics like Scheduled Receipt Quantity, Projected Available Balance, and quantities from supply documents such as purchase orders, transfer receipts and manufacturing documents.';
                }
                action("Inventory by Lot (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory by Lot (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory by Lot";
                    Tooltip = 'Open a Power BI Report that displays inventory quantities categorized by lot number, providing detailed insights into specific batches of stock. A decomposition tree enhances this by allowing users to drill down into inventory data, breaking down lot quantities by various dimensions such as location, item category, or vendor.';
                }
                action("Inventory by Serial No. (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory by Serial No. (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Inventory by Serial No.";
                    Tooltip = 'Open a Power BI Report that displays inventory quantities categorized by serial number. The decomposition tree enhances this report by allowing users to drill down into inventory data, breaking down quantities by various dimensions such as location, item category, or vendor.';
                }
                action("Bin Contents (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bin Contents (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "PowerBI Bin Contents";
                    Tooltip = 'Open a Power BI Report that provides a detailed view of item quantities by bin code and location. It includes additional information such as warehouse quantity, pick and put-away quantities, and both negative and positive adjustments, offering a comprehensive overview of bin movements and inventory management within the warehouse.';
                }
                action("Bin Contents by Item Tracking (Power BI)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bin Contents by Item Tracking (Power BI)';
                    Image = "PowerBI";
                    RunObject = page "Bin Contents by Item Tracking";
                    Tooltip = 'Open a Power BI Report that provides a detailed view of warehouse quantities by Item, Location, Bin Code, Zone Code, Lot number or Serial number. ';
                }
            }
        }
    }
}

