// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4825 "Intr. Report Purch. Info Base"
{
    Extensible = true;
    value(0; "Buy-from Vendor") { Caption = 'Buy-from Vendor'; }
    value(1; "Pay-to Vendor") { Caption = 'Pay-to Vendor'; }
}