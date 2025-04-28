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
            column(entryNo; "Entry No.") { }
            column(orderType; "Order Type") { }
            column(orderNo; "Order No.") { }
            column(orderLineNo; "Order Line No.") { }
            column(type; Type) { }
            column(no; "No.") { }
            column(description; Description) { }
            column(postingDate; "Posting Date") { }
            column(itemNo; "Item No.") { }
            column(setupTime; "Setup Time") { }
            column(runTime; "Run Time") { }
            column(stopTime; "Stop Time") { }
            column(quantity; Quantity) { }
            column(outputQuantity; "Output Quantity") { }
            column(scrapQuantity; "Scrap Quantity") { }
            column(directCost; "Direct Cost") { }
            column(overheadCost; "Overhead Cost") { }
            column(routingNo; "Routing No.") { }
            column(routingReferenceNo; "Routing Reference No.") { }
            column(operationNo; "Operation No.") { }
            column(workCenterGroupCode; "Work Center Group Code") { }
            column(scrapCode; "Scrap Code") { }
            column(dimensionSetID; "Dimension Set ID") { }
            column(workCenterNo; "Work Center No.") { }
            column(workShiftCode; "Work Shift Code") { }
            column(subcontracting; Subcontracting) { }
            column(qtyPerCapUnitOfMeasure; "Qty. per Cap. Unit of Measure") { }
            column(capUnitOfMeasureCode; "Cap. Unit of Measure Code") { }
            column(qtyPerUnitOfMeasure; "Qty. per Unit of Measure") { }
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