// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30156 "Shpfy Metafield Owner Type" implements "Shpfy IMetafield Owner Type"
{
    value(0; Customer)
    {
        Caption = 'Customer';
        Implementation = "Shpfy IMetafield Owner Type" = "Shpfy Metafield Owner Customer";
    }

    value(1; Product)
    {
        Caption = 'Product';
        Implementation = "Shpfy IMetafield Owner Type" = "Shpfy Metafield Owner Product";
    }

    value(2; ProductVariant)
    {
        Caption = 'Variant';
        Implementation = "Shpfy IMetafield Owner Type" = "Shpfy Metafield Owner Variant";
    }

    value(3; Company)
    {
        Caption = 'Company';
        Implementation = "Shpfy IMetafield Owner Type" = "Shpfy Metafield Owner Company";
    }
}