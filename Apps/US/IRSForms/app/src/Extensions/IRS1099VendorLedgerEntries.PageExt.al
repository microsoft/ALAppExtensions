// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Payables;

pageextension 10048 "IRS 1099 Vendor Ledger Entries" extends "Vendor Ledger Entries"
{
    layout
    {
#if not CLEAN25
#pragma warning disable AL0432
        modify("IRS 1099 Code")
        {
            Visible = not IsNewFeatureEnabled;
        }
        modify("IRS 1099 Amount")
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter("Exported to Payment File")
        {
            field("IRS 1099 Reporting Period"; Rec."IRS 1099 Reporting Period")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS reporting period for the vendor ledger entry.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("IRS 1099 Form No."; Rec."IRS 1099 Form No.")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS form number for the vendor ledger entry.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("IRS 1099 Form Box No."; Rec."IRS 1099 Form Box No.")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS form box number for the vendor ledger entry.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("IRS 1099 Reporting Amount"; Rec."IRS 1099 Reporting Amount")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS reporting amount for the vendor ledger entry.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
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
