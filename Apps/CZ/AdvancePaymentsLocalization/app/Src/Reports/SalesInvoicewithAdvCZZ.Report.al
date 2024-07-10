// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

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
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.EMail;
using System.Globalization;
using System.Security.User;
using System.Utilities;
using System.Text;

report 31018 "Sales - Invoice with Adv. CZZ"
{
    Caption = 'Sales - Invoice with Advance';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = "SalesInvoicewithAdv.rdl";
    ApplicationArea = Basic, Suite;
    WordMergeDataItem = "Sales Invoice Header";

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
        }
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
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
            column(PrepayedLbl; PrepayedLbl)
            {
            }
            column(TotalAfterPrepayedLbl; TotalAfterPrepayedLbl)
            {
            }
            column(PaymentsLbl; PaymentsLbl)
            {
            }
            column(DisplayAdditionalFeeNote; DisplayAddFeeNote)
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
            column(QRPaymentLbl; QRPaymentLbl)
            {
            }
            column(No_SalesInvoiceHeader; "No.")
            {
            }
            column(VATRegistrationNo_SalesInvoiceHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_SalesInvoiceHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_SalesInvoiceHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_SalesInvoiceHeader; "Registration No. CZL")
            {
            }
            column(BankAccountNo_SalesInvoiceHeaderCaption; FieldCaption("Bank Account No. CZL"))
            {
            }
            column(BankAccountNo_SalesInvoiceHeader; "Bank Account No. CZL")
            {
            }
            column(IBAN_SalesInvoiceHeaderCaption; FieldCaption("IBAN CZL"))
            {
            }
            column(IBAN_SalesInvoiceHeader; "IBAN CZL")
            {
            }
            column(BIC_SalesInvoiceHeaderCaption; FieldCaption("SWIFT Code CZL"))
            {
            }
            column(BIC_SalesInvoiceHeader; "SWIFT Code CZL")
            {
            }
            column(PostingDate_SalesInvoiceHeaderCaption; FieldCaption("Posting Date"))
            {
            }
            column(PostingDate_SalesInvoiceHeader; Format("Posting Date"))
            {
            }
            column(VATDate_SalesInvoiceHeaderCaption; FieldCaption("VAT Reporting Date"))
            {
            }
            column(VATDate_SalesInvoiceHeader; Format("VAT Reporting Date"))
            {
            }
            column(DueDate_SalesInvoiceHeaderCaption; FieldCaption("Due Date"))
            {
            }
            column(DueDate_SalesInvoiceHeader; Format("Due Date"))
            {
            }
            column(DocumentDate_SalesInvoiceHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_SalesInvoiceHeader; Format("Document Date"))
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
            column(OrderNo_SalesInvoiceHeaderCaption; FieldCaption("Order No."))
            {
            }
            column(OrderNo_SalesInvoiceHeader; "Order No.")
            {
            }
            column(YourReference_SalesInvoiceHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_SalesInvoiceHeader; "Your Reference")
            {
            }
            column(ShipmentMethod; ShipmentMethod.Description)
            {
            }
            column(CurrencyCode_SalesInvoiceHeader; "Currency Code")
            {
            }
            column(Amount_SalesInvoiceHeaderCaption; FieldCaption(Amount))
            {
            }
            column(Amount_SalesInvoiceHeader; Amount)
            {
            }
            column(AmountIncludingVAT_SalesInvoiceHeaderCaption; FieldCaption("Amount Including VAT"))
            {
            }
            column(AmountIncludingVAT_SalesInvoiceHeader; "Amount Including VAT")
            {
            }
            column(PrepaymentAmt_SalesInvoiceHeader; PrepaymentAmt)
            {
            }
            column(TotalAfterPrepayed_SalesInvoiceHeader; TotalAfterPrepayed)
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
            column(QRPaymentCode; QRPaymentCode)
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
                    DataItemLinkReference = "Sales Invoice Header";
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
                dataitem("Sales Invoice Line"; "Sales Invoice Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Sales Invoice Header";
                    DataItemTableView = sorting("Document No.", "Line No.") where("Prepayment Line" = const(false));
                    column(LineNo_SalesInvoiceLine; "Line No.")
                    {
                    }
                    column(Type_SalesInvoicetLine; Format(Type, 0, 2))
                    {
                    }
                    column(No_SalesInvoiceLineCaption; FieldCaption("No."))
                    {
                    }
                    column(No_SalesInvoiceLine; "No.")
                    {
                    }
                    column(Description_SalesInvoiceLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_SalesInvoiceLine; Description)
                    {
                    }
                    column(Quantity_SalesInvoiceLineCaption; FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_SalesInvoiceLine; Quantity)
                    {
                    }
                    column(UnitofMeasure_SalesInvoiceLine; "Unit of Measure")
                    {
                    }
                    column(UnitPrice_SalesInvoiceLineCaption; FieldCaption("Unit Price"))
                    {
                    }
                    column(UnitPrice_SalesInvoiceLine; "Unit Price")
                    {
                    }
                    column(LineDiscount_SalesInvoiceLineCaption; FieldCaption("Line Discount %"))
                    {
                    }
                    column(LineDiscount_SalesInvoiceLine; "Line Discount %")
                    {
                    }
                    column(VAT_SalesInvoiceLineCaption; FieldCaption("VAT %"))
                    {
                    }
                    column(VAT_SalesInvoiceLine; "VAT %")
                    {
                    }
                    column(LineAmount_SalesInvoiceLineCaption; FieldCaption("Line Amount"))
                    {
                    }
                    column(LineAmount_SalesInvoiceLine; "Line Amount")
                    {
                    }
                    column(InvDiscountAmount_SalesInvoiceLineCaption; FieldCaption("Inv. Discount Amount"))
                    {
                    }
                    column(InvDiscountAmount_SalesInvoiceLine; "Inv. Discount Amount")
                    {
                    }
                }
                dataitem(SalesAdvanceUsage; "Sales Adv. Letter Entry CZZ")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Sales Invoice Header";
                    DataItemTableView = sorting("Document No.") where("Entry Type" = const(Usage), Cancelled = const(false));

                    column(LetterNo_SalesAdvanceUsageCaption; FieldCaption("Sales Adv. Letter No."))
                    {
                    }
                    column(VATDocLetterNo_SalesAdvanceUsageCaption; FieldCaption("Document No."))
                    {
                    }
                    column(LetterNo_SalesAdvanceUsage; "Sales Adv. Letter No.")
                    {
                    }
                    column(AmountIncludingVAT_SalesAdvanceUsage; Amount)
                    {
                    }

                    dataitem(SalesAdvanceUsageVAT; "Sales Adv. Letter Entry CZZ")
                    {
                        DataItemLink = "Related Entry" = field("Related Entry");
                        DataItemTableView = sorting("Sales Adv. Letter No.", "Document No.") where("Entry Type" = const("VAT Payment"), Cancelled = const(false));

                        column(VATDocLetterNo_SalesAdvanceUsage; "Document No.")
                        {
                        }
                        column(PostingDate_SalesAdvanceUsage; "Posting Date")
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            SalesAdvLetterEntryCZZVATUsage: Record "Sales Adv. Letter Entry CZZ";
                        begin
                            SalesAdvLetterEntryCZZVATUsage.SetRange("Entry Type", SalesAdvLetterEntryCZZVATUsage."Entry Type"::"VAT Usage");
                            SalesAdvLetterEntryCZZVATUsage.SetRange("Related Entry", SalesAdvanceUsage."Entry No.");
                            SalesAdvLetterEntryCZZVATUsage.Setrange("Auxiliary Entry", false);
                            if SalesAdvLetterEntryCZZVATUsage.IsEmpty() then
                                CurrReport.Break();

                            SetRange("Sales Adv. Letter No.", "Sales Adv. Letter No.");
                            SetRange("Document No.", "Document No.");
                            FindLast();
                            SetRange("Sales Adv. Letter No.");
                            SetRange("Document No.");
                        end;
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
                        AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                    {
                        AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATBaseLCY; TempVATAmountLine."VAT Base (LCY) CZL")
                    {
                        AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmtLCY; TempVATAmountLine."VAT Amount (LCY) CZL")
                    {
                        AutoFormatExpression = "Sales Invoice Header"."Currency Code";
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

                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                        if not VATClause.Get(TempVATAmountLine."VAT Clause Code") then
                            CurrReport.Skip();
                        VATClauseText := VATClause.GetDescriptionText("Sales Invoice Header");
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem(LineFee; "Integer")
                {
                    DataItemTableView = sorting(Number) order(ascending) where(Number = filter(1 ..));
                    column(LineFeeCaptionLbl; TempLineFeeNoteOnReportHist.ReportText)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not TempLineFeeNoteOnReportHist.FindSet() then
                                CurrReport.Break()
                        end else
                            if TempLineFeeNoteOnReportHist.Next() = 0 then
                                CurrReport.Break();
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not DisplayAddFeeNote then
                            CurrReport.Break();
                        SetRange(Number, 1, TempLineFeeNoteOnReportHist.Count);
                    end;
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = field("User ID");
                    DataItemLinkReference = "Sales Invoice Header";
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
                        Codeunit.Run(Codeunit::"Sales Inv.-Printed", "Sales Invoice Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCop) + Customer."Invoice Copies" + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;
            }

            trigger OnAfterGetRecord()
            var
                SalesInvLine: Record "Sales Invoice Line";
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddressFields("Sales Invoice Header");
                FormatDocumentFields("Sales Invoice Header");

                if not Customer.Get("Bill-to Customer No.") then
                    Clear(Customer);

                SalesInvLine.CalcVATAmountLines("Sales Invoice Header", TempVATAmountLine);
                TempVATAmountLine.UpdateVATEntryLCYAmountsCZL("Sales Invoice Header");
                SalesAdvLetterEntryCZZ.CalcUsageVATAmountLines("Sales Invoice Header", TempVATAmountLine);

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code";

                if ("Currency Factor" <> 0) and ("Currency Factor" <> 1) then begin
                    CurrencyExchangeRate.FindCurrency("Posting Date", "Currency Code", 1);
                    CalculatedExchRate := Round(1 / "Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.00001);
                    ExchRateText :=
                      StrSubstNo(ExchRateLbl, CalculatedExchRate, "General Ledger Setup"."LCY Code",
                        CurrencyExchangeRate."Exchange Rate Amount", "Currency Code");
                end else
                    CalculatedExchRate := 1;

                SalesInvLine.SetRange("Document No.", "No.");
                SalesInvLine.CalcSums(Amount, "Amount Including VAT");
                Amount := SalesInvLine.Amount;
                "Amount Including VAT" := SalesInvLine."Amount Including VAT";

                SalesAdvLetterEntryCZZ.SetRange("Document No.", "No.");
                SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
                SalesAdvLetterEntryCZZ.CalcSums(Amount);
                PrepaymentAmt := -SalesAdvLetterEntryCZZ.Amount;
                TotalAfterPrepayed := "Amount Including VAT" + PrepaymentAmt;

                GetLineFeeNoteOnReportHist("No.");

                if LogInteract and not IsReportInPreviewMode() then
                    if "Bill-to Contact No." <> '' then
                        SegManagement.LogDocument(
                          4, "No.", 0, 0, DATABASE::Contact, "Bill-to Contact No.", "Salesperson Code",
                          "Campaign No.", "Posting Description", '')
                    else
                        SegManagement.LogDocument(
                          4, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                          "Campaign No.", "Posting Description", '');

                Clear(QRPaymentCode);
                if "Sales & Receivables Setup"."Print QR Payment CZL" and PaymentMethod."Print QR Payment CZL" then begin
                    CalcFields("Remaining Amount");
                    if "Remaining Amount" <> 0 then
                        GenerateQRPaymentCode();
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
                    field(LogInteraction; LogInteract)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to record the sales invoice you print as Interactions and add them to the Interaction Log Entry table.';
                    }
                    field(DisplayAdditionalFeeNote; DisplayAddFeeNote)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Additional Fee Note';
                        ToolTip = 'Specifies when the additional fee note is to be show';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            InitLogInteraction();
            LogInteractionEnable := LogInteract;
        end;
    }

    rendering
    {
        layout("SalesInvoicewithAdv.rdl")
        {
            Type = RDLC;
            LayoutFile = './Src/Reports/SalesInvoicewithAdv.rdl';
            Caption = 'Sales Invoice with Advance (RDL)';
            Summary = 'The Sales Invoice with Advance (RDL) provides a detailed layout.';
        }
        layout("SalesInvoicewithAdvEmail.docx")
        {
            Type = Word;
            LayoutFile = './Src/Reports/SalesInvoicewithAdvEmail.docx';
            Caption = 'Sales Invoice with Advance Email (Word)';
            Summary = 'The Sales Invoice with Advance Email (Word) provides an email body layout.';
        }
    }

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        TempLineFeeNoteOnReportHist: Record "Line Fee Note on Report Hist." temporary;
        Customer: Record Customer;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        VATClause: Record "VAT Clause";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        SegManagement: Codeunit SegManagement;
        LogInteractionEnable: Boolean;
        NoOfLoops: Integer;
        ExchRateLbl: Label 'Exchange Rate %1 %2 / %3 %4', Comment = '%1 = Calculated Exch. Rate, %2 = General Ledger Setup LCY Code, %3 = Exch. Rate Exchange Rate Amount, %4 = Currency Code';
        DocumentLbl: Label 'Invoice';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        ShipmentMethodLbl: Label 'Shipment Method';
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
        PrepayedLbl: Label 'Prepayed Advances';
        TotalAfterPrepayedLbl: Label 'Total after Prepayed Advances';
        PaymentsLbl: Label 'Payments List';
        GreetingLbl: Label 'Hello';
        ClosingLbl: Label 'Sincerely';
        BodyLbl: Label 'Thank you for your business. Your invoice is attached to this message.';
        DocumentNoLbl: Label 'No.';
        QRPaymentLbl: Label 'QR Payment';

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
        ExchRateText: Text[50];
        VATClauseText: Text;
        CalculatedExchRate: Decimal;
        PrepaymentAmt: Decimal;
        TotalAfterPrepayed: Decimal;
        NoOfCop: Integer;
        LogInteract: Boolean;
        QRPaymentCode: Text;
        DisplayAddFeeNote: Boolean;

    procedure InitLogInteraction()
    begin
        LogInteract := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Sales Inv.") <> '';
    end;

    local procedure GetLineFeeNoteOnReportHist(SalesInvoiceHeaderNo: Code[20])
    var
        LineFeeNoteOnReportHist: Record "Line Fee Note on Report Hist.";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        TempLineFeeNoteOnReportHist.DeleteAll();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not CustLedgerEntry.FindFirst() then
            exit;

        if not Customer.Get(CustLedgerEntry."Customer No.") then
            exit;

        LineFeeNoteOnReportHist.SetRange("Cust. Ledger Entry No", CustLedgerEntry."Entry No.");
        LineFeeNoteOnReportHist.SetRange("Language Code", Customer."Language Code");
        if LineFeeNoteOnReportHist.FindSet() then
            repeat
                TempLineFeeNoteOnReportHist.Init();
                TempLineFeeNoteOnReportHist.Copy(LineFeeNoteOnReportHist);
                TempLineFeeNoteOnReportHist.Insert();
            until LineFeeNoteOnReportHist.Next() = 0
        else begin
            LineFeeNoteOnReportHist.SetRange("Language Code", LanguageMgt.GetUserLanguageCode());
            if LineFeeNoteOnReportHist.FindSet() then
                repeat
                    TempLineFeeNoteOnReportHist.Init();
                    TempLineFeeNoteOnReportHist.Copy(LineFeeNoteOnReportHist);
                    TempLineFeeNoteOnReportHist.Insert();
                until LineFeeNoteOnReportHist.Next() = 0;
        end;
    end;

    local procedure FormatDocumentFields(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        FormatDocument.SetPaymentTerms(PaymentTerms, SalesInvoiceHeader."Payment Terms Code", SalesInvoiceHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, SalesInvoiceHeader."Shipment Method Code", SalesInvoiceHeader."Language Code");
        FormatDocument.SetPaymentMethod(PaymentMethod, SalesInvoiceHeader."Payment Method Code", SalesInvoiceHeader."Language Code");

        if SalesInvoiceHeader."Reason Code" = '' then
            ReasonCode.Init()
        else
            ReasonCode.Get(SalesInvoiceHeader."Reason Code");

        FormatDocumentMgtCZL.SetPaymentSymbols(
          PaymentSymbol, PaymentSymbolLabel,
          SalesInvoiceHeader."Variable Symbol CZL", SalesInvoiceHeader.FieldCaption("Variable Symbol CZL"),
          SalesInvoiceHeader."Constant Symbol CZL", SalesInvoiceHeader.FieldCaption("Constant Symbol CZL"),
          SalesInvoiceHeader."Specific Symbol CZL", SalesInvoiceHeader.FieldCaption("Specific Symbol CZL"));
        DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText(SalesInvoiceHeader."Language Code");
    end;

    local procedure FormatAddressFields(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        FormatAddress.SalesInvBillTo(CustAddr, SalesInvoiceHeader);
        FormatAddress.SalesInvShipTo(ShipToAddr, CustAddr, SalesInvoiceHeader);
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;

    local procedure GenerateQRPaymentCode()
    var
        BarcodeSymbology2D: Enum "Barcode Symbology 2D";
        BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
        BarcodeString: Text;
    begin
        BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
        BarcodeSymbology2D := Enum::"Barcode Symbology 2D"::"QR-Code";
        BarcodeString := "Sales Invoice Header".CreateSalesInvoicePaymentQRCodeStringCZL();
        QRPaymentCode := BarcodeFontProvider2D.EncodeFont(BarcodeString, BarcodeSymbology2D);
    end;
}

