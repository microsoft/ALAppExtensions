// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

/// <summary>
/// Interface "Shpfy ICreateProductStatusValue."
/// </summary>
interface "Shpfy ICreateProductStatusValue"
{
    Access = Internal;

    /// <summary>
    /// GetStatus.
    /// </summary>
    /// <param name="Item">Record Item.</param>
    /// <returns>Return value of type Enum "Shopify Product Status".</returns>
    procedure GetStatus(Item: Record Item): Enum "Shpfy Product Status";
}
