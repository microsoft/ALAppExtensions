// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.History;

pageextension 10061 "IRS 1099 Posted Purch. Cr.Memo" extends "Posted Purchase Credit Memo"
{
    layout
    {
#if not CLEAN25
#pragma warning disable AL0432
        modify("IRS 1099 Code")
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter(Control46)
        {
            field("IRS 1099 Reporting Period"; Rec."IRS 1099 Reporting Period")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS reporting period for the document.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("IRS 1099 Form No."; Rec."IRS 1099 Form No.")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS form number for the document.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
                Editable = false;
            }
            field("IRS 1099 Form Box No."; Rec."IRS 1099 Form Box No.")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS form box number for the vendor ledger entry.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
                Editable = false;
            }
        }
    }

#if not CLEAN25
    var
        IsNewFeatureEnabled: Boolean;

    trigger OnOpenPage()
    var
        IRSFormsFeature: Codeunit "IRS Forms Feature";
    begin
        IsNewFeatureEnabled := IRSFormsFeature.IsEnabled();
    end;
#endif
}
