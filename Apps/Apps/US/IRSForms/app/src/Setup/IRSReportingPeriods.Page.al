// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10031 "IRS Reporting Periods"
{
    PageType = List;
    SourceTable = "IRS Reporting Period";
    ApplicationArea = BasicUS;
    UsageCategory = Administration;
    AboutTitle = 'About reporting periods';
    AboutText = 'Here you can set up the different periods and form boxes, vendor mapping, and statement for reporting per period.';
    DelayedInsert = true;
    RefreshOnActivate = true;
    AnalysisModeEnabled = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    Tooltip = 'Specifies a reporting period number.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies a starting date of the reporting period.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ToolTip = 'Specifies a ending date of the reporting period.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the reporting period.';
                }
                field("Forms In Period"; Rec."Forms In Period")
                {
                    ToolTip = 'Specifies a number of forms in the reporting period.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Forms)
            {
                Caption = 'Forms';
                Image = Form;
                Scope = Repeater;
                ToolTip = 'Specifies the forms to be reported in this period.';
                AboutTitle = 'About forms';
                AboutText = 'Here you can set up all the forms and form boxes you want to report in the certain period. Form boxes will be used in the documents.';
                RunObject = Page "IRS 1099 Forms";
                RunPageLink = "Period No." = field("No.");
            }
            action(VendorSetup)
            {
                Caption = 'Vendor Setup';
                Image = Vendor;
                Scope = Repeater;
                ToolTip = 'Specifies the setup for vendors to be reported in this period.';
                AboutTitle = 'About vendor setup';
                AboutText = 'Here you can set up mapping between vendors and forms for reporting in the certain period. When you create a document for a certain vendor, the system will use this setup to fill in the form boxes.';
                RunObject = Page "IRS 1099 Vendor Form Box Setup";
                RunPageLink = "Period No." = field("No.");
            }
            action(Adjustments)
            {
                Caption = 'Adjustments';
                Image = AdjustEntries;
                Scope = Repeater;
                ToolTip = 'Specifies the adjustment amount for vendors and form boxes in this period';
                AboutTitle = 'About adjustments';
                AboutText = 'Here you specify the adjustment amount for vendors and form boxes. The adjustment amount will be added to the calculated amount in the form box when you create a form document.';
                RunObject = Page "IRS 1099 Vend. Form Box Adjmts";
                RunPageLink = "Period No." = field("No.");
            }
            action(Documents)
            {
                Caption = 'Documents';
                Image = Document;
                Scope = Repeater;
                ToolTip = 'Specifies the documents to be reported in this period.';
                AboutTitle = 'About document';
                AboutText = 'Here you can create the form documents based on the vendor ledger entries with form boxes and adjustments. The documents will be used for reporting to the IRS.';
                RunObject = Page "IRS 1099 Form Documents";
                RunPageLink = "Period No." = field("No.");
            }
            action(CopyFrom)
            {
                Caption = 'Copy Setup From...';
                Image = Copy;
                ToolTip = 'Copy the setup from another period. That includes forms with boxes, vendor setup, adjustments and form statement.';
                trigger OnAction()
                var
                    IRSReportingPeriod: Codeunit "IRS Reporting Period";
                begin
                    IRSReportingPeriod.CopyReportingPeriodSetup(Rec."No.");
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(CopyFrom_Promoted; CopyFrom)
                {

                }
                actionref(Forms_Promoted; Forms)
                {

                }
                actionref(VendorSetup_Promoted; VendorSetup)
                {

                }
                actionref(Adjustments_Promoted; Adjustments)
                {

                }
                actionref(Documents_Promoted; Documents)
                {

                }
            }
        }
    }

#if not CLEAN25
    trigger OnOpenPage()
    var
        IRSFormsFeature: Codeunit "IRS Forms Feature";
    begin
        CurrPage.Editable := IRSFormsFeature.FeatureCanBeUsed();
    end;
#endif
}
