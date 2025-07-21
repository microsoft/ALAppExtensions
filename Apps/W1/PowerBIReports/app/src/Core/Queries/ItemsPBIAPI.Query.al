namespace Microsoft.PowerBIReports;

using Microsoft.Inventory.Item;

#pragma warning disable AS0125
#pragma warning disable AS0030
query 36953 "Items - PBI API"
#pragma warning restore AS0030
#pragma warning restore AS0125
{
    Access = Internal;
    Caption = 'Power BI Items';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'item';
    EntitySetName = 'items';
    DataAccessIntent = ReadOnly;
    elements
    {
        dataitem(Item; Item)
        {
            column(itemNo; "No.") { }
            column(itemDescription; Description) { }
            column(baseUnitofMeasure; "Base Unit of Measure") { }
            column(unitCost; "Unit Cost") { }
            column(inventoryPostingGroup; "Inventory Posting Group") { }
            column(routingNo; "Routing No.") { }
            column(productionBomNo; "Production BOM No.") { }
            column(replenishmentSystem; "Replenishment System") { }
            column(singleLevelCapOvhdCost; "Single-Level Cap. Ovhd Cost") { }
            column(singleLevelCapacityCost; "Single-Level Capacity Cost") { }
            column(singleLevelMaterialCost; "Single-Level Material Cost") { }
            column(singleLevelMfgOvhdCost; "Single-Level Mfg. Ovhd Cost") { }
            column(singleLevelSubcontrdCost; "Single-Level Subcontrd. Cost") { }
            column(singleLvlMatNonInvtCost; "Single-Lvl Mat. Non-Invt. Cost") { }
            column(rolledUpCapOverheadCost; "Rolled-up Cap. Overhead Cost") { }
            column(rolledUpCapacityCost; "Rolled-up Capacity Cost") { }
            column(rolledUpMatNonInvtCost; "Rolled-up Mat. Non-Invt. Cost") { }
            column(rolledUpMaterialCost; "Rolled-up Material Cost") { }
            column(rolledUpMfgOvhdCost; "Rolled-up Mfg. Ovhd Cost") { }
            column(rolledUpSubcontractedCost; "Rolled-up Subcontracted Cost") { }
            column(scrapPrc; "Scrap %") { }
            dataitem(ItemCategory; "Item Category")
            {
                DataItemLink = Code = Item."Item Category Code";
                column(itemCategoryCode; Code) { }
                column(itemCategoryDescription; Description) { }
            }
        }
    }
}