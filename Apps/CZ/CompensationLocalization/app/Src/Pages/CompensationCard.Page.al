// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.EServices.EDocument;
using Microsoft.Foundation.Attachment;
using Microsoft.Utilities;
using System.Automation;
using System.Security.User;

page 31272 "Compensation Card CZC"
{
    Caption = 'Compensation Card';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Compensation Header CZC";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the compensation.';
                    Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies description for compensation.';
                }
                field("Company Type"; Rec."Company Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company type in compensation.';
                    ShowMandatory = true;
                }
                field("Company No."; Rec."Company No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of company.';
                    Importance = Additional;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of company.';
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Rec.LookupCompanyName() then
                            CurrPage.Update();
                    end;
                }
                field("Company Name 2"; Rec."Company Name 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name 2 of company.';
                    Importance = Additional;
                }
                field("Company Address"; Rec."Company Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of company.';
                }
                field("Company Address 2"; Rec."Company Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address 2 of customer or vendor.';
                    Importance = Additional;
                }
                field("Company City"; Rec."Company City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the post code and city of company.';
                    Importance = Additional;
                }
                field("Company Post Code"; Rec."Company Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the post code of company.';
                    Importance = Additional;
                }
                field("Company Country/Region Code"; Rec."Company Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company country or region of address.';
                    Importance = Additional;
                }
                field("Company Contact"; Rec."Company Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact name of company.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the record is open, waiting to be approved, or released to the next stage of processing.';
                }
                field("Salesperson/Purchaser Code"; Rec."Salesperson/Purchaser Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the salesperson or purchaser.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which you created the compensation.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the date when the posting of the compensation will be done.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user associated with the entry.';
                    Importance = Additional;

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."User ID");
                    end;
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the language to be used on printouts for this document.';
                    Importance = Additional;
                }
                field("Format Region"; Rec."Format Region")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the region format to be used on printouts for this document.';
                    Importance = Additional;
                }
            }
            part(CompensationLinesCZC; "Compensation Subform CZC")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Compensation No." = field("No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31272), "No." = field("No.");
            }
            part(PendingApprovalFactBox; "Pending Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = const(31272), "Document No." = field("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part(WorkflowStatus; "Workflow Status FactBox")
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
                SubPageLink = "Table ID" = const(31272), "Document No." = field("No.");
                Visible = false;
            }
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                Visible = false;
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
        area(Navigation)
        {
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
        area(Processing)
        {
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve compensation.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Rejects compensation.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegates compensation approvement.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'Specifies the compensation comments.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group(Releasing)
            {
                Caption = 'Release';
                action(Release)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release compensation document.';

                    trigger OnAction()
                    begin
                        ReleaseCompensDocumentCZC.PerformManualRelease(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Image = ReOpen;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have that Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    begin
                        ReleaseCompensDocumentCZC.PerformManualReopen(Rec);
                    end;
                }
            }
            group(Functions)
            {
                Caption = 'F&unctions';
                action(ProposeCompensationLines)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Propose Compensation Lines';
                    Ellipsis = true;
                    Image = SuggestLines;
                    ToolTip = 'The function allows propose compensation lines.';

                    trigger OnAction()
                    begin
                        CompensationManagementCZC.SuggestCompensationLines(Rec);
                    end;
                }
                action(ApplyDocumentBalance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Apply Document Balance';
                    Image = RefreshLines;
                    ToolTip = 'The function changes the remaining amount of compensation. Compensation balance must be applied.';

                    trigger OnAction()
                    var
                        CompensationManagementCZC: Codeunit "Compensation Management CZC";
                    begin
                        CompensationManagementCZC.BalanceCompensations(Rec);
                    end;
                }
                group(IncomingDocument)
                {
                    Caption = 'Incoming Document';
                    Image = Documents;
                    action(IncomingDocCard)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'View Incoming Document';
                        Enabled = HasIncomingDocument;
                        Image = ViewOrder;
                        ToolTip = 'View any incoming document records and file attachments that exist for the entry or document.';

                        trigger OnAction()
                        var
                            IncomingDocument: Record "Incoming Document";
                        begin
                            IncomingDocument.ShowCardFromEntryNo(Rec."Incoming Document Entry No.");
                        end;
                    }
                    action(SelectIncomingDoc)
                    {
                        AccessByPermission = tabledata "Incoming Document" = R;
                        ApplicationArea = Basic, Suite;
                        Caption = 'Select Incoming Document';
                        Image = SelectLineToApply;
                        ToolTip = 'Select an incoming document record and file attachment that you want to link to the entry or document.';

                        trigger OnAction()
                        var
                            IncomingDocument: Record "Incoming Document";
                        begin
                            Rec.Validate("Incoming Document Entry No.", IncomingDocument.SelectIncomingDocument(Rec."Incoming Document Entry No.", Rec.RecordId));
                        end;
                    }
                    action(IncomingDocAttachFile)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Create Incoming Document from File';
                        Ellipsis = true;
                        Enabled = not HasIncomingDocument;
                        Image = Attach;
                        ToolTip = 'Create an incoming document record by selecting a file to attach, and then link the incoming document record to the entry or document.';

                        trigger OnAction()
                        var
                            IncomingDocumentAttachment: Record "Incoming Document Attachment";
                        begin
                            IncomingDocumentAttachment.NewAttachmentFromDocument(Rec."Incoming Document Entry No.",
                              Database::"Compensation Header CZC", 0, Rec."No.");
                        end;
                    }
                    action(RemoveIncomingDoc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Remove Incoming Document';
                        Enabled = HasIncomingDocument;
                        Image = RemoveLine;
                        ToolTip = 'Remove an external document that has been recorded, manually or automatically, and attached as a file to a document or ledger entry.';

                        trigger OnAction()
                        begin
                            Rec."Incoming Document Entry No." := 0;
                        end;
                    }
                }
            }
            group(Posting)
            {
                Caption = 'P&osting';
                action("P&ost")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the compensation. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        Post(Codeunit::"Compensation - Post Yes/No CZC", NavigateAfterPost::"Posted Document");
                    end;
                }
                action(PostAndNew)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and New';
                    Ellipsis = true;
                    Image = PostOrder;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize the compensation and create new one. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        Post(Codeunit::"Compensation - Post Yes/No CZC", NavigateAfterPost::"New Document");
                    end;
                }
                action(PostAndPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    ToolTip = 'Finalize and prepare to print the compensation. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        Post(Codeunit::"Compensation - Post Print CZC", NavigateAfterPost::"Do Nothing");
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
            group(RequestApproval)
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
                    begin
                        if CompensationApprovMgtCZC.CheckCompensationApprovalsWorkflowEnabled(Rec) then
                            CompensationApprovMgtCZC.OnSendCompensationForApprovalCZC(Rec);
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
                    begin
                        CompensationApprovMgtCZC.OnCancelCompensationApprovalRequestCZC(Rec);
                    end;
                }
            }
        }
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    CompensationHeaderCZC: Record "Compensation Header CZC";
                begin
                    CompensationHeaderCZC.Get(Rec."No.");
                    CurrPage.SetSelectionFilter(CompensationHeaderCZC);
                    CompensationHeaderCZC.PerformManualPrintRecords(true);
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

                group(Category_Category5)
                {
                    Caption = 'Posting';
                    ShowAs = SplitButton;

                    actionref("P&ost_Promoted"; "P&ost")
                    {
                    }
                    actionref(PostAndNew_Promoted; PostAndNew)
                    {
                    }
                    actionref(PostAndPrint_Promoted; PostAndPrint)
                    {
                    }
                    actionref(PreviePosting_Promoted; PreviewPosting)
                    {
                    }
                }
                group(Category_Category4)
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
                actionref(ProposeCompensationLines_Promoted; ProposeCompensationLines)
                {
                }
                actionref(ApplyDocumentBalance_Promoted; ApplyDocumentBalance)
                {
                }
            }
            group(Category_Category8)
            {
                Caption = 'Request Approval';

                actionref(SendApprovalRequest_Promoted; SendApprovalRequest)
                {
                }
                actionref(CancelApprovalRequest_Promoted; CancelApprovalRequest)
                {
                }
            }
            group(Category_Category9)
            {
                Caption = 'Approval';
                Visible = false;

                actionref(Approve_Promoted; Approve)
                {
                }
                actionref(Reject_Promoted; Reject)
                {
                }
                actionref(Delegate_Promoted; Delegate)
                {
                }
                actionref(Comment_Promoted; Comment)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print';

                actionref(Print_Promoted; Print)
                {
                }
                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Compensation';

                actionref(Approvals_Promoted; "A&pprovals")
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.IncomingDocAttachFactBox.PAGE.LoadDataFromRecord(Rec);
        ShowWorkflowStatus := CurrPage.WorkflowStatus.Page.SetFilterOnWorkflowRecord(Rec.RecordId);
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlVisibility();
    end;

    trigger OnOpenPage()
    begin
        SetNoFieldVisible();
    end;

    var
        CompensationManagementCZC: Codeunit "Compensation Management CZC";
        CompensationApprovMgtCZC: Codeunit "Compensation Approv. Mgt. CZC";
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        ReleaseCompensDocumentCZC: Codeunit "Release Compens. Document CZC";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        NavigateAfterPost: Option "Posted Document","New Document","Do Nothing";
        NoFieldVisible: Boolean;
        ShowWorkflowStatus: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        HasIncomingDocument: Boolean;
        DocumentIsPosted: Boolean;
        OpenPostedCompensationQst: Label 'The compensation has been posted and moved to the posted compensations window.\\Do you want to open the posted compensation?';

    local procedure SetNoFieldVisible()
    begin
        NoFieldVisible := DocumentNoVisibility.ForceShowNoSeriesForDocNo(DetermineCompensationCZCSeriesNo());
    end;

    local procedure DetermineCompensationCZCSeriesNo(): Code[20]
    var
        CompensationsSetupCZC: Record "Compensations Setup CZC";
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        CompensationsSetupCZC.Get();
        DocumentNoVisibility.CheckNumberSeries(CompensationHeaderCZC, CompensationsSetupCZC."Compensation Nos.", CompensationHeaderCZC.FieldNo("No."));
        exit(CompensationsSetupCZC."Compensation Nos.");
    end;

    local procedure Post(PostingCodeunitID: Integer; Navigate: Option)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        Rec.SendToPosting(PostingCodeunitID);
        DocumentIsPosted := not CompensationHeaderCZC.Get(Rec."No.");
        CurrPage.Update(false);

        if PostingCodeunitID <> Codeunit::"Compensation - Post Yes/No CZC" then
            exit;

        case Navigate of
            NavigateAfterPost::"Posted Document":
                if InstructionMgt.IsEnabled(InstructionMgt.ShowPostedConfirmationMessageCode()) then
                    ShowPostedConfirmationMessage(Rec."No.");
            NavigateAfterPost::"New Document":
                if DocumentIsPosted then
                    ShowNewCompensation();
        end;
    end;

    local procedure SetControlVisibility()
    begin
        HasIncomingDocument := Rec."Incoming Document Entry No." <> 0;

        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;

    local procedure ShowPreview()
    var
        CompensationPostYesNoCZC: Codeunit "Compensation - Post Yes/No CZC";
    begin
        CompensationPostYesNoCZC.Preview(Rec);
    end;

    local procedure ShowPostedConfirmationMessage(DocumentNo: Code[20])
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        PostedCompensationHeaderCZC.SetRange("No.", DocumentNo);
        if PostedCompensationHeaderCZC.FindFirst() then
            if InstructionMgt.ShowConfirm(OpenPostedCompensationQst, InstructionMgt.ShowPostedConfirmationMessageCode()) then
                Page.Run(Page::"Posted Compensation Card CZC", PostedCompensationHeaderCZC);
    end;

    local procedure ShowNewCompensation()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        CompensationHeaderCZC.Init();
        CompensationHeaderCZC.Insert(true);
        Page.Run(Page::"Compensation Card CZC", CompensationHeaderCZC);
    end;
}
