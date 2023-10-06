// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.Currency;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.Reporting;
using Microsoft.Inventory;
using Microsoft.Purchases.Comment;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;
using Microsoft.Warehouse.Document;
using Microsoft.Warehouse.Request;

page 18491 "Subcontracting Order"
{
    Caption = 'Subcontracting Order';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = filter(Order), Subcontracting = const(true));
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting order number.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number the order belongs to.';

                    trigger OnValidate()
                    begin
                        BuyfromVendorNoOnAfterValidate();
                    end;
                }
                field("Buy-from Contact No."; Rec."Buy-from Contact No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact number of the vendor.';
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor name.';
                }
                field("Buy-from Address"; Rec."Buy-from Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor address.';
                }
                field("Buy-from Address 2"; Rec."Buy-from Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional address of vendor.';
                }
                field("Buy-from Post Code"; Rec."Buy-from Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Buy-from Post Code/City';
                    ToolTip = 'Specifies the post code of the vendor.';
                }
                field("Buy-from City"; Rec."Buy-from City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of the vendor.';

                }
                field("Buy-from Contact"; Rec."Buy-from Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact of the vendor.';
                }
                field("No. of Archived Versions"; Rec."No. of Archived Versions")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total number of versions created for the order.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the entry.';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the order date of the document.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document date of the document.';
                }
                field("Vendor Order No."; Rec."Vendor Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor order number.';
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor shipment number.';
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor invoice number.';
                }
                field("Order Address Code"; Rec."Order Address Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor order address, if any.';
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the assigned purchaser from the organization.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the responsibility center for the document.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the document.';
                }
            }
            part(PurchLines; "Subcontracting Order Subform")
            {
                ApplicationArea = Basic, Suite;
                Editable = Rec."Buy-from Vendor No." <> '';
                Enabled = Rec."Buy-from Vendor No." <> '';
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the pay to vendor code used in the document.';

                    trigger OnValidate()
                    begin
                        PaytoVendorNoOnAfterValidate();
                    end;
                }
                field("Pay-to Contact No."; Rec."Pay-to Contact No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact number of the pay to vendor.';
                }
                field("Pay-to Name"; Rec."Pay-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the pay to vendor.';
                }
                field("Pay-to Address"; Rec."Pay-to Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of pay to vendor.';
                }
                field("Pay-to Address 2"; Rec."Pay-to Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional address of pay to vendor.';
                }
                field("Pay-to Post Code"; Rec."Pay-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pay-to Post Code/City';
                    ToolTip = 'Specifies the post code of the pay to vendor.';
                }
                field("Pay-to City"; Rec."Pay-to City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of the pay to vendor.';
                }
                field("Pay-to Contact"; Rec."Pay-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact of the pay to vendor.';
                }
                field("No. of Archived Versions2"; Rec."No. of Archived Versions")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total number of archived versions of the document.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Secifies the shortcut dimension 1 code.';

                    trigger OnValidate()
                    begin
                        ShortcutDimension1CodeOnAfterV();
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Shortcut Dimension 2 Code.';

                    trigger OnValidate()
                    begin
                        ShortcutDimension2CodeOnAfterV();
                    end;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment term used in the document.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the due date of the order as per payment terms.';
                }
                field("Payment Discount %"; Rec."Payment Discount %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the discount on payment, if any.';
                }
                field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the discount amount of the payment as per discount percentage.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the method of payment.';
                }
                field("On Hold"; Rec."On Hold")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the document is on hold or not.';
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to name used for the document.';
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to address used for the document.';
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional address used for the document.';
                }

                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ship-to Post Code/City';
                    ToolTip = 'Specifies the ship to post code used for the document.';
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to city used for the document.';
                }

                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to contact used for the document.';
                }

                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type of the entry which will be applied with this document.';
                }

                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the entry which will be applied with this document.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code used in the document.';
                }
                field("Inbound Whse. Handling Time"; Rec."Inbound Whse. Handling Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the inbound warehouse handling time.';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shipment method code used in the document.';
                }
                field("Lead Time Calculation"; Rec."Lead Time Calculation")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculation time formula for lead time calculation.';
                }

                field("Requested Receipt Date"; Rec."Requested Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date by which delivery of finished good requested by company.';
                }

                field("Promised Receipt Date"; Rec."Promised Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date by which delivery of finished good promised by vendor.';
                }

                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of expected receipt of the material.';
                }

                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer code.';
                }

                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to code used for the document.';
                }
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the foreign currency code used in the document.';

                    trigger OnAssistEdit()
                    begin
                        ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Posting Date");
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec.Validate("Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.Update();
                        end;
                        Clear(ChangeExchangeRate);
                    end;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction type of the document.';
                }
                field("Transaction Specification"; Rec."Transaction Specification")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction specification if any.';
                }

                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transportation method mentioned in the document.';
                }

                field("Entry Point"; Rec."Entry Point")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry point.';
                }

                field("Area"; Rec."Area")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the area of the document.';
                }
            }
        }
        area(FactBoxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = PurchLines;
                SubPageLink = "Table ID Filter" = const(39), "Document Type Filter" = field("Document Type"), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                Image = "Order";
                action(List)
                {
                    Caption = 'List';
                    ToolTip = 'List';
                    Image = OpportunitiesList;
                    RunObject = page "Subcontracting Order List";
                    ShortCutKey = 'Shift+Ctrl+L';
                    ApplicationArea = Basic, Suite;
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    ToolTip = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F7';
                    ApplicationArea = Basic, Suite;
                    trigger OnAction()
                    begin
                        PurchSetup.Get();
                        if PurchSetup."Calc. Inv. Discount" then begin
                            CurrPage.PurchLines.Page.CalcInvDisc();
                            Commit();
                        end;
                        Rec.OpenPurchaseOrderStatistics();
                    end;
                }
                action(Card)
                {
                    Caption = 'Card';
                    ToolTip = 'Card';
                    Image = EditLines;
                    RunObject = Page "Vendor Card";
                    RunPageLink = "No." = field("Buy-from Vendor No.");
                    ShortCutKey = 'Shift+F7';
                    ApplicationArea = Basic, Suite;
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    ToolTip = 'comments';
                    Image = ViewComments;
                    RunObject = Page "Purch. Comment Sheet";
                    RunPageLink = "Document Type" = field("Document Type"),
                                  "No." = field("No.");
                    ApplicationArea = Basic, Suite;
                }

                action(Receipts)
                {
                    Caption = 'Receipts';
                    ToolTip = 'Receipts';
                    Image = PostedReceipts;
                    RunObject = Page "Posted Purchase Receipts";
                    RunPageLink = "Order No." = field("No.");
                    RunPageView = Sorting("Order No.");
                    ApplicationArea = Basic, Suite;
                }

                action(Invoices)
                {
                    Caption = 'Invoices';
                    ToolTip = 'Invoices';
                    Image = Invoice;
                    RunObject = Page "Posted Purchase Invoices";
                    RunPageLink = "Order No." = field("No.");
                    RunPageView = Sorting("Order No.");
                    ApplicationArea = Basic, Suite;
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    ToolTip = 'Dimensions';
                    Image = Dimensions;
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
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
                action("Copy Document")
                {
                    Caption = 'Copy Document';
                    ToolTip = 'Copy Document';
                    Ellipsis = true;
                    Image = CopyDocument;
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        CopyPurchDoc.SetPurchHeader(Rec);
                        CopyPurchDoc.RunModal();
                        Clear(CopyPurchDoc);
                    end;
                }
                action("Archi&ve Document")
                {
                    Caption = 'Archi&ve Document';
                    ToolTip = 'Archieve Document';
                    Image = Archive;
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        ArchiveManagement.ArchivePurchDocument(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action("Move Negative Lines")
                {
                    Caption = 'Move Negative Lines';
                    ToolTip = 'Move Negative Lines';
                    Ellipsis = true;
                    Image = MoveNegativeLines;
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        Clear(MoveNegPurchLines);
                        MoveNegPurchLines.SetPurchHeader(Rec);
                        MoveNegPurchLines.RunModal();
                        MoveNegPurchLines.ShowDocument();
                    end;
                }
                group("Drop Shipment")
                {
                    Caption = 'Drop Shipment';
                    Image = Delivery;
                    action("Get &Sales Order2")
                    {
                        Caption = 'Get &Sales Order';
                        ToolTip = 'Get Sales Order';
                        Ellipsis = true;
                        Image = "Order";
                        ApplicationArea = Basic, Suite;
                        RunObject = Codeunit "Purch.-Get Drop Shpt.";
                    }
                }
                group("Special Order")
                {
                    Caption = 'Special Order';
                    Image = SpecialOrder;
                    action("Get &Sales Order")
                    {
                        Caption = 'Get &Sales Order';
                        ToolTip = 'Get Sales Order';
                        Image = "Order";
                        ApplicationArea = Basic, Suite;

                        trigger OnAction()
                        var
                            PurchHeader: Record "Purchase Header";
                            DistIntegration: Codeunit "Dist. Integration";
                        begin
                            PurchHeader.Copy(Rec);
                            DistIntegration.GetSpecialOrders(PurchHeader);
                            Rec := PurchHeader;
                        end;
                    }
                }
                group(Warehouse)
                {
                    Caption = 'Warehouse';
                    Image = Warehouse;
                    action("Receipt Lines")
                    {
                        Caption = 'Receipt Lines';
                        ToolTip = 'Receipt Lines';
                        Image = ReceiptLines;
                        RunObject = Page "Whse. Receipt Lines";
                        RunPageLink = "Source Type" = Const(39),
                                      "Source Subtype" = field("Document Type"),
                                      "Source No." = field("No.");
                        ApplicationArea = Basic, Suite;
                        RunPageView = Sorting("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    }
                    action("Create Receipt")
                    {
                        Caption = 'Create Receipt';
                        ToolTip = 'Create Receipt';
                        ApplicationArea = Basic, Suite;
                        Image = Receipt;

                        trigger OnAction()
                        var
                            GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
                        begin
                            GetSourceDocInbound.CreateFromPurchOrder(Rec);
                        end;
                    }
                }
                action("Re&lease")
                {
                    Caption = 'Re&lease';
                    ToolTip = 'Release';
                    Image = ReleaseDoc;
                    ApplicationArea = Basic, Suite;
                    RunObject = Codeunit "Release Purchase Document";
                    ShortCutKey = 'Ctrl+F9';
                }
                action("Re&open")
                {
                    Caption = 'Re&open';
                    ToolTip = 'Reopen';
                    Image = ReOpen;
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    var
                        ReleasePurchDoc: Codeunit "Release Purchase Document";
                    begin
                        ReleasePurchDoc.Reopen(Rec);
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Test Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Test Report';
                    ToolTip = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintPurchHeader(Rec);
                    end;
                }
                action("P&ost")
                {
                    Caption = 'P&ost';
                    ToolTip = 'Post Document';
                    Ellipsis = true;
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = Basic, Suite;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        PostDocument(CODEUNIT::"Purch.-Post (Yes/No)");
                    end;
                }
                action("Post and &Print")
                {
                    Caption = 'Post and &Print';
                    ToolTip = 'Post and Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = Basic, Suite;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Purch.-Post + Print";
                    ShortCutKey = 'Shift+F9';
                }
                action("Post &Batch")
                {
                    Caption = 'Post &Batch';
                    ToolTip = 'Post Batch';
                    Ellipsis = true;
                    Image = PostBatch;
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        Report.RunModal(Report::"Batch Post Purchase Orders", true, true, Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Print)
            {
                Caption = 'Print';
                Image = Print;
                action("&Print")
                {
                    ApplicationArea = Suite;
                    Caption = '&Print';
                    Ellipsis = true;
                    Image = Print;
                    ToolTip = 'Prepare to print the document. The report request window for the document opens where you can specify what to include on the print-out.';

                    trigger OnAction()
                    var
                        PurchaseHeader: Record "Purchase Header";
                    begin
                        PurchaseHeader := Rec;
                        CurrPage.SetSelectionFilter(PurchaseHeader);
                        PurchaseHeader.PrintRecords(true);
                    end;
                }
            }
        }
    }


    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord();
        exit(Rec.ConfirmDeletion());
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if CurrPage.CAPTION <> '' then
            error(SubconOrderErr);
    end;

    local procedure BuyfromVendorNoOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    local procedure PaytoVendorNoOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    local procedure ShortcutDimension1CodeOnAfterV()
    begin
        CurrPage.PurchLines.Page.UpdateForm(true);
    end;

    local procedure ShortcutDimension2CodeOnAfterV()
    begin
        CurrPage.PurchLines.Page.UpdateForm(true);
    end;

    local procedure PostDocument(PostingCodeunitID: Integer)
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
    begin
        LinesInstructionMgt.PurchaseCheckAllLinesHaveQuantityAssigned(Rec);
        Rec.SendToPosting(PostingCodeunitID);
        CurrPage.Update(false);
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        CopyPurchDoc: Report "Copy Purchase Document";
        MoveNegPurchLines: Report "Move Negative Purchase Lines";
        ReportPrint: Codeunit "Test Report-Print";
        // DocPrint: Codeunit "Document-Print";
        ArchiveManagement: Codeunit ArchiveManagement;
        ChangeExchangeRate: Page "Change Exchange Rate";
        SubconOrderErr: Label 'Subcontracting Order can not be created manually.\Please Use Subcontracting work Sheet';
}
