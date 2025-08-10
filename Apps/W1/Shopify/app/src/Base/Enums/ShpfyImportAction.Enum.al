// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Import Action (ID 30100).
/// </summary>
enum 30100 "Shpfy Import Action"
{
    Access = Internal;
    Caption = 'Shopify Import Action';
    Extensible = true;

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; Update)
    {
        Caption = 'Update';
    }
}
