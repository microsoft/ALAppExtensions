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
        addafter("Exclude from Pmt. Practices")
        {
#if not CLEAN28
#pragma warning disable AL0432
            field("IRS Reporting Period"; Rec."IRS Reporting Period")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies the last IRS reporting period where the vendor has a vendor form box setup';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by a dynamic field on the vendor card and list pages.';
                ObsoleteTag = '28.0';
            }
            field("IRS 1099 Form No."; Rec."IRS 1099 Form No.")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies the IRS form number where the vendor has a vendor form box setup';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by a dynamic field on the vendor card and list pages.';
                ObsoleteTag = '28.0';
            }
            field("IRS 1099 Form Box No."; Rec."IRS 1099 Form Box No.")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies the IRS form box number where the vendor has a vendor form box setup';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by a dynamic field on the vendor card and list pages.';
                ObsoleteTag = '28.0';
            }
#pragma warning restore AL0432
#endif
            field(IRSReportingPeriodNoField; IRSReportingPeriodNo)
            {
                ApplicationArea = BasicUS;
                Caption = 'IRS Reporting Period';
                ToolTip = 'Specifies the current IRS reporting period where the vendor has a vendor form box setup';
                Editable = false;
            }
            field(IRS1099FormNoField; IRS1099FormNo)
            {
                ApplicationArea = BasicUS;
                Caption = 'IRS 1099 Form No.';
                ToolTip = 'Specifies the current IRS form number where the vendor has a vendor form box setup';
                Editable = false;
            }
            field(IRS1099FormBoxNoField; IRS1099FormBoxNo)
            {
                ApplicationArea = BasicUS;
                Caption = 'IRS 1099 Form Box No.';
                ToolTip = 'Specifies the current IRS form box number where the vendor has a vendor form box setup';
                Editable = false;

                trigger OnDrillDown()
                begin
                    IRS1099VendorFormBox.ShowVendor1099FormBoxSetupAsOfWorkDate(Rec."No.");
                end;
            }
            field("Receive Elec. IRS Forms"; Rec."Receiving 1099 E-Form Consent")
            {
                ApplicationArea = BasicUS;
#pragma warning disable AA0219
                Tooltip = 'By selecting this field, you acknowledge that your vendor has provided signed consent to receive their 1099 form electronically.';
#pragma warning restore AA0219
            }
            field("E-Mail For IRS"; Rec."E-Mail For IRS")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies the email address of the vendor to receive the IRS 1099 form.';
            }
            field("FATCA Requirement"; Rec."FATCA Requirement")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies if the vendor is set up to require FATCA filing.';
            }
        }
    }

    actions
    {
        addlast("&Purchases")
        {
            action(IRS1099Setup)
            {
                Caption = 'IRS 1099 Setup';
                ApplicationArea = BasicUS;
                Image = Vendor;
                Scope = Repeater;
                ToolTip = 'Specifies the setup for a vendor to be reported in IRS 1099 form in this period.';
                RunObject = Page "IRS 1099 Vendor Form Box Setup";
                RunPageLink = "Vendor No." = field("No.");
            }
        }
    }

    var
        IRS1099VendorFormBox: Codeunit "IRS 1099 Vendor Form Box";
        IRSReportingPeriodNo, IRS1099FormNo, IRS1099FormBoxNo : Code[20];

    trigger OnAfterGetCurrRecord()
    begin
        IRS1099VendorFormBox.GetVendorIRS1099FormBoxSetupAsOfWorkdate(IRSReportingPeriodNo, IRS1099FormNo, IRS1099FormBoxNo, Rec."No.");
    end;

    trigger OnAfterGetRecord()
    begin
        IRS1099VendorFormBox.GetVendorIRS1099FormBoxSetupAsOfWorkdate(IRSReportingPeriodNo, IRS1099FormNo, IRS1099FormBoxNo, Rec."No.");
    end;
}