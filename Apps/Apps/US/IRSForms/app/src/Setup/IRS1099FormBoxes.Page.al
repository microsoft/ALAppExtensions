// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10034 "IRS 1099 Form Boxes"
{
    PageType = List;
    SourceTable = "IRS 1099 Form Box";
    ApplicationArea = BasicUS;
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
                field("Form No."; Rec."Form No.")
                {
                    Tooltip = 'Specifies the 1099 that box belongs to.';
                    Visible = FormIsVisible;
                }
                field("No."; Rec."No.")
                {
                    Tooltip = 'Specifies the number of the 1099 form box.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the reporting period.';
                }
                field("Minimum Reportable Amount"; Rec."Minimum Reportable Amount")
                {
                    ToolTip = 'Specifies the minimum amount for this form box that must be reported.';
                }
            }
        }
    }

    var
        PeriodIsVisible: Boolean;
        FormIsVisible: Boolean;

    trigger OnOpenPage()
    begin
        PeriodIsVisible := Rec.GetFilter("Period No.") = '';
        FormIsVisible := Rec.GetFilter("Form No.") = '';
    end;
}
