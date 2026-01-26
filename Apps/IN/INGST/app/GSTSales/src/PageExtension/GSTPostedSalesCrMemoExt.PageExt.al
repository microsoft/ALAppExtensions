// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Finance.GST.Sales;

pageextension 18143 "GST Posted Sales Cr. Memo Ext" extends "Posted Sales Credit Memo"
{
    layout
    {
        addbefore("Location Code")
        {
            field("Ship-to Customer"; Rec."Ship-to Customer")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Ship to Customer code on the sales document.';
            }
        }
        addfirst("Tax Info")
        {
            field("GST Bill-to State Code"; Rec."GST Bill-to State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bill-to state code of the customer on the sales document.';
            }
            field("GST Ship-to State Code"; Rec."GST Ship-to State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the ship-to state code of the customer on the sales document.';
            }
            field("Location State Code"; Rec."Location State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the sate code mentioned in location on the sales document.';
            }
            field("Location GST Reg. No."; Rec."Location GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST registration number of the Location specified on the Sales document.';
            }
            field("Customer GST Reg. No."; Rec."Customer GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST registration number of the customer specified on the Sales document.';
            }
            field("Ship-to GST Reg. No."; Rec."Ship-to GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the ship to GST registration number of the customer specified on the Sales document.';
            }
            field("Nature of Supply"; Rec."Nature of Supply")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
            }
            field("GST Customer Type"; Rec."GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of the customer. For example, Registered, Unregistered, Export etc..';
            }
            field("Ship-to GST Customer Type"; Rec."Ship-to GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Ship to GST Customer Type mentioned on the sales document.';
            }
            field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the invoice is a GST invoice with or without payment of duty.';
            }
            field("Invoice Type"; Rec."Invoice Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Invoice type as per GST law.';
            }
            field("Bill Of Export No."; Rec."Bill Of Export No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bill of export number. It is a document number which is submitted to custom department .';
            }
            field("Bill Of Export Date"; Rec."Bill Of Export Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the entry date defined in bill of export document.';
            }
            field("e-Commerce Customer"; Rec."e-Commerce Customer")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the customer number for which merchant id has to be recorded.';
            }
            field("E-Comm. Merchant Id"; Rec."E-Comm. Merchant Id")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the merchant ID provided to customers by their payment processor.';
            }
            field("Distance (Km)"; Rec."Distance (Km)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the distance.';
            }
            field("POS Out Of India"; Rec."POS Out Of India")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the place of supply of invoice is out of India.';
            }
            field("Reference Invoice No."; Rec."Reference Invoice No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Reference Invoice number.';
            }
            field("Sale Return Type"; Rec."Sale Return Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the sale return type. For example, Sales cancellation.';
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
            part("QR Code"; "Sales Cr Memo QR Code")
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
                    if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Cr.Memo Header") then begin
                        if Rec."GST Customer Type" in
                           [Rec."GST Customer Type"::Unregistered,
                            Rec."GST Customer Type"::" "]
                        then
                            Error(eInvoiceNotApplicableCustomerErr);

                        Clear(eInvoiceManagement);
                        eInvoiceManagement.GenerateIRN(Rec."No.", Database::"Sales Cr.Memo Header");
                        CurrPage.Update();
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
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                    eInvoiceManagement: Codeunit "e-Invoice Management";
                    eInvoiceJsonHandler: Codeunit "e-Invoice Json Handler";
                begin
                    if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Cr.Memo Header") then begin
                        SalesCrMemoHeader.Reset();
                        SalesCrMemoHeader.SetRange("No.", Rec."No.");
                        if SalesCrMemoHeader.FindFirst() then begin
                            Clear(eInvoiceJsonHandler);
                            SalesCrMemoHeader.Mark(true);
                            eInvoiceJsonHandler.SetCrMemoHeader(SalesCrMemoHeader);
                            eInvoiceJsonHandler.Run();
                        end;
                    end else
                        Error(eInvoiceNonGSTTransactionErr);
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
                    if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Cr.Memo Header") then begin
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
}
