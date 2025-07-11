// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

pageextension 31179 "Customer Templ. Card CZL" extends "Customer Templ. Card"
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
