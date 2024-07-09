// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

page 31215 "Non-Deductible VAT Setup CZL"
{
    Caption = 'Non-Deductible VAT Setup';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Non-Deductible VAT Setup CZL";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("From Date"; Rec."From Date")
                {
                    ToolTip = 'Specifies the date from which the VAT coefficient is valid.';
                }
                field("To Date"; Rec."To Date")
                {
                    ToolTip = 'Specifies the date to which the VAT coefficient is valid.';
                }
                field("Advance Coefficient"; Rec."Advance Coefficient")
                {
                    ToolTip = 'Specifies the amount of the advance coefficient for non-deductible VAT (e.g. if you can only apply VAT at 12% of the original value, set the field to 100-12 = 88).';
                }
                field("Settlement Coefficient"; Rec."Settlement Coefficient")
                {
                    ToolTip = 'Specifies the amount of the settlement coefficient for annual settlement (e.g. if you can only apply VAT at 15% of the original value, set the field to 100-15 = 85)';
                }
            }
        }
    }

    var
        NonDeductibleVATCZIsNoEnabledErr: Label 'The Non-Deductible VAT CZ feature is not enabled. Please enable it in the VAT Setup page.';

    trigger OnOpenPage()
    begin
        if not NonDeductibleVATCZL.IsNonDeductibleVATEnabled() then
            Error(NonDeductibleVATCZIsNoEnabledErr);
    end;

    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
}