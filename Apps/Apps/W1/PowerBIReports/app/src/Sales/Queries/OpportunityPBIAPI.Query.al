namespace Microsoft.Sales.PowerBIReports;

using Microsoft.CRM.Opportunity;

query 37017 "Opportunity - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Opportunity';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'opportunity';
    EntitySetName = 'opportunities';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(opportunity; Opportunity)
        {
            column(opportunityNo; "No.") { }
            column(opportunityDescription; Description) { }
            column(opportunitySalesCycle; "Sales Cycle Code") { }
            column(opportunityCreationDate; "Creation Date") { }
            column(opportunityStatus; Status) { }
            column(opportunityClosed; Closed) { }
            column(opportunitySalesDocumentNo; "Sales Document No.") { }
            column(opportunitySalesDocumentType; "Sales Document Type") { }
            column(opportunityPriority; Priority) { }
            column(opportunityCampaignNo; "Campaign No.") { }
            column(opportunitySegmentNo; "Segment No.") { }
        }
    }
}