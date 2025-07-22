// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Location;

/// <summary>
/// Report Shpfy Create Location Filter (ID 30101).
/// </summary>
report 30101 "Shpfy Create Location Filter"
{
    Caption = 'Shopify Create Location Filter';
    ProcessingOnly = true;
    UseRequestPage = true;
    UsageCategory = None;

    dataset
    {
        dataitem(Location; Location)
        {
            RequestFilterFields = Code;

            trigger OnPreDataItem()
            begin
                LocationFilter := Location.GetFilter(Code);
            end;
        }
    }

    var
        LocationFilter: Text;

    /// <summary> 
    /// Get Location Filter.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetLocationFilter(): Text
    begin
        exit(LocationFilter);
    end;
}