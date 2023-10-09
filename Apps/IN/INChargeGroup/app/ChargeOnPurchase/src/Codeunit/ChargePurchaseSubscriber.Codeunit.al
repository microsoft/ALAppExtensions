// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeOnPurchase;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;

codeunit 18516 "Charge Purchase Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure GenerateThirdPartyPurchaseInvoice(PurchaseHeader: Record "Purchase Header")
    begin
        GenerateThirdPartyInvoice(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure PostThridPartyPurchaseInvoice(PurchaseHeader: Record "Purchase Header")
    begin
        ThridPartyPurchaseInvoicePosting(PurchaseHeader)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateNoOnCopyFromTempPurchLine', '', false, false)]
    local procedure UpdateChargeGroupOnPurchaseLine(var PurchLine: Record "Purchase Line"; TempPurchaseLine: Record "Purchase Line" temporary; xPurchLine: Record "Purchase Line")
    begin
        UpdateChargeGroupOnPurchaseLineOnCopyDocument(PurchLine, xPurchLine);
    end;

    local procedure ThridPartyPurchaseInvoicePosting(PurchaseHeader: Record "Purchase Header")
    var
        ThirdPartyPurchaseMgmt: Codeunit "Third Party Purchase Mgmt.";
    begin
        if (PurchaseHeader."Charge Group Code" = '') or (not PurchaseHeader.Invoice) then
            exit;

        If not (PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order"]) then
            ThirdPartyPurchaseMgmt.PostThirdPartyPurchaseInvoice(PurchaseHeader);
    end;

    local procedure UpdateChargeGroupOnPurchaseLineOnCopyDocument(var PurchLine: Record "Purchase Line"; xPurchLine: Record "Purchase Line")
    begin
        PurchLine."Charge Group Code" := xPurchLine."Charge Group Code";
        PurchLine."Charge Group Line No." := xPurchLine."Charge Group Line No.";
    end;

    local procedure GenerateThirdPartyInvoice(PurchaseHeader: Record "Purchase Header")
    var
        ThirdPartyPurchaseMgmt: Codeunit "Third Party Purchase Mgmt.";
        ChargeGroupManagemnet: Codeunit "Charge Group Management";
    begin
        if PurchaseHeader."Charge Group Code" = '' then
            exit;

        if ((PurchaseHeader.Invoice) or (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice)) then begin
            ChargeGroupManagemnet.CheckChargeLinesOnDoc(PurchaseHeader);
            if not (PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order"]) then
                ThirdPartyPurchaseMgmt.GenerateThirdPartyInvoice(PurchaseHeader);
        end;
    end;
}
