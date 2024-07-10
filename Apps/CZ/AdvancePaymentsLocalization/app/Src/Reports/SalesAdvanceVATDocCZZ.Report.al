// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31015 "Sales - Advance VAT Doc. CZZ"
{
    Caption = 'Sales - Advance VAT Document';
    PreviewMode = PrintLayout;
    UsageCategory = None;
    DefaultRenderingLayout = "SalesAdvanceVATDoc.rdl";
    WordMergeDataItem = TempSalesAdvLetterEntry;

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
        dataitem("Sales Adv. Letter Entry"; "Sales Adv. Letter Entry CZZ")
        {
            DataItemTableView = sorting("Entry No.");
            RequestFilterFields = "Entry No.";

            trigger OnAfterGetRecord()
            begin
                if not ("Entry Type" in ["Entry Type"::"VAT Payment", "Entry Type"::"VAT Usage", "Entry Type"::"VAT Close"]) then
                    FieldError("Entry Type");

                TempSalesAdvLetterEntry.SetRange("Document No.", "Document No.");
                TempSalesAdvLetterEntry.SetRange("Sales Adv. Letter No.", "Sales Adv. Letter No.");
                if TempSalesAdvLetterEntry.IsEmpty() then begin
                    TempSalesAdvLetterEntry := "Sales Adv. Letter Entry";
                    TempSalesAdvLetterEntry.Insert();
                end;
                TempSalesAdvLetterEntry.Reset();
            end;
        }
        dataitem(TempSalesAdvLetterEntry; "Sales Adv. Letter Entry CZZ")
        {
            DataItemTableView = sorting("Document No.");
            UseTemporary = true;

            dataitem("Sales Adv. Letter Header"; "Sales Adv. Letter Header CZZ")
            {
                DataItemTableView = sorting("No.");
                DataItemLink = "No." = field("Sales Adv. Letter No.");
                column(DocumentLbl; DocumentLabel)
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
                column(SalespersonLbl; SalespersonLbl)
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
                column(VATLbl; VATLbl)
                {
                }
                column(AdvanceLetterLbl; AdvanceLetterLbl)
                {
                }
                column(DocumentNo_SalesAdvLetterEntry; TempSalesAdvLetterEntry."Document No.")
                {
                }
                column(LetterNo_SalesAdvLetterEntry; TempSalesAdvLetterEntry."Sales Adv. Letter No.")
                {
                }
                column(VATRegistrationNo_DocumentHeaderCaption; FieldCaption("VAT Registration No."))
                {
                }
                column(VATRegistrationNo_DocumentHeader; "VAT Registration No.")
                {
                }
                column(RegistrationNo_DocumentHeaderCaption; FieldCaption("Registration No."))
                {
                }
                column(RegistrationNo_DocumentHeader; "Registration No.")
                {
                }
                column(BankAccountNo_DocumentHeaderCaption; FieldCaption("Bank Account No."))
                {
                }
                column(BankAccountNo_DocumentHeader; "Bank Account No.")
                {
                }
                column(IBAN_DocumentHeaderCaption; FieldCaption(IBAN))
                {
                }
                column(IBAN_DocumentHeader; IBAN)
                {
                }
                column(BIC_DocumentHeaderCaption; FieldCaption("SWIFT Code"))
                {
                }
                column(BIC_DocumentHeader; "SWIFT Code")
                {
                }
                column(DocumentDate_DocumentHeaderCaption; FieldCaption("Document Date"))
                {
                }
                column(DocumentDate_SalesAdvLetterEntry; Format(TempSalesAdvLetterEntry."Posting Date"))
                {
                }
                column(VATDate_DocumentHeaderCaption; FieldCaption("VAT Date"))
                {
                }
                column(VATDate_SalesAdvLetterEntry; Format(TempSalesAdvLetterEntry."VAT Date"))
                {
                }
                column(PaymentTerms; PaymentTerms.Description)
                {
                }
                column(PaymentMethod; PaymentMethod.Description)
                {
                }
                column(CurrencyCode_SalesAdvLetterEntry; TempSalesAdvLetterEntry."Currency Code")
                {
                }
                column(CalculatedExchRate; CalculatedExchRate)
                {
                }
                column(ExchRateText; ExchRateText)
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
                column(OriginalAdvanceVATDocumentNo; OriginalAdvanceVATDocumentNo)
                {
                }
                column(OriginalAdvanceVATDocumentNoLbl; OriginalAdvanceVATDocumentNoLbl)
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
                        DataItemLinkReference = "Sales Adv. Letter Header";
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
                    dataitem("VAT Entry"; "Sales Adv. Letter Entry CZZ")
                    {
                        DataItemLink = "Sales Adv. Letter No." = field("Sales Adv. Letter No."), "Document No." = field("Document No.");
                        DataItemLinkReference = TempSalesAdvLetterEntry;
                        DataItemTableView = sorting("Document No.") where("Entry Type" = filter("VAT Payment" | "VAT Usage" | "VAT Close"), "Auxiliary Entry" = const(false));

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.Init();
                            TempVATAmountLine."VAT Identifier" := "VAT Identifier";
                            TempVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                            TempVATAmountLine."VAT %" := "VAT %";
                            TempVATAmountLine."VAT Base" := -"VAT Base Amount";
                            TempVATAmountLine."Amount Including VAT" := -"Amount";
                            TempVATAmountLine."VAT Base (LCY) CZL" := -"VAT Base Amount (LCY)";
                            TempVATAmountLine."VAT Amount (LCY) CZL" := -"VAT Amount (LCY)";
                            TempVATAmountLine.InsertLine();
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempVATAmountLine.DeleteAll();
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
                            AutoFormatExpression = "Sales Adv. Letter Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Adv. Letter Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATBaseLCY; TempVATAmountLine."VAT Base (LCY) CZL")
                        {
                            AutoFormatExpression = "Sales Adv. Letter Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmtLCY; TempVATAmountLine."VAT Amount (LCY) CZL")
                        {
                            AutoFormatExpression = "Sales Adv. Letter Header"."Currency Code";
                            AutoFormatType = 1;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number, 1, TempVATAmountLine.Count());
                        end;
                    }
                    dataitem("User Setup"; "User Setup")
                    {
                        DataItemLink = "User ID" = field("User ID");
                        DataItemLinkReference = "TempSalesAdvLetterEntry";
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
                }

                trigger OnAfterGetRecord()
                var
                    SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
                begin
                    CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                    CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                    if IsCreditMemo(TempSalesAdvLetterEntry) then
                        DocumentLabel := CrMemoDocumentLbl
                    else
                        DocumentLabel := DocumentLbl;

                    DocumentFooterCZL.SetFilter("Language Code", '%1|%2', '', "Language Code");
                    if DocumentFooterCZL.FindLast() then
                        DocFooterText := DocumentFooterCZL."Footer Text"
                    else
                        DocFooterText := '';

                    if "Currency Code" = '' then
                        "Currency Code" := "General Ledger Setup"."LCY Code";

                    if (TempSalesAdvLetterEntry."Currency Factor" <> 0) and (TempSalesAdvLetterEntry."Currency Factor" <> 1) then begin
                        CurrencyExchangeRate.FindCurrency(TempSalesAdvLetterEntry."Posting Date", "Currency Code", 1);
                        CalculatedExchRate := Round(1 / TempSalesAdvLetterEntry."Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.000001);
                        ExchRateText :=
                          StrSubstNo(ExchangeRateTxt, CalculatedExchRate, "General Ledger Setup"."LCY Code",
                            CurrencyExchangeRate."Exchange Rate Amount", "Currency Code");
                    end else
                        CalculatedExchRate := 1;

                    FormatAddress.FormatAddr(CustAddr, "Bill-to Name", "Bill-to Name 2", "Bill-to Contact", "Bill-to Address", "Bill-to Address 2",
                      "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code");

                    if "Payment Terms Code" = '' then
                        PaymentTerms.Init()
                    else begin
                        PaymentTerms.Get("Payment Terms Code");
                        PaymentTerms.TranslateDescription(PaymentTerms, "Language Code");
                    end;
                    if "Payment Method Code" = '' then
                        PaymentMethod.Init()
                    else
                        PaymentMethod.Get("Payment Method Code");

                    SalesAdvLetterLineCZZ.SetRange("Document No.", "No.");
                    SalesAdvLetterLineCZZ.CalcSums("Amount Including VAT");
                    AmountIncludingVAT := SalesAdvLetterLineCZZ."Amount Including VAT";
                end;
            }

            trigger OnAfterGetRecord()
            var
                SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
            begin
                OriginalAdvanceVATDocumentNo := '';
                if IsCreditMemo(TempSalesAdvLetterEntry) then begin
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", TempSalesAdvLetterEntry."Sales Adv. Letter No.");
                    SalesAdvLetterEntryCZZ.SetRange("Related Entry", TempSalesAdvLetterEntry."Related Entry");
                    SalesAdvLetterEntryCZZ.SetFilter("Document No.", '<>%1', TempSalesAdvLetterEntry."Document No.");
                    SalesAdvLetterEntryCZZ.SetFilter("Entry No.", '<%1', TempSalesAdvLetterEntry."Entry No.");
                    if SalesAdvLetterEntryCZZ.FindLast() then
                        OriginalAdvanceVATDocumentNo := SalesAdvLetterEntryCZZ."Document No.";
                end;
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

    rendering
    {
        layout("SalesAdvanceVATDoc.rdl")
        {
            Type = RDLC;
            LayoutFile = './Src/Reports/SalesAdvanceVATDoc.rdl';
            Caption = 'Sales Advance VAT Document (RDL)';
            Summary = 'The Sales Advance VAT Document (RDL) provides a detailed layout.';
        }
        layout("SalesAdvanceVATDocEmail.docx")
        {
            Type = Word;
            LayoutFile = './Src/Reports/SalesAdvanceVATDocEmail.docx';
            Caption = 'Sales Advance VAT Document Email (Word)';
            Summary = 'The Sales Advance VAT Document Email (Word) provides an email body layout.';
        }
    }

    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        DocumentFooterCZL: Record "Document Footer CZL";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        NoOfLoops: Integer;
        ExchangeRateTxt: Label 'Exchange Rate %1 %2 / %3 %4', Comment = '%1=calculatedexchrate;%2=general ledger setup.LCY Code;%3=currexchrate.exchange rate amount;%4=currency code';
        DocumentLbl: Label 'VAT Document to Received Payment';
        CrMemoDocumentLbl: Label 'VAT Credit Memo to Received Payment';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        SalespersonLbl: Label 'Salesperson';
        CreatorLbl: Label 'Posted by';
        VATIdentLbl: Label 'VAT Recapitulation';
        VATPercentLbl: Label 'VAT %';
        VATBaseLbl: Label 'VAT Base';
        VATAmtLbl: Label 'VAT Amount';
        TotalLbl: Label 'total';
        VATLbl: Label 'VAT';
        AdvanceLetterLbl: Label 'VAT Document to Advance Letter';
        OriginalAdvanceVATDocumentNoLbl: Label 'Original Advance VAT Document No.';
        GreetingLbl: Label 'Hello';
        ClosingLbl: Label 'Sincerely';
        BodyLbl: Label 'The sales advance VAT document is attached to this message.';
        DocumentNoLbl: Label 'No.';
        AmountIncludingVATLbl: Label 'Amount Including VAT';

    protected var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        DocumentLabel: Text;
        ExchRateText: Text[50];
        OriginalAdvanceVATDocumentNo: Code[20];
        AmountIncludingVAT: Decimal;
        CalculatedExchRate: Decimal;
        CopyNo: Integer;
        NoOfCop: Integer;

    local procedure IsCreditMemo(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"): Boolean
    var
        DocumentAmount: Decimal;
    begin
        DocumentAmount := SalesAdvLetterEntryCZZ.CalcDocumentAmount();
        exit(((SalesAdvLetterEntryCZZ."Entry Type" = SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment") and (DocumentAmount > 0)) or
             ((SalesAdvLetterEntryCZZ."Entry Type" = SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage") and (DocumentAmount < 0)) or
             (SalesAdvLetterEntryCZZ."Entry Type" = SalesAdvLetterEntryCZZ."Entry Type"::"VAT Close"));
    end;
}
