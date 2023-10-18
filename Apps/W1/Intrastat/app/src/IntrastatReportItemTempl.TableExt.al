// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

tableextension 4820 "Intrastat Report Item Templ." extends "Item Templ."
{
    fields
    {
        field(4810; "Exclude from Intrastat Report"; Boolean)
        {
            Caption = 'Exclude from Intrastat Report';
            trigger OnValidate()
            begin
                ValidateItemField(FieldNo("Exclude from Intrastat Report"));
            end;
        }
    }
}