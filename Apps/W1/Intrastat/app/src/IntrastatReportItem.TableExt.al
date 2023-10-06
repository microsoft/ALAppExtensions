// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

tableextension 4811 "Intrastat Report Item" extends Item
{
    fields
    {
        modify("Tariff No.")
        {
            trigger OnAfterValidate()
            var
                ItemUOM: Record "Item Unit of Measure";
                TariffNumber: Record "Tariff Number";
                IntrastatReportMgt: Codeunit IntrastatReportManagement;
            begin
                if "Tariff No." <> '' then begin
                    TariffNumber.Get("Tariff No.");
                    if not (TariffNumber."Suppl. Unit of Measure" in ['', "Supplementary Unit of Measure"]) then begin
                        if not ItemUOM.Get("No.", TariffNumber."Suppl. Unit of Measure") then begin
                            ItemUOM.Init();
                            ItemUOM.Validate("Item No.", "No.");
                            ItemUOM.Validate(Code, TariffNumber."Suppl. Unit of Measure");
                            ItemUOM.Insert(true);
                        end;
                        IntrastatReportMgt.UpdateItemUOM(ItemUOM, TariffNumber);
                        IntrastatReportMgt.NotifyUserAboutSupplementaryUnitUpdate();
                    end;
                    "Supplementary Unit of Measure" := TariffNumber."Suppl. Unit of Measure";
                end else
                    "Supplementary Unit of Measure" := '';
            end;
        }
        field(4810; "Exclude from Intrastat Report"; Boolean)
        {
            Caption = 'Exclude from Intrastat Report';
        }
        field(4811; "Supplementary Unit of Measure"; Code[10])
        {
            Caption = 'Supplementary Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));
        }
    }
}