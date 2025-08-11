// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Value Type (ID 30123).
/// </summary>
enum 30123 "Shpfy Value Type"
{
    Access = Internal;
    Caption = 'Shopify Value Type';
    Extensible = true;

    value(3; "Fixed Amount")
    {
        Caption = 'Fixed Amount';
    }
    value(4; "Percentage")
    {
        Caption = 'Percentage';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}
