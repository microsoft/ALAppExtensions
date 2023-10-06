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
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Globalization;
using System.Utilities;

report 18017 "Sales - Quote GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/SalesQuote.rdl';
    Caption = 'Sales - Quote';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Quote));
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'Sales Quote';

            column(DocumentType_SalesHeader; "Document Type")
            {
            }
            column(No_SalesHeader; "No.")
            {
            }
            column(InvDiscountAmountCaption; InvDiscountAmountCaptionLbl)
            {
            }
            column(VATCaption; VATCaptionLbl)
            {
            }
            column(VATBaseCaption; VATBaseCaptionLbl)
            {
            }
            column(VATAmountCaption; VATAmountCaptionLbl)
            {
            }
            column(VATIdentifierCaption; VATIdentifierCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

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
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfo3Picture; CompanyInfo3.Picture)
                    {
                    }
                    column(DocumentCaptionCopyText; StrSubstNo(SalesQuoteLbl, CopyText))
                    {
                    }
                    column(GSTComponentCode1; GSTComponentCodeName[2] + ' Amount')
                    {
                    }
                    column(GSTComponentCode2; GSTComponentCodeName[3] + ' Amount')
                    {
                    }
                    column(GSTComponentCode3; GSTComponentCodeName[5] + ' Amount')
                    {
                    }
                    column(GSTComponentCode4; GSTComponentCodeName[6] + ' Amount')
                    {
                    }
                    column(GSTCompAmount1; Abs(GSTCompAmount[2]))
                    {
                    }
                    column(GSTCompAmount2; Abs(GSTCompAmount[3]))
                    {
                    }
                    column(GSTCompAmount3; Abs(GSTCompAmount[5]))
                    {
                    }
                    column(GSTCompAmount4; Abs(GSTCompAmount[6]))
                    {
                    }
                    column(IsGSTApplicable; IsGSTApplicable)
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
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoEMail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
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
                    column(PaymentTermsDescription; PaymentTerms.Description)
                    {
                    }
                    column(ShipmentMethodDescription; ShipmentMethod.Description)
                    {
                    }
                    column(BillToCustNo_SalesHeader; "Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(DocumentDate_SalesHeader; Format("Sales Header"."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_SalesHeader; "Sales Header"."VAT Registration No.")
                    {
                    }
                    column(ShipmentDate_SalesHeader; Format("Sales Header"."Shipment Date"))
                    {
                    }
                    column(SalesPersonText; SalesPersonText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourReference_SalesHeader; "Sales Header"."Your Reference")
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
                    column(HomePageCaption; HomePageCaptionLbl)
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
                    column(BankAccountNoCaption; BankAccountNoCaptionLbl)
                    {
                    }
                    column(ShipmentDateCaption; ShipmentDateCaptionLbl)
                    {
                    }
                    column(QuoteNoCaption; QuoteNoCaptionLbl)
                    {
                    }
                    column(EMailCaption1; EMailCaption1Lbl)
                    {
                    }
                    column(PaymentTermsCaption; PaymentTermsCaptionLbl)
                    {
                    }
                    column(ShipmentMethodCaption; ShipmentMethodCaptionLbl)
                    {
                    }
                    column(DocumentDateCaption; DocumentDateCaptionLbl)
                    {
                    }
                    column(BillToCustNo_SalesHeaderCaption; "Sales Header".FieldCaption("Bill-to Customer No."))
                    {
                    }
                    column(PricesInclVAT_SalesHeaderCaption; "Sales Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    column(TotGSTAmt; TotGSTAmt)
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
                        column(HeaderDimensionsCaption; HeaderDimensionsCaptionLbl)
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
                            if not ShowIntInfo then
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

                        column(SalesLineLineAmount; TempSalesLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(No_SalesLine; "Sales Line"."No.")
                        {
                        }
                        column(Description_SalesLine; "Sales Line".Description)
                        {
                        }
                        column(Quantity_SalesLine; "Sales Line".Quantity)
                        {
                        }
                        column(UnitOfMeasure_SalesLine; "Sales Line"."Unit of Measure")
                        {
                        }
                        column(LineAmt_SalesLine; "Sales Line"."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
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
                        column(LineDiscount_SalesLineAmount; "Sales Line"."Line Discount Amount")
                        {
                        }
                        column(Type_SalesLine; Format("Sales Line".Type))
                        {
                        }
                        column(No1_SalesLine; "Sales Line"."Line No.")
                        {
                        }
                        column(AllowInvoiceDisYesNo; Format("Sales Line"."Allow Invoice Disc."))
                        {
                        }
                        column(VATIdentifier_SalesLine; "Sales Line"."VAT Identifier")
                        {
                        }
                        column(SalesLineInvDiscountAmount; -TempSalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(VATAmount; VATAmount)
                        {
                        }
                        column(ChargesAmount; ChargesAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(OtherTaxesAmount; OtherTaxesAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(HSNSACCaption; HSNSACLbl)
                        {
                        }
                        column(SalesLineHSnCode; TempSalesLine."HSN/SAC Code")
                        {
                        }
                        column(GSTAMountCaption; GSTAMountLbl)
                        {
                        }
                        column(VATDiscountAmount; -VATDiscountAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseDisc_SalesHeader; "Sales Header"."VAT Base Discount %")
                        {
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(VATAmtLineVATAmtText; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(TotalAmountInclVAT; TotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseAmount; VATBaseAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
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
                        column(LineDiscountAmountCaption; LineDiscountAmountCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(ExciseAmountCaption; ExciseAmountCaptionLbl)
                        {
                        }
                        column(TaxAmountCaption; TaxAmountCaptionLbl)
                        {
                        }
                        column(ServiceTaxAmountCaption; ServiceTaxAmountCaptionLbl)
                        {
                        }
                        column(ChargesAmountCaption; ChargesAmountCaptionLbl)
                        {
                        }
                        column(OtherTaxesAmountCaption; OtherTaxesAmountCaptionLbl)
                        {
                        }
                        column(ServTaxeCessAmtCaption; ServTaxeCessAmtCaptionLbl)
                        {
                        }
                        column(ServTaxSHECessAmtCaption; ServTaxSHECessAmtCaptionLbl)
                        {
                        }
                        column(PaymentDiscOnVATCaption; PaymentDiscOnVATCaptionLbl)
                        {
                        }
                        column(No_SalesLineCaption; "Sales Line".FieldCaption("No."))
                        {
                        }
                        column(Description_SalesLineCaption; "Sales Line".FieldCaption(Description))
                        {
                        }
                        column(Quantity_SalesLineCaption; "Sales Line".FieldCaption(Quantity))
                        {
                        }
                        column(UnitOfMeasure_SalesLineCaption; "Sales Line".FieldCaption("Unit of Measure"))
                        {
                        }
                        column(AllowInvDisc_SalesLineCaption; "Sales Line".FieldCaption("Allow Invoice Disc."))
                        {
                        }
                        column(ServTaxSBCAmtCaption; ServTaxSBCAmtCaptionLbl)
                        {
                        }
                        column(KKCessAmtCaption; KKCessAmtCaptionLbl)
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText_DimensionLoop2; DimText)
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
                                if not ShowIntInfo then
                                    CurrReport.Break();

                                DimSetEntry2.SetRange("Dimension Set ID", "Sales Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                TempSalesLine.Find('-')
                            else
                                TempSalesLine.Next();
                            "Sales Line" := TempSalesLine;

                            if not "Sales Header"."Prices Including VAT" and
                               (TempSalesLine."VAT Calculation Type" = TempSalesLine."VAT Calculation Type"::"Full VAT")
                            then
                                TempSalesLine."Line Amount" := 0;

                            if (TempSalesLine.Type = TempSalesLine.Type::"G/L Account") and (not ShowIntInfo) then
                                "Sales Line"."No." := '';
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
                        column(VATAmtLineInvDiscBaseAmt; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscountAmt; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVAT_VATCounter; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmtLineVATIdent_VATCounter; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATAmountSpecificationCaption; VATAmountSpecificationCaptionLbl)
                        {
                        }
                        column(LineAmountCaption; LineAmountCaptionLbl)
                        {
                        }
                        column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
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
                        column(VATAmountLineVAT_VATCounterLCY; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmtLineVATIdent_VATCounterLCY; TempVATAmountLine."VAT Identifier")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                            VALVATBaseLCY := TempVATAmountLine.GetBaseLCY(
                                "Sales Header"."Posting Date",
                                "Sales Header"."Currency Code",
                                "Sales Header"."Currency Factor");
                            VALVATAmountLCY := TempVATAmountLine.GetAmountLCY(
                                "Sales Header"."Posting Date",
                                "Sales Header"."Currency Code",
                                "Sales Header"."Currency Factor");
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

                            CurrExchRate.FindCurrency("Sales Header"."Order Date", "Sales Header"."Currency Code", 1);
                            VALExchRate := StrSubstNo(
                                ExchRateLbl,
                                CurrExchRate."Relational Exch. Rate Amount",
                                CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem(Total; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));
                    }
                    dataitem(Total2; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

                        column(SellToCustNo_SalesHeader; "Sales Header"."Sell-to Customer No.")
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
                        column(ShipToAddr7; ShipToAddr[7])
                        {
                        }
                        column(ShipToAddr8; ShipToAddr[8])
                        {
                        }
                        column(ShipToAddressCaption; ShipToAddressCaptionLbl)
                        {
                        }
                        column(SellToCustNo_SalesHeaderCaption; "Sales Header".FieldCaption("Sell-to Customer No."))
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
                    TaxTrnasactionValue: Record "Tax Transaction Value";
                    SalesLine1: Record "Sales Line";
                    TaxTrnasactionValue1: Record "Tax Transaction Value";
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
                    TotalAmountInclVAT := TempVATAmountLine.GetTotalAmountInclVAT();
                    if (TempSalesLine.Type <> TempSalesLine.Type::" ") then begin
                        SalesLine1.SetRange("Document No.", "Sales Header"."No.");
                        SalesLine1.SetRange("Document Type", "Sales Header"."Document Type");
                        if SalesLine1.FindSet() then
                            repeat
                                GSTCompNo := 1;
                                TaxTrnasactionValue.Reset();
                                TaxTrnasactionValue.SetRange("Tax Record ID", SalesLine1.RecordId);
                                TaxTrnasactionValue.SetRange("Tax Type", 'GST');
                                TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                                TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                                if TaxTrnasactionValue.FindSet() then
                                    repeat
                                        GSTCompNo := TaxTrnasactionValue."Value ID";
                                        GSTComponentCode[GSTCompNo] := TaxTrnasactionValue."Value ID";
                                        TaxTrnasactionValue1.Reset();
                                        TaxTrnasactionValue1.SetRange("Tax Record ID", SalesLine1.RecordId);
                                        TaxTrnasactionValue1.SetRange("Tax Type", 'GST');
                                        TaxTrnasactionValue1.SetRange("Value Type", TaxTrnasactionValue1."Value Type"::COMPONENT);
                                        TaxTrnasactionValue1.SetRange("Value ID", GSTComponentCode[GSTCompNo]);
                                        if TaxTrnasactionValue1.FindSet() then begin
                                            repeat
                                                GSTCompAmount[GSTCompNo] += TaxTrnasactionValue1."Amount";
                                                TotGSTAmt += TaxTrnasactionValue1.Amount;
                                            until TaxTrnasactionValue1.Next() = 0;
                                            GSTCompNo += 1;
                                        end;
                                    until TaxTrnasactionValue.Next() = 0;

                                TaxTrnasactionValue.Reset();
                                TaxTrnasactionValue.SetRange("Tax Record ID", SalesLine1.RecordId);
                                TaxTrnasactionValue.SetRange("Tax Type", 'GST');
                                TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                                TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                                if TaxTrnasactionValue.FindSet() then
                                    repeat
                                        j := TaxTrnasactionValue."Value ID";
                                        case TaxTrnasactionValue."Value ID" of
                                            6:
                                                GSTComponentCodeName[j] := 'SGST';
                                            2:
                                                GSTComponentCodeName[j] := 'CGST';
                                            3:
                                                GSTComponentCodeName[j] := 'IGST';
                                            5:
                                                GSTComponentCodeName[j] := 'UTGST';
                                        end;
                                        j += 1;
                                    until TaxTrnasactionValue.Next() = 0;
                            until SalesLine1.Next() = 0;
                    end;

                    if Number > 1 then begin
                        CopyText := CopyLbl;
                        OutputNo += 1;
                    end;

                    ChargesAmount := 0;
                    OtherTaxesAmount := 0;
                end;

                trigger OnPostDataItem()
                begin
                    if Print then
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
            var
                "Sell-to Country": Text[50];
            begin
                CurrReport.Language := Language.GetLanguageID("Language Code");
                CurrReport.FormatRegion := Language.GetFormatRegionOrDefault("Format Region");
                CompanyInfo.Get();

                IsGSTApplicable := CheckGSTDoc("Sales Line");
                Customer.Get("Bill-to Customer No.");
                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInfo);

                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

                if "Salesperson Code" = '' then begin
                    SalesPurchPerson.Init();
                    SalesPersonText := '';
                end else begin
                    SalesPurchPerson.Get("Salesperson Code");
                    SalesPersonText := SalesPersLbl;
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
                    TotalInclVATText := StrSubstNo(TotalIncTaxLbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(TotalExcTaxLbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(TotalLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(TotalIncTaxLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(TotalExcTaxLbl, "Currency Code");
                end;

                FormatAddr.SalesHeaderBillTo(CustAddr, "Sales Header");

                if "Payment Terms Code" = '' then
                    PaymentTerms.Init()
                else begin
                    PaymentTerms.Get("Payment Terms Code");
                    PaymentTerms.TranslateDescription(PaymentTerms, "Language Code");
                end;

                if "Shipment Method Code" = '' then
                    ShipmentMethod.Init()
                else begin
                    ShipmentMethod.Get("Shipment Method Code");
                    ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                end;

                if Country.Get("Sell-to Country/Region Code") then
                    "Sell-to Country" := Country.Name;

                ShowShippingAddr := "Sell-to Customer No." <> "Bill-to Customer No.";
                for i := 1 TO ArrayLen(ShipToAddr) do
                    if (ShipToAddr[i] <> CustAddr[i]) and (ShipToAddr[i] <> '') and (ShipToAddr[i] <> "Sell-to Country") then
                        ShowShippingAddr := true;

                if Print then begin
                    if ShowRequestPage and ArchiveDoc or
                       not ShowRequestPage and (SalesSetup."Archive Quotes" = SalesSetup."Archive Quotes"::Always)
                    then
                        ArchiveManagement.StoreSalesDocument("Sales Header", LogIntaction);

                    if LogIntaction then begin
                        CalcFields("No. of Archived Versions");
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              1, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", Database::Contact, "Bill-to Contact No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.")
                        else
                            SegManagement.LogDocument(
                              1, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", Database::Customer, "Bill-to Customer No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
                    end;
                end;

                Mark(true);
                Clear(GSTComponentCode);
                Clear(GSTCompAmount);
            end;

            trigger OnPostDataItem()
            begin
                MarkedOnly := true;
                Commit();
                CurrReport.LANGUAGE := ReportLanguage;
                if ReportFormatRegion <> '' then
                    CurrReport.FormatRegion := ReportFormatRegion;
            end;

            trigger OnPreDataItem()
            begin
                ReportLanguage := CurrReport.Language();
                ReportFormatRegion := CurrReport.FormatRegion();
                Print := Print or not CurrReport.Preview;
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
                    field(NoOfCopies; NoOfCopy)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of copies that need to be printed.';
                    }
                    field(ShowInternalInfo; ShowIntInfo)
                    {
                        Caption = 'Show Internal Information';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the line internal information';
                    }
                    field(ArchiveDocument; ArchiveDoc)
                    {
                        Caption = 'Archive Document';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether the document is archived or not.';

                        trigger OnValidate()
                        begin
                            if not ArchiveDoc then
                                LogIntaction := false;
                        end;
                    }
                    field(LogInteraction; LogIntaction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the log Interaction for archived document to be done or not.';

                        trigger OnValidate()
                        begin
                            if LogIntaction then
                                ArchiveDoc := ArchiveDocumentEnable;
                        end;
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
            ArchiveDocumentEnable := false;
            if (SalesSetup."Archive Quotes" = SalesSetup."Archive Quotes"::Always) then
                ArchiveDoc := true
            else
                ArchiveDoc := false;
            LogIntaction := SegManagement.FindInteractionTemplateCode(1) <> '';
            LogInteractionEnable := LogIntaction;
            ShowRequestPage := true;
        end;
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
    end;

    var
        GLSetup: Record "General Ledger Setup";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        CompanyInfo: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        Country: Record "Country/Region";
        CurrExchRate: Record "Currency Exchange Rate";
        SalesCountPrinted: Codeunit "Sales-Printed";
        Language: Codeunit Language;
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        ArchiveManagement: Codeunit ArchiveManagement;
        GSTComponentCodeName: array[10] of Code[20];
        GSTCompAmount: array[20] of Decimal;
        GSTComponentCode: array[20] of Integer;
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
        ShowIntInfo: Boolean;
        Continue: Boolean;
        ArchiveDoc: Boolean;
        LogIntaction: Boolean;
        VATAmount: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        OutputNo: Integer;
        Print: Boolean;
        ChargesAmount: Decimal;
        OtherTaxesAmount: Decimal;
        TotGSTAmt: Decimal;
        [InDataSet]
        ArchiveDocumentEnable: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        ShowRequestPage: Boolean;
        IsGSTApplicable: Boolean;
        GSTCompNo: Integer;
        j: Integer;
        ReportFormatRegion: Text[80];
        ReportLanguage: Integer;
        VatAmtLbl: Label 'VAT Amount Specification in ';
        LocalCurrLbl: Label 'Local Currency';
        SalesPersLbl: Label 'Salesperson';
        TotalLbl: Label 'Total %1', Comment = '%1 Amt';
        CopyLbl: Label ' COPY';
        SalesQuoteLbl: Label 'Sales - Quote %1', Comment = '%1 = CopyText';
        PageLbl: Label 'Page %1', Comment = '%1 No.';
        ExchRateLbl: Label 'Exchange rate: %1/%2', Comment = '%1 Relational Exch Rate %2 Exchange Rate Amt';
        TotalIncTaxLbl: Label 'Total %1 Incl. Taxes', Comment = '%1 Amt';
        TotalExcTaxLbl: Label 'Total %1 Excl. Taxes', Comment = '%1 Amt';
        PhoneNoCaptionLbl: Label 'Phone No.';
        HomePageCaptionLbl: Label 'Home Page';
        VATRegNoCaptionLbl: Label 'VAT Registration No.';
        GiroNoCaptionLbl: Label 'Giro No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccountNoCaptionLbl: Label 'Account No.';
        ShipmentDateCaptionLbl: Label 'Shipment Date';
        QuoteNoCaptionLbl: Label 'Quote No.';
        EMailCaption1Lbl: Label 'E-Mail';
        PaymentTermsCaptionLbl: Label 'Payment Terms';
        ShipmentMethodCaptionLbl: Label 'Shipment Method';
        DocumentDateCaptionLbl: Label 'Document Date';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        UnitPriceCaptionLbl: Label 'Unit Price';
        DiscountCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        LineDiscountAmountCaptionLbl: Label 'Line Discount Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        ExciseAmountCaptionLbl: Label 'Excise Amount';
        TaxAmountCaptionLbl: Label 'Tax Amount';
        ServiceTaxAmountCaptionLbl: Label 'Service Tax Amount';
        ChargesAmountCaptionLbl: Label 'Charges Amount';
        OtherTaxesAmountCaptionLbl: Label 'Other Taxes Amount';
        ServTaxeCessAmtCaptionLbl: Label 'Service Tax eCess Amount';
        ServTaxSHECessAmtCaptionLbl: Label 'Service Tax SHECess Amount';
        PaymentDiscOnVATCaptionLbl: Label 'Payment Discount on VAT';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATAmountSpecificationCaptionLbl: Label 'VAT Amount Specification';
        LineAmountCaptionLbl: Label 'Line Amount';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        ShipToAddressCaptionLbl: Label 'Ship-to Address';
        InvDiscountAmountCaptionLbl: Label 'Invoice Discount Amount';
        VATCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmountCaptionLbl: Label 'VAT Amount';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        TotalCaptionLbl: Label 'Total';
        ServTaxSBCAmtCaptionLbl: Label 'SBC Amount';
        KKCessAmtCaptionLbl: Label 'KKC Amount';
        CompanyRegistrationLbl: Label 'Company Registration No.';
        HSNSACLbl: Label 'HSN/SAC Code';
        CustomerRegistrationLbl: Label 'Customer GST Reg No.';
        GSTAMountLbl: Label 'GST Amount';

    [Scope('OnPrem')]
    procedure InitializeRequest(
        NoOfCopiesFrom: Integer;
        ShowInternalInfoFrom: Boolean;
        ArchiveDocumentFrom: Boolean;
        LogInteractionFrom: Boolean;
        PrintFrom: Boolean)
    begin
        NoOfCopy := NoOfCopiesFrom;
        ShowIntInfo := ShowInternalInfoFrom;
        ArchiveDoc := ArchiveDocumentFrom;
        LogIntaction := LogInteractionFrom;
        Print := PrintFrom;
    end;

    local procedure CheckGSTDoc(SalesLine: Record "Sales Line"): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
        TaxTransactionValue.SetRange("Tax Type", 'GST');
        if not TaxTransactionValue.IsEmpty then
            exit(true);
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
}
