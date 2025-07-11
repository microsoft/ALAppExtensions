// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

enum 18603 "Gate Entry Type"
{
    value(0; Inward)
    {
        Caption = 'Inward';
    }
    value(1; Outward)
    {
        Caption = 'Outward';
    }
}
