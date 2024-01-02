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

report 31014 "Sales - Advance Letter CZZ"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/SalesAdvanceLetter.rdl';
    Caption = 'Sales - Advance Letter';
    PreviewMode = PrintLayout;
    UsageCategory = None;
    Permissions = tabledata "Sales Adv. Letter Header CZZ" = m;
    WordMergeDataItem = "Sales Advance Letter Header";

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
        dataitem("Sales Advance Letter Header"; "Sales Adv. Letter Header CZZ")
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
            column(VendLbl; VendLbl)
            {
            }
            column(CustLbl; CustLbl)
            {
            }
            column(PaymentTermsLbl; PaymentTermsLbl)
            {
            }
            column(PaymentMethodLbl; PaymentMethodLbl)
            {
            }
            column(SalespersonLbl; SalespersonLbl)
            {
            }
            column(TotalLbl; TotalLbl)
            {
            }
            column(CreatorLbl; CreatorLbl)
            {
            }
            column(GreetingLbl; GreetingLbl)
            {
            }
            column(BodyLbl; BodyLbl)
            {
            }
            column(ClosingLbl; ClosingLbl)
            {
            }
            column(DocumentNoLbl; DocumentNoLbl)
            {
            }
            column(No_SalesAdvanceLetterHeader; "No.")
            {
            }
            column(VATRegistrationNo_SalesAdvanceLetterHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_SalesAdvanceLetterHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_SalesAdvanceLetterHeaderCaption; FieldCaption("Registration No."))
            {
            }
            column(RegistrationNo_SalesAdvanceLetterHeader; "Registration No.")
            {
            }
            column(BankAccountNo_SalesAdvanceLetterHeaderCaption; FieldCaption("Bank Account No."))
            {
            }
            column(BankAccountNo_SalesAdvanceLetterHeader; "Bank Account No.")
            {
            }
            column(IBAN_SalesAdvanceLetterHeaderCaption; FieldCaption(IBAN))
            {
            }
            column(IBAN_SalesAdvanceLetterHeader; IBAN)
            {
            }
            column(BIC_SalesAdvanceLetterHeaderCaption; FieldCaption("SWIFT Code"))
            {
            }
            column(BIC_SalesAdvanceLetterHeader; "SWIFT Code")
            {
            }
            column(DocumentDate_SalesAdvanceLetterHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_SalesAdvanceLetterHeader; Format("Document Date"))
            {
            }
            column(PmntSymbol1; PaymentSymbolLabel[1])
            {
            }
            column(PmntSymbol2; PaymentSymbol[1])
            {
            }
            column(PmntSymbol3; PaymentSymbolLabel[2])
            {
            }
            column(PmntSymbol4; PaymentSymbol[2])
            {
            }
            column(PaymentTerms; PaymentTerms.Description)
            {
            }
            column(PaymentMethod; PaymentMethod.Description)
            {
            }
            column(CurrencyCode_SalesAdvanceLetterHeader; "Currency Code")
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
            column(AdvanceDueDate_SalesAdvancLetterHeaderCaption; FieldCaption("Advance Due Date"))
            {
            }
            column(AdvanceDueDate_SalesAdvancLetterHeader; Format("Advance Due Date"))
            {
            }
            column(AmountIncludingVATLbl; AmountIncludingVATLbl)
            {
            }
            column(AmountIncludingVAT; AmountIncludingVAT)
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
                    DataItemLink = Code = field("Salesperson Code");
                    DataItemLinkReference = "Sales Advance Letter Header";
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
                dataitem("Sales Advance Letter Line"; "Sales Adv. Letter Line CZZ")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Sales Advance Letter Header";
                    DataItemTableView = sorting("Document No.", "Line No.");
                    column(LineNo_SalesAdvanceLetterLine; "Line No.")
                    {
                    }
                    column(Description_SalesAdvanceLetterLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_SalesAdvanceLetterLine; Description)
                    {
                    }
                    column(VAT_SalesAdvanceLetterLineCaption; FieldCaption("VAT %"))
                    {
                    }
                    column(VAT_SalesAdvanceLetterLine; "VAT %")
                    {
                    }
                    column(AmountIncludingVAT_SalesAdvanceLetterLineCaption; FieldCaption("Amount Including VAT"))
                    {
                    }
                    column(AmountIncludingVAT_SalesAdvanceLetterLine; "Amount Including VAT")
                    {
                    }
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLinkReference = "Sales Advance Letter Header";
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
                        Codeunit.Run(Codeunit::"Sales Adv. Letter-Printed CZZ", "Sales Advance Letter Header");
                end;
            }

            trigger OnAfterGetRecord()
            var
                SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatDocumentFields("Sales Advance Letter Header");

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code";

                FormatAddress.FormatAddr(CustAddr, "Bill-to Name", "Bill-to Name 2", "Bill-to Contact", "Bill-to Address", "Bill-to Address 2",
                  "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code");

                SalesAdvLetterLineCZZ.SetRange("Document No.", "No.");
                SalesAdvLetterLineCZZ.CalcSums("Amount Including VAT");
                AmountIncludingVAT := SalesAdvLetterLineCZZ."Amount Including VAT";
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
    }

    var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        FormatDocument: Codeunit "Format Document";
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        PaymentSymbol: array[2] of Text;
        PaymentSymbolLabel: array[2] of Text;
        AmountIncludingVAT: Decimal;
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
        SalespersonLbl: Label 'Salesperson';
        TotalLbl: Label 'total';
        CreatorLbl: Label 'Posted by';
        GreetingLbl: Label 'Hello';
        ClosingLbl: Label 'Sincerely';
        BodyLbl: Label 'The sales advance letter is attached to this message.';
        DocumentNoLbl: Label 'No.';
        AmountIncludingVATLbl: Label 'Amount Including VAT';

    local procedure FormatDocumentFields(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, SalesAdvLetterHeaderCZZ."Payment Terms Code", SalesAdvLetterHeaderCZZ."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, SalesAdvLetterHeaderCZZ."Payment Method Code", SalesAdvLetterHeaderCZZ."Language Code");

        FormatDocumentMgtCZL.SetPaymentSymbols(
          PaymentSymbol, PaymentSymbolLabel,
          SalesAdvLetterHeaderCZZ."Variable Symbol", SalesAdvLetterHeaderCZZ.FieldCaption("Variable Symbol"),
          SalesAdvLetterHeaderCZZ."Constant Symbol", SalesAdvLetterHeaderCZZ.FieldCaption("Constant Symbol"),
          SalesAdvLetterHeaderCZZ."Specific Symbol", SalesAdvLetterHeaderCZZ.FieldCaption("Specific Symbol"));
        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(SalesAdvLetterHeaderCZZ."Language Code");
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
