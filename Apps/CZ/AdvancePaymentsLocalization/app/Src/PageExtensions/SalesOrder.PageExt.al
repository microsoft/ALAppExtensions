// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;

pageextension 31023 "Sales Order CZZ" extends "Sales Order"
{
    layout
    {
        modify(Control1900201301)
        {
            Visible = false;
        }
        modify("Prepayment %")
        {
            Visible = false;
        }
        modify("Compress Prepayment")
        {
            Visible = false;
        }
        modify("Prepmt. Payment Terms Code")
        {
            Visible = false;
        }
        modify("Prepayment Due Date")
        {
            Visible = false;
        }
        modify("Prepmt. Payment Discount %")
        {
            Visible = false;
        }
        modify("Prepmt. Pmt. Discount Date")
        {
            Visible = false;
        }
        addlast(General)
        {
            field("Unpaid Advance Letter CZZ"; Rec."Unpaid Advance Letter CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if unpaid advance letter exists for this order.';
                Visible = false;
            }
        }
        addlast(factboxes)
        {
            part("Sales Adv. Usage FactBox CZZ"; "Sales Adv. Usage FactBox CZZ")
            {
                ApplicationArea = Basic, Suite;
                Provider = SalesLines;
                SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Line No." = field("Line No.");
            }
        }
    }

    actions
    {
        modify(Prepayment)
        {
            Visible = false;
        }
        modify(PagePostedSalesPrepaymentInvoices)
        {
            Visible = false;
        }
        modify(PagePostedSalesPrepaymentCrMemos)
        {
            Visible = false;
        }
        modify("Prepa&yment")
        {
            Visible = false;
        }
        addbefore("P&osting")
        {
            group(AdvanceLetterGrCZZ)
            {
                Caption = 'Advance Letter';
                Image = Prepayment;

                action(CreateAdvanceLetterCZZ)
                {
                    Caption = 'Create Advance Letter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The function create advance letter.';
                    Image = CreateDocument;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        CreateSalesAdvLetterCZZ: Report "Create Sales Adv. Letter CZZ";
                    begin
                        CreateSalesAdvLetterCZZ.SetSalesHeader(Rec);
                        CreateSalesAdvLetterCZZ.Run();
                    end;
                }
                action(LinkAdvanceLetterCZZ)
                {
                    Caption = 'Link Advance Letter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The function allows to link advance letters.';
                    Image = LinkWithExisting;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
                    begin
                        SalesAdvLetterManagementCZZ.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Sales Order", Rec."No.", Rec."Bill-to Customer No.", Rec."Posting Date", Rec."Currency Code");
                    end;
                }
            }
        }
        addafter(PreviewPosting)
        {
            action(AdvanceVATStatisticsCZZ)
            {
                Caption = 'Advance VAT Statistics';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Shows summarized VAT Entries, include advance VAT Entries, based on posting preview.';
                Image = VATEntries;

                trigger OnAction()
                var
                    ShowPreviewHandlerCZZ: Codeunit "Show Preview Handler CZZ";
                    SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
                begin
                    BindSubscription(ShowPreviewHandlerCZZ);
                    SalesPostYesNo.Preview(Rec);
                end;
            }
        }
    }
}
