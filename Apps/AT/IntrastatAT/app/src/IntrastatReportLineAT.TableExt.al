// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;

tableextension 11150 "Intrastat Report Line AT" extends "Intrastat Report Line"
{
    fields
    {
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
                CompanyInfo: Record "Company Information";
                Item: Record Item;
                FixedAsset: Record "Fixed Asset";
                ItemFAOrigCountryCode: Code[10];
            begin
                if Type = Type::Receipt then begin
                    CompanyInfo.Get();
                    if ("Source Type" = "Source Type"::"FA Entry") then begin
                        FixedAsset.Get("Item No.");
                        ItemFAOrigCountryCode := FixedAsset."Country/Region of Origin Code";
                    end else begin
                        Item.Get("Item No.");
                        ItemFAOrigCountryCode := Item."Country/Region of Origin Code";
                    end;

                    if (ItemFAOrigCountryCode = CompanyInfo."Ship-to Country/Region Code") or
                        (ItemFAOrigCountryCode = '')
                    then
                        "Country/Region of Origin Code" := "Country/Region Code"
                    else
                        "Country/Region of Origin Code" := ItemFAOrigCountryCode;
                end;
            end;
        }

        modify("Partner VAT ID")
        {
            trigger OnBeforeValidate()
            begin
                if "Partner VAT ID" <> '' then
                    TestField(Type, Type::Shipment);
            end;
        }
        modify("Transaction Type")
        {
            Caption = 'Nature of Transaction';
        }
    }
}