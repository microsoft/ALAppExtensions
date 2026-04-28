// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Purchases.Vendor;

pageextension 10973 "E-Reporting Vendor Card FR" extends "Vendor Card"
{
    layout
    {
        addafter("VAT Registration No.")
        {
            field("FR E-Reporting Trans. Type"; Rec."FR E-Reporting Trans. Type")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'E-Reporting Transaction Type';
                ToolTip = 'Specifies the transaction type for French e-reporting. This determines how transactions for this vendor are categorized in the e-reporting file sent to the tax authorities.';
            }
        }
    }
}
