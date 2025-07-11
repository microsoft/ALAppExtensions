// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;
using Microsoft.Inventory.Item;

pageextension 7331 "Item Card Ext." extends "Item Card"
{
    actions
    {
        addlast(Category_Category4)
        {
            actionref(Substitution_Promoted; "Substituti&ons") { }
        }
    }
}