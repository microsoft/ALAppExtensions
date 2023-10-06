// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;
using System.Globalization;
using System.Utilities;

report 18012 "Purchase - Quote GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/PurchaseQuote.rdl';
    Caption = 'Purchase - Quote';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = sorting("Document Type", "No.")
                                where("Document Type" = const(Quote));
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Purchase Quote';

            column(DocType_PurchHead; "Document Type")
            {
            }
            column(PurchHeadNo; "No.")
            {
            }
            column(CompanyInfoPhoneNoCap; CompanyInfoPhoneNoCapLbl)
            {
            }
            column(CompanyInfoVATRegNoCap; CompanyInfoVATRegNoCapLbl)
            {
            }
            column(CompanyInfoGiroNoCap; CompanyInfoGiroNoCapLbl)
            {
            }
            column(CompanyInfoBankNameCap; CompanyInfoBankNameCapLbl)
            {
            }
            column(CompInfoBankAccNoCap; CompInfoBankAccNoCapLbl)
            {
            }
            column(DocumentDateCap; DocumentDateCapLbl)
            {
            }
            column(PageNoCaption; PageNoCaptionLbl)
            {
            }
            column(ShipmentMethodDescCap; ShipmentMethodDescCapLbl)
            {
            }
            column(PurchLineVendItemNoCap; PurchLineVendItemNoCapLbl)
            {
            }
            column(PurchaseLineDescCap; PurchaseLineDescCapLbl)
            {
            }
            column(PurchaseLineQuantityCap; PurchaseLineQuantityCapLbl)
            {
            }
            column(PurchaseLineUOMCaption; PurchaseLineUOMCaptionLbl)
            {
            }
            column(PurchaseLineNoCaption; PurchaseLineNoCaptionLbl)
            {
            }
            column(PurchaserTextCaption; PurchaserTextCaptionLbl)
            {
            }
            column(ReferenceTextCaption; ReferenceTextCaptionLbl)
            {
            }
            column(HomePageCaption; HomePageCaptionLbl)
            {
            }
            column(EMailCaption; EMailCaptionLbl)
            {
            }
            column(VatRegistrationNoCaption; VatRegistrationNoCaptionLbl)
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
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
                    column(PurchaseQuoteCopyText; StrSubstNo(PurchQuoteLbl, CopyText))
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
                        IncludeCaption = false;
                    }
                    column(VendAddr6; VendAddr[6])
                    {
                    }
                    column(CompanyInfoVatRegNo; CompanyInfo."VAT Registration No.")
                    {
                        IncludeCaption = false;
                    }
                    column(CompanyInfoGiroNo; CompanyInfo."Giro No.")
                    {
                        IncludeCaption = false;
                    }
                    column(CompanyInfoBankName; CompanyInfo."Bank Name")
                    {
                        IncludeCaption = false;
                    }
                    column(CompanyInfoBankAccNo; CompanyInfo."Bank Account No.")
                    {
                        IncludeCaption = false;
                    }
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoEMail; CompanyInfo."E-Mail")
                    {
                    }
                    column(PaytoVendNo_PurchHdr; "Purchase Header"."Pay-to Vendor No.")
                    {
                    }
                    column(DocDate_PurchHdr; Format("Purchase Header"."Document Date", 0, 4))
                    {
                    }
                    column(VatNoText; VATNoText)
                    {
                    }
                    column(VatTRegNo_PurchHdr; "Purchase Header"."VAT Registration No.")
                    {
                    }
                    column(ExpctRecpDt_PurchHdr; Format("Purchase Header"."Expected Receipt Date"))
                    {
                    }
                    column(PurchaserText; PurchaserText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(No1_PurchaseHdr; "Purchase Header"."No.")
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourRef_PurchHdr; "Purchase Header"."Your Reference")
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
                    column(ShipMethodDesc; ShipmentMethod.Description)
                    {
                    }
                    column(OutpuNo; OutputNo)
                    {
                    }
                    column(BuyfromVendNo_PurchHdr; "Purchase Header"."Buy-from Vendor No.")
                    {
                    }
                    column(ExpectedDateCaption; ExpectedDateCaptionLbl)
                    {
                    }
                    column(QuoteNoCaption; QuoteNoCaptionLbl)
                    {
                    }
                    column(PaytoVendNo_PurchHdrCaption; "Purchase Header".FieldCaption("Pay-to Vendor No."))
                    {
                    }
                    column(BuyfromVendNo_PurchHdrCaption; "Purchase Header".FieldCaption("Buy-from Vendor No."))
                    {
                    }
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Purchase Header";
                        DataItemTableView = sorting(Number)
                                            where(Number = filter(1 ..));

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
                            DimText := GetDimensionText(DimSetEntry1, Number, Continue);
                            if not Continue then
                                CurrReport.Break();
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowIntInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Purchase Line"; "Purchase Line")
                    {
                        DataItemLink = "Document Type" = field("Document Type"),
                                       "Document No." = field("No.");
                        DataItemLinkReference = "Purchase Header";
                        DataItemTableView = sorting("Document Type", "Document No.", "Line No.");


                        trigger OnPreDataItem()
                        begin
                            CurrReport.Break();
                        end;
                    }
                    dataitem(RoundLoop; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(ShowInternalInfo; ShowIntInfo)
                        {
                        }
                        column(ArchiveDocument; ArchiveDoc)
                        {
                        }
                        column(LogInteraction; LogInterLbl)
                        {
                        }
                        column(Type_PurchaseLine; Format("Purchase Line".Type, 0, 2))
                        {
                            IncludeCaption = false;
                        }
                        column(LineNo_PurchaseLine; "Purchase Line"."Line No.")
                        {
                            IncludeCaption = false;
                        }
                        column(Description_PurchaseLine; "Purchase Line".Description)
                        {
                            IncludeCaption = false;
                        }
                        column(Quantity_PurchaseLine; "Purchase Line".Quantity)
                        {
                            IncludeCaption = false;
                        }
                        column(UnitOfMeasure_PurchaseLine; "Purchase Line"."Unit of Measure")
                        {
                            IncludeCaption = false;
                        }
                        column(ExpcRecpDt_PurchHdr; Format("Purchase Line"."Expected Receipt Date"))
                        {
                            IncludeCaption = false;
                        }
                        column(No_PurchaseLine; "Purchase Line"."No.")
                        {
                        }
                        column(VendItemNo_PurchLine; "Purchase Line"."Vendor Item No.")
                        {
                            IncludeCaption = false;
                        }
                        column(PurchaseLineNoOurNoCap; PurchaseLineNoOurNoCapLbl)
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText1; DimText)
                            {
                            }
                            column(Number2_DimensionLoop; Number)
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
                                if not ShowIntInfo then
                                    CurrReport.Break();
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            TaxTrnasactionValue: Record "Tax Transaction Value";
                            TaxTrnasactionValue1: Record "Tax Transaction Value";
                        begin
                            if Number = 1 then
                                TempPurchLine.FindFirst()
                            else
                                TempPurchLine.Next();
                            "Purchase Line" := TempPurchLine;

                            DimSetEntry2.SetRange("Dimension Set ID", "Purchase Line"."Dimension Set ID");
                            if IsGSTApplicable then begin
                                j := 1;
                                TaxTrnasactionValue.Reset();
                                TaxTrnasactionValue.SetRange("Tax Record ID", TempPurchLine.RecordId);
                                TaxTrnasactionValue.SetRange("Tax Type", 'GST');
                                TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                                TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                                if TaxTrnasactionValue.FindSet() then
                                    repeat
                                        GSTComponentCode[j] := TaxTrnasactionValue."Value ID";
                                        TaxTrnasactionValue1.Reset();
                                        TaxTrnasactionValue1.SetRange("Tax Record ID", TempPurchLine.RecordId);
                                        TaxTrnasactionValue1.SetRange("Tax Type", 'GST');
                                        TaxTrnasactionValue1.SetRange("Value Type", TaxTrnasactionValue1."Value Type"::COMPONENT);
                                        TaxTrnasactionValue1.SetRange("Value ID", GSTComponentCode[j]);
                                        if TaxTrnasactionValue1.FindSet() then
                                            repeat
                                                GSTCompAmount[j] += TaxTrnasactionValue1.Amount;
                                            until TaxTrnasactionValue1.Next() = 0;
                                        j += 1;
                                    until TaxTrnasactionValue.Next() = 0;
                            end;

                            TaxTrnasactionValue.Reset();
                            TaxTrnasactionValue.SetRange("Tax Record ID", TempPurchLine.RecordId);
                            TaxTrnasactionValue.SetRange("Tax Type", 'GST');
                            TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                            TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                            if TaxTrnasactionValue.FindSet() then
                                repeat
                                    j := 1;
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

                        end;

                        trigger OnPostDataItem()
                        begin
                            TempPurchLine.DeleteAll();
                        end;

                        trigger OnPreDataItem()
                        begin
                            MoreLines := TempPurchLine.FindLast();
                            while MoreLines and (TempPurchLine.Description = '') and (TempPurchLine."Description 2" = '') and
                                  (TempPurchLine."No." = '') and (TempPurchLine.Quantity = 0) and
                                  (TempPurchLine.Amount = 0)
                            do
                                MoreLines := TempPurchLine.Next(-1) <> 0;
                            if not MoreLines then
                                CurrReport.Break();
                            TempPurchLine.SetRange("Line No.", 0, TempPurchLine."Line No.");
                            SetRange(Number, 1, TempPurchLine.Count);
                        end;
                    }
                    dataitem(Total3; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

                        column(SelltoCustNo_PurchHdr; "Purchase Header"."Sell-to Customer No.")
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

                        trigger OnPreDataItem()
                        begin
                            if ("Purchase Header"."Sell-to Customer No." = '') and (ShipToAddr[1] = '') then
                                CurrReport.Break();
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(TempPurchLine);
                    Clear(PurchPost);
                    TempPurchLine.DeleteAll();
                    PurchPost.GetPurchLines("Purchase Header", TempPurchLine, 0);

                    if Number > 1 then begin
                        CopyText := CopyLbl;
                        OutputNo += 1;
                    end;
                end;

                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then
                        PurchCountPrinted.Run("Purchase Header");
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
            begin
                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := Language.GetFormatRegionOrDefault("Format Region");

                CompanyInfo.Get();
                IsGSTApplicable := CheckGSTDoc("Purchase Line");

                Vendor.Get("Buy-from Vendor No.");
                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInfo);

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

                FormatAddr.PurchHeaderPayTo(VendAddr, "Purchase Header");

                if "Shipment Method Code" = '' then
                    ShipmentMethod.Init()
                else begin
                    ShipmentMethod.Get("Shipment Method Code");
                    ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                end;

                FormatAddr.PurchHeaderShipTo(ShipToAddr, "Purchase Header");

                if not CurrReport.Preview then begin
                    if ArchiveDoc then
                        ArchiveManagement.StorePurchDocument("Purchase Header", ArchiveDoc);

                    if LogInterLbl then begin
                        CalcFields("No. of Archived Versions");
                        SegManagement.LogDocument(
                          11, "No.", "Doc. No. Occurrence", "No. of Archived Versions", Database::Vendor, "Pay-to Vendor No.",
                          "Purchaser Code", '', "Posting Description", '');
                    end;
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
                    field(NoOfCopies; NoOfCopy)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of copies that need to be printed.';
                    }
                    field(ShowInternalInfo; ShowIntInfo)
                    {
                        Caption = 'Show Internal Information';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the line internal information.';
                    }
                    field(ArchiveDocument; ArchiveDoc)
                    {
                        Caption = 'Archive Document';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether the document is archived or not.';

                        trigger OnValidate()
                        begin
                            if not ArchiveDoc then
                                LogInterLbl := false;
                        end;
                    }
                    field(LogInteraction; LogInterLbl)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the log Interaction for archived document to be done or not.';

                        trigger OnValidate()
                        begin
                            if LogInterLbl then
                                ArchiveDoc := ArchiveDocumentEnable;
                        end;
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
            ArchiveDocumentEnable := false;
        end;

        trigger OnOpenPage()
        begin
            LogInterLbl := SegManagement.FindInteractionTemplateCode(11) <> '';
            LogInteractionEnable := LogInterLbl;
        end;
    }

    labels
    {
    }


    trigger OnInitReport()
    begin
        PurchSetup.Get();
    end;

    var
        ShipmentMethod: Record "Shipment Method";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInfo: Record "Company Information";
        TempPurchLine: Record "Purchase Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        PurchSetup: Record "Purchases & Payables Setup";
        Vendor: Record Vendor;
        Language: Codeunit Language;
        PurchCountPrinted: Codeunit "Purch.Header-Printed";
        FormatAddr: Codeunit "Format Address";
        PurchPost: Codeunit "Purch.-Post";
        SegManagement: Codeunit SegManagement;
        ArchiveManagement: Codeunit ArchiveManagement;
        VendAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        GSTComponentCodeName: array[10] of Code[20];
        PurchaserText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        MoreLines: Boolean;
        NoOfCopy: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        DimText: Text[120];
        ShowIntInfo: Boolean;
        Continue: Boolean;
        ArchiveDoc: Boolean;
        LogInterLbl: Boolean;
        OutputNo: Integer;
        [InDataSet]
        ArchiveDocumentEnable: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        GSTCompAmount: array[20] of Decimal;
        GSTComponentCode: array[20] of Integer;
        IsGSTApplicable: Boolean;
        j: Integer;
        PurchLbl: Label 'Purchaser';
        CopyLbl: Label 'COPY';
        PurchQuoteLbl: Label 'Purchase - Quote %1', Comment = '%1 Purchase Quote';
        ExpectedDateCaptionLbl: Label 'Expected Date';
        QuoteNoCaptionLbl: Label 'Quote No.';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        PurchaseLineNoOurNoCapLbl: Label 'Our No.';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        CompanyInfoPhoneNoCapLbl: Label 'Phone No.';
        CompanyInfoVATRegNoCapLbl: Label 'VAT Reg. No.';
        CompanyInfoGiroNoCapLbl: Label 'Giro No.';
        CompanyInfoBankNameCapLbl: Label 'Bank';
        CompInfoBankAccNoCapLbl: Label 'Account No.';
        DocumentDateCapLbl: Label 'Document Date';
        PageNoCaptionLbl: Label 'Page';
        ShipmentMethodDescCapLbl: Label 'Shipment Method';
        PurchLineVendItemNoCapLbl: Label 'Vendor Item No.';
        PurchaseLineDescCapLbl: Label 'Description';
        PurchaseLineQuantityCapLbl: Label 'Quantity';
        PurchaseLineUOMCaptionLbl: Label 'Unit of Measure';
        PurchaseLineNoCaptionLbl: Label 'Item No.';
        PurchaserTextCaptionLbl: Label 'Purchaser';
        ReferenceTextCaptionLbl: Label 'Your Reference';
        HomePageCaptionLbl: Label 'Home Page';
        EMailCaptionLbl: Label 'E-Mail';
        VatRegistrationNoCaptionLbl: Label 'VAT Registration No.';
        CompanyRegistrationLbl: Label 'Company Registration No.';
        VendorRegistrationLbl: Label 'Vendor GST Reg No.';

    procedure IntializeRequest(
        NewNoOfCopies: Integer;
        NewShowInternalInfo: Boolean;
        NewArchiveDocument: Boolean;
        NewLogInteraction: Boolean)
    begin
        NoOfCopy := NewNoOfCopies;
        ShowIntInfo := NewShowInternalInfo;
        ArchiveDoc := NewArchiveDocument;
        LogInterLbl := NewLogInteraction;
    end;

    local procedure CheckGSTDoc(PurchLine: Record "Purchase Line"): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", PurchLine.RecordId);
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
}
