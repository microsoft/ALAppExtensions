// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;

codeunit 5689 "Create Posted Purchase Data"
{
    trigger OnRun()
    var
        PurchHeader: Record "Purchase Header";
        CreatePurchaseDocument: Codeunit "Create Purchase Document";
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);
        PurchHeader.SetFilter("Your Reference", '<>%1', CreatePurchaseDocument.OpenYourReference());
        if PurchHeader.FindSet() then
            repeat
                PurchHeader.Validate(Invoice, true);
                PurchHeader.Validate(Receive, true);
                Codeunit.Run(Codeunit::"Purch.-Post", PurchHeader);
            until PurchHeader.Next() = 0;
    end;
}
