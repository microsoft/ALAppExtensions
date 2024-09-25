// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN25
namespace Microsoft.Sales.Pricing;

pageextension 18152 "GST Sales Prices Ext" extends "Sales Prices"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
#pragma warning disable AS0072
    ObsoleteTag = '19.0';
#pragma warning restore AS0072

    layout
    {
        addafter("Price Includes VAT")
        {
            field("Price Inclusive of Tax"; Rec."Price Inclusive of Tax")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if prices are Inclusive of tax on the line.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
#pragma warning disable AS0072
                ObsoleteTag = '19.0';
#pragma warning restore AS0072
            }
        }
    }
}
#endif
