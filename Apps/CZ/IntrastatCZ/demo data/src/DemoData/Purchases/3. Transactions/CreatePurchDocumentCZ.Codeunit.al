// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.DemoData.Inventory;
using Microsoft.DemoTool.Helpers;
using Microsoft.Purchases.Document;

codeunit 11711 "Create Purch. Document CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateOpenPurchaseDocuments();
    end;

    local procedure CreateOpenPurchaseDocuments()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ContosoPurchase: Codeunit "Contoso Purchase";
        CreateVendor: Codeunit "Create Vendor";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateItem: Codeunit "Create Item";
        CreatePurchaseDocument: Codeunit "Create Purchase Document";
        CreateLocation: Codeunit "Create Location";
    begin
        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), CreatePurchaseDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19030704D), ContosoUtilities.AdjustDate(19030704D), ContosoUtilities.AdjustDate(19030704D), '', CreateLocation.MainLocation(), '', '5879', ContosoUtilities.AdjustDate(19030704D), '');
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AthensDesk(), 10);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Direct Unit Cost", Round(PurchaseLine."Direct Unit Cost" * PurchaseHeader."Currency Factor"));
            PurchaseLine.Modify(true);
        end;
    end;
}