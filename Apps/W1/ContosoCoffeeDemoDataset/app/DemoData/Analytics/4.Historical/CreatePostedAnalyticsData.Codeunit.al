// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Analytics;

using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;

codeunit 5698 "Create Posted Analytics Data"
{
    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        CreateExtendedSalesDocument: Codeunit "Create Extended Sales Document";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("Your Reference", CreateExtendedSalesDocument.AnalyticsReference());
        if SalesHeader.Findset() then
            repeat
                SalesHeader.Validate(Invoice, true);
                SalesHeader.Validate(Ship, true);
                Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
            until SalesHeader.Next() = 0;
    end;

    procedure PostPurchaseOrdersForAnalytics()
    var
        PurchHeader: Record "Purchase Header";
        CreatePurchaseDocument: Codeunit "Create Extended Purch Document";
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("Your Reference", CreatePurchaseDocument.AnalyticsReference());
        if PurchHeader.FindSet() then
            repeat
                PurchHeader.Validate(Invoice, true);
                PurchHeader.Validate(Receive, true);
                Codeunit.Run(Codeunit::"Purch.-Post", PurchHeader);
            until PurchHeader.Next() = 0;
    end;
}