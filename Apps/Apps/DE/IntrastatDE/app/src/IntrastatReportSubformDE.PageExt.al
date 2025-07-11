// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 11029 "Intrastat Report Subform DE" extends "Intrastat Report Subform"
{
    layout
    {
        modify("Area")
        {
            Visible = true;
        }
    }
}
