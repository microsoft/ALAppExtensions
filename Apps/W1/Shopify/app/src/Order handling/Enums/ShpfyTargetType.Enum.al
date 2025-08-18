// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Target Type (ID 30121).
/// </summary>
enum 30121 "Shpfy Target Type"
{
    Access = Internal;
    Caption = 'Shopify Target Type';

    value(2; "Line Item")
    {
        Caption = 'Line Item';
    }
    value(3; "Shipping Line")
    {
        Caption = 'Shipping Line';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}
