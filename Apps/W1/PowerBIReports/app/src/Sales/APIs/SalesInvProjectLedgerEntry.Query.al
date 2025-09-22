// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Projects.Project.Ledger;
using Microsoft.Sales.History;

query 37110 "Sales Inv Project Ledger Entry"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sales Inv. Project Ledger Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'salesInvoiceProjectLedgerEntry';
    EntitySetName = 'salesInvoiceProjectLedgerEntries';
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

            dataitem(salesInvoiceHeader; "Sales Invoice Header")
            {
                DataItemLink = "No." = ProjectLedgerEntry."Document No.";
                SqlJoinType = InnerJoin;
                column(salesInvoiceDocumentNo; "No.") { }
                column(campaignNo; "Campaign No.") { }
                column(salespersonCode; "Salesperson Code") { }
                column(opportunityNo; "Opportunity No.") { }
                column(quoteNo; "Quote No.") { }
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