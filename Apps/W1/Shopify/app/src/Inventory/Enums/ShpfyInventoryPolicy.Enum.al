// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Inventory Policy (ID 30125).
/// </summary>
enum 30125 "Shpfy Inventory Policy"
{
    Caption = 'Shopify Inventory Policy';
    Extensible = false;

    value(0; DENY)
    {
        Caption = 'Deny';
    }
    value(1; CONTINUE)
    {
        Caption = 'Continue';
    }

}
