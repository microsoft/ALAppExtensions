// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4823 "Intr. Rep. Purch. VAT No. Base"
{
    Extensible = true;
    value(0; "Buy-from VAT") { Caption = 'Buy-from Vendor'; }
    value(1; "Pay-to VAT") { Caption = 'Pay-to Vendor'; }
    value(2; Document) { Caption = 'Document'; }
}