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
            field("Withholding Tax Liable"; Rec."Withholding Tax Liable")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the vendor is liable for withholding tax.';

                trigger OnValidate()
                begin
                    Rec.TestField("Wthldg. Tax Bus. Post. Group", '');
                    IsWithholdingTaxLiable();
                end;
            }
            field("Wthldg. Tax Bus. Post. Group"; Rec."Wthldg. Tax Bus. Post. Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the withholding tax business posting group for the vendor.';
                Enabled = IsWHTLiable;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsWithholdingTaxLiable();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsWithholdingTaxLiable();
    end;

    local procedure IsWithholdingTaxLiable()
    begin
        if Rec."Withholding Tax Liable" then
            IsWHTLiable := true
        else
            IsWHTLiable := false;
    end;

    var
        IsWHTLiable: Boolean;
}