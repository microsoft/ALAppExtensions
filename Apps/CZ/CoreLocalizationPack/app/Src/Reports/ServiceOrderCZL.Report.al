// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Team;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.HumanResources.Employee;
using Microsoft.Service.Comment;
using Microsoft.Service.Setup;
using Microsoft.Utilities;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31194 "Service Order CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/ServiceOrder.rdl';
    Caption = 'Service Order';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(RegistrationNo_CompanyInformation; "Registration No.")
            {
            }
            column(VATRegistrationNo_CompanyInformation; "VAT Registration No.")
            {
            }
            column(HomePage_CompanyInformation; "Home Page")
            {
            }
            column(Picture_CompanyInformation; Picture)
            {
            }
            dataitem("Service Mgt. Setup"; "Service Mgt. Setup")
            {
                DataItemTableView = sorting("Primary Key");
                column(LogoPositiononDocuments_ServiceMgtSetup; Format("Logo Position on Documents", 0, 2))
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                FormatAddress.Company(CompanyAddr, "Company Information");
            end;
        }
        dataitem("Service Header"; "Service Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Order));
            RequestFilterFields = "No.", "Customer No.";
            column(DocumentLbl; DocumentLbl)
            {
            }
            column(PageLbl; PageLbl)
            {
            }
            column(CopyLbl; CopyLbl)
            {
            }
            column(VendorLbl; VendLbl)
            {
            }
            column(CustomerLbl; CustLbl)
            {
            }
            column(ShipToLbl; ShipToLbl)
            {
            }
            column(PaymentTermsLbl; PaymentTermsLbl)
            {
            }
            column(PaymentMethodLbl; PaymentMethodLbl)
            {
            }
            column(ShipmentMethodLbl; ShipmentMethodLbl)
            {
            }
            column(SalespersonLbl; SalespersonLbl)
            {
            }
            column(PrintedByLbl; PrintedByLbl)
            {
            }
            column(No_ServiceHeader; "No.")
            {
            }
            column(VATRegistrationNo_ServiceHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_ServiceHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_ServiceHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_ServiceHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_ServiceHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_ServiceHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_ServiceHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_ServiceHeader; "IBAN CZL")
            {
            }
            column(SWIFTCode_ServiceHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(SWIFTCode_ServiceHeader; "SWIFT Code CZL")
            {
            }
            column(OrderDate_ServiceHeaderCaption; FieldCaption("Order Date"))
            {
            }
            column(OrderDate_ServiceHeader; Format("Order Date"))
            {
            }
            column(YourReference_ServiceHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_ServiceHeader; "Your Reference")
            {
            }
            column(ContractNo_ServiceHeaderCaption; FieldCaption("Contract No."))
            {
            }
            column(ContractNo_ServiceHeader; "Contract No.")
            {
            }
            column(PaymentTerms; PaymentTerms.Description)
            {
            }
            column(PaymentMethod; PaymentMethod.Description)
            {
            }
            column(ShipmentMethod; ShipmentMethod.Description)
            {
            }
            column(DocFooterText; DocFooterText)
            {
            }
            column(CustAddr1; CustAddr[1])
            {
            }
            column(CustAddr2; CustAddr[2])
            {
            }
            column(CustAddr3; CustAddr[3])
            {
            }
            column(CustAddr4; CustAddr[4])
            {
            }
            column(CustAddr5; CustAddr[5])
            {
            }
            column(CustAddr6; CustAddr[6])
            {
            }
            column(ShipToAddr1; ShipToAddr[1])
            {
            }
            column(ShipToAddr2; ShipToAddr[2])
            {
            }
            column(ShipToAddr3; ShipToAddr[3])
            {
            }
            column(ShipToAddr4; ShipToAddr[4])
            {
            }
            column(ShipToAddr5; ShipToAddr[5])
            {
            }
            column(ShipToAddr6; ShipToAddr[6])
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(CopyNo; Number)
                {
                }
                dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
                {
                    DataItemLink = Code = field("Salesperson Code");
                    DataItemLinkReference = "Service Header";
                    DataItemTableView = sorting(Code);
                    column(Name_SalespersonPurchaser; Name)
                    {
                    }
                    column(PhoneNo_SalespersonPurchaser; "Phone No.")
                    {
                    }
                    column(EMail_SalespersonPurchaser; "E-Mail")
                    {
                    }
                }
                dataitem("Service Item Line"; "Service Item Line")
                {
                    DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                    DataItemLinkReference = "Service Header";
                    DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                    column(ServiceItemLinesLbl; ServiceItemLinesLbl)
                    {
                    }
                    column(DocumentNo_ServiceItemLine; "Document No.")
                    {
                    }
                    column(LineNo_ServiceItemLine; "Line No.")
                    {
                    }
                    column(ServiceItemNo_ServiceItemLineCaption; FieldCaption("Service Item No."))
                    {
                    }
                    column(ServiceItemNo_ServiceItemLine; "Service Item No.")
                    {
                    }
                    column(ServiceItemGroupCode_ServiceItemLineCaption; FieldCaption("Service Item Group Code"))
                    {
                    }
                    column(ServiceItemGroupCode_ServiceItemLine; "Service Item Group Code")
                    {
                    }
                    column(SerialNo_ServiceItemLineCaption; FieldCaption("Serial No."))
                    {
                    }
                    column(SerialNo_ServiceItemLine; "Serial No.")
                    {
                    }
                    column(Description_ServiceItemLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_ServiceItemLine; Description)
                    {
                    }
                    column(LoanerNo_ServiceItemLineCaption; FieldCaption("Loaner No."))
                    {
                    }
                    column(LoanerNo_ServiceItemLine; "Loaner No.")
                    {
                    }
                    column(ServiceShelfNo_ServiceItemLineCaption; FieldCaption("Service Shelf No."))
                    {
                    }
                    column(ServiceShelfNo_ServiceItemLine; "Service Shelf No.")
                    {
                    }
                    column(Warranty_ServiceItemLineCaption; FieldCaption(Warranty))
                    {
                    }
                    column(Warranty_ServiceItemLine; Format(Warranty))
                    {
                    }
                    column(RepairStatusCode_ServiceItemLineCaption; FieldCaption("Repair Status Code"))
                    {
                    }
                    column(RepairStatusCode_ServiceItemLine; "Repair Status Code")
                    {
                    }
                    column(ResponseDate_ServiceItemLineCaption; FieldCaption("Response Date"))
                    {
                    }
                    column(ResponseDate_ServiceItemLine; Format("Response Date"))
                    {
                    }
                    column(ResponseTime_ServiceItemLineCaption; FieldCaption("Response Time"))
                    {
                    }
                    column(ResponseTime_ServiceItemLine; "Response Time")
                    {
                    }
                    dataitem("Fault Comment"; "Service Comment Line")
                    {
                        DataItemLink = "Table Subtype" = field("Document Type"), "No." = field("Document No."), "Table Line No." = field("Line No.");
                        DataItemTableView = sorting("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.") where("Table Name" = const("Service Header"), Type = const(Fault));
                        column(FaultCommentsLbl; FaultCommentsLbl)
                        {
                        }
                        column(Number_FaultComment; Number1)
                        {
                        }
                        column(Comment_FaultComment; Comment)
                        {
                        }
                        trigger OnAfterGetRecord()
                        begin
                            Number2 := 0;
                            Number1 += 1;
                        end;
                    }
                    dataitem("Resolution Comment"; "Service Comment Line")
                    {
                        DataItemLink = "Table Subtype" = field("Document Type"), "No." = field("Document No."), "Table Line No." = field("Line No.");
                        DataItemTableView = sorting("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.") where("Table Name" = const("Service Header"), Type = const(Resolution));
                        column(ResolutionCommentsLbl; ResolutionCommentsLbl)
                        {
                        }
                        column(Number_ResolutionComment; Number2)
                        {
                        }
                        column(Comment_ResolutionComment; Comment)
                        {
                        }
                        trigger OnAfterGetRecord()
                        begin
                            Number1 := 0;
                            Number2 += 1;
                        end;
                    }
                }
                dataitem("Service Line"; "Service Line")
                {
                    DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                    DataItemLinkReference = "Service Header";
                    DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                    column(ServiceLineLbl; ServiceLineLbl)
                    {
                    }
                    column(AmountLbl; AmountLbl)
                    {
                    }
                    column(GrossAmountLbl; GrossAmountLbl)
                    {
                    }
                    column(TotalLbl; TotalLbl)
                    {
                    }
                    column(DocumentNo_ServiceLine; "Document No.")
                    {
                    }
                    column(LineNo_ServiceLine; "Line No.")
                    {
                    }
                    column(LineAmount_ServiceLine; "Line Amount")
                    {
                    }
                    column(AmountIncludingVAT_ServiceLine; "Amount Including VAT")
                    {
                    }
                    column(ServiceItemSerialNo_ServiceLineCaption; FieldCaption("Service Item Serial No."))
                    {
                    }
                    column(ServiceItemSerialNo_ServiceLine; "Service Item Serial No.")
                    {
                    }
                    column(Type_ServiceLineCaption; FieldCaption(Type))
                    {
                    }
                    column(Type_ServiceLine; Type)
                    {
                    }
                    column(No_ServiceLineCaption; FieldCaption("No."))
                    {
                    }
                    column(No_ServiceLine; "No.")
                    {
                    }
                    column(Description_ServiceLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_ServiceLine; Description)
                    {
                    }
                    column(UnitPrice_ServiceLineCaption; FieldCaption("Unit Price"))
                    {
                    }
                    column(UnitPrice_ServiceLine; "Unit Price")
                    {
                    }
                    column(LineDiscount_ServiceLineCaption; FieldCaption("Line Discount %"))
                    {
                    }
                    column(LineDiscount_ServiceLine; "Line Discount %")
                    {
                    }
                    column(VariantCode_ServiceLineCaption; FieldCaption("Variant Code"))
                    {
                    }
                    column(VariantCode_ServiceLine; "Variant Code")
                    {
                    }
                    column(Quantity_ServiceLineCaption; FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_ServiceLine; Quantity)
                    {
                    }
                    column(QtytoConsume_ServiceLineCaption; FieldCaption("Qty. to Consume"))
                    {
                    }
                    column(QtytoConsume_ServiceLine; "Qty. to Consume")
                    {
                    }
                    column(QuantityConsumed_ServiceLineCaption; FieldCaption("Quantity Consumed"))
                    {
                    }
                    column(QuantityConsumed_ServiceLine; "Quantity Consumed")
                    {
                    }
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLinkReference = "Service Header";
                    DataItemTableView = sorting("User ID");
                    dataitem(Employee; Employee)
                    {
                        DataItemLink = "No." = field("Employee No. CZL");
                        DataItemTableView = sorting("No.");
                        column(FullName_Employee; FullName())
                        {
                        }
                        column(PhoneNo_Employee; "Phone No.")
                        {
                        }
                        column(CompanyEMail_Employee; "Company E-Mail")
                        {
                        }
                    }
                    trigger OnPreDataItem()
                    begin
                        "User Setup".SetRange("User ID", UserId());
                    end;
                }
                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode() then
                        Codeunit.Run(Codeunit::"Service-Printed", "Service Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddressFields("Service Header");
                FormatDocumentFields("Service Header");
            end;
        }
    }
    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoOfCopiesCZL; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies the number of copies to print.';
                    }
                }
            }
        }
    }

    var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        ShipmentMethod: Record "Shipment Method";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        Number1: Integer;
        Number2: Integer;
        DocumentLbl: Label 'Service Order';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        ShipmentMethodLbl: Label 'Shipment Method';
        SalespersonLbl: Label 'Salesperson';
        PrintedByLbl: Label 'Printed by';
        ServiceItemLinesLbl: Label 'Service Item Lines';
        ServiceLineLbl: Label 'Service Line';
        FaultCommentsLbl: Label 'Fault Comments';
        ResolutionCommentsLbl: Label 'Resolution Comments';
        AmountLbl: Label 'Amount';
        GrossAmountLbl: Label 'Gross Amount';
        TotalLbl: Label 'Total';

    procedure InitializeRequest(NoOfCopiesFrom: Integer)
    begin
        NoOfCopies := NoOfCopiesFrom;
    end;

    local procedure FormatDocumentFields(ServiceHeader: Record "Service Header")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, ServiceHeader."Payment Terms Code", ServiceHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, ServiceHeader."Shipment Method Code", ServiceHeader."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, ServiceHeader."Payment Method Code", ServiceHeader."Language Code");
        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(ServiceHeader."Language Code");
    end;

    local procedure FormatAddressFields(ServiceHeader: Record "Service Header")
    begin
        FormatAddress.ServiceOrderSellto(CustAddr, ServiceHeader);
        FormatAddress.ServiceHeaderShipTo(ShipToAddr, ServiceHeader);
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
