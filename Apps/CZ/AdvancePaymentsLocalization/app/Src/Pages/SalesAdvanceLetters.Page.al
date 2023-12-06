// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.EServices.EDocument;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Attachment;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using System.Automation;

#pragma warning disable AL0204, AL0604
page 31170 "Sales Advance Letters CZZ"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Sales Advance Letters';
    PageType = List;
    SourceTable = "Sales Adv. Letter Header CZZ";
    UsageCategory = Lists;
    CardPageId = "Sales Advance Letter CZZ";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies advance letter document no.';
                }
                field("Advance Letter Code"; Rec."Advance Letter Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies code of advance letter template.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies bill-to customer no.';
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies bill-to name.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies posting date.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document date.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies currency code.';
                    Visible = false;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies order no.';
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT bus. posting group.';
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies status.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    AccessByPermission = tabledata "Responsibility Center" = R;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the responsibility center, such as a distribution hub, that is associated with the involved user, company, customer, or vendor.';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount including VAT.';
                    Visible = false;
                }
                field("Amount Including VAT (LCY)"; Rec."Amount Including VAT (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount including VAT (LCY).';
                    Visible = false;
                }
                field("To Pay"; Rec."To Pay")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies to pay amount.';
                    Visible = false;
                }
                field("To Use"; Rec."To Use")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies to use amount.';
                    Visible = false;
                }
                field("To Use (LCY)"; Rec."To Use (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies to use (LCY) amount.';
                    Visible = false;
                }
                field("Variable Symbol"; Rec."Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies variable symbol.';
                    Visible = false;
                }
                field("Constant Symbol"; Rec."Constant Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies constant symbol.';
                    Visible = false;
                }
                field("Specific Symbol"; Rec."Specific Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies specific symbol.';
                    Visible = false;
                }
                field("Advance Due Date"; Rec."Advance Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies due date.';
                    Visible = false;
                }
                field("Automatic Post VAT Document"; Rec."Automatic Post VAT Document")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether VAT document will be posted automatically.';
                    Visible = false;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(SalesAdvLetterFactBox; "Sales Adv. Letter FactBox CZZ")
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
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
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
                action(Approvals)
                {
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
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
            group(ReleaseGr)
            {
                Caption = 'Release';
                Image = ReleaseDoc;

                action(Release)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Release';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the advance letter document to indicate that it has been account. The status then changes to To Pay.';

                    trigger OnAction()
                    var
                        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                    begin
                        CurrPage.SetSelectionFilter(SalesAdvLetterHeaderCZZ);
                        Rec.PerformManualRelease(SalesAdvLetterHeaderCZZ);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reopen';
                    Image = ReOpen;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the To Pay status and must be opened before they can be changed.';

                    trigger OnAction()
                    var
                        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                    begin
                        CurrPage.SetSelectionFilter(SalesAdvLetterHeaderCZZ);
                        Rec.PerformManualReopen(SalesAdvLetterHeaderCZZ);
                    end;
                }
            }
        }
        area(Reporting)
        {
            action(AdvanceLetter)
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
            action(AdvanceLetters)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Letters';
                Image = PrintReport;
                Ellipsis = true;
                ToolTip = 'Allows the print list of advance letters.';
                RunObject = Report "Sales Advance Letters CZZ";
            }
            action(AdvanceLettersVAT)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Letters VAT';
                Image = PrintReport;
                Ellipsis = true;
                ToolTip = 'Allows the print list of advance letters with VAT.';
                RunObject = Report "Sales Advance Letters VAT CZZ";
            }
            action(AdvanceLettersRecap)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Letters Recapitulation';
                Image = PrintReport;
                Ellipsis = true;
                ToolTip = 'Allows the print list of advance letters recapitulation.';
                RunObject = Report "Sales Adv. Letters Recap. CZZ";
            }
        }
        area(Promoted)
        {
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
            group(Category_Category6)
            {
                Caption = 'Print/Send';

                actionref(AdvanceLetter_Promoted; AdvanceLetter)
                {
                }
                actionref(Email_Promoted; Email)
                {
                }
                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Sales Advance Letter';

                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref(SuggestedUsage_Promoted; SuggestedUsage)
                {
                }
                actionref(Approvals_Promoted; Approvals)
                {
                }
                actionref(DocAttach_Promoted; DocAttach)
                {
                }
                actionref(Entries_Promoted; Entries)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetSecurityFilterOnRespCenter();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.IncomingDocAttachFactBox.Page.LoadDataFromRecord(Rec);
    end;
}
