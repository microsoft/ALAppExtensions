// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10054 "IRS 1099 Vend. Form Box Adjmts"
{
    Caption = 'IRS 1099 Vendor Form Box Adjustments';
    PageType = List;
    SourceTable = "IRS 1099 Vendor Form Box Adj.";
    ApplicationArea = BasicUS;
    UsageCategory = Administration;
    DelayedInsert = true;

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
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the adjustment amount for the 1099 form box that will be added to the amount from vendor ledger entries when the 1099 form document is generated.';
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
