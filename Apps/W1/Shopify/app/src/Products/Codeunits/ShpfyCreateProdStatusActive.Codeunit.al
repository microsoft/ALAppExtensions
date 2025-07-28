// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

/// <summary>
/// Codeunit Shpfy CreateProdStatusActive (ID 30172) implements Interface Shpfy.ICreateProductStatusValue.
/// </summary>
codeunit 30172 "Shpfy CreateProdStatusActive" implements "Shpfy ICreateProductStatusValue"
{
    Access = Internal;

    /// <summary>
    /// GetStatus.
    /// </summary>
    /// <param name="Item">Record Item.</param>
    /// <returns>Return value of type enum "Shopify Product Status".</returns>
    internal procedure GetStatus(Item: Record Item): enum "Shpfy Product Status";
    begin
        exit(Enum::"Shpfy Product Status"::Active);
    end;
}
