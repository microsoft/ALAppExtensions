namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Document;
using Microsoft.Inventory.Location;

query 36989 "Prod. Order Lines - Manuf."
{
    Access = Internal;
    Caption = 'Power BI Prod. Order Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'manufacturingProdOrderLines';
    EntitySetName = 'manufacturingProdOrderLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ProdOrderLine; "Prod. Order Line")
        {
            column(prodOrderStatus; Status)
            {
            }
            column(prodOrderNo; "Prod. Order No.")
            {
            }
            column(prodOrderLineNo; "Line No.")
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(quantityBase; "Quantity (Base)")
            {
                Method = Sum;
            }
            column(remainingQtyBase; "Remaining Qty. (Base)")
            {
                Method = Sum;
            }
            column(dueDate; "Due Date")
            {
            }
            column(routingNo; "Routing No.")
            {
            }
            column(routingReferenceNo; "Routing Reference No.")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            dataitem(Location; Location)
            {
                DataItemLink = Code = ProdOrderLine."Location Code";
                column(locationName; Name)
                {
                }
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Manuf. Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateManufacturingReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(dueDate, DateFilterText);
    end;
}