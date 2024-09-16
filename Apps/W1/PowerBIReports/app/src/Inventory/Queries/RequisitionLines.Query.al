namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Inventory.Requisition;

query 36974 "Requisition Lines"
{
    Access = Internal;
    Caption = 'Power BI Requisition Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'requisitionLine';
    EntitySetName = 'requisitionLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Requisition_Line; "Requisition Line")
        {
            DataItemTableFilter = Type = const(Item);
            column(worksheetTemplateName; "Worksheet Template Name")
            {

            }
            column(journalBatchName; "Journal Batch Name")
            {

            }
            column(planningLineOrigin; "Planning Line Origin")
            {
            }
            column(replenishmentSystem; "Replenishment System")
            {

            }
            column(itemNo; "No.")
            {

            }
            column(transferFromCode; "Transfer-from Code")
            {

            }
            column(locationCode; "Location Code")
            {

            }
            column(dueDate; "Due Date")
            {

            }
            column(startingDate; "Starting Date")
            {

            }
            column(orderDate; "Order Date")
            {

            }
            column(transferShipmentDate; "Transfer Shipment Date")
            {

            }
            column(quantityBase; "Quantity (Base)")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(qtyPerUnitOfMeasure; "Qty. per Unit of Measure")
            {
            }
            column(unitOfMeasureCode; "Unit of Measure Code")
            {
            }
        }
    }
}