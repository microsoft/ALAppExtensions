// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10035 "IRS 1099 Vendor Form Box Setup"
{
    PageType = List;
    SourceTable = "IRS 1099 Vendor Form Box Setup";
    ApplicationArea = BasicUS;
    UsageCategory = Administration;
    AboutTitle = 'About the setup of form boxes for vendors';
    AboutText = 'Here you can map the form boxes to vendor in the certain period. When you create a document for a certain vendor, the system will use this setup to fill in the form boxes.';
    DelayedInsert = true;
    AnalysisModeEnabled = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Period No."; Rec."Period No.")
                {
                    Tooltip = 'Specifies the period of the 1099 form box.';
                    Visible = PeriodIsVisible;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    Tooltip = 'Specifies the vendor number.';
                    Visible = VendorIsVisible;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ToolTip = 'Specifies the vendor name.';
                    Visible = VendorIsVisible;
                }
                field("Form No."; Rec."Form No.")
                {
                    Tooltip = 'Specifies the 1099 that box belongs to.';
                }
                field("Form Box No."; Rec."Form Box No.")
                {
                    Tooltip = 'Specifies the number of the 1099 form box.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SuggestVendors)
            {
                ApplicationArea = BasicUS;
                Caption = 'Suggest';
                Image = Suggest;
                ToolTip = 'Suggest vendors for the selected period';
                AboutTitle = 'About suggest vendors';
                AboutText = 'Here you can set filters for the vendors that will be suggested for the selected period instead of adding them manually one by one.';

                trigger OnAction()
                var
                    IRSReportingPeriod: Record "IRS Reporting Period";
                    IRS1099VendorFormBox: Codeunit "IRS 1099 Vendor Form Box";
                    PeriodFilter: Text;
                begin
                    PeriodFilter := Rec.GetFilter("Period No.");
                    if IRSReportingPeriod.Get(PeriodFilter) then;
                    IRS1099VendorFormBox.SuggestVendorsForFormBoxSetup(IRSReportingPeriod."No.");
                end;
            }
            action(Propagate)
            {
                ApplicationArea = BasicUS;
                Caption = 'Propagate';
                Image = CopyBudget;
                ToolTip = 'Propagate the vendor form box setup to the existing opened purchase documents vendor ledger entries.';
                AboutTitle = 'About propagate vendor setup';
                AboutText = 'Here you can propagete the new vendor form box setup to the existing opened purchase documents and vendor ledger entries instead of updating documents and entries manually one by one.';

                trigger OnAction()
                var
                    IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
                    IRS1099VendorFormBox: Codeunit "IRS 1099 Vendor Form Box";
                begin
                    CurrPage.SetSelectionFilter(IRS1099VendorFormBoxSetup);
                    IRS1099VendorFormBox.PropagateVendorsFormBoxSetupToExistingEntries(IRS1099VendorFormBoxSetup);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(SuggestVendors_Promoted; SuggestVendors)
                {

                }
            }
        }
    }

    var
        PeriodIsVisible: Boolean;
        VendorIsVisible: Boolean;

    trigger OnOpenPage()
    var
#if not CLEAN25
        IRSFormsFeature: Codeunit "IRS Forms Feature";
#endif
    begin
        PeriodIsVisible := Rec.GetFilter("Period No.") = '';
        VendorIsVisible := Rec.GetFilter("Vendor No.") = '';
#if not CLEAN25
        CurrPage.Editable := IRSFormsFeature.FeatureCanBeUsed();
#endif
    end;
}
