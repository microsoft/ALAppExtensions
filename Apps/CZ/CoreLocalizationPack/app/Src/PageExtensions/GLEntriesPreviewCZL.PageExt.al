// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.VAT.Calculation;

pageextension 11760 "G/L Entries Preview CZL" extends "G/L Entries Preview"
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
        addafter("FA Entry No.")
        {

            field("External Document No. CZL"; Rec."External Document No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the external document number on the entry.';
                Visible = false;
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
