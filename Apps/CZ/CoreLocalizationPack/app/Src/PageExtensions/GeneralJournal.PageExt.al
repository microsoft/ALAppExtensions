// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;
#if not CLEAN22
using Microsoft.Finance.VAT.Calculation;
#endif

pageextension 11722 "General Journal CZL" extends "General Journal"
{
    layout
    {
#if not CLEAN22
        modify("VAT Reporting Date")
        {
            Visible = ReplaceVATDateEnabled and VATDateEnabled and (not IsSimplePage);
        }
#endif
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
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT date of the original document.';
                Visible = false;
            }
        }
        addafter("Account No.")
        {
            field("Posting Group CZL"; Rec."Posting Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the posting group that will be used in posting the journal line. The field is used only if the account type is either customer or vendor.';
            }
        }
        addafter(Correction)
        {
            field("Original Doc. Partner Type CZL"; Rec."Original Doc. Partner Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of partner (customer or vendor). It''s possible for VAT Control Report.';
            }
            field("Original Doc. Partner No. CZL"; Rec."Original Doc. Partner No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of partner (customer or vendor). It''s possible for VAT Control Report.';
            }
            field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the detail information for payment.';
                Visible = false;
            }
            field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Bank Account Code CZL"; Rec."Bank Account Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code to idenfity bank account of company.';
                Visible = false;
            }
            field("Bank Account No. CZL"; Rec."Bank Account No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number used by the bank for the bank account.';
                Visible = false;
            }
            field("Transit No. CZL"; Rec."Transit No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a bank identification number of your own choice.';
                Visible = false;
            }
            field("IBAN CZL"; Rec."IBAN CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bank account''s international bank account number.';
            }
            field("SWIFT Code CZL"; Rec."SWIFT Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the international bank identifier code (SWIFT) of the bank where you have the account.';
                Visible = false;
            }
        }
    }
#if not CLEAN22
    trigger OnOpenPage()
    begin
        VATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
        ReplaceVATDateEnabled := ReplaceVATDateMgtCZL.IsEnabled();
    end;

    var
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        ReplaceVATDateEnabled: Boolean;
        VATDateEnabled: Boolean;
#endif
}
