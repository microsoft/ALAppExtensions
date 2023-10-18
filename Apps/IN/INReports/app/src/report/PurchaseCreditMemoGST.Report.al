// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Setup;
using System.Utilities;

report 18010 "Purchase - Credit Memo GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/PurchaseCreditMemo.rdl';
    Caption = 'Purchase - Credit Memo';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Purch. Cr. Memo Hdr."; "Purch. Cr. Memo Hdr.")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Posted Purchase Cr. Memo';

            column(No_PurchCrMemoHeader; "No.")
            {
            }
            column(InvDiscountAmtCaption; InvDiscountAmtCaptionLbl)
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfoPicture; CompanyInfo3.Picture)
                    {
                    }
                    column(DocCaptionCopyText; DocCaption)
                    {
                    }
                    column(CompanyRegistrationLbl; CompanyRegistrationLbl)
                    {
                    }
                    column(CompanyInfo_GST_RegistrationNo; CompanyInfo."GST Registration No.")
                    {
                    }
                    column(VendorRegistrationLbl; VendorRegistrationLbl)
                    {
                    }
                    column(Vendor_GST_RegistrationNo; Vendor."GST Registration No.")
                    {
                    }
                    column(VendAddr1; VendAddr[1])
                    {
                    }
                    column(CompanyAddr1; CompanyAddr[1])
                    {
                    }
                    column(VendAddr2; VendAddr[2])
                    {
                    }
                    column(CompanyAddr2; CompanyAddr[2])
                    {
                    }
                    column(VendAddr3; VendAddr[3])
                    {
                    }
                    column(CompanyAddr3; CompanyAddr[3])
                    {
                    }
                    column(VendAddr4; VendAddr[4])
                    {
                    }
                    column(CompanyAddr4; CompanyAddr[4])
                    {
                    }
                    column(VendAddr5; VendAddr[5])
                    {
                    }
                    column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
                    {
                    }
                    column(VendAddr6; VendAddr[6])
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
                    column(PaytoVendNo_PurchCrMemoHeader; "Purch. Cr. Memo Hdr."."Pay-to Vendor No.")
                    {
                    }
                    column(DocDt_PurchCrMemoHeader; Format("Purch. Cr. Memo Hdr."."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_PurchCrMemoHeader; "Purch. Cr. Memo Hdr."."VAT Registration No.")
                    {
                    }
                    column(PurchaserText; PurchaserText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(AppliedToText; AppliedToText)
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourRef_PurchCrMemoHeader; "Purch. Cr. Memo Hdr."."Your Reference")
                    {
                    }
                    column(VendAddr7; VendAddr[7])
                    {
                    }
                    column(VendAddr8; VendAddr[8])
                    {
                    }
                    column(CompanyAddr5; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr6; CompanyAddr[6])
                    {
                    }
                    column(PostDt_PurchCrMemoHeader; Format("Purch. Cr. Memo Hdr."."Posting Date"))
                    {
                    }
                    column(PricIncVAT_PurchCrMemoHeader; "Purch. Cr. Memo Hdr."."Prices Including VAT")
                    {
                    }
                    column(RetOrderNo_PurchCrMemoHeader; "Purch. Cr. Memo Hdr."."Return Order No.")
                    {
                    }
                    column(ReturnOrderNoText; ReturnOrderNoText)
                    {
                    }
                    column(SupplementaryText; SupplementaryText)
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PricIncVAT1_PurchCrMemoHeader; Format("Purch. Cr. Memo Hdr."."Prices Including VAT"))
                    {
                    }
                    column(PhoneNoCaption; PhoneNoCaptionLbl)
                    {
                    }
                    column(HomePageCaption; HomePageCaptionLbl)
                    {
                    }
                    column(EMailCaption; EMailCaptionLbl)
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
                    column(CreditMemoNoCaption; CreditMemoNoCaptionLbl)
                    {
                    }
                    column(PostingDateCaption; PostingDateCaptionLbl)
                    {
                    }
                    column(DocumentDateCaption; DocumentDateCaptionLbl)
                    {
                    }
                    column(PaytoVendNo_PurchCrMemoHeaderCaption; "Purch. Cr. Memo Hdr.".FieldCaption("Pay-to Vendor No."))
                    {
                    }
                    column(PricIncVAT_PurchCrMemoHeaderCaption; "Purch. Cr. Memo Hdr.".FieldCaption("Prices Including VAT"))
                    {
                    }
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Purch. Cr. Memo Hdr.";
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
                            if not ShowInternalInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Purch. Cr. Memo Line"; "Purch. Cr. Memo Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Purch. Cr. Memo Hdr.";
                        DataItemTableView = sorting("Document No.", "Line No.");

                        column(GSTComponentCode1; GSTComponentCodeName[1] + ' Amount')
                        {
                        }
                        column(GSTComponentCode2; GSTComponentCodeName[2] + ' Amount')
                        {
                        }
                        column(GSTComponentCode3; GSTComponentCodeName[3] + ' Amount')
                        {
                        }
                        column(GSTComponentCode4; GSTComponentCodeName[4] + 'Amount')
                        {
                        }
                        column(GSTCompAmount1; ABS(GSTCompAmount[1]))
                        {
                        }
                        column(GSTCompAmount2; ABS(GSTCompAmount[2]))
                        {
                        }
                        column(GSTCompAmount3; ABS(GSTCompAmount[3]))
                        {
                        }
                        column(GSTCompAmount4; ABS(GSTCompAmount[4]))
                        {
                        }
                        column(IsGSTApplicable; IsGSTApplicable)
                        {
                        }
                        column(LogInteraction_; LogInteraction)
                        {
                        }
                        column(AllowInvDisc; AllowInvDiscount)
                        {
                        }
                        column(PricIncVAT; PricesIncludingVAT)
                        {
                        }
                        column(Type_PurchCrMemoLine; Format("Purch. Cr. Memo Line".Type, 0, 2))
                        {
                        }
                        column(VATBasDisc_PurchCrMemoHeader; "Purch. Cr. Memo Hdr."."VAT Base Discount %")
                        {
                        }
                        column(VATAmtText; VATAmountText)
                        {
                        }
                        column(LineAmt_PurchCrMemoLine; "Line Amount")
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(Desc_PurchCrMemoLine; Description)
                        {
                        }
                        column(No_PurchCrMemoLine; "No.")
                        {
                        }
                        column(Qty_PurchCrMemoLine; Quantity)
                        {
                        }
                        column(UOM_PurchCrMemoLine; "Unit of Measure")
                        {
                        }
                        column(DirectUnitCost_PurchCrMemoLine; "Direct Unit Cost")
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 2;
                        }
                        column(LineDisc_PurchCrMemoLine; "Line Discount %")
                        {
                        }
                        column(AllowInvDisc_PurchCrMemoLine; "Allow Invoice Disc.")
                        {
                            IncludeCaption = false;
                        }
                        column(LineDiscAmt_PurchCrMemoLine; "Line Discount Amount")
                        {
                        }
                        column(SrcDocType_PurchCrMemoLine; 'Ref: ' + Format("Source Document Type", 0))
                        {
                        }
                        column(SrcDocNo_PurchCrMemoLine; "Source Document No.")
                        {
                        }
                        column(Supp_PurchCrMemoLine; Supplementary)
                        {
                        }
                        column(InvDiscAmt_PurchCrMemoLine; -"Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(Amt_PurchCrMemoLine; Amount)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(ExciseAmt_PurchCrMemoLine; 0)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TaxAmt_PurchCrMemoLine; 0)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(ServTaxAmt_PurchCrMemoLine; 0)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(OtherTaxesAmt; OtherTaxesAmount)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(ChargesAmt; ChargesAmount)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(ServTaxeCessAmt_PurchCrMemoLine; 0)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(ServTaxSHECessAmt_PurchCrMemoLine; 0)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(ServTaxSBCAmt_PurchCrMemoLine; 0)
                        {
                        }
                        column(KKCessAmt_PurchCrMemoLine; 0)
                        {
                        }
                        column(AmtToVend_PurchCrMemoLine; 0)
                        {
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(AmtIncVATAmt; "Amount Including VAT" - Amount)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmtIncVAT_PurchCrMemoLine; "Amount Including VAT")
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(LineNo_PurchCrMemoLine; "Line No.")
                        {
                        }
                        column(TotalSubTotal; TotalSubTotal)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInvDiscAmt; TotalInvoiceDiscountAmount)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmt; TotalAmount)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmtInclVAT; TotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Purch. Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalPaymentDiscOnVAT; TotalPaymentDiscountOnVAT)
                        {
                            AutoFormatType = 1;
                        }
                        column(DirectUnitCostCaption; DirectUnitCostCaptionLbl)
                        {
                        }
                        column(DiscountPercentageCaption; DiscountPercentageCaptionLbl)
                        {
                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {
                        }
                        column(ContinuedCaption; ContinuedCaptionLbl)
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
                        column(OtherTaxesAmtCaption; OtherTaxesAmtCaptionLbl)
                        {
                        }
                        column(ChargesAmountCaption; ChargesAmountCaptionLbl)
                        {
                        }
                        column(PaymentDisconVATCaption; PaymentDisconVATCaptionLbl)
                        {
                        }
                        column(AllowInvDiscCaption; AllowInvDiscCaptionLbl)
                        {
                        }
                        column(Desc_PurchCrMemoLineCaption; FieldCaption(Description))
                        {
                        }
                        column(No_PurchCrMemoLineCaption; FieldCaption("No."))
                        {
                        }
                        column(Qty_PurchCrMemoLineCaption; FieldCaption(Quantity))
                        {
                        }
                        column(UOM_PurchCrMemoLineCaption; FieldCaption("Unit of Measure"))
                        {
                        }
                        column(LineDiscAmt_PurchCrMemoLineCaption; FieldCaption("Line Discount Amount"))
                        {
                        }
                        column(CGSTAmt; CGSTAmt)
                        {
                        }
                        column(SGSTAmt; SGSTAmt)
                        {
                        }
                        column(IGSTAmt; IGSTAmt)
                        {
                        }
                        column(CessAmt; CessAmt)
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText1; DimText)
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
                                if not ShowInternalInfo then
                                    CurrReport.Break();

                                DimSetEntry2.SetRange("Dimension Set ID", "Purch. Cr. Memo Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if (Type = Type::"G/L Account") and (not ShowInternalInfo) then
                                "No." := '';

                            VATAmountLine.Init();
                            VATAmountLine."VAT Identifier" := "Purch. Cr. Memo Line"."VAT Identifier";
                            VATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                            VATAmountLine."Tax Group Code" := "Tax Group Code";
                            VATAmountLine."Use Tax" := "Use Tax";
                            VATAmountLine."VAT %" := "VAT %";
                            VATAmountLine."VAT Base" := Amount;
                            VATAmountLine."Amount Including VAT" := "Amount Including VAT";
                            VATAmountLine."Line Amount" := "Line Amount";
                            if "Allow Invoice Disc." then
                                VATAmountLine."Inv. Disc. Base Amount" := "Line Amount";
                            VATAmountLine."Invoice Discount Amount" := "Inv. Discount Amount";
                            VATAmountLine.InsertLine();

                            AllowInvDiscount := Format("Purch. Cr. Memo Line"."Allow Invoice Disc.");

                            GetGSTAmount("Purch. Cr. Memo Hdr.", "Purch. Cr. Memo Line");

                            TotalSubTotal += "Line Amount";
                            TotalInvoiceDiscountAmount -= "Inv. Discount Amount";
                            TotalAmount += Amount;
                            TotalAmountInclVAT += "Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CessAmt;
                            TotalPaymentDiscountOnVAT += -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT");
                        end;

                        trigger OnPreDataItem()
                        var
                            PurchCrMemoLine: Record "Purch. Cr. Memo Line";
                            VATIdentifier: Code[20];
                        begin
                            VATAmountLine.DeleteAll();
                            MoreLines := Find('+');
                            while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0) and (Amount = 0) do
                                MoreLines := Next(-1) <> 0;

                            if not MoreLines then
                                CurrReport.Break();

                            SetRange("Line No.", 0, "Line No.");
                            PurchCrMemoLine.SetRange("Document No.", "Purch. Cr. Memo Hdr."."No.");
                            PurchCrMemoLine.SetFilter(Type, '<>%1', 0);
                            VATAmountText := '';
                            if PurchCrMemoLine.Find('-') then begin
                                VATAmountText := StrSubstNo(VatPerLbl, PurchCrMemoLine."VAT %");
                                VATIdentifier := PurchCrMemoLine."VAT Identifier";
                                repeat
                                    if (PurchCrMemoLine."VAT Identifier" <> VATIdentifier) and (PurchCrMemoLine.Quantity <> 0) then
                                        VATAmountText := VatAmtLbl;
                                until PurchCrMemoLine.Next() = 0;
                            end;

                            AllowInvDiscount := Format("Purch. Cr. Memo Line"."Allow Invoice Disc.");
                        end;
                    }
                    dataitem(VATCounter; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(VATAmtLineVATBase; VATAmountLine."VAT Base")
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmt; VATAmountLine."VAT Amount")
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineLineAmt; VATAmountLine."Line Amount")
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscBaseAmt; VATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscAmt; VATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVAT; VATAmountLine."VAT %")
                        {
                        }
                        column(VATAmtLineVATIdentifier; VATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATPercentageCaption; VATPercentageCaptionLbl)
                        {
                        }
                        column(VATBaseCaption; VATBaseCaptionLbl)
                        {
                        }
                        column(VATAmountCaption; VATAmountCaptionLbl)
                        {
                        }
                        column(VATAmtSpecificationCaption; VATAmtSpecificationCaptionLbl)
                        {
                        }
                        column(VATIdentifierCaption; VATIdentifierCaptionLbl)
                        {
                        }
                        column(LineAmountCaption; LineAmountCaptionLbl)
                        {
                        }
                        column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number, 1, VATAmountLine.Count);
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
                        column(VALVATAmtLCY; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVAT1; VATAmountLine."VAT %")
                        {
                        }
                        column(VATAmtLineVATIdentifier1; VATAmountLine."VAT Identifier")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                            VALVATBaseLCY := VATAmountLine.GetBaseLCY(
                                "Purch. Cr. Memo Hdr."."Posting Date",
                                "Purch. Cr. Memo Hdr."."Currency Code",
                                "Purch. Cr. Memo Hdr."."Currency Factor");
                            VALVATAmountLCY := VATAmountLine.GetAmountLCY(
                                "Purch. Cr. Memo Hdr."."Posting Date",
                                "Purch. Cr. Memo Hdr."."Currency Code",
                                "Purch. Cr. Memo Hdr."."Currency Factor");
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GLSetup."Print VAT specification in LCY") or
                               ("Purch. Cr. Memo Hdr."."Currency Code" = '')
                            then
                                CurrReport.Break();

                            SetRange(Number, 1, VATAmountLine.Count);

                            if GLSetup."LCY Code" = '' then
                                VALSpecLCYHeader := VatAmtSpecinLbl + LocalCurrLbl
                            else
                                VALSpecLCYHeader := VatAmtSpecinLbl + Format(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency("Purch. Cr. Memo Hdr."."Posting Date", "Purch. Cr. Memo Hdr."."Currency Code", 1);
                            CalculatedExchRate := Round(1 / "Purch. Cr. Memo Hdr."."Currency Factor" * CurrExchRate."Exchange Rate Amount", 0.000001);
                            VALExchRate := StrSubstNo(ExchanLbl, CalculatedExchRate, CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem(Total; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

                        column(BuyfrVendNo_PurchCrMemoHeader; "Purch. Cr. Memo Hdr."."Buy-from Vendor No.")
                        {
                        }
                        column(BuyfrVendNo_PurchCrMemoHeaderCaption; "Purch. Cr. Memo Hdr.".FieldCaption("Buy-from Vendor No."))
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if "Purch. Cr. Memo Hdr."."Buy-from Vendor No." = "Purch. Cr. Memo Hdr."."Pay-to Vendor No." then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(Total2; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

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
                        column(ShiptoAddressCaption; ShiptoAddressCaptionLbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if ShipToAddr[1] = '' then
                                CurrReport.Break();
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then begin
                        CopyText := CopYLbl;

                        OutputNo += 1;
                    end;

                    TotalSubTotal := 0;
                    TotalInvoiceDiscountAmount := 0;
                    TotalAmount := 0;
                    TotalAmountInclVAT := 0;
                    TotalPaymentDiscountOnVAT := 0;
                    ChargesAmount := 0;
                    OtherTaxesAmount := 0;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.PREVIEW then
                        PurchCrMemoCountPrinted.Run("Purch. Cr. Memo Hdr.");
                end;

                trigger OnPreDataItem()
                begin
                    OutputNo := 1;

                    NoOfLoops := Abs(NoOfCopy) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                end;
            }

            trigger OnAfterGetRecord()
            var
                PurchCrMemoLine: Record "Purch. Cr. Memo Line";
            begin
                CompanyInfo.Get();
                IsGSTApplicable := CheckGSTDoc("Purch. Cr. Memo Line");
                Vendor.Get("Buy-from Vendor No.");
                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInfo);

                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

                if "Return Order No." = '' then
                    ReturnOrderNoText := ''
                else
                    ReturnOrderNoText := FieldCaption("Return Order No.");

                if "Purchaser Code" = '' then begin
                    SalesPurchPerson.Init();
                    PurchaserText := '';
                end else begin
                    SalesPurchPerson.Get("Purchaser Code");
                    PurchaserText := PurchLbl
                end;

                if "Your Reference" = '' then
                    ReferenceText := ''
                else
                    ReferenceText := FieldCaption("Your Reference");

                if "VAT Registration No." = '' then
                    VATNoText := ''
                else
                    VATNoText := FieldCaption("VAT Registration No.");

                if "Currency Code" = '' then begin
                    GLSetup.TestField("LCY Code");
                    TotalText := StrSubstNo(TotalLbl, GLSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(TotalIncTaxLbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(TotalExclTaxLbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(TotalLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(TotalIncTaxLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(TotalExclTaxLbl, "Currency Code");
                end;

                FormatAddr.PurchCrMemoPayTo(VendAddr, "Purch. Cr. Memo Hdr.");
                if "Applies-to Doc. No." = '' then
                    AppliedToText := ''
                else
                    AppliedToText := Format(StrSubstNo(AppliesToLbl, Format("Applies-to Doc. Type"), "Applies-to Doc. No."));

                FormatAddr.PurchCrMemoShipTo(ShipToAddr, "Purch. Cr. Memo Hdr.");

                if LogInteraction then
                    if not CurrReport.Preview then
                        SegManagement.LogDocument(
                            16,
                            "No.",
                            0,
                            0,
                            DATABASE::Vendor,
                            "Buy-from Vendor No.",
                            "Purchaser Code",
                            '',
                            "Posting Description",
                            '');

                SupplementaryText := '';
                PurchCrMemoLine.SetRange("Document No.", "No.");
                PurchCrMemoLine.SetRange(Supplementary, true);
                if not PurchCrMemoLine.IsEmpty() then
                    SupplementaryText := SupplementCredLbl;

                PricesIncludingVAT := Format("Prices Including VAT");
            end;

            trigger OnPreDataItem()
            begin
                DocumentCaption();
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
                    field(NoOfCopy_; NoOfCopy)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = Basic, Suite;
                        Tooltip = 'Specifies the number of copies that need to be printed.';
                    }
                    field(ShowInternalInfo_; ShowInternalInfo)
                    {
                        Caption = 'Show Internal Information';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the Line Internal Information';
                    }
                    field(LogInteraction_; LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the log Interaction for archived document to be done or not';
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
            LogInteraction := SegManagement.FindInteractionTemplateCode(16) <> '';
            LogInteractionEnable := LogInteraction;
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
                CompanyInfo.CalcFields(Picture);
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

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        CompanyInfo: Record "Company Information";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        VATAmountLine: Record "VAT Amount Line";
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        CurrExchRate: Record "Currency Exchange Rate";
        Vendor: Record Vendor;
        PurchCrMemoCountPrinted: Codeunit "PurchCrMemo-Printed";
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        GSTCompAmount: array[20] of Decimal;
        GSTComponentCodeName: array[20] of Code[10];
        VendAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        ReturnOrderNoText: Text;
        PurchaserText: Text[30];
        VATNoText: Text;
        ReferenceText: Text;
        AppliedToText: Text;
        DocCaption: Text;
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        AllowInvDiscount: Text[30];
        PricesIncludingVAT: Text[30];
        VATAmountText: Text[30];
        MoreLines: Boolean;
        NoOfCopy: Integer;
        NoOfLoops: Integer;
        OutputNo: Integer;
        CopyText: Text;
        DimText: Text;
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        LogInteraction: Boolean;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text;
        VALExchRate: Text[50];
        CalculatedExchRate: Decimal;
        OtherTaxesAmount: Decimal;
        ChargesAmount: Decimal;
        SupplementaryText: Text[30];
        [InDataSet]
        LogInteractionEnable: Boolean;
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalInvoiceDiscountAmount: Decimal;
        TotalPaymentDiscountOnVAT: Decimal;
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        CessAmt: Decimal;
        IsGSTApplicable: Boolean;
        PurchLbl: Label 'Purchase %1', Comment = '%1 = GLSetup."LCY Code"';
        TotalLbl: Label 'Total Amount %1', Comment = '%1= GLSetup LCY Code';
        AppliesToLbl: Label '(Applies to %1 %2)', Comment = '%1 = docNo %2 = DocType';
        CopYLbl: Label 'COPY';
        PurchCredLbl: Label 'Purchase - Credit Memo%1', Comment = '%1 Document No.';
        VatAmtSpecinLbl: Label 'VAT Amount Specification in ';
        LocalCurrLbl: Label 'Local Currency';
        ExchanLbl: Label 'Exchange rate: %1/%2', Comment = '%1 =  CalculatedExchRate, %2 = CurrExchRate."Exchange Rate Amount")';
        PurchPrepmLbl: Label 'Purchase - Prepmt. Credit Memo %1', Comment = '%1 = Credit Memo';
        VatPerLbl: Label '%1% VAT', Comment = '%1 = Vat %';
        VatAmtLbl: Label 'VAT Amount';
        TotalIncTaxLbl: Label 'Total %1 Incl. Taxes', Comment = '%1 = Amt';
        TotalExclTaxLbl: Label 'Total %1 Excl. Taxes', Comment = '%1 = Amt';
        SupplementCredLbl: Label 'Supplementary Credit Memo';
        PhoneNoCaptionLbl: Label 'Phone No.';
        HomePageCaptionLbl: Label 'Home Page';
        EMailCaptionLbl: Label 'E-Mail';
        VATRegNoCaptionLbl: Label 'VAT Reg. No.';
        GiroNoCaptionLbl: Label 'Giro No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccNoCaptionLbl: Label 'Account No.';
        CreditMemoNoCaptionLbl: Label 'Credit Memo No.';
        PostingDateCaptionLbl: Label 'Posting Date';
        DocumentDateCaptionLbl: Label 'Document Date';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        DirectUnitCostCaptionLbl: Label 'Direct Unit Cost';
        DiscountPercentageCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        ContinuedCaptionLbl: Label 'Continued';
        SubtotalCaptionLbl: Label 'Subtotal';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        CessLbl: Label 'CESS';
        ExciseAmountCaptionLbl: Label 'Excise Amount';
        TaxAmountCaptionLbl: Label 'Tax Amount';
        OtherTaxesAmtCaptionLbl: Label 'Other Taxes Amount';
        ChargesAmountCaptionLbl: Label 'Charges Amount';
        PaymentDisconVATCaptionLbl: Label 'Payment Discount on VAT';
        AllowInvDiscCaptionLbl: Label 'Allow Invoice Discount';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATPercentageCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmountCaptionLbl: Label 'VAT Amount';
        VATAmtSpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        LineAmountCaptionLbl: Label 'Line Amount';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        TotalCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        InvDiscountAmtCaptionLbl: Label 'Invoice Discount Amount';
        CompanyRegistrationLbl: Label 'Company Registration No.';
        VendorRegistrationLbl: Label 'Vendor GST Reg No.';

    procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(16) <> '';
    end;

    procedure InitializeRequest(NewNoOfCopies: Integer; NewShowInternalInfo: Boolean; NewLogInteraction: Boolean)
    begin
        NoOfCopy := NewNoOfCopies;
        ShowInternalInfo := NewShowInternalInfo;
        LogInteraction := NewLogInteraction;
    end;

    local procedure DocumentCaption(): Text[250]
    begin
        if "Purch. Cr. Memo Hdr."."Prepayment Credit Memo" then
            DocCaption := StrSubstNo(PurchPrepmLbl, CopyText)
        else
            DocCaption := StrSubstNo(PurchCredLbl, CopyText);
    end;

    local procedure CheckGSTDoc(PurchCrLine: Record "Purch. Cr. Memo Line"): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", PurchCrLine.RecordId);
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

    local procedure GetGSTAmount(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        Clear(IGSTAmt);
        Clear(CGSTAmt);
        Clear(SGSTAmt);
        Clear(CessAmt);
        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetRange("Document No.", PurchCrMemoLine."Document No.");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if (DetailedGSTLedgerEntry."GST Component Code" = CGSTLbl) And (PurchCrMemoHdr."Currency Code" <> '') then
                    CGSTAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * PurchCrMemoHdr."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = CGSTLbl) then
                        CGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                if (DetailedGSTLedgerEntry."GST Component Code" = SGSTLbl) And (PurchCrMemoHdr."Currency Code" <> '') then
                    SGSTAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * PurchCrMemoHdr."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = SGSTLbl) then
                        SGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                if (DetailedGSTLedgerEntry."GST Component Code" = IGSTLbl) And (PurchCrMemoHdr."Currency Code" <> '') then
                    IGSTAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * PurchCrMemoHdr."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = IGSTLbl) then
                        IGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                if (DetailedGSTLedgerEntry."GST Component Code" = CessLbl) And (PurchCrMemoHdr."Currency Code" <> '') then
                    CessAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * PurchCrMemoHdr."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = CessLbl) then
                        CessAmt += Abs(DetailedGSTLedgerEntry."GST Amount");
            until DetailedGSTLedgerEntry.Next() = 0;
    end;
}
