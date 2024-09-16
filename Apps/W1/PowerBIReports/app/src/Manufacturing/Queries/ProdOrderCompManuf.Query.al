namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Document;
using Microsoft.Inventory.Location;

query 36988 "Prod. Order Comp. - Manuf."
{
    Access = Internal;
    Caption = 'Power BI Prod. Order Components';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'manufacturingProdOrderComponent';
    EntitySetName = 'manufacturingProdOrderComponents';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ProdOrderComponent; "Prod. Order Component")
        {
            column(prodOrderStatus; Status)
            {
            }
            column(prodOrderNo; "Prod. Order No.")
            {
            }
            column(prodOrderLineNo; "Prod. Order Line No.")
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(expectedQtyBase; "Expected Qty. (Base)")
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
            column(routingLinkCode; "Routing Link Code")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            dataitem(Location; Location)
            {
                DataItemLink = Code = ProdOrderComponent."Location Code";
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