// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Contact State (ID 30107).
/// </summary>
enum 30148 "Shpfy Default Cont. Permission"
{
    Caption = 'Shopify Default Contact Permission';
    Extensible = false;

    value(0; "No permission")
    {
        Caption = 'No permission';
    }
    value(1; "Ordering only")
    {
        Caption = 'Ordering only';
    }
    value(2; "Location admin")
    {
        Caption = 'Location admin';
    }
}