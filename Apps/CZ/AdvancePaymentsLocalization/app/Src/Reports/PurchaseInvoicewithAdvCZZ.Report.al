// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CRM.Contact;
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
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;
using System.EMail;
using System.Globalization;
using System.Utilities;

report 31028 "Purchase-Invoice with Adv. CZZ"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PurchaseInvoiceWithAdv.rdl';
    Caption = 'Purchase - Invoice with Advance';
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
            column(InvDiscAmtCaption; InvDiscAmtCaptionLbl)
            {
            }
            column(AllowInvDiscCaption; AllowInvDiscCaptionLbl)
            {
            }
            column(PayToVendNo_PurchInvHeaderCaption; "Purch. Inv. Header".FieldCaption("Pay-to Vendor No."))
            {
            }
            column(PricesIncVAT_PurchInvHeaderCaption; "Purch. Inv. Header".FieldCaption("Prices Including VAT"))
            {
            }
            column(BuyFromVendNo_PurchInvHeaderCaption; "Purch. Inv. Header".FieldCaption("Buy-from Vendor No."))
            {
            }
            column(BuyFromContactPhoneNoLbl; BuyFromContactPhoneNoLbl)
            {
            }
            column(BuyFromContactMobilePhoneNoLbl; BuyFromContactMobilePhoneNoLbl)
            {
            }
            column(BuyFromContactEmailLbl; BuyFromContactEmailLbl)
            {
            }
            column(PayToContactPhoneNoLbl; PayToContactPhoneNoLbl)
            {
            }
            column(PayToContactMobilePhoneNoLbl; PayToContactMobilePhoneNoLbl)
            {
            }
            column(PayToContactEmailLbl; PayToContactEmailLbl)
            {
            }
            column(BuyFromContactPhoneNo; Contact."Phone No.")
            {
            }
            column(BuyFromContactMobilePhoneNo; Contact."Mobile Phone No.")
            {
            }
            column(BuyFromContactEmail; Contact."E-Mail")
            {
            }
            column(PayToContactPhoneNo; Contact2."Phone No.")
            {
            }
            column(PayToContactMobilePhoneNo; Contact2."Mobile Phone No.")
            {
            }
            column(PayToContactEmail; Contact2."E-Mail")
            {
            }
            column(PaymentsLbl; PaymentsLbl)
            {
            }
            column(PrepayedLbl; PrepayedLbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(PaymentTermsDesc; PaymentTerms.Description)
                    {
                    }
                    column(ShipmentMethodDesc; ShipmentMethod.Description)
                    {
                    }
                    column(DocCaptionCopyText; StrSubstNo(DocumentCaption(), CopyText))
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
                    column(CompanyInfoPhoneNo; CompanyInformation."Phone No.")
                    {
                    }
                    column(VendAddr6; VendAddr[6])
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInformation."Home Page")
                    {
                    }
                    column(CompanyInfoEMail; CompanyInformation."E-Mail")
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
                    column(CompanyInfoBankAccountNo; CompanyInformation."Bank Account No.")
                    {
                    }
                    column(PayToVendNo_PurchInvHeader; "Purch. Inv. Header"."Pay-to Vendor No.")
                    {
                    }
                    column(DocDate_PurchInvHeader; Format("Purch. Inv. Header"."Document Date"))
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
                    column(SalesPurchPersonName; SalespersonPurchaser.Name)
                    {
                    }
                    column(RefText; ReferenceText)
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
                    column(PostingDate_PurchInvHeader; Format("Purch. Inv. Header"."Posting Date"))
                    {
                    }
                    column(PricesIncVAT_PurchInvHeader; "Purch. Inv. Header"."Prices Including VAT")
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(ShowInternalInfo; ShowInterInfo)
                    {
                    }
                    column(VATBaseDisc_PurchInvHeader; "Purch. Inv. Header"."VAT Base Discount %")
                    {
                    }
                    column(PricesInclVATtxt; PricesInclVATtxt)
                    {
                    }
                    column(BuyFromVendNo_PurchInvHeader; "Purch. Inv. Header"."Buy-from Vendor No.")
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
                    column(DueDateCaption; DueDateCaptionLbl)
                    {
                    }
                    column(InvoiceNoCaption; InvoiceNoCaptionLbl)
                    {
                    }
                    column(PostingDateCaption; PostingDateCaptionLbl)
                    {
                    }
                    column(PageCaption; PageCaptionLbl)
                    {
                    }
                    column(PaymentTermsCaption; PaymentTermsCaptionLbl)
                    {
                    }
                    column(ShipmentMethodCaption; ShipmentMethodCaptionLbl)
                    {
                    }
                    column(DocDateCaption; DocDateCaptionLbl)
                    {
                    }
                    column(VATPercentageCaption; VATPercentageCaptionLbl)
                    {
                    }
                    column(VATBaseCaption; VATBaseCaptionLbl)
                    {
                    }
                    column(VATAmtCaption; VATAmtCaptionLbl)
                    {
                    }
                    column(VATAmtSpecificationCaption; VATAmtSpecificationCaptionLbl)
                    {
                    }
                    column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
                    {
                    }
                    column(LineAmtCaption; LineAmtCaptionLbl)
                    {
                    }
                    column(VATIdentifierCaption; VATIdentifierCaptionLbl)
                    {
                    }
                    column(TotalCaption; TotalCaptionLbl)
                    {
                    }
                    column(PrepaymentAmt_PurchInvHeader; PrepaymentAmt)
                    {
                    }
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Purch. Inv. Header";
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(DimText_DimensionLoop1; DimText)
                        {
                        }
                        column(HeaderDimensionsCaption; HeaderDimensionsCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not DimensionSetEntry1.FindSet() then
                                    CurrReport.Break();
                            end else
                                if not Continue then
                                    CurrReport.Break();

                            Clear(DimText);
                            Continue := false;
                            repeat
                                OldDimText := DimText;
                                if DimText = '' then
                                    DimText := StrSubstNo(TwoPlaceholdersTok, DimensionSetEntry1."Dimension Code", DimensionSetEntry1."Dimension Value Code")
                                else
                                    DimText :=
                                      StrSubstNo(
                                        ThreePlaceholdersTok, DimText,
                                        DimensionSetEntry1."Dimension Code", DimensionSetEntry1."Dimension Value Code");
                                if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                    DimText := OldDimText;
                                    Continue := true;
                                    exit;
                                end;
                            until DimensionSetEntry1.Next() = 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowInterInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Purch. Inv. Line"; "Purch. Inv. Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Purch. Inv. Header";
                        DataItemTableView = sorting("Document No.", "Line No.") where("Prepayment Line" = const(false));
                        column(LineAmt_PurchInvLine; "Line Amount")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(Desc_PurchInvLine; Description)
                        {
                        }
                        column(No_PurchInvLine; "No.")
                        {
                        }
                        column(Qty_PurchInvLine; Quantity)
                        {
                        }
                        column(UOM_PurchInvLine; "Unit of Measure")
                        {
                        }
                        column(DirectUnitCost_PurchInvLine; "Direct Unit Cost")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 2;
                        }
                        column(LineDisc_PurchInvLine; "Line Discount %")
                        {
                        }
                        column(AllowInvDisc_PurchInvLine; "Allow Invoice Disc.")
                        {
                            IncludeCaption = false;
                        }
                        column(VATIdentifier_PurchInvLine; "VAT Identifier")
                        {
                        }
                        column(LineNo_PurchInvLine; "Line No.")
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
                        column(NegInvDiscAmt_PurchInvLine; -"Inv. Discount Amount")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(PurchInvLineAmt; Amount)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(AmtIncVAT_PurchInvLine; "Amount Including VAT")
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(AmtIncVATAmt_PurchInvLine; "Amount Including VAT" - Amount)
                        {
                            AutoFormatExpression = GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmtText; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(NegLineAmtInvDiscAmtAmtIncVAT_PurchInvLine; -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT"))
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
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
                        column(TotalAmtVAT; TotalAmountVAT)
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
                        column(DiscountPctCaption; DiscountPctCaptionLbl)
                        {
                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(PymtDiscOnVATCaption; PymtDiscOnVATCaptionLbl)
                        {
                        }
                        column(Desc_PurchInvLineCaption; FieldCaption(Description))
                        {
                        }
                        column(No_PurchInvLineCaption; FieldCaption("No."))
                        {
                        }
                        column(Qty_PurchInvLineCaption; FieldCaption(Quantity))
                        {
                        }
                        column(UOM_PurchInvLineCaption; FieldCaption("Unit of Measure"))
                        {
                        }
                        column(VATIdentifier_PurchInvLineCaption; FieldCaption("VAT Identifier"))
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
                                    if not DimensionSetEntry2.FindSet() then
                                        CurrReport.Break();
                                end else
                                    if not Continue then
                                        CurrReport.Break();

                                Clear(DimText);
                                Continue := false;
                                repeat
                                    OldDimText := DimText;
                                    if DimText = '' then
                                        DimText := StrSubstNo(TwoPlaceholdersTok, DimensionSetEntry2."Dimension Code", DimensionSetEntry2."Dimension Value Code")
                                    else
                                        DimText :=
                                          StrSubstNo(
                                            ThreePlaceholdersTok, DimText,
                                            DimensionSetEntry2."Dimension Code", DimensionSetEntry2."Dimension Value Code");
                                    if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                        DimText := OldDimText;
                                        Continue := true;
                                        exit;
                                    end;
                                until DimensionSetEntry2.Next() = 0;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowInterInfo then
                                    CurrReport.Break();

                                DimensionSetEntry2.SetRange("Dimension Set ID", "Purch. Inv. Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if (Type = Type::"G/L Account") and (not ShowInterInfo) then
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

                            AllowVATDisctxt := Format("Allow Invoice Disc.");
                            PurchInLineTypeNo := Type.AsInteger();

                            TotalSubTotal += "Line Amount";
                            TotalInvoiceDiscountAmount -= "Inv. Discount Amount";
                            TotalAmount += Amount;
                            TotalAmountVAT += "Amount Including VAT" - Amount;
                            TotalAmountInclVAT += "Amount Including VAT";
                            TotalPaymentDiscountOnVAT += -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT");
                        end;

                        trigger OnPreDataItem()
                        var
                            PurchInvLine: Record "Purch. Inv. Line";
                            VATIdentifier: Code[20];
                        begin
                            TempVATAmountLine.DeleteAll();
                            MoreLines := Find('+');
                            while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0) and (Amount = 0) do
                                MoreLines := Next(-1) <> 0;
                            if not MoreLines then
                                CurrReport.Break();
                            SetRange("Line No.", 0, "Line No.");

                            PurchInvLine.SetRange("Document No.", "Purch. Inv. Header"."No.");
                            PurchInvLine.SetFilter(Type, '<>%1', 0);
                            VATAmountText := '';
                            if PurchInvLine.Find('-') then begin
                                VATAmountText := StrSubstNo(VATAmountTextLbl, PurchInvLine."VAT %");
                                VATIdentifier := PurchInvLine."VAT Identifier";
                                repeat
                                    if (PurchInvLine."VAT Identifier" <> VATIdentifier) and (PurchInvLine.Quantity <> 0) then
                                        VATAmountText := VATAmountLbl;
                                until PurchInvLine.Next() = 0;
                            end;
                        end;

                        trigger OnPostDataItem()
                        begin
                            PurchAdvLetterEntryCZZ.CalcUsageVATAmountLines("Purch. Inv. Header", TempVATAmountLine);
                        end;
                    }
                    dataitem(PurchAdvanceUsage; "Purch. Adv. Letter Entry CZZ")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Purch. Inv. Header";
                        DataItemTableView = sorting("Document No.") where("Entry Type" = const(Usage), Cancelled = const(false));

                        column(LetterNo_PurchAdvanceUsageCaption; FieldCaption("Purch. Adv. Letter No."))
                        {
                        }
                        column(VATDocLetterNo_PurchAdvanceUsageCaption; FieldCaption("Document No."))
                        {
                        }
                        column(AmountIncludingVAT_PurchAdvanceUsageCaption; FieldCaption(Amount))
                        {
                        }
                        column(LetterNo_PurchAdvanceUsage; "Purch. Adv. Letter No.")
                        {
                        }
                        column(AmountIncludingVAT_PurchAdvanceUsage; Amount)
                        {
                        }

                        dataitem(PurchAdvanceUsageVAT; "Purch. Adv. Letter Entry CZZ")
                        {
                            DataItemLink = "Related Entry" = field("Related Entry");
                            DataItemTableView = sorting("Purch. Adv. Letter No.", "Document No.") where("Entry Type" = const("VAT Payment"), Cancelled = const(false));

                            column(VATDocLetterNo_PurchAdvanceUsage; "Document No.")
                            {
                            }
                            column(PostingDate_PurchAdvanceUsage; "Posting Date")
                            {
                            }

                            trigger OnAfterGetRecord()
                            var
                                PurchAdvLetterEntryCZZVATUsage: Record "Purch. Adv. Letter Entry CZZ";
                            begin
                                PurchAdvLetterEntryCZZVATUsage.SetRange("Entry Type", PurchAdvLetterEntryCZZVATUsage."Entry Type"::"VAT Usage");
                                PurchAdvLetterEntryCZZVATUsage.SetRange("Related Entry", PurchAdvanceUsage."Entry No.");
                                PurchAdvLetterEntryCZZVATUsage.Setrange("Auxiliary Entry", false);
                                if PurchAdvLetterEntryCZZVATUsage.IsEmpty() then
                                    CurrReport.Break();

                                SetRange("Purch. Adv. Letter No.", "Purch. Adv. Letter No.");
                                SetRange("Document No.", "Document No.");
                                FindLast();
                                SetRange("Purch. Adv. Letter No.");
                                SetRange("Document No.");
                            end;
                        }
                    }
                    dataitem(VATCounter; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(VATAmtLineVATBase; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineLineAmt; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscBaseAmt; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscAmt; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purch. Inv. Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVAT_VATCounter; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmtLineVATIdentifier_VATCounter; TempVATAmountLine."VAT Identifier")
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
                    dataitem(VATCounterLCY; "Integer")
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
                        column(VATAmtLineVAT_VATCounterLCY; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmtLineVATIdentifier_VATCounterLCY; TempVATAmountLine."VAT Identifier")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                            VALVATBaseLCY :=
                              TempVATAmountLine.GetBaseLCY(
                                "Purch. Inv. Header"."Posting Date", "Purch. Inv. Header"."Currency Code",
                                "Purch. Inv. Header"."Currency Factor");
                            VALVATAmountLCY :=
                              TempVATAmountLine.GetAmountLCY(
                                "Purch. Inv. Header"."Posting Date", "Purch. Inv. Header"."Currency Code",
                                "Purch. Inv. Header"."Currency Factor");
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GeneralLedgerSetup."Print VAT specification in LCY") or
                               ("Purch. Inv. Header"."Currency Code" = '')
                            then
                                CurrReport.Break();

                            SetRange(Number, 1, TempVATAmountLine.Count);
                            Clear(VALVATBaseLCY);
                            Clear(VALVATAmountLCY);

                            if GeneralLedgerSetup."LCY Code" = '' then
                                VALSpecLCYHeader := VATAmtSpecificationLbl + LocalCurrencyLbl
                            else
                                VALSpecLCYHeader := VATAmtSpecificationLbl + Format(GeneralLedgerSetup."LCY Code");

                            CurrencyExchangeRate.FindCurrency("Purch. Inv. Header"."Posting Date", "Purch. Inv. Header"."Currency Code", 1);
                            CalculatedExchRate := Round(1 / "Purch. Inv. Header"."Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.000001);
                            VALExchRate := StrSubstNo(ExchangeRateLbl, CalculatedExchRate, CurrencyExchangeRate."Exchange Rate Amount");
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
                        column(ShipToAddressCaption; ShipToAddressCaptionLbl)
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
                        CopyText := FormatDocument.GetCOPYText();
                    end;

                    TotalSubTotal := 0;
                    TotalInvoiceDiscountAmount := 0;
                    TotalAmount := 0;
                    TotalAmountVAT := 0;
                    TotalAmountInclVAT := 0;
                    TotalPaymentDiscountOnVAT := 0;
                end;

                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode() then
                        Codeunit.Run(Codeunit::"Purch. Inv.-Printed", "Purch. Inv. Header");
                end;

                trigger OnPreDataItem()
                begin
                    OutputNo := 1;
                    NoOfLoops := Abs(NoOfCops) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddressFields("Purch. Inv. Header");
                FormatDocumentFields("Purch. Inv. Header");
                if Contact.Get("Buy-from Contact No.") then;
                if Contact2.Get("Pay-to Contact No.") then;
                PricesInclVATtxt := Format("Prices Including VAT");

                PurchAdvLetterEntryCZZ.SetRange("Document No.", "No.");
                PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
                PurchAdvLetterEntryCZZ.CalcSums(Amount);
                PrepaymentAmt := PurchAdvLetterEntryCZZ.Amount;

                DimensionSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");
            end;

            trigger OnPostDataItem()
            begin
                OnAfterPostDataItem("Purch. Inv. Header");
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
                    field(NoOfCopies; NoOfCops)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    field(ShowInternalInfo; ShowInterInfo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Internal Information';
                        ToolTip = 'Specifies if you want the printed report to show information that is only for internal use.';
                    }
                    field(LogInteraction; LogInter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies that interactions with the contact are logged.';
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
            InitLogInteraction();
            LogInteractionEnable := LogInter;
        end;
    }

    trigger OnInitReport()
    begin
        GeneralLedgerSetup.Get();
        CompanyInformation.Get();

        OnAfterInitReport();
    end;

    trigger OnPostReport()
    begin
        if LogInter and not IsReportInPreviewMode() then
            if "Purch. Inv. Header".FindSet() then
                repeat
                    SegManagement.LogDocument(14, "Purch. Inv. Header"."No.", 0, 0, Database::Vendor, "Purch. Inv. Header"."Buy-from Vendor No.",
                      "Purch. Inv. Header"."Purchaser Code", '', "Purch. Inv. Header"."Posting Description", '');
                until "Purch. Inv. Header".Next() = 0;
    end;

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        DimensionSetEntry1: Record "Dimension Set Entry";
        DimensionSetEntry2: Record "Dimension Set Entry";
        ResponsibilityCenter: Record "Responsibility Center";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Contact: Record Contact;
        Contact2: Record Contact;
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        SegManagement: Codeunit SegManagement;
        MoreLines: Boolean;
        OldDimText: Text[120];
        Continue: Boolean;
        LogInteractionEnable: Boolean;
        NoOfLoops: Integer;
        ReportLbl: Label 'Purchase - Invoice %1', Comment = '%1 = Document No.';
        Report2Lbl: Label 'Purchase - Prepayment Invoice %1', Comment = '%1 = Document No.';
        VATAmtSpecificationLbl: Label 'VAT Amount Specification in ';
        LocalCurrencyLbl: Label 'Local Currency';
        ExchangeRateLbl: Label 'Exchange rate: %1/%2', Comment = '%1 = Calculated Exchange Rate, %2 = Exchange Rate Amount';
        VATAmountTextLbl: Label '%1% VAT', Comment = '%1 = VAT %';
        VATAmountLbl: Label 'VAT Amount';
        PhoneNoCaptionLbl: Label 'Phone No.';
        HomePageCaptionLbl: Label 'Home Page';
        EMailCaptionLbl: Label 'Email';
        VATRegNoCaptionLbl: Label 'VAT Registration No.';
        GiroNoCaptionLbl: Label 'Giro No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccNoCaptionLbl: Label 'Account No.';
        DueDateCaptionLbl: Label 'Due Date';
        InvoiceNoCaptionLbl: Label 'Invoice No.';
        PostingDateCaptionLbl: Label 'Posting Date';
        PageCaptionLbl: Label 'Page';
        PaymentTermsCaptionLbl: Label 'Payment Terms';
        ShipmentMethodCaptionLbl: Label 'Shipment Method';
        DocDateCaptionLbl: Label 'Document Date';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        DirectUnitCostCaptionLbl: Label 'Direct Unit Cost';
        DiscountPctCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        PymtDiscOnVATCaptionLbl: Label 'Payment Discount on VAT';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATPercentageCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmtCaptionLbl: Label 'VAT Amount';
        VATAmtSpecificationCaptionLbl: Label 'VAT Amount Specification';
        InvDiscBaseAmtCaptionLbl: Label 'Inv. Disc. Base Amount';
        LineAmtCaptionLbl: Label 'Line Amount';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        TotalCaptionLbl: Label 'Total';
        ShipToAddressCaptionLbl: Label 'Ship-to Address';
        InvDiscAmtCaptionLbl: Label 'Invoice Discount Amount';
        AllowInvDiscCaptionLbl: Label 'Allow Invoice Discount';
        BuyFromContactPhoneNoLbl: Label 'Buy-from Contact Phone No.';
        BuyFromContactMobilePhoneNoLbl: Label 'Buy-from Contact Mobile Phone No.';
        BuyFromContactEmailLbl: Label 'Buy-from Contact E-Mail';
        PayToContactPhoneNoLbl: Label 'Pay-to Contact Phone No.';
        PayToContactMobilePhoneNoLbl: Label 'Pay-to Contact Mobile Phone No.';
        PayToContactEmailLbl: Label 'Pay-to Contact E-Mail';
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;
        ThreePlaceholdersTok: Label '%1, %2 %3', Locked = true;
        PaymentsLbl: Label 'Payments List';
        PrepayedLbl: Label 'Prepayed Advances';

    protected var
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        CompanyAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        VendAddr: array[8] of Text[100];
        AllowVATDisctxt: Text[30];
        CopyText: Text[30];
        DimText: Text[120];
        OrderNoText: Text[80];
        PricesInclVATtxt: Text[30];
        PurchaserText: Text[50];
        ReferenceText: Text[80];
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        VATAmountText: Text[30];
        VATNoText: Text[80];
        NoOfCops: Integer;
        OutputNo: Integer;
        PurchInLineTypeNo: Integer;
        LogInter: Boolean;
        ShowInterInfo: Boolean;
        CalculatedExchRate: Decimal;
        PrepaymentAmt: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalAmountVAT: Decimal;
        TotalInvoiceDiscountAmount: Decimal;
        TotalPaymentDiscountOnVAT: Decimal;
        TotalSubTotal: Decimal;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;

    local procedure DocumentCaption(): Text[250]
    begin
        if "Purch. Inv. Header"."Prepayment Invoice" then
            exit(Report2Lbl);
        exit(ReportLbl);
    end;

    local procedure InitLogInteraction()
    begin
        LogInter := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Purch. Inv.") <> '';
    end;

    procedure InitializeRequest(NewNoOfCopies: Integer; NewShowInternalInfo: Boolean; NewLogInteraction: Boolean)
    begin
        NoOfCops := NewNoOfCopies;
        ShowInterInfo := NewShowInternalInfo;
        LogInter := NewLogInteraction;
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;

    local procedure FormatAddressFields(var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        FormatAddress.GetCompanyAddr(PurchInvHeader."Responsibility Center", ResponsibilityCenter, CompanyInformation, CompanyAddr);
        FormatAddress.PurchInvPayTo(VendAddr, PurchInvHeader);
        FormatAddress.PurchInvShipTo(ShipToAddr, PurchInvHeader);
    end;

    local procedure FormatDocumentFields(PurchInvHeader: Record "Purch. Inv. Header")
    begin
        FormatDocument.SetTotalLabels(PurchInvHeader."Currency Code", TotalText, TotalInclVATText, TotalExclVATText);
        FormatDocument.SetPurchaser(SalespersonPurchaser, PurchInvHeader."Purchaser Code", PurchaserText);
        FormatDocument.SetPaymentTerms(PaymentTerms, PurchInvHeader."Payment Terms Code", PurchInvHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, PurchInvHeader."Shipment Method Code", PurchInvHeader."Language Code");

        OrderNoText := FormatDocument.SetText(PurchInvHeader."Order No." <> '', CopyStr(PurchInvHeader.FieldCaption("Order No."), 1, 80));
        ReferenceText := FormatDocument.SetText(PurchInvHeader."Your Reference" <> '', CopyStr(PurchInvHeader.FieldCaption("Your Reference"), 1, 80));
        VATNoText := FormatDocument.SetText(PurchInvHeader."VAT Registration No." <> '', CopyStr(PurchInvHeader.FieldCaption("VAT Registration No."), 1, 80));
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInitReport()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterPostDataItem(var PurchInvHeader: Record "Purch. Inv. Header")
    begin
    end;
}

