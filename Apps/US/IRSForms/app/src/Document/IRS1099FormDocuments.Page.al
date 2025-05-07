// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Utilities;

page 10036 "IRS 1099 Form Documents"
{
    PageType = List;
    SourceTable = "IRS 1099 Form Doc. Header";
    CardPageId = "IRS 1099 Form Document";
    ApplicationArea = BasicUS;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Period No."; Rec."Period No.")
                {
                    Tooltip = 'Specifies the period of the document.';
                    Visible = PeriodIsVisible;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    Tooltip = 'Specifies the vendor number.';
                }
                field("Form No."; Rec."Form No.")
                {
                    Tooltip = 'Specifies the form of the document.';
                }
                field(Status; Rec.Status)
                {
                    Tooltip = 'Specifies the status of the document';
                }
                field("Receiving 1099 E-Form Consent"; Rec."Receiving 1099 E-Form Consent")
                {
#pragma warning disable AA0219
                    Tooltip = 'By selecting this field, you acknowledge that your vendor has provided signed consent to receive their 1099 form electronically.';
#pragma warning restore AA0219
                    Visible = false;
                }
                field("Vendor E-Mail"; Rec."Vendor E-Mail")
                {
                    Tooltip = 'Specifies the vendor email address.';
                    Visible = false;
                }
                field("Copy B Sent"; Rec."Copy B Sent")
                {
                    Tooltip = 'Specifies whether the Copy B of the form has been sent to the vendor.';
                }
                field("Copy 2 Sent"; Rec."Copy 2 Sent")
                {
                    Tooltip = 'Specifies whether the Copy 2 of the form has been sent to the vendor.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateForms)
            {
                Caption = 'Create Forms';
                Image = Form;
                Scope = Repeater;
                ToolTip = 'Create IRS 1099 form documents for reporting.';

                trigger OnAction()
                var
                    IRSReportingPeriod: Record "IRS Reporting Period";
                    IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
                begin
                    if Rec.GetFilter("Period No.") <> '' then
                        if IRSReportingPeriod.Get(Rec.GetFilter("Period No.")) then;
                    IRS1099FormDocument.CreateForms(IRSReportingPeriod."No.");
                end;
            }
            action(RecreateForm)
            {
                Caption = 'Recreate Form';
                Image = Form;
                Scope = Repeater;
                ToolTip = 'Recreate a single IRS 1099 form document for reporting.';

                trigger OnAction()
                var
                    IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
                begin
                    IRS1099FormDocument.RecreateForm(Rec);
                end;
            }
            action(ReleaseAll)
            {
                Caption = 'Release All';
                Image = ReleaseDoc;
                ToolTip = 'Release all selected opened forms.';

                trigger OnAction()
                var
                    IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
                    IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
                begin
                    IRS1099FormDocHeader := Rec;
                    CurrPage.SetSelectionFilter(IRS1099FormDocHeader);
                    IRS1099FormDocHeader.SetRange(Status, IRS1099FormDocHeader.Status::Open);

                    if IRS1099FormDocHeader.FindSet() then
                        repeat
                            IRS1099FormDocument.Release(IRS1099FormDocHeader);
                        until IRS1099FormDocHeader.Next() = 0;
                end;
            }
            action(ReopenAll)
            {
                Caption = 'Reopen All';
                Image = ReOpen;
                ToolTip = 'Reopen all selected released forms.';

                trigger OnAction()
                var
                    IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
                    IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
                begin
                    IRS1099FormDocHeader := Rec;
                    CurrPage.SetSelectionFilter(IRS1099FormDocHeader);
                    IRS1099FormDocHeader.SetRange(Status, IRS1099FormDocHeader.Status::Released);

                    if IRS1099FormDocHeader.FindSet() then
                        repeat
                            IRS1099FormDocument.Reopen(IRS1099FormDocHeader);
                        until IRS1099FormDocHeader.Next() = 0;
                end;
            }
            action(SendEmail)
            {
                Caption = 'Send Email';
                Image = Email;
                ToolTip = 'Send the selected forms to the vendors by email.';

                trigger OnAction()
                var
                    IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
                    IRS1099SendEmailReport: Report "IRS 1099 Send Email";
                    IRS1099SendEmail: Codeunit "IRS 1099 Send Email";
                begin
                    IRS1099SendEmail.CheckEmailSetup();

                    IRS1099FormDocHeader := Rec;
                    CurrPage.SetSelectionFilter(IRS1099FormDocHeader);
                    IRS1099SendEmail.CheckCanSendMultipleEmails(IRS1099FormDocHeader);

                    IRS1099SendEmailReport.SetTableView(IRS1099FormDocHeader);
                    IRS1099SendEmailReport.RunModal();
                end;
            }
            action(ActivityLog)
            {
                Caption = 'Activity Log';
                Image = Log;
                ToolTip = 'Show activity log for the 1099 forms.';

                trigger OnAction()
                var
                    ActivityLog: Record "Activity Log";
                    IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
                begin
                    ActivityLog.SetRange(Context, IRS1099FormDocument.GetActivityLogContext());
                    Page.RunModal(Page::"Activity Log", ActivityLog);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(CreateForms_Promoted; CreateForms)
                {

                }
                actionref(SendEmails_Promoted; SendEmail)
                {
                }
            }
        }
    }

    var
        PeriodIsVisible: Boolean;

#if not CLEAN25
    trigger OnOpenPage()
    var
        IRSFormsFeature: Codeunit "IRS Forms Feature";
    begin
        PeriodIsVisible := Rec.GetFilter("Period No.") = '';
        CurrPage.Editable := IRSFormsFeature.FeatureCanBeUsed();
    end;
#endif
}
