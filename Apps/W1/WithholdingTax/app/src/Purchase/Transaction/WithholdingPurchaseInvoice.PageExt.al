// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Document;

pageextension 6797 "Withholding Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addlast("Shipping and Payment")
        {
            field("WHT Actual Vendor No."; Rec."WHT Actual Vendor No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the Withholding Actual Vendor who delivers the products.';
                Importance = Additional;
            }
        }
    }
}