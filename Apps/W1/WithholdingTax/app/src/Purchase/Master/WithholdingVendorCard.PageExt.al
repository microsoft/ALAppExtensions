// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Vendor;

pageextension 6784 "Withholding Vendor Card" extends "Vendor Card"
{
    layout
    {
        addbefore("Vendor Posting Group")
        {
            field("Wthldg. Tax Bus. Post. Group"; Rec."Wthldg. Tax Bus. Post. Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the withholding tax business posting group for the vendor.';
            }
        }
    }
}