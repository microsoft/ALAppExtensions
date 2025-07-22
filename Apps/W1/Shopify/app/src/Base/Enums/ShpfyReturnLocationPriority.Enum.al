// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30162 "Shpfy Return Location Priority"
{
    Access = Public;
    Extensible = false;

    value(0; "Default Return Location")
    {
        Caption = 'Default Return Location';
    }
    value(1; "Original -> Default Location")
    {
        Caption = 'Original -> Default Location';
    }
}