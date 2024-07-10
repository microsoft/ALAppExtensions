// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.VAT.Calculation;

pageextension 31230 "VAT Setup CZL" extends "VAT Setup"
{
    actions
    {
        addlast(VATReporting)
        {
            action("Non-Deductible VAT Setup CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Non-Deductible VAT Setup';
                Image = VATPostingSetup;
                RunObject = Page "Non-Deductible VAT Setup CZL";
                ToolTip = 'Set up VAT coefficient correction.';
                Visible = NonDeductibleVATVisible;
            }
        }
    }

    trigger OnOpenPage()
    begin
        NonDeductibleVATVisible := NonDeductibleVAT.IsNonDeductibleVATEnabled();
    end;

    var
        NonDeductibleVAT: Codeunit "Non-Deductible VAT";
        NonDeductibleVATVisible: Boolean;
}
