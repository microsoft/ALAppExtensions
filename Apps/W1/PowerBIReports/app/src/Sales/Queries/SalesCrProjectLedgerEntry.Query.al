namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Projects.Project.Ledger;
using Microsoft.Sales.History;

query 37071 "Sales Cr Project Ledger Entry"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sales Cr. Project Ledger Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'salesCrProjectLedgerEntry';
    EntitySetName = 'salesCrProjectLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ProjectLedgerEntry; "Job Ledger Entry")
        {
            DataItemTableFilter = Type = filter(Item), "Entry Type" = filter("Sale");
            column(postingDate; "Posting Date") { }
            column(type; Type) { }
            column(description; Description) { }
            column(entryNo; "Entry No.") { }
            column(no; "No.") { }
            column(documentNo; "Document No.") { }
            column(locationCode; "Location Code") { }
            column(quantityBase; "Quantity (Base)") { }
            column(totalPriceLCY; "Total Price (LCY)") { }
            column(totalCostLCY; "Total Cost (LCY)") { }
            column(unitCostLCY; "Unit Cost (LCY)") { }
            column(reasonCode; "Reason Code") { }
            column(dimensionSetID; "Dimension Set ID") { }
            column(projectNo; "Job No.") { }

            dataitem(salesCrMemoHeader; "Sales Cr.Memo Header")
            {
                DataItemLink = "No." = ProjectLedgerEntry."Document No.";
                SqlJoinType = InnerJoin;
                column(salesCreditDocumentNo; "No.") { }
                column(campaignNo; "Campaign No.") { }
                column(salespersonCode; "Salesperson Code") { }
                column(opportunityNo; "Opportunity No.") { }
                column(billToCustomerNo; "Bill-to Customer No.") { }
                column(sellToCustomerNo; "Sell-to Customer No.") { }
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Sales Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateItemSalesReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(postingDate, DateFilterText);
    end;
}