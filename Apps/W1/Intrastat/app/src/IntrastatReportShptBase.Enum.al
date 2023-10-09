// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4817 "Intrastat Report Shpt. Base"
{
    Extensible = true;
    value(0; "Sell-to Country") { Caption = 'Sell-to Country'; }
    value(1; "Bill-to Country") { Caption = 'Bill-to Country'; }
    value(2; "Ship-to Country") { Caption = 'Ship-to Country'; }
}