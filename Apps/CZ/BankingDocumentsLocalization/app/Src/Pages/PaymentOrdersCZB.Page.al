// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Foundation.Attachment;
using Microsoft.Utilities;
using System.Automation;

page 31261 "Payment Orders CZB"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Orders';
    CardPageID = "Payment Order CZB";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Payment Order Header CZB";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the payment order.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which you created the document.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of bank account.';
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of bank account.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount for payment order lines. The program calculates this amount from the sum of line amount fields on payment order lines.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the line consists of. The amount is in the local currency.';
                }
                field("No. of Lines"; Rec."No. of Lines")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of lines in the payment order.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name and address of the payment order file created in the system.';
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
                SubPageLink = "Table ID" = const(31256), "No." = field("No.");
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
            part(WorkflowStatus; "Workflow Status FactBox")
            {
                ApplicationArea = All;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatus;
            }
            part(ApproalFactBox; "Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = const(31256), "Document No." = field("No.");
                Visible = false;
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
                    ApprovalEntries: Page "Approval Entries";
                begin
                    ApprovalEntries.SetRecordFilters(Database::"Payment Order Header CZB", Enum::"Approval Document Type"::" ", Rec."No.");
                    ApprovalEntries.Run();
                end;
            }
            action(Statistics)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistics';
                Image = Statistics;
                ShortCutKey = 'F7';
                ToolTip = 'View the statistics on the selected payment order.';

                trigger OnAction()
                begin
                    Rec.ShowStatistics();
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
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Suggest Payments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Suggest Payments';
                    Ellipsis = true;
                    Image = SuggestPayment;
                    ToolTip = 'Opens suggest payments lines batch.';

                    trigger OnAction()
                    var
                        SuggestPaymentsCZB: Report "Suggest Payments CZB";
                    begin
                        SuggestPaymentsCZB.SetPaymentOrder(Rec);
                        SuggestPaymentsCZB.RunModal();
                    end;
                }
                action(Import)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import';
                    Ellipsis = true;
                    Image = Import;
                    ToolTip = 'Allows to import payment order prepared as file without the system.';

                    trigger OnAction()
                    begin
                        Rec.ImportPaymentOrder();
                    end;
                }
                action("Uncertainty VAT Payment Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Uncertainty VAT Payment Check';
                    Image = ElectronicPayment;
                    ToolTip = 'Checks uncertaintie vat of the vendor';

                    trigger OnAction()
                    begin
                        Rec.ImportUnreliablePayerStatus();
                    end;
                }
            }
            group("&Issuing")
            {
                Caption = '&Issuing';
                action("Test Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTip = 'Specifies test report';

                    trigger OnAction()
                    begin
                        TestPrintPaymentOrder();
                    end;
                }
                action(Issue)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Issue';
                    Ellipsis = true;
                    Image = ReleaseDoc;
                    ShortCutKey = 'F9';
                    ToolTip = 'Issue the payment order to indicate that it has been printed or exported. Payment order will be moved to issued payment order.';

                    trigger OnAction()
                    begin
                        IssueDocument(Codeunit::"Issue Payment Order YesNo CZB");
                    end;
                }
                action(IssueAndPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Issue and &Print';
                    Ellipsis = true;
                    Image = ConfirmAndPrint;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Issue and prepare to print the payment order. Payment order will be moved to issued payment order.';

                    trigger OnAction()
                    begin
                        IssueDocument(Codeunit::"Issue Payment Order Print CZB");
                    end;
                }
            }
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
                    ToolTip = 'Rejects cash document';
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
                    ToolTip = 'Specifies enu delegate of payment order.';
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
                    ToolTip = 'Specifies payment order comments.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
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
                    var
                        BankingApprovalsMgtCZB: Codeunit "Banking Approvals Mgt. CZB";
                    begin
                        if BankingApprovalsMgtCZB.CheckPaymentOrderApprovalsWorkflowEnabled(Rec) then
                            BankingApprovalsMgtCZB.OnSendPaymentOrderForApproval(Rec);
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
                        BankingApprovalsMgtCZB: Codeunit "Banking Approvals Mgt. CZB";
                    begin
                        BankingApprovalsMgtCZB.OnCancelPaymentOrderApprovalRequest(Rec);
                    end;
                }
            }
        }
        area(Reporting)
        {
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
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("Suggest Payments_Promoted"; "Suggest Payments")
                {
                }
                group(Category_Issuing)
                {
                    Caption = 'Issuing';
                    ShowAs = SplitButton;
                    actionref(Issue_Promoted; Issue)
                    {
                    }
                    actionref(IssueAndPrint_Promoted; IssueAndPrint)
                    {
                    }
                    actionref(TestReport_Promoted; "Test Report")
                    {
                    }
                }
            }
            group(Category_Category4)
            {
                Caption = 'Approval';

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
            group(Category_Category5)
            {
                Caption = 'Request Approval';

                actionref(SendApprovalRequest_Promoted; SendApprovalRequest)
                {
                }
                actionref(CancelApprovalRequest_Promoted; CancelApprovalRequest)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print';

                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Payment Order';

                actionref(Statistics_Promoted; Statistics)
                {
                }
                actionref(Approvals_Promoted; "A&pprovals")
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetControlVisibility();
        ShowWorkflowStatus := CurrPage.WorkflowStatus.Page.SetFilterOnWorkflowRecord(Rec.RecordId);
    end;

    trigger OnOpenPage()
    var
        PaymentOrderManagementCZB: Codeunit "Payment Order Management CZB";
        SelectedBankAccountForPaymentOrder: Boolean;
    begin
        PaymentOrderManagementCZB.PaymentOrderSelection(Rec, SelectedBankAccountForPaymentOrder);
        if not SelectedBankAccountForPaymentOrder then
            Error('');
    end;

    var
        InstructionMgt: Codeunit "Instruction Mgt.";
        InstructionMgtCZB: Codeunit "Instruction Mgt. CZB";
        ShowWorkflowStatus, OpenApprovalEntriesExistForCurrUser, OpenApprovalEntriesExist : Boolean;
        OpenIssuedPayOrdQst: Label 'The payment order has been issued and moved to the Issued Payment Orders window.\\Do you want to open the issued payment orders?';

    local procedure IssueDocument(IssuingCodeunitID: Integer)
    begin
        Rec.SendToIssuing(IssuingCodeunitID);
        CurrPage.Update(false);

        if IssuingCodeunitID <> Codeunit::"Issue Payment Order YesNo CZB" then
            exit;

        if InstructionMgt.IsEnabled(InstructionMgtCZB.GetOpeningIssuedDocumentNotificationId()) then
            ShowIssuedConfirmationMessage(Rec."No.");
    end;

    local procedure ShowIssuedConfirmationMessage(PreAssignedNo: Code[20])
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
    begin
        IssPaymentOrderHeaderCZB.SetRange("Pre-Assigned No.", PreAssignedNo);
        if IssPaymentOrderHeaderCZB.FindFirst() then
            if InstructionMgt.ShowConfirm(OpenIssuedPayOrdQst, InstructionMgtCZB.ShowIssuedConfirmationMessageCode()) then
                Page.Run(Page::"Iss. Payment Order CZB", IssPaymentOrderHeaderCZB);
    end;

    local procedure TestPrintPaymentOrder()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        CurrPage.SetSelectionFilter(PaymentOrderHeaderCZB);
        PaymentOrderHeaderCZB.TestPrintRecords(true);
    end;

    local procedure SetControlVisibility()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;
}
