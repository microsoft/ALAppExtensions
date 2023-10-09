// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

pageextension 10686 "Elec. VAT Reporting Codes" extends "VAT Reporting Codes"
{
    layout
    {
        addlast(VATCodes)
        {
            field("VAT Rate For Reporting"; Rec."VAT Rate For Reporting")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT rate to report.';
            }
            field("Report VAT Rate"; Rec."Report VAT Rate")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the VAT rate value must be reported.';
            }
        }
    }
}
