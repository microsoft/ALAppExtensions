// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.FixedAssets.FixedAsset;

pageextension 11349 "Intrastat Report FA Card BE" extends "Fixed Asset Card"
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