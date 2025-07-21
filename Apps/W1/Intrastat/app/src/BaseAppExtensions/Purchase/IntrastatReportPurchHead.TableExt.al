// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Address;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

tableextension 4817 "Intrastat Report Purch. Head." extends "Purchase Header"
{
    fields
    {
        modify("Buy-from Vendor No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateIntrastatFields(FieldNo("Buy-from Vendor No."));
            end;
        }
        modify("Pay-to Vendor No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateIntrastatFields(FieldNo("Pay-to Vendor No."));
            end;
        }
    }

    procedure IsIntrastatTransaction(): Boolean
    var
        CountryRegion: Record "Country/Region";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeCheckIsIntrastatTransaction(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if IsCreditDocType() then
            exit(CountryRegion.IsIntrastat("VAT Country/Region Code", true));

        if "VAT Country/Region Code" = "Ship-to Country/Region Code" then
            exit(false);

        if CountryRegion.IsLocalCountry("Ship-to Country/Region Code", true) then
            exit(CountryRegion.IsIntrastat("VAT Country/Region Code", true));

        exit(CountryRegion.IsIntrastat("Ship-to Country/Region Code", true));
    end;

    internal procedure ShipOrReceiveInventoriableTypeItems(): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", "Document Type");
        PurchaseLine.SetRange("Document No.", "No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        if PurchaseLine.FindSet() then
            repeat
                if ((PurchaseLine."Qty. to Receive" <> 0) or (PurchaseLine."Return Qty. to Ship" <> 0)) and PurchaseLine.IsInventoriableItem() then
                    exit(true);
            until PurchaseLine.Next() = 0;
    end;

    internal procedure CheckIntrastatMandatoryFields()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if Rec.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not (Rec.Ship or Rec.Receive) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if IsIntrastatTransaction() and ShipOrReceiveInventoriableTypeItems() then begin
            if IntrastatReportSetup."Transaction Type Mandatory" then
                TestField("Transaction Type");
            if IntrastatReportSetup."Transaction Spec. Mandatory" then
                TestField("Transaction Specification");
            if IntrastatReportSetup."Transport Method Mandatory" then
                TestField("Transport Method");
            if IntrastatReportSetup."Shipment Method Mandatory" then
                TestField("Shipment Method Code");
        end;
    end;

    local procedure UpdateIntrastatFields(FieldNo: Integer)
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Vendor: Record Vendor;
        VendorNo: Code[20];
        IsHandled: Boolean;
    begin
        OnBeforeUpdateIntrastatFields(Rec, FieldNo, IsHandled);
        if IsHandled then
            exit;

        if IsTemporary() then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        case true of
            (IntrastatReportSetup."Purch. Intrastat Info Based On" = IntrastatReportSetup."Purch. Intrastat Info Based On"::"Buy-from Vendor") and
            (FieldNo = FieldNo("Buy-from Vendor No.")):
                VendorNo := "Buy-from Vendor No.";
            (IntrastatReportSetup."Purch. Intrastat Info Based On" = IntrastatReportSetup."Purch. Intrastat Info Based On"::"Pay-to Vendor") and
            (FieldNo = FieldNo("Pay-to Vendor No.")):
                VendorNo := "Pay-to Vendor No.";
            else
                exit;
        end;

        if Vendor.Get(VendorNo) then begin
            Validate("Transport Method", Vendor."Def. Transport Method");
            if "Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"] then
                if Vendor."Default Trans. Type - Return" <> '' then
                    Validate("Transaction Type", Vendor."Default Trans. Type - Return")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Return")
            else
                if Vendor."Default Trans. Type" <> '' then
                    Validate("Transaction Type", Vendor."Default Trans. Type")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Purchase");
        end else begin
            Validate("Transport Method", '');
            Validate("Transaction Type", '');
        end;

        OnAfterUpdateIntrastatFields(Rec, Vendor, IntrastatReportSetup, FieldNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateIntrastatFields(var PurchaseHeader: Record "Purchase Header"; FieldNo: Integer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateIntrastatFields(var PurchaseHeader: Record "Purchase Header"; var Vendor: Record Vendor; var IntrastatReportSetup: Record "Intrastat Report Setup"; FieldNo: Integer);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckIsIntrastatTransaction(PurchaseHeader: Record "Purchase Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}