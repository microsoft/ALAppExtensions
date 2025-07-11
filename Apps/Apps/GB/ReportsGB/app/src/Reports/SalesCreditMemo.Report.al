// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;
using System.Globalization;
using System.Utilities;
using System.Telemetry;

report 10582 "Sales - Credit Memo"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/SalesCreditMemoGB.rdlc';
    Caption = 'Sales - Credit Memo';
    Permissions = TableData "Sales Shipment Buffer" = rimd;

    dataset
    {
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'Posted Sales Credit Memo';
            column(No_SalesCrMemoHeader; "No.")
            {
            }
            column(EMailCaption; EMailCaptionLbl)
            {
            }
            column(DocumentDateCaption; DocumentDateCaptionLbl)
            {
            }
            column(AppliesToCaption; AppliesToCaptionLbl)
            {
            }
            column(TotalReverseChargeVATCaption; TotalReverseChargeVATLbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(CopyText; StrSubstNo(Text005Lbl, CopyText))
                    {
                    }
                    column(CustAddr1; CustAddr[1])
                    {
                    }
                    column(CompanyInfoPicture1; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfoPicture2; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfoPicture3; CompanyInfo3.Picture)
                    {
                    }
                    column(PaymentDiscountText; PaymentDiscountText)
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
                    column(CompanyInfoFaxNo; CompanyInfo."Fax No.")
                    {
                    }
                    column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyBankAccount.Name)
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoEMail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoBankAccountNo; CompanyBankAccount."Bank Account No.")
                    {
                    }
                    column(BilltoCustNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Bill-to Customer No.")
                    {
                    }
                    column(PostDate_SalesCrMemoHeader; Format("Sales Cr.Memo Header"."Posting Date"))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."VAT Registration No.")
                    {
                    }
                    column(No1_SalesCrMemoHeader; "Sales Cr.Memo Header"."No.")
                    {
                    }
                    column(SalesPersonText; SalesPersonText)
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
                    column(YourRef_SalesCrMemoHeader; "Sales Cr.Memo Header"."Your Reference")
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
                    column(DocDate_SalesCrMemoHeader; Format("Sales Cr.Memo Header"."Document Date", 0, 4))
                    {
                    }
                    column(PriceIncludVAT_SalesCrMemoHeader; "Sales Cr.Memo Header"."Prices Including VAT")
                    {
                    }
                    column(ReturnOrderNoText; ReturnOrderNoText)
                    {
                    }
                    column(ReturnOrderNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Return Order No.")
                    {
                    }
                    column(CompanyInfoBankBranchNo; CompanyBankAccount."Bank Branch No.")
                    {
                    }
                    column(PageNo; StrSubstNo(Text006Lbl, ''))
                    {
                    }
                    column(CopyLoopNumber; CopyLoop.Number)
                    {
                    }
                    column(PriceIncludVAT1_SalesCrMemoHeader; Format("Sales Cr.Memo Header"."Prices Including VAT"))
                    {
                    }
                    column(PaymentDiscountCaption; PaymentDiscountCaptionLbl)
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
                    column(BankNameCaption; BankNameCaptionLbl)
                    {
                    }
                    column(BankAccNoCaption; BankAccNoCaptionLbl)
                    {
                    }
                    column(CrMemoNoCaption; CrMemoNoCaptionLbl)
                    {
                    }
                    column(PostingDateCaption; PostingDateCaptionLbl)
                    {
                    }
                    column(BankBranchNoCaption; BankBranchNoCaptionLbl)
                    {
                    }
                    column(UnitPriceCaption; UnitPriceCaptionLbl)
                    {
                    }
                    column(DiscPercentCaption; DiscPercentCaptionLbl)
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
                    column(BilltoCustNo_SalesCrMemoHeaderCaption; "Sales Cr.Memo Header".FieldCaption("Bill-to Customer No."))
                    {
                    }
                    column(PriceIncludVAT_SalesCrMemoHeaderCaption; "Sales Cr.Memo Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Sales Cr.Memo Header";
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(DimensionLoop1Number; Number)
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
                    dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Sales Cr.Memo Header";
                        DataItemTableView = sorting("Document No.", "Line No.");
                        column(Type_SalesCrMemoLine; "Sales Cr.Memo Line".Type)
                        {
                        }
                        column(LineNo_SalesCrMemoLine; "Sales Cr.Memo Line"."Line No.")
                        {
                        }
                        column(SalesCrMemoLineLineAmount; "Line Amount")
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(Desc_SalesCrMemoLine; Description)
                        {
                        }
                        column(No_SalesCrMemoLine; "No.")
                        {
                        }
                        column(No_SalesCrMemoLineCaption; FieldCaption("No."))
                        {
                        }
                        column(Qty_SalesCrMemoLine; Quantity)
                        {
                        }
                        column(UOM_SalesCrMemoLine; "Unit of Measure")
                        {
                        }
                        column(UnitPrice_SalesCrMemoLine; "Unit Price")
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 2;
                        }
                        column(LineDisc_SalesCrMemoLine; "Line Discount %")
                        {
                        }
                        column(VATIdentifier_SalesCrMemoLine; "VAT Identifier")
                        {
                        }
                        column(ReverseChrg_SalesCrMemoLine; "Reverse Charge GB")
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(VATBasDisc_SalesCrMemoHeader; "Sales Cr.Memo Header"."VAT Base Discount %")
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
                        column(TotalLineAmount; TotalLineAmount)
                        {
                        }
                        column(TotalReverseCharge; TotalReverseCharge)
                        {
                        }
                        column(InvDiscAmt_SalesCrMemoLine; -"Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(Amt_SalesCrMemoLine; Amount)
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(AmtIncludVAT_SalesCrMemoLine; "Amount Including VAT")
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmtIncludingVATAmt; "Amount Including VAT" - Amount)
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVATAmountText; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(LineAmtInvDiscAmtIncludVAT; -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT"))
                        {
                            AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(CurrncyFctr_SalesCrMemoHeader; "Sales Cr.Memo Header"."Currency Factor")
                        {
                            DecimalPlaces = 2 : 5;
                        }
                        column(TotalInclVATTextLCY; TotalInclVATTextLCY)
                        {
                        }
                        column(AmountIncLCYAmountLCY; AmountIncLCY - AmountLCY)
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmountIncLCY; AmountIncLCY)
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalExclVATTextLCY; TotalExclVATTextLCY)
                        {
                        }
                        column(AmountLCY; AmountLCY)
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(CurCode_SalesCrMemoHeader; "Sales Cr.Memo Header"."Currency Code")
                        {
                        }
                        column(CurrencyLCY; Currency)
                        {
                        }
                        column(Desc_SalesCrMemoLineCaption; FieldCaption(Description))
                        {
                        }
                        column(Qty_SalesCrMemoLineCaption; FieldCaption(Quantity))
                        {
                        }
                        column(UOM_SalesCrMemoLineCaption; FieldCaption("Unit of Measure"))
                        {
                        }
                        column(VATIdentifier_SalesCrMemoLineCaption; FieldCaption("VAT Identifier"))
                        {
                        }
                        column(ReverseChrg_SalesCrMemoLineCaption; FieldCaption("Reverse Charge GB"))
                        {
                        }
                        dataitem("Sales Shipment Buffer"; "Integer")
                        {
                            DataItemTableView = sorting(Number);
                            column(SalesShipmentBufferPostDate; Format(TempSalesShipmentBuffer."Posting Date"))
                            {
                            }
                            column(SalesShipmentBufferQty; TempSalesShipmentBuffer.Quantity)
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(ReturnReceiptCaption; ReturnReceiptCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then
                                    TempSalesShipmentBuffer.Find('-')
                                else
                                    TempSalesShipmentBuffer.Next();
                            end;

                            trigger OnPreDataItem()
                            begin
                                SetRange(Number, 1, TempSalesShipmentBuffer.Count);
                            end;
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

                                DimSetEntry2.SetRange("Dimension Set ID", "Sales Cr.Memo Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempSalesShipmentBuffer.DeleteAll();
                            TempSalesShipmentBuffer.Reset();
                            TempSalesShipmentBuffer.DeleteAll();

                            if (Type = Type::"G/L Account") and (not ShowInternalInfo) then
                                "No." := '';

                            TempVATAmountLine.Init();
                            TempVATAmountLine."VAT Identifier" := "VAT Identifier";
                            TempVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                            TempVATAmountLine."Tax Group Code" := "Tax Group Code";
                            TempVATAmountLine."VAT %" := "VAT %";
                            TempVATAmountLine."VAT Base" := Amount;
                            TempVATAmountLine."Amount Including VAT" := "Amount Including VAT";
                            TempVATAmountLine."Line Amount" := "Line Amount";
                            if "Allow Invoice Disc." then
                                TempVATAmountLine."Inv. Disc. Base Amount" := "Line Amount";
                            TempVATAmountLine."Invoice Discount Amount" := "Inv. Discount Amount";
                            TempVATAmountLine.InsertLine();

                            TotalLineAmount += "Line Amount";
                            TotalAmount += Amount;
                            TotalInvoiceDiscAmount += "Inv. Discount Amount";
                            TotalAmountInclVAT += "Amount Including VAT";
                            TotalReverseCharge += "Reverse Charge GB";
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempVATAmountLine.DeleteAll();
                            FirstValueEntryNo := 0;
                            MoreLines := Find('+');
                            while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0) and (Amount = 0) do
                                MoreLines := Next(-1) <> 0;
                            if not MoreLines then
                                CurrReport.Break();
                            SetRange("Line No.", 0, "Line No.");
                            TotalLineAmount := 0;
                            TotalAmount := 0;
                            TotalInvoiceDiscAmount := 0;
                            TotalAmountInclVAT := 0;
                            TotalReverseCharge := 0;
                        end;
                    }
                    dataitem("Integer"; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                        dataitem(VATCounter; "Integer")
                        {
                            DataItemTableView = sorting(Number);
                            column(VATAmtLineVATBase; TempVATAmountLine."VAT Base")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineVATAmount; TempVATAmountLine."VAT Amount")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineLineAmount; TempVATAmountLine."Line Amount")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineInvDiscBaseAmt; TempVATAmountLine."Inv. Disc. Base Amount")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineInvoiceDiscAmt; TempVATAmountLine."Invoice Discount Amount")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineVAT; TempVATAmountLine."VAT %")
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
                            column(VATIdentifierCaption; VATIdentifierCaptionLbl)
                            {
                            }
                            column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
                            {
                            }
                            column(LineAmtCaption; LineAmtCaptionLbl)
                            {
                            }
                            column(InvcDiscAmtCaption; InvcDiscAmtCaptionLbl)
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
                        dataitem(Total2; "Integer")
                        {
                            DataItemTableView = sorting(Number) where(Number = const(1));
                            column(SelltoCustNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Customer No.")
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
                            column(ShiptoAddressCaption; ShiptoAddressCaptionLbl)
                            {
                            }
                            column(SelltoCustNo_SalesCrMemoHeaderCaption; "Sales Cr.Memo Header".FieldCaption("Sell-to Customer No."))
                            {
                            }
                        }
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then
                        CopyText := Text004Lbl;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then
                        CODEUNIT.Run(CODEUNIT::"Sales Cr. Memo-Printed", "Sales Cr.Memo Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NumberOfCopies) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                end;
            }

            trigger OnAfterGetRecord()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
            begin
                FeatureTelemetry.LogUsage('0000OJK', FeatureNameTok, EventNameTok);
                CurrReport.Language := GlobalLanguage.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := GlobalLanguage.GetFormatRegionOrDefault("Format Region");

                if not CompanyBankAccount.Get("Sales Cr.Memo Header"."Company Bank Account Code") then
                    CompanyBankAccount.CopyBankFieldsFromCompanyInfo(CompanyInfo);

                CompanyInfo.Get();

                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInfo);

                DimSetEntry1.SetRange("Dimension Set ID", "Sales Cr.Memo Header"."Dimension Set ID");

                if "Return Order No." = '' then
                    ReturnOrderNoText := ''
                else
                    ReturnOrderNoText := FieldCaption("Return Order No.");
                if "Salesperson Code" = '' then begin
                    SalesPurchPerson.Init();
                    SalesPersonText := '';
                end else begin
                    SalesPurchPerson.Get("Salesperson Code");
                    SalesPersonText := Text000Lbl;
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
                    TotalExclVATText := StrSubstNo(Text007Lbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(Text001Lbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(Text002Lbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(Text007Lbl, "Currency Code");
                    TotalInclVATTextLCY := StrSubstNo(Text002Lbl, GLSetup."LCY Code");
                    TotalExclVATTextLCY := StrSubstNo(Text007Lbl, GLSetup."LCY Code");
                end;
                FormatAddr.SalesCrMemoBillTo(CustAddr, "Sales Cr.Memo Header");
                if "Applies-to Doc. No." = '' then
                    AppliedToText := ''
                else
                    AppliedToText := StrSubstNo(Text003Lbl, "Applies-to Doc. Type", "Applies-to Doc. No.");

                if ("VAT Base Discount %" = 0) and ("Payment Discount %" = 0) then
                    PaymentDiscountText := ''
                else
                    PaymentDiscountText :=
                      StrSubstNo(
                        VATDiscountLbl,
                        "Payment Discount %", "VAT Base Discount %");

                FormatAddr.SalesCrMemoShipTo(ShipToAddr, CustAddr, "Sales Cr.Memo Header");

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
                          6, "No.", 0, 0, DATABASE::Customer, "Sell-to Customer No.", "Salesperson Code",
                          "Campaign No.", "Posting Description", '');
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
                        ToolTip = 'Specifies if you want the printed report to show information that is only for internal use.';
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
                        ToolTip = 'Specifies if you want the sales credit memo to show local currency instead of foreign currency.';
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
            InteractionLogging := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Sales Cr. Memo") <> '';
            LogInteractionEnable := InteractionLogging;
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
    end;

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyBankAccount: Record "Bank Account";
        CompanyInfo: Record "Company Information";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary;
        CurrExchRate: Record "Currency Exchange Rate";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        RespCenter: Record "Responsibility Center";
        GlobalLanguage: Codeunit Language;
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        CustAddr: array[8] of Text;
        ShipToAddr: array[8] of Text;
        CompanyAddr: array[8] of Text;
        ReturnOrderNoText: Text;
        SalesPersonText: Text;
        VATNoText: Text;
        ReferenceText: Text;
        AppliedToText: Text;
        TotalText: Text;
        TotalExclVATText: Text;
        TotalInclVATText: Text;
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
        FirstValueEntryNo: Integer;
        NextEntryNo: Integer;
        TotalInclVATTextLCY: Text;
        TotalExclVATTextLCY: Text;
        AmountLCY: Decimal;
        AmountIncLCY: Decimal;
        TotalLineAmount: Decimal;
        TotalInvoiceDiscAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalReverseCharge: Decimal;
        Currency: Boolean;
        LogInteractionEnable: Boolean;
        Text000Lbl: Label 'Salesperson';
        Text001Lbl: Label 'Total %1', Comment = '%1 = code';
        Text002Lbl: Label 'Total %1 Incl. VAT', Comment = '%1 = code';
        Text003Lbl: Label '(Applies to %1 %2)', Comment = '%1 = Doc. type, %2 = Doc. No.';
        Text004Lbl: Label ' COPY';
        Text005Lbl: Label 'Sales - Credit Memo%1', Comment = '%1 = copy text';
        Text006Lbl: Label 'Page %1', Comment = '%1 = page number';
        Text007Lbl: Label 'Total %1 Excl. VAT', Comment = '%1 = code';
        VATDiscountLbl: Label '%1 %, VAT discounted at %2 % ', Comment = '%1 = payment discount, %2 = VAT base discount';
        PaymentDiscountCaptionLbl: Label 'Payment Discount';
        PhoneNoCaptionLbl: Label 'Phone No.';
        HomePageCaptionLbl: Label 'Home Page';
        VATRegNoCaptionLbl: Label 'VAT Registration No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccNoCaptionLbl: Label 'Account No.';
        CrMemoNoCaptionLbl: Label 'Credit Memo No.';
        PostingDateCaptionLbl: Label 'Posting Date';
        BankBranchNoCaptionLbl: Label 'Bank Branch No.';
        UnitPriceCaptionLbl: Label 'Unit Price';
        DiscPercentCaptionLbl: Label 'Discount%';
        AmountCaptionLbl: Label 'Amount';
        InvDiscountAmountCaptionLbl: Label 'Invoice Discount Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        PaymentDisconVATCaptionLbl: Label 'Payment Discount on VAT';
        ExchangeRateCaptionLbl: Label 'Exchange Rate';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        ReturnReceiptCaptionLbl: Label 'Return Receipt';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATPercentCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmountCaptionLbl: Label 'VAT Amount';
        VATAmountSpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        LineAmtCaptionLbl: Label 'Line Amount';
        InvcDiscAmtCaptionLbl: Label 'Invoice Discount Amount';
        TotalCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        EMailCaptionLbl: Label 'E-Mail';
        DocumentDateCaptionLbl: Label 'Document Date';
        AppliesToCaptionLbl: Label 'Applies To';
        TotalReverseChargeVATLbl: Label 'Total Reverse Charge VAT';
        FeatureNameTok: Label 'Sales Credit Memo GB', Locked = true;
        EventNameTok: Label 'Sales Credit Memo GB report has been used', Locked = true;

    procedure InitLogInteraction()
    begin
        InteractionLogging := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Sales Cr. Memo") <> '';
    end;

    procedure GenerateBufferFromValueEntry(SalesCrMemoLine2: Record "Sales Cr.Memo Line")
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TotalQuantity: Decimal;
        Quantity: Decimal;
    begin
        TotalQuantity := SalesCrMemoLine2."Quantity (Base)";
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", SalesCrMemoLine2."Document No.");
        ValueEntry.SetRange("Posting Date", "Sales Cr.Memo Header"."Posting Date");
        ValueEntry.SetRange("Item Charge No.", '');
        ValueEntry.SetFilter("Entry No.", '%1..', FirstValueEntryNo);
        if ValueEntry.Find('-') then
            repeat
                if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then begin
                    if SalesCrMemoLine2."Qty. per Unit of Measure" <> 0 then
                        Quantity := ValueEntry."Invoiced Quantity" / SalesCrMemoLine2."Qty. per Unit of Measure"
                    else
                        Quantity := ValueEntry."Invoiced Quantity";
                    AddBufferEntry(
                      SalesCrMemoLine2,
                      -Quantity,
                      ItemLedgerEntry."Posting Date");
                    TotalQuantity := TotalQuantity - ValueEntry."Invoiced Quantity";
                end;
                FirstValueEntryNo := ValueEntry."Entry No." + 1;
            until (ValueEntry.Next() = 0) or (TotalQuantity = 0);
    end;

    procedure GenerateBufferFromShipment(SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine2: Record "Sales Cr.Memo Line";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        TotalQuantity: Decimal;
        Quantity: Decimal;
    begin
        TotalQuantity := 0;
        SalesCrMemoHeader.SetCurrentKey("Return Order No.");
        SalesCrMemoHeader.SetFilter("No.", '..%1', "Sales Cr.Memo Header"."No.");
        SalesCrMemoHeader.SetRange("Return Order No.", "Sales Cr.Memo Header"."Return Order No.");
        if SalesCrMemoHeader.Find('-') then
            repeat
                SalesCrMemoLine2.SetRange("Document No.", SalesCrMemoHeader."No.");
                SalesCrMemoLine2.SetRange("Line No.", SalesCrMemoLine."Line No.");
                SalesCrMemoLine2.SetRange(Type, SalesCrMemoLine.Type);
                SalesCrMemoLine2.SetRange("No.", SalesCrMemoLine."No.");
                SalesCrMemoLine2.SetRange("Unit of Measure Code", SalesCrMemoLine."Unit of Measure Code");
                if SalesCrMemoLine2.Find('-') then
                    repeat
                        TotalQuantity := TotalQuantity + SalesCrMemoLine2.Quantity;
                    until SalesCrMemoLine2.Next() = 0;
            until SalesCrMemoHeader.Next() = 0;

        ReturnReceiptLine.SetCurrentKey("Return Order No.", "Return Order Line No.");
        ReturnReceiptLine.SetRange("Return Order No.", "Sales Cr.Memo Header"."Return Order No.");
        ReturnReceiptLine.SetRange("Return Order Line No.", SalesCrMemoLine."Line No.");
        ReturnReceiptLine.SetRange("Line No.", SalesCrMemoLine."Line No.");
        ReturnReceiptLine.SetRange(Type, SalesCrMemoLine.Type);
        ReturnReceiptLine.SetRange("No.", SalesCrMemoLine."No.");
        ReturnReceiptLine.SetRange("Unit of Measure Code", SalesCrMemoLine."Unit of Measure Code");
        ReturnReceiptLine.SetFilter(Quantity, '<>%1', 0);

        if ReturnReceiptLine.Find('-') then
            repeat
                if "Sales Cr.Memo Header"."Get Return Receipt Used" then
                    CorrectShipment(ReturnReceiptLine);
                if Abs(ReturnReceiptLine.Quantity) <= Abs(TotalQuantity - SalesCrMemoLine.Quantity) then
                    TotalQuantity := TotalQuantity - ReturnReceiptLine.Quantity
                else begin
                    if Abs(ReturnReceiptLine.Quantity) > Abs(TotalQuantity) then
                        ReturnReceiptLine.Quantity := TotalQuantity;
                    Quantity :=
                      ReturnReceiptLine.Quantity - (TotalQuantity - SalesCrMemoLine.Quantity);

                    SalesCrMemoLine.Quantity := SalesCrMemoLine.Quantity - Quantity;
                    TotalQuantity := TotalQuantity - ReturnReceiptLine.Quantity;

                    if ReturnReceiptHeader.Get(ReturnReceiptLine."Document No.") then
                        AddBufferEntry(
                          SalesCrMemoLine,
                          -Quantity,
                          ReturnReceiptHeader."Posting Date");
                end;
            until (ReturnReceiptLine.Next() = 0) or (TotalQuantity = 0);
    end;

    procedure CorrectShipment(var ReturnReceiptLine: Record "Return Receipt Line")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetCurrentKey("Return Receipt No.", "Return Receipt Line No.");
        SalesCrMemoLine.SetRange("Return Receipt No.", ReturnReceiptLine."Document No.");
        SalesCrMemoLine.SetRange("Return Receipt Line No.", ReturnReceiptLine."Line No.");
        if SalesCrMemoLine.Find('-') then
            repeat
                ReturnReceiptLine.Quantity := ReturnReceiptLine.Quantity - SalesCrMemoLine.Quantity;
            until SalesCrMemoLine.Next() = 0;
    end;

    procedure AddBufferEntry(SalesCrMemoLine: Record "Sales Cr.Memo Line"; QtyOnShipment: Decimal; PostingDate: Date)
    begin
        TempSalesShipmentBuffer.SetRange("Document No.", SalesCrMemoLine."Document No.");
        TempSalesShipmentBuffer.SetRange("Line No.", SalesCrMemoLine."Line No.");
        TempSalesShipmentBuffer.SetRange("Posting Date", PostingDate);
        if TempSalesShipmentBuffer.Find('-') then begin
            TempSalesShipmentBuffer.Quantity := TempSalesShipmentBuffer.Quantity - QtyOnShipment;
            TempSalesShipmentBuffer.Modify();
            exit;
        end;

        TempSalesShipmentBuffer.Init();
        TempSalesShipmentBuffer."Document No." := SalesCrMemoLine."Document No.";
        TempSalesShipmentBuffer."Line No." := SalesCrMemoLine."Line No.";
        TempSalesShipmentBuffer."Entry No." := NextEntryNo;
        TempSalesShipmentBuffer.Type := SalesCrMemoLine.Type;
        TempSalesShipmentBuffer."No." := SalesCrMemoLine."No.";
        TempSalesShipmentBuffer.Quantity := -QtyOnShipment;
        TempSalesShipmentBuffer."Posting Date" := PostingDate;
        TempSalesShipmentBuffer.Insert();
        NextEntryNo := NextEntryNo + 1
    end;
}

