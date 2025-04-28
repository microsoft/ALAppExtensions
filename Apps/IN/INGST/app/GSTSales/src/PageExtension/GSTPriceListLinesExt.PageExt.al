// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Pricing.PriceList;

pageextension 18169 "GST Price List Lines Ext" extends "Price List Lines"
{
    layout
    {
        addafter(PriceIncludesVAT)
        {
            field("Price Inclusive of Tax"; Rec."Price Inclusive of Tax")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if prices are Inclusive of tax on the line.';
            }
        }
    }
}
