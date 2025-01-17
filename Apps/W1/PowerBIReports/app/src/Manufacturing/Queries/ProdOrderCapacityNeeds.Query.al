namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.Document;

query 36987 "Prod. Order Capacity Needs"
{
    Access = Internal;
    Caption = 'Power BI Prod. Order Cap. Need';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'prodOrderCapacityNeed';
    EntitySetName = 'prodOrderCapacityNeeds';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ProdOrderCapacityNeed; "Prod. Order Capacity Need")
        {
            column(status; Status)
            {
            }
            column(prodOrderNo; "Prod. Order No.")
            {
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
            column(allocatedTime; "Allocated Time")
            {
                Method = Sum;
            }
        }
    }

    trigger OnBeforeOpen()
    begin
        CurrQuery.SetFilter(status, '<>%1', status::Finished);
    end;
}