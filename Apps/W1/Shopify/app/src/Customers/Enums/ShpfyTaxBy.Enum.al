// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Tax By (ID 30109).
/// </summary>
enum 30109 "Shpfy Tax By"
{
    Caption = 'Shopify Tax By';
    Extensible = false;
    value(0; "No Taxes")
    {
        Caption = 'No Taxes';
    }
    value(1; "Ship-to -> Sell-to -> Bill-to")
    {
        Caption = 'Ship-to -> Sell-to -> Bill-to';
    }
    value(2; "Ship-to -> Bill-to -> Sell-to")
    {
        Caption = 'Ship-to -> Bill-to -> Sell-to';
    }
    value(3; "Sell-to -> Ship-to -> Bill-to")
    {
        Caption = 'Sell-to -> Ship-to -> Bill-to';
    }
    value(4; "Sell-to -> Bill-to -> Ship-to")
    {
        Caption = 'Sell-to -> Bill-to -> Ship-to';
    }
    value(5; "Bill-to -> Sell-to -> Ship-to")
    {
        Caption = 'Bill-to -> Sell-to -> Ship-to';
    }
    value(6; "Bill-to Ship-to Sell-to")
    {
        Caption = 'Bill-to -> Ship-to -> Sell-to';
    }
}