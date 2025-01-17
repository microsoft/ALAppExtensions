// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Ledger;

tableextension 31300 "Intrastat Report Line CZ" extends "Intrastat Report Line"
{
    fields
    {
        field(31300; "Statistic Indication CZ"; Code[10])
        {
            Caption = 'Statistic Indication';
            DataClassification = CustomerContent;
            TableRelation = "Statistic Indication CZ".Code where("Tariff No." = field("Tariff No."));
        }
        field(31305; "Specific Movement CZ"; Code[10])
        {
            Caption = 'Specific Movement';
            DataClassification = CustomerContent;
            TableRelation = "Specific Movement CZ".Code;
        }
        field(31310; "Company VAT Reg. No. CZ"; Text[50])
        {
            Caption = 'Company VAT Reg. No.';
            DataClassification = CustomerContent;
        }
        field(31315; "Internal Note 1 CZ"; Text[40])
        {
            Caption = 'Internal Note 1';
            DataClassification = CustomerContent;
        }
        field(31316; "Internal Note 2 CZ"; Text[40])
        {
            Caption = 'Internal Note 2';
            DataClassification = CustomerContent;
        }
        field(31320; "Intrastat Delivery Group CZ"; Code[10])
        {
            Caption = 'Intrastat Delivery Group ';
            DataClassification = CustomerContent;
        }
        modify("Tariff No.")
        {
            trigger OnAfterValidate()
            begin
                "Statistic Indication CZ" := '';
            end;
        }
        modify("Item No.")
        {
            trigger OnBeforeValidate()
            var
                FixedAsset: Record "Fixed Asset";
                Item: Record Item;
            begin
                if "Source Type" = "Source Type"::"FA Entry" then begin
                    if "Item No." = '' then
                        Clear(FixedAsset)
                    else
                        FixedAsset.Get("Item No.");

                    "Statistic Indication CZ" := FixedAsset."Statistic Indication CZ";
                    "Specific Movement CZ" := FixedAsset."Specific Movement CZ";
                end else begin
                    if "Item No." = '' then
                        Clear(Item)
                    else
                        Item.Get("Item No.");

                    "Statistic Indication CZ" := Item."Statistic Indication CZ";
                    "Specific Movement CZ" := Item."Specific Movement CZ";
                end;
            end;
        }
        modify("Shpt. Method Code")
        {
            trigger OnAfterValidate()
            var
                ShipmentMethod: Record "Shipment Method";
            begin
                if "Shpt. Method Code" = '' then
                    Clear(ShipmentMethod)
                else
                    ShipmentMethod.Get("Shpt. Method Code");
                "Intrastat Delivery Group CZ" := ShipmentMethod."Intrastat Deliv. Grp. Code CZ";
            end;
        }
    }

    trigger OnAfterInsert()
    var
        PrevIntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SpecificMovementCZ: Record "Specific Movement CZ";
        IntrastatReportManagement: Codeunit IntrastatReportManagement;
    begin
        PrevIntrastatReportLine := Rec;
        if "Statistics Period" = '' then begin
            IntrastatReportHeader.Get(Rec."Intrastat No.");
            "Statistics Period" := IntrastatReportHeader."Statistics Period";
        end;
        if "Company VAT Reg. No. CZ" = '' then
            "Company VAT Reg. No. CZ" := IntrastatReportManagement.GetCompanyVATRegNo();
        if "Specific Movement CZ" = '' then begin
            SpecificMovementCZ.GetOrCreate(SpecificMovementCZ.GetStandardCode());
            "Specific Movement CZ" := SpecificMovementCZ.Code;
        end;
        if (PrevIntrastatReportLine."Statistics Period" <> "Statistics Period") or
           (PrevIntrastatReportLine."Company VAT Reg. No. CZ" <> "Company VAT Reg. No. CZ") or
           (PrevIntrastatReportLine."Specific Movement CZ" <> "Specific Movement CZ")
        then
            Modify();
    end;

    procedure CompletelyInvoiced(): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if "Source Type" = "Source Type"::"Item Entry" then begin
            ItemLedgerEntry.Get("Source Entry No.");
            exit(ItemLedgerEntry."Completely Invoiced");
        end;
        exit(true);
    end;
}