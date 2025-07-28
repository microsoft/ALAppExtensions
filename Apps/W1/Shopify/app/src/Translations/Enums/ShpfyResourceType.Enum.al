// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30161 "Shpfy Resource Type" implements "Shpfy ICreate Translation"
{
    Access = Internal;
    Caption = 'Shopify  Resource Type';
    Extensible = false;

    value(0; Product)
    {
        Caption = 'Product';
        Implementation = "Shpfy ICreate Translation" = "Shpfy Create Transl. Product";
    }
}