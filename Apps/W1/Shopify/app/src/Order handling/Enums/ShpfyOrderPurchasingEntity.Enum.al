// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Order Purchasing Entity (ID 30150).
/// </summary>
enum 30150 "Shpfy Order Purchasing Entity"
{
    Access = Internal;
    Caption = 'Shopify Order Purchasing Entity';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
    value(2; Company)
    {
        Caption = 'Company';
    }
}
