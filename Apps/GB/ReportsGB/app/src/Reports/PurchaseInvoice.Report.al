// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

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
using System.Globalization;
using System.Utilities;
using System.Telemetry;

report 10581 "Purchase Invoice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/PurchaseInvoiceGB.rdlc';
    Caption = 'Purchase - Invoice';

    dataset
    {
        dataitem("Purch. Inv. Header"; "Purch. Inv. Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Posted Purchase Invoice';
            column(No_PurchInvHeader; "No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(PaymentTermsDescription; PaymentTerms.Description)
                    {
                    }
                    column(ShipmentMethodDescription; ShipmentMethod.Description)
                    {
                    }
                    column(PaymentDiscountText; PaymentDiscountText)
                    {
                    }
                    column(PurchaseInvoice; StrSubstNo(Text004Lbl, CopyText))
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
                    column(CompanyInfoEmail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyInfo."Bank Name")
                    {
                    }
                    column(CompanyInfoBankAccountNo; CompanyInfo."Bank Account No.")
                    {
                    }
                    column(PayVendNo_PurchInvHeader; "Purch. Inv. Header"."Pay-to Vendor No.")
                    {
                    }
                    column(DocDate_PurchInvHeader; Format("Purch. Inv. Header"."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_PurchInvHeader; "Purch. Inv. Header"."VAT Registration No.")
                    {
                    }
                    column(DueDate_PurchInvHeader; Format("Purch. Inv. Header"."Due Date"))
                    {
                    }
                    column(PurchaserText; PurchaserText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourRef_PurchInvHeader; "Purch. Inv. Header"."Your Reference")
                    {
                    }
                    column(OrderNoText; OrderNoText)
                    {
                    }
                    column(OrderNo_PurchInvHeader; "Purch. Inv. Header"."Order No.")
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
                    column(PostDate_PurchInvHeader; Format("Purch. Inv. Header"."Posting Date"))
                    {
                    }
                    column(PricIncVAT_PurchInvHeader; "Purch. Inv. Header"."Prices Including VAT")
                    {
                    }
                    column(CompanyInfoBankBranchNo; CompanyInfo."Bank Branch No.")
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(Pagecaption; StrSubstNo(Text005Lbl, ''))
                    {
                    }
                    column(PricIncVAT1_PurchInvHeader; Format("Purch. Inv. Header"."Prices Including VAT"))
                    {
                    }
                    column(BuyVendNo_PurchInvHeader; "Purch. Inv. Header"."Buy-from Vendor No.")
                    {
                    }
                    column(PhoneNoCaption; PhoneNoCaptionLbl)
                    {
                    }
                    column(VATRegNoCaption; VATRegNoCaptionLbl)
                    {
                    }
                    column(BankNameCaption; BankNameCaptionLbl)
                    {
                    }
                    column(BankAccountNoCaption; BankAccountNoCaptionLbl)
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
                    column(BranchNoCaption; BranchNoCaptionLbl)
                    {
                    }
                    column(PaymentTermsCaption; PaymentTermsCaptionLbl)
                    {
                    }
                    column(ShipmentMethodCaption; ShipmentMethodCaptionLbl)
                    {
                    }
                    column(PaymentDiscountCaption; PaymentDiscountCaptionLbl)
                    {
                    }
                    column(HomePageCaption; HomePageCaptionLbl)
                    {
                    }
                    column(EmailCaption; EmailCaptionLbl)
                    {
                    }
                    column(DocumentDateCaption; DocumentDateCaptionLbl)
                    {
                    }
                    column(PayVendNo_PurchInvHeaderCaption; "Purch. Inv. Header".FieldCaption("Pay-to Vendor No."))
                    {
                    }
                    column(PricIncVAT_PurchInvHeaderCaption; "Purch. Inv. Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    column(BuyVendNo_PurchInvHeaderCaption; "Purch. Inv. Header".FieldCaption("Buy-from Vendor No."))
                    {
                    }
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Purch. Inv. Header";
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(Number_IntegerLine; Number)
                        {
                        }
                        column(HeaderDimensionsCaption; HeaderDimensionsCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not DimSetEntry1.Find('-') then
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
                    dataitem("Purch. Inv. Line"; "Purch. Inv. Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Purch. Inv. Header";
                        DataItemTableView = sorting("Document No.", "Line No.");
                        column(LineAmount_PurchInvLine; "Line Amount")
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(Description_PurchInvLine; Description)
                        {
                        }
                        column(Type_PurchInvLine; "Purch. Inv. Line".Type)
                        {
                        }
                        column(No_PurchInvLine; "No.")
                        {
                        }
                        column(NoFieldCaption; FieldCaption("No."))
                        {
                        }
                        column(Quantity_PurchInvLine; Quantity)
                        {
                        }
                        column(UOM_PurchInvLine; "Unit of Measure")
                        {
                        }
                        column(DirUnitCost_PurchInvLine; "Direct Unit Cost")
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 2;
                        }
                        column(LineDiscount_PurchInvLine; "Line Discount %")
                        {
                        }
                        column(VATIdent_PurchInvLine; "VAT Identifier")
                        {
                        }
                        column(RevCharge_PurchInvLine; "Reverse Charge GB")
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalLineAmount; TotalLineAmount)
                        {
                        }
                        column(TotalInvoiceDiscAmount; TotalInvoiceDiscAmount)
                        {
                        }
                        column(TotalAmount; TotalAmount)
                        {
                        }
                        column(TotalAmountInclVAT; TotalAmountInclVAT)
                        {
                        }
                        column(InvDiscAmt_PurchInvLine; -"Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(Amount_PurchInvLine; Amount)
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(AmtIncVAT_PurchInvLine; "Amount Including VAT")
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmountIncludingVATAmount; "Amount Including VAT" - Amount)
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmountText; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(LineAmtInvDiscAmtIncVAT; -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT"))
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBasDisc_PurchInvHeader; "Purch. Inv. Header"."VAT Base Discount %")
                        {
                        }
                        column(CurrFactor_PurchInvHeader; "Purch. Inv. Header"."Currency Factor")
                        {
                            DecimalPlaces = 2 : 5;
                        }
                        column(TotalInclVATTextLCY; TotalInclVATTextLCY)
                        {
                        }
                        column(TotalExclVATTextLCY; TotalExclVATTextLCY)
                        {
                        }
                        column(AmountLCY; AmountLCY)
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmountIncLCYAmountLCY; AmountIncLCY - AmountLCY)
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmountIncLCY; AmountIncLCY)
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(CurrCode_PurchInvHeader; "Purch. Inv. Header"."Currency Code")
                        {
                        }
                        column(CurrencyLCY; Currency)
                        {
                        }
                        column(LineNo_PurchInvLine; "Line No.")
                        {
                        }
                        column(DirectUnitCostCaption; DirectUnitCostCaptionLbl)
                        {
                        }
                        column(DiscountPercentCaption; DiscountPercentCaptionLbl)
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
                        column(PaymentDisconVATCaption; PaymentDisconVATCaptionLbl)
                        {
                        }
                        column(ExchangeRateCaption; ExchangeRateCaptionLbl)
                        {
                        }
                        column(Description_PurchInvLineCaption; FieldCaption(Description))
                        {
                        }
                        column(Quantity_PurchInvLineCaption; FieldCaption(Quantity))
                        {
                        }
                        column(UOM_PurchInvLineCaption; FieldCaption("Unit of Measure"))
                        {
                        }
                        column(VATIdent_PurchInvLineCaption; FieldCaption("VAT Identifier"))
                        {
                        }
                        column(RevCharge_PurchInvLineCaption; FieldCaption("Reverse Charge GB"))
                        {
                        }
                        dataitem(DimensionLoop2; "Integer")
                        {
                            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                            column(DimText1; DimText)
                            {
                            }
                            column(LineDimensionsCaption; LineDimensionsCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not DimSetEntry2.Find('-') then
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

                                DimSetEntry2.SetRange("Dimension Set ID", "Purch. Inv. Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if (Type = Type::"G/L Account") and (not ShowInternalInfo) then
                                "No." := '';

                            TempVATAmountLine.Init();
                            TempVATAmountLine."VAT Identifier" := "Purch. Inv. Line"."VAT Identifier";
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

                            TotalAmount += Amount;
                            TotalLineAmount += "Line Amount";
                            TotalInvoiceDiscAmount += "Inv. Discount Amount";
                            TotalAmountInclVAT += "Amount Including VAT";
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempVATAmountLine.DeleteAll();
                            MoreLines := Find('+');
                            while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0) and (Amount = 0) do
                                MoreLines := Next(-1) <> 0;
                            if not MoreLines then
                                CurrReport.Break();
                            SetRange("Line No.", 0, "Line No.");
                            TotalAmount := 0;
                            TotalLineAmount := 0;
                            TotalInvoiceDiscAmount := 0;
                            TotalAmountInclVAT := 0;
                        end;
                    }
                    dataitem("Integer"; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                        dataitem(VATCounter; "Integer")
                        {
                            DataItemTableView = sorting(Number);
                            column(VATAmountLineVATBase; TempVATAmountLine."VAT Base")
                            {
                                AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineVATAmount; TempVATAmountLine."VAT Amount")
                            {
                                AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineLineAmount; TempVATAmountLine."Line Amount")
                            {
                                AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineInvDiscBaseAmt; TempVATAmountLine."Inv. Disc. Base Amount")
                            {
                                AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineInvDiscountAmt; TempVATAmountLine."Invoice Discount Amount")
                            {
                                AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineVAT; TempVATAmountLine."VAT %")
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(VATAmtLineVATIdentifier; TempVATAmountLine."VAT Identifier")
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
                            column(VATAmountSpecificationCaption; VATAmountSpecificationCaptionLbl)
                            {
                            }
                            column(InvcDiscAmtCaption; InvcDiscAmtCaptionLbl)
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
                                SetRange(Number, 1, TempVATAmountLine.Count);
                            end;
                        }

                        trigger OnPreDataItem()
                        begin
                            if TempVATAmountLine.Count <= 1 then
                                CurrReport.Break();
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
                            if "Purch. Inv. Header"."Buy-from Vendor No." = "Purch. Inv. Header"."Pay-to Vendor No." then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(Integer2; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
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
                        CopyText := Text003Lbl;
                        OutputNo += 1;
                    end;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then
                        CODEUNIT.Run(CODEUNIT::"Purch. Inv.-Printed", "Purch. Inv. Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NumberOfCopies) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
            begin
                FeatureTelemetry.LogUsage('0000OJH', FeatureNameTok, EventNameTok);
                CurrReport.Language := GlobalLanguage.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := GlobalLanguage.GetFormatRegionOrDefault("Format Region");

                CompanyInfo.Get();

                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInfo);

                DimSetEntry1.SetRange("Dimension Set ID", "Purch. Inv. Header"."Dimension Set ID");

                if "Order No." = '' then
                    OrderNoText := ''
                else
                    OrderNoText := FieldCaption("Order No.");
                if "Purchaser Code" = '' then begin
                    Clear(SalesPurchPerson);
                    PurchaserText := '';
                end else begin
                    SalesPurchPerson.Get("Purchaser Code");
                    PurchaserText := Text000Lbl
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
                    TotalText := StrSubstNo(Text001Lbl, GLSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(Text002Lbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(Text006Lbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(Text001Lbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(Text002Lbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(Text006Lbl, "Currency Code");
                    TotalInclVATTextLCY := StrSubstNo(Text002Lbl, GLSetup."LCY Code");
                    TotalExclVATTextLCY := StrSubstNo(Text006Lbl, GLSetup."LCY Code");
                end;
                FormatAddr.PurchInvPayTo(VendAddr, "Purch. Inv. Header");

                if "Payment Terms Code" = '' then
                    PaymentTerms.Init()
                else
                    PaymentTerms.Get("Payment Terms Code");
                if "Shipment Method Code" = '' then
                    ShipmentMethod.Init()
                else
                    ShipmentMethod.Get("Shipment Method Code");

                if ("VAT Base Discount %" = 0) and ("Payment Discount %" = 0) then
                    PaymentDiscountText := ''
                else
                    PaymentDiscountText :=
                      StrSubstNo(
                        VatDiscountLbl,
                        "Payment Discount %", "Pmt. Discount Date", "VAT Base Discount %");

                FormatAddr.PurchInvShipTo(ShipToAddr, "Purch. Inv. Header");

                CalcFields(Amount);
                CalcFields("Amount Including VAT");

                AmountLCY :=
                  CurrExchRate.ExchangeAmtFCYToLCY(
                    WorkDate(), "Currency Code", Amount, "Currency Factor");
                AmountIncLCY :=
                  CurrExchRate.ExchangeAmtFCYToLCY(
                    WorkDate(), "Currency Code", "Amount Including VAT", "Currency Factor");

                if InteractionLogging then
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
                    field(NoOfCopies; NumberOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    field(ShowInternalInformation; ShowInternalInfo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Internal Information';
                        ToolTip = 'Specifies if you want the printed report to show information that is only for internal use';
                    }
                    field(LogInteraction; InteractionLogging)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to log this interaction.';
                    }
                    field(CurrencyLCY; Currency)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show LCY for FCY';
                        ToolTip = 'Specifies if you want the purchase invoice to show local currency instead of foreign currency.';
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
            InteractionLogging := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Purch. Inv.") <> '';
            LogInteractionEnable := InteractionLogging;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        CurrExchRate: Record "Currency Exchange Rate";
        GlobalLanguage: Codeunit Language;
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        VendAddr: array[8] of Text;
        ShipToAddr: array[8] of Text;
        CompanyAddr: array[8] of Text;
        PurchaserText: Text;
        VATNoText: Text;
        ReferenceText: Text;
        OrderNoText: Text;
        TotalText: Text;
        TotalInclVATText: Text;
        TotalExclVATText: Text;
        PaymentDiscountText: Text;
        MoreLines: Boolean;
        NumberOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text;
        DimText: Text;
        OldDimText: Text;
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        InteractionLogging: Boolean;
        TotalInclVATTextLCY: Text;
        TotalExclVATTextLCY: Text;
        AmountLCY: Decimal;
        AmountIncLCY: Decimal;
        TotalInvoiceDiscAmount: Decimal;
        TotalLineAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        Currency: Boolean;
        OutputNo: Integer;
        LogInteractionEnable: Boolean;
        Text000Lbl: Label 'Purchaser';
        Text001Lbl: Label 'Total %1', Comment = '%1 = code';
        Text002Lbl: Label 'Total %1 Incl. VAT', Comment = '%1 = code';
        Text003Lbl: Label 'COPY';
        Text004Lbl: Label 'Purchase - Invoice %1', Comment = '%1 = copy text';
        Text005Lbl: Label 'Page %1', Comment = '%1 = page caption';
        Text006Lbl: Label 'Total %1 Excl. VAT', Comment = '%1 = code';
        VatDiscountLbl: Label '%1 % if paid by %2, VAT discounted at %3 % ', Comment = '%1 = payment discount, %2 = discount date, %3 = VAT base discount';
        PhoneNoCaptionLbl: Label 'Phone No.';
        VATRegNoCaptionLbl: Label 'VAT Registration No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccountNoCaptionLbl: Label 'Account No.';
        DueDateCaptionLbl: Label 'Due Date';
        InvoiceNoCaptionLbl: Label 'Invoice No.';
        PostingDateCaptionLbl: Label 'Posting Date';
        BranchNoCaptionLbl: Label 'Bank Branch No.';
        PaymentTermsCaptionLbl: Label 'Payment Terms';
        ShipmentMethodCaptionLbl: Label 'Shipment Method';
        PaymentDiscountCaptionLbl: Label 'Payment Discount';
        HomePageCaptionLbl: Label 'Home Page';
        EmailCaptionLbl: Label 'E-Mail';
        DocumentDateCaptionLbl: Label 'Document Date';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        DirectUnitCostCaptionLbl: Label 'Direct Unit Cost';
        DiscountPercentCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        InvDiscountAmountCaptionLbl: Label 'Invoice Discount Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        PaymentDisconVATCaptionLbl: Label 'Payment Discount on VAT';
        ExchangeRateCaptionLbl: Label 'Exchange Rate';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATPercentCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmountCaptionLbl: Label 'VAT Amount';
        VATAmountSpecificationCaptionLbl: Label 'VAT Amount Specification';
        InvcDiscAmtCaptionLbl: Label 'Invoice Discount Amount';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        LineAmountCaptionLbl: Label 'Line Amount';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        TotalCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        FeatureNameTok: Label 'Purchase Invoice GB', Locked = true;
        EventNameTok: Label 'Purchase Invoice GB report has been used', Locked = true;
}

