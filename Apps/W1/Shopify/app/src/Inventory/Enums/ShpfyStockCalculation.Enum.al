// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Inventory Policy (ID 30135).
/// </summary>
enum 30135 "Shpfy Stock Calculation" implements "Shpfy Stock Calculation", "Shpfy IStock Available"
{
    Caption = 'Shopify Stock Calculation"';
    Extensible = true;
    DefaultImplementation = "Shpfy Stock Calculation" = "Shpfy Disabled Value",
                            "Shpfy IStock Available" = "Shpfy Can Not Have Stock";
    value(0; Disabled)
    {
        Caption = 'Off';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Disabled Value",
                         "Shpfy IStock Available" = "Shpfy Can Not Have Stock";
    }

    value(1; "Projected Available Balance Today")
    {
        Caption = 'Projected Available Balance at Today';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Balance Today",
                         "Shpfy IStock Available" = "Shpfy Can Have Stock";
    }
    value(2; "Non-reserved Inventory")
    {
        Caption = 'Free Inventory (not reserved)';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Free Inventory",
                         "Shpfy IStock Available" = "Shpfy Can Have Stock";
    }
}

