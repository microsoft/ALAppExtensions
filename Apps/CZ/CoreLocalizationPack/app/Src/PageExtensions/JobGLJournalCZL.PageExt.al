// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Project.Journal;

using Microsoft.Finance.VAT.Calculation;

pageextension 31211 "Job G/L Journal CZL" extends "Job G/L Journal"
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
                ToolTip = 'Specifies the VAT date of the original document.';
                Visible = false;
            }
        }
        addafter("Account No.")
        {
            field("Posting Group CZL"; Rec."Posting Group")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the posting group that will be used in posting the journal line.The field is used only if the account type is either customer or vendor.';
                Visible = false;
            }
        }
        addbefore(Amount)
        {
            field("Correction CZL"; Rec.Correction)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the entry as a corrective entry. You can use the field if you need to post a corrective entry to an account.';
                Visible = false;
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
