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
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.WithholdingTax;
using System.Globalization;
using System.Utilities;

report 6788 "WHT Purch. - Tax Invoice"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'src\Purchase\Report\WHTPurchTaxInvoice.rdlc';
    Caption = 'Purch. - Tax Invoice';

    dataset
    {
        dataitem("Purch. Tax Inv. Header"; "WHT Purch. Tax Inv. Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Posted Purchase Tax Invoice';
            column(No_PurchTaxInvHdr; "No.")
            {
            }
            column(DocumentDateCation; DocumentDateCationLbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(BuyfromVendNo_PurchTaxInvHdr; "Purch. Tax Inv. Header"."Buy-from Vendor No.")
                    {
                    }
                    column(BuyfromVendNo_PurchTaxInvHdrCaption; "Purch. Tax Inv. Header".FieldCaption("Buy-from Vendor No."))
                    {
                    }
                    column(HomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(Email; CompanyInfo."E-Mail")
                    {
                    }
                    column(PaymentTermsDescription; PaymentTerms.Description)
                    {
                    }
                    column(ShipmentMethodDescription; ShipmentMethod.Description)
                    {
                    }
                    column(ShipmentMethodDescriptionCaption; ShipmentMethodDescriptionCaptionLbl)
                    {
                    }
                    column(PaymentTermsDescriptionCaption; PaymentTermsDescriptionCaptionLbl)
                    {
                    }
                    column(PurchTaxInvCopyText; StrSubstNo(PurchTaxInvoiceTitleLbl, CopyText))
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
                    column(PaytoVendNo_PurchTaxInvHdr; "Purch. Tax Inv. Header"."Pay-to Vendor No.")
                    {
                    }
                    column(FormatedDocumentDate; Format("Purch. Tax Inv. Header"."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_PurchTaxInvHdr; "Purch. Tax Inv. Header"."VAT Registration No.")
                    {
                    }
                    column(FormatedDueDate; Format("Purch. Tax Inv. Header"."Due Date"))
                    {
                    }
                    column(PurchaserText; PurchaserText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(No_PageLoop; "Purch. Tax Inv. Header"."No.")
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourReference_PurchTaxInvHdr; "Purch. Tax Inv. Header"."Your Reference")
                    {
                    }
                    column(OrderNoText; OrderNoText)
                    {
                    }
                    column(OrderNo_PurchTaxInvHdr; "Purch. Tax Inv. Header"."Order No.")
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
                    column(FormatedPostingDate; Format("Purch. Tax Inv. Header"."Posting Date"))
                    {
                    }
                    column(PricesIncluVAT_PurchTaxInvHdr; "Purch. Tax Inv. Header"."Prices Including VAT")
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
                    column(DueDateCaption; DueDateCaptionLbl)
                    {
                    }
                    column(InvoiceNoCaption; InvoiceNoCaptionLbl)
                    {
                    }
                    column(PostingDateCaption; PostingDateCaptionLbl)
                    {
                    }
                    column(CompanyInfoHomepageCapation; CompanyInfoHomepageCapationLbl)
                    {
                    }
                    column(CompanyInfoEmailCaption; CompanyInfoEmailCaptionLbl)
                    {
                    }
                    column(PaytoVendNo_PurchTaxInvHdrCaption; "Purch. Tax Inv. Header".FieldCaption("Pay-to Vendor No."))
                    {
                    }
                    column(PricesIncluVAT_PurchTaxInvHdrCaption; "Purch. Tax Inv. Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Purch. Tax Inv. Header";
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
                    dataitem("Purch. Tax Inv. Line"; "WHT Purch. Tax Inv. Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Purch. Tax Inv. Header";
                        DataItemTableView = sorting("Document No.", "Line No.");
                        column(LineAmount_PurchTaxInvLine; "Line Amount")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(Description_PurchTaxInvLine; Description)
                        {
                        }
                        column(TypeNo; TypeNO)
                        {
                        }
                        column(Quantity_PurchTaxInvLine; Quantity)
                        {
                        }
                        column(DirectUnitCost_PurchTaxInvLine; "Direct Unit Cost")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 2;
                        }
                        column(LineDiscount_PurchTaxInvLine; "Line Discount %")
                        {
                        }
                        column(AllowInvDisc_PurchTaxInvLine; "Allow Invoice Disc.")
                        {
                        }
                        column(VATIdentifier_PurchTaxInvLine; "VAT Identifier")
                        {
                        }
                        column(ExternalDoNo_PurchTaxInvLine; "External Document No.")
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
                        column(Amount_PurchTaxInvLine; Amount)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalAmt; TotalAmt)
                        {
                        }
                        column(TotalVATAmt; TotalVATAmt)
                        {
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(AmtIncluVAT_PurchTaxInvLine; "Amount Including VAT")
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
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(LineAmtInvDisAmtAmtIncluVAT; -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT"))
                        {
                            AutoFormatExpression = "Purch. Tax Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PurchTaxInvHdrVATBaseDiscount0; "Purch. Tax Inv. Header"."VAT Base Discount %" <> 0)
                        {
                        }
                        column(AmountIncLCY; AmountIncLCY)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATTextLCY; TotalInclVATTextLCY)
                        {
                        }
                        column(CurrFactor_PurchTaxInvHdr; "Purch. Tax Inv. Header"."Currency Factor")
                        {
                        }
                        column(TotalExclVATTextLCY; TotalExclVATTextLCY)
                        {
                        }
                        column(AmountLCY; AmountLCY)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(CurrencyLCY; CurrencyLCY)
                        {
                        }
                        column(CurrCode_PurchTaxInvHdr; "Purch. Tax Inv. Header"."Currency Code")
                        {
                        }
                        column(AmountLangB1AmountLangB2; AmountLangB[1] + ' ' + AmountLangB[2])
                        {
                            AutoFormatType = 1;
                        }
                        column(AmountLangA1AmountLangA2; AmountLangA[1] + ' ' + AmountLangA[2])
                        {
                            AutoFormatType = 1;
                        }
                        column(AmountInWords; AmountInWords)
                        {
                        }
                        column(LineNo_PurchTaxInvLine; "Line No.")
                        {
                        }
                        column(TotalLineAmt; TotalLineAmt)
                        {
                        }
                        column(TotalInvAmt; TotalInvAmt)
                        {
                        }
                        column(InvoiceRefCaption; InvoiceRefCaptionLbl)
                        {
                        }
                        column(DirectUnitCostCaption; DirectUnitCostCaptionLbl)
                        {
                        }
                        column(PurchTaxInvLineLineDiscountCaption; PurchTaxInvLineLineDiscountCaptionLbl)
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
                        column(Description_PurchTaxInvLineCaption; FieldCaption(Description))
                        {
                        }
                        column(Quantity_PurchTaxInvLineCaption; FieldCaption(Quantity))
                        {
                        }
                        column(AllowInvDisc_PurchTaxInvLineCaption; FieldCaption("Allow Invoice Disc."))
                        {
                        }
                        column(VATIdentifier_PurchTaxInvLineCaption; FieldCaption("VAT Identifier"))
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

                                DimSetEntry2.SetRange("Dimension Set ID", "Purch. Tax Inv. Line"."Dimension Set ID");
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
                            TempVATAmountLine."WHT VAT Realized" := "Paid VAT";
                            TempVATAmountLine."WHT Amount Paid" := "Paid Amount Incl. VAT";
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
                        column(VATBase_VATAmountLine; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purch. Tax Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmount_VATAmountLine; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purch. Tax Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(LineAmount_VATAmountLine; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purch. Tax Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(InvDiscBaseAmt_VATAmountLine; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purch. Tax Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(InvoiceDisAmt_VATAmountLine; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purch. Tax Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATRealized_VATAmountLine; TempVATAmountLine."WHT VAT Realized")
                        {
                            AutoFormatExpression = "Purch. Tax Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AmountPaid_VATAmountLine; TempVATAmountLine."WHT Amount Paid")
                        {
                            AutoFormatExpression = "Purch. Tax Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VAT_VATAmountLine; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATIdentifier_VATAmountLine; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATAmountLineVATCaption; VATAmountLineVATCaptionLbl)
                        {
                        }
                        column(VATBaseCaption; VATBaseCaptionLbl)
                        {
                        }
                        column(VATAmountLineVATAmountCaption; VATAmountLineVATAmountCaptionLbl)
                        {
                        }
                        column(VATAmountSpecificationCaption; VATAmountSpecificationCaptionLbl)
                        {
                        }
                        column(VATAmountLineInvDisAmtCaption; VATAmountLineInvDisAmtCaptionLbl)
                        {
                        }
                        column(VATAmountLineInvDiscBaseAmtCaption; VATAmountLineInvDiscBaseAmtCaptionLbl)
                        {
                        }
                        column(VATAmountLineLineAmtCaption; VATAmountLineLineAmtCaptionLbl)
                        {
                        }
                        column(VATAmountLineVATIdentifierCaption; VATAmountLineVATIdentifierCaptionLbl)
                        {
                        }
                        column(AmountPaidCaption; AmountPaidCaptionLbl)
                        {
                        }
                        column(VATRealizedCaption; VATRealizedCaptionLbl)
                        {
                        }
                        column(VATAmountLineVATBaseCaption; VATAmountLineVATBaseCaptionLbl)
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
                    }
                    dataitem(Total2; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));

                        trigger OnPreDataItem()
                        begin
                            if "Purch. Tax Inv. Header"."Buy-from Vendor No." = "Purch. Tax Inv. Header"."Pay-to Vendor No." then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(Total3; "Integer")
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
                        CopyText := CopyCaptionLbl;
                    OutputNO += 1;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then
                        PurchTaxInvCountPrinted.Run("Purch. Tax Inv. Header");
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

                if "Order No." = '' then
                    OrderNoText := ''
                else
                    OrderNoText := FieldCaption("Order No.");
                if "Purchaser Code" = '' then begin
                    Clear(SalesPurchPerson);
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
                    TotalText := StrSubstNo(totalLbl, GLSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(TotalInclVATCaptionLbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(TotalExclVATCaptionLbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(totalLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(TotalInclVATCaptionLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(TotalExclVATCaptionLbl, "Currency Code");
                    TotalInclVATTextLCY := StrSubstNo(TotalInclVATCaptionLbl, GLSetup."LCY Code");
                    TotalExclVATTextLCY := StrSubstNo(TotalExclVATCaptionLbl, GLSetup."LCY Code");
                end;
                PurchTaxInvPayTo(VendAddr, "Purch. Tax Inv. Header");

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

                if "Payment Terms Code" = '' then
                    PaymentTerms.Init()
                else
                    PaymentTerms.Get("Payment Terms Code");
                if "Shipment Method Code" = '' then
                    ShipmentMethod.Init()
                else
                    ShipmentMethod.Get("Shipment Method Code");

                PurchTaxInvShipTo(ShipToAddr, "Purch. Tax Inv. Header");

                if LogInteraction then
                    if not CurrReport.Preview then
                        SegManagement.LogDocument(
                          14, "No.", 0, 0, DATABASE::Vendor, "Buy-from Vendor No.", "Purchaser Code", '', "Posting Description", '');
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
            LogInteraction := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Purch. Inv.") <> '';
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

    local procedure PurchTaxInvPayTo(var AddrArray: array[8] of Text[100]; var PurchTaxInvHeader: Record "WHT Purch. Tax Inv. Header")
    begin
        FormatAddr.FormatAddr(
            AddrArray, PurchTaxInvHeader."Pay-to Name", PurchTaxInvHeader."Pay-to Name 2", PurchTaxInvHeader."Pay-to Contact", PurchTaxInvHeader."Pay-to Address", PurchTaxInvHeader."Pay-to Address 2",
            PurchTaxInvHeader."Pay-to City", PurchTaxInvHeader."Pay-to Post Code", PurchTaxInvHeader."Pay-to County", PurchTaxInvHeader."Pay-to Country/Region Code");
    end;

    local procedure PurchTaxInvShipTo(var AddrArray: array[8] of Text[100]; var PurchTaxInvHeader: Record "WHT Purch. Tax Inv. Header")
    begin
        FormatAddr.FormatAddr(
            AddrArray, PurchTaxInvHeader."Ship-to Name", PurchTaxInvHeader."Ship-to Name 2", PurchTaxInvHeader."Ship-to Contact", PurchTaxInvHeader."Ship-to Address", PurchTaxInvHeader."Ship-to Address 2",
            PurchTaxInvHeader."Ship-to City", PurchTaxInvHeader."Ship-to Post Code", PurchTaxInvHeader."Ship-to County", PurchTaxInvHeader."Ship-to Country/Region Code");
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        CurrExchRate: Record "Currency Exchange Rate";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        LanguageMgt: Codeunit Language;
        PurchTaxInvCountPrinted: Codeunit "WHT Purch. Tax Inv.-Printed";
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        VendAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        PurchaserText: Text[30];
        VATNoText: Text[30];
        ReferenceText: Text[35];
        OrderNoText: Text[30];
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        AmountLangA: array[2] of Text[80];
        AmountLangB: array[2] of Text[80];
        MoreLines: Boolean;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[10];
        DimText: Text[120];
        OldDimText: Text[75];
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        LogInteraction: Boolean;
        AmountInWords: Boolean;
        PurchaserLbl: Label 'Purchaser';
        totalLbl: Label 'Total %1';
        TotalInclVATCaptionLbl: Label 'Total %1 Incl. VAT';
        CopyCaptionLbl: Label 'COPY';
        PurchTaxInvoiceTitleLbl: Label 'Purchase - Tax Invoice %1';
        TotalExclVATCaptionLbl: Label 'Total %1 Excl. VAT';
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
        ShipmentMethodDescriptionCaptionLbl: Label 'Shipment Method';
        PaymentTermsDescriptionCaptionLbl: Label 'Payment Terms';
        CompanyInfoPhoneNoCaptionLbl: Label 'Phone No.';
        CompanyInfoVATRegNoCaptionLbl: Label 'VAT Registration No.';
        CompanyInfoGiroNoCaptionLbl: Label 'Giro No.';
        CompanyInfoBankNameCaptionLbl: Label 'Bank';
        CompanyInfoBankAccNoCaptionLbl: Label 'Account No.';
        DueDateCaptionLbl: Label 'Due Date';
        InvoiceNoCaptionLbl: Label 'Invoice No.';
        PostingDateCaptionLbl: Label 'Posting Date';
        CompanyInfoHomepageCapationLbl: Label 'Home Page';
        CompanyInfoEmailCaptionLbl: Label 'E-Mail';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        InvoiceRefCaptionLbl: Label 'Invoice Ref.';
        DirectUnitCostCaptionLbl: Label 'Direct Unit Cost';
        PurchTaxInvLineLineDiscountCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        InvDiscountAmountCaptionLbl: Label 'Invoice Discount Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        LineAmtInvDisAmtAmtIncluVATCaptionLbl: Label 'Payment Discount on VAT';
        ExchangeRateCaptionLbl: Label 'Exchange Rate';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATAmountLineVATCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmountLineVATAmountCaptionLbl: Label 'VAT Amount';
        VATAmountSpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATAmountLineInvDisAmtCaptionLbl: Label 'Invoice Discount Amount';
        VATAmountLineInvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        VATAmountLineLineAmtCaptionLbl: Label 'Line Amount';
        VATAmountLineVATIdentifierCaptionLbl: Label 'VAT Identifier';
        AmountPaidCaptionLbl: Label 'Amount Paid';
        VATRealizedCaptionLbl: Label 'VAT Realized';
        VATAmountLineVATBaseCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        DocumentDateCationLbl: Label 'Document Date';
}

