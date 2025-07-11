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
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Setup;
using System.Utilities;

report 18015 "Sales - Credit Memo GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/SalesCreditMemo.rdl';
    Caption = 'Sales - Credit Memo';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

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
            column(HomePageCaption; HomePageCaptionLbl)
            {
            }
            column(EmailCaption; EmailCaptionLbl)
            {
            }
            column(DocumentDateCaption; DocumentDateCaptionLbl)
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

                    column(DocCaptionCopyText; DocCaption)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo3Picture; CompanyInfo3.Picture)
                    {
                    }
                    column(CompanyRegistrationLbl; CompanyRegistrationLbl)
                    {
                    }
                    column(CompanyInfo_GST_RegistrationNo; CompanyInformation."GST Registration No.")
                    {
                    }
                    column(CustomerRegistrationLbl; CustomerRegistrationLbl)
                    {
                    }
                    column(Customer_GST_RegistrationNo; Customer."GST Registration No.")
                    {
                    }
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
                    column(CompanyInfoPhoneNo; CompanyInformation."Phone No.")
                    {
                    }
                    column(CustAddr6; CustAddr[6])
                    {
                    }
                    column(CompanyInfoEmail; CompanyInformation."E-Mail")
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInformation."Home Page")
                    {
                    }
                    column(CompanyInfoVATRegNo; CompanyInformation."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoGiroNo; CompanyInformation."Giro No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyInformation."Bank Name")
                    {
                    }
                    column(CompanyInfoBankAccNo; CompanyInformation."Bank Account No.")
                    {
                    }
                    column(BilltoCustNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Bill-to Customer No.")
                    {
                    }
                    column(PostDate_SalesCrMemoHeader; Format("Sales Cr.Memo Header"."Posting Date", 0, 4))
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
                    column(PricIncVAT_SalesCrMemoHeader; "Sales Cr.Memo Header"."Prices Including VAT")
                    {
                    }
                    column(ReturnOrderNoText; ReturnOrderNoText)
                    {
                    }
                    column(RetOrderNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Return Order No.")
                    {
                    }
                    column(SupplementaryText; SupplementaryText)
                    {
                    }
                    column(PageCaption; PageCaptionCapLbl)
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PricInclVAT1_SalesCrMemoHeader; Format("Sales Cr.Memo Header"."Prices Including VAT"))
                    {
                    }
                    column(VATBaseDiscPct_SalesCrMemoHeader; "Sales Cr.Memo Header"."VAT Base Discount %")
                    {
                    }
                    column(PhoneNoCaption; PhoneNoCaptionLbl)
                    {
                    }
                    column(RegNoCaption; RegNoCaptionLbl)
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
                    column(CrMemoNoCaption; CrMemoNoCaptionLbl)
                    {
                    }
                    column(PostingDateCaption; PostingDateCaptionLbl)
                    {
                    }
                    column(BilltoCustNo_SalesCrMemoHeaderCaption; "Sales Cr.Memo Header".FieldCaption("Bill-to Customer No."))
                    {
                    }
                    column(PricIncVAT_SalesCrMemoHeaderCaption; "Sales Cr.Memo Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Sales Cr.Memo Header";
                        DataItemTableView = sorting(Number)
                                            where(Number = filter(1 ..));

                        column(DimText; DimText)
                        {
                        }
                        column(Number_IntegerLine; Number)
                        {
                        }
                        column(HdrDimCaption; HdrDimCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            DimText := GetDimensionText(DimSetEntry1, Number, Continue);
                            if not Continue then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Sales Cr.Memo Header";
                        DataItemTableView = sorting("Document No.", "Line No.");

                        column(LineAmt_SalesCrMemoLine; "Line Amount")
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
                        column(DiscAmt_SalesCrMemoLineLine; "Line Discount Amount")
                        {
                        }
                        column(PostedReceiptDate; Format(PostedReceiptDate))
                        {
                        }
                        column(Type_SalesCrMemoLine; Format(Type))
                        {
                        }
                        column(NNCTotalLineAmt; NNC_TotalLineAmount)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(NNCTotalAmtInclVat; NNC_TotalAmountInclVat)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(NNCTotalInvDiscAmt; NNC_TotalInvDiscAmount)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(NNCTotalAmt; NNC_TotalAmount)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(SourceDoctType; 0)
                        {
                        }
                        column(SourceDocNo_SalesCrMemoLine; 0)
                        {
                        }
                        column(Supplementary_SalesCrMemoLine; 0)
                        {
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(Amt_SalesCrMemoLine; Amount)
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(ChargesAmount; ChargesAmount)
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(OtherTaxesAmount; OtherTaxesAmount)
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(NNCTotalAmtToCust; NNC_TotalAmountToCustomer)
                        {
                        }
                        column(NNCTotalExciseAmt; NNC_TotalExciseAmount)
                        {
                        }
                        column(NNCTotalTaxAmt; NNC_TotalTaxAmount)
                        {
                        }
                        column(NNCTotalServTaxAmt; NNC_TotalServiceTaxAmount)
                        {
                        }
                        column(NNCTSTaxeCessAmt; NNC_TSTaxeCessAmount)
                        {
                        }
                        column(NNCTSTSHECessAmt; NNC_TSTSHECessAmount)
                        {
                        }
                        column(NNCttdstcsishecess; NNC_TTDSTCSISHECESS)
                        {
                        }
                        column(AmountIncludingVATAmt1; "Amount Including VAT" - Amount)
                        {
                            AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmtText1; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(TotalExclVATText1; TotalExclVATText)
                        {
                        }
                        column(LineNo_SalesCrMemoLine; "Line No.")
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
                        column(DiscAmtCaption; DiscAmtCaptionLbl)
                        {
                        }
                        column(PostedReceiptDateCaption; PostedReceiptDateCaptionLbl)
                        {
                        }
                        column(InvDiscAmtCaption; InvDiscAmtCaptionLbl)
                        {
                        }
                        column(SubTotalCaption; SubTotalCaptionLbl)
                        {
                        }
                        column(ExciseAmtCaption; ExciseAmtCaptionLbl)
                        {
                        }
                        column(TaxAmtCaption; TaxAmtCaptionLbl)
                        {
                        }
                        column(ServTaxAmtCaption; ServTaxAmtCaptionLbl)
                        {
                        }
                        column(ChargesAmtCaption; ChargesAmtCaptionLbl)
                        {
                        }
                        column(OtherTaxesAmtCaption; OtherTaxesAmtCaptionLbl)
                        {
                        }
                        column(ServiceTaxeCessAmtCaption; ServiceTaxeCessAmtCaptionLbl)
                        {
                        }
                        column(TotalTDSIncludingeCessCaption; TotalTDSIncludingeCessCaptionLbl)
                        {
                        }
                        column(TCSAmountCaption; TCSAmountCaptionLbl)
                        {
                        }
                        column(ServiceTaxSHECessAmtCaption; ServiceTaxSHECessAmtCaptionLbl)
                        {
                        }
                        column(PaymentDiscOnVATCaption; PaymentDiscOnVATCaptionLbl)
                        {
                        }
                        column(Desc_SalesCrMemoLineCaption; FieldCaption(Description))
                        {
                        }
                        column(No_SalesCrMemoLineCaption; FieldCaption("No."))
                        {
                        }
                        column(Qty_SalesCrMemoLineCaption; FieldCaption(Quantity))
                        {
                        }
                        column(UOM_SalesCrMemoLineCaption; FieldCaption("Unit of Measure"))
                        {
                        }
                        column(NNCTotalServTaxSBCAmt; NNC_TotalServiceTaxSBCAmount)
                        {
                        }
                        column(ServTaxSBCAmtCaption; ServTaxSBCAmtCaptionLbl)
                        {
                        }
                        column(NNCTotalKKCessAmt; NNC_TotalKKCessAmount)
                        {
                        }
                        column(KKCessAmtCaption; KKCessAmtCaptionLbl)
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
                        column(TCSAmt; TCSAmt)
                        {
                        }
                        dataitem("Sales Shipment Buffer"; Integer)
                        {
                            DataItemTableView = sorting(Number);

                            column(SalesShipmentBufferQuantity; TempSalesShipmentBuffer.Quantity)
                            {
                                DecimalPlaces = 0 : 5;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then
                                    TempSalesShipmentBuffer.FindFirst()
                                else
                                    TempSalesShipmentBuffer.Next();
                            end;

                            trigger OnPreDataItem()
                            begin
                                SetRange(Number, 1, TempSalesShipmentBuffer.Count);
                            end;
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText1; DimText)
                            {
                            }
                            column(LineDimCaption; LineDimCaptionLbl)
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
                                DimSetEntry2.SetRange("Dimension Set ID", "Sales Cr.Memo Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempSalesShipmentBuffer.DeleteAll();
                            PostedReceiptDate := 0D;
                            if Quantity <> 0 then
                                PostedReceiptDate := FindPostedShipmentDate();

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

                            GetSalesCrMemoGSTAmount("Sales Cr.Memo Header", "Sales Cr.Memo Line");

                            GetTCSAmt("Sales Cr.Memo Header", "Sales Cr.Memo Line");

                            NNC_TotalLineAmount += "Line Amount";
                            NNC_TotalAmountInclVat += "Amount Including VAT";
                            NNC_TotalInvDiscAmount += "Inv. Discount Amount";
                            NNC_TotalAmount += Amount;
                            NNC_TotalAmountToCustomer += "Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CessAmt;
                            NNC_TotalTaxAmount += 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempVATAmountLine.DeleteAll();
                            TempSalesShipmentBuffer.Reset();
                            TempSalesShipmentBuffer.DeleteAll();

                            FirstValueEntryNo := 0;
                            MoreLines := FindLast();
                            while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0) and (Amount = 0) do
                                MoreLines := Next(-1) <> 0;

                            if not MoreLines then
                                CurrReport.Break();

                            SetRange("Line No.", 0, "Line No.");
                        end;
                    }
                    dataitem(VATCounter; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(VATAmtLineVATBase; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineLineAmt; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscBaseAmt; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscAmt; TempVATAmountLine."Invoice Discount Amount")
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
                        column(VATAmtCaption; VATAmtCaptionLbl)
                        {
                        }
                        column(VATAmtSpecCaption; VATAmtSpecCaptionLbl)
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
                        column(InvDiscAmt1Caption; InvDiscAmt1CaptionLbl)
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
                    dataitem(VATCounterLCY; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(VALSpecLCYHeader; VALSpecLCYHeader)
                        {
                        }
                        column(VALExchRate; VALExchRate)
                        {
                        }
                        column(VALVATAmountLCY; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVAT1; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmtLineVATIdentifier1; TempVATAmountLine."VAT Identifier")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                            VALVATBaseLCY := TempVATAmountLine.GetBaseLCY(
                                "Sales Cr.Memo Header"."Posting Date",
                                "Sales Cr.Memo Header"."Currency Code",
                                "Sales Cr.Memo Header"."Currency Factor");
                            VALVATAmountLCY := TempVATAmountLine.GetAmountLCY(
                                "Sales Cr.Memo Header"."Posting Date",
                                "Sales Cr.Memo Header"."Currency Code",
                                "Sales Cr.Memo Header"."Currency Factor");
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GeneralLedgerSetup."Print VAT specification in LCY") or
                               ("Sales Cr.Memo Header"."Currency Code" = '')
                            then
                                CurrReport.Break();

                            SetRange(Number, 1, TempVATAmountLine.Count);
                            if GeneralLedgerSetup."LCY Code" = '' then
                                VALSpecLCYHeader := VatAmtLbl + LocalCurrLbl
                            else
                                VALSpecLCYHeader := VatAmtLbl + Format(GeneralLedgerSetup."LCY Code");

                            CurrExchRate.FindCurrency("Sales Cr.Memo Header"."Posting Date", "Sales Cr.Memo Header"."Currency Code", 1);
                            CalculatedExchRate := Round(1 / "Sales Cr.Memo Header"."Currency Factor" * CurrExchRate."Exchange Rate Amount", 0.000001);
                            VALExchRate := StrSubstNo(ExchangeRateLbl, CalculatedExchRate, CurrExchRate."Exchange Rate Amount");
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
                        column(ShiptoAddrCaption; ShiptoAddrCaptionLbl)
                        {
                        }
                        column(SelltoCustNo_SalesCrMemoHeaderCaption; "Sales Cr.Memo Header".FieldCaption("Sell-to Customer No."))
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
                begin
                    if Number > 1 then begin
                        CopyText := CopyLbl;
                        OutputNo += 1;
                    end;

                    NNC_TotalLineAmount := 0;
                    NNC_TotalAmountInclVat := 0;
                    NNC_TotalInvDiscAmount := 0;
                    NNC_TotalAmount := 0;
                    NNC_TotalAmountToCustomer := 0;
                    NNC_TotalExciseAmount := 0;
                    NNC_TotalTaxAmount := 0;
                    NNC_TotalServiceTaxAmount := 0;
                    NNC_TSTaxeCessAmount := 0;
                    NNC_TSTSHECessAmount := 0;
                    NNC_TTDSTCSISHECESS := 0;
                    CGSTAmt := 0;
                    SGSTAmt := 0;
                    IGSTAmt := 0;
                    CessAmt := 0;
                    TCSAmt := 0;
                    ChargesAmount := 0;
                    OtherTaxesAmount := 0;
                    NNC_TotalServiceTaxSBCAmount := 0;
                    NNC_TotalKKCessAmount := 0;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then
                        SalesCrMemoCountPrinted.Run("Sales Cr.Memo Header");
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
                SalesCrMemoLine: Record "Sales Cr.Memo Line";
            begin
                IsGSTApplicable := CheckGSTDoc(SalesCrMemoLine);
                Customer.Get("Bill-to Customer No.");
                CompanyInformation.Get();

                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddress.RespCenter(CompanyAddr, RespCenter);
                    CompanyInformation."Phone No." := RespCenter."Phone No.";
                    CompanyInformation."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddress.Company(CompanyAddr, CompanyInformation);

                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

                if "Return Order No." = '' then
                    ReturnOrderNoText := ''
                else
                    ReturnOrderNoText := CopyStr(FieldCaption("Return Order No."), 1, 80);

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
                    GeneralLedgerSetup.TestField("LCY Code");
                    TotalText := StrSubstNo(TotalLbl, GeneralLedgerSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(TotalIncTaxLbl, GeneralLedgerSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(TotalExclTaxLbl, GeneralLedgerSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(TotalLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(TotalIncTaxLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(TotalExclTaxLbl, "Currency Code");
                end;

                FormatAddress.SalesCrMemoBillTo(CustAddr, "Sales Cr.Memo Header");
                if "Applies-to Doc. No." = '' then
                    AppliedToText := ''
                else
                    AppliedToText := StrSubstNo(AppliestoLbl, "Applies-to Doc. Type", "Applies-to Doc. No.");

                ShowShippingAddr := "Sell-to Customer No." <> "Bill-to Customer No.";
                for i := 1 TO ArrayLen(ShipToAddr) do
                    if ShipToAddr[i] <> CustAddr[i] then
                        ShowShippingAddr := true;

                if LogIntaction then
                    if not CurrReport.Preview then
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              6, "No.", 0, 0, Database::Contact, "Bill-to Contact No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '')
                        else
                            SegManagement.LogDocument(
                              6, "No.", 0, 0, Database::Customer, "Sell-to Customer No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '');
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
                    field(NoOfCopies; NoOfCopy)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of copies that need to be printed.';
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

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            LogIntaction := SegManagement.FindInteractionTemplateCode(6) <> '';
            LogInteractionEnable := LogIntaction;
        end;
    }


    trigger OnInitReport()
    begin
        GeneralLedgerSetup.Get();
        SalesSetup.Get();
        case SalesSetup."Logo Position on Documents" of
            SalesSetup."Logo Position on Documents"::"No Logo":
                ;
            SalesSetup."Logo Position on Documents"::Left:
                begin
                    CompanyInfo1.Get();
                    CompanyInfo1.CalcFields(Picture);
                end;
            SalesSetup."Logo Position on Documents"::Center:
                begin
                    CompanyInfo2.Get();
                    CompanyInfo2.CalcFields(Picture);
                end;
            SalesSetup."Logo Position on Documents"::Right:
                begin
                    CompanyInfo3.Get();
                    CompanyInfo3.CalcFields(Picture);
                end;
        end;
    end;

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInformation: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        Customer: Record Customer;
        SalesSetup: Record "Sales & Receivables Setup";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary;
        CurrExchRate: Record "Currency Exchange Rate";
        RespCenter: Record "Responsibility Center";
        SalesCrMemoCountPrinted: Codeunit "Sales Cr. Memo-Printed";
        FormatAddress: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        CustAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        ReturnOrderNoText: Text[80];
        SalesPersonText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        AppliedToText: Text;
        DocCaption: Text;
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
        Continue: Boolean;
        LogIntaction: Boolean;
        FirstValueEntryNo: Integer;
        PostedReceiptDate: Date;
        NextEntryNo: Integer;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        CalculatedExchRate: Decimal;
        OutputNo: Integer;
        NNC_TotalLineAmount: Decimal;
        NNC_TotalAmountInclVat: Decimal;
        NNC_TotalInvDiscAmount: Decimal;
        NNC_TotalAmount: Decimal;
        ChargesAmount: Decimal;
        OtherTaxesAmount: Decimal;
        SupplementaryText: Text[30];
        NNC_TotalAmountToCustomer: Decimal;
        NNC_TotalExciseAmount: Decimal;
        NNC_TotalTaxAmount: Decimal;
        NNC_TotalServiceTaxAmount: Decimal;
        NNC_TSTaxeCessAmount: Decimal;
        NNC_TSTSHECessAmount: Decimal;
        NNC_TTDSTCSISHECESS: Decimal;
        [InDataSet]
        LogInteractionEnable: Boolean;
        NNC_TotalServiceTaxSBCAmount: Decimal;
        NNC_TotalKKCessAmount: Decimal;
        IsGSTApplicable: Boolean;
        GSTCompAmount: array[20] of Decimal;
        GSTComponentCodeName: array[20] of Code[10];
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        TCSAmt: Decimal;
        CessAmt: Decimal;
        SalesPersLbl: Label 'Salesperson';
        TotalLbl: Label 'Total %1', Comment = '%1 Amt';
        AppliestoLbl: Label '(Applies to %1 %2)', Comment = '%1 Doc Type %2 Doc No.';
        CopyLbl: Label 'COPY';
        SalesCreditLbl: Label 'Sales - Credit Memo %1', Comment = '%1 Caption';
        PageCaptionCapLbl: Label 'Page %1', Comment = '%1 Caption';
        VatAmtLbl: Label 'VAT Amount Specification in ';
        LocalCurrLbl: Label 'Local Currency';
        ExchangeRateLbl: Label 'Exchange rate: %1/%2', Comment = '%1 Calculation %2 Rate Amt';
        SalesPrepCredLbl: Label 'Sales - Prepmt. Credit Memo %1', Comment = '%1 Caption';
        TotalIncTaxLbl: Label 'Total %1 Incl. Taxes', Comment = '%1 Amt';
        TotalExclTaxLbl: Label 'Total %1 Excl. Taxes', Comment = '%1 Amt';
        PhoneNoCaptionLbl: Label 'Phone No.';
        RegNoCaptionLbl: Label 'VAT Registration No.';
        GiroNoCaptionLbl: Label 'Giro No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccNoCaptionLbl: Label 'Account No.';
        CrMemoNoCaptionLbl: Label 'Credit Memo No.';
        PostingDateCaptionLbl: Label 'Posting Date';
        HdrDimCaptionLbl: Label 'Header Dimensions';
        UnitPriceCaptionLbl: Label 'Unit Price';
        DiscPercentCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        DiscAmtCaptionLbl: Label 'Line Discount Amount';
        PostedReceiptDateCaptionLbl: Label 'Posted Return Receipt Date';
        InvDiscAmtCaptionLbl: Label 'Invoice Discount Amount';
        SubTotalCaptionLbl: Label 'Subtotal';
        ExciseAmtCaptionLbl: Label 'Excise Amount';
        TaxAmtCaptionLbl: Label 'Tax Amount';
        ServTaxAmtCaptionLbl: Label 'Service Tax Amount';
        ChargesAmtCaptionLbl: Label 'Charges Amount';
        OtherTaxesAmtCaptionLbl: Label 'Other Taxes Amount';
        ServiceTaxeCessAmtCaptionLbl: Label 'Service Tax eCess Amount';
        TotalTDSIncludingeCessCaptionLbl: Label 'Total TDS Including eCess';
        TCSAmountCaptionLbl: Label 'TCS Amount';
        ServiceTaxSHECessAmtCaptionLbl: Label 'Service Tax SHE Cess Amount';
        PaymentDiscOnVATCaptionLbl: Label 'Payment Discount on VAT';
        LineDimCaptionLbl: Label 'Line Dimensions';
        VATPercentCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmtCaptionLbl: Label 'VAT Amount';
        VATAmtSpecCaptionLbl: Label 'VAT Amount Specification';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        LineAmtCaptionLbl: Label 'Line Amount';
        InvDiscAmt1CaptionLbl: Label 'Invoice Discount Amount';
        TotalCaptionLbl: Label 'Total';
        ShiptoAddrCaptionLbl: Label 'Ship-to Address';
        HomePageCaptionLbl: Label 'Home Page';
        EmailCaptionLbl: Label 'E-Mail';
        DocumentDateCaptionLbl: Label 'Document Date';
        ServTaxSBCAmtCaptionLbl: Label 'SBC Amount';
        KKCessAmtCaptionLbl: Label 'KK Cess Amount';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        CessLbl: Label 'CESS';
        CompanyRegistrationLbl: Label 'Company Registration No.';
        CustomerRegistrationLbl: Label 'Customer GST Reg No.';

    procedure InitLogInteraction()
    begin
        LogIntaction := SegManagement.FindInteractionTemplateCode(6) <> '';
    end;

    procedure FindPostedShipmentDate(): Date
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        TempSalesShipmentBuffer2: Record "Sales Shipment Buffer" temporary;
    begin
        NextEntryNo := 1;
        if "Sales Cr.Memo Line"."Return Receipt No." <> '' then
            if ReturnReceiptHeader.Get("Sales Cr.Memo Line"."Return Receipt No.") then
                exit(ReturnReceiptHeader."Posting Date");

        if "Sales Cr.Memo Header"."Return Order No." = '' then
            exit("Sales Cr.Memo Header"."Posting Date");

        case "Sales Cr.Memo Line".Type of
            "Sales Cr.Memo Line".Type::Item:
                GenerateBufferFromValueEntry("Sales Cr.Memo Line");
            "Sales Cr.Memo Line".Type::"G/L Account",
            "Sales Cr.Memo Line".Type::Resource,
            "Sales Cr.Memo Line".Type::"Charge (Item)",
            "Sales Cr.Memo Line".Type::"Fixed Asset":
                GenerateBufferFromShipment("Sales Cr.Memo Line");
            "Sales Cr.Memo Line".Type::" ":
                exit(0D);
        end;

        TempSalesShipmentBuffer2.Reset();
        TempSalesShipmentBuffer2.SetRange("Document No.", "Sales Cr.Memo Line"."Document No.");
        TempSalesShipmentBuffer2.SetRange("Line No.", "Sales Cr.Memo Line"."Line No.");

        if TempSalesShipmentBuffer2.FindSet() then begin
            TempSalesShipmentBuffer2 := TempSalesShipmentBuffer2;
            if TempSalesShipmentBuffer2.Next() = 0 then begin
                TempSalesShipmentBuffer2.Get(
                    TempSalesShipmentBuffer2."Document No.",
                    TempSalesShipmentBuffer2."Line No.",
                    TempSalesShipmentBuffer2."Entry No.");
                TempSalesShipmentBuffer2.Delete();

                exit(TempSalesShipmentBuffer2."Posting Date");
            end;

            TempSalesShipmentBuffer2.CalcSums(Quantity);
            if TempSalesShipmentBuffer2.Quantity <> "Sales Cr.Memo Line".Quantity then begin
                TempSalesShipmentBuffer2.DeleteAll();
                exit("Sales Cr.Memo Header"."Posting Date");
            end;
        end else
            exit("Sales Cr.Memo Header"."Posting Date");
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
        if ValueEntry.FindSet() then
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
        if SalesCrMemoHeader.FindSet() then
            repeat
                SalesCrMemoLine2.SetRange("Document No.", SalesCrMemoHeader."No.");
                SalesCrMemoLine2.SetRange("Line No.", SalesCrMemoLine."Line No.");
                SalesCrMemoLine2.SetRange(Type, SalesCrMemoLine.Type);
                SalesCrMemoLine2.SetRange("No.", SalesCrMemoLine."No.");
                SalesCrMemoLine2.SetRange("Unit of Measure Code", SalesCrMemoLine."Unit of Measure Code");
                if SalesCrMemoLine2.FindSet() then
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

        if ReturnReceiptLine.FindFirst() then
            repeat
                if "Sales Cr.Memo Header"."Get Return Receipt Used" then
                    CorrectShipment(ReturnReceiptLine);

                if Abs(ReturnReceiptLine.Quantity) <= Abs(TotalQuantity - SalesCrMemoLine.Quantity) then
                    TotalQuantity := TotalQuantity - ReturnReceiptLine.Quantity
                else begin
                    if Abs(ReturnReceiptLine.Quantity) > Abs(TotalQuantity) then
                        ReturnReceiptLine.Quantity := TotalQuantity;

                    Quantity := ReturnReceiptLine.Quantity - (TotalQuantity - SalesCrMemoLine.Quantity);

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
        if SalesCrMemoLine.FindSet() then
            repeat
                ReturnReceiptLine.Quantity := ReturnReceiptLine.Quantity - SalesCrMemoLine.Quantity;
            until SalesCrMemoLine.Next() = 0;
    end;

    procedure AddBufferEntry(
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        QtyOnShipment: Decimal;
        PostingDate: Date)
    begin
        TempSalesShipmentBuffer.SetRange("Document No.", SalesCrMemoLine."Document No.");
        TempSalesShipmentBuffer.SetRange("Line No.", SalesCrMemoLine."Line No.");
        TempSalesShipmentBuffer.SetRange("Posting Date", PostingDate);
        if TempSalesShipmentBuffer.FindFirst() then begin
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

    procedure InitializeRequest(NewNoOfCopies: Integer; NewShowInternalInfo: Boolean; NewLogInteraction: Boolean)
    begin
        NoOfCopy := NewNoOfCopies;
        LogIntaction := NewLogInteraction;
    end;

    local procedure DocumentCaption(): Text[250]
    begin
        if "Sales Cr.Memo Header"."Prepayment Credit Memo" then
            DocCaption := StrSubstNo(SalesPrepCredLbl, CopyText)
        else
            DocCaption := StrSubstNo(SalesCreditLbl, CopyText);
    end;

    local procedure CheckGSTDoc(SalesCrMemoLine: Record "Sales Cr.Memo Line"): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", SalesCrMemoLine.RecordId);
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

    local procedure GetSalesCrMemoGSTAmount(SalesCrMemoHdr: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        Clear(IGSTAmt);
        Clear(CGSTAmt);
        Clear(SGSTAmt);
        Clear(CessAmt);
        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetRange("Document No.", SalesCrMemoLine."Document No.");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if (DetailedGSTLedgerEntry."GST Component Code" = CGSTLbl) And (SalesCrMemoHdr."Currency Code" <> '') then
                    CGSTAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * SalesCrMemoHdr."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = CGSTLbl) then
                        CGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                if (DetailedGSTLedgerEntry."GST Component Code" = SGSTLbl) And (SalesCrMemoHdr."Currency Code" <> '') then
                    SGSTAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * SalesCrMemoHdr."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = SGSTLbl) then
                        SGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                if (DetailedGSTLedgerEntry."GST Component Code" = IGSTLbl) And (SalesCrMemoHdr."Currency Code" <> '') then
                    IGSTAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * SalesCrMemoHdr."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = IGSTLbl) then
                        IGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                if (DetailedGSTLedgerEntry."GST Component Code" = CessLbl) And (SalesCrMemoHdr."Currency Code" <> '') then
                    CessAmt += Round((Abs(DetailedGSTLedgerEntry."GST Amount") * SalesCrMemoHdr."Currency Factor"), GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
                else
                    if (DetailedGSTLedgerEntry."GST Component Code" = CessLbl) then
                        CessAmt += Abs(DetailedGSTLedgerEntry."GST Amount");
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure GetTCSAmt(SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSAmt := 0;
        TCSEntry.Reset();
        TCSEntry.SetRange("Document No.", SalesCrMemoLine."Document No.");
        if TCSEntry.FindSet() then
            repeat
                if SalesCrMemoHeader."Currency Code" <> '' then
                    TcsAmt += SalesCrMemoHeader."Currency Factor" * TCSEntry."Total TCS Including SHE CESS"
                else
                    TcsAmt += TCSEntry."Total TCS Including SHE CESS";

                TcsAmt := Round(TcsAmt, 1);
            until TCSEntry.Next() = 0;
    end;
}
