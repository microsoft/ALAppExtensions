// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 11150 "Intrastat Report Subform AT" extends "Intrastat Report Subform"
{
    layout
    {
        modify("Area")
        {
            Visible = true;
        }

        modify("Transaction Specification")
        {
            Visible = true;
        }

        modify("Transport Method")
        {
            Visible = false;
        }
    }
}