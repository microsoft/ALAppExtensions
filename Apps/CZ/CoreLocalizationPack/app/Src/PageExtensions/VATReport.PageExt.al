// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

pageextension 31236 "VAT Report CZL" extends "VAT Report"
{
    layout
    {
        modify(General)
        {
            Editable = IsEditableCZL;
        }
        modify(Control23)
        {
            Editable = true;
        }
        modify("Start Date")
        {
            Editable = false;
        }
        modify("End Date")
        {
            Editable = false;
        }
#if not CLEAN25
#pragma warning disable AL0432
        modify("Attached Documents")
#pragma warning restore AL0432
        {
            Visible = false;
        }
#endif
        moveafter("Period Type"; "Period Year")
        addafter("Period No.")
        {
            field("VAT Return Type CZL"; Rec."VAT Report Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of VAT return.';
            }
        }
        addafter("Amounts in Add. Rep. Currency")
        {
            field("Round to Integer CZL"; Rec."Round to Integer CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the amounts in the VAT report should be rounded to the nearest integer.';
                Editable = false;
            }
            field("Rounding Direction CZL"; Rec."Rounding Direction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the rounding direction for the amounts in the VAT report.';
                Editable = false;
            }
        }
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
        modify(Generate)
        {
            Caption = 'Generate Xml';
            Visible = GenerateVisibleCZL;
        }
        modify(Submit)
        {
            Visible = false;
        }
        modify("Calc. and Post VAT Settlement")
        {
            Enabled = true;
            Visible = false;
        }
        addafter(Submit)
        {
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
        addafter("Calc. and Post VAT Settlement")
        {
            action(CalculateAndPostVATSettlementCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Calculate and Post VAT Settlement';
                Image = "Report";
                ToolTip = 'Close open VAT entries and transfers purchase and sales VAT amounts to the VAT settlement account. For every VAT posting group, the batch job finds all the VAT entries in the VAT Entry table that are included in the filters in the definition window.';

                trigger OnAction()
                var
                    CalcAndPostVATSettlCZL: Report "Calc. and Post VAT Settl. CZL";
                begin
                    CalcAndPostVATSettlCZL.InitializeRequest(Rec."Start Date", Rec."End Date", WorkDate(), Rec."No.", '', false, false);
                    CalcAndPostVATSettlCZL.Run();
                end;
            }
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
        }
        addlast(navigation)
        {
            action(VATStatementsCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Statements';
                RunObject = page "VAT Statement";
                Image = VATStatement;
                Tooltip = 'Open the VAT Statements page.';
            }
            action(AttachmentsCZL)
            {
                ApplicationArea = VAT;
                Caption = 'Attachments';
                Image = Attachments;
                ToolTip = 'Specifies VAT statement attachments.';

                trigger OnAction()
                var
                    VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
                begin
                    VATStatementAttachmentCZL.FilterGroup(2);
                    VATStatementAttachmentCZL.SetRange("VAT Statement Template Name", Rec."Statement Template Name");
                    VATStatementAttachmentCZL.SetRange("VAT Statement Name", Rec."Statement Name");
                    VATStatementAttachmentCZL.SetRange("Date", Rec."Start Date", Rec."End Date");
                    VATStatementAttachmentCZL.FilterGroup(0);
                    Page.RunModal(Page::"VAT Stmt. Attachment Sheet CZL", VATStatementAttachmentCZL);
                end;
            }
            action(CommentsCZL)
            {
                ApplicationArea = VAT;
                Caption = 'Comments';
                Image = ViewComments;
                ToolTip = 'Specifies VAT statement comments.';

                trigger OnAction()
                var
                    VATStatementCommentLineCZL: Record "VAT Statement Comment Line CZL";
                begin
                    VATStatementCommentLineCZL.FilterGroup(2);
                    VATStatementCommentLineCZL.SetRange("VAT Statement Template Name", Rec."Statement Template Name");
                    VATStatementCommentLineCZL.SetRange("VAT Statement Name", Rec."Statement Name");
                    VATStatementCommentLineCZL.SetRange("Date", Rec."Start Date", Rec."End Date");
                    VATStatementCommentLineCZL.FilterGroup(0);
                    Page.RunModal(Page::"VAT Stmt. Comment Sheet CZL", VATStatementCommentLineCZL);
                end;
            }
        }
        movebefore(Submit_Promoted; Generate_Promoted)
        addafter(Submit_Promoted)
        {
            actionref(Submit_PromotedCZL; SubmitCZL)
            {
            }
        }
        addafter("Calc. and Post VAT Settlement_Promoted")
        {
            actionref(CalculateAndPostVATSettlement_Promoted; CalculateAndPostVATSettlementCZL)
            {
            }
            actionref(DocumentationforVAT_PromotedCZL; DocumentationforVATCZL)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec."No." <> '' then
            SetControlAppearance();
        IsEditableCZL := Rec.Status = Rec.Status::Open;
        Rec.CheckOnlyStandardVATReportInPeriod(false);
    end;

    trigger OnAfterGetRecord()
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
        VATStatementCommentLineCZL: Record "VAT Statement Comment Line CZL";
    begin
        SetControlAppearance();
        IsEditableCZL := Rec.Status = Rec.Status::Open;

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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetControlAppearance();
    end;

    var
        VATReportMediator: Codeunit "VAT Report Mediator";
        GenerateVisibleCZL, SubmitVisibleCZL, ErrorsExistCZL, IsEditableCZL : Boolean;
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
        CurrPage.ErrorMessagesPart.Page.SetRecords(TempErrorMessage);
        CurrPage.ErrorMessagesPart.Page.Update();
        ErrorsExistCZL := not TempErrorMessage.IsEmpty();
        exit(ErrorsExistCZL);
    end;
}