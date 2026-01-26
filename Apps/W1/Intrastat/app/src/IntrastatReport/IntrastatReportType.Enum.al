// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4813 "Intrastat Report Type"
{
    Extensible = true;
    value(0; Purchases) { Caption = 'Purchases'; }
    value(1; Sales) { Caption = 'Sales'; }
}