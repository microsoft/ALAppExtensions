// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Team;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.EMail;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31016 "Purchase - Advance Letter CZZ"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PurchaseAdvanceLetter.rdl';
    Caption = 'Purchase - Advance Letter';
    PreviewMode = PrintLayout;
    UsageCategory = None;
    Permissions = tabledata "Purch. Adv. Letter Header CZZ" = m;

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
            dataitem("Sales & Receivables Setup"; "Sales & Receivables Setup")
            {
                DataItemTableView = sorting("Primary Key");
                column(LogoPositiononDocuments_SalesReceivablesSetup; Format("Logo Position on Documents", 0, 2))
                {
                }
                dataitem("General Ledger Setup"; "General Ledger Setup")
                {
                    DataItemTableView = sorting("Primary Key");
                    column(LCYCode_GeneralLedgerSetup; "LCY Code")
                    {
                    }
                }
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddress.Company(CompanyAddr, "Company Information");
            end;

            trigger OnPreDataItem()
            begin
                CalcFields(Picture);
            end;
        }
        dataitem("Purch. Advance Letter Header"; "Purch. Adv. Letter Header CZZ")
        {
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
            column(PaymentTermsLbl; PaymentTermsLbl)
            {
            }
            column(PaymentMethodLbl; PaymentMethodLbl)
            {
            }
            column(PurchaserLbl; PurchaserLbl)
            {
            }
            column(TotalLbl; TotalLbl)
            {
            }
            column(CreatorLbl; CreatorLbl)
            {
            }
            column(No_PurchSalesAdvanceLetterHeader; "No.")
            {
            }
            column(VATRegistrationNo_PurchAdvanceLetterHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_PurchAdvanceLetterHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_PurchAdvanceLetterHeaderCaption; FieldCaption("Registration No."))
            {
            }
            column(RegistrationNo_PurchAdvanceLetterHeader; "Registration No.")
            {
            }
            column(BankAccountNo_PurchAdvanceLetterHeaderCaption; FieldCaption("Bank Account No."))
            {
            }
            column(BankAccountNo_PurchAdvanceLetterHeader; "Bank Account No.")
            {
            }
            column(IBAN_PurchAdvanceLetterHeaderCaption; FieldCaption(IBAN))
            {
            }
            column(IBAN_PurchAdvanceLetterHeader; IBAN)
            {
            }
            column(BIC_PurchAdvanceLetterHeaderCaption; FieldCaption("SWIFT Code"))
            {
            }
            column(BIC_PurchAdvanceLetterHeader; "SWIFT Code")
            {
            }
            column(DocumentDate_PurchAdvanceLetterHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_PurchAdvanceLetterHeader; Format("Document Date"))
            {
            }
            column(PaymentTerms; PaymentTerms.Description)
            {
            }
            column(PaymentMethod; PaymentMethod.Description)
            {
            }
            column(CurrencyCode_PurchAdvanceLetterHeader; "Currency Code")
            {
            }
            column(DocFooterText; DocFooterText)
            {
            }
            column(VendAddr1; VendAddr[1])
            {
            }
            column(VendAddr2; VendAddr[2])
            {
            }
            column(VendAddr3; VendAddr[3])
            {
            }
            column(VendAddr4; VendAddr[4])
            {
            }
            column(VendAddr5; VendAddr[5])
            {
            }
            column(VendAddr6; VendAddr[6])
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(CopyNo; CopyNo)
                {
                }
                dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
                {
                    DataItemLink = Code = field("Purchaser Code");
                    DataItemLinkReference = "Purch. Advance Letter Header";
                    DataItemTableView = sorting(Code);
                    column(Name_SalespersonPurchaser; Name)
                    {
                    }
                    column(EMail_SalespersonPurchaser; "E-Mail")
                    {
                    }
                    column(PhoneNo_SalespersonPurchaser; "Phone No.")
                    {
                    }
                }
                dataitem("Purch. Advance Letter Line"; "Purch. Adv. Letter Line CZZ")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Purch. Advance Letter Header";
                    DataItemTableView = sorting("Document No.", "Line No.");
                    column(LineNo_PurchAdvanceLetterLine; "Line No.")
                    {
                    }
                    column(Description_PurchAdvanceLetterLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_PurchAdvanceLetterLine; Description)
                    {
                    }
                    column(VAT_PurchAdvanceLetterLineCaption; FieldCaption("VAT %"))
                    {
                    }
                    column(VAT_PurchAdvanceLetterLine; "VAT %")
                    {
                    }
                    column(AmountIncludingVAT_PurchAdvanceLetterLineCaption; FieldCaption("Amount Including VAT"))
                    {
                    }
                    column(AmountIncludingVAT_PurchAdvanceLetterLine; "Amount Including VAT")
                    {
                    }
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLinkReference = "Purch. Advance Letter Header";
                    DataItemTableView = sorting("User ID");
                    dataitem(Employee; Employee)
                    {
                        DataItemLink = "No." = field("Employee No. CZL");
                        DataItemTableView = sorting("No.");
                        column(FullName_Employee; Employee.FullName())
                        {
                        }
                        column(PhoneNo_Employee; Employee."Phone No.")
                        {
                        }
                        column(CompanyEMail_Employee; Employee."Company E-Mail")
                        {
                        }
                    }

                    trigger OnPreDataItem()
                    begin
                        SetRange("User ID", UserId());
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        CopyNo := 1
                    else
                        CopyNo += 1;
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCop) + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;

                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode() then
                        Codeunit.Run(Codeunit::"Purch. Adv. Letter-Printed CZZ", "Purch. Advance Letter Header");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code";

                FormatAddress.FormatAddr(VendAddr, "Pay-to Name", "Pay-to Name 2", "Pay-to Contact", "Pay-to Address", "Pay-to Address 2",
                  "Pay-to City", "Pay-to Post Code", "Pay-to County", "Pay-to Country/Region Code");

                FormatDocumentFields("Purch. Advance Letter Header");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoOfCopies; NoOfCop)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies the number of copies to print.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        VATIdentLbl = 'VAT Recapitulation';
        VATPercentLbl = 'VAT %';
        VATBaseLbl = 'VAT Base';
        VATAmtLbl = 'VAT Amount';
    }

    var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        CompanyAddr: array[8] of Text[100];
        VendAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        NoOfCop: Integer;
        CopyNo: Integer;
        NoOfLoops: Integer;
        DocumentLbl: Label 'Advance Letter';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        PurchaserLbl: Label 'Purchaser';
        TotalLbl: Label 'total';
        CreatorLbl: Label 'Posted by';

    local procedure FormatDocumentFields(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, PurchAdvLetterHeaderCZZ."Payment Terms Code", PurchAdvLetterHeaderCZZ."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, PurchAdvLetterHeaderCZZ."Payment Method Code", PurchAdvLetterHeaderCZZ."Language Code");

        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(PurchAdvLetterHeaderCZZ."Language Code");
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
