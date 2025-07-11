// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Finance.GST.Sales;

pageextension 18144 "GST Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Ship-to Code")
        {
            field("Ship-to Customer"; Rec."Ship-to Customer")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the alternate customer code which will be used as Ship-to-Customer, this provision is only applicable for GST calculation of export customers.';
            }
        }
        addfirst("Tax Info")
        {
            field("Invoice Type"; Rec."Invoice Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the Invoice type as per GST law.';
            }
            field("Bill Of Export No."; Rec."Bill Of Export No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the bill of export number. It is a document number which is submitted to custom department .';
            }
            field("Bill Of Export Date"; Rec."Bill Of Export Date")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the entry date defined in bill of export document.';
            }
            field("E-Commerce Customer"; Rec."E-Commerce Customer")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the customer number for which merchant id has to be recorded.';
            }
            field("E-Comm. Merchant Id"; Rec."E-Comm. Merchant Id")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the merchant ID provided to customers by their payment processor.';
            }
            field("Reference Invoice No."; Rec."Reference Invoice No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the Reference Invoice number.';
            }
            field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies if the invoice is a GST invoice with or without payment of duty.';
            }
            field("GST Invoice"; Rec."GST Invoice")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies whether this transaction is related to GST.';
            }
            field("POS Out Of India"; Rec."POS Out Of India")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies if the place of supply of invoice is out of India.';
            }
            field("GST Bill-to State Code"; Rec."GST Bill-to State Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the bill-to state code of the customer on the sales document.';
            }
            field("GST Ship-to State Code"; Rec."GST Ship-to State Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the ship-to state code of the customer on the sales document.';
            }
            field("Location State Code"; Rec."Location State Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the sate code mentioned of the location used on the sales document.';
            }
            field("Nature of Supply"; Rec."Nature of Supply")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
            }
            field("GST Customer Type"; Rec."GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the type of the customer. For example, Registered, Unregistered, Export etc..';
            }
            field("Ship-to GST Customer Type"; Rec."Ship-to GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of the customer. For example, Registered/Unregistered/Export etc.';
            }
            field("Rate Change Applicable"; Rec."Rate Change Applicable")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies if rate change is applicable on the sales document.';
            }
            field("Supply Finish Date"; Rec."Supply Finish Date")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the supply finish date. For example, Before rate change/After rate change.';
            }
            field("Payment Date"; Rec."Payment Date")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the payment date. For example, Before rate change/After rate change.';
            }
            field("Vehicle No."; Rec."Vehicle No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the vehicle number on the sales document.';
            }
            field("Date of Removal"; Rec."Posting Date")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Date of Removal';
                ToolTip = 'Specifies the date of removal.';
            }
            field("Time of Removal"; Rec."Time of Removal")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the time of removal.';
            }
            field("Mode of Transport"; Rec."Mode of Transport")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the transportation mode e.g. by road, by air etc.';
            }
            field("Vehicle Type"; Rec."Vehicle Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the vehicle type on the sales document. For example, Regular/ODC.  ';
            }
            field("Distance (Km)"; Rec."Distance (Km)")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the distance on the sales document.';
            }
            field("E-Way Bill No."; Rec."E-Way Bill No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the E-way bill number on the sale document.';
            }
            field("Acknowledgement No."; Rec."Acknowledgement No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = MakeFieldUneditable;
                ToolTip = 'Specifies a unique number assigned by e-invoice portal.';
            }
            field("Acknowledgement Date"; Rec."Acknowledgement Date")
            {
                ApplicationArea = Basic, Suite;
                Editable = MakeFieldUneditable;
                ToolTip = 'Specifies the date of acknowledgement.';
            }
            field("IRN Hash"; Rec."IRN Hash")
            {
                ApplicationArea = Basic, Suite;
                Editable = MakeFieldUneditable;
                ToolTip = 'Specifies a unique number of 64 character generated by system.';
            }
            field("E-Inv. Cancelled Date"; Rec."E-Inv. Cancelled Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies e-invoice cancellation date.';
            }
            field("Cancel Reason"; Rec."Cancel Reason")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cancellation reason.';
            }
        }
        addafter(IncomingDocAttachFactBox)
        {
            part("QR Code"; "Sales Invoice QR Code")
            {
                Caption = 'QR Code';
                SubPageLink = "No." = field("No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        addafter(Print)
        {
            action("Generate IRN")
            {
                ApplicationArea = Basic, Suite;
                Image = UpdateDescription;
                ToolTip = 'Specifies the function which will generate IRN No.';
                trigger OnAction()
                var
                    eInvoiceManagement: Codeunit "e-Invoice Management";
                begin
                    if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Invoice Header") then begin
                        if Rec."GST Customer Type" in
                           [Rec."GST Customer Type"::Unregistered,
                            Rec."GST Customer Type"::" "]
                        then
                            Error(eInvoiceNotApplicableCustomerErr);

                        Clear(eInvoiceManagement);
                        eInvoiceManagement.GenerateIRN(Rec."No.", Database::"Sales Invoice Header");
                        CurrPage.Update();
                    end else
                        Error(eInvoiceNonGSTTransactionErr);
                end;
            }
            action("Cancel E-Invoice")
            {
                ApplicationArea = Basic, Suite;
                Image = Cancel;
                ToolTip = 'Specifies the function through which cancelled Json file will be generated.';
                trigger OnAction()
                var
                    SalesInvHeader: Record "Sales Invoice Header";
                    eInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
                    eInvoiceManagement: Codeunit "e-Invoice Management";
                begin
                    Rec.TestField("IRN Hash");
                    Rec.TestField("Cancel Reason");

                    if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Invoice Header") then begin
                        SalesInvHeader.Reset();
                        SalesInvHeader.SetRange("No.", Rec."No.");
                        if SalesInvHeader.FindFirst() then begin
                            Clear(eInvoiceJsonHandler);
                            SalesInvHeader.Mark(true);
                            eInvoiceJsonHandler.SetSalesInvHeader(SalesInvHeader);
                            eInvoiceJsonHandler.GenerateCanceledInvoice();
                        end;
                    end else
                        Error(eInvoiceNonGSTTransactionErr);
                end;
            }
            action("Generate E-Invoice")
            {
                ApplicationArea = Basic, Suite;
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Specifies the function through which Json file will be generated.';

                trigger OnAction()
                var
                    SalesInvHeader: Record "Sales Invoice Header";
                    eInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
                    eInvoiceManagement: Codeunit "e-Invoice Management";
                begin
                    if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Invoice Header") then begin
                        SalesInvHeader.Reset();
                        SalesInvHeader.SetRange("No.", Rec."No.");
                        if SalesInvHeader.FindFirst() then begin
                            Clear(eInvoiceJsonHandler);
                            SalesInvHeader.Mark(true);
                            eInvoiceJsonHandler.SetSalesInvHeader(SalesInvHeader);
                            eInvoiceJsonHandler.Run();
                        end;
                    end else
                        Error(eInvoiceNonGSTTransactionErr);
                end;
            }
            action("Generate QR Code")
            {
                ApplicationArea = Basic, Suite;
                Image = Ranges;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Specifies the function through which QR Code will be generated for B2C Transactions.';

                trigger OnAction()
                var
                    eInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
                begin
                    CheckQrCode(Rec."No.", Rec."QR Code".HasValue);
                    eInvoiceJsonHandler.GenerateEInvoiceQRCodeForB2CCustomer(Rec."No.", Database::"Sales Invoice Header");
                end;
            }
            action("Import E-Invoice Response")
            {
                ApplicationArea = Basic, Suite;
                Image = ImportCodes;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Specifies the function through which Json file can be imported.';

                trigger OnAction()
                var
                    eInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
                    eInvoiceManagement: Codeunit "e-Invoice Management";
                    RecRef: RecordRef;
                begin
                    if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Invoice Header") then begin
                        if Rec."GST Customer Type" in
                           [Rec."GST Customer Type"::Unregistered,
                            Rec."GST Customer Type"::" "]
                        then
                            Error(eInvoiceNotApplicableCustomerErr);

                        Clear(eInvoiceJsonHandler);
                        Clear(RecRef);
                        RecRef.GetTable(Rec);
                        eInvoiceJsonHandler.GetEInvoiceResponse(RecRef);
                        CurrPage.Update();
                    end else
                        Error(eInvoiceNonGSTTransactionErr);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        MakeFieldUneditable := not Rec.IsJSONImported;
    end;

    var
        MakeFieldUneditable: Boolean;
        eInvoiceNonGSTTransactionErr: Label 'E-Invoicing is not applicable for Non-GST Transactions.';
        eInvoiceNotApplicableCustomerErr: Label 'E-Invoicing is not applicable for Unregistered, Export and Deemed Export Customers.';
        QRCodeAlreadyExistErr: Label 'QR Code for the Invoice no. %1 is already been generated', Comment = '%1 = DocumentNo';

    local procedure CheckQrCode(DocumentNo: Text[20]; QRCodeHasValue: Boolean)
    begin
        if QRCodeHasValue then
            Error(QRCodeAlreadyExistErr, DocumentNo);
    End;
}
