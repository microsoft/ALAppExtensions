// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Service.Document;
using Microsoft.Inventory.Item;

tableextension 6616 "FS Service Line" extends "Service Line"
{
    fields
    {
        field(12000; "Item Type"; Enum "Item Type")
        {
            Caption = 'Item Type';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Type where("No." = field("No.")));
        }
    }
}
