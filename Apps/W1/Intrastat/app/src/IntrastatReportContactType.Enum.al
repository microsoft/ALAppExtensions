// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4816 "Intrastat Report Contact Type"
{
    Extensible = true;
    value(0; " ") { Caption = ' '; }
    value(1; Contact) { Caption = 'Contact'; }
    value(2; Vendor) { Caption = 'Vendor'; }
}