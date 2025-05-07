// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10037 "IRS 1099 Form Document"
{
    PageType = Card;
    SourceTable = "IRS 1099 Form Doc. Header";
    ApplicationArea = BasicUS;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Period No."; Rec."Period No.")
                {
                    Tooltip = 'Specifies the period of the document.';
                    Visible = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    Tooltip = 'Specifies the vendor number.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        UpdateLinesAvailable();
                    end;
                }
                field("Form No."; Rec."Form No.")
                {
                    Tooltip = 'Specifies the form of the document.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        UpdateLinesAvailable();
                    end;
                }
                field(Status; Rec.Status)
                {
                    Tooltip = 'Specifies the status of the document';
                }
            }
            group(Email)
            {
                field("Receiving 1099 E-Form Consent"; Rec."Receiving 1099 E-Form Consent")
                {
#pragma warning disable AA0219
                    Tooltip = 'By selecting this field, you acknowledge that your vendor has provided signed consent to receive their 1099 form electronically.';
#pragma warning restore AA0219
                    Importance = Additional;
                }
                field("Vendor E-Mail"; Rec."Vendor E-Mail")
                {
                    Tooltip = 'Specifies the vendor email address.';
                    Importance = Additional;
                }
                field("Copy B Sent"; Rec."Copy B Sent")
                {
                    Tooltip = 'Specifies whether the Copy B of the form has been sent to the vendor.';
                    Importance = Additional;
                }
                field("Copy 2 Sent"; Rec."Copy 2 Sent")
                {
                    Tooltip = 'Specifies whether the Copy 2 of the form has been sent to the vendor.';
                    Importance = Additional;
                }
                field("Email Error Log"; Rec."Email Error Log")
                {
                    ToolTip = 'Specifies the error log for the email.';
                    Importance = Additional;
                    Visible = EmailErrorVisible;
                    MultiLine = true;
                }
            }
            part(FormLines; "IRS 1099 Form Doc. Subform")
            {
                ApplicationArea = BasicUS;
                SubPageLink = "Document ID" = field(ID), "Period No." = field("Period No."), "Vendor No." = field("Vendor No."), "Form No." = field("Form No.");
                Editable = IsLinesEditable;
                Enabled = IsLinesEditable;
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            systempart(LinksFactBox; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
                Provider = FormLines;
            }
            systempart(NotesFactBox; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
                Provider = FormLines;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ReleaseReopen)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action(Release)
                {
                    ApplicationArea = BasicUS;
                    Caption = 'Re&lease';
                    Enabled = Rec.Status = Rec.Status::Open;
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the form before submission. You must reopen the form before you can make changes to it.';

                    trigger OnAction()
                    var
                        IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
                    begin
                        IRS1099FormDocument.Release(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = BasicUS;
                    Caption = 'Re&open';
                    Enabled = Rec.Status <> Rec.Status::Open;
                    Image = ReOpen;
                    ToolTip = 'Reopen the form to change it after it has been approved. Approved forms have the Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    var
                        IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
                    begin
                        IRS1099FormDocument.Reopen(Rec);
                    end;
                }
                action("Mark as Submitted")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Mark as Submitted';
                    Image = Approve;
                    ToolTip = 'Indicate that you submitted the form document to the tax authority manually.';

                    trigger OnAction()
                    var
                        IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
                    begin
                        IRS1099FormDocument.MarkAsSubmitted(Rec);
                    end;
                }
                action(Print)
                {
                    ApplicationArea = BasicUS;
                    Caption = 'Print';
                    Ellipsis = true;
                    Image = PrintAcknowledgement;
                    ToolTip = 'Prints a single form.';

                    trigger OnAction()
                    var
                        IRSFormsFacade: Codeunit "IRS Forms Facade";
                    begin
                        IRSFormsFacade.PrintContent(Rec);
                    end;
                }
                action(Reports)
                {
                    ApplicationArea = BasicUS;
                    Caption = 'Reports';
                    Ellipsis = true;
                    Image = Report;
                    ToolTip = 'Opens the reports page.';
                    RunObject = page "IRS 1099 Form Reports";
                    RunPageLink = "Document ID" = field(ID);
                }
                action(SendEmail)
                {
                    ApplicationArea = BasicUS;
                    Caption = 'Send Email';
                    Ellipsis = true;
                    Image = Email;
                    ToolTip = 'Sends the form by email.';

                    trigger OnAction()
                    var
                        IRS1099SendEmailReport: Report "IRS 1099 Send Email";
                        IRS1099SendEmail: Codeunit "IRS 1099 Send Email";
                    begin
                        IRS1099SendEmail.CheckEmailSetup();
                        IRS1099SendEmail.CheckCanSendEmail(Rec);

                        Rec.SetRecFilter();
                        IRS1099SendEmailReport.SetTableView(Rec);
                        IRS1099SendEmailReport.RunModal();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Status)
            {
                Caption = 'Release';
                ShowAs = SplitButton;

                actionref(Release_Promoted; Release)
                {
                }
                actionref(Reopen_Promoted; Reopen)
                {
                }
            }
            group(Category_Print)
            {
                Caption = 'Print';
                actionref(Print_Single; Print)
                {
                }
            }
            actionref(Reports_Single; Reports)
            {
            }
            actionref(Send_Email; SendEmail)
            {
            }
        }
    }

    var
        IsLinesEditable: Boolean;
        EmailErrorVisible: Boolean;

    trigger OnOpenPage()
    begin
        UpdateLinesAvailable();
        EmailErrorVisible := Rec."Email Error Log" <> '';
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateLinesAvailable();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateLinesAvailable();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        PeriodNo: Code[20];
    begin
        PeriodNo := GetPeriodNoFilter();
        if PeriodNo <> '' then
            Rec.Validate("Period No.", PeriodNo);
    end;

    local procedure GetPeriodNoFilter(): Code[20]
    begin
        if Rec.GetFilter("Period No.") <> '' then
            exit(Rec.GetRangeMin("Period No."));
    end;

    local procedure UpdateLinesAvailable()
    begin
        IsLinesEditable := (Rec."Period No." <> '') and (Rec."Vendor No." <> '') and (Rec."Form No." <> '');
    end;
}
