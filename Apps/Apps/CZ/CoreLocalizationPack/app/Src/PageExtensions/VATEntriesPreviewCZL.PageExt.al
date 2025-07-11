// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Ledger;

using Microsoft.Finance.VAT.Calculation;

pageextension 11759 "VAT Entries Preview CZL" extends "VAT Entries Preview"
{
    layout
    {
        addafter("Posting Date")
        {
            field("VAT Reporting Date CZL"; Rec."VAT Reporting Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date used to include entries on VAT reports in a VAT period. This is either the date that the document was created or posted, depending on your setting on the General Ledger Setup page.';
                Visible = VATDateEnabled;
            }
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT entry''s Original Document VAT Date.';
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
        addbefore("VAT Calculation Type")
        {
            field("Unrealized Amount CZL"; Rec."Unrealized Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the unrealized amount of the VAT entry.';
                Visible = false;
            }
            field("Unrealized Base CZL"; Rec."Unrealized Base")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the unrealized base of the VAT entry.';
                Visible = false;
            }
            field("Remaining Unrealized Amount CZL"; Rec."Remaining Unrealized Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the remaining unrealized amount of the VAT entry.';
                Visible = false;
            }
            field("Remaining Unrealized Base CZL"; Rec."Remaining Unrealized Base")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the remaining unrealized base of the VAT entry.';
                Visible = false;
            }
        }
        addafter("EU Service")
        {
            field("VAT Settlement No. CZL"; Rec."VAT Settlement No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the document number which the VAT entries were closed.';
            }
            field("VAT Ctrl. Report Line No. CZL"; Rec."VAT Ctrl. Report Line No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT control report line number of the VAT control line that the entry is linked to.';
            }
        }
        addafter("EU 3-Party Trade")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the entry was part of a 3-party intermediate role.';
            }
        }
        addlast(Control1)
        {
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
        VATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
        NonDeductibleVATVisible := NonDeductibleVATCZL.IsNonDeductibleVATEnabled();
    end;

    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        VATDateEnabled: Boolean;
        NonDeductibleVATVisible: Boolean;
}
