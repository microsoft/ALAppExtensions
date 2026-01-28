// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.WithholdingTax;

using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.WithholdingTax;
using System.Globalization;
using System.Utilities;

report 6789 "WHT Purch. - Tax Cr. Memo"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'src\Purchase\Report\WHTPurchTaxCrMemo.rdlc';
    Caption = 'Purch. - Tax Cr. Memo';

    dataset
    {
        dataitem("Purch. Tax Cr. Memo Hdr."; "WHT Purch. Tax Cr. Memo Hdr.")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Posted Purchase Tax Credit Memo';
            column(No_PurchTaxCrMemoHdr; "No.")
            {
            }
            column(DocumentDateCaption; DocumentDateCaptionLbl)
            {
            }
            column(EMailCaption; EMailCaptionLbl)
            {
            }
            column(HomePageCaption; HomePageCaptionLbl)
            {
            }
            column(AllowInvoiceDiscCaption; AllowInvoiceDiscCaptionLbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(CopyText; StrSubstNo(PurchaseTaxCreditMemoLbl, CopyText))
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
                    column(CompanyInfoHomepage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoEmail; CompanyInfo."E-Mail")
                    {
                    }
                    column(VendAddr6; VendAddr[6])
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
                    column(CompanyInfoBankAccNo; CompanyInfo."Bank Account No.")
                    {
                    }
                    column(PaytoVendNo_PurchTaxCrMemoHdr; "Purch. Tax Cr. Memo Hdr."."Pay-to Vendor No.")
                    {
                    }
                    column(BuyfromVendNo_PurchTaxCrMemoHdr; "Purch. Tax Cr. Memo Hdr."."Buy-from Vendor No.")
                    {
                    }
                    column(FormatedDocumentDate; Format("Purch. Tax Cr. Memo Hdr."."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_PurchTaxCrMemoHdr; "Purch. Tax Cr. Memo Hdr."."VAT Registration No.")
                    {
                    }
                    column(No_CopyLoop; "Purch. Tax Cr. Memo Hdr."."No.")
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
                    column(YourRef_PurchTaxCrMemoHdr; "Purch. Tax Cr. Memo Hdr."."Your Reference")
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
                    column(FormatedPostingDate; Format("Purch. Tax Cr. Memo Hdr."."Posting Date"))
                    {
                    }
                    column(PricesIncluVAT_PurchTaxCrMemoHdr; "Purch. Tax Cr. Memo Hdr."."Prices Including VAT")
                    {
                    }
                    column(ReturnOrderNo_PurchTaxCrMemoHdr; "Purch. Tax Cr. Memo Hdr."."Return Order No.")
                    {
                    }
                    column(ReturnOrderNoText; ReturnOrderNoText)
                    {
                    }
                    column(NoOfLoops; OutputNO)
                    {
                    }
                    column(CompanyInfoPhoneNoCaption; CompanyInfoPhoneNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoVATRegNoCaption; CompanyInfoVATRegNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoGiroNoCaption; CompanyInfoGiroNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoBankNameCaption; CompanyInfoBankNameCaptionLbl)
                    {
                    }
                    column(CompanyInfoBankAccNoCaption; CompanyInfoBankAccNoCaptionLbl)
                    {
                    }
                    column(PurchTaxCrMemoHdrNoCaption; PurchTaxCrMemoHdrNoCaptionLbl)
                    {
                    }
                    column(PurchTaxCrMemoHdrPostingDateCaption; PurchTaxCrMemoHdrPostingDateCaptionLbl)
                    {
                    }
                    column(PaytoVendNo_PurchTaxCrMemoHdrCaption; "Purch. Tax Cr. Memo Hdr.".FieldCaption("Pay-to Vendor No."))
                    {
                    }
                    column(BuyfromVendNo_PurchTaxCrMemoHdrCaption; "Purch. Tax Cr. Memo Hdr.".FieldCaption("Buy-from Vendor No."))
                    {
                    }
                    column(PricesIncluVAT_PurchTaxCrMemoHdrCaption; "Purch. Tax Cr. Memo Hdr.".FieldCaption("Prices Including VAT"))
                    {
                    }
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Purch. Tax Cr. Memo Hdr.";
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(Number_DimensionLoop1; Number)
                        {
                        }
                        column(HeaderDimensionsCaption; HeaderDimensionsCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not DimSetEntry1.FindFirst() then
                                    CurrReport.Break();
                            end else
                                if not Continue then
                                    CurrReport.Break();

                            Clear(DimText);
                            Continue := false;
                            repeat
                                OldDimText := DimText;
                                if DimText = '' then
                                    DimText := StrSubstNo(
                                        '%1 %2', DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code")
                                else
                                    DimText :=
                                      StrSubstNo(
                                        '%1, %2 %3', DimText,
                                        DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code");
                                if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                    DimText := OldDimText;
                                    Continue := true;
                                    exit;
                                end;
                            until (DimSetEntry1.Next() = 0);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowInternalInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Purch. Tax Cr. Memo Line"; "WHT Purch. Tax Cr. Memo Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Purch. Tax Cr. Memo Hdr.";
                        DataItemTableView = sorting("Document No.", "Line No.");
                        column(LineAmt_PurchTaxCrMemoLine; "Line Amount")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(Desc_PurchTaxCrMemoLine; Description)
                        {
                        }
                        column(Desc_PurchTaxCrMemoLineCaption; FieldCaption(Description))
                        {
                        }
                        column(TypeNO; TypeNO)
                        {
                        }
                        column(No_PurchTaxCrMemoLine; "No.")
                        {
                        }
                        column(No_PurchTaxCrMemoLineCaption; FieldCaption("No."))
                        {
                        }
                        column(Quantity_PurchTaxCrMemoLine; Quantity)
                        {
                        }
                        column(QuantityCaption; FieldCaption(Quantity))
                        {
                        }
                        column(UOM_PurchTaxCrMemoLine; "Unit of Measure")
                        {
                        }
                        column(UOMCaption; FieldCaption("Unit of Measure"))
                        {
                        }
                        column(DirectUnitCost_PurchTaxCrMemoLine; "Direct Unit Cost")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 2;
                        }
                        column(LineDiscount_PurchTaxCrMemoLine; "Line Discount %")
                        {
                        }
                        column(AllowInvoiceDisc_PurchTaxCrMemoLine; "Allow Invoice Disc.")
                        {
                        }
                        column(VATIdentifier_PurchTaxCrMemoLine; "VAT Identifier")
                        {
                        }
                        column(VATIdentifierCaption; FieldCaption("VAT Identifier"))
                        {
                        }
                        column(InvDiscountAmount; -"Inv. Discount Amount")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(InvDiscountAmount0; TotalInvAmt <> 0)
                        {
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(PurchTaxCrMemoLineAmount; Amount)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalAmt; TotalAmt)
                        {
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(AmountIncluVAT_PurchTaxCrMemoLine; "Amount Including VAT")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmountIncludingVATAmount; "Amount Including VAT" - Amount)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVATAmountText; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(TotalVATAmt; TotalVATAmt)
                        {
                        }
                        column(LineAmtInvDisAmtAmtIncluVAT; -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT"))
                        {
                            AutoFormatExpression = "Purch. Tax Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PurchTaxCrMemoHdrVATBaseDis0; "Purch. Tax Cr. Memo Hdr."."VAT Base Discount %" <> 0)
                        {
                        }
                        column(CurrFactor_PurchTaxCrMemoHdr; "Purch. Tax Cr. Memo Hdr."."Currency Factor")
                        {
                        }
                        column(TotalExclVATTextLCY; TotalExclVATTextLCY)
                        {
                        }
                        column(TotalInclVATTextLCY; TotalInclVATTextLCY)
                        {
                        }
                        column(AmountIncLCY; AmountIncLCY)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmountIncLCYAmountLCY; AmountIncLCY - AmountLCY)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmountLCY; AmountLCY)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(CurrCode_PurchTaxCrMemoHdr; "Purch. Tax Cr. Memo Hdr."."Currency Code")
                        {
                        }
                        column(CurrencyLCY; CurrencyLCY)
                        {
                        }
                        column(AmountLangB1AmountLangB2; AmountLangB[1] + ' ' + AmountLangB[2])
                        {
                        }
                        column(AmountLangA1AmountLangA2; AmountLangA[1] + ' ' + AmountLangA[2])
                        {
                        }
                        column(AmountInWords; AmountInWords)
                        {
                        }
                        column(LineNo_PurchTaxCrMemoLine; "Line No.")
                        {
                        }
                        column(TotalLineAmt; TotalLineAmt)
                        {
                        }
                        column(TotalInvAmt; TotalInvAmt)
                        {
                        }
                        column(DirectUnitCostCaption; DirectUnitCostCaptionLbl)
                        {
                        }
                        column(PurchTaxCrMemoLineLineDisCaption; PurchTaxCrMemoLineLineDisCaptionLbl)
                        {
                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {
                        }
                        column(InvDiscountAmountCaption; InvDiscountAmountCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(LineAmtInvDisAmtAmtIncluVATCaption; LineAmtInvDisAmtAmtIncluVATCaptionLbl)
                        {
                        }
                        column(ExchangeRateCaption; ExchangeRateCaptionLbl)
                        {
                        }
                        dataitem(DimensionLoop2; "Integer")
                        {
                            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                            column(DimText_DimensionLoop2; DimText)
                            {
                            }
                            column(LineDimensionsCaption; LineDimensionsCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not DimSetEntry2.FindFirst() then
                                        CurrReport.Break();
                                end else
                                    if not Continue then
                                        CurrReport.Break();

                                Clear(DimText);
                                Continue := false;
                                repeat
                                    OldDimText := DimText;
                                    if DimText = '' then
                                        DimText := StrSubstNo(
                                            '%1 %2', DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code")
                                    else
                                        DimText :=
                                          StrSubstNo(
                                            '%1, %2 %3', DimText,
                                            DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code");
                                    if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                        DimText := OldDimText;
                                        Continue := true;
                                        exit;
                                    end;
                                until (DimSetEntry2.Next() = 0);
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowInternalInfo then
                                    CurrReport.Break();

                                DimSetEntry2.SetRange("Dimension Set ID", "Purch. Tax Cr. Memo Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if (Type = Type::"G/L Account") and (not ShowInternalInfo) then
                                "No." := '';

                            TempVATAmountLine.Init();
                            TempVATAmountLine."VAT Identifier" := "VAT Identifier";
                            TempVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                            TempVATAmountLine."Tax Group Code" := "Tax Group Code";
                            TempVATAmountLine."Use Tax" := "Use Tax";
                            TempVATAmountLine."VAT %" := "VAT %";
                            TempVATAmountLine."VAT Base" := Amount;
                            TempVATAmountLine."Amount Including VAT" := "Amount Including VAT";
                            TempVATAmountLine."Line Amount" := "Line Amount";
                            if "Allow Invoice Disc." then
                                TempVATAmountLine."Inv. Disc. Base Amount" := "Line Amount";
                            TempVATAmountLine."Invoice Discount Amount" := "Inv. Discount Amount";
                            TempVATAmountLine.InsertLine();

                            TypeNO := Type;
                            TotalLineAmt += "Line Amount";
                            TotalInvAmt += "Inv. Discount Amount";
                            TotalAmt += Amount;
                            TotalVATAmt += "Amount Including VAT";
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempVATAmountLine.DeleteAll();
                            MoreLines := FindLast();
                            while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0) and (Amount = 0) do
                                MoreLines := Next(-1) <> 0;
                            if not MoreLines then
                                CurrReport.Break();
                            SetRange("Line No.", 0, "Line No.");
                            TotalLineAmt := 0;
                            TotalInvAmt := 0;
                            TotalAmt := 0;
                            TotalVATAmt := 0;
                        end;
                    }
                    dataitem(VATCounter; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(VATAmountLineVATBase; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purch. Tax Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVATAmount; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purch. Tax Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineLineAmount; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purch. Tax Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineInvDiscBaseAmt; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purch. Tax Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineInvoiceDisAmt; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purch. Tax Cr. Memo Hdr."."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVAT; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmountLineVATIdentifier; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATAmountLineVATCaption; VATAmountLineVATCaptionLbl)
                        {
                        }
                        column(VATAmountLineVATBaseCaption; VATAmountLineVATBaseCaptionLbl)
                        {
                        }
                        column(VATAmountLineVATAmtCaption; VATAmountLineVATAmtCaptionLbl)
                        {
                        }
                        column(VATAmountSpecificationCaption; VATAmountSpecificationCaptionLbl)
                        {
                        }
                        column(VATAmountLineVATIdentCaption; VATAmountLineVATIdentCaptionLbl)
                        {
                        }
                        column(VATAmountLineLineAmtCaption; VATAmountLineLineAmtCaptionLbl)
                        {
                        }
                        column(VATAmtLineInvDiscBaseAmtCaption; VATAmtLineInvDiscBaseAmtCaptionLbl)
                        {
                        }
                        column(VATAmountLineInvDisAmtCaption; VATAmountLineInvDisAmtCaptionLbl)
                        {
                        }
                        column(VATBaseCaption; VATBaseCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if TempVATAmountLine.GetTotalVATAmount() = 0 then
                                CurrReport.Break();
                            SetRange(Number, 1, TempVATAmountLine.Count);
                        end;
                    }
                    dataitem(Total; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));

                        trigger OnPreDataItem()
                        begin
                            if "Purch. Tax Cr. Memo Hdr."."Buy-from Vendor No." = "Purch. Tax Cr. Memo Hdr."."Pay-to Vendor No." then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(Total2; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
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
                    if Number > 1 then
                        CopyText := CopyLbl;
                    OutputNO += 1;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then
                        PurchTaxCrMemoCountPrinted.Run("Purch. Tax Cr. Memo Hdr.");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);

                    OutputNO := 1;
                end;
            }

            trigger OnAfterGetRecord()
            var
                WithholdingTaxInvoiceMgmt: Codeunit "Withholding Tax Invoice Mgmt.";
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

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
                    PurchaserText := PurchaserLbl
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
                    TotalInclVATText := StrSubstNo(TotalIncludingVATLbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(TotalExclVATLbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(TotalLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(TotalIncludingVATLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(TotalExclVATLbl, "Currency Code");
                    TotalInclVATTextLCY := StrSubstNo(TotalIncludingVATLbl, GLSetup."LCY Code");
                    TotalExclVATTextLCY := StrSubstNo(TotalExclVATLbl, GLSetup."LCY Code");
                end;
                PurchTaxCrMemoPayTo(VendAddr, "Purch. Tax Cr. Memo Hdr.");

                CalcFields(Amount);
                CalcFields("Amount Including VAT");

                AmountLCY :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      WorkDate(), "Currency Code", Amount, "Currency Factor"));
                AmountIncLCY :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      WorkDate(), "Currency Code", "Amount Including VAT", "Currency Factor"));
                WithholdingTaxInvoiceMgmt.InitTextVariable();
                WithholdingTaxInvoiceMgmt.FormatNoText(AmountLangA, "Amount Including VAT", "Currency Code");
                if ShowTHFormatting then begin
                    WithholdingTaxInvoiceMgmt.InitTextVariableTH();
                    WithholdingTaxInvoiceMgmt.FormatNoTextTH(AmountLangB, "Amount Including VAT", "Currency Code");
                end else begin
                    AmountLangB[1] := '';
                    AmountLangB[2] := '';
                end;

                if "Applies-to Doc. No." = '' then
                    AppliedToText := ''
                else
                    AppliedToText := StrSubstNo(AppliesToLbl, "Applies-to Doc. Type", "Applies-to Doc. No.");

                PurchTaxCrMemoShipTo(ShipToAddr, "Purch. Tax Cr. Memo Hdr.");

                if LogInteraction then
                    if not CurrReport.Preview then
                        SegManagement.LogDocument(
                          16, "No.", 0, 0, DATABASE::Vendor, "Buy-from Vendor No.", "Purchaser Code", '', "Posting Description", '');
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
                    field(NoOfCopies; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    field(ShowInternalInformation; ShowInternalInfo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Internal Information';
                        ToolTip = 'Specifies if the document shows internal information.';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to log this interaction.';
                    }
                    field(AmountInWords; AmountInWords)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Total In Words';
                        ToolTip = 'Specifies that you want to print total amounts as words.';
                    }
                    field(CurrencyLCY; CurrencyLCY)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show LCY for FCY';
                        ToolTip = 'Specifies if you want to use your own currency instead of the currency of your customers or vendors.';
                    }
                    field(ShowTHAmountInWords; ShowTHFormatting)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show TH Amount In Words';
                        ToolTip = 'Specifies that you want to print Thai amounts as words.';
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
            LogInteraction := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Purch. Cr. Memo") <> '';
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
    end;

    local procedure PurchTaxCrMemoPayTo(var AddrArray: array[8] of Text[100]; var PurchTaxCrMemoHeader: Record "WHT Purch. Tax Cr. Memo Hdr.")
    begin
        FormatAddr.FormatAddr(
            AddrArray, PurchTaxCrMemoHeader."Pay-to Name", PurchTaxCrMemoHeader."Pay-to Name 2", PurchTaxCrMemoHeader."Pay-to Contact", PurchTaxCrMemoHeader."Pay-to Address", PurchTaxCrMemoHeader."Pay-to Address 2",
            PurchTaxCrMemoHeader."Pay-to City", PurchTaxCrMemoHeader."Pay-to Post Code", PurchTaxCrMemoHeader."Pay-to County", PurchTaxCrMemoHeader."Pay-to Country/Region Code");
    end;

    local procedure PurchTaxCrMemoShipTo(var AddrArray: array[8] of Text[100]; var PurchTaxCrMemoHeader: Record "WHT Purch. Tax Cr. Memo Hdr.")
    begin
        FormatAddr.FormatAddr(
            AddrArray, PurchTaxCrMemoHeader."Ship-to Name", PurchTaxCrMemoHeader."Ship-to Name 2", PurchTaxCrMemoHeader."Ship-to Contact", PurchTaxCrMemoHeader."Ship-to Address", PurchTaxCrMemoHeader."Ship-to Address 2",
            PurchTaxCrMemoHeader."Ship-to City", PurchTaxCrMemoHeader."Ship-to Post Code", PurchTaxCrMemoHeader."Ship-to County", PurchTaxCrMemoHeader."Ship-to Country/Region Code");
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        CurrExchRate: Record "Currency Exchange Rate";
        LanguageMgt: Codeunit Language;
        PurchTaxCrMemoCountPrinted: Codeunit "WHT Purch. Tax Cr.Memo-Printed";
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        VendAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        ReturnOrderNoText: Text[30];
        PurchaserText: Text[30];
        VATNoText: Text[30];
        ReferenceText: Text[35];
        AppliedToText: Text[40];
        TotalText: Text[50];
        AmountLangA: array[2] of Text[80];
        AmountLangB: array[2] of Text[80];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        MoreLines: Boolean;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        DimText: Text[120];
        OldDimText: Text[75];
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        LogInteraction: Boolean;
        AmountInWords: Boolean;
        PurchaserLbl: Label 'Purchaser';
        TotalLbl: Label 'Total %1';
        TotalIncludingVATLbl: Label 'Total %1 Incl. VAT';
        AppliesToLbl: Label '(Applies to %1 %2)';
        CopyLbl: Label 'COPY';
        PurchaseTaxCreditMemoLbl: Label 'Purchase - Tax Credit Memo %1';
        TotalExclVATLbl: Label 'Total %1 Excl. VAT';
        CurrencyLCY: Boolean;
        AmountIncLCY: Decimal;
        TotalInclVATTextLCY: Text[50];
        TotalExclVATTextLCY: Text[50];
        AmountLCY: Decimal;
        ShowTHFormatting: Boolean;
        TypeNO: Integer;
        OutputNO: Integer;
        TotalLineAmt: Decimal;
        TotalInvAmt: Decimal;
        TotalAmt: Decimal;
        TotalVATAmt: Decimal;
        LogInteractionEnable: Boolean;
        CompanyInfoPhoneNoCaptionLbl: Label 'Phone No.';
        CompanyInfoVATRegNoCaptionLbl: Label 'VAT Registration No.';
        CompanyInfoGiroNoCaptionLbl: Label 'Giro No.';
        CompanyInfoBankNameCaptionLbl: Label 'Bank';
        CompanyInfoBankAccNoCaptionLbl: Label 'Account No.';
        PurchTaxCrMemoHdrNoCaptionLbl: Label 'Credit Memo No.';
        PurchTaxCrMemoHdrPostingDateCaptionLbl: Label 'Posting Date';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        DirectUnitCostCaptionLbl: Label 'Direct Unit Cost';
        PurchTaxCrMemoLineLineDisCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        InvDiscountAmountCaptionLbl: Label 'Invoice Discount Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        LineAmtInvDisAmtAmtIncluVATCaptionLbl: Label 'Payment Discount on VAT';
        ExchangeRateCaptionLbl: Label 'Exchange Rate';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATAmountLineVATCaptionLbl: Label 'VAT %';
        VATAmountLineVATBaseCaptionLbl: Label 'VAT Base';
        VATAmountLineVATAmtCaptionLbl: Label 'VAT Amount';
        VATAmountSpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATAmountLineVATIdentCaptionLbl: Label 'VAT Identifier';
        VATAmountLineLineAmtCaptionLbl: Label 'Line Amount';
        VATAmtLineInvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        VATAmountLineInvDisAmtCaptionLbl: Label 'Invoice Discount Amount';
        VATBaseCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        DocumentDateCaptionLbl: Label 'Document Date';
        EMailCaptionLbl: Label 'E Mail';
        HomePageCaptionLbl: Label 'HomePage';
        AllowInvoiceDiscCaptionLbl: Label 'Allow Invoice Discount';
}

