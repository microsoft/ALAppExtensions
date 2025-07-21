// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Pricing.PriceList;

tableextension 18163 "GST Price List Line Ext" extends "Price List Line"
{
    fields
    {
        field(18141; "Price Inclusive of Tax"; boolean)
        {
            Caption = 'Price Inclusive of Tax';
            DataClassification = CustomerContent;
        }
    }
}
