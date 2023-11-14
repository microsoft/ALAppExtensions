// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.VAT.Calculation;

pageextension 11708 "General Ledger Entries CZL" extends "General Ledger Entries"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'The VAT Date will be replaced by VAT Reporting Date.';

    layout
    {
        modify("VAT Reporting Date")
        {
            Visible = ReplaceVATDateEnabled and VATDateEnabled;
        }
        addafter("Posting Date")
        {
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
        }
    }

    trigger OnOpenPage()
    begin
        VATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
        ReplaceVATDateEnabled := ReplaceVATDateMgtCZL.IsEnabled();
    end;

    var
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        ReplaceVATDateEnabled: Boolean;
        VATDateEnabled: Boolean;
}
#endif
