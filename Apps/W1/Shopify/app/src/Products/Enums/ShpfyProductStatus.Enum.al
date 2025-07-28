// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Product Status (ID 30130).
/// </summary>
enum 30130 "Shpfy Product Status"
{
    Caption = 'Shopify Product Status';
    Extensible = false;

    value(0; Active)
    {
        Caption = 'Active';
    }
    value(1; Archived)
    {
        Caption = 'Archived';
    }
    value(2; Draft)
    {
        Caption = 'Draft';
    }

}
