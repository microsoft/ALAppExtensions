// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

using Microsoft.Finance.TaxBase;
using Microsoft.Purchases.Document;

codeunit 18081 "GST Purhase No. Series"
{
    //No Series for Purchase
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnpurchaseAfterInsertEvent(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        if not Rec.IsTemporary() then begin
            Record := Rec;
            PostingNoSeries.GetPostingNoSeriesCode(Record);
            Rec := Record;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Buy-from Vendor No.', false, false)]
    local procedure BuyFromVendor(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Buy-from Contact No.', false, false)]
    local procedure BuyfromContactNo(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Pay-to Contact No.', false, false)]
    local procedure PaytoContactNo(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'trading', false, false)]
    local procedure Purchasetrading(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Invoice Type', false, false)]
    local procedure PurchaseInvoiceType(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure PurchaseLocation(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateShortcutDimCode', '', false, false)]
    local procedure OnAfterValidateShortcutDimCode(var PurchHeader: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        PurchHeaderVariant: Variant;
    begin
        if not PurchHeader.IsTemporary() then begin
            PurchHeaderVariant := PurchHeader;
            PostingNoSeries.GetPostingNoSeriesCode(PurchHeaderVariant);
            PurchHeader := PurchHeaderVariant;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnShowDocDimOnAfterSetDimensionSetID', '', false, false)]
    local procedure OnShowDocDimOnAfterSetDimensionSetID(var PurchaseHeader: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        PurchaseHeaderVariant: Variant;
    begin
        if not PurchaseHeader.IsTemporary() then begin
            PurchaseHeaderVariant := PurchaseHeader;
            PostingNoSeries.GetPostingNoSeriesCode(PurchaseHeaderVariant);
            PurchaseHeader := PurchaseHeaderVariant;
        end;
    end;
}
