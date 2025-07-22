// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Mapping Direction (ID 30101).
/// </summary>
enum 30101 "Shpfy Mapping Direction"
{
    Caption = 'Shopify Mapping Direction';
    Extensible = false;

    value(0; ShopifyToBC)
    {
        Caption = 'Shopify to BC';
    }
    value(1; BCToShopify)
    {
        Caption = 'BC to Shopify';
    }

}
