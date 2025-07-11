// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;

tableextension 11347 "Intrastat Report Line BE" extends "Intrastat Report Line"
{
    fields
    {
        modify("Item No.")
        {
            trigger OnAfterValidate()
            begin
                Validate("Tariff No.");
            end;
        }

        modify("Tariff No.")
        {
            trigger OnAfterValidate()
            var
                TariffNumber: Record "Tariff Number";
                ItemOUM: Record "Item Unit of Measure";
                UOM: Record "Unit of Measure";
            begin
                if TariffNumber.Get("Tariff No.") and (TariffNumber."Suppl. Unit of Measure" <> '') then begin
                    if not UOM.Get(TariffNumber."Suppl. Unit of Measure") then begin
                        UOM.Init();
                        UOM.Code := TariffNumber."Suppl. Unit of Measure";
                        UOM.Insert(true);
                    end;

                    if "Source Type" <> "Source Type"::"FA Entry" then
                        if not ItemOUM.Get("Item No.", UOM.Code) then begin
                            ItemOUM.Init();
                            ItemOUM.Validate("Item No.", "Item No.");
                            ItemOUM.Validate(Code, UOM.Code);
                            ItemOUM.Insert(true);
                        end;

                    Validate("Suppl. Unit of Measure", TariffNumber."Suppl. Unit of Measure");
                    Validate("Suppl. Conversion Factor", TariffNumber."Suppl. Conversion Factor");
                end;
            end;
        }
    }
}