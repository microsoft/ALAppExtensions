// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31190 "Sales Credit Memo CZL"
{
    Caption = 'Sales Credit Memo';
    PreviewMode = PrintLayout;
    DefaultRenderingLayout = "SalesCreditMemo.rdl";
    WordMergeDataItem = "Sales Cr.Memo Header";

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
        }
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
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
            column(ShipmentMethodLbl; ShipmentMethodLbl)
            {
            }
            column(ToInvoiceLbl; ToInvoiceLbl)
            {
            }
            column(YourReferenceLbl; YourReferenceLbl)
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
            column(Type3Text; Type3TextLbl)
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
            column(No_SalesCrMemoHeader; "No.")
            {
            }
            column(CreditMemoType_SalesCrMemoHeader; Format("Credit Memo Type CZL", 0, 2))
            {
            }
            column(VATRegistrationNo_SalesCrMemoHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_SalesCrMemoHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_SalesCrMemoHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_SalesCrMemoHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_SalesCrMemoHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_SalesCrMemoHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_SalesCrMemoHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_SalesCrMemoHeader; "IBAN CZL")
            {
            }
            column(BIC_SalesCrMemoHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(BIC_SalesCrMemoHeader; "SWIFT Code CZL")
            {
            }
            column(PostingDate_SalesCrMemoHeaderCaption; FieldCaption("Posting Date"))
            {
            }
            column(PostingDate_SalesCrMemoHeader; Format("Posting Date"))
            {
            }
            column(VATDate_SalesCrMemoHeaderCaption; FieldCaption("VAT Reporting Date"))
            {
            }
            column(VATDate_SalesCrMemoHeader; Format("VAT Reporting Date"))
            {
            }
            column(DueDate_SalesCrMemoHeaderCaption; FieldCaption("Due Date"))
            {
            }
            column(DueDate_SalesCrMemoHeader; Format("Due Date"))
            {
            }
            column(DocumentDate_SalesCrMemoHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_SalesCrMemoHeader; Format("Document Date"))
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
            column(AppliestoDocNo_SalesCrMemoHeader; "Applies-to Doc. No.")
            {
            }
            column(ExternalDocumentNo_SalesCrMemoHeader; "External Document No.")
            {
            }
            column(ShipmentMethod; ShipmentMethod.Description)
            {
            }
            column(CurrencyCode_SalesCrMemoHeader; "Currency Code")
            {
            }
            column(Amount_SalesCrMemoHeaderCaption; FieldCaption(Amount))
            {
            }
            column(Amount_SalesCrMemoHeader; Amount)
            {
            }
            column(AmountIncludingVAT_SalesCrMemoHeaderCaption; FieldCaption("Amount Including VAT"))
            {
            }
            column(AmountIncludingVAT_SalesCrMemoHeader; "Amount Including VAT")
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
                    DataItemLinkReference = "Sales Cr.Memo Header";
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
                dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Sales Cr.Memo Header";
                    DataItemTableView = sorting("Document No.", "Line No.");
                    column(LineNo_SalesCrMemoLine; "Line No.")
                    {
                    }
                    column(Type_SalesCrMemoLine; Format(Type, 0, 2))
                    {
                    }
                    column(No_SalesCrMemoLineCaption; FieldCaption("No."))
                    {
                    }
                    column(No_SalesCrMemoLine; "No.")
                    {
                    }
                    column(Description_SalesCrMemoLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_SalesCrMemoLine; Description)
                    {
                    }
                    column(Quantity_SalesCrMemoLineCaption; FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_SalesCrMemoLine; Quantity)
                    {
                    }
                    column(UnitofMeasure_SalesCrMemoLine; "Unit of Measure")
                    {
                    }
                    column(UnitPrice_SalesCrMemoLineCaption; UnitPriceExclVATLbl)
                    {
                    }
                    column(UnitPrice_SalesCrMemoLine; UnitPriceExclVAT)
                    {
                    }
                    column(LineDiscount_SalesCrMemoLineCaption; FieldCaption("Line Discount %"))
                    {
                    }
                    column(LineDiscount_SalesCrMemoLine; "Line Discount %")
                    {
                    }
                    column(VAT_SalesCrMemoLineCaption; FieldCaption("VAT %"))
                    {
                    }
                    column(VAT_SalesCrMemoLine; "VAT %")
                    {
                    }
                    column(LineAmount_SalesCrMemoLineCaption; FieldCaption("Line Amount"))
                    {
                    }
                    column(LineAmount_SalesCrMemoLine; "Line Amount")
                    {
                    }
                    column(InvDiscountAmount_SalesCrMemoLineCaption; FieldCaption("Inv. Discount Amount"))
                    {
                    }
                    column(InvDiscountAmount_SalesCrMemoLine; "Inv. Discount Amount")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        UnitPriceExclVAT := "Unit Price";
                        if "Sales Cr.Memo Header"."Prices Including VAT" then
                            UnitPriceExclVAT := Round("Unit Price" / (1 + "VAT %" / 100), Currency."Amount Rounding Precision");
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
                    column(VATAmtLineVATBase; -TempVATAmountLine."VAT Base")
                    {
                        AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmt; -TempVATAmountLine."VAT Amount")
                    {
                        AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATBaseLCY; -TempVATAmountLine."VAT Base (LCY) CZL")
                    {
                        AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmtLCY; -TempVATAmountLine."VAT Amount (LCY) CZL")
                    {
                        AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                        if UseFunctionalCurrency then begin
                            TempVATAmountLine."VAT Base (LCY) CZL" := TempVATAmountLine."Additional-Currency Base CZL";
                            TempVATAmountLine."VAT Amount (LCY) CZL" := TempVATAmountLine."Additional-Currency Amount CZL";
                        end;
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

                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                        if not VATClause.Get(TempVATAmountLine."VAT Clause Code") then
                            CurrReport.Skip();
                        VATClauseText := VATClause.GetDescriptionText("Sales Cr.Memo Header");
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = field("User ID");
                    DataItemLinkReference = "Sales Cr.Memo Header";
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
                        Codeunit.Run(Codeunit::"Sales Cr. Memo-Printed", "Sales Cr.Memo Header");
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
                SalesCrMemoLine: Record "Sales Cr.Memo Line";
                IsHandled: Boolean;
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddressFields("Sales Cr.Memo Header");
                FormatDocumentFields("Sales Cr.Memo Header");
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
                        OnSelectDocumentLabelCase("Sales Cr.Memo Header", DocumentLbl, IsHandled);
                        if not IsHandled then
                            DocumentLbl := CorrectiveTaxDocumentLbl;
                    end;
                end;

                if "Currency Code" = '' then
                    Currency.InitRoundingPrecision()
                else
                    if not Currency.Get("Currency Code") then
                        Currency.InitRoundingPrecision();

                SalesCrMemoLine.CalcVATAmountLines("Sales Cr.Memo Header", TempVATAmountLine);
                TempVATAmountLine.UpdateVATEntryLCYAmountsCZL("Sales Cr.Memo Header");
                if ("Currency Factor" <> 0) and ("Currency Factor" <> 1) then begin
                    CurrencyExchangeRate.FindCurrency("Posting Date", "Currency Code", 1);
                    CalculatedExchRate := Round(1 / "Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.00001);
                    ExchRateText := StrSubstNo(ExchRateLbl, CalculatedExchRate, "General Ledger Setup"."LCY Code",
                                        CurrencyExchangeRate."Exchange Rate Amount", "Currency Code");
                end else
                    CalculatedExchRate := 1;

                if UseFunctionalCurrency then
                    if ("Additional Currency Factor CZL" <> 0) and ("Additional Currency Factor CZL" <> 1) then begin
                        CurrencyExchangeRate.FindCurrency("Posting Date", "General Ledger Setup"."Additional Reporting Currency", 1);
                        CalculatedExchRate := Round(1 / "Additional Currency Factor CZL" * CurrencyExchangeRate."Exchange Rate Amount", 0.00001);
                        ExchRateText :=
                          StrSubstNo(ExchRateLbl, CurrencyExchangeRate."Exchange Rate Amount", "Currency Code",
                           CalculatedExchRate, "General Ledger Setup"."Additional Reporting Currency");
                    end else
                        CalculatedExchRate := 1;

                if LogInteraction and not IsReportInPreviewMode() then
                    if "Bill-to Contact No." <> '' then
                        SegManagement.LogDocument(
                          6, "No.", 0, 0, Database::Contact, "Bill-to Contact No.", "Salesperson Code",
                          "Campaign No.", "Posting Description", '')
                    else
                        SegManagement.LogDocument(
                          6, "No.", 0, 0, Database::Customer, "Sell-to Customer No.", "Salesperson Code",
                          "Campaign No.", "Posting Description", '');

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code";
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
                    field(LogInteractionCZL; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to record the sales credit memo you print as Interactions and add them to the Interaction Log Entry table.';
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

    rendering
    {
        layout("SalesCreditMemo.rdl")
        {
            Type = RDLC;
            LayoutFile = './Src/Reports/SalesCreditMemo.rdl';
            Caption = 'Sales Credit Memo (RDL)';
            Summary = 'The Sales Credit Memo (RDL) provides a detailed layout.';
        }
        layout("SalesCreditMemoEmail.docx")
        {
            Type = Word;
            LayoutFile = './Src/Reports/SalesCreditMemoEmail.docx';
            Caption = 'Sales Credit Memo Email (Word)';
            Summary = 'The Sales Credit Memo Email (Word) provides an email body layout.';
        }
    }

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        Customer: Record Customer;
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        VATClause: Record "VAT Clause";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        SegManagement: Codeunit SegManagement;
        ExchRateText: Text[50];
        VATClauseText: Text;
        ExchRateLbl: Label 'Exchange Rate %1 %2 / %3 %4', Comment = '%1 = Calculated Exchange Rate, %2 = LCY Code, %3 = Exchange Rate, %4 = Currency Code';
        CorrectiveTaxDocumentLbl: Label 'Corrective Tax Document';
        InternalCorrectionLbl: Label 'Internal Correction';
        InsolvencyTaxDocumentLbl: Label 'Insolvency Tax Document';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        ShipmentMethodLbl: Label 'Shipment Method';
        ToInvoiceLbl: Label 'To Invoice';
        YourReferenceLbl: Label 'Your Reference';
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
        UnitPriceExclVATLbl: Label 'Unit Price Excl. VAT';
        Type3TextLbl: Label 'Correction of tax base in case of bad debt';
        GreetingLbl: Label 'Hello';
        ClosingLbl: Label 'Sincerely';
        BodyLbl: Label 'Thank you for your business. Your credit memo is attached to this message.';
        DocumentNoLbl: Label 'No.';
        LogInteractionEnable: Boolean;

    protected var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        ReasonCode: Record "Reason Code";
        ShipmentMethod: Record "Shipment Method";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        PaymentSymbol: array[2] of Text;
        PaymentSymbolLabel: array[2] of Text;
        DocFooterText: Text[1000];
        DocumentLbl: Text;
        CalculatedExchRate: Decimal;
        UnitPriceExclVAT: Decimal;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        LogInteraction: Boolean;
        UseFunctionalCurrency: Boolean;
        VATCurrencyCode: Code[10];

    procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Sales Cr. Memo") <> '';
    end;

    local procedure FormatDocumentFields(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, SalesCrMemoHeader."Payment Terms Code", SalesCrMemoHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, SalesCrMemoHeader."Shipment Method Code", SalesCrMemoHeader."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, SalesCrMemoHeader."Payment Method Code", SalesCrMemoHeader."Language Code");
        if SalesCrMemoHeader."Reason Code" = '' then
            ReasonCode.Init()
        else
            ReasonCode.Get(SalesCrMemoHeader."Reason Code");
        FormatDocumentMgtCZL.SetPaymentSymbols(
          PaymentSymbol, PaymentSymbolLabel,
          SalesCrMemoHeader."Variable Symbol CZL", SalesCrMemoHeader.FieldCaption(SalesCrMemoHeader."Variable Symbol CZL"),
          SalesCrMemoHeader."Constant Symbol CZL", SalesCrMemoHeader.FieldCaption(SalesCrMemoHeader."Constant Symbol CZL"),
          SalesCrMemoHeader."Specific Symbol CZL", SalesCrMemoHeader.FieldCaption(SalesCrMemoHeader."Specific Symbol CZL"));
        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(SalesCrMemoHeader."Language Code");
    end;

    local procedure FormatAddressFields(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        FormatAddress.SalesCrMemoBillTo(CustAddr, SalesCrMemoHeader);
        FormatAddress.SalesCrMemoShipTo(ShipToAddr, CustAddr, SalesCrMemoHeader);
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSelectDocumentLabelCase(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var DocumentLabel: Text; var IsHandled: Boolean)
    begin
    end;
}
