// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

tableextension 31268 "Item Entry Relation CZA" extends "Item Entry Relation"
{
    fields
    {
        field(31071; "Undo CZA"; Boolean)
        {
            Caption = 'Undo';
            DataClassification = CustomerContent;
        }
    }
}
