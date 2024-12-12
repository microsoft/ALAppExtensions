// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4820 "Intrastat Report Line Type Sel"
{
    Extensible = true;
    value(0; Shipment) { Caption = 'Shipment'; }
    value(1; Receipt) { Caption = 'Receipt'; }
    value(2; Both) { Caption = 'Both'; }
}