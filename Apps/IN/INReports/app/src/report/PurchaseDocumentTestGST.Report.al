// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.CRM.Campaign;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Setup;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Document;
using System.Security.User;
using System.Utilities;

report 18022 "Purchase Document - Test GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/PurchaseDocumentTest.rdl';
    Caption = 'Purchase Document - Test';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = where("Document Type" = filter(<> Quote));
            RequestFilterFields = "Document Type", "No.";
            RequestFilterHeading = 'Purchase Document';

            column(Purchase_Header_Document_Type; "Document Type")
            {
            }
            column(Purchase_Header_No_; "No.")
            {
            }
            dataitem(PageCounter; Integer)
            {
                DataItemTableView = sorting(Number)
                                    where(Number = const(1));

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
                column(FORMAT_TODAY_0_4_; Format(TODAY, 0, 4))
                {
                }
                column(COMPANYNAME; COMPANYNAME)
                {
                }
                column(USERID; UserId())
                {
                }
                column(STRSUBSTNO_Text018_PurchHeaderFilter_; StrSubstNo(PurchDocLbl, PurchHeaderFilter))
                {
                }
                column(PurchHeaderFilter; PurchHeaderFilter)
                {
                }
                column(ReceiveInvoiceText; ReceiveInvoiceText)
                {
                }
                column(ShipInvoiceText; ShipInvoiceText)
                {
                }
                column(Purchase_Header___Sell_to_Customer_No__; "Purchase Header"."Sell-to Customer No.")
                {
                }
                column(ShipToAddr_1_; ShipToAddr[1])
                {
                }
                column(ShipToAddr_2_; ShipToAddr[2])
                {
                }
                column(ShipToAddr_3_; ShipToAddr[3])
                {
                }
                column(ShipToAddr_4_; ShipToAddr[4])
                {
                }
                column(ShipToAddr_5_; ShipToAddr[5])
                {
                }
                column(ShipToAddr_6_; ShipToAddr[6])
                {
                }
                column(ShipToAddr_7_; ShipToAddr[7])
                {
                }
                column(ShipToAddr_8_; ShipToAddr[8])
                {
                }
                column(FORMAT__Purchase_Header___Document_Type____________Purchase_Header___No__; Format("Purchase Header"."Document Type") + ' ' + "Purchase Header"."No.")
                {
                }
                column(BuyFromAddr_8_; BuyFromAddr[8])
                {
                }
                column(BuyFromAddr_7_; BuyFromAddr[7])
                {
                }
                column(BuyFromAddr_6_; BuyFromAddr[6])
                {
                }
                column(BuyFromAddr_5_; BuyFromAddr[5])
                {
                }
                column(BuyFromAddr_4_; BuyFromAddr[4])
                {
                }
                column(BuyFromAddr_3_; BuyFromAddr[3])
                {
                }
                column(BuyFromAddr_2_; BuyFromAddr[2])
                {
                }
                column(BuyFromAddr_1_; BuyFromAddr[1])
                {
                }
                column(Purchase_Header___Buy_from_Vendor_No__; "Purchase Header"."Buy-from Vendor No.")
                {
                }
                column(Purchase_Header___Document_Type_; Format("Purchase Header"."Document Type", 0, 2))
                {
                }
                column(Purchase_Header___VAT_Base_Discount___; "Purchase Header"."VAT Base Discount %")
                {
                }
                column(PricesInclVATtxt; PricesInclVATtxt)
                {
                }
                column(ShowItemChargeAssgnt; ShowItemChargeAssgnt)
                {
                }
                column(PayToAddr_1_; PayToAddr[1])
                {
                }
                column(PayToAddr_2_; PayToAddr[2])
                {
                }
                column(PayToAddr_3_; PayToAddr[3])
                {
                }
                column(PayToAddr_4_; PayToAddr[4])
                {
                }
                column(PayToAddr_5_; PayToAddr[5])
                {
                }
                column(PayToAddr_6_; PayToAddr[6])
                {
                }
                column(PayToAddr_7_; PayToAddr[7])
                {
                }
                column(PayToAddr_8_; PayToAddr[8])
                {
                }
                column(Purchase_Header___Pay_to_Vendor_No__; "Purchase Header"."Pay-to Vendor No.")
                {
                }
                column(Purchase_Header___Purchaser_Code_; "Purchase Header"."Purchaser Code")
                {
                }
                column(Purchase_Header___Your_Reference_; "Purchase Header"."Your Reference")
                {
                }
                column(Purchase_Header___Vendor_Posting_Group_; "Purchase Header"."Vendor Posting Group")
                {
                }
                column(Purchase_Header___Posting_Date_; Format("Purchase Header"."Posting Date"))
                {
                }
                column(Purchase_Header___Document_Date_; Format("Purchase Header"."Document Date"))
                {
                }
                column(Purchase_Header___Prices_Including_VAT_; "Purchase Header"."Prices Including VAT")
                {
                }
                column(Purchase_Header___Payment_Terms_Code_; "Purchase Header"."Payment Terms Code")
                {
                }
                column(Purchase_Header___Payment_Discount___; "Purchase Header"."Payment Discount %")
                {
                }
                column(Purchase_Header___Due_Date_; Format("Purchase Header"."Due Date"))
                {
                }
                column(Purchase_Header___Pmt__Discount_Date_; Format("Purchase Header"."Pmt. Discount Date"))
                {
                }
                column(Purchase_Header___Shipment_Method_Code_; "Purchase Header"."Shipment Method Code")
                {
                }
                column(Purchase_Header___Payment_Method_Code_; "Purchase Header"."Payment Method Code")
                {
                }
                column(Purchase_Header___Vendor_Order_No__; "Purchase Header"."Vendor Order No.")
                {
                }
                column(Purchase_Header___Vendor_Shipment_No__; "Purchase Header"."Vendor Shipment No.")
                {
                }
                column(Purchase_Header___Vendor_Invoice_No__; "Purchase Header"."Vendor Invoice No.")
                {
                }
                column(Purchase_Header___Vendor_Posting_Group__Control104; "Purchase Header"."Vendor Posting Group")
                {
                }
                column(Purchase_Header___Posting_Date__Control106; Format("Purchase Header"."Posting Date"))
                {
                }
                column(Purchase_Header___Document_Date__Control107; Format("Purchase Header"."Document Date"))
                {
                }
                column(Purchase_Header___Order_Date_; Format("Purchase Header"."Order Date"))
                {
                }
                column(Purchase_Header___Expected_Receipt_Date_; Format("Purchase Header"."Expected Receipt Date"))
                {
                }
                column(Purchase_Header___Prices_Including_VAT__Control212; "Purchase Header"."Prices Including VAT")
                {
                }
                column(Purchase_Header___Payment_Discount____Control14; "Purchase Header"."Payment Discount %")
                {
                }
                column(Purchase_Header___Payment_Terms_Code__Control18; "Purchase Header"."Payment Terms Code")
                {
                }
                column(Purchase_Header___Due_Date__Control19; Format("Purchase Header"."Due Date"))
                {
                }
                column(Purchase_Header___Pmt__Discount_Date__Control22; Format("Purchase Header"."Pmt. Discount Date"))
                {
                }
                column(Purchase_Header___Payment_Method_Code__Control30; "Purchase Header"."Payment Method Code")
                {
                }
                column(Purchase_Header___Shipment_Method_Code__Control33; "Purchase Header"."Shipment Method Code")
                {
                }
                column(Purchase_Header___Vendor_Shipment_No___Control34; "Purchase Header"."Vendor Shipment No.")
                {
                }
                column(Purchase_Header___Vendor_Invoice_No___Control35; "Purchase Header"."Vendor Invoice No.")
                {
                }
                column(Purchase_Header___Vendor_Posting_Group__Control110; "Purchase Header"."Vendor Posting Group")
                {
                }
                column(Purchase_Header___Posting_Date__Control112; Format("Purchase Header"."Posting Date"))
                {
                }
                column(Purchase_Header___Document_Date__Control113; Format("Purchase Header"."Document Date"))
                {
                }
                column(Purchase_Header___Prices_Including_VAT__Control214; "Purchase Header"."Prices Including VAT")
                {
                }
                column(Purchase_Header___Vendor_Cr__Memo_No__; "Purchase Header"."Vendor Cr. Memo No.")
                {
                }
                column(Purchase_Header___Applies_to_Doc__Type_; "Purchase Header"."Applies-to Doc. Type")
                {
                }
                column(Purchase_Header___Applies_to_Doc__No__; "Purchase Header"."Applies-to Doc. No.")
                {
                }
                column(Purchase_Header___Vendor_Posting_Group__Control128; "Purchase Header"."Vendor Posting Group")
                {
                }
                column(Purchase_Header___Posting_Date__Control130; Format("Purchase Header"."Posting Date"))
                {
                }
                column(Purchase_Header___Document_Date__Control131; Format("Purchase Header"."Document Date"))
                {
                }
                column(Purchase_Header___Prices_Including_VAT__Control216; "Purchase Header"."Prices Including VAT")
                {
                }
                column(PageCounter_Number; Number)
                {
                }
                column(Purchase_Document___TestCaption; Purchase_Document___TestCaptionLbl)
                {
                }
                column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
                {
                }
                column(Purchase_Header___Sell_to_Customer_No__Caption; "Purchase Header".FieldCaption("Sell-to Customer No."))
                {
                }
                column(Ship_toCaption; Ship_toCaptionLbl)
                {
                }
                column(Buy_fromCaption; Buy_fromCaptionLbl)
                {
                }
                column(Purchase_Header___Buy_from_Vendor_No__Caption; "Purchase Header".FieldCaption("Buy-from Vendor No."))
                {
                }
                column(Pay_toCaption; Pay_toCaptionLbl)
                {
                }
                column(Purchase_Header___Pay_to_Vendor_No__Caption; "Purchase Header".FieldCaption("Pay-to Vendor No."))
                {
                }
                column(Purchase_Header___Purchaser_Code_Caption; "Purchase Header".FieldCaption("Purchaser Code"))
                {
                }
                column(Purchase_Header___Your_Reference_Caption; "Purchase Header".FieldCaption("Your Reference"))
                {
                }
                column(Purchase_Header___Vendor_Posting_Group_Caption; "Purchase Header".FieldCaption("Vendor Posting Group"))
                {
                }
                column(Purchase_Header___Posting_Date_Caption; Purchase_Header___Posting_Date_CaptionLbl)
                {
                }
                column(Purchase_Header___Document_Date_Caption; Purchase_Header___Document_Date_CaptionLbl)
                {
                }
                column(Purchase_Header___Prices_Including_VAT_Caption; "Purchase Header".FieldCaption("Prices Including VAT"))
                {
                }
                column(Purchase_Header___Payment_Terms_Code_Caption; "Purchase Header".FieldCaption("Payment Terms Code"))
                {
                }
                column(Purchase_Header___Payment_Discount___Caption; "Purchase Header".FieldCaption("Payment Discount %"))
                {
                }
                column(Purchase_Header___Due_Date_Caption; Purchase_Header___Due_Date_CaptionLbl)
                {
                }
                column(Purchase_Header___Pmt__Discount_Date_Caption; Purchase_Header___Pmt__Discount_Date_CaptionLbl)
                {
                }
                column(Purchase_Header___Shipment_Method_Code_Caption; "Purchase Header".FieldCaption("Shipment Method Code"))
                {
                }
                column(Purchase_Header___Payment_Method_Code_Caption; "Purchase Header".FieldCaption("Payment Method Code"))
                {
                }
                column(Purchase_Header___Vendor_Order_No__Caption; "Purchase Header".FieldCaption("Vendor Order No."))
                {
                }
                column(Purchase_Header___Vendor_Shipment_No__Caption; "Purchase Header".FieldCaption("Vendor Shipment No."))
                {
                }
                column(Purchase_Header___Vendor_Invoice_No__Caption; "Purchase Header".FieldCaption("Vendor Invoice No."))
                {
                }
                column(Purchase_Header___Vendor_Posting_Group__Control104Caption; "Purchase Header".FieldCaption("Vendor Posting Group"))
                {
                }
                column(Purchase_Header___Posting_Date__Control106Caption; Purchase_Header___Posting_Date__Control106CaptionLbl)
                {
                }
                column(Purchase_Header___Document_Date__Control107Caption; Purchase_Header___Document_Date__Control107CaptionLbl)
                {
                }
                column(Purchase_Header___Order_Date_Caption; Purchase_Header___Order_Date_CaptionLbl)
                {
                }
                column(Purchase_Header___Expected_Receipt_Date_Caption; Purchase_Header___Expected_Receipt_Date_CaptionLbl)
                {
                }
                column(Purchase_Header___Prices_Including_VAT__Control212Caption; "Purchase Header".FieldCaption("Prices Including VAT"))
                {
                }
                column(Purchase_Header___Payment_Discount____Control14Caption; "Purchase Header".FieldCaption("Payment Discount %"))
                {
                }
                column(Purchase_Header___Payment_Terms_Code__Control18Caption; "Purchase Header".FieldCaption("Payment Terms Code"))
                {
                }
                column(Purchase_Header___Due_Date__Control19Caption; Purchase_Header___Due_Date__Control19CaptionLbl)
                {
                }
                column(Purchase_Header___Pmt__Discount_Date__Control22Caption; Purchase_Header___Pmt__Discount_Date__Control22CaptionLbl)
                {
                }
                column(Purchase_Header___Payment_Method_Code__Control30Caption; "Purchase Header".FieldCaption("Payment Method Code"))
                {
                }
                column(Purchase_Header___Shipment_Method_Code__Control33Caption; "Purchase Header".FieldCaption("Shipment Method Code"))
                {
                }
                column(Purchase_Header___Vendor_Shipment_No___Control34Caption; "Purchase Header".FieldCaption("Vendor Shipment No."))
                {
                }
                column(Purchase_Header___Vendor_Invoice_No___Control35Caption; "Purchase Header".FieldCaption("Vendor Invoice No."))
                {
                }
                column(Purchase_Header___Vendor_Posting_Group__Control110Caption; "Purchase Header".FieldCaption("Vendor Posting Group"))
                {
                }
                column(Purchase_Header___Posting_Date__Control112Caption; Purchase_Header___Posting_Date__Control112CaptionLbl)
                {
                }
                column(Purchase_Header___Document_Date__Control113Caption; Purchase_Header___Document_Date__Control113CaptionLbl)
                {
                }
                column(Purchase_Header___Prices_Including_VAT__Control214Caption; "Purchase Header".FieldCaption("Prices Including VAT"))
                {
                }
                column(Purchase_Header___Vendor_Cr__Memo_No__Caption; "Purchase Header".FieldCaption("Vendor Cr. Memo No."))
                {
                }
                column(Purchase_Header___Applies_to_Doc__Type_Caption; "Purchase Header".FieldCaption("Applies-to Doc. Type"))
                {
                }
                column(Purchase_Header___Applies_to_Doc__No__Caption; "Purchase Header".FieldCaption("Applies-to Doc. No."))
                {
                }
                column(Purchase_Header___Vendor_Posting_Group__Control128Caption; "Purchase Header".FieldCaption("Vendor Posting Group"))
                {
                }
                column(Purchase_Header___Posting_Date__Control130Caption; Purchase_Header___Posting_Date__Control130CaptionLbl)
                {
                }
                column(Purchase_Header___Document_Date__Control131Caption; Purchase_Header___Document_Date__Control131CaptionLbl)
                {
                }
                column(Purchase_Header___Prices_Including_VAT__Control216Caption; "Purchase Header".FieldCaption("Prices Including VAT"))
                {
                }
                dataitem(DimensionLoop1; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = filter(1 ..));

                    column(DimText; DimText)
                    {
                    }
                    column(DimensionLoop1_Number; Number)
                    {
                    }
                    column(DimText_Control163; DimText)
                    {
                    }
                    column(Header_DimensionsCaption; Header_DimensionsCaptionLbl)
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
                        if not ShowDim then
                            CurrReport.Break();
                    end;
                }
                dataitem(HeaderErrorCounter; Integer)
                {
                    DataItemTableView = sorting(Number);

                    column(ErrorText_Number_; ErrorText[Number])
                    {
                    }
                    column(HeaderErrorCounter_Number; Number)
                    {
                    }
                    column(ErrorText_Number_Caption; ErrorText_Number_CaptionLbl)
                    {
                    }

                    trigger OnPostDataItem()
                    begin
                        ErrorCounter := 0;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, ErrorCounter);
                    end;
                }
                dataitem(CopyLoop; Integer)
                {
                    DataItemTableView = sorting(Number);
                    MaxIteration = 1;

                    dataitem("Purchase Line"; "Purchase Line")
                    {
                        DataItemLink = "Document Type" = field("Document Type"),
                                       "Document No." = field("No.");
                        DataItemLinkReference = "Purchase Header";
                        DataItemTableView = sorting("Document Type", "Document No.", "Line No.");

                        column(Purchase_Line_Document_Type; "Document Type")
                        {
                        }
                        column(Purchase_Line_Document_No_; "Document No.")
                        {
                        }
                        column(Purchase_Line_Line_No_; "Line No.")
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if FindLast() then
                                OrigMaxLineNo := "Line No.";

                            CurrReport.Break();
                        end;
                    }
                    dataitem(RoundLoop; Integer)
                    {
                        DataItemTableView = sorting(Number);

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
                        column(TDSAmt; TDSAmt)
                        {
                        }
                        column(TotalServiceTaxAmount; TotalServiceTaxAmount)
                        {
                        }
                        column(QtyToHandleCaption; QtyToHandleCaption)
                        {
                        }
                        column(Purchase_Line__Type; "Purchase Line".Type)
                        {
                        }
                        column(Purchase_Line___Line_Amount_; "Purchase Line"."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Purchase_Line___Line_Discount_Amount_; "Purchase Line"."Line Discount Amount")
                        {
                        }
                        column(Purchase_Line___Allow_Invoice_Disc__; "Purchase Line"."Allow Invoice Disc.")
                        {
                        }
                        column(Purchase_Line___Line_Discount___; "Purchase Line"."Line Discount %")
                        {
                        }
                        column(Purchase_Line___Direct_Unit_Cost_; "Purchase Line"."Direct Unit Cost")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 2;
                        }
                        column(Purchase_Line___Qty__to_Invoice_; "Purchase Line"."Qty. to Invoice")
                        {
                        }
                        column(QtyToHandle; QtyToHandle)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(Purchase_Line__Quantity; "Purchase Line".Quantity)
                        {
                        }
                        column(Purchase_Line__Description; "Purchase Line".Description)
                        {
                        }
                        column(Purchase_Line___No__; "Purchase Line"."No.")
                        {
                        }
                        column(Purchase_Line___Line_No__; "Purchase Line"."Line No.")
                        {
                        }
                        column(Purchase_Line___Inv__Discount_Amount_; "Purchase Line"."Inv. Discount Amount")
                        {
                        }
                        column(AllowInvDisctxt; AllowInvDisctxt)
                        {
                        }
                        column(ShowDim; ShowDim)
                        {
                        }
                        column(TempPurchLine__Inv__Discount_Amount_; -TempPurchLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TempPurchLine__Line_Amount_; TempPurchLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(TempPurchLine__Line_Amount____TempPurchLine__Inv__Discount_Amount_; TempPurchLine."Line Amount" - TempPurchLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(TempPurchLine__Line_Amount____TempPurchLine__Inv__Discount_Amount____VATAmount; NetTotal)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(SumInvDiscountAmount; SumInvDiscountAmount)
                        {
                        }
                        column(SumLineAmount; SumLineAmount)
                        {
                        }
                        column(TempPurchLine__Excise_Amount_; 0)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TempPurchLine__Tax_Amount_; 0)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(ServiceTaxAmt; ServiceTaxAmt)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TempPurchLine__Total_TDS_Including_SHE_CESS_; 0)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TempPurchLine__Work_Tax_Amount_; 0)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(OtherTaxesAmount; OtherTaxesAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(ChargesAmount; ChargesAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(ServiceTaxECessAmt; ServiceTaxECessAmt)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AppliedServiceTaxAmt; AppliedServiceTaxAmt)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AppliedServiceTaxECessAmt; AppliedServiceTaxECessAmt)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(ServiceTaxSHECessAmt; ServiceTaxSHECessAmt)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AppliedServiceTaxSHECessAmt; AppliedServiceTaxSHECessAmt)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(ServiceTaxSBCAmt; ServiceTaxSBCAmt)
                        {
                        }
                        column(AppliedServiceTaxSBCAmount; AppliedServiceTaxSBCAmount)
                        {
                        }
                        column(KKCessAmt; KKCessAmt)
                        {
                        }
                        column(AppliedKKCessAmount; AppliedKKCessAmount)
                        {
                        }
                        column(SumExciseAmount; SumExciseAmount)
                        {
                        }
                        column(SumTaxAmount; SumTaxAmount)
                        {
                        }
                        column(SumSvcTaxAmount; SumSvcTaxAmount)
                        {
                        }
                        column(SumSvcTaxeCessAmount; SumSvcTaxeCessAmount)
                        {
                        }
                        column(SumSvcTaxSHECESSAmount; SumSvcTaxSHECESSAmount)
                        {
                        }
                        column(SumSvcTaxSBCAmount; SumSvcTaxSBCAmount)
                        {
                        }
                        column(SumKKCessAmount; SumKKCessAmount)
                        {
                        }
                        column(SumAmountToVendor; SumAmountToVendor)
                        {
                        }
                        column(SumTotalTDSIncSHECESS; SumTotalTDSIncSHECESS)
                        {
                        }
                        column(SumWorkTaxAmount; SumWorkTaxAmount)
                        {
                        }
                        column(VATDiscountAmount; -VATDiscountAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmount; VATAmount)
                        {
                        }
                        column(TotalInclVATText_Control155; TotalInclVATText)
                        {
                        }
                        column(VATAmountLine_VATAmountText_Control151; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(TotalExclVATText_Control153; TotalExclVATText)
                        {
                        }
                        column(VATBaseAmount; VATBaseAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseAmount___VATAmount; VATBaseAmount + VATAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmount_Control150; VATAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(RoundLoop_Number; Number)
                        {
                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {
                        }
                        column(Purchase_Line___Line_Discount_Amount_Caption; Purchase_Line___Line_Discount_Amount_CaptionLbl)
                        {
                        }
                        column(Purchase_Line___Allow_Invoice_Disc__Caption; "Purchase Line".FieldCaption("Allow Invoice Disc."))
                        {
                        }
                        column(Purchase_Line___Line_Discount___Caption; Purchase_Line___Line_Discount___CaptionLbl)
                        {
                        }
                        column(Direct_Unit_CostCaption; Direct_Unit_CostCaptionLbl)
                        {
                        }
                        column(Purchase_Line___Qty__to_Invoice_Caption; "Purchase Line".FieldCaption("Qty. to Invoice"))
                        {
                        }
                        column(Purchase_Line__QuantityCaption; "Purchase Line".FieldCaption(Quantity))
                        {
                        }
                        column(Purchase_Line__DescriptionCaption; "Purchase Line".FieldCaption(Description))
                        {
                        }
                        column(Purchase_Line___No__Caption; "Purchase Line".FieldCaption("No."))
                        {
                        }
                        column(Purchase_Line__TypeCaption; "Purchase Line".FieldCaption(Type))
                        {
                        }
                        column(TempPurchLine__Inv__Discount_Amount_Caption; TempPurchLine__Inv__Discount_Amount_CaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(TempPurchLine__Excise_Amount_Caption; TempPurchLine__Excise_Amount_CaptionLbl)
                        {
                        }
                        column(TempPurchLine__Tax_Amount_Caption; TempPurchLine__Tax_Amount_CaptionLbl)
                        {
                        }
                        column(ServiceTaxAmtCaption; ServiceTaxAmtCaptionLbl)
                        {
                        }
                        column(TempPurchLine__Total_TDS_Including_SHE_CESS_Caption; TempPurchLine__Total_TDS_Including_SHE_CESS_CaptionLbl)
                        {
                        }
                        column(TempPurchLine__Work_Tax_Amount_Caption; TempPurchLine__Work_Tax_Amount_CaptionLbl)
                        {
                        }
                        column(Other_Taxes_AmountCaption; Other_Taxes_AmountCaptionLbl)
                        {
                        }
                        column(Charges_AmountCaption; Charges_AmountCaptionLbl)
                        {
                        }
                        column(ServiceTaxECessAmtCaption; ServiceTaxECessAmtCaptionLbl)
                        {
                        }
                        column(Svc_Tax_Amt__Applied_Caption; Svc_Tax_Amt__Applied_CaptionLbl)
                        {
                        }
                        column(Svc_Tax_eCess_Amt__Applied_Caption; Svc_Tax_eCess_Amt__Applied_CaptionLbl)
                        {
                        }
                        column(ServiceTaxSHECessAmtCaption; ServiceTaxSHECessAmtCaptionLbl)
                        {
                        }
                        column(Svc_Tax_SHECess_Amt_Applied_Caption; Svc_Tax_SHECess_Amt_Applied_CaptionLbl)
                        {
                        }
                        column(VATDiscountAmountCaption; VATDiscountAmountCaptionLbl)
                        {
                        }
                        column(ServiceTaxSBCAmtCaption; ServiceTaxSBCAmtCaptionLbl)
                        {
                        }
                        column(Svc_Tax_SBC_Amt__Applied_Caption; Svc_Tax_SBC_Amt__Applied_CaptionLbl)
                        {
                        }
                        column(KKCessAmtCaption; KKCessAmtCaptionLbl)
                        {
                        }
                        column(KKCess_Amt__Applied_Caption; KKCess_Amt__Applied_CaptionLbl)
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText_Control165; DimText)
                            {
                            }
                            column(DimensionLoop2_Number; Number)
                            {
                            }
                            column(DimText_Control167; DimText)
                            {
                            }
                            column(Line_DimensionsCaption; Line_DimensionsCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                DimText := GetDimensionText(DimSetEntry2, Number, Continue);
                                if not Continue then
                                    CurrReport.Break();
                            end;

                            trigger OnPostDataItem()
                            begin
                                SumLineAmount := SumLineAmount + TempPurchLine."Line Amount";
                                SumInvDiscountAmount := SumInvDiscountAmount + TempPurchLine."Inv. Discount Amount";
                                SumExciseAmount := SumExciseAmount;
                                SumTaxAmount := SumTaxAmount;
                                SumSvcTaxAmount := SumSvcTaxAmount;
                                SumSvcTaxeCessAmount := SumSvcTaxeCessAmount;
                                SumSvcTaxSHECESSAmount := SumSvcTaxSHECESSAmount;
                                SumSvcTaxSBCAmount := SumSvcTaxSBCAmount;
                                SumKKCessAmount := SumKKCessAmount;
                                SumAmountToVendor := SumAmountToVendor;
                                SumTotalTDSIncSHECESS := SumTotalTDSIncSHECESS;
                                SumWorkTaxAmount := SumWorkTaxAmount;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowDim then
                                    CurrReport.Break();
                            end;
                        }
                        dataitem(LineErrorCounter; Integer)
                        {
                            DataItemTableView = sorting(Number);

                            column(ErrorText_Number__Control103; ErrorText[Number])
                            {
                            }
                            column(LineErrorCounter_Number; Number)
                            {
                            }
                            column(ErrorText_Number__Control103Caption; ErrorText_Number__Control103CaptionLbl)
                            {
                            }

                            trigger OnPostDataItem()
                            begin
                                ErrorCounter := 0;
                            end;

                            trigger OnPreDataItem()
                            begin
                                SetRange(Number, 1, ErrorCounter);
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            TableID: array[10] of Integer;
                            No: array[10] of Code[20];
                            Fraction: Decimal;
                        begin
                            if Number = 1 then
                                TempPurchLine.Find('-')
                            else
                                TempPurchLine.Next();

                            "Purchase Line" := TempPurchLine;
                            if not "Purchase Header"."Prices Including VAT" and
                               ("Purchase Line"."VAT Calculation Type" = "Purchase Line"."VAT Calculation Type"::"Full VAT")
                            then
                                TempPurchLine."Line Amount" := 0;

                            DimSetEntry2.SetRange("Dimension Set ID", "Purchase Line"."Dimension Set ID");
                            DimMgt.GetDimensionSet(TempDimSetEntry, "Purchase Line"."Dimension Set ID");

                            FilterAppliedEntries();

                            if "Purchase Line"."Document Type" in [
                                "Purchase Line"."Document Type"::"Return Order",
                                "Purchase Line"."Document Type"::"Credit Memo"]
                            then begin
                                if "Purchase Line"."Document Type" = "Purchase Line"."Document Type"::"Credit Memo" then begin
                                    if ("Purchase Line"."Return Qty. to Ship" <> "Purchase Line".Quantity) and
                                        ("Purchase Line"."Return Shipment No." = '')
                                    then
                                        AddError(
                                            StrSubstNo(
                                                MustBe12Lbl,
                                                "Purchase Line".FieldCaption("Return Qty. to Ship"),
                                                "Purchase Line".Quantity));

                                    if "Purchase Line"."Qty. to Invoice" <> "Purchase Line".Quantity then
                                        AddError(
                                            StrSubstNo(
                                                MustBe12Lbl,
                                                "Purchase Line".FieldCaption("Qty. to Invoice"),
                                                "Purchase Line".Quantity));
                                end;

                                if "Purchase Line"."Qty. to Receive" <> 0 then
                                    AddError(StrSubstNo(MustBeZeroLbl, "Purchase Line".FieldCaption("Qty. to Receive")));
                            end else begin
                                if "Purchase Line"."Document Type" = "Purchase Line"."Document Type"::Invoice then begin
                                    if ("Purchase Line"."Qty. to Receive" <> "Purchase Line".Quantity) and
                                        ("Purchase Line"."Receipt No." = '')
                                    then
                                        AddError(
                                            StrSubstNo(
                                                MustBe12Lbl,
                                                "Purchase Line".FieldCaption("Qty. to Receive"),
                                                "Purchase Line".Quantity));

                                    if "Purchase Line"."Qty. to Invoice" <> "Purchase Line".Quantity then
                                        AddError(StrSubstNo(MustBe12Lbl, "Purchase Line".FieldCaption("Qty. to Invoice"), "Purchase Line".Quantity));
                                end;

                                if "Purchase Line"."Return Qty. to Ship" <> 0 then
                                    AddError(StrSubstNo(MustBeZeroLbl, "Purchase Line".FieldCaption("Return Qty. to Ship")));
                            end;

                            CalcQty("Purchase Line");
                            if "Purchase Line"."Gen. Prod. Posting Group" <> '' then begin
                                Clear(GenPostingSetup);
                                GenPostingSetup.Reset();
                                GenPostingSetup.SetRange("Gen. Bus. Posting Group", "Purchase Line"."Gen. Bus. Posting Group");
                                GenPostingSetup.SetRange("Gen. Prod. Posting Group", "Purchase Line"."Gen. Prod. Posting Group");
                                if not GenPostingSetup.FindLast() then
                                    AddError(
                                      StrSubstNo(
                                        MustBeMessLbl,
                                        GenPostingSetup.TableCaption,
                                        "Purchase Line"."Gen. Bus. Posting Group",
                                        "Purchase Line"."Gen. Prod. Posting Group"));
                            end;

                            if "Purchase Line".Quantity <> 0 then begin
                                if "Purchase Line"."No." = '' then
                                    AddError(StrSubstNo(MustbeSpecLbl, "Purchase Line".FieldCaption("No.")));
                                if "Purchase Line".Type.AsInteger() = 0 then
                                    AddError(StrSubstNo(MustbeSpecLbl, "Purchase Line".FieldCaption(Type)));
                            end else
                                if "Purchase Line".Amount <> 0 then
                                    AddError(
                                        StrSubstNo(
                                            MustBe01Lbl,
                                            "Purchase Line".FieldCaption(Amount),
                                            "Purchase Line".FieldCaption(Quantity)));

                            PurchLine := "Purchase Line";
                            TestJobFields(PurchLine);
                            if "Purchase Line"."Document Type" in [
                                "Purchase Line"."Document Type"::"Return Order",
                                "Purchase Line"."Document Type"::"Credit Memo"]
                            then begin
                                PurchLine."Return Qty. to Ship" := -PurchLine."Return Qty. to Ship";
                                PurchLine."Qty. to Invoice" := -PurchLine."Qty. to Invoice";
                            end;

                            RemQtyToBeInvoiced := PurchLine."Qty. to Invoice";

                            case "Purchase Line"."Document Type" of
                                "Purchase Line"."Document Type"::"Return Order", "Purchase Line"."Document Type"::"Credit Memo":
                                    CheckShptLines("Purchase Line");
                                "Purchase Line"."Document Type"::Order, "Purchase Line"."Document Type"::Invoice:
                                    CheckRcptLines("Purchase Line");
                            end;

                            if ("Purchase Line".Type.AsInteger() >= Type::"G/L Account".AsInteger()) and
                                ("Purchase Line"."Qty. to Invoice" <> 0)
                            then
                                if not GenPostingSetup.Get("Purchase Line"."Gen. Bus. Posting Group", "Purchase Line"."Gen. Prod. Posting Group") then
                                    AddError(
                                      StrSubstNo(
                                        MustBeMessLbl,
                                        GenPostingSetup.TableCaption, "Purchase Line"."Gen. Bus. Posting Group", "Purchase Line"."Gen. Prod. Posting Group"));

                            if "Purchase Line"."Prepayment %" > 0 then
                                if not "Purchase Line"."Prepayment Line" and ("Purchase Line".Quantity > 0) then begin
                                    Fraction := ("Purchase Line"."Qty. to Invoice" + "Purchase Line"."Quantity Invoiced") / "Purchase Line".Quantity;
                                    if Fraction > 1 then
                                        Fraction := 1;

                                    case true of
                                        (Fraction * "Purchase Line"."Line Amount" < "Purchase Line"."Prepmt Amt to Deduct") and
                                        ("Purchase Line"."Prepmt Amt to Deduct" <> 0):
                                            AddError(
                                              StrSubstNo(
                                                CanmostLbl,
                                                "Purchase Line".FieldCaption("Prepmt Amt to Deduct"),
                                                Round(Fraction * "Purchase Line"."Line Amount", GLSetup."Amount Rounding Precision")));
                                        (1 - Fraction) * "Purchase Line"."Line Amount" < "Purchase Line"."Prepmt. Amt. Inv." - "Purchase Line"."Prepmt Amt Deducted" - "Purchase Line"."Prepmt Amt to Deduct":
                                            AddError(
                                              StrSubstNo(
                                                AtleasRoundtLbl,
                                                "Purchase Line".FieldCaption("Prepmt Amt to Deduct"),
                                                Round(
                                                  "Purchase Line"."Prepmt. Amt. Inv." -
                                                  "Purchase Line"."Prepmt Amt Deducted" -
                                                  (1 - Fraction) * "Purchase Line"."Line Amount",
                                                  GLSetup."Amount Rounding Precision")));
                                    end;
                                end;

                            if not "Purchase Line"."Prepayment Line" and ("Purchase Line"."Prepmt. Line Amount" > 0) then
                                if "Purchase Line"."Prepmt. Line Amount" > "Purchase Line"."Prepmt. Amt. Inv." then
                                    AddError(StrSubstNo(PreinvLbl, "Purchase Line".FieldCaption("Prepmt. Line Amount")));

                            CheckType("Purchase Line");

                            if "Purchase Line"."Line No." > OrigMaxLineNo then begin
                                AddDimToTempLine("Purchase Line");
                                if not DimMgt.CheckDimIDComb("Purchase Line"."Dimension Set ID") then
                                    AddError(DimMgt.GetDimCombErr());
                                if not DimMgt.CheckDimValuePosting(TableID, No, "Purchase Line"."Dimension Set ID") then
                                    AddError(DimMgt.GetDimValuePostingErr());
                            end else begin
                                if not DimMgt.CheckDimIDComb("Purchase Line"."Dimension Set ID") then
                                    AddError(DimMgt.GetDimCombErr());

                                TableID[1] := DimMgt.PurchLineTypeToTableID("Purchase Line".Type);
                                No[1] := "Purchase Line"."No.";
                                TableID[2] := Database::Job;
                                No[2] := "Purchase Line"."Job No.";
                                TableID[3] := Database::"Work Center";
                                No[3] := "Purchase Line"."Work Center No.";
                                if not DimMgt.CheckDimValuePosting(TableID, No, "Purchase Line"."Dimension Set ID") then
                                    AddError(DimMgt.GetDimValuePostingErr());
                            end;

                            AllowInvDisctxt := Format("Purchase Line"."Allow Invoice Disc.");
                        end;

                        trigger OnPreDataItem()
                        var
                            MoreLines: Boolean;
                        begin
                            MoreLines := TempPurchLine.FindLast();
                            while MoreLines and
                                (TempPurchLine.Description = '') and
                                (TempPurchLine."Description 2" = '') and
                                (TempPurchLine."No." = '') and
                                (TempPurchLine.Quantity = 0) and
                                (TempPurchLine.Amount = 0)
                            do
                                MoreLines := TempPurchLine.Next(-1) <> 0;

                            if not MoreLines then
                                CurrReport.Break();

                            TempPurchLine.SetRange("Line No.", 0, TempPurchLine."Line No.");
                            SetRange(Number, 1, TempPurchLine.Count);

                            SumLineAmount := 0;
                            SumInvDiscountAmount := 0;
                            SumExciseAmount := 0;
                            SumTaxAmount := 0;
                            SumSvcTaxAmount := 0;
                            SumSvcTaxeCessAmount := 0;
                            SumSvcTaxSHECESSAmount := 0;
                            SumSvcTaxSBCAmount := 0;
                            SumKKCessAmount := 0;
                            SumAmountToVendor := 0;
                            SumTotalTDSIncSHECESS := 0;
                            SumWorkTaxAmount := 0;
                        end;
                    }
                    dataitem(VATCounter; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(VATAmountLine__VAT_Amount_; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base_; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount_; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount_; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount_; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount__Control98; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base__Control138; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT___; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmountLine__VAT_Identifier_; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATAmountLine__Line_Amount__Control175; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control176; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control177; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount__Control95; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base__Control139; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control181; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control182; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount__Control183; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount__Control85; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base__Control137; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control187; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control188; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount__Control189; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATCounter_Number; Number)
                        {
                        }
                        column(VAT_Amount_SpecificationCaption; VAT_Amount_SpecificationCaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Amount__Control98Caption; VATAmountLine__VAT_Amount__Control98CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Base__Control138Caption; VATAmountLine__VAT_Base__Control138CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT___Caption; VATAmountLine__VAT___CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Identifier_Caption; VATAmountLine__VAT_Identifier_CaptionLbl)
                        {
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control176Caption; VATAmountLine__Inv__Disc__Base_Amount__Control176CaptionLbl)
                        {
                        }
                        column(VATAmountLine__Line_Amount__Control175Caption; VATAmountLine__Line_Amount__Control175CaptionLbl)
                        {
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control177Caption; VATAmountLine__Invoice_Discount_Amount__Control177CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Base_Caption; VATAmountLine__VAT_Base_CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Base__Control139Caption; VATAmountLine__VAT_Base__Control139CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Base__Control137Caption; VATAmountLine__VAT_Base__Control137CaptionLbl)
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

                        column(VALExchRate; VALExchRate)
                        {
                        }
                        column(VALSpecLCYHeader; VALSpecLCYHeader)
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
                        column(VALVATAmountLCY_Control242; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY_Control243; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT____Control244; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmountLine__VAT_Identifier__Control245; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VALVATAmountLCY_Control246; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY_Control247; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATAmountLCY_Control249; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY_Control250; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATCounterLCY_Number; VATCounterLCY.Number)
                        {
                        }
                        column(VALVATAmountLCY_Control242Caption; VALVATAmountLCY_Control242CaptionLbl)
                        {
                        }
                        column(VALVATBaseLCY_Control243Caption; VALVATBaseLCY_Control243CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT____Control244Caption; VATAmountLine__VAT____Control244CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Identifier__Control245Caption; VATAmountLine__VAT_Identifier__Control245CaptionLbl)
                        {
                        }
                        column(ContinuedCaption; ContinuedCaptionLbl)
                        {
                        }
                        column(ContinuedCaption_Control248; ContinuedCaption_Control248Lbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                            VALVATBaseLCY := TempVATAmountLine.GetBaseLCY(
                                "Purchase Header"."Posting Date",
                                "Purchase Header"."Currency Code",
                                "Purchase Header"."Currency Factor");
                            VALVATAmountLCY := TempVATAmountLine.GetAmountLCY(
                                "Purchase Header"."Posting Date",
                                "Purchase Header"."Currency Code",
                                "Purchase Header"."Currency Factor");
                        end;

                        trigger OnPreDataItem()
                        var
                            CurrExchRate: Record "Currency Exchange Rate";
                        begin
                            if (not GLSetup."Print VAT specification in LCY") or
                               ("Purchase Header"."Currency Code" = '')
                            then
                                CurrReport.Break();

                            SetRange(Number, 1, TempVATAmountLine.Count);
                            if GLSetup."LCY Code" = '' then
                                VALSpecLCYHeader := VatAmtSpecLbl + LocCuLbl
                            else
                                VALSpecLCYHeader := VatAmtSpecLbl + Format(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency("Purchase Header"."Posting Date", "Purchase Header"."Currency Code", 1);
                            CurrExchRate."Relational Exch. Rate Amount" := CurrExchRate."Exchange Rate Amount" / "Purchase Header"."Currency Factor";
                            VALExchRate := StrSubstNo(
                                ExchRateLbl,
                                CurrExchRate."Relational Exch. Rate Amount",
                                CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem("Item Charge Assignment (Purch)"; "Item Charge Assignment (Purch)")
                    {
                        DataItemLink = "Document Type" = field("Document Type"),
                                       "Document No." = field("Document No.");
                        DataItemLinkReference = "Purchase Line";
                        DataItemTableView = sorting("Document Type", "Document No.", "Document Line No.", "Line No.");

                        column(Item_Charge_Assignment__Purch___Qty__to_Assign_; "Qty. to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Amount_to_Assign_; "Amount to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Item_Charge_No__; "Item Charge No.")
                        {
                        }
                        column(PurchLine2_Description; PurchLine2.Description)
                        {
                        }
                        column(PurchLine2_Quantity; PurchLine2.Quantity)
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Item_No__; "Item No.")
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Qty__to_Assign__Control204; "Qty. to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Unit_Cost_; "Unit Cost")
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Amount_to_Assign__Control210; "Amount to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Qty__to_Assign__Control195; "Qty. to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Amount_to_Assign__Control196; "Amount to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Qty__to_Assign__Control191; "Qty. to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Amount_to_Assign__Control193; "Amount to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Purch__Document_Type; "Document Type")
                        {
                        }
                        column(Item_Charge_Assignment__Purch__Document_No_; "Document No.")
                        {
                        }
                        column(Item_Charge_Assignment__Purch__Document_Line_No_; "Document Line No.")
                        {
                        }
                        column(Item_Charge_Assignment__Purch__Line_No_; "Line No.")
                        {
                        }
                        column(Item_Charge_SpecificationCaption; Item_Charge_SpecificationCaptionLbl)
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Item_Charge_No__Caption; FieldCaption("Item Charge No."))
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Item_No__Caption; FieldCaption("Item No."))
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Qty__to_Assign__Control204Caption; FieldCaption("Qty. to Assign"))
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Unit_Cost_Caption; FieldCaption("Unit Cost"))
                        {
                        }
                        column(Item_Charge_Assignment__Purch___Amount_to_Assign__Control210Caption; FieldCaption("Amount to Assign"))
                        {
                        }
                        column(DescriptionCaption; DescriptionCaptionLbl)
                        {
                        }
                        column(PurchLine2_QuantityCaption; PurchLine2_QuantityCaptionLbl)
                        {
                        }
                        column(ContinuedCaption_Control197; ContinuedCaption_Control197Lbl)
                        {
                        }
                        column(TotalCaption_Control194; TotalCaption_Control194Lbl)
                        {
                        }
                        column(ContinuedCaption_Control192; ContinuedCaption_Control192Lbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if PurchLine2.Get("Document Type", "Document No.", "Document Line No.") then;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowItemChargeAssgnt then
                                CurrReport.Break();
                        end;
                    }

                    trigger OnAfterGetRecord()
                    var
                        PurchPost: Codeunit "Purch.-Post";
                    begin
                        Clear(TempPurchLine);
                        Clear(PurchPost);

                        TempPurchLine.DeleteAll();
                        TempVATAmountLine.DeleteAll();

                        PurchPost.GetPurchLines("Purchase Header", TempPurchLine, 1);
                        TempPurchLine.CalcVATAmountLines(0, "Purchase Header", TempPurchLine, TempVATAmountLine);
                        TempPurchLine.UpdateVATOnLines(0, "Purchase Header", TempPurchLine, TempVATAmountLine);

                        VATAmount := TempVATAmountLine.GetTotalVATAmount();
                        VATBaseAmount := TempVATAmountLine.GetTotalVATBase();
                        VATDiscountAmount := TempVATAmountLine.GetTotalVATDiscount(
                            "Purchase Header"."Currency Code",
                            "Purchase Header"."Prices Including VAT");

                        VATAmount := 0;
                        ChargesAmount := 0;
                        OtherTaxesAmount := 0;
                    end;
                }
            }

            trigger OnAfterGetRecord()
            var
                TaxTrnasactionValue: Record "Tax Transaction Value";
                TaxTrnasactionValue1: Record "Tax Transaction Value";
                TaxTrnasactionValue2: Record "Tax Transaction Value";
                TableID: array[10] of Integer;
                No: array[10] of Code[20];
            begin
                Vendor.Get("Buy-from Vendor No.");
                DimSetEntry1.SetRange("Dimension Set ID", "Purchase Header"."Dimension Set ID");
                ServiceTaxAmt := 0;
                ServiceTaxECessAmt := 0;
                ServiceTaxSHECessAmt := 0;
                AmountToVendor := 0;
                ServiceTaxSBCAmt := 0;
                KKCessAmt := 0;

                FormatAddr.PurchHeaderPayTo(PayToAddr, "Purchase Header");
                FormatAddr.PurchHeaderBuyFrom(BuyFromAddr, "Purchase Header");
                FormatAddr.PurchHeaderShipTo(ShipToAddr, "Purchase Header");
                if "Currency Code" = '' then begin
                    GLSetup.TestField("LCY Code");
                    TotalText := StrSubstNo(TotalLbl, GLSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(IncTaxLbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(ExcTaxLbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(TotalLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(IncTaxLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(ExcTaxLbl, "Currency Code");
                end;

                Invoice := InvOnNextPostReq;
                Receive := ReceiveShipOnNextPostReq;
                Ship := ReceiveShipOnNextPostReq;
                VerifyBuyFromVend("Purchase Header");
                VerifyPayToVend("Purchase Header");

                PurchSetup.Get();
                VerifyPostingDate("Purchase Header");

                if "Document Date" <> 0D then
                    if "Document Date" <> NormalDate("Document Date") then
                        AddError(StrSubstNo(ClosingDateLbl, FieldCaption("Document Date")));

                case "Document Type" of
                    "Document Type"::Order:
                        Ship := false;
                    "Document Type"::Invoice:
                        begin
                            Receive := true;
                            Invoice := true;
                            Ship := false;
                        end;
                    "Document Type"::"Return Order":
                        Receive := false;
                    "Document Type"::"Credit Memo":
                        begin
                            Receive := false;
                            Invoice := true;
                            Ship := true;
                        end;
                end;

                if not (Receive or Invoice or Ship) then
                    AddError(
                      StrSubstNo(
                        EnterYesLbl,
                        FieldCaption(Receive), FieldCaption(Invoice), FieldCaption(Ship)));

                if Invoice then begin
                    PurchLine.Reset();
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    PurchLine.SetFilter(Quantity, '<>0');
                    if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                        PurchLine.SetFilter("Qty. to Invoice", '<>0');

                    Invoice := PurchLine.FindSet();
                    if Invoice and (not Receive) and ("Document Type" = "Document Type"::Order) then begin
                        Invoice := false;

                        repeat
                            Invoice := PurchLine."Quantity Received" - PurchLine."Quantity Invoiced" <> 0;
                        until Invoice or (PurchLine.Next() = 0);
                    end else
                        if Invoice and (not Ship) and ("Document Type" = "Document Type"::"Return Order") then begin
                            Invoice := false;

                            repeat
                                Invoice := PurchLine."Return Qty. Shipped" - PurchLine."Quantity Invoiced" <> 0;
                            until Invoice or (PurchLine.Next() = 0);
                        end;
                end;

                if Receive then begin
                    PurchLine.Reset();
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    PurchLine.SetFilter(Quantity, '<>0');
                    if "Document Type" = "Document Type"::Order then
                        PurchLine.SetFilter("Qty. to Receive", '<>0');

                    PurchLine.SetRange("Receipt No.", '');
                    Receive := PurchLine.FindFirst();
                end;

                if Ship then begin
                    PurchLine.Reset();
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    PurchLine.SetFilter(Quantity, '<>0');
                    if "Document Type" = "Document Type"::"Return Order" then
                        PurchLine.SetFilter("Return Qty. to Ship", '<>0');
                    PurchLine.SetRange("Return Shipment No.", '');
                    Ship := PurchLine.FindFirst();
                end;

                if not (Receive or Invoice or Ship) then
                    AddError(NtihngToPostLbl);

                if Invoice then begin
                    PurchLine.Reset();
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    PurchLine.SetFilter("Sales Order Line No.", '<>0');
                    if PurchLine.FindSet() then
                        repeat
                            SalesLine.Get(SalesLine."Document Type"::Order, PurchLine."Sales Order No.", PurchLine."Sales Order Line No.");
                            if Receive and
                               Invoice and
                               (PurchLine."Qty. to Invoice" <> 0) and
                               (PurchLine."Qty. to Receive" <> 0)
                            then
                                AddError(ShipmentLbl);

                            if Abs(PurchLine."Quantity Received" - PurchLine."Quantity Invoiced") <
                               Abs(PurchLine."Qty. to Invoice")
                            then
                                PurchLine."Qty. to Invoice" := PurchLine."Quantity Received" - PurchLine."Quantity Invoiced";

                            if Abs(PurchLine.Quantity - (PurchLine."Qty. to Invoice" + PurchLine."Quantity Invoiced")) <
                               Abs(SalesLine.Quantity - SalesLine."Quantity Invoiced")
                            then
                                AddError(
                                  StrSubstNo(
                                    SalesOrderLbl,
                                    PurchLine."Sales Order No."));
                        until PurchLine.Next() = 0;
                end;

                if Invoice then
                    if not ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then
                        if "Due Date" = 0D then
                            AddError(StrSubstNo(MustbeSpecLbl, FieldCaption("Due Date")));

                if Receive and ("Receiving No." = '') then
                    if ("Document Type" = "Document Type"::Order) or
                       (("Document Type" = "Document Type"::Invoice) and PurchSetup."Receipt on Invoice")
                    then
                        if "Receiving No. Series" = '' then
                            AddError(
                              StrSubstNo(
                                EntrerdLbl,
                                FieldCaption("Receiving No. Series")));

                if Ship and ("Return Shipment No." = '') then
                    if ("Document Type" = "Document Type"::"Return Order") or
                       (("Document Type" = "Document Type"::"Credit Memo") and PurchSetup."Return Shipment on Credit Memo")
                    then
                        if "Return Shipment No. Series" = '' then
                            AddError(
                              StrSubstNo(
                                EntrerdLbl,
                                FieldCaption("Return Shipment No. Series")));

                if Invoice and ("Posting No." = '') then
                    if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                        if "Posting No. Series" = '' then
                            AddError(
                              StrSubstNo(
                                EntrerdLbl,
                                FieldCaption("Posting No. Series")));

                PurchLine.Reset();
                PurchLine.SetRange("Document Type", "Document Type");
                PurchLine.SetRange("Document No.", "No.");
                PurchLine.SetFilter("Sales Order Line No.", '<>0');
                if PurchLine.FindSet() then
                    if Receive then
                        repeat
                            if SalesHeader."No." <> PurchLine."Sales Order No." then begin
                                SalesHeader.Get(1, PurchLine."Sales Order No.");
                                if SalesHeader."Bill-to Customer No." = '' then
                                    AddError(
                                      StrSubstNo(
                                        SalesOrder1Lbl,
                                        SalesHeader.FieldCaption("Bill-to Customer No.")));

                                if SalesHeader."Shipping No." = '' then
                                    if SalesHeader."Shipping No. Series" = '' then
                                        AddError(
                                          StrSubstNo(
                                            SalesOrder1Lbl,
                                            SalesHeader.FieldCaption("Shipping No. Series")));
                            end;
                        until PurchLine.Next() = 0;

                if Invoice then
                    if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then begin
                        if PurchSetup."Ext. Doc. No. Mandatory" and ("Vendor Invoice No." = '') then
                            AddError(StrSubstNo(MustbeSpecLbl, FieldCaption("Vendor Invoice No.")));
                    end else
                        if PurchSetup."Ext. Doc. No. Mandatory" and ("Vendor Cr. Memo No." = '') then
                            AddError(StrSubstNo(MustbeSpecLbl, FieldCaption("Vendor Cr. Memo No.")));

                if not DimMgt.CheckDimIDComb("Dimension Set ID") then
                    AddError(DimMgt.GetDimCombErr());

                TableID[1] := Database::Vendor;
                No[1] := "Pay-to Vendor No.";
                TableID[3] := Database::"Salesperson/Purchaser";
                No[3] := "Purchaser Code";
                TableID[4] := Database::Campaign;
                No[4] := "Campaign No.";
                TableID[5] := Database::"Responsibility Center";
                No[5] := "Responsibility Center";

                if not DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then
                    AddError(DimMgt.GetDimValuePostingErr());

                PurchLine.Reset();
                PurchLine.SetRange("Document Type", "Document Type");
                PurchLine.SetRange("Document No.", "No.");
                PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
                if PurchLine.FindSet() then
                    repeat
                        j := 1;
                        TaxTrnasactionValue.Reset();
                        TaxTrnasactionValue.SetRange("Tax Record ID", PurchLine.RecordId);
                        TaxTrnasactionValue.SetRange("Tax Type", 'GST');
                        TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                        TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                        if TaxTrnasactionValue.FindSet() then
                            repeat
                                j := TaxTrnasactionValue."Value ID";
                                GSTComponentCode[j] := TaxTrnasactionValue."Value ID";
                                TaxTrnasactionValue1.Reset();
                                TaxTrnasactionValue1.SetRange("Tax Record ID", PurchLine.RecordId);
                                TaxTrnasactionValue1.SetRange("Tax Type", 'GST');
                                TaxTrnasactionValue1.SetRange("Value Type", TaxTrnasactionValue1."Value Type"::COMPONENT);
                                TaxTrnasactionValue1.SetRange("Value ID", GSTComponentCode[j]);
                                if TaxTrnasactionValue1.FindSet() then
                                    repeat
                                        GSTCompAmount[j] += TaxTrnasactionValue1.Amount;
                                        TotalServiceTaxAmount += TaxTrnasactionValue1.Amount;
                                    until TaxTrnasactionValue1.Next() = 0;
                                j += 1;
                            until TaxTrnasactionValue.Next() = 0;

                        j := 1;
                        TaxTrnasactionValue.Reset();
                        TaxTrnasactionValue.SetRange("Tax Record ID", PurchLine.RecordId);
                        TaxTrnasactionValue.SetRange("Tax Type", 'TDS');
                        TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                        TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                        if TaxTrnasactionValue.FindSet() then
                            repeat
                                j := TaxTrnasactionValue."Value ID";
                                TDSComponentCode[j] := TaxTrnasactionValue."Value ID";
                                TaxTrnasactionValue2.Reset();
                                TaxTrnasactionValue2.SetRange("Tax Record ID", PurchLine.RecordId);
                                TaxTrnasactionValue2.SetRange("Tax Type", 'TDS');
                                TaxTrnasactionValue2.SetRange("Value Type", TaxTrnasactionValue2."Value Type"::COMPONENT);
                                TaxTrnasactionValue2.SetRange("Value ID", TDSComponentCode[j]);
                                if TaxTrnasactionValue2.FindSet() then
                                    repeat
                                        TDSCompAmount[j] += TaxTrnasactionValue2.Amount;
                                        TDSAmt += TaxTrnasactionValue2.Amount;
                                    until TaxTrnasactionValue2.Next() = 0;
                                j += 1;
                            until TaxTrnasactionValue.Next() = 0;

                        TaxTrnasactionValue.Reset();
                        TaxTrnasactionValue.SetRange("Tax Record ID", PurchLine.RecordId);
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
                    until PurchLine.Next() = 0;

                PricesInclVATtxt := Format("Purchase Header"."Prices Including VAT");
                ChargesAmount := 0;
                OtherTaxesAmount := 0;
            end;

            trigger OnPreDataItem()
            begin
                PurchHeader.Copy("Purchase Header");
                PurchHeader.FilterGroup := 2;
                PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                if PurchHeader.FindFirst() then begin
                    case true of
                        ReceiveShipOnNextPostReq and InvOnNextPostReq:
                            ReceiveInvoiceText := ReceiveandInvLbl;
                        ReceiveShipOnNextPostReq:
                            ReceiveInvoiceText := ReceiveLbl;
                        InvOnNextPostReq:
                            ReceiveInvoiceText := InvLbl;
                    end;

                    ReceiveInvoiceText := StrSubstNo(OrderPostLbl, ReceiveInvoiceText);
                end;

                PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::"Return Order");
                if PurchHeader.FindFirst() then begin
                    case true of
                        ReceiveShipOnNextPostReq and InvOnNextPostReq:
                            ShipInvoiceText := ShipAndInvLbl;
                        ReceiveShipOnNextPostReq:
                            ShipInvoiceText := ShipLbl;
                        InvOnNextPostReq:
                            ShipInvoiceText := InvLbl;
                    end;

                    ShipInvoiceText := StrSubstNo(RetuOrderPosLbl, ShipInvoiceText);
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
                    group("Order/Credit Memo Posting")
                    {
                        Caption = 'Order/Credit Memo Posting';
                        field(ReceiveShip; ReceiveShipOnNextPostReq)
                        {
                            Caption = 'Receive/Ship';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies whether the posting type of the document is receive/ship or not.';

                            trigger OnValidate()
                            begin
                                if not ReceiveShipOnNextPostReq then
                                    InvOnNextPostReq := true;
                                ;
                            end;
                        }
                        field(Invoice; InvOnNextPostReq)
                        {
                            Caption = 'Invoice';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies whether the posting type of the document is invoice or not.';

                            trigger OnValidate()
                            begin
                                if not InvOnNextPostReq then
                                    ReceiveShipOnNextPostReq := true;
                                ;
                            end;
                        }
                    }
                    field(ShowDimension; ShowDim)
                    {
                        Caption = 'Show Dimensions';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether the dimensions have to be displayed or not.';
                    }
                    field(ShowItemChargeAssignment; ShowItemChargeAssgnt)
                    {
                        Caption = 'Show Item Charge Assgnt.';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies wheteher the assigned item charge have to be displyed or not.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if not ReceiveShipOnNextPostReq and not InvOnNextPostReq then begin
                ReceiveShipOnNextPostReq := true;
                ;
                InvOnNextPostReq := true;
                ;
            end;
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

    trigger OnPreReport()
    begin
        PurchHeaderFilter := "Purchase Header".GetFilters;
    end;

    var
        CompanyInfo: Record "Company Information";
        Vendor: Record Vendor;
        PurchSetup: Record "Purchases & Payables Setup";
        GLSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        Vend: Record Vendor;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        TempPurchLine: Record "Purchase Line" temporary;
        GLAcc: Record "G/L Account";
        Item: Record Item;
        FA: Record "Fixed Asset";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnShptLine: Record "Return Shipment Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenPostingSetup: Record "General Posting Setup";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        InvtPeriod: Record "Inventory Period";
        FormatAddr: Codeunit "Format Address";
        DimMgt: Codeunit "DimensionManagement";
        GSTComponentCode: array[20] of Integer;
        PayToAddr: array[8] of Text[50];
        BuyFromAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        PurchHeaderFilter: Text;
        ErrorText: array[99] of Text[250];
        DimText: Text[120];
        ReceiveInvoiceText: Text[50];
        ShipInvoiceText: Text[50];
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        QtyToHandleCaption: Text[30];
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        MaxQtyToBeInvoiced: Decimal;
        RemQtyToBeInvoiced: Decimal;
        QtyToBeInvoiced: Decimal;
        QtyToHandle: Decimal;
        VATAmount: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        ErrorCounter: Integer;
        OrigMaxLineNo: Integer;
        InvOnNextPostReq: Boolean;
        ReceiveShipOnNextPostReq: Boolean;
        ShowDim: Boolean;
        Continue: Boolean;
        ShowItemChargeAssgnt: Boolean;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        PricesInclVATtxt: Text[30];
        AllowInvDisctxt: Text[30];
        SumLineAmount: Decimal;
        SumInvDiscountAmount: Decimal;
        OtherTaxesAmount: Decimal;
        ChargesAmount: Decimal;
        ServiceTaxAmt: Decimal;
        ServiceTaxECessAmt: Decimal;
        AppliedServiceTaxAmt: Decimal;
        AppliedServiceTaxECessAmt: Decimal;
        NetTotal: Decimal;
        ServiceTaxSHECessAmt: Decimal;
        AppliedServiceTaxSHECessAmt: Decimal;
        SumExciseAmount: Decimal;
        SumTaxAmount: Decimal;
        SumSvcTaxAmount: Decimal;
        SumSvcTaxeCessAmount: Decimal;
        SumSvcTaxSHECESSAmount: Decimal;
        SumAmountToVendor: Decimal;
        SumTotalTDSIncSHECESS: Decimal;
        SumWorkTaxAmount: Decimal;
        AmountToVendor: Decimal;
        AppliedServiceTaxSBCAmount: Decimal;
        AppliedServiceTaxSBCAmt: Decimal;
        ServiceTaxSBCAmt: Decimal;
        SumSvcTaxSBCAmount: Decimal;
        AppliedKKCessAmount: Decimal;
        AppliedKKCessAmt: Decimal;
        KKCessAmt: Decimal;
        SumKKCessAmount: Decimal;
        GSTCompAmount: array[20] of Decimal;
        j: Integer;
        TDSCompAmount: array[20] of Decimal;
        TDSComponentCode: array[20] of Integer;
        GSTComponentCodeName: array[20] of Code[20];
        TotalServiceTaxAmount: Decimal;
        TDSAmt: Decimal;
        ReceiveandInvLbl: Label 'Receive and Invoice';
        ReceiveLbl: Label 'Receive';
        InvLbl: Label 'Invoice';
        OrderPostLbl: Label 'Order Posting: %1', Comment = '%1 Receive Invoice';
        TotalLbl: Label 'Total %1', Comment = '%1 Amt';
        MustbeSpecLbl: Label '%1 must be specified.', Comment = '%1 Purchase Header';
        Musstbepec123Lbl: Label '%1 must be %2 for %3 %4.', Comment = '%1= Field Caption, %2= False , %3= Table Caption, %4= No.';
        DoesnotExistLbl: Label '%1 %2 does not exist.', Comment = '%1= Table/Field Caption, %2= No.';
        ClosingDateLbl: Label '%1 must not be a closing date.', Comment = '%1 Date';
        AllowedRangeLbl: Label '%1 is not within your allowed range of posting dates.', Comment = '%1 Date';
        NtihngToPostLbl: Label 'There is nothing to post.';
        ShipmentLbl: Label 'A drop shipment from a purchase order cannot be received and invoiced at the same time.';
        SalesOrderLbl: Label 'Invoice sales order %1 before invoicing this purchase order.', Comment = '%1 Sales Order No.';
        EntrerdLbl: Label '%1 must be entered.', Comment = '%1 No. Series.';
        SalesOrder1Lbl: Label '%1 must be entered on the sales order header.', Comment = '%1 Field';
        PurchDocLbl: Label 'Purchase Document: %1', Comment = '%1 Purchase Document No.';
        MustBe12Lbl: Label '%1 must be %2.', Comment = '%1= Field Caption, %2=Quantity';
        MustBeMessLbl: Label '%1 %2 %3 does not exist.', Comment = '%1= Gen. Posting Setup , %2= Gen. Bus. Posting Group of Purchase Line %3 = Gen. Prod. Posting Group of Purchase Line';
        MustBe01Lbl: Label '%1 must be 0 when %2 is 0.', Comment = '%1= Amount %2= Quantity';
        PurchHeadRecLbl: Label 'The %1 on the receipt is not the same as the %1 on the purchase header.', Comment = '%1 Field Caption';
        SignRecErrLbl: Label '%1 must have the same sign as the receipt.', Comment = '%1 Field Caption';
        ReturnShipLbl: Label '%1 must have the same sign as the return shipment.', Comment = '%1 Qty.To Invoice';
        ShipAndInvLbl: Label 'Ship and Invoice';
        ShipLbl: Label 'Ship';
        RetuOrderPosLbl: Label 'Return Order Posting: %1', Comment = '%1 Return Order Post';
        EnterYesLbl: Label 'Enter "Yes" in %1 and/or %2 and/or %3.', Comment = '%1= Receive , %2= Invoice, %3= Ship';
        ReceiptAtempInvLbl: Label 'Line %1 of the receipt %2, which you are attempting to invoice, has already been invoiced.', Comment = '%1= Receipt Line No. %2= Rceipt No.';
        ShipInvAlreLbl: Label 'Line %1 of the return shipment %2, which you are attempting to invoice, has already been invoiced.', Comment = '%1=Return Shipment Line No. %2= Return Shipment No.';
        ShipsamePurchHeadLbl: Label 'The %1 on the return shipment is not the same as the %1 on the purchase header.', Comment = '%1= Return Shipment Field';
        AttemptInvLbl: Label 'The quantity you are attempting to invoice is greater than the quantity in receipt %1.', Comment = '%1 = Receipt No.';
        QuantityInvLbl: Label 'The quantity you are attempting to invoice is greater than the quantity in return shipment %1.', Comment = '%1 Return Shipment No.';
        MustBeZeroLbl: Label '%1 must be zero.', Comment = '%1 = Return Qty. to Ship';
        MustBepurh1Lbl: Label '%1 must not be %2 for %3 %4.', Comment = '%1= Blocked, %2= Blocked Value, %3 = Table, %4 = Pay-to Vendor No.';
        PreinvLbl: Label '%1 must be completely preinvoiced before you can ship or invoice the line.', Comment = '%1=Prepmt. Line Amount';
        VatAmtSpecLbl: Label 'VAT Amount Specification in ';
        LocCuLbl: Label 'Local Currency';
        ExchRateLbl: Label 'Exchange rate: %1/%2', Comment = '%1= Relational Exch. Rate Amount, %2= Exchange Rate Amount';
        CanmostLbl: Label '%1 can at most be %2.', Comment = '%1= Table/Field Caption, %2= Field Value.';
        AtleastLbl: Label '%1 must be at least %2 %3 %4', Comment = '%1= Field Cation, %2=Field Value, %3= Table Value , %4= Field Value';
        AtleasRoundtLbl: Label '%1 must be at least %2', Comment = '%1= Field Cation, %2=Rounded Amount';
        IncTaxLbl: Label 'Total %1 Incl. Taxes', Comment = '%1= LCY/Curreny Code';
        ExcTaxLbl: Label 'Total %1 Excl. Taxes', Comment = '%1= LCY/Curreny Code';
        Purchase_Document___TestCaptionLbl: Label 'Purchase Document - Test';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Ship_toCaptionLbl: Label 'Ship-to';
        Buy_fromCaptionLbl: Label 'Buy-from';
        Pay_toCaptionLbl: Label 'Pay-to';
        Purchase_Header___Posting_Date_CaptionLbl: Label 'Posting Date';
        Purchase_Header___Document_Date_CaptionLbl: Label 'Document Date';
        Purchase_Header___Due_Date_CaptionLbl: Label 'Due Date';
        Purchase_Header___Pmt__Discount_Date_CaptionLbl: Label 'Pmt. Discount Date';
        Purchase_Header___Posting_Date__Control106CaptionLbl: Label 'Posting Date';
        Purchase_Header___Document_Date__Control107CaptionLbl: Label 'Document Date';
        Purchase_Header___Order_Date_CaptionLbl: Label 'Order Date';
        Purchase_Header___Expected_Receipt_Date_CaptionLbl: Label 'Expected Receipt Date';
        Purchase_Header___Due_Date__Control19CaptionLbl: Label 'Due Date';
        Purchase_Header___Pmt__Discount_Date__Control22CaptionLbl: Label 'Pmt. Discount Date';
        Purchase_Header___Posting_Date__Control112CaptionLbl: Label 'Posting Date';
        Purchase_Header___Document_Date__Control113CaptionLbl: Label 'Document Date';
        Purchase_Header___Posting_Date__Control130CaptionLbl: Label 'Posting Date';
        Purchase_Header___Document_Date__Control131CaptionLbl: Label 'Document Date';
        Header_DimensionsCaptionLbl: Label 'Header Dimensions';
        ErrorText_Number_CaptionLbl: Label 'Warning!';
        AmountCaptionLbl: Label 'Amount';
        Purchase_Line___Line_Discount_Amount_CaptionLbl: Label 'Line Discount Amount';
        Purchase_Line___Line_Discount___CaptionLbl: Label 'Line Disc. %';
        Direct_Unit_CostCaptionLbl: Label 'Direct Unit Cost';
        TempPurchLine__Inv__Discount_Amount_CaptionLbl: Label 'Inv. Discount Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        TempPurchLine__Excise_Amount_CaptionLbl: Label 'Excise Amount';
        TempPurchLine__Tax_Amount_CaptionLbl: Label 'Tax Amount';
        ServiceTaxAmtCaptionLbl: Label 'Service Tax Amount';
        TempPurchLine__Total_TDS_Including_SHE_CESS_CaptionLbl: Label 'Total TDS Incl. eCess Amount';
        TempPurchLine__Work_Tax_Amount_CaptionLbl: Label 'Work Tax Amount';
        Other_Taxes_AmountCaptionLbl: Label 'Other Taxes Amount';
        Charges_AmountCaptionLbl: Label 'Charges Amount';
        ServiceTaxECessAmtCaptionLbl: Label 'Service Tax eCess Amount';
        Svc_Tax_Amt__Applied_CaptionLbl: Label 'Svc Tax Amt (Applied)';
        Svc_Tax_eCess_Amt__Applied_CaptionLbl: Label 'Svc Tax eCess Amt (Applied)';
        ServiceTaxSHECessAmtCaptionLbl: Label 'Service Tax SHECess Amount';
        Svc_Tax_SHECess_Amt_Applied_CaptionLbl: Label 'Svc Tax SHECess Amt(Applied)';
        VATDiscountAmountCaptionLbl: Label 'Payment Discount on VAT';
        Line_DimensionsCaptionLbl: Label 'Line Dimensions';
        ErrorText_Number__Control103CaptionLbl: Label 'Warning!';
        VAT_Amount_SpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATAmountLine__VAT_Amount__Control98CaptionLbl: Label 'VAT Amount';
        VATAmountLine__VAT_Base__Control138CaptionLbl: Label 'VAT Base';
        VATAmountLine__VAT___CaptionLbl: Label 'VAT %';
        VATAmountLine__VAT_Identifier_CaptionLbl: Label 'VAT Identifier';
        VATAmountLine__Inv__Disc__Base_Amount__Control176CaptionLbl: Label 'Invoice Discount Base Amount';
        VATAmountLine__Line_Amount__Control175CaptionLbl: Label 'Line Amount';
        VATAmountLine__Invoice_Discount_Amount__Control177CaptionLbl: Label 'Invoice Discount Amount';
        VATAmountLine__VAT_Base_CaptionLbl: Label 'Continued';
        VATAmountLine__VAT_Base__Control139CaptionLbl: Label 'Continued';
        VATAmountLine__VAT_Base__Control137CaptionLbl: Label 'Total';
        VALVATAmountLCY_Control242CaptionLbl: Label 'VAT Amount';
        VALVATBaseLCY_Control243CaptionLbl: Label 'VAT Base';
        VATAmountLine__VAT____Control244CaptionLbl: Label 'VAT %';
        VATAmountLine__VAT_Identifier__Control245CaptionLbl: Label 'VAT Identifier';
        ContinuedCaptionLbl: Label 'Continued';
        ContinuedCaption_Control248Lbl: Label 'Continued';
        TotalCaptionLbl: Label 'Total';
        Item_Charge_SpecificationCaptionLbl: Label 'Item Charge Specification';
        DescriptionCaptionLbl: Label 'Description';
        PurchLine2_QuantityCaptionLbl: Label 'Assignable Qty';
        ContinuedCaption_Control197Lbl: Label 'Continued';
        TotalCaption_Control194Lbl: Label 'Total';
        ContinuedCaption_Control192Lbl: Label 'Continued';
        ServiceTaxSBCAmtCaptionLbl: Label 'SBC Amount';
        Svc_Tax_SBC_Amt__Applied_CaptionLbl: Label 'Svc Tax SBC Amt (Applied)';
        KKCessAmtCaptionLbl: Label 'KKC Amount';
        KKCess_Amt__Applied_CaptionLbl: Label 'KK Cess Amt (Applied)';
        CompanyRegistrationLbl: Label 'Company Registration No.';
        VendorRegistrationLbl: Label 'Vendor GST Reg No.';

    procedure TestJobFields(var PurchLine: Record "Purchase Line")
    var
        Job: Record Job;
        JT: Record "Job Task";
        PurchHeader2: Record "Purchase Header";
    begin
        if PurchLine."Job No." = '' then
            exit;

        if Job.Get(PurchLine."Job No.") then begin
            PurchHeader2.Get(PurchLine."Document Type", PurchLine."Document No.");
            if (PurchLine.Type <> Type::"G/L Account") and (PurchLine.Type <> Type::Item) then
                exit;

            if (PurchLine."Document Type" <> PurchLine."Document Type"::Invoice) and
               (PurchLine."Document Type" <> PurchLine."Document Type"::"Credit Memo")
            then
                exit;

            if not Job.Get(PurchLine."Job No.") then
                AddError(StrSubstNo(CanmostLbl, Job.TableCaption, PurchLine."Job No."))
            else
                if Job.Blocked <> Job.Blocked::" " then
                    AddError(StrSubstNo(AtleastLbl, Job.FieldCaption(Blocked), Job.Blocked, Job.TableCaption, PurchLine."Job No."));

            if PurchLine."Job Task No." = '' then
                AddError(StrSubstNo(MustbeSpecLbl, PurchLine.FieldCaption("Job Task No.")))
            else
                if not JT.Get(PurchLine."Job No.", PurchLine."Job Task No.") then
                    AddError(StrSubstNo(CanmostLbl, JT.TableCaption, PurchLine."Job Task No."))
        end;
    end;

    procedure AddDimToTempLine(PurchLine: Record "Purchase Line")
    var
        SourceCodesetup: Record "Source Code Setup";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        SourceCodesetup.Get();
        DimMgt.AddDimSource(DefaultDimSource, DimMgt.PurchLineTypeToTableID(PurchLine.Type), PurchLine."No.");
        DimMgt.AddDimSource(DefaultDimSource, Database::Job, PurchLine."Job No.");
        DimMgt.AddDimSource(DefaultDimSource, Database::"Responsibility Center", PurchLine."Responsibility Center");

        PurchLine."Shortcut Dimension 1 Code" := '';
        PurchLine."Shortcut Dimension 2 Code" := '';

        PurchLine."Dimension Set ID" :=
            DimMgt.GetDefaultDimID(
                DefaultDimSource,
                SourceCodesetup.Purchases,
                PurchLine."Shortcut Dimension 1 Code",
                PurchLine."Shortcut Dimension 2 Code",
                PurchLine."Dimension Set ID",
                Database::Vendor);
    end;

    procedure FilterAppliedEntries()
    var
        OldVendLedgEntry: Record "Vendor Ledger Entry";
        Vendor2: Record Vendor;
        Currency: Record Currency;
        GenLedgSetup: Record "General Ledger Setup";
        PurchLine3: Record "Purchase Line";
        ApplyingDate: Date;
        AmountforAppl: Decimal;
        AppliedAmount: Decimal;
        AppliedAmountLCY: Decimal;
        RemainingAmount: Decimal;
        AmountToBeApplied: Decimal;
        AppliedServiceTaxAmount: Decimal;
        AppliedServiceTaxEcessAmount: Decimal;
        AppliedServiceTaxSHEcessAmount: Decimal;
    begin
        Clear(RemainingAmount);
        Vendor2.Get("Purchase Header"."Pay-to Vendor No.");

        ApplyingDate := "Purchase Header"."Posting Date";
        Vend.Get("Purchase Header"."Pay-to Vendor No.");
        if "Purchase Header"."Applies-to Doc. No." <> '' then begin
            OldVendLedgEntry.Reset();
            OldVendLedgEntry.SetCurrentKey("Document No.", "Document Type", "Vendor No.");
            OldVendLedgEntry.SetRange("Document No.", "Purchase Header"."Applies-to Doc. No.");
            OldVendLedgEntry.SetRange("Document Type", "Purchase Header"."Applies-to Doc. Type");
            OldVendLedgEntry.SetRange("Vendor No.", "Purchase Header"."Pay-to Vendor No.");
            OldVendLedgEntry.SetRange(Open, true);
            OldVendLedgEntry.SetRange("On Hold", '');

            OldVendLedgEntry.FindFirst();
            if OldVendLedgEntry."Posting Date" > ApplyingDate then
                ApplyingDate := OldVendLedgEntry."Posting Date";

            OldVendLedgEntry.CalcFields("Remaining Amount");
            if "Purchase Header"."Currency Code" <> '' then begin
                Currency.Get("Purchase Header"."Currency Code");
                FindAmtForAppln(
                    OldVendLedgEntry,
                    AppliedAmount,
                    AppliedAmountLCY,
                    OldVendLedgEntry."Remaining Amount",
                    Currency."Amount Rounding Precision",
                    0);
            end else begin
                GenLedgSetup.Get();
                FindAmtForAppln(OldVendLedgEntry, AppliedAmount, AppliedAmountLCY,
                  OldVendLedgEntry."Remaining Amount", GenLedgSetup."Amount Rounding Precision", 0);
            end;

            AppliedAmountLCY := Abs(AppliedAmountLCY);
            AppliedAmountLCY := AppliedAmountLCY - 0;
            AppliedServiceTaxSHEcessAmount := Round(AppliedServiceTaxSHEcessAmount);
            AppliedServiceTaxEcessAmount := Round(AppliedServiceTaxEcessAmount);
            AppliedServiceTaxSBCAmount := Round(AppliedServiceTaxSBCAmount);
            AppliedKKCessAmount := Round(AppliedKKCessAmount);
            AppliedServiceTaxAmount := Round(
                AppliedServiceTaxAmount -
                AppliedServiceTaxEcessAmount -
                AppliedServiceTaxSHEcessAmount -
                AppliedServiceTaxSBCAmount -
                AppliedKKCessAmount);
            AppliedServiceTaxSHECessAmt += Round(AppliedServiceTaxSHEcessAmount);
            AppliedServiceTaxECessAmt += Round(AppliedServiceTaxEcessAmount);
            AppliedServiceTaxAmt += Round(AppliedServiceTaxAmount);
            AppliedServiceTaxSBCAmt += Round(AppliedServiceTaxSBCAmount);
            AppliedKKCessAmt += Round(AppliedKKCessAmount);
        end;

        if "Purchase Header"."Applies-to ID" <> '' then begin
            if not (Vend."Application Method" = Vend."Application Method"::"Apply to Oldest") then
                OldVendLedgEntry.SetFilter("Amount to Apply", '<>%1', 0);

            if PurchSetup."Appln. between Currencies" = PurchSetup."Appln. between Currencies"::None then
                OldVendLedgEntry.SetRange("Currency Code", "Purchase Header"."Currency Code");

            if OldVendLedgEntry.FindSet(false, false) then
                repeat
                    AppliedAmountLCY := Abs(AppliedAmountLCY);
                    if RemainingAmount > 0 then
                        if RemainingAmount >= Abs(AppliedAmountLCY) then
                            AmountToBeApplied := Abs(AppliedAmountLCY)
                        else
                            AmountToBeApplied := 0;

                    AppliedAmountLCY := AppliedAmountLCY - AmountToBeApplied;
                    AmountforAppl := AmountforAppl - AmountToBeApplied;
                    AppliedServiceTaxSHEcessAmount := Round(AppliedServiceTaxSHEcessAmount);
                    AppliedServiceTaxEcessAmount := Round(AppliedServiceTaxEcessAmount);
                    AppliedServiceTaxSBCAmount := Round(AppliedServiceTaxSBCAmount);
                    AppliedKKCessAmount := Round(AppliedKKCessAmount);
                    AppliedServiceTaxAmount := Round(
                        AppliedServiceTaxAmount -
                        AppliedServiceTaxEcessAmount -
                        AppliedServiceTaxSHEcessAmount -
                        AppliedServiceTaxSBCAmount -
                        AppliedKKCessAmount);
                    AppliedServiceTaxSHECessAmt += Round(AppliedServiceTaxSHEcessAmount);
                    AppliedServiceTaxECessAmt += Round(AppliedServiceTaxEcessAmount);
                    AppliedServiceTaxAmt += Round(AppliedServiceTaxAmount);
                    AppliedServiceTaxSBCAmt += Round(AppliedServiceTaxSBCAmount);
                    AppliedKKCessAmt += Round(AppliedKKCessAmount);
                until OldVendLedgEntry.Next() = 0;
        end;

        PurchLine3.CopyFilters("Purchase Line");
        PurchLine3 := "Purchase Line";
        if PurchLine3.Next() = 0 then begin
            ServiceTaxAmt -= Round(AppliedServiceTaxAmt);
            ServiceTaxECessAmt -= Round(AppliedServiceTaxECessAmt);
            ServiceTaxSHECessAmt -= Round(AppliedServiceTaxSHECessAmt);
            ServiceTaxSBCAmt -= Round(AppliedServiceTaxSBCAmt);
            KKCessAmt -= Round(AppliedKKCessAmt);
        end;

        if ServiceTaxSHECessAmt < 0 then
            ServiceTaxSHECessAmt := 0;

        if ServiceTaxECessAmt < 0 then
            ServiceTaxECessAmt := 0;

        if ServiceTaxAmt < 0 then
            ServiceTaxAmt := 0;

        if ServiceTaxSBCAmt < 0 then
            ServiceTaxSBCAmt := 0;

        if KKCessAmt < 0 then
            KKCessAmt := 0;

        if AppliedServiceTaxAmt = 0 then
            NetTotal := AmountToVendor
    end;

    procedure FindAmtForAppln(
        OldVendLedgEntry: Record "Vendor Ledger Entry";
        var AppliedAmount: Decimal;
        var AppliedAmountLCY: Decimal;
        OldRemainingAmtBeforeAppln: Decimal;
        ApplnRoundingPrecision: Decimal;
        AmountforAppl: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
        OldAppliedAmount: Decimal;
    begin
        if OldVendLedgEntry.GetFilter(Positive) <> '' then begin
            if OldVendLedgEntry."Amount to Apply" <> 0 then
                AppliedAmount := -OldVendLedgEntry."Amount to Apply"
            else
                AppliedAmount := -OldVendLedgEntry."Remaining Amount";
        end else
            if OldVendLedgEntry."Amount to Apply" <> 0 then begin
                if (CheckCalcPmtDisc(OldVendLedgEntry, ApplnRoundingPrecision, false, false, 0) and
                  (Abs(OldVendLedgEntry."Amount to Apply") >= Abs(
                      OldVendLedgEntry."Remaining Amount" -
                      OldVendLedgEntry."Remaining Pmt. Disc. Possible")) and
                  (Abs(AmountforAppl) >= Abs(OldVendLedgEntry."Amount to Apply" - OldVendLedgEntry."Remaining Pmt. Disc. Possible"))) or
                  OldVendLedgEntry."Accepted Pmt. Disc. Tolerance"
                then begin
                    AppliedAmount := -OldVendLedgEntry."Remaining Amount";
                    OldVendLedgEntry."Accepted Pmt. Disc. Tolerance" := false;
                end else
                    if Abs(AmountforAppl) <= Abs(OldVendLedgEntry."Amount to Apply") then
                        AppliedAmount := AmountforAppl
                    else
                        AppliedAmount := -OldVendLedgEntry."Amount to Apply";

            end else
                if Abs(AmountforAppl) < Abs(OldVendLedgEntry."Remaining Amount") then
                    AppliedAmount := AmountforAppl
                else
                    AppliedAmount := -OldVendLedgEntry."Remaining Amount";

        if PurchHeader."Currency Code" = OldVendLedgEntry."Currency Code" then begin
            AppliedAmountLCY := Round(AppliedAmount / OldVendLedgEntry."Original Currency Factor");
            OldAppliedAmount := AppliedAmount;
        end else begin
            if AppliedAmount = -OldVendLedgEntry."Remaining Amount" then
                OldAppliedAmount := -OldVendLedgEntry."Remaining Amount"
            else
                OldAppliedAmount := CurrExchRate.ExchangeAmount(
                    AppliedAmount,
                    PurchHeader."Currency Code",
                    OldVendLedgEntry."Currency Code",
                    PurchHeader."Posting Date");

            if PurchHeader."Currency Code" <> '' then
                AppliedAmountLCY := Round(OldAppliedAmount / OldVendLedgEntry."Original Currency Factor")
            else
                AppliedAmountLCY := Round(AppliedAmount / PurchHeader."Currency Factor");
        end;
    end;

    procedure InitializeRequest(
        NewReceiveShipOnNextPostReq: Boolean;
        NewInvOnNextPostReq: Boolean;
        NewShowDim: Boolean;
        NewShowItemChargeAssgnt: Boolean)
    begin
        ReceiveShipOnNextPostReq := NewReceiveShipOnNextPostReq;
        InvOnNextPostReq := NewInvOnNextPostReq;
        ShowDim := NewShowDim;
        ShowItemChargeAssgnt := NewShowItemChargeAssgnt;
    end;

    procedure CheckType(var PurchaseLine: Record "Purchase Line")
    begin
        case PurchaseLine.Type of
            Type::"G/L Account":
                begin
                    if (PurchaseLine."No." = '') and (PurchaseLine.Amount = 0) then
                        exit;

                    if PurchaseLine."No." <> '' then
                        if GLAcc.Get(PurchaseLine."No.") then begin
                            if GLAcc.Blocked then
                                AddError(
                                  StrSubstNo(
                                    Musstbepec123Lbl,
                                    GLAcc.FieldCaption(Blocked),
                                    false,
                                    GLAcc.TableCaption,
                                    PurchaseLine."No."));

                            if not GLAcc."Direct Posting" and (PurchaseLine."Line No." <= OrigMaxLineNo) then
                                AddError(
                                  StrSubstNo(
                                    Musstbepec123Lbl,
                                    GLAcc.FieldCaption("Direct Posting"),
                                    true,
                                    GLAcc.TableCaption,
                                    PurchaseLine."No."));
                        end else
                            AddError(
                              StrSubstNo(
                                DoesnotExistLbl,
                                GLAcc.TableCaption, PurchaseLine."No."));
                end;
            Type::Item:
                begin
                    if (PurchaseLine."No." = '') and (PurchaseLine.Quantity = 0) then
                        exit;

                    if PurchaseLine."No." <> '' then
                        if Item.Get(PurchaseLine."No.") then begin
                            if Item.Blocked then
                                AddError(
                                  StrSubstNo(
                                    Musstbepec123Lbl,
                                    Item.FieldCaption(Blocked),
                                    false,
                                    Item.TableCaption,
                                    PurchaseLine."No."));

                            if Item."Costing Method" = Item."Costing Method"::Specific then
                                if Item.Reserve = Item.Reserve::Always then begin
                                    PurchaseLine.CalcFields("Reserved Quantity");
                                    if (PurchaseLine.Signed(PurchaseLine.Quantity) < 0) and
                                        (Abs(PurchaseLine."Reserved Quantity") < Abs(PurchaseLine."Qty. to Receive"))
                                    then
                                        AddError(
                                          StrSubstNo(
                                            MustBe12Lbl,
                                            PurchaseLine.FieldCaption("Reserved Quantity"),
                                            PurchaseLine.Signed(PurchaseLine."Qty. to Receive")));
                                end;
                        end else
                            AddError(StrSubstNo(DoesnotExistLbl, Item.TableCaption, PurchaseLine."No."));
                end;
            Type::"Fixed Asset":
                begin
                    if (PurchaseLine."No." = '') and (PurchaseLine.Quantity = 0) then
                        exit;

                    if PurchaseLine."No." <> '' then
                        if FA.Get(PurchaseLine."No.") then begin
                            if FA.Blocked then
                                AddError(
                                  StrSubstNo(
                                    Musstbepec123Lbl,
                                    FA.FieldCaption(Blocked),
                                    false,
                                    FA.TableCaption,
                                    PurchaseLine."No."));

                            if FA.Inactive then
                                AddError(
                                  StrSubstNo(
                                    Musstbepec123Lbl,
                                    FA.FieldCaption(Inactive),
                                    false,
                                    FA.TableCaption,
                                    PurchaseLine."No."));
                        end else
                            AddError(
                              StrSubstNo(
                                DoesnotExistLbl,
                                FA.TableCaption,
                                PurchaseLine."No."));
                end;
        end;
    end;

    local procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;

    local procedure CheckRcptLines(PurchLine2: Record "Purchase Line")
    var
        TempPostedDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if Abs(RemQtyToBeInvoiced) > Abs(PurchLine2."Qty. to Receive") then begin
            PurchRcptLine.Reset();
            case PurchLine2."Document Type" of
                PurchLine2."Document Type"::Order:
                    begin
                        PurchRcptLine.SetCurrentKey("Order No.", "Order Line No.");
                        PurchRcptLine.SetRange("Order No.", PurchLine2."Document No.");
                        PurchRcptLine.SetRange("Order Line No.", PurchLine2."Line No.");
                    end;
                PurchLine2."Document Type"::Invoice:
                    begin
                        PurchRcptLine.SetRange("Document No.", PurchLine2."Receipt No.");
                        PurchRcptLine.SetRange("Line No.", PurchLine2."Receipt Line No.");
                    end;
            end;

            PurchRcptLine.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
            if PurchRcptLine.Find('-') then
                repeat
                    DimMgt.GetDimensionSet(TempPostedDimSetEntry, PurchRcptLine."Dimension Set ID");
                    if not DimMgt.CheckDimIDConsistency(
                         TempDimSetEntry,
                         TempPostedDimSetEntry,
                         DATABASE::"Purchase Line",
                         DATABASE::"Purch. Rcpt. Line")
                    then
                        AddError(DimMgt.GetDocDimConsistencyErr());

                    if PurchRcptLine."Buy-from Vendor No." <> PurchLine2."Buy-from Vendor No." then
                        AddError(
                          StrSubstNo(
                            PurchHeadRecLbl,
                            PurchLine2.FieldCaption("Buy-from Vendor No.")));

                    if PurchRcptLine.Type <> PurchLine2.Type then
                        AddError(
                          StrSubstNo(
                            PurchHeadRecLbl,
                            PurchLine2.FieldCaption(Type)));

                    if PurchRcptLine."No." <> PurchLine2."No." then
                        AddError(
                          StrSubstNo(
                            PurchHeadRecLbl,
                            PurchLine2.FieldCaption("No.")));

                    if PurchRcptLine."Gen. Bus. Posting Group" <> PurchLine2."Gen. Bus. Posting Group" then
                        AddError(
                          StrSubstNo(
                            PurchHeadRecLbl,
                            PurchLine2.FieldCaption("Gen. Bus. Posting Group")));

                    if PurchRcptLine."Gen. Prod. Posting Group" <> PurchLine2."Gen. Prod. Posting Group" then
                        AddError(
                          StrSubstNo(
                            PurchHeadRecLbl,
                            PurchLine2.FieldCaption("Gen. Prod. Posting Group")));

                    if PurchRcptLine."Location Code" <> PurchLine2."Location Code" then
                        AddError(
                          StrSubstNo(
                            PurchHeadRecLbl,
                            PurchLine2.FieldCaption("Location Code")));

                    if PurchRcptLine."Job No." <> PurchLine2."Job No." then
                        AddError(
                          StrSubstNo(
                            PurchHeadRecLbl,
                            PurchLine2.FieldCaption("Job No.")));

                    if PurchLine."Qty. to Invoice" * PurchRcptLine.Quantity < 0 then
                        AddError(StrSubstNo(SignRecErrLbl, PurchLine2.FieldCaption("Qty. to Invoice")));

                    QtyToBeInvoiced := RemQtyToBeInvoiced - PurchLine."Qty. to Receive";
                    if Abs(QtyToBeInvoiced) > Abs(PurchRcptLine.Quantity - PurchRcptLine."Quantity Invoiced") then
                        QtyToBeInvoiced := PurchRcptLine.Quantity - PurchRcptLine."Quantity Invoiced";

                    RemQtyToBeInvoiced := RemQtyToBeInvoiced - QtyToBeInvoiced;
                    PurchRcptLine."Quantity Invoiced" := PurchRcptLine."Quantity Invoiced" + QtyToBeInvoiced;
                until (PurchRcptLine.Next() = 0) or (Abs(RemQtyToBeInvoiced) <= Abs(PurchLine2."Qty. to Receive"))
            else
                AddError(
                  StrSubstNo(
                    ReceiptAtempInvLbl,
                    PurchLine2."Receipt Line No.",
                    PurchLine2."Receipt No."));
        end;

        if Abs(RemQtyToBeInvoiced) > Abs(PurchLine2."Qty. to Receive") then
            if PurchLine2."Document Type" = PurchLine2."Document Type"::Invoice then
                AddError(
                  StrSubstNo(
                    AttemptInvLbl,
                    PurchLine2."Receipt No."))
    end;

    local procedure CheckShptLines(PurchLine2: Record "Purchase Line")
    var
        TempPostedDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if Abs(RemQtyToBeInvoiced) > Abs(PurchLine2."Return Qty. to Ship") then begin
            ReturnShptLine.Reset();
            case PurchLine2."Document Type" of
                PurchLine2."Document Type"::"Return Order":
                    begin
                        ReturnShptLine.SetCurrentKey("Return Order No.", "Return Order Line No.");
                        ReturnShptLine.SetRange("Return Order No.", PurchLine2."Document No.");
                        ReturnShptLine.SetRange("Return Order Line No.", PurchLine2."Line No.");
                    end;
                PurchLine2."Document Type"::"Credit Memo":
                    begin
                        ReturnShptLine.SetRange("Document No.", PurchLine2."Return Shipment No.");
                        ReturnShptLine.SetRange("Line No.", PurchLine2."Return Shipment Line No.");
                    end;
            end;

            PurchRcptLine.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
            if ReturnShptLine.FindSet() then
                repeat
                    DimMgt.GetDimensionSet(TempPostedDimSetEntry, ReturnShptLine."Dimension Set ID");
                    if not DimMgt.CheckDimIDConsistency(
                         TempDimSetEntry,
                         TempPostedDimSetEntry,
                         DATABASE::"Purchase Line",
                         DATABASE::"Return Shipment Line")
                    then
                        AddError(DimMgt.GetDocDimConsistencyErr());

                    if ReturnShptLine."Buy-from Vendor No." <> PurchLine2."Buy-from Vendor No." then
                        AddError(
                          StrSubstNo(
                            ShipsamePurchHeadLbl,
                            PurchLine2.FieldCaption("Buy-from Vendor No.")));

                    if ReturnShptLine.Type <> PurchLine2.Type then
                        AddError(
                          StrSubstNo(
                            ShipsamePurchHeadLbl,
                            PurchLine2.FieldCaption(Type)));

                    if ReturnShptLine."No." <> PurchLine2."No." then
                        AddError(
                          StrSubstNo(
                            ShipsamePurchHeadLbl,
                            PurchLine2.FieldCaption("No.")));

                    if ReturnShptLine."Gen. Bus. Posting Group" <> PurchLine2."Gen. Bus. Posting Group" then
                        AddError(
                          StrSubstNo(
                            ShipsamePurchHeadLbl,
                            PurchLine2.FieldCaption("Gen. Bus. Posting Group")));

                    if ReturnShptLine."Gen. Prod. Posting Group" <> PurchLine2."Gen. Prod. Posting Group" then
                        AddError(
                          StrSubstNo(
                            ShipsamePurchHeadLbl,
                            PurchLine2.FieldCaption("Gen. Prod. Posting Group")));

                    if ReturnShptLine."Location Code" <> PurchLine2."Location Code" then
                        AddError(
                          StrSubstNo(
                            ShipsamePurchHeadLbl,
                            PurchLine2.FieldCaption("Location Code")));

                    if ReturnShptLine."Job No." <> PurchLine2."Job No." then
                        AddError(
                          StrSubstNo(
                            ShipsamePurchHeadLbl,
                            PurchLine2.FieldCaption("Job No.")));

                    if -PurchLine."Qty. to Invoice" * ReturnShptLine.Quantity < 0 then
                        AddError(StrSubstNo(ReturnShipLbl, PurchLine2.FieldCaption("Qty. to Invoice")));

                    QtyToBeInvoiced := RemQtyToBeInvoiced - PurchLine."Return Qty. to Ship";
                    if Abs(QtyToBeInvoiced) > Abs(ReturnShptLine.Quantity - ReturnShptLine."Quantity Invoiced") then
                        QtyToBeInvoiced := ReturnShptLine.Quantity - ReturnShptLine."Quantity Invoiced";

                    RemQtyToBeInvoiced := RemQtyToBeInvoiced - QtyToBeInvoiced;
                    ReturnShptLine."Quantity Invoiced" := ReturnShptLine."Quantity Invoiced" + QtyToBeInvoiced;
                until (ReturnShptLine.Next() = 0) or (Abs(RemQtyToBeInvoiced) <= Abs(PurchLine2."Return Qty. to Ship"))
            else
                AddError(
                  StrSubstNo(
                    ShipInvAlreLbl,
                    PurchLine2."Return Shipment Line No.",
                    PurchLine2."Return Shipment No."));
        end;

        if Abs(RemQtyToBeInvoiced) > Abs(PurchLine2."Return Qty. to Ship") then
            if PurchLine2."Document Type" = PurchLine2."Document Type"::"Credit Memo" then
                AddError(
                  StrSubstNo(
                    QuantityInvLbl,
                    PurchLine2."Return Shipment No."));
    end;

    local procedure IsInvtPosting(): Boolean
    var
        IsInvtPostingPurchLine: Record "Purchase Line";
    begin
        IsInvtPostingPurchLine.SetRange("Document Type", "Purchase Header"."Document Type");
        IsInvtPostingPurchLine.SetRange("Document No.", "Purchase Header"."No.");
        IsInvtPostingPurchLine.SetFilter(Type, '%1|%2', IsInvtPostingPurchLine.Type::Item, IsInvtPostingPurchLine.Type::"Charge (Item)");
        if IsInvtPostingPurchLine.IsEmpty then
            exit(false);

        if "Purchase Header".Receive then begin
            IsInvtPostingPurchLine.SetFilter("Qty. to Receive", '<>%1', 0);
            if not IsInvtPostingPurchLine.IsEmpty then
                exit(true);
        end;

        if "Purchase Header".Ship then begin
            IsInvtPostingPurchLine.SetFilter("Return Qty. to Ship", '<>%1', 0);
            if not IsInvtPostingPurchLine.IsEmpty then
                exit(true);
        end;

        if "Purchase Header".Invoice then begin
            IsInvtPostingPurchLine.SetFilter("Qty. to Invoice", '<>%1', 0);
            if not IsInvtPostingPurchLine.IsEmpty then
                exit(true);
        end;
    end;

    local procedure VerifyBuyFromVend(PurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."Buy-from Vendor No." = '' then
            AddError(StrSubstNo(MustbeSpecLbl, PurchaseHeader.FieldCaption("Buy-from Vendor No.")))
        else
            if Vend.Get(PurchaseHeader."Buy-from Vendor No.") then begin
                if Vend."Privacy Blocked" then
                    AddError(Vend.GetPrivacyBlockedGenericErrorText(Vend));

                if Vend.Blocked = Vend.Blocked::All then
                    AddError(
                      StrSubstNo(
                        MustBepurh1Lbl,
                        Vend.FieldCaption(Blocked),
                        Vend.Blocked,
                        Vend.TableCaption,
                        PurchaseHeader."Buy-from Vendor No."));
            end else
                AddError(
                  StrSubstNo(
                    DoesnotExistLbl,
                    Vend.TableCaption,
                    PurchaseHeader."Buy-from Vendor No."));

    end;

    local procedure VerifyPayToVend(PurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."Pay-to Vendor No." = '' then
            AddError(StrSubstNo(MustbeSpecLbl, PurchaseHeader.FieldCaption("Pay-to Vendor No.")))
        else
            if PurchaseHeader."Pay-to Vendor No." <> PurchaseHeader."Buy-from Vendor No." then
                if Vend.Get(PurchaseHeader."Pay-to Vendor No.") then begin
                    if Vend."Privacy Blocked" then
                        AddError(Vend.GetPrivacyBlockedGenericErrorText(Vend));

                    if Vend.Blocked = Vend.Blocked::All then
                        AddError(
                          StrSubstNo(
                            MustBepurh1Lbl,
                            Vend.FieldCaption(Blocked),
                            Vend.Blocked::All,
                            Vend.TableCaption,
                            PurchaseHeader."Pay-to Vendor No."));
                end else
                    AddError(
                      StrSubstNo(
                        DoesnotExistLbl,
                        Vend.TableCaption,
                        PurchaseHeader."Pay-to Vendor No."));
    end;

    local procedure VerifyPostingDate(PurchaseHeader: Record "Purchase Header")
    var
        InvtPeriodEndDate: Date;
    begin
        if PurchaseHeader."Posting Date" = 0D then
            AddError(StrSubstNo(MustbeSpecLbl, PurchaseHeader.FieldCaption("Posting Date")))
        else
            if PurchaseHeader."Posting Date" <> NormalDate(PurchaseHeader."Posting Date") then
                AddError(StrSubstNo(ClosingDateLbl, PurchaseHeader.FieldCaption("Posting Date")))
            else begin
                if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
                    if UserId <> '' then
                        if UserSetup.Get(UserId) then begin
                            AllowPostingFrom := UserSetup."Allow Posting From";
                            AllowPostingTo := UserSetup."Allow Posting To";
                        end;

                    if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
                        AllowPostingFrom := GLSetup."Allow Posting From";
                        AllowPostingTo := GLSetup."Allow Posting To";
                    end;

                    if AllowPostingTo = 0D then
                        AllowPostingTo := DMY2Date(31, 12, 9999);
                end;

                if (PurchaseHeader."Posting Date" < AllowPostingFrom) or (PurchaseHeader."Posting Date" > AllowPostingTo) then
                    AddError(StrSubstNo(AllowedRangeLbl, PurchaseHeader.FieldCaption("Posting Date")))
                else
                    if IsInvtPosting() then begin
                        InvtPeriodEndDate := PurchaseHeader."Posting Date";
                        if not InvtPeriod.IsValidDate(InvtPeriodEndDate) then
                            AddError(StrSubstNo(AllowedRangeLbl, Format(PurchaseHeader."Posting Date")))
                    end;
            end;
    end;

    local procedure CheckCalcPmtDisc(
        var OldVendLedgEntry: Record "Vendor Ledger Entry";
        ApplnRoundingPrecision: Decimal;
        CheckFilter: Boolean;
        CheckAmount: Boolean;
        AmountforAppl: Decimal): Boolean
    begin
        if ((OldVendLedgEntry."Document Type" = OldVendLedgEntry."Document Type"::Invoice) and
          (PurchHeader."Posting Date" <= OldVendLedgEntry."Pmt. Discount Date"))
        then begin
            if CheckFilter then begin
                if CheckAmount then begin
                    if (OldVendLedgEntry.GetFilter(Positive) <> '') or
                      (Abs(AmountforAppl) + ApplnRoundingPrecision >=
                      Abs(OldVendLedgEntry."Remaining Amount" - OldVendLedgEntry."Remaining Pmt. Disc. Possible"))
                    then
                        exit(true);
                end else
                    if (OldVendLedgEntry.GetFilter(Positive) <> '')
                    then
                        exit(true);

            end else begin
                if CheckAmount then
                    if (Abs(AmountforAppl) + ApplnRoundingPrecision >=
                      Abs(OldVendLedgEntry."Remaining Amount" - OldVendLedgEntry."Remaining Pmt. Disc. Possible"))
                    then
                        exit(true);

                exit(true);
            end;

            exit(true);
        end else
            exit(false);
    end;

    local procedure CalcQty(var PurchaseLine: Record "Purchase Line")
    begin
        if not "Purchase Header".Receive then
            PurchaseLine."Qty. to Receive" := 0;

        if not "Purchase Header".Ship then
            PurchaseLine."Return Qty. to Ship" := 0;

        if (PurchaseLine."Document Type" = PurchaseLine."Document Type"::Invoice) and (PurchaseLine."Receipt No." <> '') then begin
            PurchaseLine."Quantity Received" := PurchaseLine.Quantity;
            PurchaseLine."Qty. to Receive" := 0;
        end;

        if (PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Credit Memo") and
            (PurchaseLine."Return Shipment No." <> '')
        then begin
            PurchaseLine."Return Qty. Shipped" := PurchaseLine.Quantity;
            PurchaseLine."Return Qty. to Ship" := 0;
        end;

        if "Purchase Header".Invoice then begin
            if (PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Credit Memo") or
                (PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Return Order")
            then
                MaxQtyToBeInvoiced := PurchaseLine."Return Qty. to Ship" +
                    PurchaseLine."Return Qty. Shipped" -
                    PurchaseLine."Quantity Invoiced"
            else
                MaxQtyToBeInvoiced := PurchaseLine."Qty. to Receive" + PurchaseLine."Quantity Received" - PurchaseLine."Quantity Invoiced";

            if Abs(PurchaseLine."Qty. to Invoice") > Abs(MaxQtyToBeInvoiced) then
                PurchaseLine."Qty. to Invoice" := MaxQtyToBeInvoiced;
        end else
            PurchaseLine."Qty. to Invoice" := 0;

        if "Purchase Header".Receive then begin
            QtyToHandle := PurchaseLine."Qty. to Receive";
            QtyToHandleCaption := CopyStr(PurchaseLine.FieldCaption("Qty. to Receive"), 1, MaxStrLen(QtyToHandleCaption));
        end;

        if "Purchase Header".Ship then begin
            QtyToHandle := PurchaseLine."Return Qty. to Ship";
            QtyToHandleCaption := CopyStr(PurchaseLine.FieldCaption("Return Qty. to Ship"), 1, MaxStrLen(QtyToHandleCaption));
        end;
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
