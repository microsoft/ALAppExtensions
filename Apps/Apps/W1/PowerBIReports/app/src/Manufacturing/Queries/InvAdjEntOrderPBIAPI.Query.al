namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Inventory.Costing;

query 37020 "Inv. Adj. Ent Order - PBI API"
{
    Access = Internal;
    Caption = 'Power BI Inventory Adjustment Entry Order';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'inventoryAdjustmentEntryOrder';
    EntitySetName = 'inventoryAdjustmentEntryOrders';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Inventory_Adjmt__Entry__Order_; "Inventory Adjmt. Entry (Order)")
        {
            DataItemTableFilter = "Order Type" = const("Production");
            column(itemNo; "Item No.") { }
            column(orderLineNo; "Order Line No.") { }
            column(orderNo; "Order No.") { }
            column(singleLevelMaterialCost; "Single-Level Material Cost") { }
            column(singleLevelCapacityCost; "Single-Level Capacity Cost") { }
            column(singleLevelSubcontrdCost; "Single-Level Subcontrd. Cost") { }
            column(singleLevelCapOvhdCost; "Single-Level Cap. Ovhd Cost") { }
            column(singleLevelMfgOvhdCost; "Single-Level Mfg. Ovhd Cost") { }
            column(iSFinished; "Is Finished") { }
            column(completelyInvoiced; "Completely Invoiced") { }
            column(indirectCostPercent; "Indirect Cost %") { }
            column(overheadRate; "Overhead Rate") { }
        }
    }
}