// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.History;

using Microsoft.Finance.GST.Services;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

pageextension 18451 "GST Posted Service Invoice" extends "Posted Service Invoice"
{
    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = ServInvLines;
                SubPageLink = "Table ID Filter" = const(5993), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("No. Printed")
        {
            field("GST Reason Type"; Rec."GST Reason Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the reason of return or credit memo of a posted document where gst is applicable. For example Deficiency in Service/Correction in Invoice etc.';
            }
        }
        addafter("Foreign Trade")
        {
            Group(GST)
            {
                field("Nature of Supply"; Rec."Nature of Supply")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                }
                field("GST Customer Type"; Rec."GST Customer Type")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the type of the customer. For example, Registered/Unregistered/Export/Exempted/SEZ Unit/SEZ Development etc.';
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the invoice type on the service document. For example, Bill of supply, Export, Supplementary, Debit Note, Non-GST and Taxable.';
                }
                field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether with or without payment of duty.';
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
                field("Reference Invoice No."; Rec."Reference Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Reference Invoice number.';
                }
                field("Rate Change Applicable"; Rec."Rate Change Applicable")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if rate change is applicable on the service document.';
                }
                field("Supply Finish Date"; Rec."Supply Finish Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the supply finish date. For example, Before rate change/After rate change.';
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment date. For example, Before rate change/After rate change.';
                }
                field("GST Inv. Rounding Precision"; Rec."GST Inv. Rounding Precision")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Rounding Precision on the service document.';
                }
                field("GST Inv. Rounding Type"; Rec."GST Inv. Rounding Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Rounding Type on the service document.';
                }
                field("POS Out Of India"; Rec."POS Out Of India")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the place of supply of invoice is out of India.';
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

        }
        addafter(TaxInformation)
        {
            part("QR Code"; "Service Invoice QR Code")
            {
                Caption = 'QR Code';
                SubPageLink = "No." = field("No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        addafter("&Print")
        {
            action("Generate IRN")
            {
                ApplicationArea = Basic, Suite;
                Image = UpdateDescription;
                ToolTip = 'Specifies the function which will generate IRN No.';

                trigger OnAction()
                var
                    eInvoiceManagementforser: Codeunit "e-Invoice Management for Ser.";
                begin
                    if eInvoiceManagementforser.IsGSTApplicable(Rec."No.", Database::"Service Invoice Header") then begin
                        if Rec."GST Customer Type" in
                           [Rec."GST Customer Type"::Unregistered,
                            Rec."GST Customer Type"::" "]
                        then
                            Error(eInvoiceNotApplicableCustomerErr);

                        Clear(eInvoiceManagementforser);
                        eInvoiceManagementforser.GenerateIRN(Rec."No.", Database::"Service Invoice Header");
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
                    ServiceInvHeader: Record "Service Invoice Header";
                    eInvoiceJsonHandlerforser: Codeunit "e-Invoice Json Handler for Ser";
                    eInvoiceManagementforser: Codeunit "e-Invoice Management for Ser.";
                begin
                    Rec.TestField("IRN Hash");
                    Rec.TestField("Cancel Reason");

                    if eInvoiceManagementforser.IsGSTApplicable(Rec."No.", Database::"Service Invoice Header") then begin
                        ServiceInvHeader.Reset();
                        ServiceInvHeader.SetRange("No.", Rec."No.");
                        if ServiceInvHeader.FindFirst() then begin
                            Clear(eInvoiceJsonHandlerforser);
                            ServiceInvHeader.Mark(true);
                            eInvoiceJsonHandlerforser.SetServiceInvHeader(ServiceInvHeader);
                            eInvoiceJsonHandlerforser.GenerateCanceledInvoice();
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
                    ServiceInvHeader: Record "Service Invoice Header";
                    eInvoiceJsonHandlerforSer: Codeunit "e-Invoice Json Handler for Ser";
                    eInvoiceManagementforSer: Codeunit "e-Invoice Management for Ser.";
                begin
                    if eInvoiceManagementforSer.IsGSTApplicable(Rec."No.", Database::"Service Invoice Header") then begin
                        ServiceInvHeader.Reset();
                        ServiceInvHeader.Get(Rec."No.");
                        eInvoiceJsonHandlerforSer.SetServiceInvHeader(ServiceInvHeader);
                        eInvoiceJsonHandlerforSer.Run();
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
                    eInvoiceJsonHandlerforSer: Codeunit "e-Invoice Json Handler for Ser";
                    eInvoiceManagementforSer: Codeunit "e-Invoice Management for Ser.";
                    RecRef: RecordRef;
                begin
                    if eInvoiceManagementforSer.IsGSTApplicable(Rec."No.", Database::"Service Invoice Header") then begin
                        if Rec."GST Customer Type" in
                           [Rec."GST Customer Type"::Unregistered,
                            Rec."GST Customer Type"::" "]
                        then
                            Error(eInvoiceNotApplicableCustomerErr);

                        Clear(eInvoiceJsonHandlerforSer);
                        Clear(RecRef);
                        RecRef.GetTable(Rec);
                        eInvoiceJsonHandlerforSer.GetEInvoiceResponse(RecRef);
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
