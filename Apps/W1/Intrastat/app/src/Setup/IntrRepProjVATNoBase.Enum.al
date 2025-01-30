// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4826 "Intr. Rep. Proj. VAT No. Base"
{
    Extensible = true;
    value(0; "Sell-to Customer") { Caption = 'Sell-to Customer'; }
    value(1; "Bill-to Customer") { Caption = 'Bill-to Customer'; }
}