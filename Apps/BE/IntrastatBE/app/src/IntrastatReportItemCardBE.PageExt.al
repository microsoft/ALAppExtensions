// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

pageextension 11348 "Intrastat Report Item Card BE" extends "Item Card"
{
    layout
    {
        modify("Supplementary Unit of Measure")
        {
            Visible = false;
            Enabled = false;
        }
    }
}