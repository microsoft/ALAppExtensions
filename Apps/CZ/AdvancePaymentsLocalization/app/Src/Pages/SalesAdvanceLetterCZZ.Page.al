﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.EServices.EDocument;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Attachment;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;
using System.Automation;
using System.Security.User;

#pragma warning disable AL0204, AL0604
page 31171 "Sales Advance Letter CZZ"
{
    Caption = 'Sales Advance Letter';
    PageType = Document;
    SourceTable = "Sales Adv. Letter Header CZZ";
    RefreshOnActivate = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Advance Letter Code"; Rec."Advance Letter Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies advance letter code.';
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Visible = DocNoVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit() then
                            CurrPage.Update();
                    end;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default.';
                    Importance = Additional;
                    NotBlank = true;
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the customer who will receive the products and be billed by default.';
                }
                group("Bill-to")
                {
                    Caption = 'Bill-to';
                    field("Bill-to Address"; Rec."Bill-to Address")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Address';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the address where the customer is located.';
                    }
                    field("Bill-to Address 2"; Rec."Bill-to Address 2")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Address 2';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field("Bill-to City"; Rec."Bill-to City")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'City';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the city of the customer on the sales document.';
                    }
                    group(Control123)
                    {
                        ShowCaption = false;
                        Visible = IsBillToCountyVisible;
                        field("Bill-to County"; Rec."Bill-to County")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'County';
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the state, province or county of the address.';
                        }
                    }
                    field("Bill-to Post Code"; Rec."Bill-to Post Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Country/Region Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the country or region of the address.';

                        trigger OnValidate()
                        begin
                            IsBillToCountyVisible := FormatAddress.UseCounty(Rec."Bill-to Country/Region Code");
                        end;
                    }
                    field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Contact No.';
                        Importance = Additional;
                        ToolTip = 'Specifies the number of the contact person that the sales document will be sent to.';
                    }
                }
                field("Bill-to Contact"; Rec."Bill-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contact';
                    Editable = "Bill-to Customer No." <> '';
                    ToolTip = 'Specifies the name of the person to contact at the customer.';
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the document.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the date when the related document was created.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the posting of the sales document will be recorded.';
                }
                field("VAT Date"; Rec."VAT Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT date. This date must be shown on the VAT statement.';
                    Visible = false;
                }
                field("Advance Due Date"; Rec."Advance Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies when the related advance letter must be paid.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    QuickEntry = false;
                    ToolTip = 'Specifies document status.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    AccessByPermission = tabledata "Responsibility Center" = R;
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the code of the responsibility center, such as a distribution hub, that is associated with the involved user, company, customer, or vendor.';
                }
                field("Automatic Post VAT Document"; Rec."Automatic Post VAT Document")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if post VAT document automatically.';
                }
            }
            part(AdvLetterLines; "Sales Advance Letter Line CZZ")
            {
                ApplicationArea = Basic, Suite;
                Editable = DynamicEditable;
                Enabled = "Bill-to Customer No." <> '';
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group("Invoice Details")
            {
                Caption = 'Invoice Details';

                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency of amounts on the sales document.';

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        if Rec."Posting Date" <> 0D then
                            ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Posting Date")
                        else
                            ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", WorkDate());
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec.Validate("Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.SaveRecord();
                            CurrPage.AdvLetterLines.Page.ClearAdvLetterDocTotals();
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                        CurrPage.AdvLetterLines.Page.ClearAdvLetterDocTotals();
                    end;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("VAT Registration No. CZL"; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
                }
                field("Registration No. CZL"; Rec."Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the registration number of customer.';
                }
                field("Tax Registration No. CZL"; Rec."Tax Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the secondary VAT registration number for the customer.';
                    Importance = Additional;
                }
            }
            group(Payments)
            {
                Caption = 'Payment Details';

                field("Variable Symbol CZL"; Rec."Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the detail information for payment.';
                    Importance = Promoted;
                }
                field("Constant Symbol CZL"; Rec."Constant Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                    Importance = Additional;
                }
                field("Specific Symbol CZL"; Rec."Specific Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                    Importance = Additional;
                }
                field("Bank Account Code CZL"; Rec."Bank Account Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code to idenfity bank account of company.';
                }
                field("Bank Name CZL"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the bank.';
                }
                field("Bank Account No. CZL"; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                    Importance = Promoted;
                }
                field("IBAN CZL"; Rec.IBAN)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account''s international bank account number.';
                    Importance = Promoted;
                }
                field("SWIFT Code CZL"; Rec."SWIFT Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the international bank identifier code (SWIFT) of the bank where you have the account.';
                }
                field("Transit No. CZL"; Rec."Transit No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a bank identification number of your own choice.';
                    Importance = Additional;
                }
                field("Bank Branch No. CZL"; Rec."Bank Branch No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the bank branch.';
                    Importance = Additional;
                }
            }
        }
        area(FactBoxes)
        {
            part(SalesAdvLettrFactBox; "Sales Adv. Letter FactBox CZZ")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");
            }
            part(CustomerDetailFactBox; "Customer Details FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Bill-to Customer No.");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31004), "No." = field("No.");
            }
            part(PendingApprovalFactBox; "Pending Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = const(31004), "Document No." = field("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part(ApprovalFactBox; "Approval FactBox")
            {
                ApplicationArea = All;
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
        area(navigation)
        {
            group(AdvanceLetterGr)
            {
                Caption = 'Advance Letter';
                Image = "Invoice";

                action(Dimensions)
                {
                    AccessByPermission = tabledata Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Enabled = "No." <> '';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                        CurrPage.SaveRecord();
                    end;
                }
                action(SuggestedUsage)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Suggested Usage';
                    Image = CoupledInvoice;
                    ToolTip = 'View a list of suggested usages.';
                    RunObject = Page "Suggested Usage CZZ";
                    RunPageLink = "Advance Letter Type" = const(Sales), "Advance Letter No." = field("No.");
                }
                action(DocAttach)
                {
                    ApplicationArea = Basic, Suite;
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
            group(History)
            {
                Caption = 'History';
                Image = History;

                action(Entries)
                {
                    ApplicationArea = Suite;
                    Caption = 'Advance Letter Entries';
                    Image = Entries;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View a list of entries related to this document.';
                    RunObject = Page "Sales Adv. Letter Entries CZZ";
                    RunPageLink = "Sales Adv. Letter No." = field("No.");
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
                    ToolTip = 'Approve the requested changes.';
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
                    ToolTip = 'Reject the approval request.';
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
                    ToolTip = 'Delegate the approval to a substitute approver.';
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
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group(ReleaseGr)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action(Release)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&lease';
                    Enabled = Status = Status::New;
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document.';

                    trigger OnAction()
                    var
                        RelSalesAdvLetterDoc: Codeunit "Rel. Sales Adv.Letter Doc. CZZ";
                    begin
                        RelSalesAdvLetterDoc.PerformManualRelease(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Enabled = Status = Status::"To Pay";
                    Image = ReOpen;
                    ToolTip = 'Reopen the document.';

                    trigger OnAction()
                    var
                        RelSalesAdvLetterDoc: Codeunit "Rel. Sales Adv.Letter Doc. CZZ";
                    begin
                        RelSalesAdvLetterDoc.PerformManualReopen(Rec);
                    end;
                }
            }
            group(Functions)
            {
                Caption = 'Functions';
                Image = "Action";

                action(CloseAdvanceLetter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Close Advance Letter';
                    Enabled = Status <> Status::Closed;
                    Image = CloseDocument;
                    Ellipsis = true;
                    ToolTip = 'Close advance letter.';

                    trigger OnAction()
                    var
                        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
                    begin
                        SalesAdvLetterManagement.CloseAdvanceLetter(Rec);
                    end;
                }
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                action(Approvals)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
                action(SendApprovalRequest)
                {
                    ApplicationArea = Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = not OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    var
                        AdvPaymentsApprovMgtCZZ: Codeunit "Adv. Payments Approv. Mgt. CZZ";
                    begin
                        if AdvPaymentsApprovMgtCZZ.CheckSalesAdvanceLetterApprovalsWorkflowEnabled(Rec) then
                            AdvPaymentsApprovMgtCZZ.OnSendSalesAdvanceLetterForApproval(Rec);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = OpenApprovalEntriesExist;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        AdvPaymentsApprovMgtCZZ: Codeunit "Adv. Payments Approv. Mgt. CZZ";
                    begin
                        AdvPaymentsApprovMgtCZZ.OnCancelSalesAdvanceLetterApprovalRequest(Rec);
                    end;
                }
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
                          Database::"Sales Adv. Letter Header CZZ", 0, Rec."No.");
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
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Letter';
                Image = PrintReport;
                Ellipsis = true;
                ToolTip = 'Allows the print of advance letter.';

                trigger OnAction()
                var
                    SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                begin
                    SalesAdvLetterHeaderCZZ := Rec;
                    CurrPage.SetSelectionFilter(SalesAdvLetterHeaderCZZ);
                    SalesAdvLetterHeaderCZZ.PrintRecords(true);
                end;
            }
            action(Email)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Send by Email';
                Image = Email;
                ToolTip = 'Prepare to email the document. The Send Email window opens prefilled with the customer''s email address so you can add or edit information.';

                trigger OnAction()
                var
                    SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                begin
                    SalesAdvLetterHeaderCZZ := Rec;
                    CurrPage.SetSelectionFilter(SalesAdvLetterHeaderCZZ);
                    SalesAdvLetterHeaderCZZ.EmailRecords(true);
                end;
            }
            action(PrintToAttachment)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attach as PDF';
                Image = PrintAttachment;
                ToolTip = 'Create a PDF file and attach it to the document.';

                trigger OnAction()
                var
                    SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                begin
                    SalesAdvLetterHeaderCZZ := Rec;
                    CurrPage.SetSelectionFilter(SalesAdvLetterHeaderCZZ);
                    SalesAdvLetterHeaderCZZ.PrintToDocumentAttachment();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                group(Category_Release)
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
            }
            group(Category_RequestApproval)
            {
                Caption = 'Request Approval';

                actionref(Approvals_Promoted; Approvals)
                {
                }
                actionref(SendApprovalRequest_Promoted; SendApprovalRequest)
                {
                }
                actionref(CancelApprovalRequest_Promoted; CancelApprovalRequest)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print/Send';

                actionref(PrintPromoted; Print)
                {
                }
                actionref(EmailPromoted; Email)
                {
                }
                actionref(PrintToAttachmentPromoted; PrintToAttachment)
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

                actionref(Print_Promoted; Print)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
                actionref(Email_Promoted; Email)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
            }
            group(Category_History)
            {
                Caption = 'History';
                ObsoleteTag = '22.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'This group has been removed.';
                Visible = false;

                actionref(Entries_Promoted; Entries)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
            }
            group(Category_Approve)
            {
                Caption = 'Approve';
                ObsoleteTag = '22.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'This group has been removed.';
                Visible = false;

                actionref(Approve_Promoted; Approve)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
                actionref(Reject_Promoted; Reject)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
                actionref(Delegate_Promoted; Delegate)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
                actionref(Comment_Promoted; Comment)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
            }
#pragma warning restore AS0072
#endif
            group(Category_Category7)
            {
                Caption = 'Sales Advance Letter';

                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref(SuggestedUsage_Promoted; SuggestedUsage)
                {
                }
                actionref(DocAttach_Promoted; DocAttach)
                {
                }
                actionref(EntriesPromoted; Entries)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetSecurityFilterOnRespCenter();
        ActivateFields();
        SetDocNoVisible();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        AdvanceLetterTemplate: Record "Advance Letter Template CZZ";
        UserSetupManagement: Codeunit "User Setup Management";
    begin
        AdvanceLetterTemplate.SetRange("Sales/Purchase", AdvanceLetterTemplate."Sales/Purchase"::Sales);
        if Page.RunModal(0, AdvanceLetterTemplate) <> Action::LookupOK then
            Error('');

        AdvanceLetterTemplate.TestField("Advance Letter Document Nos.");
        Rec."Advance Letter Code" := AdvanceLetterTemplate.Code;
        Rec."No. Series" := AdvanceLetterTemplate."Advance Letter Document Nos.";
        Rec."Responsibility Center" := UserSetupManagement.GetSalesFilter();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        DynamicEditable := CurrPage.Editable;
        CurrPage.ApprovalFactBox.Page.UpdateApprovalEntriesFromSourceRecord(RecordId);
        CurrPage.IncomingDocAttachFactBox.Page.LoadDataFromRecord(Rec);
        SetControlVisibility();
    end;

    var
        FormatAddress: Codeunit "Format Address";
        DocNoVisible, IsBillToCountyVisible, DynamicEditable, OpenApprovalEntriesExistForCurrUser, OpenApprovalEntriesExist, HasIncomingDocument : Boolean;

    local procedure SetDocNoVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        if Rec."No." <> '' then
            DocNoVisible := false
        else
            DocNoVisible := DocumentNoVisibility.ForceShowNoSeriesForDocNo(Rec."No. Series");
    end;

    local procedure ActivateFields()
    begin
        IsBillToCountyVisible := FormatAddress.UseCounty(Rec."Bill-to Country/Region Code");
    end;

    local procedure SetControlVisibility()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        HasIncomingDocument := Rec."Incoming Document Entry No." <> 0;
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;
}
