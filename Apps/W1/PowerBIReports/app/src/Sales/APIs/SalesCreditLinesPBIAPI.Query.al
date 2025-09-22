// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Sales.History;

query 37109 "Sales Credit Lines - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sales Credit Lines';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'salesCreditLine';
    EntitySetName = 'salesCreditLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SalesCreditLine; "Sales Cr.Memo Line")
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

            dataitem(SalesCreditHeader; "Sales Cr.Memo Header")
            {
                DataItemLink = "No." = SalesCreditLine."Document No.";
                column(salesCreditDocumentNo; "No.") { }
                column(campaignNo; "Campaign No.") { }
                column(salespersonCode; "Salesperson Code") { }
                column(opportunityNo; "Opportunity No.") { }
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