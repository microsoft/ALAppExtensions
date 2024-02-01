#if not CLEAN24
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.VAT.Calculation;

pageextension 31230 "VAT Setup CZL" extends "VAT Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';
    ObsoleteReason = 'The page extension is no longer needed.';
#if not CLEAN22

    layout
    {
        modify(VATDate)
        {
            Visible = IsVATDateEnabled and ReplaceVATDateEnabled;
        }
    }
    trigger OnOpenPage()
    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
    begin
        ReplaceVATDateEnabled := ReplaceVATDateMgtCZL.IsEnabled();
        IsVATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
    end;

    var
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
        ReplaceVATDateEnabled: Boolean;
        IsVATDateEnabled: Boolean;
#endif
}

#endif