// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.CRM.Team;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Vendor;
using System.Globalization;
using System.Utilities;

report 18001 "Archived Purchase Quote GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/ArchivedPurchaseQuote.rdl';
    Caption = 'Archived Purchase Quote';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Purchase Header Archive"; "Purchase Header Archive")
        {
            DataItemTableView = sorting("Document Type", "No.")
                                where("Document Type" = const(Quote));
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Archived Purchase Quote';

            column(Purchase_Header_Archive_Document_Type; "Document Type")
            {
            }
            column(Purchase_Header_Archive_No_; "No.")
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

                    column(STRSUBSTNO_Text002_CopyText_; StrSubstNo(PurchQuoteArchLbl, CopyText))
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
                    column(VendAddr_1_; VendAddr[1])
                    {
                    }
                    column(CompanyAddr_1_; CompanyAddr[1])
                    {
                    }
                    column(VendAddr_2_; VendAddr[2])
                    {
                    }
                    column(CompanyAddr_2_; CompanyAddr[2])
                    {
                    }
                    column(VendAddr_3_; VendAddr[3])
                    {
                    }
                    column(CompanyAddr_3_; CompanyAddr[3])
                    {
                    }
                    column(VendAddr_4_; VendAddr[4])
                    {
                    }
                    column(CompanyAddr_4_; CompanyAddr[4])
                    {
                    }
                    column(VendAddr_5_; VendAddr[5])
                    {
                    }
                    column(CompanyInfo__Phone_No__; CompanyInformation."Phone No.")
                    {
                    }
                    column(VendAddr_6_; VendAddr[6])
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
                    column(Purchase_Header_Archive___Pay_to_Vendor_No__; "Purchase Header Archive"."Pay-to Vendor No.")
                    {
                    }
                    column(FORMAT__Purchase_Header_Archive___Document_Date__0_4_; FORMAT("Purchase Header Archive"."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(Purchase_Header_Archive___VAT_Registration_No__; "Purchase Header Archive"."VAT Registration No.")
                    {
                    }
                    column(Purchase_Header_Archive___Expected_Receipt_Date_; FORMAT("Purchase Header Archive"."Expected Receipt Date"))
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
                    column(VendAddr_7_; VendAddr[7])
                    {
                    }
                    column(VendAddr_8_; VendAddr[8])
                    {
                    }
                    column(CompanyAddr_5_; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr_6_; CompanyAddr[6])
                    {
                    }
                    column(STRSUBSTNO_Text004__Purchase_Header_Archive___Version_No____Purchase_Header_Archive___No__of_Archived_Versions__; StrSubstNo(VersionLbl, "Purchase Header Archive"."Version No.", "Purchase Header Archive"."No. of Archived Versions"))
                    {
                    }
                    column(OutpuNo; OutputNo)
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
                    column(Purchase_Header_Archive___Pay_to_Vendor_No__Caption; "Purchase Header Archive".FieldCaption("Pay-to Vendor No."))
                    {
                    }
                    column(Expected_DateCaption; Expected_DateCaptionLbl)
                    {
                    }
                    column(Quote_No_Caption; Quote_No_CaptionLbl)
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
                            if not ShowInterInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Purchase Line Archive"; "Purchase Line Archive")
                    {
                        DataItemLink = "Document Type" = field("Document Type"),
                                       "Document No." = field("No.");
                        DataItemLinkReference = "Purchase Header Archive";
                        DataItemTableView = sorting("Document Type", "Document No.", "Line No.");


                        trigger OnPreDataItem()
                        begin
                            CurrReport.Break();
                        end;
                    }
                    dataitem(RoundLoop; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(ShowInternalInfo; ShowInterInfo)
                        {
                        }
                        column(PurchaseLineType; PurchaseLineArchiveType)
                        {
                        }
                        column(Purchase_Line_Archive__Description; "Purchase Line Archive".Description)
                        {
                        }
                        column(Purchase_Line_Archive___No__; "Purchase Line Archive"."No.")
                        {
                        }
                        column(Purchase_Line_Archive__Quantity; "Purchase Line Archive".Quantity)
                        {
                        }
                        column(Purchase_Line_Archive___Unit_of_Measure_; "Purchase Line Archive"."Unit of Measure")
                        {
                        }
                        column(Purchase_Line_Archive___Expected_Receipt_Date_; FORMAT("Purchase Line Archive"."Expected Receipt Date"))
                        {
                        }
                        column(Purchase_Line_Archive___Expected_Receipt_Date__Control55; FORMAT("Purchase Line Archive"."Expected Receipt Date"))
                        {
                        }
                        column(Purchase_Line_Archive___Unit_of_Measure__Control54; "Purchase Line Archive"."Unit of Measure")
                        {
                        }
                        column(Purchase_Line_Archive__Quantity_Control53; "Purchase Line Archive".Quantity)
                        {
                        }
                        column(Purchase_Line_Archive__Description_Control52; "Purchase Line Archive".Description)
                        {
                        }
                        column(Purchase_Line_Archive___No__1; "Purchase Line Archive"."No.")
                        {
                        }
                        column(Purchase_Line_Archive___Vendor_Item_No__; "Purchase Line Archive"."Vendor Item No.")
                        {
                        }
                        column(Purchase_Line_Archive___Expected_Receipt_Date__Control55Caption; Purchase_Line_Archive___Expected_Receipt_Date__Control55CaptionLbl)
                        {
                        }
                        column(Purchase_Line_Archive___Unit_of_Measure__Control54Caption; "Purchase Line Archive".FieldCaption("Unit of Measure"))
                        {
                        }
                        column(Purchase_Line_Archive__Quantity_Control53Caption; "Purchase Line Archive".FieldCaption(Quantity))
                        {
                        }
                        column(Purchase_Line_Archive__Description_Control52Caption; "Purchase Line Archive".FieldCaption(Description))
                        {
                        }
                        column(Purchase_Line_Archive___No__Caption; Purchase_Line_Archive___No__CaptionLbl)
                        {
                        }
                        column(Purchase_Line_Archive___Vendor_Item_No__Caption; Purchase_Line_Archive___Vendor_Item_No__CaptionLbl)
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText_Control60; DimText)
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
                                if not ShowInterInfo then
                                    CurrReport.Break();
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                TempPurchLineArchive.Find('-')
                            else
                                TempPurchLineArchive.Next();
                            "Purchase Line Archive" := TempPurchLineArchive;

                            DimSetEntry2.SetRange("Dimension Set ID", "Purchase Line Archive"."Dimension Set ID");

                        end;

                        trigger OnPostDataItem()
                        begin
                            TempPurchLineArchive.DeleteAll();
                        end;

                        trigger OnPreDataItem()
                        begin
                            MoreLines := TempPurchLineArchive.Find('+');
                            while MoreLines and
                                (TempPurchLineArchive.Description = '') and
                                (TempPurchLineArchive."Description 2" = '') and
                                (TempPurchLineArchive."No." = '') and
                                (TempPurchLineArchive.Quantity = 0) and
                                (TempPurchLineArchive.Amount = 0)
                            do
                                MoreLines := TempPurchLineArchive.Next(-1) <> 0;

                            if not MoreLines then
                                CurrReport.Break();

                            TempPurchLineArchive.SetRange("Line No.", 0, TempPurchLineArchive."Line No.");
                            SetRange(Number, 1, TempPurchLineArchive.Count);
                        end;
                    }
                    dataitem(Total; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = const(1));

                        column(ShipmentMethod_Description; ShipmentMethod.Description)
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

                        column(Purchase_Header_Archive___Buy_from_Vendor_No__; "Purchase Header Archive"."Buy-from Vendor No.")
                        {
                        }
                        column(Purchase_Header_Archive___Buy_from_Vendor_No__Caption; "Purchase Header Archive".FieldCaption("Buy-from Vendor No."))
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
                        column(Ship_to_AddressCaption; Ship_to_AddressCaptionLbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if ("Purchase Header Archive"."Sell-to Customer No." = '') and (ShipToAddr[1] = '') then
                                CurrReport.Break();
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                var
                    PurchLineArchive2: Record "Purchase Line Archive";
                begin
                    Clear(TempPurchLineArchive);
                    TempPurchLineArchive.DeleteAll();
                    PurchLineArchive2.SetRange("Document Type", "Purchase Header Archive"."Document Type");
                    PurchLineArchive2.SetRange("Document No.", "Purchase Header Archive"."No.");
                    PurchLineArchive2.SetRange("Version No.", "Purchase Header Archive"."Version No.");
                    if PurchLineArchive2.FindSet() then
                        repeat
                            TempPurchLineArchive := PurchLineArchive2;
                            TempPurchLineArchive.Insert();
                        until PurchLineArchive2.Next() = 0;

                    if Number > 1 then begin
                        CopyText := CopyLbl;
                        OutputNo += 1;
                    end;
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
                    OutputNo := 1;
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

                FormatAddr.PurchHeaderPayToArch(VendAddr, "Purchase Header Archive");

                if "Shipment Method Code" = '' then
                    ShipmentMethod.Init()
                else begin
                    ShipmentMethod.Get("Shipment Method Code");
                    ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                end;

                CalcFields("No. of Archived Versions");
                FormatAddr.PurchHeaderShipToArch(ShipToAddr, "Purchase Header Archive");
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
                    field(ShowInternalInfo; ShowInterInfo)
                    {
                        Caption = 'Show Internal Information';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the line internal information.';
                    }
                }
            }
        }
    }

    var
        ShipmentMethod: Record "Shipment Method";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        Vendor: Record "Vendor";
        CompanyInformation: Record "Company Information";
        TempPurchLineArchive: Record "Purchase Line Archive" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        Language: Codeunit "Language";
        FormatAddr: Codeunit "Format Address";
        PurchCountPrintedArch: Codeunit "Purch.HeaderArch-Printed";
        VendAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        PurchaserText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        MoreLines: Boolean;
        NoOfCopy: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        DimText: Text[120];
        ShowInterInfo: Boolean;
        Continue: Boolean;
        OutputNo: Integer;
        PurchaseLineArchiveType: Integer;
        VersionLbl: Label 'Version %1 of %2 ', Comment = ' %1 = Version No. , %2 = No. of Archived Versions';
        CompanyInfo__Phone_No__CaptionLbl: Label 'Phone No.', Locked = true;
        CompanyInfo__Fax_No__CaptionLbl: Label 'Fax No.', Locked = true;
        CompanyInfo__VAT_Registration_No__CaptionLbl: Label 'VAT Reg. No.', Locked = true;
        CompanyInfo__Giro_No__CaptionLbl: Label 'Giro No.', Locked = true;
        CompanyInfo__Bank_Name_CaptionLbl: Label 'Bank', Locked = true;
        CompanyInfo__Bank_Account_No__CaptionLbl: Label 'Account No.', Locked = true;
        Expected_DateCaptionLbl: Label 'Expected Date', Locked = true;
        Quote_No_CaptionLbl: Label 'Quote No.', Locked = true;
        Header_DimensionsCaptionLbl: Label 'Header Dimensions', Locked = true;
        Purchase_Line_Archive___Expected_Receipt_Date__Control55CaptionLbl: Label 'Expected Date', Locked = true;
        Purchase_Line_Archive___No__CaptionLbl: Label 'Item No.', Locked = true;
        Purchase_Line_Archive___Vendor_Item_No__CaptionLbl: Label 'Vendor Item No', Locked = true;
        Line_DimensionsCaptionLbl: Label 'Line Dimensions';
        ShipmentMethod_DescriptionCaptionLbl: Label 'Shipment Method', Locked = true;
        Ship_to_AddressCaptionLbl: Label 'Ship-to Address', Locked = true;
        CompanyRegistrationLbl: Label 'Company Registration No.', Locked = true;
        VendorRegistrationLbl: Label 'Vendor GST Reg No.', Locked = true;
        PurchLbl: Label 'Purchaser', Locked = true;
        CopyLbl: Label 'COPY', Locked = true;
        PurchQuoteArchLbl: Label 'Purchase - Quote Archived %1', Locked = true;

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
