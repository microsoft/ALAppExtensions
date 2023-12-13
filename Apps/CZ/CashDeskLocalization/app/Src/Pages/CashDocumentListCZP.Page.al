// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Foundation.Attachment;
using System.Automation;

page 31162 "Cash Document List CZP"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Cash Documents';
    CardPageID = "Cash Document CZP";
    DataCaptionFields = "Cash Desk No.";
    Editable = false;
    PageType = List;
    SourceTable = "Cash Document Header CZP";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Cash Desk No."; Rec."Cash Desk No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of cash desk.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the cash desk document represents a cash receipt (Receipt) or a withdrawal (Wirthdrawal)';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the cash document.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if cash desk document status is Open or Released.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the posting of the cash document will be recorded.';
                }
                field("Released Amount"; Rec."Released Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the cash desk document, in the currency of the cash document after releasing.';
                }
                field("VAT Base Amount"; Rec."VAT Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total VAT base amount for lines. The program calculates this amount from the sum of line VAT base amount fields.';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field("Payment Purpose"; Rec."Payment Purpose")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a payment purpose.';
                }
                field("Received From"; Rec."Received From")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies who recieved amount.';
                    Visible = false;
                }
                field("Paid To"; Rec."Paid To")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whom is paid.';
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(11732), "No." = field("No.");
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("Cash Document")
            {
                Caption = 'Cash Document';
                Image = Document;
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit the dimension sets that are set up for the cash document.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                    end;
                }
                action("A&pprovals")
                {
                    ApplicationArea = Suite;
                    Caption = 'A&pprovals';
                    Image = Approvals;
                    ToolTip = 'This function opens the approvals entries.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
                action(DocAttach)
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";

                action(CopyDocument)
                {
                    ApplicationArea = Suite;
                    Caption = 'Copy Document';
                    Ellipsis = true;
                    Image = CopyDocument;
                    ToolTip = 'Create a new cash document by copying an existing cash document.';

                    trigger OnAction()
                    var
                        CopyCashDocumentCZP: Report "Copy Cash Document CZP";
                    begin
                        CopyCashDocumentCZP.SetCashDocument(Rec);
                        CopyCashDocumentCZP.RunModal();
                        Clear(CopyCashDocumentCZP);
                        if Rec.Get(Rec."Cash Desk No.", Rec."No.") then;
                    end;
                }
            }
            group("&Releasing")
            {
                Caption = '&Releasing';
                action("&Release")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Release';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the cash document to indicate that it has been account. The status then changes to Released.';

                    trigger OnAction()
                    var
                        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
                    begin
                        CurrPage.SetSelectionFilter(CashDocumentHeaderCZP);
                        Rec.PerformManualRelease(CashDocumentHeaderCZP);
                    end;
                }
#if not CLEAN22
                action("Release and &Print")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Release and &Print';
                    Image = ConfirmAndPrint;
                    ToolTip = 'Release and prepare to print the cash document.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The action will only be available on the card page of the cash document.';
                    ObsoleteTag = '22.0';

                    trigger OnAction()
                    var
                        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
                        CashDocumentReleasePrintCZP: Codeunit "Cash Document-ReleasePrint CZP";
                    begin
                        CashDocumentHeaderCZP := Rec;
                        CashDocumentHeaderCZP.SetRecFilter();
                        CashDocumentReleasePrintCZP.PerformManualRelease(CashDocumentHeaderCZP);
                        CurrPage.Update(false);
                    end;
                }
#endif
                action("Re&open")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Image = ReOpen;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    var
                        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
                    begin
                        CurrPage.SetSelectionFilter(CashDocumentHeaderCZP);
                        Rec.PerformManualReopen(CashDocumentHeaderCZP);
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("P&ost")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostDocument;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the cash document. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        Post(Codeunit::"Cash Document-Post(Yes/No) CZP");
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the cash document. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        Post(Codeunit::"Cash Document-Post + Print CZP");
                    end;
                }
                action(PreviewPosting)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview Posting';
                    Image = ViewPostedOrder;
                    ShortCutKey = 'Ctrl+Alt+F9';
                    ToolTip = 'Review the result of the posting lines before the actual posting.';

                    trigger OnAction()
                    begin
                        ShowPreview();
                    end;
                }
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(SendApprovalRequest)
                {
                    ApplicationArea = Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = not OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    ToolTip = 'Relations to the workflow.';

                    trigger OnAction()
                    var
                        CashDocumentApprovMgtCZP: Codeunit "Cash Document Approv. Mgt. CZP";
                    begin
                        if CashDocumentApprovMgtCZP.CheckCashDocApprovalsWorkflowEnabled(Rec) then
                            CashDocumentApprovMgtCZP.OnSendCashDocumentForApproval(Rec);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = OpenApprovalEntriesExist;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Relations to the workflow.';

                    trigger OnAction()
                    var
                        CashDocumentApprovMgtCZP: Codeunit "Cash Document Approv. Mgt. CZP";
                    begin
                        CashDocumentApprovMgtCZP.OnCancelCashDocumentApprovalRequest(Rec);
                    end;
                }
            }
        }
        area(reporting)
        {
            action("&Print")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    CashDocumentHeaderCZP: Record "Cash Document Header CZP";
                begin
                    CashDocumentHeaderCZP := Rec;
                    CashDocumentHeaderCZP.SetRecFilter();
                    CashDocumentHeaderCZP.PrintRecords(true);
                end;
            }
            action(PrintToAttachment)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attach as PDF';
                Image = PrintAttachment;
                ToolTip = 'Create a PDF file and attach it to the document.';

                trigger OnAction()
                begin
                    Rec.PrintToDocumentAttachment();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CopyDocument_Promoted; CopyDocument)
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Release';
                ShowAs = SplitButton;

                actionref(ReleasePromoted; "&Release")
                {
                }
#if not CLEAN22
#pragma warning disable AL0432
                actionref(ReleaseAndPrintPromoted; "Release and &Print")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The action will only be available on the card page of the cash document.';
                    ObsoleteTag = '22.0';
                }
#pragma warning restore AL0432
#endif
                actionref(ReopenPromoted; "Re&open")
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Posting';
                ShowAs = SplitButton;

                actionref(PostPromoted; "P&ost")
                {
                }
                actionref(PostAndPrintPromoted; "Post and &Print")
                {
                }
                actionref(PreviePostingPromoted; PreviewPosting)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Request Approval';

                actionref(SendApprovalRequestPromoted; SendApprovalRequest)
                {
                }
                actionref(CancelApprovalRequestPromoted; CancelApprovalRequest)
                {
                }
            }
#if not CLEAN22
#pragma warning disable AS0072
            group(Category_Report)
            {
                Caption = 'Report';
                ObsoleteTag = '22.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'This group has been removed.';
                Visible = false;

                actionref(PrintToAttachmentPromoted; PrintToAttachment)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
                actionref(PrintPromoted; "&Print")
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
            }
#pragma warning restore AS0072
#endif
            group(Category_Category8)
            {
                Caption = 'Print';

                actionref(Print_Promoted; "&Print")
                {
                }
                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Cash Document';

                actionref(DimensionsPromoted; Dimensions)
                {
                }
                actionref(ApprovalsPromoted; "A&pprovals")
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance();
    end;

    trigger OnOpenPage()
    var
        CashDeskFilter: Text;
    begin
        CashDeskManagementCZP.CheckCashDesks();
        CashDeskFilter := CashDeskManagementCZP.GetCashDesksFilter();

        Rec.FilterGroup(2);
        if CashDeskFilter <> '' then
            Rec.SetFilter("Cash Desk No.", CashDeskFilter);
        Rec.FilterGroup(0);
    end;

    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        OpenApprovalEntriesExist: Boolean;

    local procedure Post(PostingCodeunitID: Integer)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        CashDocumentHeaderCZP := Rec;
        CashDocumentHeaderCZP.SetRecFilter();
        CashDocumentHeaderCZP.SendToPosting(PostingCodeunitID);
        CurrPage.Update(false);
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;

    local procedure ShowPreview()
    var
        CashDocumentPostYesNoCZP: Codeunit "Cash Document-Post(Yes/No) CZP";
    begin
        CashDocumentPostYesNoCZP.Preview(Rec);
    end;
}
