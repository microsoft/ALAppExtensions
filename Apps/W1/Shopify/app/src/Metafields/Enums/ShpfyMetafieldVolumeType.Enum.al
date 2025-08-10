// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30158 "Shpfy Metafield Volume Type"
{
    Access = Internal;

    value(0; Milliliters)
    {
        Caption = 'ml';
    }

    value(1; Centiliters)
    {
        Caption = 'cl';
    }

    value(2; Liters)
    {
        Caption = 'L';
    }
    value(3; "Cubic Meters")
    {
        Caption = 'm3';
    }

    value(4; "Fluid Ounces")
    {
        Caption = 'fl oz';
    }

    value(5; Pints)
    {
        Caption = 'pt';
    }
    value(6; Quarts)
    {
        Caption = 'qt';
    }
    value(7; Gallons)
    {
        Caption = 'gal';
    }
    value(8; "Imperial Fluid Ounces")
    {
        Caption = 'imp fl oz';
    }
    value(9; "Imperial Pints")
    {
        Caption = 'imp pt';
    }
    value(10; "Imperial Quarts")
    {
        Caption = 'imp qt';
    }
    value(11; "Imperial Gallons")
    {
        Caption = 'imp gal';
    }
}