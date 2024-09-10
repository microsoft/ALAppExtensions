// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

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

        if Rec.IsTemporary() then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if FieldNo = FieldNo("Buy-from Vendor No.") then
            VendorNo := IntrastatReportSetup.GetPartnerNo("Buy-from Vendor No.", "Pay-to Vendor No.", IntrastatReportSetup."VAT No. Based On"::"Sell-to VAT");

        if FieldNo = FieldNo("Pay-to Vendor No.") then
            VendorNo := IntrastatReportSetup.GetPartnerNo("Buy-from Vendor No.", "Pay-to Vendor No.", IntrastatReportSetup."VAT No. Based On"::"Bill-to VAT");

        if VendorNo = '' then
            exit;

        if Vendor.Get(VendorNo) then begin
            Validate("Transport Method", Vendor."Def. Transport Method");

            if "Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"] then
                if Vendor."Default Trans. Type - Return" <> '' then
                    Validate("Transaction Type", Vendor."Default Trans. Type - Return")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Return");

            if "Document Type" in ["Document Type"::Invoice, "Document Type"::Order] then
                if Vendor."Default Trans. Type" <> '' then
                    Validate("Transaction Type", Vendor."Default Trans. Type")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Purchase");
        end else begin
            Validate("Transport Method", Vendor."Def. Transport Method");
            Validate("Transaction Type", Vendor."Default Trans. Type");
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
}