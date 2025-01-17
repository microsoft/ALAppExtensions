// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Currency;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Attachment;
using Microsoft.Utilities;
using System.Automation;

page 31160 "Cash Document CZP"
{
    Caption = 'Cash Document';
    DelayedInsert = true;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Cash Document Header CZP";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies if the cash desk document represents a cash receipt (Receipt) or a withdrawal (Wirthdrawal)';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();

                        UpdateEditable();
                        SetShowMandatoryConditions();
                    end;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the cash document.';
                    Visible = false;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Payment Purpose"; Rec."Payment Purpose")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies a payment purpose.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = DateEditable;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the posting of the cash document will be recorded.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = DateEditable;
                    ToolTip = 'Specifies the date on which you created the document.';
                }
                field("VAT Date"; Rec."VAT Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = VATDateEnabled;
                    Visible = VATDateEnabled;
                    ToolTip = 'Specifies the VAT date. This date must be shown on the VAT statement.';
                }
                field("Paid To"; Rec."Paid To")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = WithdrawalEditable;
                    ShowMandatory = WithdrawalToChecking;
                    ToolTip = 'Specifies whom is paid.';
                }
                field("Received From"; Rec."Received From")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = ReceiptEditable;
                    ShowMandatory = ReceiveToChecking;
                    ToolTip = 'Specifies who recieved amount.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if cash desk document status is Open or Released.';
                }
                field("Amounts Including VAT"; Rec."Amounts Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Lookup = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';

                    trigger OnAssistEdit()
                    begin
                        Clear(ChangeExchangeRate);
                        ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Posting Date");
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec.Validate("Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.Update();
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("VAT Base Amount (LCY)", "Amount Including VAT (LCY)");
                    end;
                }
                field("Released Amount"; Rec."Released Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the cash desk document, in the currency of the cash document after releasing.';
                }
                field("VAT Base Amount"; Rec."VAT Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the total VAT base amount for lines. The program calculates this amount from the sum of line VAT base amount fields.';
                    Visible = false;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                    Visible = false;
                }
                field("VAT Base Amount (LCY)"; Rec."VAT Base Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the VAT base amount for cash desk document line.';
                    Visible = false;
                }
                field("Amount Including VAT (LCY)"; Rec."Amount Including VAT (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                    Visible = false;
                }
                field("EET Cash Register"; Rec."EET Cash Register")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies that the cash register works with EET.';
                }
            }
            part(CashDocLines; "Cash Document Subform CZP")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Partner Type"; Rec."Partner Type")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies if the partner is Customer or Vendor or Contact or Salesperson/Purchaser or Employee.';
                }
                field("Partner No."; Rec."Partner No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the partner number.';
                }
                field("Paid By"; Rec."Paid By")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = WithdrawalEditable;
                    ShowMandatory = WithdrawalToChecking;
                    ToolTip = 'Specifies whom is paid.';
                }
                field("Received By"; Rec."Received By")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = ReceiptEditable;
                    ShowMandatory = ReceiveToChecking;
                    ToolTip = 'Specifies who recieved amount.';
                }
                field("Identification Card No."; Rec."Identification Card No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for a card.';
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the registration number of customer or vendor.';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 1, which is defined in the Shortcut Dimension 1 Code field in the General Ledger Setup window.';

                    trigger OnValidate()
                    begin
                        CurrPage.CashDocLines.Page.UpdatePage(true);
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 2, which is defined in the Shortcut Dimension 2 Code field in the General Ledger Setup window.';

                    trigger OnValidate()
                    begin
                        CurrPage.CashDocLines.Page.UpdatePage(true);
                    end;
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which salesperson/purchaser is assigned to the cash desk document.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the responsibility center which works with this cash desk.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number that the vendor uses on the invoice they sent to you or number of receipt.';
                }
                field("Created ID"; Rec."Created ID")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies employee ID of creating cash desk document.';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies date of creating cash desk document.';
                }
            }
        }
        area(factboxes)
        {
#if not CLEAN25
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ObsoleteTag = '25.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'The "Document Attachment FactBox" has been replaced by "Doc. Attachment List Factbox", which supports multiple files upload.';
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(database::"Cash Document Header CZP"), "No." = field("No.");
            }
#endif
            part("Attached Documents List"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                SubPageLink = "Table ID" = const(database::"Cash Document Header CZP"), "No." = field("No.");
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
            part(PendingApprovalFactBox; "Pending Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = const(11732), "Document No." = field("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part(WorkflowStatusFactBox; "Workflow Status FactBox")
            {
                ApplicationArea = All;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatus;
            }
            part(ApprovalFactBox; "Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = const(11732), "Document No." = field("No.");
                Visible = false;
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
                action(Statistics)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Statistics';
                    Image = Statistics;
                    ShortCutKey = 'F7';
                    RunPageMode = View;
                    ToolTip = 'View the statistics on the selected cash document.';

                    trigger OnAction()
                    begin
                        CurrPage.CashDocLines.Page.ShowStatistics();
                    end;
                }
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
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Relations to the workflow.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Rejects credit document';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Specifies enu delegate of cash document.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'Specifies cash document comments.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Cash Document Rounding")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Document Rounding';
                    Image = Calculate;
                    ToolTip = 'Specifies rounding of cash document.';

                    trigger OnAction()
                    begin
                        Rec.VATRounding();
                    end;
                }
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
                action(Release)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Release';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the cash document to indicate that it has been account. The status then changes to Released.';

                    trigger OnAction()
                    begin
                        ReleaseDocument(Codeunit::"Cash Document-Release CZP", NavigateAfterRelease::"Released Document");
                    end;
                }
                action(ReleaseAndNew)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Release and New';
                    Image = ReleaseDoc;
                    ToolTip = 'Release the cash document to indicate that can be posted and create new cash document with same type. The status then changes to Released.';

                    trigger OnAction()
                    begin
                        ReleaseDocument(Codeunit::"Cash Document-Release CZP", NavigateAfterRelease::"New Document");
                    end;
                }
                action(ReleaseAndPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Release and &Print';
                    Image = ConfirmAndPrint;
                    ToolTip = 'Release and prepare to print the cash document.';

                    trigger OnAction()
                    begin
                        ReleaseDocument(Codeunit::"Cash Document-ReleasePrint CZP", NavigateAfterRelease::"Do Nothing");
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Image = ReOpen;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    var
                        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
                    begin
                        CashDocumentReleaseCZP.PerformManualReopen(Rec);
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(Post)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostDocument;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the cash document. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        PostDocument(Codeunit::"Cash Document-Post(Yes/No) CZP", NavigateAfterPost::"Posted Document");
                    end;
                }
                action(PostAndNew)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and New';
                    Ellipsis = true;
                    Image = PostOrder;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize the cash document and create new cash document with same type. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        PostDocument(Codeunit::"Cash Document-Post(Yes/No) CZP", NavigateAfterPost::"New Document");
                    end;
                }
                action(PostAndPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    ToolTip = 'Finalize and prepare to print the cash document. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        PostDocument(Codeunit::"Cash Document-Post + Print CZP", NavigateAfterPost::"Do Nothing");
                    end;
                }
                action(Preview)
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
            group(Category_Category8)
            {
                Caption = 'Release';
                ShowAs = SplitButton;

                actionref(ReleasePromoted; Release)
                {
                }
                actionref(ReleaseAndNewPromoted; ReleaseAndNew)
                {
                }
                actionref(ReleaseAndPrintPromoted; ReleaseAndPrint)
                {
                }
                actionref(ReopenPromoted; Reopen)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Posting';
                ShowAs = SplitButton;

                actionref(PostPromoted; Post)
                {
                }
                actionref(PostAndNewPromoted; PostAndNew)
                {
                }
                actionref(PostAndPrintPromoted; PostAndPrint)
                {
                }
                actionref(PreviewPromoted; Preview)
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Request Approval';

                actionref(SendApprovalRequestPromoted; SendApprovalRequest)
                {
                }
                actionref(CancelApprovalRequestPromoted; CancelApprovalRequest)
                {
                }
            }
            group(Category_Category9)
            {
                Caption = 'Print';

                actionref(Print_Promoted; "&Print")
                {
                }
                actionref(PrinttoAttachment_Promoted; PrintToAttachment)
                {
                }
            }
            group(Category_Category6)
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

    trigger OnOpenPage()
    begin
        VATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetShowMandatoryConditions();
        ShowWorkflowStatus := CurrPage.WorkflowStatusFactBox.Page.SetFilterOnWorkflowRecord(Rec.RecordId);
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateEditable();
        SetControlVisibility();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        CashDeskNo: Code[20];
        CashDeskSelected: Boolean;
    begin
        if Rec.GetFilter("Cash Desk No.") <> '' then
            if CashDeskCZP.Get(Rec.GetFilter("Cash Desk No.")) then
                CashDeskNo := CashDeskCZP."No.";

        if CashDeskNo = '' then begin
            CashDeskManagementCZP.CashDocumentSelection(Rec, CashDeskSelected);
            if not CashDeskSelected then
                Error('');
        end else begin
            Rec.FilterGroup(2);
            Rec.SetRange("Cash Desk No.", CashDeskNo);
            Rec.FilterGroup(0);
        end;

        Rec.FilterGroup(2);
        Rec."Cash Desk No." := CopyStr(Rec.GetFilter("Cash Desk No."), 1, MaxStrLen(Rec."Cash Desk No."));
        Rec.FilterGroup(0);
    end;

    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        ChangeExchangeRate: Page "Change Exchange Rate";
        NavigateAfterPost: Option "Posted Document","New Document","Do Nothing";
        NavigateAfterRelease: Option "Released Document","New Document","Do Nothing";
        DateEditable: Boolean;
        ReceiptEditable: Boolean;
        WithdrawalEditable: Boolean;
        ReceiveToChecking: Boolean;
        WithdrawalToChecking: Boolean;
        ShowWorkflowStatus: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        OpenPostedCashDocQst: Label 'The cash document has been posted and moved to the Posted Cash Documents window.\\Do you want to open the posted cash document?';
        DocumentIsPosted: Boolean;
        DocumentIsReleased: Boolean;
        VATDateEnabled: Boolean;

    local procedure PostDocument(PostingCodeunitID: Integer; Navigate: Option)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        Rec.SendToPosting(PostingCodeunitID);
        DocumentIsPosted := not CashDocumentHeaderCZP.Get(Rec."Cash Desk No.", Rec."No.");

        CurrPage.Update(false);

        if PostingCodeunitID <> Codeunit::"Cash Document-Post(Yes/No) CZP" then
            exit;

        case Navigate of
            NavigateAfterPost::"Posted Document":
                if InstructionMgt.IsEnabled(InstructionMgt.ShowPostedConfirmationMessageCode()) then
                    ShowPostedConfirmationMessage(Rec."Cash Desk No.", Rec."No.");
            NavigateAfterPost::"New Document":
                if DocumentIsPosted then
                    ShowNewCashDocument();
        end;
    end;

    local procedure ReleaseDocument(ReleasingCodeunitID: Integer; Navigate: Option)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
        CashDocumentReleasePrintCZP: Codeunit "Cash Document-ReleasePrint CZP";
    begin
        case ReleasingCodeunitID of
            Codeunit::"Cash Document-Release CZP":
                CashDocumentReleaseCZP.PerformManualRelease(Rec);
            Codeunit::"Cash Document-ReleasePrint CZP":
                CashDocumentReleasePrintCZP.PerformManualRelease(Rec);
        end;

        CashDocumentHeaderCZP.Get(Rec."Cash Desk No.", Rec."No.");
        DocumentIsReleased := CashDocumentHeaderCZP.Status = CashDocumentHeaderCZP.Status::Released;

        CurrPage.Update(false);

        if ReleasingCodeunitID <> Codeunit::"Cash Document-Release CZP" then
            exit;

        case Navigate of
            NavigateAfterRelease::"New Document":
                if DocumentIsReleased then
                    ShowNewCashDocument();
        end;
    end;

    local procedure UpdateEditable()
    begin
        DateEditable := Rec.Status = Rec.Status::Open;
        ReceiptEditable := Rec."Document Type" = Rec."Document Type"::Receipt;
        WithdrawalEditable := Rec."Document Type" = Rec."Document Type"::Withdrawal;
        OnAfterUpdateEditable(Rec);
    end;

    local procedure SetShowMandatoryConditions()
    var
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if not CashDeskCZP.Get(Rec."Cash Desk No.") then
            CashDeskCZP.Init();

        ReceiveToChecking :=
          (Rec."Document Type" = Rec."Document Type"::Receipt) and
          (CashDeskCZP."Payed To/By Checking" <> CashDeskCZP."Payed To/By Checking"::"No Checking");
        WithdrawalToChecking :=
          (Rec."Document Type" = Rec."Document Type"::Withdrawal) and
          (CashDeskCZP."Payed To/By Checking" <> CashDeskCZP."Payed To/By Checking"::"No Checking");
    end;

    local procedure SetControlVisibility()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;

    local procedure ShowPreview()
    var
        CashDocumentPostYesNoCZP: Codeunit "Cash Document-Post(Yes/No) CZP";
    begin
        CashDocumentPostYesNoCZP.Preview(Rec);
    end;

    local procedure ShowPostedConfirmationMessage(CashDeskNo: Code[20]; CashDocumentNo: Code[20])
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskNo);
        PostedCashDocumentHdrCZP.SetRange("No.", CashDocumentNo);
        if PostedCashDocumentHdrCZP.FindFirst() then
            if InstructionMgt.ShowConfirm(OpenPostedCashDocQst, InstructionMgt.ShowPostedConfirmationMessageCode()) then
                Page.Run(Page::"Posted Cash Document CZP", PostedCashDocumentHdrCZP);
    end;

    local procedure ShowNewCashDocument()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        CashDocumentHeaderCZP.Init();
        CashDocumentHeaderCZP.Validate("Cash Desk No.", Rec."Cash Desk No.");
        CashDocumentHeaderCZP.Validate("Document Type", Rec."Document Type");
        CashDocumentHeaderCZP.Insert(true);
        Page.Run(Page::"Cash Document CZP", CashDocumentHeaderCZP);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterUpdateEditable(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;
}
