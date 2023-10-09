// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

pageextension 27038 "DIOT VAT Posting Setup" extends "VAT Posting Setup"
{
    layout
    {
        addafter("VAT Calculation Type")
        {
            field("DIOT WHT %"; "DIOT WHT %")
            {
                ApplicationArea = BasicMX;
                ToolTip = 'Specifies the withholding tax percentage to be used with this VAT posting setup when exporting the DIOT report. Important: This field only affects the DIOT report.';
            }
        }
    }
}
