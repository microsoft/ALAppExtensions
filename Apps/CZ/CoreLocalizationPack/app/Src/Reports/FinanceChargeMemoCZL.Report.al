// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31183 "Finance Charge Memo CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FinanceChargeMemo.rdl';
    Caption = 'Finance Charge Memo';
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
            column(PhoneNo_CompanyInformationCaption; FieldCaption("Phone No."))
            {
            }
            column(PhoneNo_CompanyInformation; "Phone No.")
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
        }
        dataitem("Issued Fin. Charge Memo Header"; "Issued Fin. Charge Memo Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
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
            column(CreatorLbl; CreatorLbl)
            {
            }
            column(VATIdentLbl; VATIdentLbl)
            {
            }
            column(VATPercentLbl; VATPercentLbl)
            {
            }
            column(VATBaseLbl; VATBaseLbl)
            {
            }
            column(VATAmtLbl; VATAmtLbl)
            {
            }
            column(TotalLbl; TotalLbl)
            {
            }
            column(TotalInclVATText; TotalInclVATText)
            {
            }
            column(No_IssuedFinChargeMemoHeader; "No.")
            {
            }
            column(VATRegistrationNo_IssuedFinChargeMemoHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_IssuedFinChargeMemoHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_IssuedFinChargeMemoHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_IssuedFinChargeMemoHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_IssuedFinChargeMemoHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_IssuedFinChargeMemoHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_IssuedFinChargeMemoHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_IssuedFinChargeMemoHeader; "IBAN CZL")
            {
            }
            column(SWIFTCode_IssuedFinChargeMemoHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(SWIFTCode_IssuedFinChargeMemoHeader; "SWIFT Code CZL")
            {
            }
            column(CustomerNo_IssuedFinChargeMemoHeaderCaption; FieldCaption("Customer No."))
            {
            }
            column(CustomerNo_IssuedFinChargeMemoHeader; "Customer No.")
            {
            }
            column(PostingDate_IssuedFinChargeMemoHeaderCaption; FieldCaption("Posting Date"))
            {
            }
            column(PostingDate_IssuedFinChargeMemoHeader; "Posting Date")
            {
            }
            column(DocumentDate_IssuedFinChargeMemoHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_IssuedFinChargeMemoHeader; "Document Date")
            {
            }
            column(CurrencyCode_IssuedFinChargeMemoHeader; "Currency Code")
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
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(CopyNo; Number)
                {
                }
                dataitem("Issued Fin. Charge Memo Line"; "Issued Fin. Charge Memo Line")
                {
                    DataItemLink = "Finance Charge Memo No." = field("No.");
                    DataItemLinkReference = "Issued Fin. Charge Memo Header";
                    DataItemTableView = sorting("Finance Charge Memo No.", "Line No.");
                    column(DocumentType_IssuedFinChargeMemoLineCaption; FieldCaption("Document Type"))
                    {
                    }
                    column(DocumentType_IssuedFinChargeMemoLine; "Document Type")
                    {
                    }
                    column(DocumentNo_IssuedFinChargeMemoLineCaption; FieldCaption("Document No."))
                    {
                    }
                    column(DocumentNo_IssuedFinChargeMemoLine; "Document No.")
                    {
                    }
                    column(PostingDate_IssuedFinChargeMemoLineCaption; FieldCaption("Posting Date"))
                    {
                    }
                    column(PostingDate_IssuedFinChargeMemoLine; "Posting Date")
                    {
                    }
                    column(DocumentDate_IssuedFinChargeMemoLineCaption; FieldCaption("Document Date"))
                    {
                    }
                    column(DocumentDate_IssuedFinChargeMemoLine; "Document Date")
                    {
                    }
                    column(DueDate_IssuedFinChargeMemoLineCaption; FieldCaption("Due Date"))
                    {
                    }
                    column(DueDate_IssuedFinChargeMemoLine; "Due Date")
                    {
                    }
                    column(Description_IssuedFinChargeMemoLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_IssuedFinChargeMemoLine; Description)
                    {
                    }
                    column(OriginalAmount_IssuedFinChargeMemoLineCaption; FieldCaption("Original Amount"))
                    {
                    }
                    column(OriginalAmount_IssuedFinChargeMemoLine; "Original Amount")
                    {
                    }
                    column(RemainingAmount_IssuedFinChargeMemoLineCaption; FieldCaption("Remaining Amount"))
                    {
                    }
                    column(RemainingAmount_IssuedFinChargeMemoLine; "Remaining Amount")
                    {
                    }
                    column(VATAmount_IssuedFinChargeMemoLineCaption; FieldCaption("VAT Amount"))
                    {
                    }
                    column(VATAmount_IssuedFinChargeMemoLine; "VAT Amount")
                    {
                    }
                    column(Amount_IssuedFinChargeMemoLineCaption; FieldCaption(Amount))
                    {
                    }
                    column(Amount_IssuedFinChargeMemoLine; Amount)
                    {
                    }
                    column(LineNo_IssuedFinChargeMemoLine; "Line No.")
                    {
                    }
                    column(Type_IssuedFinChargeMemoLine; Format(Type, 0, 2))
                    {
                    }
                    column(InterestRate_IssuedFinChargeMemoLineCaption; FieldCaption("Interest Rate"))
                    {
                    }
                    column(InterestRate_IssuedFinChargeMemoLine; "Interest Rate")
                    {
                    }
                    column(DetailedInterestRatesEntry_IssuedFinChargeMemoLine; "Detailed Interest Rates Entry")
                    {
                    }
                    column(PrintInterestDetail; PrintInterestDetail)
                    {
                    }
                    column(ShowCaptions; ShowCaptions)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if not "Detailed Interest Rates Entry" then begin
                            TempVATAmountLine.Init();
                            TempVATAmountLine."VAT Identifier" := "VAT Identifier";
                            TempVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                            TempVATAmountLine."Tax Group Code" := "Tax Group Code";
                            TempVATAmountLine."VAT %" := "VAT %";
                            TempVATAmountLine."VAT Base" := Amount;
                            TempVATAmountLine."VAT Amount" := "VAT Amount";
                            TempVATAmountLine."Amount Including VAT" := Amount + "VAT Amount";
                            TempVATAmountLine."VAT Clause Code" := "VAT Clause Code";
                            TempVATAmountLine.InsertLine();
                        end;

                        ShowCaptions := not PrevDetailedInterestRatesEntry and "Detailed Interest Rates Entry";
                        PrevDetailedInterestRatesEntry := "Detailed Interest Rates Entry";
                    end;

                    trigger OnPreDataItem()
                    begin
                        TempVATAmountLine.Reset();
                        TempVATAmountLine.DeleteAll();

                        if not PrintInterestDetail then
                            SetRange("Detailed Interest Rates Entry", false);

                        ShowCaptions := false;
                    end;
                }
                dataitem(VATCounter; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(VATAmtLineVATIdentifier; TempVATAmountLine."VAT Identifier")
                    {
                    }
                    column(VATAmtLineVATPer; TempVATAmountLine."VAT %")
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(VATAmtLineVATBase; TempVATAmountLine."VAT Base")
                    {
                        AutoFormatExpression = "Issued Fin. Charge Memo Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                    {
                        AutoFormatExpression = "Issued Fin. Charge Memo Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATBaseLCY; TempVATAmountLine."VAT Base (LCY) CZL")
                    {
                        AutoFormatExpression = "Issued Fin. Charge Memo Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmtLCY; TempVATAmountLine."VAT Amount (LCY) CZL")
                    {
                        AutoFormatExpression = "Issued Fin. Charge Memo Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                    end;

                    trigger OnPreDataItem()
                    begin
                        TempVATAmountLine.UpdateVATEntryLCYAmountsCZL("Issued Fin. Charge Memo Header");
                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = field("User ID");
                    DataItemLinkReference = "Issued Fin. Charge Memo Header";
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
                }
                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode() then
                        "Issued Fin. Charge Memo Header".IncrNoPrinted();
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

                FormatAddress.IssuedFinanceChargeMemo(CustAddr, "Issued Fin. Charge Memo Header");
                DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText("Language Code");
                TotalInclVATText := StrSubstNo(TotalInclVATLbl, "Currency Code");

                if LogInteraction and not IsReportInPreviewMode() then
                    SegManagement.LogDocument(
                      19, "No.", 0, 0, Database::Customer, "Customer No.", '', '', "Posting Description", '');

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code";
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
                        ToolTip = 'Specifies if you want the program to record the finance charge memos you print as interactions, and add them to the Interaction Log Entry table.';
                    }
                    field(PrintInterestDetailCZL; PrintInterestDetail)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Interest Detail';
                        ToolTip = 'Specifies if the interest details has to be printed.';
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
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        SegManagement: Codeunit SegManagement;
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        TotalInclVATText: Text[50];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        LogInteraction: Boolean;
        LogInteractionEnable: Boolean;
        ShowCaptions: Boolean;
        PrevDetailedInterestRatesEntry: Boolean;
        DocumentLbl: Label 'Finance Charge Memo';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        TotalLbl: Label 'Total';
        TotalInclVATLbl: Label 'Total %1 including VAT', Comment = '%1 = currency code';
        CreatorLbl: Label 'Created by';
        VATIdentLbl: Label 'VAT Recapitulation';
        VATPercentLbl: Label 'VAT %', Comment = 'VAT %';
        VATBaseLbl: Label 'VAT Base';
        VATAmtLbl: Label 'VAT Amount';
        PrintInterestDetail: Boolean;

    procedure InitializeRequest(NoOfCopiesFrom: Integer; LogInteractionFrom: Boolean; PrintInterestDetailFrom: Boolean)
    begin
        NoOfCopies := NoOfCopiesFrom;
        LogInteraction := LogInteractionFrom;
        PrintInterestDetail := PrintInterestDetailFrom;
    end;

    local procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Sales Finance Charge Memo") <> '';
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
