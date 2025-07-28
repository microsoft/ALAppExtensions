// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30157 "Shpfy Metafield Weight Type"
{
    Access = Internal;

    value(0; Kilograms)
    {
        Caption = 'kg';
    }

    value(1; Grams)
    {
        Caption = 'g';
    }

    value(2; Pounds)
    {
        Caption = 'lb';
    }

    value(3; Ounces)
    {
        Caption = 'oz';
    }
}