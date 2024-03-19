// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;

pageextension 10050 "IRS 1099 Vendor List" extends "Vendor List"
{
    actions
    {
#if not CLEAN25
#pragma warning disable AL0432
        modify("1099 Statistics")
        {
            Visible = not IsNewFeatureEnabled;
        }
        modify("Vendor 1099 Div")
        {
            Visible = not IsNewFeatureEnabled;
        }
        modify("Vendor 1099 Information")
        {
            Visible = not IsNewFeatureEnabled;
        }
        modify("Vendor 1099 Int")
        {
            Visible = not IsNewFeatureEnabled;
        }
        modify("Vendor 1099 Misc")
        {
            Visible = not IsNewFeatureEnabled;
        }
        modify(RunVendor1099NecReport)
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addlast("&Purchases")
        {
            action(IRS1099Setup)
            {
                Caption = 'IRS 1099 Setup';
                ApplicationArea = BasicUS;
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
                Image = Vendor;
                Scope = Repeater;
                ToolTip = 'Specifies the setup for a vendor to be reported in IRS 1099 form';
                RunObject = Page "IRS 1099 Vendor Form Box Setup";
                RunPageLink = "Vendor No." = field("No.");
            }
            action(Adjustments)
            {
                Caption = 'Adjustments';
                ApplicationArea = BasicUS;
                Image = AdjustEntries;
                Scope = Repeater;
                ToolTip = 'Specifies the adjustment amount for certain form boxes for this vendor';
                RunObject = Page "IRS 1099 Vend. Form Box Adjmts";
                RunPageLink = "Vendor No." = field("No.");
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
