// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.History;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Customer;
using Microsoft.Service.Setup;
using Microsoft.Utilities;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31198 "Service Credit Memo CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/ServiceCreditMemo.rdl';
    Caption = 'Service Credit Memo';
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
        dataitem("Service Cr.Memo Header"; "Service Cr.Memo Header")
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
            column(ShipToLbl; ShipToLbl)
            {
            }
            column(PaymentTermsLbl; PaymentTermsLbl)
            {
            }
            column(PaymentMethodLbl; PaymentMethodLbl)
            {
            }
            column(ToInvoiceLbl; ToInvoiceLbl)
            {
            }
            column(SalespersonLbl; SalespersonLbl)
            {
            }
            column(UoMLbl; UoMLbl)
            {
            }
            column(CreatorLbl; CreatorLbl)
            {
            }
            column(SubtottalLbl; SubtottalLbl)
            {
            }
            column(DiscPercentLbl; DiscPercentLbl)
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
            column(No_ServiceCrMemoHeader; "No.")
            {
            }
            column(VATRegistrationNo_ServiceCrMemoHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_ServiceCrMemoHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_ServiceCrMemoHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_ServiceCrMemoHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_ServiceCrMemoHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_ServiceCrMemoHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_ServiceCrMemoHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_ServiceCrMemoHeader; "IBAN CZL")
            {
            }
            column(BIC_ServiceCrMemoHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(BIC_ServiceCrMemoHeader; "SWIFT Code CZL")
            {
            }
            column(PostingDate_ServiceCrMemoHeaderCaption; FieldCaption("Posting Date"))
            {
            }
            column(PostingDate_ServiceCrMemoHeader; Format("Posting Date"))
            {
            }
            column(VATDate_ServiceCrMemoHeaderCaption; FieldCaption("VAT Reporting Date"))
            {
            }
            column(VATDate_ServiceCrMemoHeader; Format("VAT Reporting Date"))
            {
            }
            column(DueDate_ServiceCrMemoHeaderCaption; FieldCaption("Due Date"))
            {
            }
            column(DueDate_ServiceCrMemoHeader; Format("Due Date"))
            {
            }
            column(DocumentDate_ServiceCrMemoHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_ServiceCrMemoHeader; Format("Document Date"))
            {
            }
            column(YourReference_ServiceCrMemoHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_ServiceCrMemoHeader; "Your Reference")
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
            column(ReasonCode; ReasonCode.Description)
            {
            }
            column(AppliestoDocNo_ServiceCrMemoHeader; "Applies-to Doc. No.")
            {
            }
            column(CurrencyCode_ServiceCrMemoHeader; "Currency Code")
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
                    DataItemLinkReference = "Service Cr.Memo Header";
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
                dataitem("Service Cr.Memo Line"; "Service Cr.Memo Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Service Cr.Memo Header";
                    DataItemTableView = sorting("Document No.", "Line No.");
                    column(LineNo_ServiceCrMemoLine; "Line No.")
                    {
                    }
                    column(Type_ServiceCrMemoLine; Format(Type, 0, 2))
                    {
                    }
                    column(No_ServiceCrMemoLineCaption; FieldCaption("No."))
                    {
                    }
                    column(No_ServiceCrMemoLine; "No.")
                    {
                    }
                    column(Description_ServiceCrMemoLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_ServiceCrMemoLine; Description)
                    {
                    }
                    column(Quantity_ServiceCrMemoLineCaption; FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_ServiceCrMemoLine; Quantity)
                    {
                    }
                    column(UnitofMeasure_ServiceCrMemoLine; "Unit of Measure")
                    {
                    }
                    column(UnitPrice_ServiceCrMemoLineCaption; FieldCaption("Unit Price"))
                    {
                    }
                    column(UnitPrice_ServiceCrMemoLine; "Unit Price")
                    {
                    }
                    column(LineDiscount_ServiceCrMemoLineCaption; FieldCaption("Line Discount %"))
                    {
                    }
                    column(LineDiscount_ServiceCrMemoLine; "Line Discount %")
                    {
                    }
                    column(VAT_ServiceCrMemoLineCaption; FieldCaption("VAT %"))
                    {
                    }
                    column(VAT_ServiceCrMemoLine; "VAT %")
                    {
                    }
                    column(LineAmount_ServiceCrMemoLineCaption; FieldCaption("Line Amount"))
                    {
                    }
                    column(LineAmount_ServiceCrMemoLine; "Line Amount")
                    {
                    }
                    column(InvDiscountAmount_ServiceCrMemoLineCaption; FieldCaption("Inv. Discount Amount"))
                    {
                    }
                    column(InvDiscountAmount_ServiceCrMemoLine; "Inv. Discount Amount")
                    {
                    }
                    column(Amount_ServiceCrMemoLineCaption; FieldCaption(Amount))
                    {
                    }
                    column(Amount_ServiceCrMemoLine; Amount)
                    {
                    }
                    column(AmountIncludingVAT_ServiceCrMemoLineCaption; FieldCaption("Amount Including VAT"))
                    {
                    }
                    column(AmountIncludingVAT_ServiceCrMemoLine; "Amount Including VAT")
                    {
                    }
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
                    column(VATAmtLineVATBase; -TempVATAmountLine."VAT Base")
                    {
                        AutoFormatExpression = "Service Cr.Memo Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmt; -TempVATAmountLine."VAT Amount")
                    {
                        AutoFormatExpression = "Service Cr.Memo Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATBaseLCY; -TempVATAmountLine."VAT Base (LCY) CZL")
                    {
                        AutoFormatExpression = "Service Cr.Memo Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmtLCY; -TempVATAmountLine."VAT Amount (LCY) CZL")
                    {
                        AutoFormatExpression = "Service Cr.Memo Header"."Currency Code";
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
                dataitem(VATClauseEntryCounter; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(VATClauseIdentifier; TempVATAmountLine."VAT Identifier")
                    {
                    }
                    column(VATClauseDescription; VATClauseText)
                    {
                    }
                    column(VATClauseDescription2; VATClause."Description 2")
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                        if not VATClause.Get(TempVATAmountLine."VAT Clause Code") then
                            CurrReport.Skip();
                        VATClauseText := VATClause.GetDescriptionText("Service Cr.Memo Header");
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = field("User ID");
                    DataItemLinkReference = "Service Cr.Memo Header";
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
                        Codeunit.Run(Codeunit::"Service Cr. Memo-Printed", "Service Cr.Memo Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + Customer."Invoice Copies" + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;
            }
            trigger OnAfterGetRecord()
            var
                ServiceCrMemoLine: Record "Service Cr.Memo Line";
                IsHandled: Boolean;
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddressFields("Service Cr.Memo Header");
                FormatDocumentFields("Service Cr.Memo Header");
                if not Customer.Get("Bill-to Customer No.") then
                    Clear(Customer);

                case "Credit Memo Type CZL" of
                    "Credit Memo Type CZL"::"Corrective Tax Document":
                        DocumentLbl := CorrectiveTaxDocumentLbl;
                    "Credit Memo Type CZL"::"Internal Correction":
                        DocumentLbl := InternalCorrectionLbl;
                    "Credit Memo Type CZL"::"Insolvency Tax Document":
                        DocumentLbl := InsolvencyTaxDocumentLbl;
                    else begin
                        IsHandled := false;
                        OnSelectDocumentLabelCase("Service Cr.Memo Header", DocumentLbl, IsHandled);
                        if not IsHandled then
                            DocumentLbl := CorrectiveTaxDocumentLbl;
                    end;
                end;

                ServiceCrMemoLine.CalcVATAmountLines("Service Cr.Memo Header", TempVATAmountLine);
                TempVATAmountLine.UpdateVATEntryLCYAmountsCZL("Service Cr.Memo Header");
                if ("Currency Factor" <> 0) and ("Currency Factor" <> 1) then begin
                    CurrencyExchangeRate.FindCurrency("Posting Date", "Currency Code", 1);
                    CalculatedExchRate := Round(1 / "Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.00001);
                    ExchRateText :=
                      StrSubstNo(ExchRateLbl, CalculatedExchRate, "General Ledger Setup"."LCY Code",
                        CurrencyExchangeRate."Exchange Rate Amount", "Currency Code");
                end else
                    CalculatedExchRate := 1;

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code";
#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    "VAT Reporting Date" := "VAT Date CZL";
#pragma warning restore AL0432
#endif
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
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        Customer: Record Customer;
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        ReasonCode: Record "Reason Code";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        VATClause: Record "VAT Clause";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
#if not CLEAN22
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
#endif
        ExchRateText: Text[50];
        VATClauseText: Text;
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        PaymentSymbol: array[2] of Text;
        PaymentSymbolLabel: array[2] of Text;
        CalculatedExchRate: Decimal;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        ExchRateLbl: Label 'Exchange Rate %1 %2 / %3 %4', Comment = '%1 = Calculated Exchange Rate, %2 = LCY Code, %3 = Exchange Rate, %4 = Currency Code';
        DocumentLbl: Text;
        CorrectiveTaxDocumentLbl: Label 'Service - Corrective Tax Document';
        InternalCorrectionLbl: Label 'Service - Internal Correction';
        InsolvencyTaxDocumentLbl: Label 'Service - Insolvency Tax Document';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        ToInvoiceLbl: Label 'To Invoice';
        SalespersonLbl: Label 'Salesperson';
        UoMLbl: Label 'UoM';
        CreatorLbl: Label 'Posted by';
        SubtottalLbl: Label 'Subtotal';
        DiscPercentLbl: Label 'Discount %';
        VATIdentLbl: Label 'VAT Recapitulation';
        VATPercentLbl: Label 'VAT %';
        VATBaseLbl: Label 'VAT Base';
        VATAmtLbl: Label 'VAT Amount';
        TotalLbl: Label 'total';
        VATLbl: Label 'VAT';

    local procedure FormatDocumentFields(ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, ServiceCrMemoHeader."Payment Terms Code", ServiceCrMemoHeader."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, ServiceCrMemoHeader."Payment Method Code", ServiceCrMemoHeader."Language Code");
        if ServiceCrMemoHeader."Reason Code" = '' then
            ReasonCode.Init()
        else
            ReasonCode.Get(ServiceCrMemoHeader."Reason Code");
        FormatDocumentMgtCZL.SetPaymentSymbols(
          PaymentSymbol, PaymentSymbolLabel,
          ServiceCrMemoHeader."Variable Symbol CZL", ServiceCrMemoHeader.FieldCaption(ServiceCrMemoHeader."Variable Symbol CZL"),
          ServiceCrMemoHeader."Constant Symbol CZL", ServiceCrMemoHeader.FieldCaption(ServiceCrMemoHeader."Constant Symbol CZL"),
          ServiceCrMemoHeader."Specific Symbol CZL", ServiceCrMemoHeader.FieldCaption(ServiceCrMemoHeader."Specific Symbol CZL"));
        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(ServiceCrMemoHeader."Language Code");
    end;

    local procedure FormatAddressFields(ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    begin
        FormatAddress.ServiceCrMemoBillTo(CustAddr, ServiceCrMemoHeader);
        FormatAddress.ServiceCrMemoShipTo(ShipToAddr, CustAddr, ServiceCrMemoHeader);
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSelectDocumentLabelCase(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var DocumentLabel: Text; var IsHandled: Boolean)
    begin
    end;
}
