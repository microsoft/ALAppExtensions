// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 31180 "Vendor Templ. Card CZL" extends "Vendor Templ. Card"
{
    layout
    {
        addafter("Validate EU Vat Reg. No.")
        {
            field("Validate Registration No. CZL"; Rec."Validate Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the registration number has been validated by registration number validation service.';
            }
        }
    }
}
