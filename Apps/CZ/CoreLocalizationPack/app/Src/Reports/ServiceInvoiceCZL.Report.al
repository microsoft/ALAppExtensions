// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.History;

using Microsoft.Bank.BankAccount;
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
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Setup;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;
using Microsoft.CRM.Team;
using Microsoft.Utilities;

report 31197 "Service Invoice CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/ServiceInvoice.rdl';
    Caption = 'Service Invoice';
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
        dataitem("Service Invoice Header"; "Service Invoice Header")
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
            column(SalespersonLbl; SalespersonLbl)
            {
            }
            column(UoMLbl; UoMLbl)
            {
            }
            column(CreatorLbl; CreatorLbl)
            {
            }
            column(SubtotalLbl; SubtotalLbl)
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
            column(PaymentsLbl; PaymentsLbl)
            {
            }
            column(DisplayAdditionalFeeNote; DisplayAdditionalFeeNote)
            {
            }
            column(No_ServiceInvoiceHeader; "No.")
            {
            }
            column(VATRegistrationNo_ServiceInvoiceHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_ServiceInvoiceHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_ServiceInvoiceHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_ServiceInvoiceHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_ServiceInvoiceHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_ServiceInvoiceHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_ServiceInvoiceHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_ServiceInvoiceHeader; "IBAN CZL")
            {
            }
            column(BIC_ServiceInvoiceHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(BIC_ServiceInvoiceHeader; "SWIFT Code CZL")
            {
            }
            column(PostingDate_ServiceInvoiceHeaderCaption; FieldCaption("Posting Date"))
            {
            }
            column(PostingDate_ServiceInvoiceHeader; Format("Posting Date"))
            {
            }
            column(VATDate_ServiceInvoiceHeaderCaption; FieldCaption("VAT Reporting Date"))
            {
            }
            column(VATDate_ServiceInvoiceHeader; Format("VAT Reporting Date"))
            {
            }
            column(DueDate_ServiceInvoiceHeaderCaption; FieldCaption("Due Date"))
            {
            }
            column(DueDate_ServiceInvoiceHeader; Format("Due Date"))
            {
            }
            column(DocumentDate_ServiceInvoiceHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_ServiceInvoiceHeader; Format("Document Date"))
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
            column(OrderNoLbl; OrderNoLbl)
            {
            }
            column(OrderNo_ServiceInvoiceHeader; "Order No.")
            {
            }
            column(YourReference_ServiceInvoiceHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_ServiceInvoiceHeader; "Your Reference")
            {
            }
            column(CurrencyCode_ServiceInvoiceHeader; "Currency Code")
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
                    DataItemLinkReference = "Service Invoice Header";
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
                dataitem("Service Invoice Line"; "Service Invoice Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Service Invoice Header";
                    DataItemTableView = sorting("Document No.", "Line No.");
                    column(LineNo_ServiceInvoiceLine; "Line No.")
                    {
                    }
                    column(Type_ServiceInvoiceLine; Format(Type, 0, 2))
                    {
                    }
                    column(No_ServiceInvoiceLineCaption; FieldCaption("No."))
                    {
                    }
                    column(No_ServiceInvoiceLine; "No.")
                    {
                    }
                    column(Description_ServiceInvoiceLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_ServiceInvoiceLine; Description)
                    {
                    }
                    column(Quantity_ServiceInvoiceLineCaption; FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_ServiceInvoiceLine; Quantity)
                    {
                    }
                    column(UnitofMeasure_ServiceInvoiceLine; "Unit of Measure")
                    {
                    }
                    column(UnitPrice_ServiceInvoiceLineCaption; FieldCaption("Unit Price"))
                    {
                    }
                    column(UnitPrice_ServiceInvoiceLine; "Unit Price")
                    {
                    }
                    column(LineDiscount_ServiceInvoiceLineCaption; FieldCaption("Line Discount %"))
                    {
                    }
                    column(LineDiscount_ServiceInvoiceLine; "Line Discount %")
                    {
                    }
                    column(VAT_ServiceInvoiceLineCaption; FieldCaption("VAT %"))
                    {
                    }
                    column(VAT_ServiceInvoiceLine; "VAT %")
                    {
                    }
                    column(LineAmount_ServiceInvoiceLineCaption; FieldCaption("Line Amount"))
                    {
                    }
                    column(LineAmount_ServiceInvoiceLine; "Line Amount")
                    {
                    }
                    column(InvDiscountAmount_ServiceInvoiceLineCaption; FieldCaption("Inv. Discount Amount"))
                    {
                    }
                    column(InvDiscountAmount_ServiceInvoiceLine; "Inv. Discount Amount")
                    {
                    }
                    column(Amount_ServiceInvoiceLineCaption; FieldCaption(Amount))
                    {
                    }
                    column(Amount_ServiceInvoiceLine; Amount)
                    {
                    }
                    column(AmountIncludingVAT_ServiceInvoiceLineCaption; FieldCaption("Amount Including VAT"))
                    {
                    }
                    column(AmountIncludingVAT_ServiceInvoiceLine; "Amount Including VAT")
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
                    column(VATAmtLineVATBase; TempVATAmountLine."VAT Base")
                    {
                        AutoFormatExpression = "Service Invoice Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                    {
                        AutoFormatExpression = "Service Invoice Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATBaseLCY; TempVATAmountLine."VAT Base (LCY) CZL")
                    {
                        AutoFormatExpression = "Service Invoice Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmtLCY; TempVATAmountLine."VAT Amount (LCY) CZL")
                    {
                        AutoFormatExpression = "Service Invoice Header"."Currency Code";
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
                        VATClauseText := VATClause.GetDescriptionText("Service Invoice Header");
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem(LineFee; "Integer")
                {
                    DataItemTableView = sorting(Number) order(ascending) where(Number = filter(1 ..));
                    column(LineFeeCaptionLbl; TempLineFeeNoteonReportHist.ReportText)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not TempLineFeeNoteonReportHist.FindSet() then
                                CurrReport.Break()
                        end else
                            if TempLineFeeNoteonReportHist.Next() = 0 then
                                CurrReport.Break();
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not DisplayAdditionalFeeNote then
                            CurrReport.Break();
                        SetRange(Number, 1, TempLineFeeNoteonReportHist.Count);
                    end;
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = field("User ID");
                    DataItemLinkReference = "Service Invoice Header";
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
                        Codeunit.Run(Codeunit::"Service Inv.-Printed", "Service Invoice Header");
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
                ServiceInvLine: Record "Service Invoice Line";
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddressFields("Service Invoice Header");
                FormatDocumentFields("Service Invoice Header");
                if not Customer.Get("Bill-to Customer No.") then
                    Clear(Customer);

                ServiceInvLine.CalcVATAmountLines("Service Invoice Header", TempVATAmountLine);
                TempVATAmountLine.UpdateVATEntryLCYAmountsCZL("Service Invoice Header");
                if ("Currency Factor" <> 0) and ("Currency Factor" <> 1) then begin
                    CurrencyExchangeRate.FindCurrency("Posting Date", "Currency Code", 1);
                    CalculatedExchRate := Round(1 / "Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.00001);
                    ExchRateText :=
                      StrSubstNo(ExchRateLbl, CalculatedExchRate, "General Ledger Setup"."LCY Code",
                        CurrencyExchangeRate."Exchange Rate Amount", "Currency Code");
                end else
                    CalculatedExchRate := 1;

                GetLineFeeNoteOnReportHist("No.");

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
                    field(DisplayAdditionalFeeNoteCZL; DisplayAdditionalFeeNote)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Additional Fee Note';
                        ToolTip = 'Specifies when the additional fee note is to be show';
                    }
                }
            }
        }
    }

    var
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TempLineFeeNoteonReportHist: Record "Line Fee Note on Report Hist." temporary;
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
        DocumentLbl: Label 'Invoice';
        CalculatedExchRate: Decimal;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        DisplayAdditionalFeeNote: Boolean;
        OrderNoLbl: Label 'Order No.';
        ExchRateLbl: Label 'Exchange Rate %1 %2 / %3 %4', Comment = '%1 = Calculated Exchange Rate, %2 = LCY Code, %3 = Exchange Rate, %4 = Currency Code';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        SalespersonLbl: Label 'Salesperson';
        UoMLbl: Label 'UoM';
        CreatorLbl: Label 'Posted by';
        SubtotalLbl: Label 'Subtotal';
        DiscPercentLbl: Label 'Discount %';
        VATIdentLbl: Label 'VAT Recapitulation';
        VATPercentLbl: Label 'VAT %';
        VATBaseLbl: Label 'VAT Base';
        VATAmtLbl: Label 'VAT Amount';
        TotalLbl: Label 'total';
        VATLbl: Label 'VAT';
        PaymentsLbl: Label 'Payments List';

    local procedure GetLineFeeNoteOnReportHist(ServiceInvoiceHeaderNo: Code[20])
    var
        LineFeeNoteonReportHist: Record "Line Fee Note on Report Hist.";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        LanguageCustomer: Record Customer;
    begin
        TempLineFeeNoteonReportHist.DeleteAll();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", ServiceInvoiceHeaderNo);
        if not CustLedgerEntry.FindFirst() then
            exit;
        if not LanguageCustomer.Get(CustLedgerEntry."Customer No.") then
            exit;

        LineFeeNoteonReportHist.SetRange("Cust. Ledger Entry No", CustLedgerEntry."Entry No.");
        LineFeeNoteonReportHist.SetRange("Language Code", LanguageCustomer."Language Code");
        if LineFeeNoteonReportHist.FindSet() then
            repeat
                TempLineFeeNoteonReportHist.Init();
                TempLineFeeNoteonReportHist.Copy(LineFeeNoteonReportHist);
                TempLineFeeNoteonReportHist.Insert();
            until LineFeeNoteonReportHist.Next() = 0
        else begin
            LineFeeNoteonReportHist.SetRange("Language Code", LanguageMgt.GetUserLanguageCode());
            if LineFeeNoteonReportHist.FindSet() then
                repeat
                    TempLineFeeNoteonReportHist.Init();
                    TempLineFeeNoteonReportHist.Copy(LineFeeNoteonReportHist);
                    TempLineFeeNoteonReportHist.Insert();
                until LineFeeNoteonReportHist.Next() = 0;
        end;
    end;

    local procedure FormatDocumentFields(ServiceInvoiceHeader: Record "Service Invoice Header")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, ServiceInvoiceHeader."Payment Terms Code", ServiceInvoiceHeader."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, ServiceInvoiceHeader."Payment Method Code", ServiceInvoiceHeader."Language Code");
        if ServiceInvoiceHeader."Reason Code" = '' then
            ReasonCode.Init()
        else
            ReasonCode.Get(ServiceInvoiceHeader."Reason Code");
        FormatDocumentMgtCZL.SetPaymentSymbols(
          PaymentSymbol, PaymentSymbolLabel,
          ServiceInvoiceHeader."Variable Symbol CZL", ServiceInvoiceHeader.FieldCaption(ServiceInvoiceHeader."Variable Symbol CZL"),
          ServiceInvoiceHeader."Constant Symbol CZL", ServiceInvoiceHeader.FieldCaption(ServiceInvoiceHeader."Constant Symbol CZL"),
          ServiceInvoiceHeader."Specific Symbol CZL", ServiceInvoiceHeader.FieldCaption(ServiceInvoiceHeader."Specific Symbol CZL"));
        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(ServiceInvoiceHeader."Language Code");
    end;

    local procedure FormatAddressFields(ServiceInvoiceHeader: Record "Service Invoice Header")
    begin
        FormatAddress.ServiceInvBillTo(CustAddr, ServiceInvoiceHeader);
        FormatAddress.ServiceInvShipTo(ShipToAddr, CustAddr, ServiceInvoiceHeader);
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
