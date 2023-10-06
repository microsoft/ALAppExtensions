// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

reportextension 31300 "Intrastat Report Get Lines CZ" extends "Intrastat Report Get Lines"
{
    requestpage
    {
        trigger OnOpenPage()
        begin
            ShowItemCharges := true;
        end;
    }
}