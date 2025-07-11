namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Inventory.Transfer;

query 36977 "Transfer Lines"
{
    Access = Internal;
    Caption = 'Power BI Qty. on Transfer Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'transferLine';
    EntitySetName = 'transferLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(transferLine; "Transfer Line")
        {
            DataItemTableFilter = "Derived From Line No." = const(0);
            column(documentNo; "Document No.")
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(inTransitLocationCode; "In-Transit Code")
            {
            }
            column(transferToLocationCode; "Transfer-to Code")
            {
            }
            column(transferFromLocationCode; "Transfer-from Code")
            {
            }
            column(qtyInTransitBase; "Qty. in Transit (Base)")
            {
                Method = Sum;
            }
            column(outstandingQtyBase; "Outstanding Qty. (Base)")
            {
                Method = Sum;
            }
            column(receiptDate; "Receipt Date")
            {
            }
            column(shipmentDate; "Shipment Date")
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