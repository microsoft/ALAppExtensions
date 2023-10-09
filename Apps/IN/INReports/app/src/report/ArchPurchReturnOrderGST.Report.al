// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Vendor;
using System.Globalization;
using System.Utilities;

report 18004 "Arch.Purch. Return Order GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/ArchPurchReturnOrder.rdl';
    Caption = 'Arch. Purch. Return Order';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Purchase Header Archive"; "Purchase Header Archive")
        {
            DataItemTableView = sorting("Document Type", "No.")
                                where("Document Type" = const("Return Order"));
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Purchase Return Order';

            column(Purchase_Header_Archive_Document_Type; "Document Type")
            {
            }
            column(Purchase_Header_Archive_No_; "No.")
            {
            }
            column(Purchase_Header_Archive_Doc__No__Occurrence; "Doc. No. Occurrence")
            {
            }
            column(Purchase_Header_Archive_Version_No_; "Version No.")
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

                    column(STRSUBSTNO_Text004_CopyText_; StrSubstNo(PurchReturnOrderLbl, CopyText))
                    {
                    }
                    column(CompanyRegistrationLbl; CompanyRegistrationLbl)
                    {
                    }
                    column(CompanyInfo_GST_RegistrationNo; CompanyInformation."GST Registration No.")
                    {
                    }
                    column(VendorRegistrationLbl; VendorRegistrationLbl)
                    {
                    }
                    column(Vendor_GST_RegistrationNo; Vendor."GST Registration No.")
                    {
                    }
                    column(CompanyAddr_1_; CompanyAddr[1])
                    {
                    }
                    column(CompanyAddr_2_; CompanyAddr[2])
                    {
                    }
                    column(CompanyAddr_3_; CompanyAddr[3])
                    {
                    }
                    column(CompanyAddr_4_; CompanyAddr[4])
                    {
                    }
                    column(CompanyInfo__Phone_No__; CompanyInformation."Phone No.")
                    {
                    }
                    column(CompanyInfo__Fax_No__; CompanyInformation."Fax No.")
                    {
                    }
                    column(CompanyInfo__VAT_Registration_No__; CompanyInformation."VAT Registration No.")
                    {
                    }
                    column(CompanyInfo__Giro_No__; CompanyInformation."Giro No.")
                    {
                    }
                    column(CompanyInfo__Bank_Name_; CompanyInformation."Bank Name")
                    {
                    }
                    column(CompanyInfo__Bank_Account_No__; CompanyInformation."Bank Account No.")
                    {
                    }
                    column(FORMAT__Purchase_Header_Archive___Document_Date__0_4_; Format("Purchase Header Archive"."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(Purchase_Header_Archive___VAT_Registration_No__; "Purchase Header Archive"."VAT Registration No.")
                    {
                    }
                    column(PurchaserText; PurchaserText)
                    {
                    }
                    column(SalesPurchPerson_Name; SalesPurchPerson.Name)
                    {
                    }
                    column(Purchase_Header_Archive___No__; "Purchase Header Archive"."No.")
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(Purchase_Header_Archive___Your_Reference_; "Purchase Header Archive"."Your Reference")
                    {
                    }
                    column(CompanyAddr_5_; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr_6_; CompanyAddr[6])
                    {
                    }
                    column(Purchase_Header_Archive___Buy_from_Vendor_No__; "Purchase Header Archive"."Buy-from Vendor No.")
                    {
                    }
                    column(BuyFromAddr_1_; BuyFromAddr[1])
                    {
                    }
                    column(BuyFromAddr_2_; BuyFromAddr[2])
                    {
                    }
                    column(BuyFromAddr_3_; BuyFromAddr[3])
                    {
                    }
                    column(BuyFromAddr_4_; BuyFromAddr[4])
                    {
                    }
                    column(BuyFromAddr_5_; BuyFromAddr[5])
                    {
                    }
                    column(BuyFromAddr_6_; BuyFromAddr[6])
                    {
                    }
                    column(BuyFromAddr_7_; BuyFromAddr[7])
                    {
                    }
                    column(BuyFromAddr_8_; BuyFromAddr[8])
                    {
                    }
                    column(Purchase_Header_Archive___Prices_Including_VAT_; "Purchase Header Archive"."Prices Including VAT")
                    {
                    }
                    column(STRSUBSTNO_Text010__Purchase_Header_Archive___Version_No____Purchase_Header_Archive___No__of_Archived_Versions__; StrSubstNo(VersionLbl, "Purchase Header Archive"."Version No.", "Purchase Header Archive"."No. of Archived Versions"))
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(Purchase_Header_Archive___VAT_Base_Discount___; "Purchase Header Archive"."VAT Base Discount %")
                    {
                    }
                    column(PricesInclVATtxt; PricesInclVATtxt)
                    {
                    }
                    column(ShowInternalInfo; ShowInternalInfo)
                    {
                    }
                    column(PageLoop_Number; Number)
                    {
                    }
                    column(CompanyInfo__Phone_No__Caption; CompanyInfo__Phone_No__CaptionLbl)
                    {
                    }
                    column(CompanyInfo__Fax_No__Caption; CompanyInfo__Fax_No__CaptionLbl)
                    {
                    }
                    column(CompanyInfo__VAT_Registration_No__Caption; CompanyInfo__VAT_Registration_No__CaptionLbl)
                    {
                    }
                    column(CompanyInfo__Giro_No__Caption; CompanyInfo__Giro_No__CaptionLbl)
                    {
                    }
                    column(CompanyInfo__Bank_Name_Caption; CompanyInfo__Bank_Name_CaptionLbl)
                    {
                    }
                    column(CompanyInfo__Bank_Account_No__Caption; CompanyInfo__Bank_Account_No__CaptionLbl)
                    {
                    }
                    column(Order_No_Caption; Order_No_CaptionLbl)
                    {
                    }
                    column(Purchase_Header_Archive___Buy_from_Vendor_No__Caption; "Purchase Header Archive".FieldCaption("Buy-from Vendor No."))
                    {
                    }
                    column(Purchase_Header_Archive___Prices_Including_VAT_Caption; "Purchase Header Archive".FieldCaption("Prices Including VAT"))
                    {
                    }
                    column(PageCaption; PageCaptionLbl)
                    {
                    }
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Purchase Header Archive";
                        DataItemTableView = sorting(Number)
                                            where(Number = filter(1 ..));

                        column(DimText; DimText)
                        {
                        }
                        column(DimText_Control72; DimText)
                        {
                        }
                        column(DimensionLoop1_Number; Number)
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
                    }
                    dataitem("Purchase Line Archive"; "Purchase Line Archive")
                    {
                        DataItemLink = "Document Type" = field("Document Type"),
                                       "Document No." = field("No."),
                                       "Doc. No. Occurrence" = field("Doc. No. Occurrence"),
                                       "Version No." = field("Version No.");
                        DataItemLinkReference = "Purchase Header Archive";
                        DataItemTableView = sorting("Document Type", "Document No.", "Doc. No. Occurrence", "Version No.", "Line No.");


                        trigger OnPreDataItem()
                        begin
                            CurrReport.Break();
                        end;
                    }
                    dataitem(RoundLoop; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(PurchLineArch__Line_Amount_; TempPurchLineArch."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Line Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Purchase_Line_Archive__Description; "Purchase Line Archive".Description)
                        {
                        }
                        column(Purchase_Line_Archive___Line_No__; "Purchase Line Archive"."Line No.")
                        {
                        }
                        column(AllowInvDisctxt; AllowInvDisctxt)
                        {
                        }
                        column(Purchase_Line_Archive__Type; PurchaseLineArchiveType)
                        {
                        }
                        column(Purchase_Line_Archive___No__; "Purchase Line Archive"."No.")
                        {
                        }
                        column(Purchase_Line_Archive__Description_Control63; "Purchase Line Archive".Description)
                        {
                        }
                        column(Purchase_Line_Archive__Quantity; "Purchase Line Archive".Quantity)
                        {
                        }
                        column(Purchase_Line_Archive___Unit_of_Measure_; "Purchase Line Archive"."Unit of Measure")
                        {
                        }
                        column(Purchase_Line_Archive___Direct_Unit_Cost_; "Purchase Line Archive"."Direct Unit Cost")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 2;
                        }
                        column(Purchase_Line_Archive___Line_Discount___; "Purchase Line Archive"."Line Discount %")
                        {
                        }
                        column(Purchase_Line_Archive___Line_Amount_; "Purchase Line Archive"."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Purchase_Line_Archive___Allow_Invoice_Disc__; "Purchase Line Archive"."Allow Invoice Disc.")
                        {
                        }
                        column(Purchase_Line_Archive___VAT_Identifier_; "Purchase Line Archive"."VAT Identifier")
                        {
                        }
                        column(PurchLineArch__Line_Amount__Control77; TempPurchLineArch."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PurchLineArch__Inv__Discount_Amount_; -TempPurchLineArch."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Line Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PurchLineArch__Line_Amount__Control109; TempPurchLineArch."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(PurchLineArch__Line_Amount__PurchLineArch__Inv__Discount_Amount_; TempPurchLineArch."Line Amount" - TempPurchLineArch."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(VATAmountLine_VATAmountText; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(VATAmount; VATAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PurchLineArch__Line_Amount__PurchLineArch__Inv__Discount_Amount____VATAmount; TempPurchLineArch."Line Amount" - TempPurchLineArch."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(PurchLineArch__Line_Amount__PurchLineArch__Inv__Discount_Amount__Control147; TempPurchLineArch."Line Amount" - TempPurchLineArch."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATDiscountAmount; -VATDiscountAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine_VATAmountText_Control32; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(TotalExclVATText_Control51; TotalExclVATText)
                        {
                        }
                        column(TotalInclVATText_Control69; TotalInclVATText)
                        {
                        }
                        column(VATBaseAmount; VATBaseAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmount_Control83; VATAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmountInclVAT; TotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(RoundLoop_Number; Number)
                        {
                        }
                        column(TotalSubTotal; TotalSubTotal)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInvoiceDiscountAmount; TotalInvoiceDiscountAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmount; TotalAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Purchase_Line_Archive___No__Caption; "Purchase Line Archive".FieldCaption("No."))
                        {
                        }
                        column(Purchase_Line_Archive__Description_Control63Caption; "Purchase Line Archive".FieldCaption(Description))
                        {
                        }
                        column(Purchase_Line_Archive__QuantityCaption; "Purchase Line Archive".FieldCaption(Quantity))
                        {
                        }
                        column(Purchase_Line_Archive___Unit_of_Measure_Caption; "Purchase Line Archive".FieldCaption("Unit of Measure"))
                        {
                        }
                        column(Direct_Unit_CostCaption; Direct_Unit_CostCaptionLbl)
                        {
                        }
                        column(Purchase_Line_Archive___Line_Discount___Caption; Purchase_Line_Archive___Line_Discount___CaptionLbl)
                        {
                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {
                        }
                        column(Purchase_Line_Archive___Allow_Invoice_Disc__Caption; "Purchase Line Archive".FieldCaption("Allow Invoice Disc."))
                        {
                        }
                        column(Purchase_Line_Archive___VAT_Identifier_Caption; "Purchase Line Archive".FieldCaption("VAT Identifier"))
                        {
                        }
                        column(ContinuedCaption; ContinuedCaptionLbl)
                        {
                        }
                        column(ContinuedCaption_Control76; ContinuedCaption_Control76Lbl)
                        {
                        }
                        column(PurchLineArch__Inv__Discount_Amount_Caption; PurchLineArch__Inv__Discount_Amount_CaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(VATDiscountAmountCaption; VATDiscountAmountCaptionLbl)
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText_Control74; DimText)
                            {
                            }
                            column(DimensionLoop2_Number; Number)
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

                            trigger OnPreDataItem()
                            begin
                                if not ShowInternalInfo then
                                    CurrReport.Break();

                                DimSetEntry2.SetRange("Dimension Set ID", "Purchase Line Archive"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                TempPurchLineArch.FindFirst()
                            else
                                TempPurchLineArch.Next();
                            "Purchase Line Archive" := TempPurchLineArch;

                            if not "Purchase Header Archive"."Prices Including VAT" and
                               (TempPurchLineArch."VAT Calculation Type" = TempPurchLineArch."VAT Calculation Type"::"Full VAT")
                            then
                                TempPurchLineArch."Line Amount" := 0;

                            if (TempPurchLineArch.Type = TempPurchLineArch.Type::"G/L Account") and (not ShowInternalInfo) then
                                "Purchase Line Archive"."No." := '';
                            AllowInvDisctxt := Format("Purchase Line Archive"."Allow Invoice Disc.");
                            PurchaseLineArchiveType := "Purchase Line Archive".Type.AsInteger();

                            TotalSubTotal += "Purchase Line Archive"."Line Amount";
                            TotalInvoiceDiscountAmount -= "Purchase Line Archive"."Inv. Discount Amount";
                            TotalAmount += "Purchase Line Archive".Amount;
                        end;

                        trigger OnPostDataItem()
                        begin
                            TempPurchLineArch.DeleteAll();
                        end;

                        trigger OnPreDataItem()
                        begin
                            MoreLines := TempPurchLineArch.FindLast();

                            while MoreLines and
                                (TempPurchLineArch.Description = '') and
                                (TempPurchLineArch."Description 2" = '') and
                                (TempPurchLineArch."No." = '') and
                                (TempPurchLineArch.Quantity = 0) and
                                (TempPurchLineArch.Amount = 0)
                            do
                                MoreLines := TempPurchLineArch.Next(-1) <> 0;

                            if not MoreLines then
                                CurrReport.Break();

                            TempPurchLineArch.SetRange("Line No.", 0, TempPurchLineArch."Line No.");
                            SetRange(Number, 1, TempPurchLineArch.Count);
                        end;
                    }
                    dataitem(VATCounter; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(VATAmountLine__VAT_Base_; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount_; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount_; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount_; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount_; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT___; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmountLine__VAT_Base__Control99; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount__Control100; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Identifier_; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATAmountLine__Line_Amount__Control131; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control132; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control133; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base__Control103; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount__Control104; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount__Control56; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control57; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control58; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Base__Control107; TempVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT_Amount__Control108; TempVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Line_Amount__Control59; TempVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control60; TempVATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control61; TempVATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATCounter_Number; Number)
                        {
                        }
                        column(VATAmountLine__VAT___Caption; VATAmountLine__VAT___CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Base__Control99Caption; VATAmountLine__VAT_Base__Control99CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Amount__Control100Caption; VATAmountLine__VAT_Amount__Control100CaptionLbl)
                        {
                        }
                        column(VAT_Amount_SpecificationCaption; VAT_Amount_SpecificationCaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Identifier_Caption; VATAmountLine__VAT_Identifier_CaptionLbl)
                        {
                        }
                        column(VATAmountLine__Inv__Disc__Base_Amount__Control132Caption; VATAmountLine__Inv__Disc__Base_Amount__Control132CaptionLbl)
                        {
                        }
                        column(VATAmountLine__Line_Amount__Control131Caption; VATAmountLine__Line_Amount__Control131CaptionLbl)
                        {
                        }
                        column(VATAmountLine__Invoice_Discount_Amount__Control133Caption; VATAmountLine__Invoice_Discount_Amount__Control133CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Base_Caption; VATAmountLine__VAT_Base_CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Base__Control103Caption; VATAmountLine__VAT_Base__Control103CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Base__Control107Caption; VATAmountLine__VAT_Base__Control107CaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if VATAmount = 0 then
                                CurrReport.Break();

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
                        column(VALVATAmountLCY_Control158; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY_Control159; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmountLine__VAT____Control160; TempVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmountLine__VAT_Identifier__Control161; TempVATAmountLine."VAT Identifier")
                        {
                        }
                        column(VALVATAmountLCY_Control162; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY_Control163; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATAmountLCY_Control165; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY_Control166; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATCounterLCY_Number; Number)
                        {
                        }
                        column(VALVATAmountLCY_Control158Caption; VALVATAmountLCY_Control158CaptionLbl)
                        {
                        }
                        column(VALVATBaseLCY_Control159Caption; VALVATBaseLCY_Control159CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT____Control160Caption; VATAmountLine__VAT____Control160CaptionLbl)
                        {
                        }
                        column(VATAmountLine__VAT_Identifier__Control161Caption; VATAmountLine__VAT_Identifier__Control161CaptionLbl)
                        {
                        }
                        column(VALVATBaseLCYCaption; VALVATBaseLCYCaptionLbl)
                        {
                        }
                        column(VALVATBaseLCY_Control163Caption; VALVATBaseLCY_Control163CaptionLbl)
                        {
                        }
                        column(VALVATBaseLCY_Control166Caption; VALVATBaseLCY_Control166CaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempVATAmountLine.GetLine(Number);
                            VALVATBaseLCY := TempVATAmountLine.GetBaseLCY(
                                "Purchase Header Archive"."Posting Date",
                                "Purchase Header Archive"."Currency Code",
                                "Purchase Header Archive"."Currency Factor");
                            VALVATAmountLCY := TempVATAmountLine.GetAmountLCY(
                                "Purchase Header Archive"."Posting Date",
                                "Purchase Header Archive"."Currency Code",
                                "Purchase Header Archive"."Currency Factor");
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GeneralLedgerSetup."Print VAT specification in LCY") or
                               ("Purchase Header Archive"."Currency Code" = '') or
                               (TempVATAmountLine.GetTotalVATAmount() = 0)
                            then
                                CurrReport.Break();

                            SetRange(Number, 1, TempVATAmountLine.Count);

                            if GeneralLedgerSetup."LCY Code" = '' then
                                VALSpecLCYHeader := VATAMtLbl + LocalCurLbl
                            else
                                VALSpecLCYHeader := VATAMtLbl + Format(GeneralLedgerSetup."LCY Code");

                            CurrExchRate.FindCurrency("Purchase Header Archive"."Posting Date", "Purchase Header Archive"."Currency Code", 1);
                            VALExchRate := StrSubstNo(
                                ExchrateLbl,
                                CurrExchRate."Relational Exch. Rate Amount",
                                CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem(Total; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

                        column(PaymentTerms_Description; PaymentTerms.Description)
                        {
                        }
                        column(ShipmentMethod_Description; ShipmentMethod.Description)
                        {
                        }
                        column(Total_Number; Number)
                        {
                        }
                        column(PaymentTerms_DescriptionCaption; PaymentTerms_DescriptionCaptionLbl)
                        {
                        }
                        column(ShipmentMethod_DescriptionCaption; ShipmentMethod_DescriptionCaptionLbl)
                        {
                        }
                    }
                    dataitem(Total2; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

                        column(Purchase_Header_Archive___Pay_to_Vendor_No__; "Purchase Header Archive"."Pay-to Vendor No.")
                        {
                        }
                        column(VendAddr_8_; VendAddr[8])
                        {
                        }
                        column(VendAddr_7_; VendAddr[7])
                        {
                        }
                        column(VendAddr_6_; VendAddr[6])
                        {
                        }
                        column(VendAddr_5_; VendAddr[5])
                        {
                        }
                        column(VendAddr_4_; VendAddr[4])
                        {
                        }
                        column(VendAddr_3_; VendAddr[3])
                        {
                        }
                        column(VendAddr_2_; VendAddr[2])
                        {
                        }
                        column(VendAddr_1_; VendAddr[1])
                        {
                        }
                        column(Total2_Number; Number)
                        {
                        }
                        column(Payment_DetailsCaption; Payment_DetailsCaptionLbl)
                        {
                        }
                        column(Vendor_No_Caption; Vendor_No_CaptionLbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if "Purchase Header Archive"."Buy-from Vendor No." = "Purchase Header Archive"."Pay-to Vendor No." then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(Total3; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

                        column(Purchase_Header_Archive___Sell_to_Customer_No__; "Purchase Header Archive"."Sell-to Customer No.")
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
                        column(Total3_Number; Number)
                        {
                        }
                        column(Ship_to_AddressCaption; Ship_to_AddressCaptionLbl)
                        {
                        }
                        column(Purchase_Header_Archive___Sell_to_Customer_No__Caption; "Purchase Header Archive".FieldCaption("Sell-to Customer No."))
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if ("Purchase Header Archive"."Sell-to Customer No." = '') and (ShipToAddr[1] = '') then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(PrepmtLoop; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = filter(1 ..));

                        column(PrepmtLineAmount; PrepmtLineAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtInvBuf__G_L_Account_No__; TempPrepmtInvBuf."G/L Account No.")
                        {
                        }
                        column(PrepmtLineAmount_Control173; PrepmtLineAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                        }
                        column(PrepmtInvBuf_Description; TempPrepmtInvBuf.Description)
                        {
                        }
                        column(PrepmtLineAmount_Control177; PrepmtLineAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalExclVATText_Control182; TotalExclVATText)
                        {
                        }
                        column(PrepmtInvBuf_Amount; TempPrepmtInvBuf.Amount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine_VATAmountText; TempPrepmtVATAmountLine.VATAmountText())
                        {
                        }
                        column(PrepmtVATAmount; PrepmtVATAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText_Control186; TotalInclVATText)
                        {
                        }
                        column(PrepmtInvBuf_Amount___PrepmtVATAmount; TempPrepmtInvBuf.Amount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText_Control188; TotalInclVATText)
                        {
                        }
                        column(VATAmountLine_VATAmountText_Control189; TempVATAmountLine.VATAmountText())
                        {
                        }
                        column(PrepmtVATAmount_Control190; PrepmtVATAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtTotalAmountInclVAT; PrepmtTotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalExclVATText_Control192; TotalExclVATText)
                        {
                        }
                        column(PrepmtVATBaseAmount; PrepmtVATBaseAmount)
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtLoop_Number; Number)
                        {
                        }
                        column(PrepmtLineAmount_Control173Caption; PrepmtLineAmount_Control173CaptionLbl)
                        {
                        }
                        column(PrepmtInvBuf_DescriptionCaption; PrepmtInvBuf_DescriptionCaptionLbl)
                        {
                        }
                        column(PrepmtInvBuf__G_L_Account_No__Caption; PrepmtInvBuf__G_L_Account_No__CaptionLbl)
                        {
                        }
                        column(Prepayment_SpecificationCaption; Prepayment_SpecificationCaptionLbl)
                        {
                        }
                        column(ContinuedCaption_Control176; ContinuedCaption_Control176Lbl)
                        {
                        }
                        column(ContinuedCaption_Control178; ContinuedCaption_Control178Lbl)
                        {
                        }
                        dataitem(PrepmtDimLoop; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText_Control179; DimText)
                            {
                            }
                            column(DimText_Control181; DimText)
                            {
                            }
                            column(PrepmtDimLoop_Number; Number)
                            {
                            }
                            column(Line_DimensionsCaption_Control180; Line_DimensionsCaption_Control180Lbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                DimText := GetDimensionText(PrepmtDimSetEntry, Number, Continue);
                                if not Continue then
                                    CurrReport.Break();
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not TempPrepmtInvBuf.Find('-') then
                                    CurrReport.Break();
                            end else
                                if TempPrepmtInvBuf.Next() = 0 then
                                    CurrReport.Break();

                            if ShowInternalInfo then
                                PrepmtDimSetEntry.SetRange("Dimension Set ID", TempPrepmtInvBuf."Dimension Set ID");

                            if "Purchase Header Archive"."Prices Including VAT" then
                                PrepmtLineAmount := TempPrepmtInvBuf."Amount Incl. VAT"
                            else
                                PrepmtLineAmount := TempPrepmtInvBuf.Amount;
                        end;
                    }
                    dataitem(PrepmtVATCounter; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(PrepmtVATAmountLine__VAT_Amount_; TempPrepmtVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__VAT_Base_; TempPrepmtVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__Line_Amount_; TempPrepmtVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__VAT___; TempPrepmtVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(PrepmtVATAmountLine__VAT_Amount__Control194; TempPrepmtVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__VAT_Base__Control195; TempPrepmtVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__Line_Amount__Control196; TempPrepmtVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__VAT____Control197; TempPrepmtVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(PrepmtVATAmountLine__VAT_Identifier_; TempPrepmtVATAmountLine."VAT Identifier")
                        {
                        }
                        column(PrepmtVATAmountLine__VAT_Amount__Control210; TempPrepmtVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__VAT_Base__Control211; TempPrepmtVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__Line_Amount__Control212; TempPrepmtVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__VAT____Control213; TempPrepmtVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(PrepmtVATAmountLine__VAT_Amount__Control215; TempPrepmtVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__VAT_Base__Control216; TempPrepmtVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmountLine__Line_Amount__Control217; TempPrepmtVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header Archive"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATCounter_Number; Number)
                        {
                        }
                        column(PrepmtVATAmountLine__VAT_Amount__Control194Caption; PrepmtVATAmountLine__VAT_Amount__Control194CaptionLbl)
                        {
                        }
                        column(PrepmtVATAmountLine__VAT_Base__Control195Caption; PrepmtVATAmountLine__VAT_Base__Control195CaptionLbl)
                        {
                        }
                        column(PrepmtVATAmountLine__Line_Amount__Control196Caption; PrepmtVATAmountLine__Line_Amount__Control196CaptionLbl)
                        {
                        }
                        column(PrepmtVATAmountLine__VAT____Control197Caption; PrepmtVATAmountLine__VAT____Control197CaptionLbl)
                        {
                        }
                        column(Prepayment_VAT_Amount_SpecificationCaption; Prepayment_VAT_Amount_SpecificationCaptionLbl)
                        {
                        }
                        column(PrepmtVATAmountLine__VAT_Identifier_Caption; PrepmtVATAmountLine__VAT_Identifier_CaptionLbl)
                        {
                        }
                        column(ContinuedCaption_Control209; ContinuedCaption_Control209Lbl)
                        {
                        }
                        column(ContinuedCaption_Control214; ContinuedCaption_Control214Lbl)
                        {
                        }
                        column(PrepmtVATAmountLine__VAT_Base__Control216Caption; PrepmtVATAmountLine__VAT_Base__Control216CaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            TempPrepmtVATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number, 1, TempPrepmtVATAmountLine.Count);
                        end;
                    }
                    dataitem(PrepmtTotal; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

                        column(PrepmtPaymentTerms_Description; PrepmtPaymentTerms.Description)
                        {
                        }
                        column(PrepmtTotal_Number; Number)
                        {
                        }
                        column(PrepmtPaymentTerms_DescriptionCaption; PrepmtPaymentTerms_DescriptionCaptionLbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if not TempPrepmtInvBuf.Find('-') then
                                CurrReport.Break();
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                var
                    PurchLineArchive: Record "Purchase Line Archive";
                begin
                    Clear(TempPurchLineArch);
                    TempPurchLineArch.DeleteAll();
                    PurchLineArchive.SetRange("Document Type", "Purchase Header Archive"."Document Type");
                    PurchLineArchive.SetRange("Document No.", "Purchase Header Archive"."No.");
                    PurchLineArchive.SetRange("Version No.", "Purchase Header Archive"."Version No.");
                    if PurchLineArchive.FindSet() then
                        repeat
                            TempPurchLineArch := PurchLineArchive;
                            TempPurchLineArch.Insert();
                        until PurchLineArchive.Next() = 0;

                    TempVATAmountLine.DeleteAll();
                    if Number > 1 then
                        CopyText := CopyLbl;

                    OutputNo := OutputNo + 1;
                    TotalSubTotal := 0;
                    TotalInvoiceDiscountAmount := 0;
                    TotalAmount := 0;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then
                        PurchCountPrintedArch.Run("Purchase Header Archive");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopy) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                    OutputNo := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.LANGUAGE := Language.GetLanguageID("Language Code");
                CurrReport.FormatRegion := Language.GetFormatRegionOrDefault("Format Region");
                Vendor.Get("Buy-from Vendor No.");
                CompanyInformation.Get();

                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInformation."Phone No." := RespCenter."Phone No.";
                    CompanyInformation."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInformation);

                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

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
                    ReferenceText := CopyStr(FieldCaption("Your Reference"), 1, 80);

                if "VAT Registration No." = '' then
                    VATNoText := ''
                else
                    VATNoText := CopyStr(FieldCaption("VAT Registration No."), 1, 80);

                if "Currency Code" = '' then begin
                    GeneralLedgerSetup.TestField("LCY Code");
                    TotalText := StrSubstNo(TotalLbl, GeneralLedgerSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(TotaIncVatLbl, GeneralLedgerSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(TotalExclVatLbl, GeneralLedgerSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(TotalLbl, "Currency Code");
                    TotalInclVATText := StrSubstNo(TotaIncVatLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(TotalExclVatLbl, "Currency Code");
                end;

                FormatAddr.PurchHeaderBuyFromArch(BuyFromAddr, "Purchase Header Archive");
                if "Buy-from Vendor No." <> "Pay-to Vendor No." then
                    FormatAddr.PurchHeaderPayToArch(VendAddr, "Purchase Header Archive");

                if "Payment Terms Code" = '' then
                    PaymentTerms.Init()
                else begin
                    PaymentTerms.Get("Payment Terms Code");
                    PaymentTerms.TranslateDescription(PaymentTerms, "Language Code");
                end;

                if "Prepmt. Payment Terms Code" = '' then
                    PrepmtPaymentTerms.Init()
                else begin
                    PrepmtPaymentTerms.Get("Prepmt. Payment Terms Code");
                    PrepmtPaymentTerms.TranslateDescription(PrepmtPaymentTerms, "Language Code");
                end;

                if "Shipment Method Code" = '' then
                    PrepmtPaymentTerms.Init()
                else begin
                    ShipmentMethod.Get("Shipment Method Code");
                    ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                end;

                CalcFields("No. of Archived Versions");
                FormatAddr.PurchHeaderShipToArch(ShipToAddr, "Purchase Header Archive");
                PricesInclVATtxt := Format("Prices Including VAT");
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
                    field(NoOfCopies; NoOfCopy)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of copies that need to be printed.';
                    }
                    field(ShowInternalInformation; ShowInternalInfo)
                    {
                        Caption = 'Show Internal Information';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the line internal information.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }


    trigger OnInitReport()
    begin
        GeneralLedgerSetup.Get();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        PrepmtPaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        Vendor: Record "Vendor";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TempPrepmtVATAmountLine: Record "VAT Amount Line" temporary;
        TempPurchLineArch: Record "Purchase Line Archive" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        PrepmtDimSetEntry: Record "Dimension Set Entry";
        TempPrepmtInvBuf: Record "Prepayment Inv. Line Buffer" temporary;
        RespCenter: Record "Responsibility Center";
        CurrExchRate: Record "Currency Exchange Rate";
        FormatAddr: Codeunit "Format Address";
        PurchCountPrintedArch: Codeunit "Purch.HeaderArch-Printed";
        Language: Codeunit "Language";
        VendAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        BuyFromAddr: array[8] of Text[50];
        PurchaserText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        MoreLines: Boolean;
        NoOfCopy: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        OutputNo: Integer;
        PurchaseLineArchiveType: Integer;
        DimText: Text[120];
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        VATAmount: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        PrepmtVATAmount: Decimal;
        PrepmtVATBaseAmount: Decimal;
        PrepmtTotalAmountInclVAT: Decimal;
        PrepmtLineAmount: Decimal;
        PricesInclVATtxt: Text[30];
        AllowInvDisctxt: Text[30];
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;
        TotalInvoiceDiscountAmount: Decimal;
        VATAMtLbl: Label 'VAT Amount Specification in ', Locked = true;
        LocalCurLbl: Label 'Local Currency', Locked = true;
        ExchRateLbl: Label 'Exchange rate: %1/%2', Comment = '%1 = Relational Exch. Rate Amount %2 = Exchange Rate Amount';
        PurchLbl: Label 'Purchaser', Locked = true;
        TotalLbl: Label 'Total %1', Comment = '%1 = LCY Code';
        TotaIncVatLbl: Label 'Total %1 Incl. VAT', Comment = '%1 = LCY Code';
        CopyLbl: Label 'COPY', Locked = true;
        PurchReturnOrderLbl: Label 'Purchase Return Order Archived %1', Comment = ' %1 = CopyText';
        TotalExclVatLbl: Label 'Total %1 Excl. VAT', Comment = ' %1 = Currency Code';
        VersionLbl: Label 'Version %1 of %2 ', Comment = ' %1 = Version No. , %2 = No. of Archived Versions';
        CompanyInfo__Phone_No__CaptionLbl: Label 'Phone No.', Locked = true;
        CompanyInfo__Fax_No__CaptionLbl: Label 'Fax No.', Locked = true;
        CompanyInfo__VAT_Registration_No__CaptionLbl: Label 'VAT Reg. No.', Locked = true;
        CompanyInfo__Giro_No__CaptionLbl: Label 'Giro No.', Locked = true;
        CompanyInfo__Bank_Name_CaptionLbl: Label 'Bank', Locked = true;
        CompanyInfo__Bank_Account_No__CaptionLbl: Label 'Account No.', Locked = true;
        Order_No_CaptionLbl: Label 'Order No.', Locked = true;
        PageCaptionLbl: Label 'Page', Locked = true;
        Header_DimensionsCaptionLbl: Label 'Header Dimensions', Locked = true;
        Direct_Unit_CostCaptionLbl: Label 'Direct Unit Cost', Locked = true;
        Purchase_Line_Archive___Line_Discount___CaptionLbl: Label 'Disc. %';
        AmountCaptionLbl: Label 'Amount', Locked = true;
        ContinuedCaptionLbl: Label 'Continued', Locked = true;
        ContinuedCaption_Control76Lbl: Label 'Continued', Locked = true;
        PurchLineArch__Inv__Discount_Amount_CaptionLbl: Label 'Inv. Discount Amount', Locked = true;
        SubtotalCaptionLbl: Label 'Subtotal', Locked = true;
        VATDiscountAmountCaptionLbl: Label 'Payment Discount on VAT', Locked = true;
        Line_DimensionsCaptionLbl: Label 'Line Dimensions', Locked = true;
        VATAmountLine__VAT___CaptionLbl: Label 'VAT %', Locked = true;
        VATAmountLine__VAT_Base__Control99CaptionLbl: Label 'VAT Base', Locked = true;
        VATAmountLine__VAT_Amount__Control100CaptionLbl: Label 'VAT Amount', Locked = true;
        VAT_Amount_SpecificationCaptionLbl: Label 'VAT Amount Specification', Locked = true;
        VATAmountLine__VAT_Identifier_CaptionLbl: Label 'VAT Identifier', Locked = true;
        VATAmountLine__Inv__Disc__Base_Amount__Control132CaptionLbl: Label 'Inv. Disc. Base Amount', Locked = true;
        VATAmountLine__Line_Amount__Control131CaptionLbl: Label 'Line Amount', Locked = true;
        VATAmountLine__Invoice_Discount_Amount__Control133CaptionLbl: Label 'Invoice Discount Amount', Locked = true;
        VATAmountLine__VAT_Base_CaptionLbl: Label 'Continued', Locked = true;
        VATAmountLine__VAT_Base__Control103CaptionLbl: Label 'Continued', Locked = true;
        VATAmountLine__VAT_Base__Control107CaptionLbl: Label 'Total', Locked = true;
        VALVATAmountLCY_Control158CaptionLbl: Label 'VAT Amount', Locked = true;
        VALVATBaseLCY_Control159CaptionLbl: Label 'VAT Base', Locked = true;
        VATAmountLine__VAT____Control160CaptionLbl: Label 'VAT %';
        VATAmountLine__VAT_Identifier__Control161CaptionLbl: Label 'VAT Identifier', Locked = true;
        VALVATBaseLCYCaptionLbl: Label 'Continued', Locked = true;
        VALVATBaseLCY_Control163CaptionLbl: Label 'Continued', Locked = true;
        VALVATBaseLCY_Control166CaptionLbl: Label 'Total', Locked = true;
        PaymentTerms_DescriptionCaptionLbl: Label 'Payment Terms', Locked = true;
        ShipmentMethod_DescriptionCaptionLbl: Label 'Shipment Method', Locked = true;
        Payment_DetailsCaptionLbl: Label 'Payment Details', Locked = true;
        Vendor_No_CaptionLbl: Label 'Vendor No.', Locked = true;
        Ship_to_AddressCaptionLbl: Label 'Ship-to Address', Locked = true;
        PrepmtLineAmount_Control173CaptionLbl: Label 'Amount', Locked = true;
        PrepmtInvBuf_DescriptionCaptionLbl: Label 'Description', Locked = true;
        PrepmtInvBuf__G_L_Account_No__CaptionLbl: Label 'G/L Account No.', Locked = true;
        Prepayment_SpecificationCaptionLbl: Label 'Prepayment Specification', Locked = true;
        ContinuedCaption_Control176Lbl: Label 'Continued', Locked = true;
        ContinuedCaption_Control178Lbl: Label 'Continued', Locked = true;
        Line_DimensionsCaption_Control180Lbl: Label 'Line Dimensions', Locked = true;
        PrepmtVATAmountLine__VAT_Amount__Control194CaptionLbl: Label 'VAT Amount', Locked = true;
        PrepmtVATAmountLine__VAT_Base__Control195CaptionLbl: Label 'VAT Base', Locked = true;
        PrepmtVATAmountLine__Line_Amount__Control196CaptionLbl: Label 'Line Amount', Locked = true;
        PrepmtVATAmountLine__VAT____Control197CaptionLbl: Label 'VAT %', Locked = true;
        Prepayment_VAT_Amount_SpecificationCaptionLbl: Label 'Prepayment VAT Amount Specification', Locked = true;
        PrepmtVATAmountLine__VAT_Identifier_CaptionLbl: Label 'VAT Identifier', Locked = true;
        ContinuedCaption_Control209Lbl: Label 'Continued', Locked = true;
        ContinuedCaption_Control214Lbl: Label 'Continued', Locked = true;
        PrepmtVATAmountLine__VAT_Base__Control216CaptionLbl: Label 'Total', Locked = true;
        PrepmtPaymentTerms_DescriptionCaptionLbl: Label 'Prepmt. Payment Terms', Locked = true;
        CompanyRegistrationLbl: Label 'Company Registration No.', Locked = true;
        VendorRegistrationLbl: Label 'Vendor GST Reg No.', Locked = true;

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
