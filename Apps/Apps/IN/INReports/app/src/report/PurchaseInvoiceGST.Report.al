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
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using System.Utilities;

report 18011 "Purchase - Invoice GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/PurchaseInvoice.rdl';
    Caption = 'Purchase - Invoice';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

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
            column(InvDiscountAmountCaption; InvDiscountAmountCaptionLbl)
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

                    column(PaymentTermsDesc; PaymentTerms.Description)
                    {
                    }
                    column(ShipmentMethodDesc; ShipmentMethod.Description)
                    {
                    }
                    column(DocCaptionCopyText; DocCaption)
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
                    column(CompanyInfoEMail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
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
                    column(PayVendNo_PurchInvHeader; "Purch. Inv. Header"."Pay-to Vendor No.")
                    {
                    }
                    column(BuyfrVendNo_PurchInvHeaderCaption; "Purch. Inv. Header".FieldCaption("Buy-from Vendor No."))
                    {
                    }
                    column(BuyfrVendNo_PurchInvHeader; "Purch. Inv. Header"."Buy-from Vendor No.")
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
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(ShowInternalInfo; ShowInternalInfo)
                    {
                    }
                    column(VATBasDisc_PurchInvHeader; "Purch. Inv. Header"."VAT Base Discount %")
                    {
                    }
                    column(PricesInclVATtxt; PricesInclVATtxt)
                    {
                    }
                    column(CompanyInfoPhoneNoCaption; CompanyInfoPhoneNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoEMailCaption; CompanyInfoEMailCaptionLbl)
                    {
                    }
                    column(CompanyInfoHomePageCaption; CompanyInfoHomePageCaptionLbl)
                    {
                    }
                    column(CompanyInfoVATRegistrationNoCaption; CompanyInfoVATRegistrationNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoGiroNoCaption; CompanyInfoGiroNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoBankNameCaption; CompanyInfoBankNameCaptionLbl)
                    {
                    }
                    column(CompanyInfoBankAccountNoCaption; CompanyInfoBankAccountNoCaptionLbl)
                    {
                    }
                    column(PurchInvHeaderDueDateCaption; PurchInvHeaderDueDateCaptionLbl)
                    {
                    }
                    column(InvoiceNoCaption; InvoiceNoCaptionLbl)
                    {
                    }
                    column(PurchInvHeaderPostingDateCaption; PurchInvHeaderPostingDateCaptionLbl)
                    {
                    }
                    column(PageCaption; PageCaptionLbl)
                    {
                    }
                    column(PaymentTermsDescriptionCaption; PaymentTermsDescriptionCaptionLbl)
                    {
                    }
                    column(ShipmentMethodDescriptionCaption; ShipmentMethodDescriptionCaptionLbl)
                    {
                    }
                    column(VATAmountLineVATCaption; VATAmountLineVATCaptionLbl)
                    {
                    }
                    column(VATAmountLineVATBaseVTCCaption; VATAmountLineVATBaseVTCCaptionLbl)
                    {
                    }
                    column(VATAmtLineVATAmtVTCCaption; VATAmtLineVATAmtVTCCaptionLbl)
                    {
                    }
                    column(VATAmountSpecificationCaption; VATAmountSpecificationCaptionLbl)
                    {
                    }
                    column(VATAmtLineInvDiscBaseAmtVTCCaption; VATAmtLineInvDiscBaseAmtVTCCaptionLbl)
                    {
                    }
                    column(VATAmtLineLineAmtVTCCaption; VATAmtLineLineAmtVTCCaptionLbl)
                    {
                    }
                    column(VATAmountLineVATIdentifierCaption; VATAmountLineVATIdentifierCaptionLbl)
                    {
                    }
                    column(VATAmountLineVATBaseVTC1Caption; VATAmountLineVATBaseVTC1CaptionLbl)
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
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Purch. Inv. Header";
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
                    dataitem("Purch. Inv. Line"; "Purch. Inv. Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Purch. Inv. Header";
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
                        column(GSTCompAmount1; Abs(GSTCompAmount[1]))
                        {
                        }
                        column(GSTCompAmount2; Abs(GSTCompAmount[2]))
                        {
                        }
                        column(GSTCompAmount3; Abs(GSTCompAmount[3]))
                        {
                        }
                        column(GSTCompAmount4; Abs(GSTCompAmount[4]))
                        {
                        }
                        column(IsGSTApplicable; IsGSTApplicable)
                        {
                        }
                        column(KKCessAmount; KKCessAmount)
                        {
                        }
                        column(LineAmt_PurchInvLine; "Line Amount")
                        {
                            AutoFormatType = 1;
                        }
                        column(Desc_PurchInvLine; Description)
                        {
                        }
                        column(No_PurchInvLine; "Purch. Inv. Line"."No.")
                        {
                        }
                        column(No_PurchInvLineCaption; FieldCaption("No."))
                        {
                        }
                        column(Quantity_PurchInvLine; Quantity)
                        {
                        }
                        column(UOM_PurchInvLine; "Unit of Measure")
                        {
                        }
                        column(DirectUnitCost_PurchInvLine; "Direct Unit Cost")
                        {
                            AutoFormatType = 2;
                        }
                        column(LineDisc_PurchInvLine; "Line Discount %")
                        {
                        }
                        column(AllowInvDisc_PurchInvLine; "Allow Invoice Disc.")
                        {
                            IncludeCaption = false;
                        }
                        column(LineDiscAmt_PurchInvLine; "Line Discount Amount")
                        {
                        }
                        column(LineNo_PurchInvLine; "Purch. Inv. Line"."Line No.")
                        {
                        }
                        column(AllowVATDisctxt; AllowVATDisctxt)
                        {
                        }
                        column(PurchInLineTypeNo; PurchInLineTypeNo)
                        {
                        }
                        column(VATAmtText; VATAmountText)
                        {
                        }
                        column(SourceDocNo_PurchInvLine; 0)
                        {
                        }
                        column(InvDiscAmt_PurchInvLine; -"Inv. Discount Amount")
                        {
                            AutoFormatType = 1;
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(Amt_PurchInvLine; Amount)
                        {
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(AmtToVend_PurchInvLine; 0)
                        {
                            AutoFormatType = 1;
                        }
                        column(ExciseAmt_PurchInvLine; 0)
                        {
                            AutoFormatType = 1;
                        }
                        column(TaxAmt_PurchInvLine; 0)
                        {
                            AutoFormatType = 1;
                        }
                        column(OtherTaxesAmt; OtherTaxesAmount)
                        {
                            AutoFormatType = 1;
                        }
                        column(ChargesAmt; ChargesAmount)
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmtIncVATAmt_PurchInvLine; "Amount Including VAT" - Amount)
                        {
                            AutoFormatExpression = "Purch. Inv. Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmtText; VATAmountLine.VATAmountText())
                        {
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(TotalSubTotal; TotalSubTotal)
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInvDiscAmt; TotalInvoiceDiscountAmount)
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmt; TotalAmount)
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmtInclVAT; TotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalPaymentDiscOnVAT; TotalPaymentDiscountOnVAT)
                        {
                            AutoFormatType = 1;
                        }
                        column(DirectUnitCostCaption; DirectUnitCostCaptionLbl)
                        {
                        }
                        column(PurchInvLineLineDiscountCaption; PurchInvLineLineDiscountCaptionLbl)
                        {
                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(PurchInvLineExciseAmountCaption; PurchInvLineExciseAmountCaptionLbl)
                        {
                        }
                        column(PurchInvLineTaxAmountCaption; PurchInvLineTaxAmountCaptionLbl)
                        {
                        }
                        column(TotalTDSIncludingSHECESSCaption; TotalTDSIncludingSHECESSCaptionLbl)
                        {
                        }
                        column(OtherTaxesAmountCaption; OtherTaxesAmountCaptionLbl)
                        {
                        }
                        column(ChargesAmountCaption; ChargesAmountCaptionLbl)
                        {
                        }
                        column(LineAmtInvDiscountAmtAmtInclVATCaption; LineAmtInvDiscountAmtAmtInclVATCaptionLbl)
                        {
                        }
                        column(AllowInvDiscountCaption; AllowInvDiscountCaptionLbl)
                        {
                        }
                        column(Desc_PurchInvLineCaption; FieldCaption(Description))
                        {
                        }
                        column(Quantity_PurchInvLineCaption; FieldCaption(Quantity))
                        {
                        }
                        column(UOM_PurchInvLineCaption; FieldCaption("Unit of Measure"))
                        {
                        }
                        column(LineDiscAmt_PurchInvLineCaption; FieldCaption("Line Discount Amount"))
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
                        column(TDSAmt; Round(TDSAmt, 1))
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

                                DimSetEntry2.SetRange("Dimension Set ID", "Purch. Inv. Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            GetGSTAmount("Purch. Inv. Header", "Purch. Inv. Line");

                            GetTDSAmt("Purch. Inv. Header", "Purch. Inv. Line");

                            TotalSubTotal += "Line Amount";
                            TotalInvoiceDiscountAmount -= "Inv. Discount Amount";
                            TotalAmount += Amount;
                            TotalPaymentDiscountOnVAT += -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT");
                        end;

                        trigger OnPreDataItem()
                        var
                            PurchInvLine: Record "Purch. Inv. Line";
                            VATIdentifier: Code[10];
                        begin
                            MoreLines := FindLast();
                            while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0) and (Amount = 0) do
                                MoreLines := Next(-1) <> 0;

                            if not MoreLines then
                                CurrReport.Break();

                            SetRange("Line No.", 0, "Line No.");
                            VATAmountText := '';

                            PurchInvLine.SetRange("Document No.", "Purch. Inv. Header"."No.");
                            PurchInvLine.SetFilter(Type, '<>%1', 0);
                            if PurchInvLine.FindSet() then begin
                                VATAmountText := StrSubstNo(VatLbl, PurchInvLine."VAT %");
                                VATIdentifier := CopyStr(PurchInvLine."VAT Identifier", 1, 10);

                                repeat
                                    if (PurchInvLine."VAT Identifier" <> VATIdentifier) and (PurchInvLine.Quantity <> 0) then
                                        VATAmountText := VatAmtLbl;
                                until PurchInvLine.Next() = 0;
                            end;
                        end;
                    }
                    dataitem(VATCounter; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(VATAmtLineVATBase; VATAmountLine."VAT Base")
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmt; 0)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineLineAmt; 0)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscBaseAmt; 0)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscAmt; 0)
                        {
                        }
                        column(VATAmtLineVAT; 0)
                        {
                        }
                        column(VATAmtLineVATIdentifier; VATAmountLine."VAT Identifier")
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
                        column(VALVATAmtLCY; 0)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY; 0)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVAT1; 0)
                        {
                        }
                        column(VATAmtLineVATIdentifier1; VATAmountLine."VAT Identifier")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin

                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GLSetup."Print VAT specification in LCY") or
                               ("Purch. Inv. Header"."Currency Code" = '')
                            then
                                CurrReport.Break();

                            SetRange(Number, 1, VATAmountLine.Count);

                            if GLSetup."LCY Code" = '' then
                                VALSpecLCYHeader := VatAMtSpecLbl + LocCurLbl
                            else
                                VALSpecLCYHeader := VatAMtSpecLbl + Format(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency("Purch. Inv. Header"."Posting Date", "Purch. Inv. Header"."Currency Code", 1);
                            CalculatedExchRate := Round(
                                1 / "Purch. Inv. Header"."Currency Factor" * CurrExchRate."Exchange Rate Amount",
                                0.000001);
                            VALExchRate := StrSubstNo(ExchLbl, CalculatedExchRate, CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem(Total; Integer)
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                    }
                    dataitem(Total2; Integer)
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));


                        trigger OnPreDataItem()
                        begin
                            if "Purch. Inv. Header"."Buy-from Vendor No." = "Purch. Inv. Header"."Pay-to Vendor No." then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(Total3; Integer)
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
                    if Number > 1 then begin
                        OutputNo := OutputNo + 1;
                        CopyText := CopyLbl;
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
                    if not CurrReport.Preview then
                        PurchInvCountPrinted.Run("Purch. Inv. Header");
                end;

                trigger OnPreDataItem()
                begin
                    OutputNo := 1;
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                end;
            }

            trigger OnAfterGetRecord()
            var
                PurchInvLine: Record "Purch. Inv. Line";
            begin
                CompanyInfo.Get();
                IsGSTApplicable := CheckGSTDoc("Purch. Inv. Line");
                Vendor.Get("Buy-from Vendor No.");

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
                    OrderNoText := CopyStr(FieldCaption("Order No."), 1, 80);

                if "Purchaser Code" = '' then begin
                    Clear(SalesPurchPerson);
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
                    TotalInclVATText := StrSubstNo(TotalExlLbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(TotalIncLbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(TotalLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(TotalExlLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(TotalIncLbl, "Currency Code");
                end;

                FormatAddr.PurchInvPayTo(VendAddr, "Purch. Inv. Header");
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

                FormatAddr.PurchInvShipTo(ShipToAddr, "Purch. Inv. Header");

                if LogInteraction then
                    if not CurrReport.Preview then
                        SegManagement.LogDocument(14, "No.", 0, 0, Database::Vendor, "Buy-from Vendor No.", "Purchaser Code", '', "Posting Description", '');

                SupplementaryText := '';
                PurchInvLine.SetRange("Document No.", "No.");
                PurchInvLine.SetRange(Supplementary, true);
                if not PurchInvLine.IsEmpty() then
                    SupplementaryText := SupplemenInvLbl;

                PricesInclVATtxt := Format("Purch. Inv. Header"."Prices Including VAT");
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
                    field(NoOfCopies_; NoOfCopies)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of copies that need to be printed.';
                    }
                    field(ShowInternalInfo_; ShowInternalInfo)
                    {
                        Caption = 'Show Internal Information';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the lineInternal Information';
                    }
                    field(LogInteraction_; LogInteraction)
                    {
                        Caption = 'Log Interaction ';
                        Enabled = LogInteractionEnable;
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the Log Interaction for Archive Document';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := TRUE;
        end;

        trigger OnOpenPage()
        begin
            LogInteraction := SegManagement.FindInteractionTemplateCode(14) <> '';
            LogInteractionEnable := LogInteraction;
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
        VATAmountLine: Record "VAT Amount Line";
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        CurrExchRate: Record "Currency Exchange Rate";
        Vendor: Record Vendor;
        PurchInvCountPrinted: Codeunit "Purch. Inv.-Printed";
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        GSTCompAmount: array[20] of Decimal;
        GSTComponentCodeName: array[20] of Code[10];
        VendAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        PurchaserText: Text;
        VATNoText: Text;
        ReferenceText: Text;
        OrderNoText: Text;
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        MoreLines: Boolean;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[10];
        DimText: Text[120];
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        LogInteraction: Boolean;
        TDSAmt: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        CalculatedExchRate: Decimal;
        OutputNo: Integer;
        PricesInclVATtxt: Text[30];
        AllowVATDisctxt: Text[30];
        VATAmountText: Text[30];
        PurchInLineTypeNo: Integer;
        OtherTaxesAmount: Decimal;
        ChargesAmount: Decimal;
        SupplementaryText: Text[30];
        DocCaption: Text;
        LogInteractionEnable: Boolean;
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalInvoiceDiscountAmount: Decimal;
        TotalPaymentDiscountOnVAT: Decimal;
        KKCessAmount: Decimal;
        IsGSTApplicable: Boolean;
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        CessAmt: Decimal;
        PurchLbl: Label 'Purchase';
        TotalLbl: Label 'Total %1', Comment = '%1 = GLSetup."LCY Code';
        CopyLbl: Label 'COPY';
        PurchInvLbl: Label 'Purchase - Invoice %1', Comment = '%1 =  Invoice No.';
        VatAMtSpecLbl: Label 'VAT Amount Specification in ';
        LocCurLbl: Label 'Local Currency';
        ExchLbl: Label 'Exchange rate: %1/%2', Comment = '%1 =  CalculatedExchRate, %2 = CurrExchRate."Exchange Rate Amount")';
        PurchPrepLbl: Label 'Purchase - Prepayment Invoice %1', Comment = '%1 =  Invoice No.';
        VatLbl: Label '%1% VAT', Comment = '%1 = Vat %';
        VatAmtLbl: Label 'VAT Amount';
        TotalExlLbl: Label 'Total %1 Incl. Taxes', Comment = '%1 =  Total Amount';
        TotalIncLbl: Label 'Total %1 Excl. Taxes', Comment = '%1 = Total Amount';
        SupplemenInvLbl: Label 'Supplementary Invoice';
        CompanyInfoPhoneNoCaptionLbl: Label 'Phone No.';
        CompanyInfoEMailCaptionLbl: Label 'E-Mail';
        CompanyInfoHomePageCaptionLbl: Label 'Home Page';
        CompanyInfoVATRegistrationNoCaptionLbl: Label 'VAT Reg. No.';
        CompanyInfoGiroNoCaptionLbl: Label 'Giro No.';
        CompanyInfoBankNameCaptionLbl: Label 'Bank';
        CompanyInfoBankAccountNoCaptionLbl: Label 'Account No.';
        PurchInvHeaderDueDateCaptionLbl: Label 'Due Date';
        InvoiceNoCaptionLbl: Label 'Invoice No.';
        PurchInvHeaderPostingDateCaptionLbl: Label 'Posting Date';
        PageCaptionLbl: Label 'Page';
        PaymentTermsDescriptionCaptionLbl: Label 'Payment Terms';
        ShipmentMethodDescriptionCaptionLbl: Label 'Shipment Method';
        DocumentDateCaptionLbl: Label 'Document Date';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        DirectUnitCostCaptionLbl: Label 'Direct Unit Cost';
        PurchInvLineLineDiscountCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        SubtotalCaptionLbl: Label 'Total Amount';
        PurchInvLineExciseAmountCaptionLbl: Label 'Excise Amount';
        PurchInvLineTaxAmountCaptionLbl: Label 'Tax Amount';
        TotalTDSIncludingSHECESSCaptionLbl: Label 'Total TDS Amount';
        OtherTaxesAmountCaptionLbl: Label 'Other Taxes Amount';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        CessLbl: Label 'CESS';
        ChargesAmountCaptionLbl: Label 'Charges Amount';
        LineAmtInvDiscountAmtAmtInclVATCaptionLbl: Label 'Payment Discount on VAT';
        AllowInvDiscountCaptionLbl: Label 'Allow Invoice Discount';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATAmountLineVATCaptionLbl: Label 'VAT %';
        VATAmountLineVATBaseVTCCaptionLbl: Label 'VAT Base';
        VATAmtLineVATAmtVTCCaptionLbl: Label 'VAT Amount';
        VATAmountSpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATAmtLineInvDiscBaseAmtVTCCaptionLbl: Label 'Inv. Disc. Base Amount';
        VATAmtLineLineAmtVTCCaptionLbl: Label 'Line Amount';
        VATAmountLineVATIdentifierCaptionLbl: Label 'VAT Identifier';
        VATAmountLineVATBaseVTC1CaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        InvDiscountAmountCaptionLbl: Label 'Invoice Discount Amount';
        CompanyRegistrationLbl: Label 'Company Registration No.';
        VendorRegistrationLbl: Label 'Vendor GST Reg No.';

    procedure InitializeRequest(NewNoOfCopies: Integer; NewShowInternalInfo: Boolean; NewLogInteraction: Boolean)
    begin
        NoOfCopies := NewNoOfCopies;
        ShowInternalInfo := NewShowInternalInfo;
        LogInteraction := NewLogInteraction;
    end;

    local procedure DocumentCaption(): Text[250]
    begin
        if "Purch. Inv. Header"."Prepayment Invoice" then
            DocCaption := StrSubstNo(PurchPrepLbl, CopyText)
        else
            DocCaption := StrSubstNo(PurchInvLbl, CopyText);
    end;

    local procedure CheckGSTDoc(PurchInvLine: Record "Purch. Inv. Line"): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", PurchInvLine.RecordId);
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

    local procedure GetGSTAmount(PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        Clear(IGSTAmt);
        Clear(CGSTAmt);
        Clear(SGSTAmt);
        Clear(CessAmt);
        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetRange("Document No.", PurchInvLine."Document No.");
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if (DetailedGSTLedgerEntry."GST Component Code" = CGSTLbl) And (PurchInvHeader."Currency Code" <> '') then
                    CGSTAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * PurchInvHeader."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = CGSTLbl) then
                        CGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                if (DetailedGSTLedgerEntry."GST Component Code" = SGSTLbl) And (PurchInvHeader."Currency Code" <> '') then
                    SGSTAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * PurchInvHeader."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = SGSTLbl) then
                        SGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                if (DetailedGSTLedgerEntry."GST Component Code" = IGSTLbl) And (PurchInvHeader."Currency Code" <> '') then
                    IGSTAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * PurchInvHeader."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = IGSTLbl) then
                        IGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");
                if (DetailedGSTLedgerEntry."GST Component Code" = CessLbl) And (PurchInvHeader."Currency Code" <> '') then
                    CessAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * PurchInvHeader."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = CessLbl) then
                        CessAmt += Abs(DetailedGSTLedgerEntry."GST Amount");
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure GetTDSAmt(PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line")
    var
        TDSEntry: Record "TDS Entry";
    begin
        Clear(TDSAmt);
        TDSEntry.Reset();
        TDSEntry.SetRange("Document No.", PurchInvLine."Document No.");
        if TDSEntry.FindSet() then
            repeat
                if "Purch. Inv. Header"."Currency Code" <> '' then
                    TDSAmt += (PurchInvHeader."Currency Factor" * TDSEntry."Total TDS Including SHE CESS")
                else
                    TDSAmt += TDSEntry."Total TDS Including SHE CESS";
            until TDSEntry.Next() = 0;
    end;
}
