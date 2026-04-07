// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.History;

pageextension 6798 "Withholding Posted Purch Inv" extends "Posted Purchase Invoice"
{
    layout
    {
        addlast("Shipping and Payment")
        {
            field("WHT Actual Vendor No."; Rec."WHT Actual Vendor No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the number of the Withholding Actual Vendor who delivers the products.';
                Importance = Additional;
            }
        }
    }
}