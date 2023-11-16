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
#if not CLEAN22
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Date (Obsolete)';
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Replaced by VAT Reporting Date.';
                Visible = not ReplaceVATDateEnabled;
            }
#endif
            field("VAT Reporting Date CZL"; Rec."VAT Reporting Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date used to include entries on VAT reports in a VAT period. This is either the date that the document was created or posted, depending on your setting on the General Ledger Setup page.';
#if not CLEAN22
                Visible = ReplaceVATDateEnabled and VATDateEnabled;
#else
                Visible = VATDateEnabled;
#endif
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
    }
    trigger OnOpenPage()
    begin
        VATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
#if not CLEAN22
        ReplaceVATDateEnabled := ReplaceVATDateMgtCZL.IsEnabled();
#endif
    end;

    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
#if not CLEAN22
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
        ReplaceVATDateEnabled: Boolean;
#endif
        VATDateEnabled: Boolean;
}
