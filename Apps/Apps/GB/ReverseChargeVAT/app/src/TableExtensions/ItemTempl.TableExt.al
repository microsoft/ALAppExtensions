// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Inventory.Item;

tableextension 10554 "Item Templ." extends "Item Templ."
{
    fields
    {
        field(10507; "Reverse Charge Applies GB"; Boolean)
        {
            Caption = 'Reverse Charge Applies';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateItemField(FieldNo("Reverse Charge Applies GB"));
            end;
        }
    }
}