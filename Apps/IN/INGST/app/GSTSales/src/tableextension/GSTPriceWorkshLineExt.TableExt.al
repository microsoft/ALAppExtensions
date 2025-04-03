// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Pricing.PriceList;
using Microsoft.Pricing.Worksheet;

tableextension 18164 "GST Price Worksh. Line Ext" extends "Price Worksheet Line"
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
