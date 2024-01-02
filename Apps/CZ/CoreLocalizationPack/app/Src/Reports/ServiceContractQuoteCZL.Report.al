// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Customer;
using Microsoft.Service.Comment;
using Microsoft.Service.Contract;
using Microsoft.Service.Setup;
using Microsoft.Utilities;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31195 "Service Contract Quote CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/ServiceContractQuote.rdl';
    Caption = 'Service Contract Quote';
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
            column(PhoneNo_CompanyInformation; "Phone No.")
            {
            }
            column(EMail_CompanyInformation; "E-Mail")
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
        dataitem("Service Contract Header"; "Service Contract Header")
        {
            DataItemTableView = sorting("Contract Type", "Contract No.") where("Contract Type" = const(Quote));
            RequestFilterFields = "Contract No.", "Customer No.";
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
            column(SalespersonLbl; SalespersonLbl)
            {
            }
            column(PrintedByLbl; PrintedByLbl)
            {
            }
            column(VATRegistrationNoLbl; VATRegistrationNoLbl)
            {
            }
            column(RegistrationNoLbl; RegistrationNoLbl)
            {
            }
            column(VATRegistrationNo; Customer."VAT Registration No.")
            {
            }
            column(RegistrationNo; Customer."Registration Number")
            {
            }
            column(ContractNo_ServiceContractHeader; "Contract No.")
            {
            }
            column(YourReference_ServiceContractHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_ServiceContractHeader; "Your Reference")
            {
            }
            column(PhoneNo_ServiceContractHeaderCaption; FieldCaption("Phone No."))
            {
            }
            column(PhoneNo_ServiceContractHeader; "Phone No.")
            {
            }
            column(EMail_ServiceContractHeaderCaption; FieldCaption("E-Mail"))
            {
            }
            column(EMail_ServiceContractHeader; "E-Mail")
            {
            }
            column(AcceptBefore_ServiceContractHeaderCaption; FieldCaption("Accept Before"))
            {
            }
            column(AcceptBefore_ServiceContractHeader; "Accept Before")
            {
            }
            column(StartingDate_ServiceContractHeaderCaption; FieldCaption("Starting Date"))
            {
            }
            column(StartingDate_ServiceContractHeader; Format("Starting Date"))
            {
            }
            column(InvoicePeriod_ServiceContractHeaderCaption; FieldCaption("Invoice Period"))
            {
            }
            column(InvoicePeriod_ServiceContractHeader; "Invoice Period")
            {
            }
            column(NextInvoiceDate_ServiceContractHeaderCaption; FieldCaption("Next Invoice Date"))
            {
            }
            column(NextInvoiceDate_ServiceContractHeader; Format("Next Invoice Date"))
            {
            }
            column(AnnualAmount_ServiceContractHeaderCaption; FieldCaption("Annual Amount"))
            {
            }
            column(AnnualAmount_ServiceContractHeader; "Annual Amount")
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
                    DataItemLinkReference = "Service Contract Header";
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
                dataitem("Service Contract Line"; "Service Contract Line")
                {
                    DataItemLink = "Contract Type" = field("Contract Type"), "Contract No." = field("Contract No.");
                    DataItemLinkReference = "Service Contract Header";
                    DataItemTableView = sorting("Contract Type", "Contract No.", "Line No.");
                    column(ContractNo_ServiceContractLine; "Contract No.")
                    {
                    }
                    column(LineNo_ServiceContractLine; "Line No.")
                    {
                    }
                    column(ServiceItemNo_ServiceContractLineCaption; FieldCaption("Service Item No."))
                    {
                    }
                    column(ServiceItemNo_ServiceContractLine; "Service Item No.")
                    {
                    }
                    column(SerialNo_ServiceContractLineCaption; FieldCaption("Serial No."))
                    {
                    }
                    column(SerialNo_ServiceContractLine; "Serial No.")
                    {
                    }
                    column(Description_ServiceContractLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_ServiceContractLine; Description)
                    {
                    }
                    column(ItemNo_ServiceContractLineCaption; FieldCaption("Item No."))
                    {
                    }
                    column(ItemNo_ServiceContractLine; "Item No.")
                    {
                    }
                    column(UnitofMeasureCode_ServiceContractLineCaption; FieldCaption("Unit of Measure Code"))
                    {
                    }
                    column(UnitofMeasureCode_ServiceContractLine; "Unit of Measure Code")
                    {
                    }
                    column(ResponseTimeHours_ServiceContractLineCaption; FieldCaption("Response Time (Hours)"))
                    {
                    }
                    column(ResponseTimeHours_ServiceContractLine; "Response Time (Hours)")
                    {
                    }
                    column(ServicePeriod_ServiceContractLineCaption; FieldCaption("Service Period"))
                    {
                    }
                    column(ServicePeriod_ServiceContractLine; "Service Period")
                    {
                    }
                    column(LineValue_ServiceContractLineCaption; FieldCaption("Line Value"))
                    {
                    }
                    column(LineValue_ServiceContractLine; "Line Value")
                    {
                    }
                    dataitem("Service Comment Line"; "Service Comment Line")
                    {
                        DataItemLink = "Table Subtype" = field("Contract Type"), "Table Line No." = field("Line No."), "No." = field("Contract No.");
                        DataItemTableView = sorting("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.") where("Table Name" = filter("Service Contract"));
                        column(Date_ServiceCommentLine; Date)
                        {
                        }
                        column(Comment_ServiceCommentLine; Comment)
                        {
                        }
                    }
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLinkReference = "Service Contract Header";
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

                FormatAddress.ServContractSellto(CustAddr, "Service Contract Header");
                FormatAddress.ServContractShipto(ShipToAddr, "Service Contract Header");
                DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText("Language Code");
                if not Customer.Get("Customer No.") then
                    Customer.Init();

                if LogInteraction and not IsReportInPreviewMode() then
                    if "Contact No." <> '' then
                        SegManagement.LogDocument(
                          24, "Contract No.", 0, 0, Database::Contact, "Contact No.", "Salesperson Code", '', Description, '')
                    else
                        SegManagement.LogDocument(
                          24, "Contract No.", 0, 0, Database::Customer, "Customer No.", "Salesperson Code", '', Description, '');
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
                    field(LogInteractionCZL; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to record the service contract quote you print as Interactions and add them to the Interaction Log Entry table.';
                    }
                }
            }
        }
        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            InitLogInteraction();
            LogInteractionEnable := LogInteraction;
        end;
    }

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        Customer: Record Customer;
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        SegManagement: Codeunit SegManagement;
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        LogInteraction: Boolean;
        LogInteractionEnable: Boolean;
        DocumentLbl: Label 'Service Contract Quote';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        SalespersonLbl: Label 'Salesperson';
        PrintedByLbl: Label 'Printed by';
        VATRegistrationNoLbl: Label 'VAT Registration No.';
        RegistrationNoLbl: Label 'Registration No.';

    procedure InitializeRequest(NoOfCopiesFrom: Integer; LogInteractionFrom: Boolean)
    begin
        NoOfCopies := NoOfCopiesFrom;
        LogInteraction := LogInteractionFrom;
    end;

    local procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Service Contract Quote") <> '';
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
