// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10033 "IRS 1099 Forms"
{
    PageType = List;
    SourceTable = "IRS 1099 Form";
    ApplicationArea = BasicUS;
    DelayedInsert = true;
    RefreshOnActivate = true;

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
                field("No."; Rec."No.")
                {
                    Tooltip = 'Specifies the number of the 1099 form.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the reporting period.';
                }
                field("Boxes Count"; Rec."Boxes Count")
                {
                    ToolTip = 'Specifies a number of boxes for a certain form.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FormBoxes)
            {
                Caption = 'Form Boxes';
                Image = Form;
                Scope = Repeater;
                ToolTip = 'Specifies the form boxes to be reported.';
                RunObject = Page "IRS 1099 Form Boxes";
                RunPageLink = "Period No." = field("Period No."), "Form No." = field("No.");
            }
            action(EditStatement)
            {
                Caption = 'Edit Statement';
                Image = SetupList;
                ToolTip = 'View or edit how to print your IRS 1099 form statement';
                RunObject = Page "IRS 1099 Form Statement";
                RunPageLink = "Period No." = field("Period No."), "Form No." = field("No.");
            }
            action(EditInstructions)
            {
                Caption = 'Edit Instructions';
                Image = SetupList;
                ToolTip = 'View or edit the instructions for the printed version of the 1099 form document.';
                RunObject = Page "IRS 1099 Form Instructions";
                RunPageLink = "Period No." = field("Period No."), "Form No." = field("No.");
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(FormBoxes_Promoted; FormBoxes)
                {

                }
                actionref(EditStatement_Promoted; EditStatement)
                {

                }
                actionref(EditInstructions_Promoted; EditInstructions)
                {

                }
            }
        }
    }

    var
        PeriodIsVisible: Boolean;

    trigger OnOpenPage()
    begin
        PeriodIsVisible := Rec.GetFilter("Period No.") = '';
    end;
}
