// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Sales.History;

query 37074 "Sales Invoice Lines - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sales Invoice Lines';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'salesInvoiceLine';
    EntitySetName = 'salesInvoiceLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SalesInvoiceLine; "Sales Invoice Line")
        {
            DataItemTableFilter = "Type" = filter("G/L Account" | "Resource");
            column(postingDate; "Posting Date") { }
            column(type; Type) { }
            column(description; Description) { }
            column(documentNo; "Document No.") { }
            column(lineNo; "Line No.") { }
            column(no; "No.") { }
            column(locationCode; "Location Code") { }
            column(quantityBase; "Quantity (Base)") { }
            column(amount; Amount) { }
            column(unitCostLCY; "Unit Cost (LCY)") { }
            column(returnReasonCode; "Return Reason Code") { }
            column(shipmentDate; "Shipment Date") { }
            column(dimensionSetID; "Dimension Set ID") { }
            column(projectNo; "Job No.") { }
            column(billToCustomerNo; "Bill-to Customer No.") { }
            column(sellToCustomerNo; "Sell-to Customer No.") { }

            dataitem(SalesInvoiceHeader; "Sales Invoice Header")
            {
                DataItemLink = "No." = SalesInvoiceLine."Document No.";
                column(salesInvoiceDocumentNo; "No.") { }
                column(campaignNo; "Campaign No.") { }
                column(salespersonCode; "Salesperson Code") { }
                column(opportunityNo; "Opportunity No.") { }
                column(quoteNo; "Quote No.") { }
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