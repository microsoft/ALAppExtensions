// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;

pageextension 10053 "IRS 1099 Vendor Card" extends "Vendor Card"
{
    layout
    {
#if not CLEAN25
#pragma warning disable AL0432
        modify("IRS 1099 Code")
        {
            Visible = not IsNewFeatureEnabled;
        }
        modify("FATCA filing requirement")
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter("Exclude from Pmt. Practices")
        {
            field("IRS Reporting Period"; Rec."IRS Reporting Period")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies the last IRS reporting period where the vendor has a vendor form box setup';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("IRS 1099 Form No."; Rec."IRS 1099 Form No.")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies the IRS form number where the vendor has a vendor form box setup';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("IRS 1099 Form Box No."; Rec."IRS 1099 Form Box No.")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies the IRS form box number where the vendor has a vendor form box setup';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("Receive Elec. IRS Forms"; Rec."Receiving 1099 E-Form Consent")
            {
                ApplicationArea = BasicUS;
#pragma warning disable AA0219
                Tooltip = 'By selecting this field, you acknowledge that your vendor has provided signed consent to receive their 1099 form electronically.';
#pragma warning restore AA0219
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("E-Mail For IRS"; Rec."E-Mail For IRS")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies the email address of the vendor to receive the IRS 1099 form.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("FATCA Requirement"; Rec."FATCA Requirement")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies if the vendor is set up to require FATCA filing.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
        }
    }

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
                ToolTip = 'Specifies the setup for a vendor to be reported in IRS 1099 form in this period.';
                RunObject = Page "IRS 1099 Vendor Form Box Setup";
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
