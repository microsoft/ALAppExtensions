// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Requisition;

using Microsoft.Purchases.Document;

codeunit 31437 "Req.Wksh.Make Ord. Handler CZA"
{
    Access = Internal;
    SingleInstance = true;

    var
        NoSeriesCode: Code[20];

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnBeforePurchOrderHeaderInsert', '', false, false)]
    local procedure ModifyPurchaseHeaderOnBeforePurchOrderHeaderInsert(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader."No. Series" := NoSeriesCode;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterSet', '', false, false)]
    local procedure SaveNoSeriesCodeOnAfterSet(NewPurchOrderHeader: Record "Purchase Header")
    begin
        NoSeriesCode := NewPurchOrderHeader."No. Series";
    end;
}
