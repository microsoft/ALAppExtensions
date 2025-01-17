namespace Microsoft.Projects.PowerBIReports;

using Microsoft.Purchases.Document;

query 36996 "Purch. Lines - Job Outstanding"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Outstanding PO Line';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'jobOutstandingPurchaseLine';
    EntitySetName = 'jobOutstandingPurchaseLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(OutstandinguPOLine; "Purchase Line")
        {
            DataItemTableFilter = "Document Type" = filter(Order | Invoice),
                                    "Job No." = filter(<> ''),
                                    "Outstanding Qty. (Base)" = filter(> 0);
            column(documentType; "Document Type")
            {
            }
            column(documentNo; "Document No.")
            {
            }
            column(no; "No.")
            {
            }
            column(type; Type)
            {
            }
            column(outstandingQtyBase; "Outstanding Qty. (Base)")
            {
            }
            column(outstandingAmountLCY; "Outstanding Amount (LCY)")
            {
            }
            column(jobNo; "Job No.")
            {
            }
            column(jobTaskNo; "Job Task No.")
            {
            }
            column(expectedReceiptDate; "Expected Receipt Date")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(description; Description)
            {
            }
        }
    }
}
