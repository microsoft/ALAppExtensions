namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Document;
using Microsoft.Inventory.Location;

query 36990 "Prod. Order Routing Lines"
{
    Access = Internal;
    Caption = 'Power BI Production Order Routing Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'prodOrderRoutingLine';
    EntitySetName = 'prodOrderRoutingLines';
    DataAccessIntent = ReadOnly;


    elements
    {
        dataitem(ProdOrderRoutingLine; "Prod. Order Routing Line")
        {
            column(routingStatus; "Routing Status") { }
            column(status; Status) { }
            column(prodOrderNo; "Prod. Order No.") { }
            column(type; Type) { }
            column(no; "No.") { }
            column(description; Description) { }
            column(locationCode; "Location Code") { }
            column(expectedCapacityNeed; "Expected Capacity Need")
            {
                Method = Sum;
            }
            column(expectedOperationCostAmt; "Expected Operation Cost Amt.")
            {
                Method = Sum;
            }
            column(expectedCapacityOvhdCost; "Expected Capacity Ovhd. Cost")
            {
                Method = Sum;
            }
            column(endingDate; "Ending Date") { }
            column(routingNo; "Routing No.") { }
            column(routingReferenceNo; "Routing Reference No.") { }
            column(operationNo; "Operation No.") { }
            column(workCenterNo; "Work Center No.") { }
            column(workCenterGroupCode; "Work Center Group Code") { }
            column(routingLinkCode; "Routing Link Code") { }
            column(setupTime; "Setup Time") { }
            column(runTime; "Run Time") { }
            column(waitTime; "Wait Time") { }
            column(moveTime; "Move Time") { }
            column(startingDateTime; "Starting Date-Time") { }
            column(endingDateTime; "Ending Date-Time") { }
            dataitem(Location; Location)
            {
                DataItemLink = Code = ProdOrderRoutingLine."Location Code";
                column(locationName; Name) { }
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
            CurrQuery.SetFilter(endingDate, DateFilterText);
    end;
}