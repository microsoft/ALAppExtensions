// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Document;

pageextension 6790 "WHT Purch. Cr. Memo Subform" extends "Purch. Cr. Memo Subform"
{
    layout
    {
        addafter("VAT Prod. Posting Group")
        {
            field("Wthldg. Tax Bus. Post. Group"; Rec."Wthldg. Tax Bus. Post. Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Withholding Tax Business Posting Group is assigned from the Purchase Header Table and is used for all the Withholding Tax calculations.';
                Visible = false;
            }
            field("Wthldg. Tax Prod. Post. Group"; Rec."Wthldg. Tax Prod. Post. Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Withholding Tax Product Posting Group is assigned from the Product Entity selected in Purchase Line.';
                Visible = false;
            }
        }
    }
}