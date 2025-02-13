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
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31017 "Purchase - Advance VAT Doc.CZZ"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PurchaseAdvanceVATDoc.rdl';
    Caption = 'Purchase - Advance VAT Document';
    PreviewMode = PrintLayout;
    UsageCategory = None;

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
                    column(VATCurrencyCode; VATCurrencyCode)
                    {
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    UseFunctionalCurrency := "General Ledger Setup"."Functional Currency CZL";
                    if UseFunctionalCurrency then
                        VATCurrencyCode := "General Ledger Setup"."Additional Reporting Currency"
                    else
                        VATCurrencyCode := "General Ledger Setup"."LCY Code";
                end;
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
        dataitem("Purch. Adv. Letter Entry"; "Purch. Adv. Letter Entry CZZ")
        {
            DataItemTableView = sorting("Entry No.");

            trigger OnAfterGetRecord()
            begin
                if not ("Entry Type" in ["Entry Type"::"VAT Payment", "Entry Type"::"VAT Usage", "Entry Type"::"VAT Close"]) then
                    FieldError("Entry Type");

                TempPurchAdvLetterEntry.SetRange("Document No.", "Document No.");
                TempPurchAdvLetterEntry.SetRange("Purch. Adv. Letter No.", "Purch. Adv. Letter No.");
                if TempPurchAdvLetterEntry.IsEmpty() then begin
                    TempPurchAdvLetterEntry := "Purch. Adv. Letter Entry";
                    TempPurchAdvLetterEntry.Insert();
                end;
                TempPurchAdvLetterEntry.Reset();
            end;
        }
        dataitem(TempPurchAdvLetterEntry; "Purch. Adv. Letter Entry CZZ")
        {
            DataItemTableView = sorting("Document No.");
            UseTemporary = true;
            dataitem("Purch. Adv. Letter Header"; "Purch. Adv. Letter Header CZZ")
            {
                DataItemTableView = sorting("No.");
                DataItemLink = "No." = field("Purch. Adv. Letter No.");
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
                column(PurchaserLbl; PurchaserLbl)
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
                column(VATLbl; VATLbl)
                {
                }
                column(AdvanceLetterLbl; AdvanceLetterLbl)
                {
                }
                column(DocumentNo_PurchAdvLetterEntry; TempPurchAdvLetterEntry."Document No.")
                {
                }
                column(LetterNo_PurchAdvLetterEntry; TempPurchAdvLetterEntry."Purch. Adv. Letter No.")
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
                column(DocumentDate_PurchAdvLetterEntry; Format(TempPurchAdvLetterEntry."Posting Date"))
                {
                }
                column(VATDate_DocumentHeaderCaption; FieldCaption("VAT Date"))
                {
                }
                column(VATDate_PurchAdvLetterEntry; Format(TempPurchAdvLetterEntry."VAT Date"))
                {
                }
                column(PaymentTerms; PaymentTerms.Description)
                {
                }
                column(PaymentMethod; PaymentMethod.Description)
                {
                }
                column(CurrencyCode_PurchAdvLetterEntry; TempPurchAdvLetterEntry."Currency Code")
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
                column(OriginalAdvanceVATDocumentNo; OriginalAdvanceVATDocumentNo)
                {
                }
                column(OriginalAdvanceVATDocumentNoLbl; OriginalAdvanceVATDocumentNoLbl)
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
                        DataItemLinkReference = "Purch. Adv. Letter Header";
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
                    dataitem("VAT Entry"; "Purch. Adv. Letter Entry CZZ")
                    {
                        DataItemLink = "Purch. Adv. Letter No." = field("Purch. Adv. Letter No."), "Document No." = field("Document No.");
                        DataItemLinkReference = TempPurchAdvLetterEntry;
                        DataItemTableView = sorting("Document No.") where("Entry Type" = filter("VAT Payment" | "VAT Usage" | "VAT Close"), "Auxiliary Entry" = const(false));

                        trigger OnAfterGetRecord()
                        var
                            VATEntry: Record "VAT Entry";
                        begin
                            TempVATAmountLine.Init();
                            TempVATAmountLine."VAT Identifier" := "VAT Identifier";
                            TempVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                            TempVATAmountLine."VAT %" := "VAT %";
                            TempVATAmountLine."VAT Base" := "VAT Base Amount";
                            TempVATAmountLine."Amount Including VAT" := "Amount";
                            TempVATAmountLine."VAT Base (LCY) CZL" := "VAT Base Amount (LCY)";
                            TempVATAmountLine."VAT Amount (LCY) CZL" := "VAT Amount (LCY)";
                            if VATEntry.Get("VAT Entry No.") then begin
                                TempVATAmountLine."Additional-Currency Base CZL" := VATEntry."Additional-Currency Base";
                                TempVATAmountLine."Additional-Currency Amount CZL" := VATEntry."Additional-Currency Amount";
                            end;
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
                            AutoFormatExpression = "Purch. Adv. Letter Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purch. Adv. Letter Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATBaseLCY; TempVATAmountLine."VAT Base (LCY) CZL")
                        {
                            AutoFormatExpression = "Purch. Adv. Letter Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmtLCY; TempVATAmountLine."VAT Amount (LCY) CZL")
                        {
                            AutoFormatExpression = "Purch. Adv. Letter Header"."Currency Code";
                            AutoFormatType = 1;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number, 1, TempVATAmountLine.Count);
                        end;
                    }
                    dataitem("User Setup"; "User Setup")
                    {
                        DataItemLink = "User ID" = field("User ID");
                        DataItemLinkReference = TempPurchAdvLetterEntry;
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
                    AdditionalCurrencyFactor: Decimal;
                begin
                    CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                    CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                    if IsCreditMemo(TempPurchAdvLetterEntry) then
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

                    if (TempPurchAdvLetterEntry."Currency Factor" <> 0) and (TempPurchAdvLetterEntry."Currency Factor" <> 1) then begin
                        CurrencyExchangeRate.FindCurrency(TempPurchAdvLetterEntry."Posting Date", "Currency Code", 1);
                        CalculatedExchRate := Round(1 / TempPurchAdvLetterEntry."Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.000001);
                        ExchRateText :=
                          StrSubstNo(Text009Txt, CalculatedExchRate, "General Ledger Setup"."LCY Code",
                            CurrencyExchangeRate."Exchange Rate Amount", "Currency Code");
                    end else
                        CalculatedExchRate := 1;

                    if UseFunctionalCurrency then begin
                        AdditionalCurrencyFactor := CurrencyExchangeRate.ExchangeRate(TempPurchAdvLetterEntry."Posting Date", "General Ledger Setup"."Additional Reporting Currency");
                        if (AdditionalCurrencyFactor <> 0) and (AdditionalCurrencyFactor <> 1) then begin
                            CurrencyExchangeRate.FindCurrency("Posting Date", "General Ledger Setup"."Additional Reporting Currency", 1);
                            CalculatedExchRate := Round(1 / AdditionalCurrencyFactor * CurrencyExchangeRate."Exchange Rate Amount", 0.00001);
                            ExchRateText :=
                              StrSubstNo(Text009Txt, CurrencyExchangeRate."Exchange Rate Amount", "Currency Code",
                               CalculatedExchRate, "General Ledger Setup"."Additional Reporting Currency");
                        end else
                            CalculatedExchRate := 1;
                    end;

                    FormatAddress.FormatAddr(VendAddr, "Pay-to Name", "Pay-to Name 2", "Pay-to Contact", "Pay-to Address", "Pay-to Address 2",
                      "Pay-to City", "Pay-to Post Code", "Pay-to County", "Pay-to Country/Region Code");

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
                end;
            }

            trigger OnAfterGetRecord()
            var
                PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
            begin
                OriginalAdvanceVATDocumentNo := '';
                if IsCreditMemo(TempPurchAdvLetterEntry) then begin
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", TempPurchAdvLetterEntry."Purch. Adv. Letter No.");
                    PurchAdvLetterEntryCZZ.SetRange("Related Entry", TempPurchAdvLetterEntry."Related Entry");
                    PurchAdvLetterEntryCZZ.SetFilter("Document No.", '<>%1', TempPurchAdvLetterEntry."Document No.");
                    PurchAdvLetterEntryCZZ.SetFilter("Entry No.", '<%1', TempPurchAdvLetterEntry."Entry No.");
                    if PurchAdvLetterEntryCZZ.FindLast() then
                        OriginalAdvanceVATDocumentNo := PurchAdvLetterEntryCZZ."Document No.";
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

    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        DocumentFooterCZL: Record "Document Footer CZL";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        NoOfLoops: Integer;
        Text009Txt: Label 'Exchange Rate %1 %2 / %3 %4', Comment = '%1=calculatedexchrate;%2=general ledger setup.LCY Code;%3=currexchrate.exchange rate amount;%4=currency code';
        DocumentLbl: Label 'VAT Document to Paid Payment';
        CrMemoDocumentLbl: Label 'VAT Credit Memo to Paid Payment';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        PurchaserLbl: Label 'Purchaser';
        CreatorLbl: Label 'Posted by';
        VATIdentLbl: Label 'VAT Recapitulation';
        VATPercentLbl: Label 'VAT %';
        VATBaseLbl: Label 'VAT Base';
        VATAmtLbl: Label 'VAT Amount';
        TotalLbl: Label 'total';
        VATLbl: Label 'VAT';
        AdvanceLetterLbl: Label 'VAT Document to Advance Letter';
        OriginalAdvanceVATDocumentNoLbl: Label 'Original Advance VAT Document No.';

    protected var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        CompanyAddr: array[8] of Text[100];
        VendAddr: array[8] of Text[100];
        ExchRateText: Text[50];
        DocFooterText: Text[1000];
        OriginalAdvanceVATDocumentNo: Code[20];
        DocumentLabel: Text;
        CalculatedExchRate: Decimal;
        CopyNo: Integer;
        NoOfCop: Integer;
        UseFunctionalCurrency: Boolean;
        VATCurrencyCode: Code[10];

    local procedure IsCreditMemo(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"): Boolean
    var
        DocumentAmount: Decimal;
    begin
        DocumentAmount := PurchAdvLetterEntryCZZ.CalcDocumentAmount();
        exit(((PurchAdvLetterEntryCZZ."Entry Type" = PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment") and (DocumentAmount < 0)) or
             ((PurchAdvLetterEntryCZZ."Entry Type" = PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage") and (DocumentAmount > 0)) or
             (PurchAdvLetterEntryCZZ."Entry Type" = PurchAdvLetterEntryCZZ."Entry Type"::"VAT Close"));
    end;
}
