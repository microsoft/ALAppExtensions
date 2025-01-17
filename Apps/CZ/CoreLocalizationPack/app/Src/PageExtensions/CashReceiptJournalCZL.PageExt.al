// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.VAT.Calculation;

pageextension 11723 "Cash Receipt Journal CZL" extends "Cash Receipt Journal"
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
        }
    }
    trigger OnOpenPage()
    begin
        VATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
    end;

    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        VATDateEnabled: Boolean;
}
