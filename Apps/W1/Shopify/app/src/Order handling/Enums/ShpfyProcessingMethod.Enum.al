// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Processing Method (ID 30118).
/// </summary>
enum 30118 "Shpfy Processing Method"
{
    Caption = 'Shopify Processing Method';
    Extensible = false;

    value(0; Checkout)
    {
        Caption = 'Checkout';
    }
    value(1; Direct)
    {
        Caption = 'Direct';
    }
    value(2; Manual)
    {
        Caption = 'Manual';
    }
    value(3; Offsite)
    {
        Caption = 'Offsite';
    }
    value(4; Express)
    {
        Caption = 'Express';
    }
    value(5; Free)
    {
        Caption = 'Free';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}
