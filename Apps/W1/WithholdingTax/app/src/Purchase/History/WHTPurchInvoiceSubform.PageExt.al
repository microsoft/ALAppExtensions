// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Document;

pageextension 6789 "WHT Purch. Invoice Subform" extends "Purch. Invoice Subform"
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
        addafter("Line Amount")
        {
            field("Withholding Tax Absorb Base"; Rec."Withholding Tax Absorb Base")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Amount when you want Withholding Tax to be calculated on the Amount other than the Line Amount.';
            }
        }
    }
}