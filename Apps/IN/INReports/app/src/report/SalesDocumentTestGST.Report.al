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
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Setup;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Setup;
using System.Security.User;
using System.Utilities;

report 18023 "Sales Document - Test GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/SalesDocumentTest.rdl';
    Caption = 'Sales Document - Test';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = where("Document Type" = filter(<> Quote));
            RequestFilterFields = "Document Type", "No.";
            RequestFilterHeading = 'Sales Document';

            column(Sales_Header_Document_Type; "Document Type")
            {
            }
            column(Sales_Header_No_; "No.")
            {
            }
            dataitem(PageCounter; Integer)
            {
                DataItemTableView = sorting(Number)
                                    where(Number = const(1));

                column(CompanyInfo_GST_RegistrationNo; CompanyInfo."GST Registration No.")
                {
                }
                column(Customer_GST_RegistrationNo; Cust."GST Registration No.")
                {
                }
                column(CompanyRegistrationLbl; CompanyRegistrationLbl)
                {
                }
                column(CustomerRegistrationLbl; CustomerRegistrationLbl)
                {
                }
                column(FORMAT_TODAY_0_4_; Format(Today(), 0, 4))
                {
                }
                column(COMPANYNAME; CompanyName)
                {
                }
                column(USERID; UserId())
                {
                }
                column(STRSUBSTNO_Text014_SalesHeaderFilter_; StrSubstNo(SalesDocLbl, SalesHeaderFilter))
                {
                }
                column(SalesHeaderFilter; SalesHeaderFilter)
                {
                }
                column(ShipInvText; ShipInvText)
                {
                }
                column(ReceiveInvText; ReceiveInvText)
                {
                }
                column(Sales_Header___Sell_to_Customer_No__; "Sales Header"."Sell-to Customer No.")
                {
                }
                column(ShipToAddr_8_; ShipToAddr[8])
                {
                }
                column(ShipToAddr_7_; ShipToAddr[7])
                {
                }
                column(ShipToAddr_6_; ShipToAddr[6])
                {
                }
                column(ShipToAddr_5_; ShipToAddr[5])
                {
                }
                column(ShipToAddr_4_; ShipToAddr[4])
                {
                }
                column(ShipToAddr_3_; ShipToAddr[3])
                {
                }
                column(ShipToAddr_2_; ShipToAddr[2])
                {
                }
                column(ShipToAddr_1_; ShipToAddr[1])
                {
                }
                column(SellToAddr_8_; SellToAddr[8])
                {
                }
                column(SellToAddr_7_; SellToAddr[7])
                {
                }
                column(SellToAddr_6_; SellToAddr[6])
                {
                }
                column(SellToAddr_5_; SellToAddr[5])
                {
                }
                column(SellToAddr_4_; SellToAddr[4])
                {
                }
                column(SellToAddr_3_; SellToAddr[3])
                {
                }
                column(SellToAddr_2_; SellToAddr[2])
                {
                }
                column(SellToAddr_1_; SellToAddr[1])
                {
                }
                column(Sales_Header___Ship_to_Code_; "Sales Header"."Ship-to Code")
                {
                }
                column(FORMAT__Sales_Header___Document_Type____________Sales_Header___No__; Format("Sales Header"."Document Type") + ' ' + "Sales Header"."No.")
                {
                }
                column(ShipReceiveOnNextPostReq; ShipReceiveOnNextPostReq)
                {
                }
                column(ShowCostAssignment; ShowCostAssignment)
                {
                }
                column(InvOnNextPostReq; InvOnNextPostReq)
                {
                }
                column(Sales_Header___VAT_Base_Discount___; "Sales Header"."VAT Base Discount %")
                {
                }
                column(SalesDocumentType; Format("Sales Header"."Document Type", 0, 2))
                {
                }
                column(BillToAddr_8_; BillToAddr[8])
                {
                }
                column(BillToAddr_7_; BillToAddr[7])
                {
                }
                column(BillToAddr_6_; BillToAddr[6])
                {
                }
                column(BillToAddr_5_; BillToAddr[5])
                {
                }
                column(BillToAddr_4_; BillToAddr[4])
                {
                }
                column(BillToAddr_3_; BillToAddr[3])
                {
                }
                column(BillToAddr_2_; BillToAddr[2])
                {
                }
                column(BillToAddr_1_; BillToAddr[1])
                {
                }
                column(Sales_Header___Bill_to_Customer_No__; "Sales Header"."Bill-to Customer No.")
                {
                }
                column(Sales_Header___Salesperson_Code_; "Sales Header"."Salesperson Code")
                {
                }
                column(Sales_Header___Your_Reference_; "Sales Header"."Your Reference")
                {
                }
                column(Sales_Header___Customer_Posting_Group_; "Sales Header"."Customer Posting Group")
                {
                }
                column(Sales_Header___Posting_Date_; Format("Sales Header"."Posting Date"))
                {
                }
                column(Sales_Header___Document_Date_; Format("Sales Header"."Document Date"))
                {
                }
                column(Sales_Header___Prices_Including_VAT_; "Sales Header"."Prices Including VAT")
                {
                }
                column(SalesHdrPricesIncludingVATFmt; Format("Sales Header"."Prices Including VAT"))
                {
                }
                column(Sales_Header___Payment_Terms_Code_; "Sales Header"."Payment Terms Code")
                {
                }
                column(Sales_Header___Payment_Discount___; "Sales Header"."Payment Discount %")
                {
                }
                column(Sales_Header___Due_Date_; Format("Sales Header"."Due Date"))
                {
                }
                column(Sales_Header___Customer_Disc__Group_; "Sales Header"."Customer Disc. Group")
                {
                }
                column(Sales_Header___Pmt__Discount_Date_; Format("Sales Header"."Pmt. Discount Date"))
                {
                }
                column(Sales_Header___Invoice_Disc__Code_; "Sales Header"."Invoice Disc. Code")
                {
                }
                column(Sales_Header___Shipment_Method_Code_; "Sales Header"."Shipment Method Code")
                {
                }
                column(Sales_Header___Payment_Method_Code_; "Sales Header"."Payment Method Code")
                {
                }
                column(Sales_Header___Customer_Posting_Group__Control104; "Sales Header"."Customer Posting Group")
                {
                }
                column(Sales_Header___Posting_Date__Control105; Format("Sales Header"."Posting Date"))
                {
                }
                column(Sales_Header___Document_Date__Control106; Format("Sales Header"."Document Date"))
                {
                }
                column(Sales_Header___Order_Date_; Format("Sales Header"."Order Date"))
                {
                }
                column(Sales_Header___Shipment_Date_; Format("Sales Header"."Shipment Date"))
                {
                }
                column(Sales_Header___Prices_Including_VAT__Control194; "Sales Header"."Prices Including VAT")
                {
                }
                column(Sales_Header___Payment_Terms_Code__Control18; "Sales Header"."Payment Terms Code")
                {
                }
                column(Sales_Header___Due_Date__Control19; Format("Sales Header"."Due Date"))
                {
                }
                column(Sales_Header___Pmt__Discount_Date__Control22; Format("Sales Header"."Pmt. Discount Date"))
                {
                }
                column(Sales_Header___Payment_Discount____Control23; "Sales Header"."Payment Discount %")
                {
                }
                column(Sales_Header___Payment_Method_Code__Control26; "Sales Header"."Payment Method Code")
                {
                }
                column(Sales_Header___Shipment_Method_Code__Control37; "Sales Header"."Shipment Method Code")
                {
                }
                column(Sales_Header___Customer_Disc__Group__Control100; "Sales Header"."Customer Disc. Group")
                {
                }
                column(Sales_Header___Invoice_Disc__Code__Control102; "Sales Header"."Invoice Disc. Code")
                {
                }
                column(Sales_Header___Customer_Posting_Group__Control130; "Sales Header"."Customer Posting Group")
                {
                }
                column(Sales_Header___Posting_Date__Control131; Format("Sales Header"."Posting Date"))
                {
                }
                column(Sales_Header___Document_Date__Control132; Format("Sales Header"."Document Date"))
                {
                }
                column(Sales_Header___Prices_Including_VAT__Control196; "Sales Header"."Prices Including VAT")
                {
                }
                column(Sales_Header___Applies_to_Doc__Type_; "Sales Header"."Applies-to Doc. Type")
                {
                }
                column(Sales_Header___Applies_to_Doc__No__; "Sales Header"."Applies-to Doc. No.")
                {
                }
                column(Sales_Header___Customer_Posting_Group__Control136; "Sales Header"."Customer Posting Group")
                {
                }
                column(Sales_Header___Posting_Date__Control137; Format("Sales Header"."Posting Date"))
                {
                }
                column(Sales_Header___Document_Date__Control138; Format("Sales Header"."Document Date"))
                {
                }
                column(Sales_Header___Prices_Including_VAT__Control198; "Sales Header"."Prices Including VAT")
                {
                }
                column(PageCounter_Number; Number)
                {
                }
                column(Sales_Document___TestCaption; Sales_Document___TestCaptionLbl)
                {
                }
                column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
                {
                }
                column(Sales_Header___Sell_to_Customer_No__Caption; "Sales Header".FieldCaption("Sell-to Customer No."))
                {
                }
                column(Ship_toCaption; Ship_toCaptionLbl)
                {
                }
                column(Sell_toCaption; Sell_toCaptionLbl)
                {
                }
                column(Sales_Header___Ship_to_Code_Caption; "Sales Header".FieldCaption("Ship-to Code"))
                {
                }
                column(Bill_toCaption; Bill_toCaptionLbl)
                {
                }
                column(Sales_Header___Bill_to_Customer_No__Caption; "Sales Header".FieldCaption("Bill-to Customer No."))
                {
                }
                column(Sales_Header___Salesperson_Code_Caption; "Sales Header".FieldCaption("Salesperson Code"))
                {
                }
                column(Sales_Header___Your_Reference_Caption; "Sales Header".FieldCaption("Your Reference"))
                {
                }
                column(Sales_Header___Customer_Posting_Group_Caption; "Sales Header".FieldCaption("Customer Posting Group"))
                {
                }
                column(Sales_Header___Posting_Date_Caption; Sales_Header___Posting_Date_CaptionLbl)
                {
                }
                column(Sales_Header___Document_Date_Caption; Sales_Header___Document_Date_CaptionLbl)
                {
                }
                column(Sales_Header___Prices_Including_VAT_Caption; "Sales Header".FieldCaption("Prices Including VAT"))
                {
                }
                column(Sales_Header___Payment_Terms_Code_Caption; "Sales Header".FieldCaption("Payment Terms Code"))
                {
                }
                column(Sales_Header___Payment_Discount___Caption; "Sales Header".FieldCaption("Payment Discount %"))
                {
                }
                column(Sales_Header___Due_Date_Caption; Sales_Header___Due_Date_CaptionLbl)
                {
                }
                column(Sales_Header___Customer_Disc__Group_Caption; "Sales Header".FieldCaption("Customer Disc. Group"))
                {
                }
                column(Sales_Header___Pmt__Discount_Date_Caption; Sales_Header___Pmt__Discount_Date_CaptionLbl)
                {
                }
                column(Sales_Header___Invoice_Disc__Code_Caption; "Sales Header".FieldCaption("Invoice Disc. Code"))
                {
                }
                column(Sales_Header___Shipment_Method_Code_Caption; "Sales Header".FieldCaption("Shipment Method Code"))
                {
                }
                column(Sales_Header___Payment_Method_Code_Caption; "Sales Header".FieldCaption("Payment Method Code"))
                {
                }
                column(Sales_Header___Customer_Posting_Group__Control104Caption; "Sales Header".FieldCaption("Customer Posting Group"))
                {
                }
                column(Sales_Header___Posting_Date__Control105Caption; Sales_Header___Posting_Date__Control105CaptionLbl)
                {
                }
                column(Sales_Header___Document_Date__Control106Caption; Sales_Header___Document_Date__Control106CaptionLbl)
                {
                }
                column(Sales_Header___Order_Date_Caption; Sales_Header___Order_Date_CaptionLbl)
                {
                }
                column(Sales_Header___Shipment_Date_Caption; Sales_Header___Shipment_Date_CaptionLbl)
                {
                }
                column(Sales_Header___Prices_Including_VAT__Control194Caption; "Sales Header".FieldCaption("Prices Including VAT"))
                {
                }
                column(Sales_Header___Payment_Terms_Code__Control18Caption; "Sales Header".FieldCaption("Payment Terms Code"))
                {
                }
                column(Sales_Header___Payment_Discount____Control23Caption; "Sales Header".FieldCaption("Payment Discount %"))
                {
                }
                column(Sales_Header___Due_Date__Control19Caption; Sales_Header___Due_Date__Control19CaptionLbl)
                {
                }
                column(Sales_Header___Pmt__Discount_Date__Control22Caption; Sales_Header___Pmt__Discount_Date__Control22CaptionLbl)
                {
                }
                column(Sales_Header___Shipment_Method_Code__Control37Caption; "Sales Header".FieldCaption("Shipment Method Code"))
                {
                }
                column(Sales_Header___Payment_Method_Code__Control26Caption; "Sales Header".FieldCaption("Payment Method Code"))
                {
                }
                column(Sales_Header___Customer_Disc__Group__Control100Caption; "Sales Header".FieldCaption("Customer Disc. Group"))
                {
                }
                column(Sales_Header___Invoice_Disc__Code__Control102Caption; "Sales Header".FieldCaption("Invoice Disc. Code"))
                {
                }
                column(Sales_Header___Customer_Posting_Group__Control130Caption; "Sales Header".FieldCaption("Customer Posting Group"))
                {
                }
                column(Sales_Header___Posting_Date__Control131Caption; Sales_Header___Posting_Date__Control131CaptionLbl)
                {
                }
                column(Sales_Header___Document_Date__Control132Caption; Sales_Header___Document_Date__Control132CaptionLbl)
                {
                }
                column(Sales_Header___Prices_Including_VAT__Control196Caption; "Sales Header".FieldCaption("Prices Including VAT"))
                {
                }
                column(Sales_Header___Applies_to_Doc__Type_Caption; "Sales Header".FieldCaption("Applies-to Doc. Type"))
                {
                }
                column(Sales_Header___Applies_to_Doc__No__Caption; "Sales Header".FieldCaption("Applies-to Doc. No."))
                {
                }
                column(Sales_Header___Customer_Posting_Group__Control136Caption; "Sales Header".FieldCaption("Customer Posting Group"))
                {
                }
                column(Sales_Header___Posting_Date__Control137Caption; Sales_Header___Posting_Date__Control137CaptionLbl)
                {
                }
                column(Sales_Header___Document_Date__Control138Caption; Sales_Header___Document_Date__Control138CaptionLbl)
                {
                }
                column(Sales_Header___Prices_Including_VAT__Control198Caption; "Sales Header".FieldCaption("Prices Including VAT"))
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
                    column(DimText_Control162; DimText)
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

                    dataitem("Sales Line"; "Sales Line")
                    {
                        DataItemLink = "Document Type" = field("Document Type"),
                                       "Document No." = field("No.");
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = sorting("Document Type", "Document No.", "Line No.");

                        column(Sales_Line_Document_Type; "Document Type")
                        {
                        }
                        column(Sales_Line_Document_No_; "Document No.")
                        {
                        }
                        column(Sales_Line_Line_No_; "Line No.")
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
                        column(TCSGSTCompAmount; TCSGSTCompAmount)
                        {
                        }
                        column(QtyToHandleCaption; QtyToHandleCaption)
                        {
                        }
                        column(Sales_Line__Type; "Sales Line".Type)
                        {
                        }
                        column(Sales_Line___No__; "Sales Line"."No.")
                        {
                        }
                        column(Sales_Line__Description; "Sales Line".Description)
                        {
                        }
                        column(Sales_Line__Quantity; "Sales Line".Quantity)
                        {
                        }
                        column(QtyToHandle; QtyToHandle)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(Sales_Line___Qty__to_Invoice_; "Sales Line"."Qty. to Invoice")
                        {
                        }
                        column(Sales_Line___Unit_Price_; "Sales Line"."Unit Price")
                        {
                            AutoFormatExpression = "Sales Line"."Currency Code";
                            AutoFormatType = 2;
                        }
                        column(Sales_Line___Line_Discount___; "Sales Line"."Line Discount %")
                        {
                        }
                        column(Sales_Line___Line_Amount_; "Sales Line"."Line Amount")
                        {
                            AutoFormatExpression = "Sales Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Sales_Line___Allow_Invoice_Disc__; "Sales Line"."Allow Invoice Disc.")
                        {
                        }
                        column(Sales_Line___Line_Discount_Amount_; "Sales Line"."Line Discount Amount")
                        {
                        }
                        column(SalesLineAllowInvoiceDiscFmt; Format("Sales Line"."Allow Invoice Disc."))
                        {
                        }
                        column(RoundLoop_RoundLoop_Number; Number)
                        {
                        }
                        column(Sales_Line___Inv__Discount_Amount_; "Sales Line"."Inv. Discount Amount")
                        {
                        }
                        column(TempSalesLine__Inv__Discount_Amount_; -TempSalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TempSalesLine__Line_Amount_; TempSalesLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(SumLineAmount; SumLineAmount)
                        {
                        }
                        column(SumInvDiscountAmount; SumInvDiscountAmount)
                        {
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(TempSalesLine__Line_Amount_____Sales_Line___Inv__Discount_Amount_; TempSalesLine."Line Amount" - TempSalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmount; VATAmount)
                        {
                        }
                        column(TempSalesLine__Excise_Amount_; 0)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TempSalesLine__Tax_Amount_; 0)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(ServiceTaxAmt; ServiceTaxAmt)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
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
                        column(ServiceTaxECessAmt; ServiceTaxECessAmt)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(SalesLine__Total_TDS_TCS_Incl__SHE_CESS_; 0)
                        {
                        }
                        column(TCSAmountApplied; TCSAmountApplied)
                        {
                        }
                        column(AppliedServiceTaxAmt; AppliedServiceTaxAmt)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AppliedServiceTaxECessAmt; AppliedServiceTaxECessAmt)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(ServiceTaxSHECessAmt; ServiceTaxSHECessAmt)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AppliedServiceTaxSHECessAmt; AppliedServiceTaxSHECessAmt)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText_Control1500007; TotalInclVATText)
                        {
                        }
                        column(TotalAmount; TotalAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(SumSalesLineGSTAmount; SumSalesLineGSTAmount)
                        {
                        }
                        column(SumSalesLineExciseAmount; SumSalesLineExciseAmount)
                        {
                        }
                        column(SumSalesLineTaxAmount; SumSalesLineTaxAmount)
                        {
                        }
                        column(SumLineServiceTaxAmount; SumLineServiceTaxAmount)
                        {
                        }
                        column(SumLineServiceTaxECessAmount; SumLineServiceTaxECessAmount)
                        {
                        }
                        column(SumLineServiceTaxSHECessAmount; SumLineServiceTaxSHECessAmount)
                        {
                        }
                        column(SumSalesLineAmountToCusTomer; SumSalesLineAmountToCusTomer)
                        {
                        }
                        column(SumTotalTDSTCSInclSHECESS; SumTotalTDSTCSInclSHECESS)
                        {
                        }
                        column(VATDiscountAmount; -VATDiscountAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText_Control191; TotalInclVATText)
                        {
                        }
                        column(VATAmountLine_VATAmountText_Control189; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(VATBaseAmount___VATAmount; VATBaseAmount + VATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmount_Control188; VATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalExclVATText_Control186; TotalExclVATText)
                        {
                        }
                        column(VATBaseAmount; VATBaseAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Sales_Line___No__Caption; "Sales Line".FieldCaption("No."))
                        {
                        }
                        column(Sales_Line__DescriptionCaption; "Sales Line".FieldCaption(Description))
                        {
                        }
                        column(Sales_Line___Qty__to_Invoice_Caption; "Sales Line".FieldCaption("Qty. to Invoice"))
                        {
                        }
                        column(Unit_PriceCaption; Unit_PriceCaptionLbl)
                        {
                        }
                        column(Sales_Line___Line_Discount___Caption; Sales_Line___Line_Discount___CaptionLbl)
                        {
                        }
                        column(Sales_Line___Allow_Invoice_Disc__Caption; "Sales Line".FieldCaption("Allow Invoice Disc."))
                        {
                        }
                        column(Sales_Line___Line_Discount_Amount_Caption; Sales_Line___Line_Discount_Amount_CaptionLbl)
                        {
                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {
                        }
                        column(Sales_Line__TypeCaption; "Sales Line".FieldCaption(Type))
                        {
                        }
                        column(Sales_Line__QuantityCaption; "Sales Line".FieldCaption(Quantity))
                        {
                        }
                        column(TempSalesLine__Inv__Discount_Amount_Caption; TempSalesLine__Inv__Discount_Amount_CaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(TempSalesLine__Excise_Amount_Caption; TempSalesLine__Excise_Amount_CaptionLbl)
                        {
                        }
                        column(TempSalesLine__Tax_Amount_Caption; TempSalesLine__Tax_Amount_CaptionLbl)
                        {
                        }
                        column(ServiceTaxAmtCaption; ServiceTaxAmtCaptionLbl)
                        {
                        }
                        column(Charges_AmountCaption; Charges_AmountCaptionLbl)
                        {
                        }
                        column(Other_Taxes_AmountCaption; Other_Taxes_AmountCaptionLbl)
                        {
                        }
                        column(ServiceTaxECessAmtCaption; ServiceTaxECessAmtCaptionLbl)
                        {
                        }
                        column(CGSTCaption; CGSTLbl)
                        {
                        }
                        column(SGSTCaption; SGSTLbl)
                        {
                        }
                        column(IGSTCaption; IGSTLbl)
                        {
                        }
                        column(UGSTCaption; UGSTLbl)
                        {
                        }
                        column(TCS_AmountCaption; TCS_AmountCaptionLbl)
                        {
                        }
                        column(TCS_Amount__Applied_Caption; TCS_Amount__Applied_CaptionLbl)
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
                        column(ServiceTaxSBCAmt; ServiceTaxSBCAmt)
                        {
                        }
                        column(AppliedServiceTaxSBCAmt; AppliedServiceTaxSBCAmt)
                        {
                        }
                        column(SumSvcTaxSBCAmount; SumSvcTaxSBCAmount)
                        {
                        }
                        column(ServiceTaxSBCAmtCaption; ServiceTaxSBCAmtCaptionLbl)
                        {
                        }
                        column(Svc_Tax_SBC_Amt__Applied_Caption; Svc_Tax_SBC_Amt__Applied_CaptionLbl)
                        {
                        }
                        column(KKCessAmt; KKCessAmt)
                        {
                        }
                        column(AppliedKKCessAmt; AppliedKKCessAmt)
                        {
                        }
                        column(SumKKCessAmount; SumKKCessAmount)
                        {
                        }
                        column(KKCessAmtCaption; KKCessAmtCaptionLbl)
                        {
                        }
                        column(KK_Cess_Amt__Applied_Caption; KK_Cess_Amt__Applied_CaptionLbl)
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText_Control159; DimText)
                            {
                            }
                            column(DimensionLoop2_Number; Number)
                            {
                            }
                            column(DimText_Control161; DimText)
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
                            var
                                TaxTrnasactionValue: Record "Tax Transaction Value";
                                TaxTrnasactionValue1: Record "Tax Transaction Value";
                                TaxTrnasactionValue2: Record "Tax Transaction Value";
                            begin
                                if (SalesLine.Type <> SalesLine.Type::" ") then begin
                                    j := 1;
                                    TaxTrnasactionValue.Reset();
                                    TaxTrnasactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
                                    TaxTrnasactionValue.SetRange("Tax Type", 'GST');
                                    TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                                    TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                                    if TaxTrnasactionValue.FindSet() then
                                        repeat
                                            j := TaxTrnasactionValue."Value ID";
                                            GSTComponentCode[j] := TaxTrnasactionValue."Value ID";
                                            TaxTrnasactionValue1.Reset();
                                            TaxTrnasactionValue1.SetRange("Tax Record ID", SalesLine.RecordId);
                                            TaxTrnasactionValue1.SetRange("Tax Type", 'GST');
                                            TaxTrnasactionValue1.SetRange("Value Type", TaxTrnasactionValue1."Value Type"::COMPONENT);
                                            TaxTrnasactionValue1.SetRange("Value ID", GSTComponentCode[j]);
                                            if TaxTrnasactionValue1.FindSet() then
                                                repeat
                                                    GSTCompAmount[j] += TaxTrnasactionValue1.Amount;
                                                    NNC_TotalGST += TaxTrnasactionValue1.Amount;
                                                until TaxTrnasactionValue1.Next() = 0;

                                            j += 1;
                                        until TaxTrnasactionValue.Next() = 0;
                                end;

                                TaxTrnasactionValue.Reset();
                                TaxTrnasactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
                                TaxTrnasactionValue.SetRange("Tax Type", 'TCS');
                                TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                                TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                                if TaxTrnasactionValue.FindSet() then
                                    repeat
                                        TCSComponentCode[j] := TaxTrnasactionValue."Value ID";
                                        TaxTrnasactionValue2.Reset();
                                        TaxTrnasactionValue2.SetRange("Tax Record ID", SalesLine.RecordId);
                                        TaxTrnasactionValue2.SetRange("Tax Type", 'TCS');
                                        TaxTrnasactionValue2.SetRange("Value Type", TaxTrnasactionValue2."Value Type"::COMPONENT);
                                        TaxTrnasactionValue2.SetRange("Value ID", TCSComponentCode[j]);
                                        if TaxTrnasactionValue2.FindSet() then
                                            repeat
                                                TCSGSTCompAmount += TaxTrnasactionValue2.Amount;
                                            until TaxTrnasactionValue2.Next() = 0;
                                        TCSGSTCompAmount := Round(TCSGSTCompAmount, 1);
                                        j += 1;
                                    until TaxTrnasactionValue.Next() = 0;

                                TaxTrnasactionValue.Reset();
                                TaxTrnasactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
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

                                SumLineAmount := SumLineAmount + TempSalesLine."Line Amount";
                                SumInvDiscountAmount := SumInvDiscountAmount + TempSalesLine."Inv. Discount Amount";

                                SumSalesLineExciseAmount := SumSalesLineExciseAmount;
                                SumSalesLineTaxAmount := SumSalesLineTaxAmount;
                                SumLineServiceTaxAmount := SumLineServiceTaxAmount;
                                SumLineServiceTaxECessAmount := SumLineServiceTaxECessAmount;
                                SumLineServiceTaxSHECessAmount := SumLineServiceTaxSHECessAmount;
                                SumTotalTDSTCSInclSHECESS := SumTotalTDSTCSInclSHECESS;
                                SumSvcTaxSBCAmount := SumSvcTaxSBCAmount;
                                SumSalesLineAmountToCusTomer := SumSalesLineAmountToCusTomer;
                                TotalAmount := SumLineAmount -
                                    SumInvDiscountAmount +
                                    SumSalesLineExciseAmount +
                                    SumSalesLineTaxAmount +
                                    ServiceTaxAmt +
                                    ServiceTaxECessAmt +
                                    ServiceTaxSHECessAmt +
                                    OtherTaxesAmount +
                                    ChargesAmount +
                                    SumTotalTDSTCSInclSHECESS +
                                    AppliedServiceTaxAmt +
                                    AppliedServiceTaxECessAmt +
                                    AppliedServiceTaxSHECessAmt +
                                    ServiceTaxSBCAmt +
                                    AppliedServiceTaxSBCAmt +
                                    KKCessAmt +
                                    AppliedKKCessAmt +
                                    SumSalesLineGSTAmount +
                                    NNC_TotalGST +
                                    TCSGSTCompAmount;
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

                            column(ErrorText_Number__Control97; ErrorText[Number])
                            {
                            }
                            column(LineErrorCounter_Number; Number)
                            {
                            }
                            column(ErrorText_Number__Control97Caption; ErrorText_Number__Control97CaptionLbl)
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
                                TempSalesLine.FindFirst()
                            else
                                TempSalesLine.Next();

                            "Sales Line" := TempSalesLine;

                            DimSetEntry2.SetRange("Dimension Set ID", "Sales Line"."Dimension Set ID");
                            DimMgt.GetDimensionSet(TempDimSetEntry, "Sales Line"."Dimension Set ID");
                            FilterAppliedEntries();

                            if "Sales Line"."Document Type" in [
                                "Sales Line"."Document Type"::"Return Order",
                                "Sales Line"."Document Type"::"Credit Memo"]
                            then begin
                                if "Sales Line"."Document Type" = "Sales Line"."Document Type"::"Credit Memo" then begin
                                    if ("Sales Line"."Return Qty. to Receive" <> "Sales Line".Quantity) and
                                        ("Sales Line"."Return Receipt No." = '')
                                    then
                                        AddError(
                                            StrSubstNo(
                                                ReversedQuantiLbl,
                                                "Sales Line".FieldCaption("Return Qty. to Receive"),
                                                "Sales Line".Quantity));

                                    if "Sales Line"."Qty. to Invoice" <> "Sales Line".Quantity then
                                        AddError(StrSubstNo(ReversedQuantiLbl, "Sales Line".FieldCaption("Qty. to Invoice"), "Sales Line".Quantity));
                                end;

                                if "Sales Line"."Qty. to Ship" <> 0 then
                                    AddError(StrSubstNo(QtyToShipLbl, "Sales Line".FieldCaption("Qty. to Ship")));
                            end else begin
                                if "Sales Line"."Document Type" = "Sales Line"."Document Type"::Invoice then begin
                                    if ("Sales Line"."Qty. to Ship" <> "Sales Line".Quantity) and ("Sales Line"."Shipment No." = '') then
                                        AddError(StrSubstNo(ReversedQuantiLbl, "Sales Line".FieldCaption("Qty. to Ship"), "Sales Line".Quantity));

                                    if "Sales Line"."Qty. to Invoice" <> "Sales Line".Quantity then
                                        AddError(StrSubstNo(ReversedQuantiLbl, "Sales Line".FieldCaption("Qty. to Invoice"), "Sales Line".Quantity));
                                end;

                                if "Sales Line"."Return Qty. to Receive" <> 0 then
                                    AddError(StrSubstNo(QtyToShipLbl, "Sales Line".FieldCaption("Return Qty. to Receive")));
                            end;

                            if not "Sales Header".Ship then
                                "Sales Line"."Qty. to Ship" := 0;

                            if not "Sales Header".Receive then
                                "Sales Line"."Return Qty. to Receive" := 0;

                            if ("Sales Line"."Document Type" = "Sales Line"."Document Type"::Invoice) and ("Sales Line"."Shipment No." <> '') then begin
                                "Sales Line"."Quantity Shipped" := "Sales Line".Quantity;
                                "Sales Line"."Qty. to Ship" := 0;
                            end;

                            if ("Sales Line"."Document Type" = "Sales Line"."Document Type"::"Credit Memo") and ("Sales Line"."Return Receipt No." <> '') then begin
                                "Sales Line"."Return Qty. Received" := "Sales Line".Quantity;
                                "Sales Line"."Return Qty. to Receive" := 0;
                            end;

                            if "Sales Header".Invoice then begin
                                if "Sales Line"."Document Type" in [
                                    "Sales Line"."Document Type"::"Return Order",
                                    "Sales Line"."Document Type"::"Credit Memo"]
                                then
                                    MaxQtyToBeInvoiced := "Sales Line"."Return Qty. to Receive" +
                                        "Sales Line"."Return Qty. Received" -
                                        "Sales Line"."Quantity Invoiced"
                                else
                                    MaxQtyToBeInvoiced := "Sales Line"."Qty. to Ship" + "Sales Line"."Quantity Shipped" - "Sales Line"."Quantity Invoiced";

                                if Abs("Sales Line"."Qty. to Invoice") > Abs(MaxQtyToBeInvoiced) then
                                    "Sales Line"."Qty. to Invoice" := MaxQtyToBeInvoiced;
                            end else
                                "Sales Line"."Qty. to Invoice" := 0;

                            if "Sales Line"."Gen. Prod. Posting Group" <> '' then begin
                                if ("Sales Header"."Document Type" in
                                     ["Sales Header"."Document Type"::"Return Order",
                                      "Sales Header"."Document Type"::"Credit Memo"]) and
                                   ("Sales Header"."Applies-to Doc. Type" = "Sales Header"."Applies-to Doc. Type"::Invoice) and
                                   ("Sales Header"."Applies-to Doc. No." <> '')
                                then begin
                                    CustLedgEntry.SetCurrentKey("Document No.");
                                    CustLedgEntry.SetRange("Customer No.", "Sales Header"."Bill-to Customer No.");
                                    CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
                                    CustLedgEntry.SetRange("Document No.", "Sales Header"."Applies-to Doc. No.");
                                    if (not CustLedgEntry.FindLast()) and (not ApplNoError) then begin
                                        ApplNoError := true;
                                        AddError(
                                            StrSubstNo(
                                                AppliesToDocLbl,
                                                "Sales Header".FieldCaption("Applies-to Doc. No."),
                                                "Sales Header"."Applies-to Doc. No."));
                                    end;
                                end else
                                    if not VATPostingSetup.Get("Sales Line"."VAT Bus. Posting Group", "Sales Line"."VAT Prod. Posting Group") then
                                        AddError(
                                            StrSubstNo(
                                                DepricBusLbl,
                                                VATPostingSetup.TableCaption,
                                                "Sales Line"."VAT Bus. Posting Group",
                                                "Sales Line"."VAT Prod. Posting Group"));

                                if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" then
                                    if ("Sales Header"."VAT Registration No." = '') and (not VATNoError) then begin
                                        VATNoError := true;
                                        AddError(
                                            StrSubstNo(
                                                VatRegNoCustLbl,
                                                "Sales Header".FieldCaption("VAT Registration No.")));
                                    end;
                            end;

                            if "Sales Line".Quantity <> 0 then begin
                                if "Sales Line"."No." = '' then
                                    AddError(StrSubstNo(TypeFielsLbl, "Sales Line".Type, "Sales Line".FieldCaption("No.")));

                                if "Sales Line".Type = "Sales Line".Type::" " then
                                    AddError(StrSubstNo(MustbeSpecLbl, "Sales Line".FieldCaption(Type)));
                            end else
                                if "Sales Line".Amount <> 0 then
                                    AddError(StrSubstNo(AmtLbl, "Sales Line".FieldCaption(Amount), "Sales Line".FieldCaption(Quantity)));

                            if "Sales Line"."Drop Shipment" then begin
                                if "Sales Line".Type <> Type::Item then
                                    AddError(DropShipPossLbl);

                                if ("Sales Line"."Qty. to Ship" <> 0) and ("Sales Line"."Purch. Order Line No." = 0) then begin
                                    AddError(StrSubstNo(ShipOrderLbl, "Sales Line"."Line No."));
                                    AddError(DropShipAssoLbl);
                                end;
                            end;

                            SalesLine := "Sales Line";
                            if not ("Sales Line"."Document Type" in [
                                "Sales Line"."Document Type"::"Return Order",
                                "Sales Line"."Document Type"::"Credit Memo"])
                            then begin
                                SalesLine."Qty. to Ship" := -SalesLine."Qty. to Ship";
                                SalesLine."Qty. to Invoice" := -SalesLine."Qty. to Invoice";
                            end;

                            RemQtyToBeInvoiced := SalesLine."Qty. to Invoice";

                            case "Sales Line"."Document Type" of
                                "Sales Line"."Document Type"::"Return Order", "Sales Line"."Document Type"::"Credit Memo":
                                    CheckRcptLines("Sales Line");
                                "Sales Line"."Document Type"::Order, "Sales Line"."Document Type"::Invoice:
                                    CheckShptLines("Sales Line");
                            end;

                            if ("Sales Line".Type.AsInteger() >= "Sales Line".Type::"G/L Account".AsInteger()) and
                                ("Sales Line"."Qty. to Invoice" <> 0)
                            then begin
                                if not GenPostingSetup.Get("Sales Line"."Gen. Bus. Posting Group", "Sales Line"."Gen. Prod. Posting Group") then
                                    AddError(
                                        StrSubstNo(
                                            DepricBusLbl,
                                            GenPostingSetup.TableCaption,
                                            "Sales Line"."Gen. Bus. Posting Group",
                                            "Sales Line"."Gen. Prod. Posting Group"));

                                if not VATPostingSetup.Get("Sales Line"."VAT Bus. Posting Group", "Sales Line"."VAT Prod. Posting Group") then
                                    AddError(
                                        StrSubstNo(
                                            DepricBusLbl,
                                            VATPostingSetup.TableCaption,
                                            "Sales Line"."VAT Bus. Posting Group",
                                            "Sales Line"."VAT Prod. Posting Group"));
                            end;

                            if "Sales Line"."Prepayment %" > 0 then
                                if not "Sales Line"."Prepayment Line" and ("Sales Line".Quantity > 0) then begin
                                    Fraction := ("Sales Line"."Qty. to Invoice" + "Sales Line"."Quantity Invoiced") / "Sales Line".Quantity;
                                    if Fraction > 1 then
                                        Fraction := 1;

                                    case true of
                                        (Fraction * "Sales Line"."Line Amount" < "Sales Line"."Prepmt Amt to Deduct") and
                                        ("Sales Line"."Prepmt Amt to Deduct" <> 0):
                                            AddError(
                                                StrSubstNo(
                                                    PrempAmtLbl,
                                                    "Sales Line".FieldCaption("Prepmt Amt to Deduct"),
                                                    Round(Fraction * "Sales Line"."Line Amount", GLSetup."Amount Rounding Precision")));
                                        (1 - Fraction) * "Sales Line"."Line Amount" <
                                            "Sales Line"."Prepmt. Amt. Inv." -
                                            "Sales Line"."Prepmt Amt Deducted" -
                                            "Sales Line"."Prepmt Amt to Deduct":
                                            AddError(
                                                StrSubstNo(
                                                    PrempAmtdeductLbl,
                                                    "Sales Line".FieldCaption("Prepmt Amt to Deduct"),
                                                    Round(
                                                        "Sales Line"."Prepmt. Amt. Inv." -
                                                            "Sales Line"."Prepmt Amt Deducted" -
                                                            (1 - Fraction) * "Sales Line"."Line Amount",
                                                        GLSetup."Amount Rounding Precision")));
                                    end;
                                end;

                            if not "Sales Line"."Prepayment Line" and ("Sales Line"."Prepmt. Line Amount" > 0) then
                                if "Sales Line"."Prepmt. Line Amount" > "Sales Line"."Prepmt. Amt. Inv." then
                                    AddError(StrSubstNo(ShipcomplpreinvLbl, "Sales Line".FieldCaption("Prepmt. Line Amount")));

                            CheckType("Sales Line");

                            if "Sales Line"."Line No." > OrigMaxLineNo then begin
                                AddDimToTempLine("Sales Line");
                                if not DimMgt.CheckDimIDComb("Sales Line"."Dimension Set ID") then
                                    AddError(DimMgt.GetDimCombErr());

                                if not DimMgt.CheckDimValuePosting(TableID, No, "Sales Line"."Dimension Set ID") then
                                    AddError(DimMgt.GetDimValuePostingErr());
                            end else begin
                                if not DimMgt.CheckDimIDComb("Sales Line"."Dimension Set ID") then
                                    AddError(DimMgt.GetDimCombErr());

                                TableID[1] := DimMgt.SalesLineTypeToTableID("Sales Line".Type);
                                No[1] := "Sales Line"."No.";
                                TableID[2] := Database::Job;
                                No[2] := "Sales Line"."Job No.";

                                if not DimMgt.CheckDimValuePosting(TableID, No, "Sales Line"."Dimension Set ID") then
                                    AddError(DimMgt.GetDimValuePostingErr());
                            end;
                        end;

                        trigger OnPreDataItem()
                        begin
                            VATNoError := false;
                            ApplNoError := false;

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

                            SumLineAmount := 0;
                            SumInvDiscountAmount := 0;
                            SumSalesLineExciseAmount := 0;
                            SumSalesLineTaxAmount := 0;
                            SumLineServiceTaxAmount := 0;
                            SumLineServiceTaxECessAmount := 0;
                            SumLineServiceTaxSHECessAmount := 0;
                            SumTotalTDSTCSInclSHECESS := 0;
                            SumSalesLineAmountToCusTomer := 0;
                            SumSvcTaxSBCAmount := 0;
                            SumKKCessAmount := 0;
                            SumSalesLineGSTAmount := 0;
                        end;
                    }
                    dataitem(VATCounter; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(VATAmountLine__VAT_Amount_; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base_; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Sales Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount_; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount_; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount_; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount__Control150; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base__Control151; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Sales Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT___; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmountLine__VAT_Identifier_; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control173; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control171; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount__Control169; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount__Control175; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base__Control176; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Sales Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control177; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control178; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount__Control179; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount__Control181; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base__Control182; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Sales Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control183; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control184; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount__Control185; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATCounter_Number; Number)
                        {
                        }
                        column(VATAmountLine__VAT_Amount__Control150Caption; VATAmountLine__VAT_Amount__Control150CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Base__Control151Caption; VATAmountLine__VAT_Base__Control151CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT___Caption; VATAmountLine__VAT___CaptionLbl)
                        {
                        }
                        column(VAT_Amount_SpecificationCaption; VAT_Amount_SpecificationCaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Identifier_Caption; VATAmountLine__VAT_Identifier_CaptionLbl)
                        {
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control173Caption; VATAmountLine__Invoice_Discount_Amount__Control173CaptionLbl)
                        {
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control171Caption; VATAmountLine__Inv__Disc__Base_Amount__Control171CaptionLbl)
                        {
                        }
                        column(VATAmountLine__Line_Amount__Control169Caption; VATAmountLine__Line_Amount__Control169CaptionLbl)
                        {
                        }
                        column(ContinuedCaption; ContinuedCaptionLbl)
                        {
                        }
                        column(ContinuedCaption_Control155; ContinuedCaption_Control155Lbl)
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
                        column(VALVATAmountLCY_Control88; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY_Control165; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT____Control167; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmountLine__VAT_Identifier__Control241; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VALVATAmountLCY_Control242; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY_Control243; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATAmountLCY_Control245; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY_Control246; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATCounterLCY_Number; Number)
                        {
                        }
                        column(VALVATAmountLCY_Control88Caption; VALVATAmountLCY_Control88CaptionLbl)
                        {
                        }
                        column(VALVATBaseLCY_Control165Caption; VALVATBaseLCY_Control165CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT____Control167Caption; VATAmountLine__VAT____Control167CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Identifier__Control241Caption; VATAmountLine__VAT_Identifier__Control241CaptionLbl)
                        {
                        }
                        column(ContinuedCaption_Control87; ContinuedCaption_Control87Lbl)
                        {
                        }
                        column(ContinuedCaption_Control244; ContinuedCaption_Control244Lbl)
                        {
                        }
                        column(TotalCaption_Control247; TotalCaption_Control247Lbl)
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
                        var
                            CurrExchRate: Record "Currency Exchange Rate";
                        begin
                            if (not GLSetup."Print VAT specification in LCY") or
                               ("Sales Header"."Currency Code" = '')
                            then
                                CurrReport.Break();

                            SetRange(Number, 1, TempVATAmountLine.Count);
                            if GLSetup."LCY Code" = '' then
                                VALSpecLCYHeader := VatAmtSpecLbl + LocalCurrLbl
                            else
                                VALSpecLCYHeader := VatAmtSpecLbl + Format(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency("Sales Header"."Posting Date", "Sales Header"."Currency Code", 1);
                            CurrExchRate."Relational Exch. Rate Amount" := CurrExchRate."Exchange Rate Amount" / "Sales Header"."Currency Factor";
                            VALExchRate := StrSubstNo(
                                ExchenRateLbl,
                                CurrExchRate."Relational Exch. Rate Amount",
                                CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem("Item Charge Assignment (Sales)"; "Item Charge Assignment (Sales)")
                    {
                        DataItemLink = "Document Type" = field("Document Type"),
                                       "Document No." = field("Document No.");
                        DataItemLinkReference = "Sales Line";
                        DataItemTableView = sorting("Document Type", "Document No.", "Document Line No.", "Line No.");

                        column(Item_Charge_Assignment__Sales___Qty__to_Assign_; "Qty. to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Amount_to_Assign_; "Amount to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Item_Charge_No__; "Item Charge No.")
                        {
                        }
                        column(SalesLine2_Description; SalesLine2.Description)
                        {
                        }
                        column(SalesLine2_Quantity; SalesLine2.Quantity)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(Item_Charge_Assignment__Sales___Item_No__; "Item No.")
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Qty__to_Assign__Control209; "Qty. to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Unit_Cost_; "Unit Cost")
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Amount_to_Assign__Control216; "Amount to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Qty__to_Assign__Control221; "Qty. to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Amount_to_Assign__Control222; "Amount to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Qty__to_Assign__Control224; "Qty. to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Amount_to_Assign__Control225; "Amount to Assign")
                        {
                        }
                        column(Item_Charge_Assignment__Sales__Document_Type; "Document Type")
                        {
                        }
                        column(Item_Charge_Assignment__Sales__Document_No_; "Document No.")
                        {
                        }
                        column(Item_Charge_Assignment__Sales__Document_Line_No_; "Document Line No.")
                        {
                        }
                        column(Item_Charge_Assignment__Sales__Line_No_; "Line No.")
                        {
                        }
                        column(Item_Charge_SpecificationCaption; Item_Charge_SpecificationCaptionLbl)
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Item_Charge_No__Caption; FieldCaption("Item Charge No."))
                        {
                        }
                        column(SalesLine2_DescriptionCaption; SalesLine2_DescriptionCaptionLbl)
                        {
                        }
                        column(SalesLine2_QuantityCaption; SalesLine2_QuantityCaptionLbl)
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Item_No__Caption; FieldCaption("Item No."))
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Qty__to_Assign__Control209Caption; FieldCaption("Qty. to Assign"))
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Unit_Cost_Caption; FieldCaption("Unit Cost"))
                        {
                        }
                        column(Item_Charge_Assignment__Sales___Amount_to_Assign__Control216Caption; FieldCaption("Amount to Assign"))
                        {
                        }
                        column(ContinuedCaption_Control210; ContinuedCaption_Control210Lbl)
                        {
                        }
                        column(TotalCaption_Control220; TotalCaption_Control220Lbl)
                        {
                        }
                        column(ContinuedCaption_Control223; ContinuedCaption_Control223Lbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if SalesLine2.Get("Document Type", "Document No.", "Document Line No.") then;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowCostAssignment then
                                CurrReport.Break();
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(TempSalesLine);
                        Clear(SalesPost);

                        TempVATAmountLine.DeleteAll();
                        TempSalesLine.DeleteAll();

                        SalesPost.GetSalesLines("Sales Header", TempSalesLine, 1);
                        TempSalesLine.CalcVATAmountLines(0, "Sales Header", TempSalesLine, TempVATAmountLine);
                        TempSalesLine.UpdateVATOnLines(0, "Sales Header", TempSalesLine, TempVATAmountLine);

                        VATAmount := TempVATAmountLine.GetTotalVATAmount();
                        VATBaseAmount := TempVATAmountLine.GetTotalVATBase();
                        VATDiscountAmount := TempVATAmountLine.GetTotalVATDiscount(
                            "Sales Header"."Currency Code",
                            "Sales Header"."Prices Including VAT");

                        ChargesAmount := 0;
                        OtherTaxesAmount := 0;
                        TCSAmountApplied := 0;
                        AppliedServiceTaxSHECessAmt := 0;
                        AppliedServiceTaxAmt := 0;
                        AppliedServiceTaxECessAmt := 0;
                        TCSGSTCompAmount := 0;
                        TotalAmount := 0;
                        AppliedServiceTaxSBCAmt := 0;
                        AppliedKKCessAmt := 0;
                    end;
                }
            }

            trigger OnAfterGetRecord()
            var
                TableID: array[10] of Integer;
                No: array[10] of Code[20];
            begin
                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");
                FormatAddr.SalesHeaderSellTo(SellToAddr, "Sales Header");
                FormatAddr.SalesHeaderBillTo(BillToAddr, "Sales Header");
                if "Currency Code" = '' then begin
                    GLSetup.TestField("LCY Code");
                    TotalText := StrSubstNo(TotalLbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(TotalIncTaxLbl, GLSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(TotalExcTaxLbl, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(TotalLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(TotalIncTaxLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(TotalExcTaxLbl, "Currency Code");
                end;

                Invoice := InvOnNextPostReq;
                Ship := ShipReceiveOnNextPostReq;
                Receive := ShipReceiveOnNextPostReq;

                VerifySellToCust("Sales Header");
                VerifyBillToCust("Sales Header");

                SalesSetup.Get();

                VerifyPostingDate("Sales Header");

                if "Document Date" <> 0D then
                    if "Document Date" <> NormalDate("Document Date") then
                        AddError(StrSubstNo(DocPostingDateLbl, FieldCaption("Document Date")));

                case "Document Type" of
                    "Document Type"::Order:
                        Receive := false;
                    "Document Type"::Invoice:
                        begin
                            Ship := true;
                            Invoice := true;
                            Receive := false;
                        end;
                    "Document Type"::"Return Order":
                        Ship := false;
                    "Document Type"::"Credit Memo":
                        begin
                            Ship := false;
                            Invoice := true;
                            Receive := true;
                        end;
                end;

                if not (Ship or Invoice or Receive) then
                    AddError(
                        StrSubstNo(
                            InvEntLbl,
                            FieldCaption(Ship),
                            FieldCaption(Invoice),
                            FieldCaption(Receive)));

                if Invoice then begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", "Document Type");
                    SalesLine.SetRange("Document No.", "No.");
                    SalesLine.SetFilter(Quantity, '<>0');
                    if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                        SalesLine.SetFilter("Qty. to Invoice", '<>0');

                    Invoice := SalesLine.FindFirst();
                    if Invoice and (not Ship) and ("Document Type" = "Document Type"::Order) then begin
                        Invoice := false;
                        repeat
                            Invoice := (SalesLine."Quantity Shipped" - SalesLine."Quantity Invoiced") <> 0;
                        until Invoice or (SalesLine.Next() = 0);
                    end else
                        if Invoice and (not Receive) and ("Document Type" = "Document Type"::"Return Order") then begin
                            Invoice := false;
                            repeat
                                Invoice := (SalesLine."Return Qty. Received" - SalesLine."Quantity Invoiced") <> 0;
                            until Invoice or (SalesLine.Next() = 0);
                        end;
                end;

                if Ship then begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", "Document Type");
                    SalesLine.SetRange("Document No.", "No.");
                    SalesLine.SetFilter(Quantity, '<>0');
                    if "Document Type" = "Document Type"::Order then
                        SalesLine.SetFilter("Qty. to Ship", '<>0');

                    SalesLine.SetRange("Shipment No.", '');
                    Ship := SalesLine.FindFirst();
                end;

                if Receive then begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", "Document Type");
                    SalesLine.SetRange("Document No.", "No.");
                    SalesLine.SetFilter(Quantity, '<>0');
                    if "Document Type" = "Document Type"::"Return Order" then
                        SalesLine.SetFilter("Return Qty. to Receive", '<>0');

                    SalesLine.SetRange("Return Receipt No.", '');
                    Receive := SalesLine.FindFirst();
                end;

                if not (Ship or Invoice or Receive) then
                    AddError(NthingTPostLbl);

                if Invoice then
                    if not ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then
                        if "Due Date" = 0D then
                            AddError(StrSubstNo(MustbeSpecLbl, FieldCaption("Due Date")));

                if Ship and ("Shipping No." = '') then
                    if ("Document Type" = "Document Type"::Order) or
                       (("Document Type" = "Document Type"::Invoice) and SalesSetup."Shipment on Invoice")
                    then
                        if "Shipping No. Series" = '' then
                            AddError(StrSubstNo(MustbeSpecLbl, FieldCaption("Shipping No. Series")));

                if Receive and ("Return Receipt No." = '') then
                    if ("Document Type" = "Document Type"::"Return Order") or
                       (("Document Type" = "Document Type"::"Credit Memo") and SalesSetup."Return Receipt on Credit Memo")
                    then
                        if "Return Receipt No. Series" = '' then
                            AddError(StrSubstNo(MustbeSpecLbl, FieldCaption("Return Receipt No. Series")));

                if Invoice and ("Posting No." = '') then
                    if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                        if "Posting No. Series" = '' then
                            AddError(StrSubstNo(MustbeSpecLbl, FieldCaption("Posting No. Series")));

                SalesLine.Reset();
                SalesLine.SetRange("Document Type", "Document Type");
                SalesLine.SetRange("Document No.", "No.");
                SalesLine.SetFilter("Purch. Order Line No.", '<>0');
                if SalesLine.FindSet() then
                    if Ship then
                        repeat
                            if PurchOrderHeader."No." <> SalesLine."Purchase Order No." then begin
                                PurchOrderHeader.Get(PurchOrderHeader."Document Type"::Order, SalesLine."Purchase Order No.");
                                if PurchOrderHeader."Pay-to Vendor No." = '' then
                                    AddError(
                                      StrSubstNo(
                                        PurchOrderHeadLbl,
                                        PurchOrderHeader.FieldCaption("Pay-to Vendor No.")));

                                if PurchOrderHeader."Receiving No." = '' then
                                    if PurchOrderHeader."Receiving No. Series" = '' then
                                        AddError(
                                          StrSubstNo(
                                            PurchOrderHeadLbl,
                                            PurchOrderHeader.FieldCaption("Receiving No. Series")));
                            end;
                        until SalesLine.Next() = 0;

                if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then
                    if SalesSetup."Ext. Doc. No. Mandatory" and ("External Document No." = '') then
                        AddError(StrSubstNo(MustbeSpecLbl, FieldCaption("External Document No.")));

                if not DimMgt.CheckDimIDComb("Dimension Set ID") then
                    AddError(DimMgt.GetDimCombErr());

                TableID[1] := Database::Customer;
                No[1] := "Bill-to Customer No.";
                TableID[3] := Database::"Salesperson/Purchaser";
                No[3] := "Salesperson Code";
                TableID[4] := Database::Campaign;
                No[4] := "Campaign No.";
                TableID[5] := Database::"Responsibility Center";
                No[5] := "Responsibility Center";
                if not DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then
                    AddError(DimMgt.GetDimValuePostingErr());

                ServiceTaxAmt := 0;
                ServiceTaxECessAmt := 0;
                ServiceTaxSHECessAmt := 0;
                ServiceTaxSBCAmt := 0;
                KKCessAmt := 0;
                TCSAmountApplied := 0;
                TCSEntry.Reset();
                TCSEntry.SetCurrentKey("Document No.", "Posting Date");
                TCSEntry.SetRange("Document Type", SalesHeader."Applies-to Doc. Type");
                TCSEntry.SetRange("Document No.", SalesHeader."Applies-to Doc. No.");
                if TCSEntry.FindFirst() then
                    repeat
                        TCSAmountApplied += TCSEntry."TCS Amount" + TCSEntry."Surcharge Amount" +
                          TCSEntry."eCESS Amount" + TCSEntry."SHE Cess Amount";
                    until (TCSEntry.Next() = 0);
            end;

            trigger OnPreDataItem()
            begin
                SalesHeader.Copy("Sales Header");
                SalesHeader.FilterGroup := 2;
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                if SalesHeader.FindFirst() then begin
                    case true of
                        ShipReceiveOnNextPostReq and InvOnNextPostReq:
                            ShipInvText := ShipandInoiceLbl;
                        ShipReceiveOnNextPostReq:
                            ShipInvText := ShipLbl;
                        InvOnNextPostReq:
                            ShipInvText := InvLbl;
                    end;
                    ShipInvText := StrSubstNo(OrderPostLbl, ShipInvText);
                end;

                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
                if SalesHeader.FindFirst() then begin
                    case true of
                        ShipReceiveOnNextPostReq and InvOnNextPostReq:
                            ReceiveInvText := ReceiveCreditLbl;
                        ShipReceiveOnNextPostReq:
                            ReceiveInvText := ReceiLbl;
                        InvOnNextPostReq:
                            ReceiveInvText := InvLbl;
                    end;

                    ReceiveInvText := StrSubstNo(ReturnOrderPostLbl, ReceiveInvText);
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
                    group("Order/Return Order Posting")
                    {
                        Caption = 'Order/Return Order Posting';
                        field(ShipReceiveOnNextPost; ShipReceiveOnNextPostReq)
                        {
                            Caption = 'Ship/Receive';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies whether the posting type of the document is ship/receive or not.';

                            trigger OnValidate()
                            begin
                                if not ShipReceiveOnNextPostReq then
                                    InvOnNextPostReq := true;
                            end;
                        }
                        field(InvOnNextPost; InvOnNextPostReq)
                        {
                            Caption = 'Invoice';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies whether the posting type of the document is invoice or not.';

                            trigger OnValidate()
                            begin
                                if not InvOnNextPostReq then
                                    ShipReceiveOnNextPostReq := true;
                            end;
                        }
                    }
                    field(ShowDimension; ShowDim)
                    {
                        Caption = 'Show Dimensions';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether the dimensions have to be displayed or not.';
                    }
                    field(ShowItemChargeAssignment; ShowCostAssignment)
                    {
                        Caption = 'Show Item Charge Assgnt.';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies wheteher the assigned item charge have to be displyed or not.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if not ShipReceiveOnNextPostReq and not InvOnNextPostReq then begin
                ShipReceiveOnNextPostReq := true;
                InvOnNextPostReq := true;
            end;
        end;
    }

    trigger OnInitReport()
    begin
        GLSetup.Get();
        CompanyInfo.Get();
    end;

    trigger OnPreReport()
    begin
        SalesHeaderFilter := "Sales Header".GetFilters;
    end;

    var
        CompanyInfo: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        GLSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        Cust: Record "Customer";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        GLAcc: Record "G/L Account";
        Item: Record Item;
        Res: Record "Resource";
        SaleShptLine: Record "Sales Shipment Line";
        ReturnRcptLine: Record "Return Receipt Line";
        PurchOrderHeader: Record "Purchase Header";
        GenPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        FA: Record "Fixed Asset";
        FADeprBook: Record "FA Depreciation Book";
        InvtPeriod: Record "Inventory Period";
        TCSEntry: Record "TCS Entry";
        GenJnlLine: Record "Gen. Journal Line";
        FormatAddr: Codeunit "Format Address";
        DimMgt: Codeunit "DimensionManagement";
        SalesPost: Codeunit "Sales-Post";
        TCSComponentCode: array[20] of Integer;
        GSTComponentCodeName: array[10] of Code[20];
        SalesHeaderFilter: Text;
        SellToAddr: array[8] of Text[50];
        BillToAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        TotalText: Text[50];
        TotalExclVATText: Text[50];
        TotalInclVATText: Text[50];
        ShipInvText: Text[50];
        ReceiveInvText: Text[50];
        DimText: Text[120];
        ErrorText: array[99] of Text[250];
        QtyToHandleCaption: Text[30];
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        MaxQtyToBeInvoiced: Decimal;
        RemQtyToBeInvoiced: Decimal;
        QtyToBeInvoiced: Decimal;
        VATAmount: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        QtyToHandle: Decimal;
        TCSGSTCompAmount: Decimal;
        ErrorCounter: Integer;
        OrigMaxLineNo: Integer;
        InvOnNextPostReq: Boolean;
        ShipReceiveOnNextPostReq: Boolean;
        VATNoError: Boolean;
        ApplNoError: Boolean;
        ShowDim: Boolean;
        Continue: Boolean;
        ShowCostAssignment: Boolean;
        MoreLines: Boolean;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        SumLineAmount: Decimal;
        SumInvDiscountAmount: Decimal;
        ChargesAmount: Decimal;
        OtherTaxesAmount: Decimal;
        TCSAmountApplied: Decimal;
        TotalAmount: Decimal;
        ServiceTaxAmt: Decimal;
        ServiceTaxECessAmt: Decimal;
        AppliedServiceTaxAmt: Decimal;
        AppliedServiceTaxECessAmt: Decimal;
        ServiceTaxSHECessAmt: Decimal;
        AppliedServiceTaxSHECessAmt: Decimal;
        GSTComponentCode: array[20] of Integer;
        SumSalesLineExciseAmount: Decimal;
        SumSalesLineTaxAmount: Decimal;
        SumLineServiceTaxAmount: Decimal;
        SumLineServiceTaxECessAmount: Decimal;
        SumLineServiceTaxSHECessAmount: Decimal;
        SumSalesLineAmountToCusTomer: Decimal;
        SumTotalTDSTCSInclSHECESS: Decimal;
        AppliedServiceTaxSBCAmount: Decimal;
        AppliedServiceTaxSBCAmt: Decimal;
        ServiceTaxSBCAmt: Decimal;
        SumSvcTaxSBCAmount: Decimal;
        AppliedKKCessAmount: Decimal;
        AppliedKKCessAmt: Decimal;
        KKCessAmt: Decimal;
        SumKKCessAmount: Decimal;
        SumSalesLineGSTAmount: Decimal;
        GSTCompAmount: array[20] of Decimal;
        j: Integer;
        NNC_TotalGST: Decimal;
        QtyToShipLbl: Label '%1 must be zero.', Comment = '%1 = Sales Line".FieldCaption("Qty. to Ship")';
        CustBlockShipBilltoCustLbl: Label '%1 must not be %2 for %3 %4.', Comment = '%1 = Customer.FieldCaption(Blocked), %2 = false, %3 = Customer.TableCaption, %4 =  SalesHeader.Bill-to Customer No.';
        ShipcomplpreinvLbl: Label '%1 must be completely preinvoiced before you can ship or invoice the line.', Comment = '%1 = Sales Line".FieldCaption("Prepmt. Line Amount")';
        VatAmtSpecLbl: Label 'VAT Amount Specification in ';
        LocalCurrLbl: Label 'Local Currency';
        ExchenRateLbl: Label 'Exchange rate: %1/%2', Comment = '%1 = CurrExchRate."Relational Exch. Rate Amount", %2 = CurrExchRate."Exchange Rate Amount"';
        PrempAmtLbl: Label '%1 can at most be %2.', Comment = '%1 = "Sales Line".FieldCaption("Prepmt Amt to Deduct"), %2 = Rounded Amount';
        PrempAmtdeductLbl: Label '%1 must be at least %2.', Comment = '%1 = "Sales Line".FieldCaption("Prepmt Amt to Deduct"), %2 = Rounded Amount';
        TotalIncTaxLbl: Label 'Total %1 Incl. Taxes', Comment = '%1 = Currency Code/LCY Code';
        TotalExcTaxLbl: Label 'Total %1 Excl. Taxes', Comment = '%1 = Currency Code/LCY Code';
        ShipandInoiceLbl: Label 'Ship and Invoice';
        ShipLbl: Label 'Ship';
        InvLbl: Label 'Invoice';
        OrderPostLbl: Label 'Order Posting: %1', Comment = '%1 = ShipInvText';
        TotalLbl: Label 'Total %1', Comment = '%1 = Currency Code/LCY Code';
        MustbeSpecLbl: Label '%1 must be specified.', Comment = '%1 = Feild Caption Value';
        MustbeSpecFor1and2Lbl: Label '%1 must be %2 for %3 %4.', Comment = '%1 = Feild Caption, %2 = false/True, %3 = Table Caption, %4 = SalesLine.No.';
        FASalesHeaderLbl: Label '%1 %2 does not exist.', Comment = '%1 = TableCaption,  %2 = SalesLine."No."';
        DocPostingDateLbl: Label '%1 must not be a closing date.', Comment = '%1 = Document Date';
        AllowedPostingDateLbl: Label '%1 is not within your allowed range of posting dates.', Comment = '%1 = Document Date';
        NthingTPostLbl: Label 'There is nothing to post.';
        PurchOrderHeadLbl: Label '%1 must be entered on the purchase order header.', Comment = '%1 = Feild Caption';
        SalesDocLbl: Label 'Sales Document: %1', Comment = '%1 = SalesHeaderFilter';
        ReversedQuantiLbl: Label '%1 must be %2.', Comment = '%1 = Qty. to Invoice, %2 = "Sales Line".Quantity';
        AppliesToDocLbl: Label '%1 %2 does not exist on customer entries.', Comment = '%1 = Field Caption %2 = Sales Header"."Applies-to Doc. No.';
        DepricBusLbl: Label '%1 %2 %3 does not exist.', Comment = '%1 = VATPostingSetup.TableCaption, %2 = Sales Line."VAT Bus. Posting Group", %3 = Sales Line.VAT Prod. Posting Group';
        ReceiveCreditLbl: Label 'Receive and Credit Memo';
        TypeFielsLbl: Label '%1 %2 must be specified.', Comment = '%1 = Sales Line".Type, %2 = "Sales Line".FieldCaption("No.")';
        AmtLbl: Label '%1 must be 0 when %2 is 0.', Comment = '%1 Sales Line".FieldCaption(Amount), %2 = "Sales Line".FieldCaption(Quantity)';
        DropShipPossLbl: Label 'Drop shipments are only possible for items.';
        ShipOrderLbl: Label 'You cannot ship sales order line %1 because the line is marked', Comment = '%1 = Sales Line.Line No';
        DropShipAssoLbl: Label 'as a drop shipment and is not yet associated with a purchase order.';
        ShipsalesHeadLbl: Label 'The %1 on the shipment is not the same as the %1 on the sales header.', Comment = '%1 = SalesLine.FieldCaption';
        ReturnReceiptAttemLbl: Label 'Line %1 of the return receipt %2, which you are attempting to invoice, has already been invoiced.', Comment = '%1 = SalesLine2.Return Receipt Line No, %2 = SalesLine2.Return Receipt No.';
        InvShipLbl: Label 'Line %1 of the shipment %2, which you are attempting to invoice, has already been invoiced.', Comment = '%1 = Shipment Line No. %2 = "Shipment No."';
        SameSignLbl: Label '%1 must have the same sign as the shipments.', Comment = '%1 = Qty. to Invoice';
        ReceiLbl: Label 'Receive';
        ReturnOrderPostLbl: Label 'Return Order Posting: %1', Comment = '%1 = ReceiveInvText';
        InvEntLbl: Label 'Enter "Yes" in %1 and/or %2 and/or %3.', Comment = '%1 = FieldCaption(Ship), %2 = FieldCaption(Invoice), %3 = FieldCaption(Receive)';
        VatRegNoCustLbl: Label 'You must enter the customer''s %1.', Comment = '%1 = Sales Header".FieldCaption("VAT Registration No.")';
        QuantAttemInvLbl: Label 'The quantity you are attempting to invoice is greater than the quantity in shipment %1.', Comment = ' %1 = SalesLine2."Shipment No.';
        QuantAtempInvLbl: Label 'The quantity you are attempting to invoice is greater than the quantity in return receipt %1.', Comment = '%1 = SalesLine2."Return Receipt No."';
        ReceiptSalesHeadLbl: Label 'The %1 on the return receipt is not the same as the %1 on the sales header.', Comment = '%1 = Field Caption';
        ReturnReceiptLbl: Label '%1 must have the same sign as the return receipt.', Comment = '%1 = SalesLine2.FieldCaption("Qty. to Invoice")';
        Sales_Document___TestCaptionLbl: Label 'Sales Document - Test';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Ship_toCaptionLbl: Label 'Ship-to';
        Sell_toCaptionLbl: Label 'Sell-to';
        Bill_toCaptionLbl: Label 'Bill-to';
        Sales_Header___Posting_Date_CaptionLbl: Label 'Posting Date';
        Sales_Header___Document_Date_CaptionLbl: Label 'Document Date';
        Sales_Header___Due_Date_CaptionLbl: Label 'Due Date';
        Sales_Header___Pmt__Discount_Date_CaptionLbl: Label 'Pmt. Discount Date';
        Sales_Header___Posting_Date__Control105CaptionLbl: Label 'Posting Date';
        Sales_Header___Document_Date__Control106CaptionLbl: Label 'Document Date';
        Sales_Header___Order_Date_CaptionLbl: Label 'Order Date';
        Sales_Header___Shipment_Date_CaptionLbl: Label 'Shipment Date';
        Sales_Header___Due_Date__Control19CaptionLbl: Label 'Due Date';
        Sales_Header___Pmt__Discount_Date__Control22CaptionLbl: Label 'Pmt. Discount Date';
        Sales_Header___Posting_Date__Control131CaptionLbl: Label 'Posting Date';
        Sales_Header___Document_Date__Control132CaptionLbl: Label 'Document Date';
        Sales_Header___Posting_Date__Control137CaptionLbl: Label 'Posting Date';
        Sales_Header___Document_Date__Control138CaptionLbl: Label 'Document Date';
        Header_DimensionsCaptionLbl: Label 'Header Dimensions';
        ErrorText_Number_CaptionLbl: Label 'Warning!';
        Unit_PriceCaptionLbl: Label 'Unit Price';
        Sales_Line___Line_Discount___CaptionLbl: Label 'Line Disc. %';
        Sales_Line___Line_Discount_Amount_CaptionLbl: Label 'Line Discount Amount';
        AmountCaptionLbl: Label 'Amount';
        TempSalesLine__Inv__Discount_Amount_CaptionLbl: Label 'Inv. Discount Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        TempSalesLine__Excise_Amount_CaptionLbl: Label 'Excise Amount';
        TempSalesLine__Tax_Amount_CaptionLbl: Label 'Tax Amount';
        ServiceTaxAmtCaptionLbl: Label 'Service Tax Amount';
        Charges_AmountCaptionLbl: Label 'Charges Amount';
        Other_Taxes_AmountCaptionLbl: Label 'Other Taxes Amount';
        ServiceTaxECessAmtCaptionLbl: Label 'Service TaxeCess Amount';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        UGSTLbl: Label 'UGST';
        TCS_AmountCaptionLbl: Label 'TCS Amount';
        TCS_Amount__Applied_CaptionLbl: Label 'TCS Amount (Applied)';
        Svc_Tax_Amt__Applied_CaptionLbl: Label 'Svc Tax Amt (Applied)';
        Svc_Tax_eCess_Amt__Applied_CaptionLbl: Label 'Svc Tax eCess Amt (Applied)';
        ServiceTaxSHECessAmtCaptionLbl: Label 'Service Tax SHECess Amt';
        Svc_Tax_SHECess_Amt_Applied_CaptionLbl: Label 'Svc Tax SHECess Amt(Applied)';
        VATDiscountAmountCaptionLbl: Label 'Payment Discount on VAT';
        Line_DimensionsCaptionLbl: Label 'Line Dimensions';
        ErrorText_Number__Control97CaptionLbl: Label 'Warning!';
        VATAmountLine__VAT_Amount__Control150CaptionLbl: Label 'VAT Amount';
        VATAmountLine__VAT_Base__Control151CaptionLbl: Label 'VAT Base';
        VATAmountLine__VAT___CaptionLbl: Label 'VAT %';
        VAT_Amount_SpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATAmountLine__VAT_Identifier_CaptionLbl: Label 'VAT Identifier';
        VATAmountLine__Invoice_Discount_Amount__Control173CaptionLbl: Label 'Invoice Discount Amount';
        VATAmountLine__Inv__Disc__Base_Amount__Control171CaptionLbl: Label 'Inv. Disc. Base Amount';
        VATAmountLine__Line_Amount__Control169CaptionLbl: Label 'Line Amount';
        ContinuedCaptionLbl: Label 'Continued';
        ContinuedCaption_Control155Lbl: Label 'Continued';
        TotalCaptionLbl: Label 'Total';
        VALVATAmountLCY_Control88CaptionLbl: Label 'VAT Amount';
        VALVATBaseLCY_Control165CaptionLbl: Label 'VAT Base';
        VATAmountLine__VAT____Control167CaptionLbl: Label 'VAT %';
        VATAmountLine__VAT_Identifier__Control241CaptionLbl: Label 'VAT Identifier';
        ContinuedCaption_Control87Lbl: Label 'Continued';
        ContinuedCaption_Control244Lbl: Label 'Continued';
        TotalCaption_Control247Lbl: Label 'Total';
        Item_Charge_SpecificationCaptionLbl: Label 'Item Charge Specification';
        SalesLine2_DescriptionCaptionLbl: Label 'Description';
        SalesLine2_QuantityCaptionLbl: Label 'Assignable Qty';
        ContinuedCaption_Control210Lbl: Label 'Continued';
        TotalCaption_Control220Lbl: Label 'Total';
        ContinuedCaption_Control223Lbl: Label 'Continued';
        ServiceTaxSBCAmtCaptionLbl: Label 'SBC Amount';
        Svc_Tax_SBC_Amt__Applied_CaptionLbl: Label 'Svc Tax SBC Amt (Applied)';
        KKCessAmtCaptionLbl: Label 'KK Cess Amount';
        KK_Cess_Amt__Applied_CaptionLbl: Label 'KK Cess Amt (Applied)';
        CompanyRegistrationLbl: Label 'Company Registration No.';
        CustomerRegistrationLbl: Label 'Customer GST Reg No.';

    procedure AddDimToTempLine(SalesLine: Record "Sales Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        SourceCodeSetup.Get();
        DimMgt.AddDimSource(DefaultDimSource, DimMgt.SalesLineTypeToTableID(SalesLine.Type), SalesLine."No.");
        DimMgt.AddDimSource(DefaultDimSource, Database::Job, SalesLine."Job No.");
        DimMgt.AddDimSource(DefaultDimSource, Database::"Responsibility Center", SalesLine."Responsibility Center");

        SalesLine."Shortcut Dimension 1 Code" := '';
        SalesLine."Shortcut Dimension 2 Code" := '';
        SalesLine."Dimension Set ID" :=
            DimMgt.GetDefaultDimID(
                DefaultDimSource,
                SourceCodeSetup.Sales,
                SalesLine."Shortcut Dimension 1 Code",
                SalesLine."Shortcut Dimension 2 Code",
                SalesLine."Dimension Set ID",
                Database::Customer);
    end;

    procedure FilterAppliedEntries()
    var
        OldCustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        Currency: Record Currency;
        GenLedgSetup: Record "General Ledger Setup";
        SalesLine3: Record "Sales Line";
        ApplyingDate: Date;
        AmountforAppl: Decimal;
        AppliedAmount: Decimal;
        AppliedAmountLCY: Decimal;
        AppliedServiceTaxAmount: Decimal;
        AppliedServiceTaxEcessAmount: Decimal;
        AppliedServiceTaxSHEcessAmount: Decimal;
    begin
        AmountforAppl := 0;

        ApplyingDate := "Sales Header"."Posting Date";
        Customer.Get("Sales Header"."Bill-to Customer No.");
        if "Sales Header"."Applies-to Doc. No." <> '' then begin
            OldCustLedgEntry.Reset();
            OldCustLedgEntry.SetCurrentKey("Document No.");
            OldCustLedgEntry.SetRange("Document No.", "Sales Header"."Applies-to Doc. No.");
            OldCustLedgEntry.SetRange("Document Type", "Sales Header"."Applies-to Doc. Type");
            OldCustLedgEntry.SetRange("Customer No.", "Sales Header"."Bill-to Customer No.");
            OldCustLedgEntry.SetRange(Open, true);
            OldCustLedgEntry.FindFirst();
            if OldCustLedgEntry."Posting Date" > ApplyingDate then
                ApplyingDate := OldCustLedgEntry."Posting Date";

            OldCustLedgEntry.CalcFields("Remaining Amount");
            if "Sales Header"."Currency Code" <> '' then begin
                Currency.Get("Sales Header"."Currency Code");
                FindAmtForAppln(OldCustLedgEntry, AppliedAmount, AppliedAmountLCY,
                  Currency."Amount Rounding Precision", AmountforAppl);
            end else begin
                GenLedgSetup.Get();
                FindAmtForAppln(OldCustLedgEntry, AppliedAmount, AppliedAmountLCY,
                  GenLedgSetup."Amount Rounding Precision", AmountforAppl);
            end;

            AppliedAmountLCY := Abs(AppliedAmountLCY);
            AppliedServiceTaxSHEcessAmount := Round(AppliedServiceTaxSHEcessAmount);
            AppliedServiceTaxEcessAmount := Round(AppliedServiceTaxEcessAmount);
            AppliedServiceTaxSBCAmount := Round(AppliedServiceTaxSBCAmount);
            AppliedKKCessAmount := Round(AppliedKKCessAmount);
            AppliedServiceTaxAmount := Round(AppliedServiceTaxAmount - AppliedServiceTaxEcessAmount -
            AppliedServiceTaxSHEcessAmount - AppliedServiceTaxSBCAmount - AppliedKKCessAmount);
            AppliedServiceTaxSHECessAmt += AppliedServiceTaxSHEcessAmount;
            AppliedServiceTaxECessAmt += AppliedServiceTaxEcessAmount;
            AppliedServiceTaxAmt += AppliedServiceTaxAmount;
            AppliedServiceTaxSBCAmt += AppliedServiceTaxSBCAmount;
            AppliedKKCessAmt += AppliedKKCessAmount;
        end;

        if "Sales Header"."Applies-to ID" <> '' then begin
            OldCustLedgEntry.Reset();
            OldCustLedgEntry.SetCurrentKey("Customer No.", "Applies-to ID", Open, Positive, "Due Date");
            OldCustLedgEntry.SetRange("Customer No.", "Sales Header"."Bill-to Customer No.");
            OldCustLedgEntry.SetRange("Applies-to ID", "Sales Header"."Applies-to ID");
            OldCustLedgEntry.SetRange(Open, true);
            if not (Cust."Application Method" = Cust."Application Method"::"Apply to Oldest") then
                OldCustLedgEntry.SetFilter("Amount to Apply", '<>%1', 0);

            if Cust."Application Method" = Cust."Application Method"::"Apply to Oldest" then
                OldCustLedgEntry.SetFilter("Posting Date", '..%1', GenJnlLine."Posting Date");

            if SalesSetup."Appln. between Currencies" = SalesSetup."Appln. between Currencies"::None then
                OldCustLedgEntry.SetRange("Currency Code", "Sales Header"."Currency Code");
        end;

        SalesLine3.CopyFilters("Sales Line");
        SalesLine3 := "Sales Line";
        if SalesLine3.Next() = 0 then begin
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
    end;

    procedure InitializeRequest(
        NewShipReceiveOnNextPostReq: Boolean;
        NewInvOnNextPostReq: Boolean;
        NewShowDim: Boolean;
        NewShowCostAssignment: Boolean)
    begin
        ShipReceiveOnNextPostReq := NewShipReceiveOnNextPostReq;
        InvOnNextPostReq := NewInvOnNextPostReq;
        ShowDim := NewShowDim;
        ShowCostAssignment := NewShowCostAssignment;
    end;

    local procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;

    local procedure CheckShptLines(SalesLine2: Record "Sales Line")
    var
        TempPostedDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if Abs(RemQtyToBeInvoiced) > Abs(SalesLine2."Qty. to Ship") then begin
            SaleShptLine.Reset();
            case SalesLine2."Document Type" of
                SalesLine2."Document Type"::Order:
                    begin
                        SaleShptLine.SetCurrentKey("Order No.", "Order Line No.");
                        SaleShptLine.SetRange("Order No.", SalesLine2."Document No.");
                        SaleShptLine.SetRange("Order Line No.", SalesLine2."Line No.");
                    end;
                SalesLine2."Document Type"::Invoice:
                    begin
                        SaleShptLine.SetRange("Document No.", SalesLine2."Shipment No.");
                        SaleShptLine.SetRange("Line No.", SalesLine2."Shipment Line No.");
                    end;
            end;

            SaleShptLine.SetFilter("Qty. Shipped Not Invoiced", '<>0');
            if SaleShptLine.Find('-') then
                repeat
                    DimMgt.GetDimensionSet(TempPostedDimSetEntry, SaleShptLine."Dimension Set ID");
                    if not DimMgt.CheckDimIDConsistency(
                         TempDimSetEntry, TempPostedDimSetEntry, Database::"Sales Line", Database::"Sales Shipment Line")
                    then
                        AddError(DimMgt.GetDocDimConsistencyErr());

                    if SaleShptLine."Sell-to Customer No." <> SalesLine2."Sell-to Customer No." then
                        AddError(StrSubstNo(ShipsalesHeadLbl, SalesLine2.FieldCaption("Sell-to Customer No.")));

                    if SaleShptLine.Type <> SalesLine2.Type then
                        AddError(StrSubstNo(ShipsalesHeadLbl, SalesLine2.FieldCaption(Type)));

                    if SaleShptLine."No." <> SalesLine2."No." then
                        AddError(StrSubstNo(ShipsalesHeadLbl, SalesLine2.FieldCaption("No.")));

                    if SaleShptLine."Gen. Bus. Posting Group" <> SalesLine2."Gen. Bus. Posting Group" then
                        AddError(StrSubstNo(ShipsalesHeadLbl, SalesLine2.FieldCaption("Gen. Bus. Posting Group")));

                    if SaleShptLine."Gen. Prod. Posting Group" <> SalesLine2."Gen. Prod. Posting Group" then
                        AddError(StrSubstNo(ShipsalesHeadLbl, SalesLine2.FieldCaption("Gen. Prod. Posting Group")));

                    if SaleShptLine."Location Code" <> SalesLine2."Location Code" then
                        AddError(StrSubstNo(ShipsalesHeadLbl, SalesLine2.FieldCaption("Location Code")));

                    if SaleShptLine."Job No." <> SalesLine2."Job No." then
                        AddError(StrSubstNo(ShipsalesHeadLbl, SalesLine2.FieldCaption("Job No.")));

                    if -SalesLine."Qty. to Invoice" * SaleShptLine.Quantity < 0 then
                        AddError(StrSubstNo(SameSignLbl, SalesLine2.FieldCaption("Qty. to Invoice")));

                    QtyToBeInvoiced := RemQtyToBeInvoiced - SalesLine."Qty. to Ship";
                    if Abs(QtyToBeInvoiced) > Abs(SaleShptLine.Quantity - SaleShptLine."Quantity Invoiced") then
                        QtyToBeInvoiced := -(SaleShptLine.Quantity - SaleShptLine."Quantity Invoiced");

                    RemQtyToBeInvoiced := RemQtyToBeInvoiced - QtyToBeInvoiced;
                    SaleShptLine."Quantity Invoiced" := SaleShptLine."Quantity Invoiced" - QtyToBeInvoiced;
                    SaleShptLine."Qty. Shipped Not Invoiced" := SaleShptLine.Quantity - SaleShptLine."Quantity Invoiced"
                until (SaleShptLine.Next() = 0) or (Abs(RemQtyToBeInvoiced) <= Abs(SalesLine2."Qty. to Ship"))
            else
                AddError(StrSubstNo(InvShipLbl, SalesLine2."Shipment Line No.", SalesLine2."Shipment No."));
        end;

        if Abs(RemQtyToBeInvoiced) > Abs(SalesLine2."Qty. to Ship") then
            if SalesLine2."Document Type" = SalesLine2."Document Type"::Invoice then
                AddError(StrSubstNo(QuantAttemInvLbl, SalesLine2."Shipment No."));
    end;

    local procedure CheckRcptLines(SalesLine2: Record "Sales Line")
    var
        TempPostedDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if Abs(RemQtyToBeInvoiced) > Abs(SalesLine2."Return Qty. to Receive") then begin
            ReturnRcptLine.Reset();
            case SalesLine2."Document Type" of
                SalesLine2."Document Type"::"Return Order":
                    begin
                        ReturnRcptLine.SetCurrentKey("Return Order No.", "Return Order Line No.");
                        ReturnRcptLine.SetRange("Return Order No.", SalesLine2."Document No.");
                        ReturnRcptLine.SetRange("Return Order Line No.", SalesLine2."Line No.");
                    end;
                SalesLine2."Document Type"::"Credit Memo":
                    begin
                        ReturnRcptLine.SetRange("Document No.", SalesLine2."Return Receipt No.");
                        ReturnRcptLine.SetRange("Line No.", SalesLine2."Return Receipt Line No.");
                    end;
            end;

            ReturnRcptLine.SetFilter("Return Qty. Rcd. Not Invd.", '<>0');
            if ReturnRcptLine.Find('-') then
                repeat
                    DimMgt.GetDimensionSet(TempPostedDimSetEntry, ReturnRcptLine."Dimension Set ID");
                    if not DimMgt.CheckDimIDConsistency(
                         TempDimSetEntry, TempPostedDimSetEntry, Database::"Sales Line", Database::"Return Receipt Line")
                    then
                        AddError(DimMgt.GetDocDimConsistencyErr());

                    if ReturnRcptLine."Sell-to Customer No." <> SalesLine2."Sell-to Customer No." then
                        AddError(StrSubstNo(ReceiptSalesHeadLbl, SalesLine2.FieldCaption("Sell-to Customer No.")));

                    if ReturnRcptLine.Type <> SalesLine2.Type then
                        AddError(StrSubstNo(ReceiptSalesHeadLbl, SalesLine2.FieldCaption(Type)));

                    if ReturnRcptLine."No." <> SalesLine2."No." then
                        AddError(StrSubstNo(ReceiptSalesHeadLbl, SalesLine2.FieldCaption("No.")));

                    if ReturnRcptLine."Gen. Bus. Posting Group" <> SalesLine2."Gen. Bus. Posting Group" then
                        AddError(StrSubstNo(ReceiptSalesHeadLbl, SalesLine2.FieldCaption("Gen. Bus. Posting Group")));

                    if ReturnRcptLine."Gen. Prod. Posting Group" <> SalesLine2."Gen. Prod. Posting Group" then
                        AddError(StrSubstNo(ReceiptSalesHeadLbl, SalesLine2.FieldCaption("Gen. Prod. Posting Group")));

                    if ReturnRcptLine."Location Code" <> SalesLine2."Location Code" then
                        AddError(StrSubstNo(ReceiptSalesHeadLbl, SalesLine2.FieldCaption("Location Code")));

                    if ReturnRcptLine."Job No." <> SalesLine2."Job No." then
                        AddError(StrSubstNo(ReceiptSalesHeadLbl, SalesLine2.FieldCaption("Job No.")));

                    if SalesLine."Qty. to Invoice" * ReturnRcptLine.Quantity < 0 then
                        AddError(StrSubstNo(ReturnReceiptLbl, SalesLine2.FieldCaption("Qty. to Invoice")));

                    QtyToBeInvoiced := RemQtyToBeInvoiced - SalesLine."Return Qty. to Receive";
                    if Abs(QtyToBeInvoiced) > Abs(ReturnRcptLine.Quantity - ReturnRcptLine."Quantity Invoiced") then
                        QtyToBeInvoiced := ReturnRcptLine.Quantity - ReturnRcptLine."Quantity Invoiced";

                    RemQtyToBeInvoiced := RemQtyToBeInvoiced - QtyToBeInvoiced;
                    ReturnRcptLine."Quantity Invoiced" := ReturnRcptLine."Quantity Invoiced" + QtyToBeInvoiced;
                    ReturnRcptLine."Return Qty. Rcd. Not Invd." := ReturnRcptLine.Quantity - ReturnRcptLine."Quantity Invoiced";
                until (ReturnRcptLine.Next() = 0) or (Abs(RemQtyToBeInvoiced) <= Abs(SalesLine2."Return Qty. to Receive"))
            else
                AddError(StrSubstNo(ReturnReceiptAttemLbl, SalesLine2."Return Receipt Line No.", SalesLine2."Return Receipt No."));
        end;

        if Abs(RemQtyToBeInvoiced) > Abs(SalesLine2."Return Qty. to Receive") then
            if SalesLine2."Document Type" = SalesLine2."Document Type"::"Credit Memo" then
                AddError(StrSubstNo(QuantAtempInvLbl, SalesLine2."Return Receipt No."));
    end;

    local procedure IsInvtPosting(): Boolean
    var
        SalesLine3: Record "Sales Line";
    begin
        SalesLine3.SetRange("Document Type", "Sales Header"."Document Type");
        SalesLine3.SetRange("Document No.", "Sales Header"."No.");
        SalesLine3.SetFilter(Type, '%1|%2', SalesLine3.Type::Item, SalesLine3.Type::"Charge (Item)");
        if SalesLine3.IsEmpty then
            exit(false);

        if "Sales Header".Ship then begin
            SalesLine3.SetFilter("Qty. to Ship", '<>%1', 0);
            if not SalesLine3.IsEmpty then
                exit(true);
        end;

        if "Sales Header".Receive then begin
            SalesLine3.SetFilter("Return Qty. to Receive", '<>%1', 0);
            if not SalesLine3.IsEmpty then
                exit(true);
        end;

        if "Sales Header".Invoice then begin
            SalesLine3.SetFilter("Qty. to Invoice", '<>%1', 0);
            if not SalesLine3.IsEmpty then
                exit(true);
        end;
    end;

    local procedure CheckType(SalesLine2: Record "Sales Line")
    begin
        case SalesLine2.Type of
            Type::"G/L Account":
                begin
                    if (SalesLine2."No." = '') and (SalesLine2.Amount = 0) then
                        exit;

                    if SalesLine2."No." <> '' then
                        if GLAcc.Get(SalesLine2."No.") then begin
                            if GLAcc.Blocked then
                                AddError(
                                    StrSubstNo(
                                        MustbeSpecFor1and2Lbl,
                                        GLAcc.FieldCaption(Blocked),
                                        false,
                                        GLAcc.TableCaption, SalesLine2."No."));

                            if not GLAcc."Direct Posting" and (SalesLine2."Line No." <= OrigMaxLineNo) then
                                AddError(
                                    StrSubstNo(
                                        MustbeSpecFor1and2Lbl,
                                        GLAcc.FieldCaption("Direct Posting"),
                                        true,
                                        GLAcc.TableCaption, SalesLine2."No."));
                        end else
                            AddError(StrSubstNo(FASalesHeaderLbl, GLAcc.TableCaption, SalesLine2."No."));
                end;
            Type::Item:
                begin
                    if (SalesLine2."No." = '') and (SalesLine2.Quantity = 0) then
                        exit;

                    if SalesLine2."No." <> '' then
                        if Item.Get(SalesLine2."No.") then begin
                            if Item.Blocked then
                                AddError(
                                    StrSubstNo(
                                        MustbeSpecFor1and2Lbl,
                                        Item.FieldCaption(Blocked),
                                        false,
                                        Item.TableCaption, SalesLine2."No."));

                            if Item.Reserve = Item.Reserve::Always then begin
                                SalesLine2.CalcFields("Reserved Quantity");
                                if SalesLine2."Document Type" in [
                                    SalesLine2."Document Type"::"Return Order",
                                    SalesLine2."Document Type"::"Credit Memo"]
                                then begin
                                    if (SalesLine2.SignedXX(SalesLine2.Quantity) < 0) and
                                        (Abs(SalesLine2."Reserved Quantity") < Abs(SalesLine2."Return Qty. to Receive"))
                                    then
                                        AddError(
                                            StrSubstNo(
                                                ReversedQuantiLbl,
                                                SalesLine2.FieldCaption("Reserved Quantity"),
                                                SalesLine2.SignedXX(SalesLine2."Return Qty. to Receive")));
                                end else
                                    if (SalesLine2.SignedXX(SalesLine2.Quantity) < 0) and
                                        (Abs(SalesLine2."Reserved Quantity") < Abs(SalesLine2."Qty. to Ship"))
                                    then
                                        AddError(
                                            StrSubstNo(
                                                ReversedQuantiLbl,
                                                SalesLine2.FieldCaption("Reserved Quantity"),
                                                SalesLine2.SignedXX(SalesLine2."Qty. to Ship")));
                            end
                        end else
                            AddError(StrSubstNo(FASalesHeaderLbl, Item.TableCaption, SalesLine2."No."));
                end;
            Type::Resource:
                begin
                    if (SalesLine2."No." = '') and (SalesLine2.Quantity = 0) then
                        exit;

                    if Res.Get(SalesLine2."No.") then begin
                        if Res."Privacy Blocked" then
                            AddError(
                                StrSubstNo(
                                    MustbeSpecFor1and2Lbl,
                                    Res.FieldCaption("Privacy Blocked"),
                                    false,
                                    Res.TableCaption,
                                    SalesLine2."No."));

                        if Res.Blocked then
                            AddError(
                                StrSubstNo(
                                    MustbeSpecFor1and2Lbl,
                                    Res.FieldCaption(Blocked),
                                    false,
                                    Res.TableCaption,
                                    SalesLine2."No."));
                    end else
                        AddError(StrSubstNo(FASalesHeaderLbl, Res.TableCaption, SalesLine2."No."));
                end;
            Type::"Fixed Asset":
                begin
                    if (SalesLine2."No." = '') and (SalesLine2.Quantity = 0) then
                        exit;

                    if SalesLine2."No." <> '' then
                        if FA.Get(SalesLine2."No.") then begin
                            if FA.Blocked then
                                AddError(
                                    StrSubstNo(
                                        MustbeSpecFor1and2Lbl,
                                        FA.FieldCaption(Blocked),
                                        false,
                                        FA.TableCaption,
                                        SalesLine2."No."));

                            if FA.Inactive then
                                AddError(
                                    StrSubstNo(
                                        MustbeSpecFor1and2Lbl,
                                        FA.FieldCaption(Inactive),
                                        false,
                                        FA.TableCaption, SalesLine2."No."));

                            if SalesLine2."Depreciation Book Code" = '' then
                                AddError(StrSubstNo(MustbeSpecLbl, SalesLine2.FieldCaption("Depreciation Book Code")))
                            else
                                if not FADeprBook.Get(SalesLine2."No.", SalesLine2."Depreciation Book Code") then
                                    AddError(
                                        StrSubstNo(
                                            DepricBusLbl,
                                            FADeprBook.TableCaption,
                                            SalesLine2."No.",
                                            SalesLine2."Depreciation Book Code"));
                        end else
                            AddError(StrSubstNo(FASalesHeaderLbl, FA.TableCaption, SalesLine2."No."));
                end;
        end;
    end;

    local procedure VerifySellToCust(SalesHeader: Record "Sales Header")
    var
        ShipQtyExist: Boolean;
    begin
        if SalesHeader."Sell-to Customer No." = '' then
            AddError(StrSubstNo(MustbeSpecLbl, SalesHeader.FieldCaption("Sell-to Customer No.")))
        else
            if Cust.Get(SalesHeader."Sell-to Customer No.") then begin
                if (Cust.Blocked = Cust.Blocked::Ship) and SalesHeader.Ship then begin
                    SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine2.SetRange("Document No.", SalesHeader."No.");
                    SalesLine2.SetFilter("Qty. to Ship", '>0');
                    if SalesLine2.FindFirst() then
                        ShipQtyExist := true;
                end;

                if Cust."Privacy Blocked" then
                    AddError(Cust.GetPrivacyBlockedGenericErrorText(Cust));

                if (Cust.Blocked = Cust.Blocked::All) or
                   ((Cust.Blocked = Cust.Blocked::Invoice) and
                        (not (SalesHeader."Document Type" in [
                            SalesHeader."Document Type"::"Credit Memo",
                            SalesHeader."Document Type"::"Return Order"]))) or
                   ShipQtyExist
                then
                    AddError(
                        StrSubstNo(
                            CustBlockShipBilltoCustLbl,
                            Cust.FieldCaption(Blocked),
                            Cust.Blocked,
                            Cust.TableCaption,
                            SalesHeader."Sell-to Customer No."))
            end else
                AddError(StrSubstNo(FASalesHeaderLbl, Cust.TableCaption, SalesHeader."Sell-to Customer No."));
    end;

    local procedure VerifyBillToCust(SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Bill-to Customer No." = '' then
            AddError(StrSubstNo(MustbeSpecLbl, SalesHeader.FieldCaption("Bill-to Customer No.")))
        else begin
            if SalesHeader."Bill-to Customer No." <> SalesHeader."Sell-to Customer No." then
                if Cust.Get(SalesHeader."Bill-to Customer No.") then
                    if Cust."Privacy Blocked" then
                        AddError(Cust.GetPrivacyBlockedGenericErrorText(Cust));

            if (Cust.Blocked = Cust.Blocked::All) or
               ((Cust.Blocked = Cust.Blocked::Invoice) and
                    (SalesHeader."Document Type" in [
                        SalesHeader."Document Type"::"Credit Memo",
                        SalesHeader."Document Type"::"Return Order"]))
            then
                AddError(
                    StrSubstNo(
                        CustBlockShipBilltoCustLbl,
                        Cust.FieldCaption(Blocked),
                        false,
                        Cust.TableCaption,
                        SalesHeader."Bill-to Customer No."))
            else
                AddError(StrSubstNo(FASalesHeaderLbl, Cust.TableCaption, SalesHeader."Bill-to Customer No."));
        end;
    end;

    local procedure VerifyPostingDate(SalesHeader: Record "Sales Header")
    var
        InvtPeriodEndDate: Date;
    begin
        if SalesHeader."Posting Date" = 0D then
            AddError(StrSubstNo(MustbeSpecLbl, SalesHeader.FieldCaption("Posting Date")))
        else
            if SalesHeader."Posting Date" <> NormalDate(SalesHeader."Posting Date") then
                AddError(StrSubstNo(DocPostingDateLbl, SalesHeader.FieldCaption("Posting Date")))
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

                if (SalesHeader."Posting Date" < AllowPostingFrom) or (SalesHeader."Posting Date" > AllowPostingTo) then
                    AddError(StrSubstNo(AllowedPostingDateLbl, SalesHeader.FieldCaption("Posting Date")))
                else
                    if IsInvtPosting() then begin
                        InvtPeriodEndDate := SalesHeader."Posting Date";

                        if not InvtPeriod.IsValidDate(InvtPeriodEndDate) then
                            AddError(StrSubstNo(AllowedPostingDateLbl, Format(SalesHeader."Posting Date")))
                    end;
            end;
    end;

    local procedure FindAmtForAppln(
        OldCustLedgEntry: Record "Cust. Ledger Entry";
        var AppliedAmount: Decimal;
        var AppliedAmountLCY: Decimal;
        ApplnRoundingPrecision: Decimal;
        AmountforAppl: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
        OldAppliedAmount: Decimal;
    begin
        if OldCustLedgEntry.GetFilter(Positive) <> '' then
            if OldCustLedgEntry."Amount to Apply" <> 0 then
                AppliedAmount := -OldCustLedgEntry."Amount to Apply"
            else
                AppliedAmount := -OldCustLedgEntry."Remaining Amount"
        else
            if OldCustLedgEntry."Amount to Apply" <> 0 then begin
                if (CheckCalcPmtDisc(OldCustLedgEntry, ApplnRoundingPrecision, false, false, AmountforAppl) and
                  (Abs(OldCustLedgEntry."Amount to Apply") >=
                        Abs(OldCustLedgEntry."Remaining Amount" - OldCustLedgEntry."Remaining Pmt. Disc. Possible")) and
                  (Abs(AmountforAppl) >=
                        Abs(OldCustLedgEntry."Amount to Apply" - OldCustLedgEntry."Remaining Pmt. Disc. Possible"))) or
                  OldCustLedgEntry."Accepted Pmt. Disc. Tolerance"
                then begin
                    AppliedAmount := -OldCustLedgEntry."Remaining Amount";
                    OldCustLedgEntry."Accepted Pmt. Disc. Tolerance" := false;
                end else
                    if Abs(AmountforAppl) <= Abs(OldCustLedgEntry."Amount to Apply") then
                        AppliedAmount := AmountforAppl
                    else
                        AppliedAmount := -OldCustLedgEntry."Amount to Apply";
            end else
                if Abs(AmountforAppl) < Abs(OldCustLedgEntry."Remaining Amount") then
                    AppliedAmount := AmountforAppl
                else
                    AppliedAmount := -OldCustLedgEntry."Remaining Amount";

        if SalesHeader."Currency Code" = OldCustLedgEntry."Currency Code" then begin
            AppliedAmountLCY := Round(AppliedAmount / OldCustLedgEntry."Original Currency Factor");
            OldAppliedAmount := AppliedAmount;
        end else begin
            if AppliedAmount = -OldCustLedgEntry."Remaining Amount" then
                OldAppliedAmount := -OldCustLedgEntry."Remaining Amount"
            else
                OldAppliedAmount := CurrExchRate.ExchangeAmount(
                    AppliedAmount,
                    SalesHeader."Currency Code",
                    OldCustLedgEntry."Currency Code",
                    SalesHeader."Posting Date");

            if SalesHeader."Currency Code" <> '' then
                AppliedAmountLCY := Round(OldAppliedAmount / OldCustLedgEntry."Original Currency Factor")
            else
                AppliedAmountLCY := Round(AppliedAmount / SalesHeader."Currency Factor");
        end;
    end;

    local procedure CheckCalcPmtDisc(
        var OldCustLedgEntry: Record "Cust. Ledger Entry";
        ApplnRoundingPrecision: Decimal;
        CheckFilter: Boolean;
        CheckAmount: Boolean;
        AmountforAppl: Decimal): Boolean
    begin
        if ((OldCustLedgEntry."Document Type" = OldCustLedgEntry."Document Type"::Invoice) and
          (SalesHeader."Posting Date" <= OldCustLedgEntry."Pmt. Discount Date"))
        then begin
            if CheckFilter then begin
                if CheckAmount then
                    if (OldCustLedgEntry.GetFilter(Positive) <> '') or
                      (Abs(AmountforAppl) + ApplnRoundingPrecision >=
                        Abs(OldCustLedgEntry."Remaining Amount" - OldCustLedgEntry."Remaining Pmt. Disc. Possible"))
                    then
                        exit(true);
            end else
                if (OldCustLedgEntry.GetFilter(Positive) <> '') then
                    exit(true);
        end else
            if CheckAmount then
                if (Abs(AmountforAppl) + ApplnRoundingPrecision >=
                  Abs(OldCustLedgEntry."Remaining Amount" - OldCustLedgEntry."Remaining Pmt. Disc. Possible"))
                then
                    exit(true)
                else
                    exit(true);
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
