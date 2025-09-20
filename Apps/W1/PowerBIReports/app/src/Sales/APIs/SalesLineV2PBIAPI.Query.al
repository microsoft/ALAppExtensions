// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Sales.Document;

query 37024 "Sales Line V2 - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sales Lines';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v1.0';
    EntityName = 'salesLine';
    EntitySetName = 'salesLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SalesHeader; "Sales Header")
        {
            column(orderNo; "No.") { }
            column(documentType; "Document Type") { }
            column(billToCustomerNo; "Bill-to Customer No.") { }
            column(sellToCustomerNo; "Sell-to Customer No.") { }
            column(salespersonCode; "Salesperson Code") { }
            column(opportunityNo; "Opportunity No.") { }
            column(quoteNo; "Quote No.") { }
            column(quoteValidUntilDate; "Quote Valid Until Date") { }
            column(orderDate; "Order Date") { }
            column(documentDate; "Document Date") { }
            column(dueDate; "Due Date") { }
            column(campaignNo; "Campaign No.") { }
            dataitem(SalesLine; "Sales Line")
            {
                DataItemTableFilter = Type = filter("Item" | "G/L Account" | "Resource");
                DataItemLink = "Document Type" = SalesHeader."Document Type", "Document No." = SalesHeader."No.";
                column(postingDate; "Posting Date") { }
                column(salesLineDocumentType; "Document Type") { }
                column(type; Type) { }
                column(description; Description) { }
                column(documentNo; "Document No.") { }
                column(lineNo; "Line No.") { }
                column(itemNo; "No.") { }
                column(locationCode; "Location Code") { }
                column(quantityBase; "Quantity (Base)") { }
                column(outstandingQtyBase; "Outstanding Qty. (Base)") { }
                column(outstandingAmountLCY; "Outstanding Amount (LCY)") { }
                column(amount; Amount) { }
                column(unitCostLCY; "Unit Cost (LCY)") { }
                column(outstandingQuantity; "Outstanding Quantity") { }
                column(returnReasonCode; "Return Reason Code") { }
                column(shipmentDate; "Shipment Date") { }
                column(plannedShipmentDate; "Planned Shipment Date") { }
                column(plannedDeliveryDate; "Planned Delivery Date") { }
                column(requestedDeliveryDate; "Requested Delivery Date") { }
                column(promisedDeliveryDate; "Promised Delivery Date") { }
                column(dimensionSetID; "Dimension Set ID") { }
                column(returnQtyRcdNotInvd; "Return Qty. Rcd. Not Invd.") { }
                column(returnQtyReceivedBase; "Return Qty. Received (Base)") { }
                column(returnQtyToReceiveBase; "Return Qty. to Receive (Base)") { }
                column(returnRcdNotInvdLCY; "Return Rcd. Not Invd. (LCY)") { }
                column(quantityShippedBase; "Qty. Shipped (Base)") { }
                column(quantityToShipBase; "Qty. to Ship (Base)") { }
                column(qtyShippedNotInvdBase; "Qty. Shipped Not Invd. (Base)") { }
                column(shippedNotInvoicedLCYNoVAT; "Shipped Not Inv. (LCY) No VAT") { }
                column(shippedNotInvoiced; "Shipped Not Invoiced") { }
                column(quantityInvoiced; "Quantity Invoiced") { }
                column(projectNo; "Job No.") { }
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
            CurrQuery.SetFilter(orderDate, DateFilterText);
    end;
}