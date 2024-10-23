namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Capacity;

query 36984 "Capacity Ledger Entries"
{
    Access = Internal;
    Caption = 'Power BI Capacity Ledger Entries';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'capacityLedgerEntry';
    EntitySetName = 'capacityLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(CapacityLedgerEntry; "Capacity Ledger Entry")
        {
            column(orderType; "Order Type")
            {
            }
            column(orderNo; "Order No.")
            {
            }
            column(orderLineNo; "Order Line No.")
            {
            }
            column(type; Type)
            {
            }
            column(no; "No.")
            {
            }
            column(description; Description)
            {
            }
            column(postingDate; "Posting Date")
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(setupTime; "Setup Time")
            {
                Method = Sum;
            }
            column(runTime; "Run Time")
            {
                Method = Sum;
            }
            column(stopTime; "Stop Time")
            {
                Method = Sum;
            }
            column(quantity; Quantity)
            {
                Method = Sum;
            }
            column(outputQuantity; "Output Quantity")
            {
                Method = Sum;
            }
            column(scrapQuantity; "Scrap Quantity")
            {
                Method = Sum;
            }
            column(directCost; "Direct Cost")
            {
                Method = Sum;
            }
            column(overheadCost; "Overhead Cost")
            {
                Method = Sum;
            }
            column(routingNo; "Routing No.")
            {
            }
            column(routingReferenceNo; "Routing Reference No.")
            {
            }
            column(operationNo; "Operation No.")
            {
            }
            column(workCenterGroupCode; "Work Center Group Code")
            {
            }
            column(scrapCode; "Scrap Code")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
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
            CurrQuery.SetFilter(postingDate, DateFilterText);
    end;
}