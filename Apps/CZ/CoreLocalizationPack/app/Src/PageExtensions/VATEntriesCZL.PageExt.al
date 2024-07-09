// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Ledger;

using Microsoft.Finance.VAT.Calculation;

pageextension 11755 "VAT Entries CZL" extends "VAT Entries"
{
    layout
    {
        addafter("VAT Reporting Date")
        {
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT entry''s Original Document VAT Date.';
            }
        }
        addafter("Posting Date")
        {
            field("VAT Settlement No. CZL"; Rec."VAT Settlement No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the document number which the VAT entries were closed.';
                Visible = false;
            }
        }
        addafter("Document No.")
        {
            field("External Document No. CZL"; Rec."External Document No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number that the vendor uses on the invoice they sent to you or number of receipt.';
            }
        }
        addafter("VAT Registration No.")
        {
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer or vendor.';
                Visible = false;
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the customer or vedor.';
                Visible = false;
            }
        }
        addafter("EU 3-Party Trade")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies when the VAT entry will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
        }
        addlast(Control1)
        {
            field("VAT Ctrl. Report No. CZL"; Rec."VAT Ctrl. Report No. CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies vat control report no.';
            }
            field("VAT Ctrl. Report Line No. CZL"; Rec."VAT Ctrl. Report Line No. CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the number of line in the VAT control report.';
            }
            field("VAT Identifier CZL"; Rec."VAT Identifier CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code to group various VAT posting setups with similar attributes, for example VAT percentage.';
                Visible = false;
            }
            field("Deductible VAT Base CZL"; Rec.CalcDeductibleVATBaseCZL())
            {
                Caption = 'Deductible VAT Base';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT base increased by the amount of unapplied input VAT.';
                Visible = NonDeductibleVATVisible;
            }
            field("Original VAT Base CZL"; Rec."Original VAT Base CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT base of the entry before the deduction by the coefficient.';
                Visible = NonDeductibleVATVisible;
            }
            field("Original VAT Amount CZL"; Rec."Original VAT Amount CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT amount of the entry before the deduction by the coefficient.';
                Visible = NonDeductibleVATVisible;
            }
            field("Non-Deductible VAT % CZL"; Rec."Non-Deductible VAT %")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the percentage of non-deductible VAT applied to the entry.';
                Visible = NonDeductibleVATVisible;
            }
            field("Original VAT Entry No. CZL"; Rec."Original VAT Entry No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies Entry No. of VAT Entry to which the current VAT Entry relates. If the value in the field is non-zero then the entry has been posted in relation to non-deductible VAT. If the value in the field ''Original Entry No.'' is the same as ''Entry No.'' then the entry has been created by posting the primary document. If the numbers do not match then it is posting of the difference between advance and settlement coefficient at the end of the accounting period.';
                Visible = NonDeductibleVATVisible;
            }
        }
    }
    trigger OnOpenPage()
    begin
        NonDeductibleVATVisible := NonDeductibleVATCZL.IsNonDeductibleVATEnabled();
    end;

    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
        NonDeductibleVATVisible: Boolean;
}
