// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Setup;
using System.Utilities;

report 18014 "Return Order Confirmation GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/ReturnOrderConfirmation.rdl';
    Caption = 'Return Order Confirmation';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.")
                                where("Document Type" = const("Return Order"));
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'Sales Return Order';

            column(No_SalesHeader; "No.")
            {
            }
            column(InvDiscAmountCaption; InvDiscAmountCaptionLbl)
            {
            }
            column(UnitPriceCaption; UnitPriceCaptionLbl)
            {
            }
            column(DiscountCaption; DiscountCaptionLbl)
            {
            }
            column(AmountCaption; AmountCaptionLbl)
            {
            }
            column(HomePageCaption; HomePageCaptionLbl)
            {
            }
            column(EmailCaption; EmailCaptionLbl)
            {
            }
            column(DouDateCaption; DouDateCaptionLbl)
            {
            }
            column(AllowInvoicDiscCaption; AllowInvoicDiscCaptionLbl)
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

                    column(CopyText; StrSubstNo(ReturnOrderLbl, CopyText))
                    {
                    }
                    column(SubtotalCaption; SubtotalCaptionLbl)
                    {
                    }
                    column(TotalSubTotal; TotalSubTotal)
                    {
                        AutoFormatExpression = "Sales Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(TotalText; TotalText)
                    {
                    }
                    column(TotalAmount; TotalAmount)
                    {
                        AutoFormatExpression = "Sales Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(CompanyInfo_GST_RegistrationNo; CompanyInfo."GST Registration No.")
                    {
                    }
                    column(Customer_GST_RegistrationNo; Customer."GST Registration No.")
                    {
                    }
                    column(CompanyRegistrationLbl; CompanyRegistrationLbl)
                    {
                    }
                    column(CustomerRegistrationLbl; CustomerRegistrationLbl)
                    {
                    }
                    column(GSTComponentCode1; GSTComponentCodeName[6] + ' Amount')
                    {
                    }
                    column(GSTComponentCode2; GSTComponentCodeName[2] + ' Amount')
                    {
                    }
                    column(GSTComponentCode3; GSTComponentCodeName[3] + ' Amount')
                    {
                    }
                    column(GSTComponentCode4; GSTComponentCodeName[5] + 'Amount')
                    {
                    }
                    column(GSTCompAmount1; Abs(CGSTAmt))
                    {
                    }
                    column(GSTCompAmount2; Abs(SGSTAmt))
                    {
                    }
                    column(GSTCompAmount3; Abs(IGSTAmt))
                    {
                    }
                    column(GSTCompAmount4; Abs(0.00))
                    {
                    }
                    column(TCSAmtCaption; TCSAmtCaptionLbl)
                    {
                    }
                    column(CessAmount; CessAmount)
                    {
                    }
                    column(GLAccountNo; GLAccountNo)
                    {
                    }
                    column(TCSGSTCompAmount1; Abs(TCSGSTCompAmount))
                    {
                    }
                    column(CustAddr1; CustAddr[1])
                    {
                    }
                    column(CompanyAddr1; CompanyAddr[1])
                    {
                    }
                    column(CustAddr2; CustAddr[2])
                    {
                    }
                    column(CompanyAddr2; CompanyAddr[2])
                    {
                    }
                    column(CustAddr3; CustAddr[3])
                    {
                    }
                    column(CompanyAddr3; CompanyAddr[3])
                    {
                    }
                    column(CustAddr4; CustAddr[4])
                    {
                    }
                    column(CompanyAddr4; CompanyAddr[4])
                    {
                    }
                    column(CustAddr5; CustAddr[5])
                    {
                    }
                    column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
                    {
                    }
                    column(CustAddr6; CustAddr[6])
                    {
                    }
                    column(CompanyInfo3Picture; CompanyInfo3.Picture)
                    {
                    }
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoEmail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoGiroNo; CompanyInfo."Giro No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyInfo."Bank Name")
                    {
                    }
                    column(CompanyInfoBankAccountNo; CompanyInfo."Bank Account No.")
                    {
                    }
                    column(BilltoCustNo_SalesHeader; "Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(DocDate_SalesHeader; Format("Sales Header"."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_SalesHeader; "Sales Header"."VAT Registration No.")
                    {
                    }
                    column(SalesPersonText; SalesPersonText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(No1_SalesHeader; "Sales Header"."No.")
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourRef_SalesHeader; "Sales Header"."Your Reference")
                    {
                    }
                    column(CustAddr7; CustAddr[7])
                    {
                    }
                    column(CustAddr8; CustAddr[8])
                    {
                    }
                    column(CompanyAddr5; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr6; CompanyAddr[6])
                    {
                    }
                    column(PricesInclVAT_SalesHeader; "Sales Header"."Prices Including VAT")
                    {
                    }
                    column(PageCaption; StrSubstNo(PageLbl, ''))
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PricesInclVATYesNo; Format("Sales Header"."Prices Including VAT"))
                    {
                    }
                    column(PhoneNoCaption; PhoneNoCaptionLbl)
                    {
                    }
                    column(VATRegNoCaption; VATRegNoCaptionLbl)
                    {
                    }
                    column(GiroNoCaption; GiroNoCaptionLbl)
                    {
                    }
                    column(BankNameCaption; BankNameCaptionLbl)
                    {
                    }
                    column(BankAccNoCaption; BankAccNoCaptionLbl)
                    {
                    }
                    column(ReturnOrderNoCaption; ReturnOrderNoCaptionLbl)
                    {
                    }
                    column(BilltoCustNo_SalesHeaderCaption; "Sales Header".FieldCaption("Bill-to Customer No."))
                    {
                    }
                    column(PricesInclVAT_SalesHeaderCaption; "Sales Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = sorting(Number)
                                            where(Number = filter(1 ..));

                        column(DimText; DimText)
                        {
                        }
                        column(DimensionLoop1Number; Number)
                        {
                        }
                        column(HeaderDimCaption; HeaderDimCaptionLbl)
                        {
                        }
                        column(TotGSTAmt; TotGSTAmt)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            DimText := GetDimensionText(DimSetEntry1, Number, Continue);
                            if not Continue then
                                CurrReport.Break();
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowInterInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Sales Line"; "Sales Line")
                    {
                        DataItemLink = "Document Type" = field("Document Type"),
                                       "Document No." = field("No.");
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = sorting("Document Type", "Document No.", "Line No.");


                        trigger OnPreDataItem()
                        begin
                            CurrReport.Break();
                        end;
                    }
                    dataitem(RoundLoop; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(TypeInt; TypeInt)
                        {
                        }
                        column(No_SalesLine; SalesLineNo)
                        {
                        }
                        column(LineNo_SalesLine; SalesLineLineNo)
                        {
                        }
                        column(LineAmount_SalesLine; TempSalesLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Description_SalesLine; "Sales Line".Description)
                        {
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(DocNo_SalesLine; TempSalesLine."Document No.")
                        {
                        }
                        column(No2_SalesLine; "Sales Line"."No.")
                        {
                        }
                        column(No2_SalesLinecaption; "Sales Line".FieldCaption("No."))
                        {
                        }
                        column(Qty_SalesLine; "Sales Line".Quantity)
                        {
                        }
                        column(UnitofMeasure_SalesLine; "Sales Line"."Unit of Measure")
                        {
                        }
                        column(UnitPrice_SalesLine; "Sales Line"."Unit Price")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 2;
                        }
                        column(LineDiscount_SalesLine; "Sales Line"."Line Discount %")
                        {
                        }
                        column(AllowInvDisc_SalesLine; "Sales Line"."Allow Invoice Disc.")
                        {
                        }
                        column(VATIdentifier_SalesLine; "Sales Line"."VAT Identifier")
                        {
                        }
                        column(AllowInvDiscYesNo; Format("Sales Line"."Allow Invoice Disc."))
                        {
                        }
                        column(InvoiceDiscAmt_SalesLine; -TempSalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(SalesLineTotalTDSTCSInclSHECESS; 0)
                        {
                        }
                        column(InvoiceDiscAmountt_SalesLine; TempSalesLine."Line Amount" - TempSalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVATAmountText; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(VATAmount; VATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AmtTotalTDSTCSInclSHECESS; TempSalesLine."Line Amount" - TempSalesLine."Inv. Discount Amount" + VATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATDiscountAmount; -VATDiscountAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseDiscount; "Sales Header"."VAT Base Discount %")
                        {
                        }
                        column(VATBaseAmount; VATBaseAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmountInclVAT; TotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInvDiscAmount; TotalInvoiceDiscountAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TCSAmountCaption; TCSAmountCaptionLbl)
                        {
                        }
                        column(PayDiscountVATCaption; PayDiscountVATCaptionLbl)
                        {
                        }
                        column(Description_SalesLineCaption; "Sales Line".FieldCaption(Description))
                        {
                        }
                        column(Quantity_SalesLineCaption; "Sales Line".FieldCaption(Quantity))
                        {
                        }
                        column(UnitofMeasure_SalesLineCaption; "Sales Line".FieldCaption("Unit of Measure"))
                        {
                        }
                        column(AllowInvDisc_SalesLineCaption; "Sales Line".FieldCaption("Allow Invoice Disc."))
                        {
                        }
                        column(VATIdentifier_SalesLineCaption; "Sales Line".FieldCaption("VAT Identifier"))
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimTextLoop2; DimText)
                            {
                            }
                            column(DimensionLoop2No; Number)
                            {
                            }
                            column(LineDimensionsCaption; LineDimensionsCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                DimText := GetDimensionText(DimSetEntry2, Number, Continue);
                                if not Continue then
                                    CurrReport.Break();
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowInterInfo then
                                    CurrReport.Break();

                                DimSetEntry2.SetRange("Dimension Set ID", "Sales Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            TaxTransactionValue: Record "Tax Transaction Value";
                            TCSSetup: Record "TCS Setup";
                            GSTSetup: Record "GST Setup";
                        begin
                            if Number = 1 then
                                TempSalesLine.FindFirst()
                            else
                                TempSalesLine.Next();
                            "Sales Line" := TempSalesLine;

                            if not GSTSetup.Get() then
                                exit;

                            if not TCSSetup.Get() then
                                exit;

                            GetGSTAmounts(TaxTransactionValue, TempSalesLine, GSTSetup);

                            GetGSTCaptions(TaxTransactionValue, TempSalesLine, GSTSetup);

                            GetCessAmount(TaxTransactionValue, TempSalesLine, GSTSetup);

                            GetTCSAmount(TaxTransactionValue, TempSalesLine, TCSSetup);

                            TypeInt := "Sales Line".Type.AsInteger();

                            GetInvoiceRoundingAmount("Sales Header");

                            if "Sales Line"."No." <> GLAccountNo then begin
                                SalesLineLineNo := "Sales Line"."Line No.";
                                TotalSubTotal += "Sales Line"."Line Amount";
                                TotalInvoiceDiscountAmount -= "Sales Line"."Inv. Discount Amount";
                                TotalAmount += "Sales Line".Amount;
                                TotalAmountInclVAT := TempVATAmountLine.GetTotalAmountInclVAT() + TotGSTAmt;
                            end;

                        end;

                        trigger OnPostDataItem()
                        begin
                            TempSalesLine.DeleteAll();
                        end;

                        trigger OnPreDataItem()
                        begin
                            MoreLines := TempSalesLine.FindLast();
                            while MoreLines and
                                (TempSalesLine.Description = '') and
                                (TempSalesLine."Description 2" = '') and
                                (TempSalesLine."No." = '') and
                                (TempSalesLine.Quantity = 0) and
                                (TempSalesLine.Amount = 0)
                            do
                                MoreLines := TempSalesLine.Next(-1) <> 0;

                            if not MoreLines then
                                CurrReport.Break();

                            TempSalesLine.SetRange("Line No.", 0, TempSalesLine."Line No.");
                            SetRange(Number, 1, TempSalesLine.Count);
                        end;
                    }
                    dataitem(VATCounter; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(VATAmountLineVATBase; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVATAmount; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineLineAmount; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineInvDiscBaseAmount; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineInvDiscAmount; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVAT; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmountLineVATIdentifier; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATPercentCaption; VATPercentCaptionLbl)
                        {
                        }
                        column(VATBaseCaption; VATBaseCaptionLbl)
                        {
                        }
                        column(VATAmountCaption; VATAmountCaptionLbl)
                        {
                        }
                        column(VATAmountSpecCaption; VATAmountSpecCaptionLbl)
                        {
                        }
                        column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
                        {
                        }
                        column(LineAmountCaption; LineAmountCaptionLbl)
                        {
                        }
                        column(VATIdentifierCaption; VATIdentifierCaptionLbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {

                        }
                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if VATAmount = 0 then
                                CurrReport.Break();
                            SetRange(Number, 1, TempVATAmountLine.Count);
                        end;
                    }
                    dataitem(VATCounterLCY; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(VALExchRate; VALExchRate)
                        {
                        }
                        column(VALSpecLCYHeader; VALSpecLCYHeader)
                        {
                        }
                        column(VALVATBaseLCY; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATAmountLCY; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVATPercent; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmountLineVATIdentifierLCY; TempVATAmountLine."VAT Identifier")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);

                            VALVATBaseLCY := Round(
                                CurrExchRate.ExchangeAmtFCYToLCY(
                                    "Sales Header"."Posting Date",
                                    "Sales Header"."Currency Code",
                                    TempVATAmountLine."VAT Base",
                                    "Sales Header"."Currency Factor"));
                            VALVATAmountLCY := Round(
                                CurrExchRate.ExchangeAmtFCYToLCY(
                                    "Sales Header"."Posting Date",
                                    "Sales Header"."Currency Code",
                                    TempVATAmountLine."VAT Amount",
                                    "Sales Header"."Currency Factor"));
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GLSetup."Print VAT specification in LCY") or
                               ("Sales Header"."Currency Code" = '') or
                               (TempVATAmountLine.GetTotalVATAmount() = 0)
                            then
                                CurrReport.Break();

                            SetRange(Number, 1, TempVATAmountLine.Count);
                            if GLSetup."LCY Code" = '' then
                                VALSpecLCYHeader := VatAmtLbl + LocalCurrLbl
                            else
                                VALSpecLCYHeader := VatAmtLbl + Format(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency("Sales Header"."Posting Date", "Sales Header"."Currency Code", 1);
                            VALExchRate := StrSubstNo(
                                ExchangeRAteLbl,
                                CurrExchRate."Relational Exch. Rate Amount",
                                CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem(Total; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

                        column(SalesHeaderSelltoCustomerNo; "Sales Header"."Sell-to Customer No.")
                        {
                        }
                        column(ShipToAddr8; ShipToAddr[8])
                        {
                        }
                        column(ShipToAddr7; ShipToAddr[7])
                        {
                        }
                        column(ShipToAddr6; ShipToAddr[6])
                        {
                        }
                        column(ShipToAddr5; ShipToAddr[5])
                        {
                        }
                        column(ShipToAddr4; ShipToAddr[4])
                        {
                        }
                        column(ShipToAddr3; ShipToAddr[3])
                        {
                        }
                        column(ShipToAddr2; ShipToAddr[2])
                        {
                        }
                        column(ShipToAddr1; ShipToAddr[1])
                        {
                        }
                        column(ShowShippingAddr; ShowShippingAddr)
                        {
                        }
                        column(ShiptoAddressCaption; ShiptoAddressCaptionLbl)
                        {
                        }
                        column(SalesHeaderSelltoCustomerNoCaption; "Sales Header".FieldCaption("Sell-to Customer No."))
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if not ShowShippingAddr then
                                CurrReport.Break();
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                var
                    SalesPost: Codeunit "Sales-Post";
                begin
                    Clear(TempSalesLine);
                    Clear(SalesPost);

                    TempSalesLine.DeleteAll();
                    TempVATAmountLine.DeleteAll();

                    SalesPost.GetSalesLines("Sales Header", TempSalesLine, 0);
                    TempSalesLine.CalcVATAmountLines(0, "Sales Header", TempSalesLine, TempVATAmountLine);
                    TempSalesLine.UpdateVATOnLines(0, "Sales Header", TempSalesLine, TempVATAmountLine);

                    VATAmount := TempVATAmountLine.GetTotalVATAmount();
                    VATBaseAmount := TempVATAmountLine.GetTotalVATBase();
                    VATDiscountAmount := TempVATAmountLine.GetTotalVATDiscount(
                        "Sales Header"."Currency Code",
                        "Sales Header"."Prices Including VAT");
                    TotalAmountInclVAT := TempVATAmountLine.GetTotalAmountInclVAT() + TotGSTAmt;

                    if Number > 1 then begin
                        CopyText := CopyLbl;
                        OutputNo += 1;
                    end;

                    TotalSubTotal := 0;
                    SGSTAmt := 0;
                    CGSTAmt := 0;
                    IGSTAmt := 0;
                    TotalInvoiceDiscountAmount := 0;
                    TotalAmount := 0;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then
                        SalesCountPrinted.Run("Sales Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopy) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CompanyInfo.Get();
                Customer.Get("Bill-to Customer No.");

                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInfo);

                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

                if "Salesperson Code" = '' then begin
                    Clear(SalesPurchPerson);
                    SalesPersonText := '';
                end else begin
                    SalesPurchPerson.Get("Salesperson Code");
                    SalesPersonText := SalesPerLbl;
                end;

                if "Your Reference" = '' then
                    ReferenceText := ''
                else
                    ReferenceText := CopyStr(FieldCaption("Your Reference"), 1, 80);

                if "VAT Registration No." = '' then
                    VATNoText := ''
                else
                    VATNoText := CopyStr(FieldCaption("VAT Registration No."), 1, 80);

                if "Currency Code" = '' then begin
                    GLSetup.TestField("LCY Code");
                    TotalText := StrSubstNo(TotalLbl, GLSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(TotalIncVatLbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(TotalExclVatLbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(TotalLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(TotalIncVatLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(TotalExclVatLbl, "Currency Code");
                end;

                FormatAddr.SalesHeaderBillTo(CustAddr, "Sales Header");
                ShowShippingAddr := "Sell-to Customer No." <> "Bill-to Customer No.";
                for i := 1 TO ArrayLen(ShipToAddr) do
                    if ShipToAddr[i] <> CustAddr[i] then
                        ShowShippingAddr := true;

                if LogIntaction then
                    if not CurrReport.Preview then
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              18, "No.", 0, 0, Database::Contact, "Bill-to Contact No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", "Opportunity No.")
                        else
                            SegManagement.LogDocument(
                              18, "No.", 0, 0, Database::Customer, "Bill-to Customer No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", "Opportunity No.");
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
                    field(NoOfCopies; NoOfCopy)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of copies that need to be printed.';
                    }
                    field(ShowInternalInfo; ShowInterInfo)
                    {
                        Caption = 'Show Internal Information';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the line internal information.';
                    }
                    field(LogInteraction; LogIntaction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the log Interaction for archived document to be done or not.';
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
            LogInteractionEnable := LogIntaction;
        end;
    }

    labels
    {
    }


    trigger OnInitReport()
    begin
        GLSetup.Get();
        CompanyInfo.Get();
        SalesSetup.Get();

        case SalesSetup."Logo Position on Documents" of
            SalesSetup."Logo Position on Documents"::"No Logo":
                ;
            SalesSetup."Logo Position on Documents"::Left:
                begin
                    CompanyInfo3.Get();
                    CompanyInfo3.CalcFields(Picture);
                end;
            SalesSetup."Logo Position on Documents"::Center:
                begin
                    CompanyInfo1.Get();
                    CompanyInfo1.CalcFields(Picture);
                end;
            SalesSetup."Logo Position on Documents"::Right:
                begin
                    CompanyInfo2.Get();
                    CompanyInfo2.CalcFields(Picture);
                end;
        end;
        GLSetup.Get();
    end;

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        CompanyInfo3: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        Customer: Record "Customer";
        GLSetup: Record "General Ledger Setup";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInfo: Record "Company Information";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        CurrExchRate: Record "Currency Exchange Rate";
        SalesCountPrinted: Codeunit "Sales-Printed";
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        CustAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        SalesPersonText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        TotalText: Text[50];
        TotalExclVATText: Text[50];
        TotalInclVATText: Text[50];
        MoreLines: Boolean;
        NoOfCopy: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        ShowShippingAddr: Boolean;
        i: Integer;
        DimText: Text[120];
        ShowInterInfo: Boolean;
        Continue: Boolean;
        VATAmount: Decimal;
        TotGSTAmt: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        LogIntaction: Boolean;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        OutputNo: Integer;
        TypeInt: Integer;
        SalesLineNo: Code[20];
        SalesLineLineNo: Integer;
        [InDataSet]
        LogInteractionEnable: Boolean;
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;
        TotalInvoiceDiscountAmount: Decimal;
        CessAmount: Decimal;
        GLAccountNo: Code[20];
        TCSGSTCompAmount: Decimal;
        GSTComponentCodeName: array[20] of Code[10];
        IGSTLbl: Label 'IGST';
        SGSTLbl: Label 'SGST';
        CGSTLbl: Label 'CGST';
        CESSLbl: Label 'CESS';
        GSTLbl: Label 'GST';
        GSTCESSLbl: Label 'GST CESS';
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        VatAmtLbl: Label 'VAT Amount Specification in ';
        LocalCurrLbl: Label 'Local Currency';
        ExchangeRAteLbl: Label 'Exchange rate: %1/%2', Comment = '%1 Lcy Amt, %2 Currency Amt';
        SalesPerLbl: Label 'Salesperson';
        TotalLbl: Label 'Total %1', Comment = ' %1 AMT';
        TotalIncVatLbl: Label 'Total %1 Incl. Taxes', Comment = '%1 Amt';
        CopyLbl: Label 'COPY';
        ReturnOrderLbl: Label 'Return Order Confirmation %1', Comment = '%1 Return Order Caption';
        PageLbl: Label 'Page %1', comment = '%1 Page Caption';
        TotalExclVatLbl: Label 'Total %1 Excl. Taxes', Comment = '%1 Currency Amt %2 Lcy Code Amt';
        InvDiscAmountCaptionLbl: Label 'Invoice Discount Amount';
        UnitPriceCaptionLbl: Label 'Unit Price';
        DiscountCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        PhoneNoCaptionLbl: Label 'Phone No.';
        VATRegNoCaptionLbl: Label 'VAT Registration No.';
        GiroNoCaptionLbl: Label 'Giro No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccNoCaptionLbl: Label 'Account No.';
        TCSAmtCaptionLbl: Label 'TCS Amount';
        ReturnOrderNoCaptionLbl: Label 'Return Order No.';
        HeaderDimCaptionLbl: Label 'Header Dimensions';
        TCSAmountCaptionLbl: Label 'TCS Amount';
        PayDiscountVATCaptionLbl: Label 'Payment Discount on VAT';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATPercentCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmountCaptionLbl: Label 'VAT Amount';
        VATAmountSpecCaptionLbl: Label 'VAT Amount Specification';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        LineAmountCaptionLbl: Label 'Line Amount';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        TotalCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        HomePageCaptionLbl: Label 'Home Page';
        EmailCaptionLbl: Label 'E-Mail';
        DouDateCaptionLbl: Label 'Document Date';
        AllowInvoicDiscCaptionLbl: Label 'Allow Invoice Discount';
        CompanyRegistrationLbl: Label 'Company Registration No.';
        CustomerRegistrationLbl: Label 'Customer GST Reg No.';

    procedure InitLogInteraction()
    begin
        LogIntaction := SegManagement.FindInteractionTemplateCode(18) <> '';
    end;

    procedure InitializeRequest(ShowInternalInfoFrom: Boolean; LogInteractionFrom: Boolean)
    begin
        InitLogInteraction();
        ShowInterInfo := ShowInternalInfoFrom;
        LogIntaction := LogInteractionFrom;
    end;

    local procedure GetDimensionText(
        var DimSetEntry: Record "Dimension Set Entry";
        Number: Integer;
        var Continue: Boolean): Text[120]
    var
        DimensionText: Text[120];
        PrevDimText: Text[75];
        DimensionTextLbl: Label '%1; %2 - %3', Comment = ' %1 = DimText, %2 = Dimension Code, %3 = Dimension Value Code';
        DimensionLbl: Label '%1 - %2', Comment = '%1 = Dimension Code, %2 = Dimension Value Code';
    begin
        Continue := false;
        if Number = 1 then
            if not DimSetEntry.FindSet() then
                exit;

        repeat
            PrevDimText := CopyStr((DimensionText), 1, 75);
            if DimensionText = '' then
                DimensionText := StrSubstNo(DimensionLbl, DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code")
            else
                DimensionText := CopyStr(
                    StrSubstNo(
                        DimensionTextLbl,
                        DimensionText,
                        DimSetEntry."Dimension Code",
                        DimSetEntry."Dimension Value Code"),
                    1,
                    120);

            if StrLen(DimensionText) > MaxStrLen(PrevDimText) then begin
                Continue := true;
                exit(PrevDimText);
            end;
        until DimSetEntry.Next() = 0;

        exit(DimensionText)
    end;

    procedure GetGSTRoundingPrecision(ComponentName: Code[30]): Decimal
    var
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        GSTRoundingPrecision: Decimal;
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, ComponentName);
        TaxComponent.FindFirst();
        if TaxComponent."Rounding Precision" <> 0 then
            GSTRoundingPrecision := TaxComponent."Rounding Precision"
        else
            GSTRoundingPrecision := 1;
        exit(GSTRoundingPrecision);
    end;

    local procedure GetInvoiceRoundingAmount(SalesHeader: Record "Sales Header")
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        Customer.SetRange("No.", SalesHeader."Sell-to Customer No.");
        Customer.SetRange("Customer Posting Group", SalesHeader."Customer Posting Group");
        if Customer.FindFirst() then begin
            CustomerPostingGroup.SetRange(Code, Customer."Customer Posting Group");
            if CustomerPostingGroup.FindFirst() then
                GLAccountNo := CustomerPostingGroup."Invoice Rounding Account";
        end;
    end;

    local procedure GetGSTAmounts(TaxTransactionValue: Record "Tax Transaction Value";
        SalesLine: Record "Sales Line";
        GSTSetup: Record "GST Setup")
    var
        ComponentName: Code[30];
    begin
        ComponentName := GetComponentName(SalesLine, GSTSetup);

        if (SalesLine.Type <> SalesLine.Type::" ") then begin
            TaxTransactionValue.Reset();
            TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
            TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            if TaxTransactionValue.FindSet() then
                repeat
                    case TaxTransactionValue."Value ID" of
                        6:
                            SGSTAmt += Round(TaxTransactionValue.Amount, GetGSTRoundingPrecision(ComponentName));
                        2:
                            CGSTAmt += Round(TaxTransactionValue.Amount, GetGSTRoundingPrecision(ComponentName));
                        3:
                            IGSTAmt += Round(TaxTransactionValue.Amount, GetGSTRoundingPrecision(ComponentName));
                    end;
                until TaxTransactionValue.Next() = 0;
        end;
    end;

    local procedure GetCessAmount(TaxTransactionValue: Record "Tax Transaction Value";
        SalesLine: Record "Sales Line";
        GSTSetup: Record "GST Setup")
    begin
        if (SalesLine.Type <> SalesLine.Type::" ") then begin
            TaxTransactionValue.Reset();
            TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."Cess Tax Type");
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            if TaxTransactionValue.FindSet() then
                repeat
                    CessAmount += Round(TaxTransactionValue.Amount, GetGSTRoundingPrecision(GetComponentName(SalesLine, GSTSetup)));
                until TaxTransactionValue.Next() = 0;
        end;
    end;

    local procedure GetGSTCaptions(TaxTransactionValue: Record "Tax Transaction Value";
        SalesLine: Record "Sales Line";
        GSTSetup: Record "GST Setup")
    begin
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
        TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if TaxTransactionValue.FindSet() then
            repeat
                case TaxTransactionValue."Value ID" of
                    6:
                        GSTComponentCodeName[6] := SGSTLbl;
                    2:
                        GSTComponentCodeName[2] := CGSTLbl;
                    3:
                        GSTComponentCodeName[3] := IGSTLbl;
                end;
            until TaxTransactionValue.Next() = 0;
    end;

    local procedure GetComponentName(SalesLine: Record "Sales Line";
        GSTSetup: Record "GST Setup"): Code[30]
    var
        ComponentName: Code[30];
    begin
        if GSTSetup."GST Tax Type" = GSTLbl then
            if SalesLine."GST Jurisdiction Type" = SalesLine."GST Jurisdiction Type"::Interstate then
                ComponentName := IGSTLbl
            else
                ComponentName := CGSTLbl
        else
            if GSTSetup."Cess Tax Type" = GSTCESSLbl then
                ComponentName := CESSLbl;
        exit(ComponentName)
    end;

    local procedure GetTCSAmount(TaxTransactionValue: Record "Tax Transaction Value";
        SalesLine: Record "Sales Line";
        TCSSetup: Record "TCS Setup")
    begin
        if (SalesLine.Type <> SalesLine.Type::" ") then begin
            TaxTransactionValue.Reset();
            TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
            TaxTransactionValue.SetRange("Tax Type", TCSSetup."Tax Type");
            TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            if TaxTransactionValue.FindSet() then
                repeat
                    TCSGSTCompAmount += TaxTransactionValue.Amount;
                until TaxTransactionValue.Next() = 0;
        end;
        TCSGSTCompAmount := Round(TCSGSTCompAmount, 1);
    end;
}
