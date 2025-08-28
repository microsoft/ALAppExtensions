// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Setup;
using System.Globalization;
using System.Utilities;
using System.Telemetry;

report 10602 "Blanket Order Sales GB"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/BlanketSalesOrderGB.rdlc';
    Caption = 'Blanket Sales Order';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const("Blanket Order"));
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'Blanket Sales Order';
            column(DocType_SalesHeader; "Document Type")
            {
            }
            column(No_SalesHeader; "No.")
            {
            }
            column(InvDiscountAmtCaption; InvDiscountAmtCaptionLbl)
            {
            }
            column(ShipmentDateCaption; ShipmentDateCaptionLbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo3Picture; CompanyInfo3.Picture)
                    {
                    }
                    column(BlanketSalesOrderText; StrSubstNo(Text004Lbl, CopyText))
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
                    column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
                    {
                    }
                    column(CustAddr6; CustAddr[6])
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoEmail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoVATNo; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyBankAccount.Name)
                    {
                    }
                    column(CompanyInfoBankNo; CompanyBankAccount."Bank Account No.")
                    {
                    }
                    column(BillNo_SalesHeader; "Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(DocDate_SalesHeader; Format("Sales Header"."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATNo_SalesHeader; "Sales Header"."VAT Registration No.")
                    {
                    }
                    column(ShptDate_SalesHeader; Format("Sales Header"."Shipment Date"))
                    {
                    }
                    column(SalesPersonText; SalesPersonText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(No1_SalesHeader; "Sales Header"."No.")
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(Reference_SalesHeader; "Sales Header"."Your Reference")
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
                    column(VATPrice_SalesHeader; "Sales Header"."Prices Including VAT")
                    {
                    }
                    column(CompanyInfoBankBranchNo; CompanyBankAccount."Bank Branch No.")
                    {
                    }
                    column(CopyLoopNumber; CopyLoop.Number)
                    {
                    }
                    column(PageText; StrSubstNo(Text005Lbl, ''))
                    {
                    }
                    column(PaymentTermsDescription; PaymentTerms.Description)
                    {
                    }
                    column(ShipmentMethodDescription; ShipmentMethod.Description)
                    {
                    }
                    column(PaymentDiscountText; PaymentDiscountText)
                    {
                    }
                    column(PricesInclVAT_SalesHeader; Format("Sales Header"."Prices Including VAT"))
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
                    column(BlanketSalesOrderNoCaption; BlanketSalesOrderNoCaptionLbl)
                    {
                    }
                    column(UnitPriceCaption; UnitPriceCaptionLbl)
                    {
                    }
                    column(SubtotalCaption; SubtotalCaptionLbl)
                    {
                    }
                    column(AmtCaption; AmtCaptionLbl)
                    {
                    }
                    column(VATDiscountAmtCaption; VATDiscountAmtCaptionLbl)
                    {
                    }
                    column(TotalAmountInclVAT; TotalAmountInclVAT)
                    {
                        AutoFormatExpression = "Sales Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmount; VATAmount)
                    {
                        AutoFormatExpression = "Sales Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(TotalText; TotalText)
                    {
                    }
                    column(TotalInclVATText; TotalInclVATText)
                    {
                    }
                    column(TotalExclVATText; TotalExclVATText)
                    {
                    }
                    column(VATBaseAmount; VATBaseAmount)
                    {
                        AutoFormatExpression = "Sales Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmountLineVATAmount; VATAmountLine.VATAmountText())
                    {
                    }
                    column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
                    {
                    }
                    column(TotalLineAmount; TotalLineAmount)
                    {
                    }
                    column(TotalInvoiceDiscAmount; TotalInvoiceDiscAmount)
                    {
                    }
                    column(VATDiscountAmount; -VATDiscountAmount)
                    {
                        AutoFormatExpression = "Sales Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(BankBranchNoCaption; BankBranchNoCaptionLbl)
                    {
                    }
                    column(EmailCaption; EmailCaptionLbl)
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
                    column(DocumentDateCaption; DocumentDateCaptionLbl)
                    {
                    }
                    column(BillNo_SalesHeaderCaption; "Sales Header".FieldCaption("Bill-to Customer No."))
                    {
                    }
                    column(VATPrice_SalesHeaderCaption; "Sales Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(DimensionLoop1Number; Number)
                        {
                        }
                        column(HdrDimCaption; HdrDimCaptionLbl)
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
                    dataitem("Sales Line"; "Sales Line")
                    {
                        DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = sorting("Document Type", "Document No.", "Line No.");

                        trigger OnPreDataItem()
                        begin
                            CurrReport.Break();
                        end;
                    }
                    dataitem(RoundLoop; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(Type_SalesLine; SalesLine.Type)
                        {
                        }
                        column(LineNo_SalesLine; "Sales Line"."Line No.")
                        {
                        }
                        column(LineAmount_SalesLine; SalesLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Desc_SalesLine; SalesLine.Description)
                        {
                        }
                        column(No_SalesLine; "Sales Line"."No.")
                        {
                        }
                        column(No_SalesLineCaption; "Sales Line".FieldCaption("No."))
                        {
                        }
                        column(Desc1_SalesLine; "Sales Line".Description)
                        {
                        }
                        column(Desc1_SalesLineCaption; "Sales Line".FieldCaption(Description))
                        {
                        }
                        column(Quantity_SalesLine; "Sales Line".Quantity)
                        {
                        }
                        column(Quantity_SalesLineCaption; "Sales Line".FieldCaption(Quantity))
                        {
                        }
                        column(UnitofMeasure_SalesLine; "Sales Line"."Unit of Measure")
                        {
                        }
                        column(UnitofMeasure_SalesLineCaption; "Sales Line".FieldCaption("Unit of Measure"))
                        {
                        }
                        column(LineAmount1_SalesLine; "Sales Line"."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(UnitPrice_SalesLine; "Sales Line"."Unit Price")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 2;
                        }
                        column(ShptDate_SalesLine; Format("Sales Line"."Shipment Date"))
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VAT_SalesLine; "Sales Line"."VAT Identifier")
                        {
                        }
                        column(VATDiscount_SalesHeader; "Sales Header"."VAT Base Discount %")
                        {
                        }
                        column(Discount1_SalesLine; -SalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Discount2_SalesLine; SalesLine."Line Amount" - SalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Discount3_SalesLine; SalesLine."Line Amount" - SalesLine."Inv. Discount Amount" + VATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VAT_SalesLineCaption; "Sales Line".FieldCaption("VAT Identifier"))
                        {
                        }
                        dataitem(DimensionLoop2; "Integer")
                        {
                            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                            column(LineDimCaption; LineDimCaptionLbl)
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

                                DimSetEntry2.SetRange("Dimension Set ID", "Sales Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                SalesLine.Find('-')
                            else
                                SalesLine.Next();
                            "Sales Line" := SalesLine;

                            if not "Sales Header"."Prices Including VAT" and
                               (SalesLine."VAT Calculation Type" = SalesLine."VAT Calculation Type"::"Full VAT")
                            then
                                SalesLine."Line Amount" := 0;

                            if (SalesLine.Type = SalesLine.Type::"G/L Account") and (not ShowInternalInfo) then
                                "Sales Line"."No." := '';

                            TotalInvoiceDiscAmount += SalesLine."Inv. Discount Amount";
                            TotalLineAmount += SalesLine."Line Amount";
                        end;

                        trigger OnPostDataItem()
                        begin
                            SalesLine.DeleteAll();
                        end;

                        trigger OnPreDataItem()
                        begin
                            MoreLines := SalesLine.Find('+');
                            while MoreLines and (SalesLine.Description = '') and (SalesLine."Description 2" = '') and
                                  (SalesLine."No." = '') and (SalesLine.Quantity = 0) and
                                  (SalesLine.Amount = 0)
                            do
                                MoreLines := SalesLine.Next(-1) <> 0;
                            if not MoreLines then
                                CurrReport.Break();
                            SalesLine.SetRange("Line No.", 0, SalesLine."Line No.");
                            SetRange(Number, 1, SalesLine.Count);
                            TotalInvoiceDiscAmount := 0;
                            TotalLineAmount := 0;
                        end;
                    }
                    dataitem("Integer"; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                        dataitem(VATCounter; "Integer")
                        {
                            DataItemTableView = sorting(Number);
                            column(VATAmountLineVATBase; VATAmountLine."VAT Base")
                            {
                                AutoFormatExpression = "Sales Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineVATAmount2; VATAmountLine."VAT Amount")
                            {
                                AutoFormatExpression = "Sales Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineLineAmount; VATAmountLine."Line Amount")
                            {
                                AutoFormatExpression = "Sales Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineBaseAmount; VATAmountLine."Inv. Disc. Base Amount")
                            {
                                AutoFormatExpression = "Sales Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineDiscount; VATAmountLine."Invoice Discount Amount")
                            {
                                AutoFormatExpression = "Sales Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineVAT2; VATAmountLine."VAT %")
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(VATAmountLineVAT3; VATAmountLine."VAT Identifier")
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
                            column(VATAmtSpecCaption; VATAmtSpecCaptionLbl)
                            {
                            }
                            column(VATIdentifierCaption; VATIdentifierCaptionLbl)
                            {
                            }
                            column(LineAmtCaption; LineAmtCaptionLbl)
                            {
                            }
                            column(TotalCaption; TotalCaptionLbl)
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

                        trigger OnPreDataItem()
                        begin
                            if VATAmountLine.Count <= 1 then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(Total; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                    }
                    dataitem(Integer2; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                        dataitem(Total2; "Integer")
                        {
                            DataItemTableView = sorting(Number) where(Number = const(1));
                            column(CustNo_SalesHeader; "Sales Header"."Sell-to Customer No.")
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
                            column(CustNo_SalesHeaderCaption; "Sales Header".FieldCaption("Sell-to Customer No."))
                            {
                            }
                        }

                        trigger OnPreDataItem()
                        begin
                            if not ShowShippingAddr then
                                CurrReport.Break();
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                var
                    SalesPost: Codeunit "Sales-Post";
                begin
                    Clear(SalesLine);
                    Clear(SalesPost);
                    SalesLine.DeleteAll();
                    VATAmountLine.DeleteAll();
                    SalesPost.GetSalesLines("Sales Header", SalesLine, 0);
                    SalesLine.CalcVATAmountLines(0, "Sales Header", SalesLine, VATAmountLine);
                    SalesLine.UpdateVATOnLines(0, "Sales Header", SalesLine, VATAmountLine);
                    VATAmount := VATAmountLine.GetTotalVATAmount();
                    VATBaseAmount := VATAmountLine.GetTotalVATBase();
                    VATDiscountAmount :=
                      VATAmountLine.GetTotalVATDiscount("Sales Header"."Currency Code", "Sales Header"."Prices Including VAT");
                    TotalAmountInclVAT := VATAmountLine.GetTotalAmountInclVAT();

                    if Number > 1 then
                        CopyText := Text003Txt;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then
                        CODEUNIT.Run(CODEUNIT::"Sales-Printed", "Sales Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                end;
            }

            trigger OnAfterGetRecord()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
            begin
                FeatureTelemetry.LogUsage('0000OJI', FeatureNameTok, EventNameTok);
                CurrReport.Language := GlobalLanguage.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := GlobalLanguage.GetFormatRegionOrDefault("Format Region");

                CompanyInfo.Get();

                if not CompanyBankAccount.Get("Sales Header"."Company Bank Account Code") then
                    CompanyBankAccount.CopyBankFieldsFromCompanyInfo(CompanyInfo);

                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInfo);

                DimSetEntry1.SetRange("Dimension Set ID", "Sales Header"."Dimension Set ID");

                if "Salesperson Code" = '' then begin
                    SalesPurchPerson.Init();
                    SalesPersonText := '';
                end else begin
                    SalesPurchPerson.Get("Salesperson Code");
                    SalesPersonText := Text000Txt;
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
                    TotalText := StrSubstNo(Text001Txt, GLSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(Text002Txt, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(Text006Txt, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(Text001Txt, "Currency Code");
                    TotalInclVATText := StrSubstNo(Text002Txt, "Currency Code");
                    TotalExclVATText := StrSubstNo(Text006Txt, "Currency Code");
                end;
                FormatAddr.SalesHeaderBillTo(CustAddr, "Sales Header");

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
                        Text1041000Txt,
                        "Payment Discount %", "VAT Base Discount %");

                ShowShippingAddr := FormatAddr.SalesHeaderShipTo(ShipToAddr, CustAddr, "Sales Header");

                if LogInteraction then
                    if not CurrReport.Preview then
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              2, "No.", 0, 0, DATABASE::Contact, "Bill-to Contact No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", "Opportunity No.")
                        else
                            SegManagement.LogDocument(
                              2, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", "Opportunity No.");
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
                        ToolTip = 'Specifies if you want the printed report to show information that is only for internal use';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to log this interaction.';
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
            LogInteraction := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Sales Blnkt. Ord") <> '';
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get();
        Salessetup.Get();
        case Salessetup."Logo Position on Documents" of
            Salessetup."Logo Position on Documents"::"No Logo":
                ;
            Salessetup."Logo Position on Documents"::Left:
                begin
                    CompanyInfo1.Get();
                    CompanyInfo1.CalcFields(Picture);
                end;
            Salessetup."Logo Position on Documents"::Center:
                begin
                    CompanyInfo2.Get();
                    CompanyInfo2.CalcFields(Picture);
                end;
            Salessetup."Logo Position on Documents"::Right:
                begin
                    CompanyInfo3.Get();
                    CompanyInfo3.CalcFields(Picture);
                end;
        end;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyBankAccount: Record "Bank Account";
        CompanyInfo: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        Salessetup: Record "Sales & Receivables Setup";
        VATAmountLine: Record "VAT Amount Line" temporary;
        SalesLine: Record "Sales Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        GlobalLanguage: Codeunit Language;
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        SalesPersonText: Text;
        VATNoText: Text;
        ReferenceText: Text;
        TotalText: Text;
        TotalExclVATText: Text;
        TotalInclVATText: Text;
        PaymentDiscountText: Text;
        MoreLines: Boolean;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text;
        ShowShippingAddr: Boolean;
        DimText: Text;
        OldDimText: Text;
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        VATAmount: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        Text1041000Txt: Label '%1 %, VAT discounted at %2 % ';
        Text000Txt: Label 'Salesperson';
        Text001Txt: Label 'Total %1';
        Text002Txt: Label 'Total %1 Incl. VAT';
        Text003Txt: Label 'COPY';
        Text004Lbl: Label 'Blanket Sales Order %1';
        Text005Lbl: Label 'Page %1';
        Text006Txt: Label 'Total %1 Excl. VAT';
        TotalInvoiceDiscAmount: Decimal;
        TotalLineAmount: Decimal;
        LogInteraction: Boolean;
        LogInteractionEnable: Boolean;
        PhoneNoCaptionLbl: Label 'Phone No.';
        HomePageCaptionLbl: Label 'Home Page';
        VATRegNoCaptionLbl: Label 'VAT Registration No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccNoCaptionLbl: Label 'Account No.';
        BlanketSalesOrderNoCaptionLbl: Label 'Blanket Sales Order No.';
        UnitPriceCaptionLbl: Label 'Unit Price';
        SubtotalCaptionLbl: Label 'Subtotal';
        AmtCaptionLbl: Label 'Amount';
        VATDiscountAmtCaptionLbl: Label 'Payment Discount on VAT';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        BankBranchNoCaptionLbl: Label 'Bank Branch No.';
        EmailCaptionLbl: Label 'E-Mail';
        PaymentTermsCaptionLbl: Label 'Payment Terms';
        ShipmentMethodCaptionLbl: Label 'Shipment Method';
        PaymentDiscountCaptionLbl: Label 'Payment Discount';
        DocumentDateCaptionLbl: Label 'Document Date';
        HdrDimCaptionLbl: Label 'Header Dimensions';
        LineDimCaptionLbl: Label 'Line Dimensions';
        VATPercentageCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmtCaptionLbl: Label 'VAT Amount';
        VATAmtSpecCaptionLbl: Label 'VAT Amount Specification';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        LineAmtCaptionLbl: Label 'Line Amount';
        TotalCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        InvDiscountAmtCaptionLbl: Label 'Invoice Discount Amount';
        ShipmentDateCaptionLbl: Label 'Shipment Date';
        FeatureNameTok: Label 'Blanket Sales Order GB', Locked = true;
        EventNameTok: Label 'Blanket Sales Order GB report has been used', Locked = true;
}

