// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

enumextension 139614 "Shpfy Bulk Operation Type" extends "Shpfy Bulk Operation Type"
{
    value(139614; AddProduct)
    {
        Caption = 'Add Product';
        Implementation = "Shpfy IBulk Operation" = "Shpfy Mock Bulk ProductCreate";
    }
}