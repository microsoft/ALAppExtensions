// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 11426 "Intrastat Report Subform NL" extends "Intrastat Report Subform"
{
    layout
    {
        modify("Transaction Specification")
        {
            Visible = true;
        }
    }
}