// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Target Selection (ID 30120).
/// </summary>
enum 30120 "Shpfy Target Selection"
{
    Access = Internal;
    Caption = 'Shopify Target Selection';
    Extensible = true;

    value(0; All)
    {
        Caption = 'All';
    }
    value(1; Entitled)
    {
        Caption = 'Entitled';
    }
    value(3; Explicit)
    {
        Caption = 'Explicit';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}
