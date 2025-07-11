// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

pageextension 31267 "VAT Report List CZL" extends "VAT Report List"
{
    layout
    {
#if not CLEAN25
#pragma warning disable AL0432
        modify("Attached Documents")
#pragma warning restore AL0432
        {
            Visible = false;
        }
#endif
        addbefore("Attached Documents List")
        {
            part(AttachmentsFactboxCZL; "VAT Stmt. Attach. Factbox CZL")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                UpdatePropagation = Both;
            }
            part(CommentsFactboxCZL; "VAT Stmt. Comment Factbox CZL")
            {
                ApplicationArea = All;
                Caption = 'Comments';
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action(DocumentationforVATCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Documentation for VAT CZL';
                Image = "Report";
                ToolTip = 'Print documentation of VAT entries.';

                trigger OnAction()
                var
                    DocumentationforVAT: Report "Documentation for VAT CZL";
                begin
                    DocumentationforVAT.InitializeRequest(
                        Rec."Start Date", Rec."End Date", false, Rec."Amounts in Add. Rep. Currency");
                    DocumentationforVAT.Run();
                end;
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(GenerateCZL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Generate';
                    Enabled = Rec.Status = Rec.Status::Released;
                    Image = GetLines;
                    ToolTip = 'Generate the content of VAT report.';
                    Visible = GenerateVisibleCZL;

                    trigger OnAction()
                    begin
                        VATReportMediator.Export(Rec);
                        if not CheckForErrors() then
                            Message(ReportGeneratedMsg);
                    end;
                }
                action(SubmitCZL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Submit';
                    Ellipsis = true;
                    Image = SendElectronicDocument;
                    ToolTip = 'Submits the VAT report to the tax authority''s reporting service.';
                    Enabled = Rec.Status = Rec.Status::Released;
                    Visible = SubmitVisibleCZL;

                    trigger OnAction()
                    begin
                        Submit(Rec);
                        if not CheckForErrors() then
                            Message(ReportSubmittedMsg);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec."No." <> '' then
            SetControlAppearance();
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;

    trigger OnAfterGetCurrRecord()
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
        VATStatementCommentLineCZL: Record "VAT Statement Comment Line CZL";
    begin
        VATStatementAttachmentCZL.FilterGroup(2);
        VATStatementAttachmentCZL.SetRange("VAT Statement Template Name", Rec."Statement Template Name");
        VATStatementAttachmentCZL.SetRange("VAT Statement Name", Rec."Statement Name");
        VATStatementAttachmentCZL.SetRange("Date", Rec."Start Date", Rec."End Date");
        VATStatementAttachmentCZL.FilterGroup(0);
        CurrPage.AttachmentsFactboxCZL.Page.SetTableView(VATStatementAttachmentCZL);
        CurrPage.AttachmentsFactboxCZL.Page.Update(false);

        VATStatementCommentLineCZL.FilterGroup(2);
        VATStatementCommentLineCZL.SetRange("VAT Statement Template Name", Rec."Statement Template Name");
        VATStatementCommentLineCZL.SetRange("VAT Statement Name", Rec."Statement Name");
        VATStatementCommentLineCZL.SetRange("Date", Rec."Start Date", Rec."End Date");
        VATStatementCommentLineCZL.FilterGroup(0);
        CurrPage.CommentsFactboxCZL.Page.SetTableView(VATStatementCommentLineCZL);
        CurrPage.CommentsFactboxCZL.Page.Update(false);
    end;

    var
        VATReportMediator: Codeunit "VAT Report Mediator";
        GenerateVisibleCZL, SubmitVisibleCZL : Boolean;
        ReportGeneratedMsg: Label 'The report has been successfully generated.';
        ReportSubmittedMsg: Label 'The report has been successfully submitted.';

    local procedure SetControlAppearance()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        VATReportMediator.GetVATReportConfiguration(VATReportsConfiguration, Rec);
        GenerateVisibleCZL := VATReportsConfiguration."Content Codeunit ID" <> 0;
        SubmitVisibleCZL := VATReportsConfiguration."Submission Codeunit ID" <> 0;
    end;

    local procedure Submit(VATReportHeader: Record "VAT Report Header")
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        VATReportMediator.GetVATReportConfiguration(VATReportsConfiguration, VATReportHeader);
        if VATReportsConfiguration."Submission Codeunit ID" <> 0 then
            Codeunit.Run(VATReportsConfiguration."Submission Codeunit ID", VATReportHeader);
    end;

    local procedure CheckForErrors(): Boolean
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        TempErrorMessage.CopyFromContext(Rec);
        exit(not TempErrorMessage.IsEmpty());
    end;
}