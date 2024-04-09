// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.IO;
using System.Utilities;

report 18049 "GSTR-1 File Format"
{
    Caption = 'GSTR-1 File Format';
    ProcessingOnly = true;
    UseRequestPage = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = const(1));

            trigger OnAfterGetRecord()
            begin
                case NatureofSupply of
                    NatureofSupply::" ":
                        ERRor(FileFormatErr);
                    NatureofSupply::B2B:
                        begin
                            MakeExcelBodyB2B();
                            CreateandOpenExcel(B2BTxt);
                        end;
                    NatureofSupply::B2CL:
                        begin
                            MakeExcelBodyB2CL();
                            CreateandOpenExcel(B2CLTxt);
                        end;
                    NatureofSupply::B2CS:
                        begin
                            MakeExcelBodyB2CS();
                            CreateandOpenExcel(B2CSTxt);
                        end;
                    NatureofSupply::AT:
                        begin
                            MakeExcelBodyAT();
                            CreateandOpenExcel(ATTxt);
                        end;
                    NatureofSupply::ATADJ:
                        begin
                            MakeExcelBodyATADJ();
                            CreateandOpenExcel(ATADJTxt);
                        end;
                    NatureofSupply::CDNR:
                        begin
                            MakeExcelBodyCDNR();
                            CreateandOpenExcel(CDNRTxt);
                        end;
                    NatureofSupply::CDNUR:
                        begin
                            MakeExcelBodyCDNUR();
                            CreateandOpenExcel(CDNURTxt);
                        end;
                    NatureofSupply::EXP:
                        begin
                            MakeExcelBodyEXP();
                            CreateandOpenExcel(EXPTxt);
                        end;
                    NatureofSupply::HSN:
                        begin
                            MakeExcelBodyHSN();
                            CreateandOpenExcel(HSNTxt);
                        end;
                    NatureofSupply::EXEMP:
                        begin
                            MakeExcelBodyEXEMP();
                            CreateandOpenExcel(EXEMPTxt);
                        end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                TempExcelBuffer.DeleteAll();
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
                    field(GSTIN; LocationGSTIN)
                    {
                        Caption = 'GSTin of the location';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the GST registration number for which the report will be generated.';
                        TableRelation = "GST Registration Nos.".Code;
                    }
                    field(Date; ReturnDate)
                    {
                        Caption = 'Date';
                        ToolTip = 'Specifies the date that you want the period of the Return.';
                        ApplicationArea = Basic, Suite;

                        trigger OnValidate()
                        begin
                            StartDate := CalcDate('<-CM>', ReturnDate);
                            EndDate := CalcDate('<+CM>', ReturnDate);
                        end;
                    }
                    field(FileFormat; NatureofSupply)
                    {
                        Caption = 'File Format';
                        ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                        ApplicationArea = Basic, Suite;

                        trigger OnValidate()
                        begin
                            case NatureofSupply of
                                NatureofSupply::B2CL:
                                    B2CLimit := 250000;
                                NatureofSupply::B2CS:
                                    B2CLimit := 250000;
                                else
                                    B2CLimit := 0.00
                            end;
                        end;
                    }
                    field(B2CLimit; B2CLimit)
                    {
                        Caption = 'B2C Limit';
                        ToolTip = 'Specifies the Invoice Value for B2CL or B2CS. For example , 250000.';
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if not GuiAllowed then
            exit;

        Progress.Open(ProgressMsg);
    end;

    trigger OnPostReport()
    begin
        Counter += 1;
        Progress.Update(1, Counter);
        Sleep(50);

        Progress.Close();
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        LocationGSTIN: Code[15];
        ReturnDate: Date;
        StartDate: Date;
        B2CLimit: Decimal;
        EndDate: Date;
        Counter: Integer;
        Progress: Dialog;
        ProgressMsg: Label 'Processing......#1######################\';
        B2BTxt: Label 'b2b';
        B2CLTxt: Label 'b2cl';
        ELbl: Label 'E';
        B2CSTxt: Label 'b2cs';
        WOPAYTxt: Label 'wopay';
        WPAYTxt: Label 'wpay';
        OtherECommTxt: Label 'oe';
        TypeTxt: Label 'Type';
        CDNURTxt: Label 'cdnur';
        YLbl: Label 'Y';
        NLbl: Label 'N';
        CLbl: Label 'C';
        DLbl: Label 'D';
        RLbl: Label 'R';
        ATTxt: Label 'at';
        CDNRTxt: Label 'cdnr';
        ATADJTxt: Label 'atadj';
        HSNTxt: Label 'hsn';
        EXPTxt: Label 'exp';
        IGSTLbl: Label 'IGST';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        CessLbl: Label 'CESS';
        NonGSTxt: Label 'Non-GST Supplies';
        DespTxt: Label 'Desciption';
        NilTxt: Label 'Nil Rated Supplies';
        InterRegTxt: Label 'Inter-State supplies to registered persons';
        IntraRegTxt: Label 'Intra-State supplies to registered persons';
        InterUnRegTxt: Label 'Inter-State supplies to unregistered persons';
        IntraUnRegTxt: Label 'Intra-State supplies to unregistered persons';
        ExmpTxt: Label 'Exempted(other than nil rated/non GST supply)';
        EXEMPTxt: Label 'exemp';
        DescTxt: Label 'Desciption Text';
        UQCTxt: Label 'uqc';
        HSNSACofSupplyTxt: Label 'HSN/SAC of Supply';
        SEZWPayTxt: Label 'SEZ With Pay';
        IGSTAmountTxt: Label 'IGST Amount';
        CGSTAmountTxt: Label 'CGST Amount';
        SGSTAmountTxt: Label 'SGST Amount';
        TotalQtyTxt: Label 'Total Quantity';
        TotalValTxt: Label 'Total Value';
        GSTINUINTxt: Label 'GSTIN/Uin of Recipient';
        InvoiceNoTxt: Label 'Invoice Number';
        URTypeTxt: Label 'UR Type';
        RegularTxt: Label 'Regular';
        EXPWOPayTxt: Label 'expwop';
        EXPWPayTxt: Label 'expwp';
        DeemedExportTxt: Label 'Deemed Export';
        ExportTypeTxt: Label 'Export Type';
        PortCodeTxt: Label 'Port Code';
        ShipBillNoTxt: Label 'Shipping Bill Number';
        ShipBillDateTxt: Label 'Shipping Bill Date';
        DocumentTypeTxt: Label 'Document Type';
        PreGSTTxt: Label 'Pre GST';
        RefundVoucherValueTxt: Label 'Note/Refund Voucher Value';
        DebitNoteNoTxt: Label 'Note/Refund Voucher Number';
        DebitNoteDateTxt: Label 'Note/Refund Voucher Date';
        InvoiceDateTxt: Label 'Invoice Date';
        InvoiceValueTxt: Label 'Invoice Value';
        PlaceofSupplyTxt: Label 'Place of Supply';
        ReverseChargeTxt: Label 'Reverse Charge';
        ECommGSTINTxt: Label 'E-Commerce GSTIN';
        TaxableValueTxt: Label 'Taxable Value';
        CESSAmountTxt: Label 'CESS Amount';
        GrossAdvanceRcvdTxt: Label 'Gross Advance Received';
        RateTxt: Label 'Rate';
        FileFormatErr: Label 'You must select GSTR File Format.';
        SEZWOPayTxt: Label 'SEZ Without Pay';
        OriginalInvNoTxt: Label 'Invoice/Advance Receipt Number';
        OriginalInvDateTxt: Label 'Invoice/Advance Receipt date';
        InvoiceTypeTxt: Label 'Invoice Type';
        ReceiverTxt: Label 'Receiver Name';
        TaxTxt: Label 'Applicable % of Tax Rate';
        ExempIntraRegAmount: Decimal;
        ExempInterRegAmount: Decimal;
        ExpExempInterRegAmt: Decimal;
        ExpExempIntraRegAmt: Decimal;
        ExpExempInterUnRegAmt: Decimal;
        ExpExempIntraUnRegAmt: Decimal;
        ExempCustIntraUnRegAmt: Decimal;
        ExempCustInterUnRegAmt: Decimal;
        ExempNonGSTInterRegAmt: Decimal;
        EXempNonGSTIntraRegAmt: Decimal;
        ExempNonGSTInterUnRegAmt: Decimal;
        ExempNonGSTIntraUnRegAmt: Decimal;
        NatureofSupply: Enum "Nature of Supply";

    procedure MakeExcelHeaderB2B()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(GSTINUINTxt);
        AddTextColumn(ReceiverTxt);
        AddTextColumn(InvoiceNoTxt);
        AddTextColumn(InvoiceDateTxt);
        AddTextColumn(InvoiceValueTxt);
        AddTextColumn(PlaceofSupplyTxt);
        AddTextColumn(ReverseChargeTxt);
        AddTextColumn(TaxTxt);
        AddTextColumn(InvoiceTypeTxt);
        AddTextColumn(ECommGSTINTxt);
        AddTextColumn(RateTxt);
        AddTextColumn(TaxableValueTxt);
        AddTextColumn(CESSAmountTxt);
    end;

    local procedure MakeExcelBodyB2B()
    var
        GSTR1B2BQuery: Query GSTR1B2BQuery;
    begin
        MakeExcelHeaderB2B();
        GSTR1B2BQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2BQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2BQuery.SetFilter(GST_Customer_Type, '%1|%2|%3|%4', "GST Customer Type"::"Deemed Export", "GST Customer Type"::"SEZ Unit", "GST Customer Type"::"SEZ Development", "GST Customer Type"::Registered);
        GSTR1B2BQuery.Open();
        while GSTR1B2BQuery.Read() do
            FillExcelBufferB2B(GSTR1B2BQuery);
    end;

    local procedure FillExcelBufferB2B(GSTR1B2BQuery: Query GSTR1B2BQuery)
    var
        Customer: Record Customer;
        GSTR1B2BCessAmt: Query GSTR1B2BCessAmt;
        LocationRegNo: Variant;
    begin
        TempExcelBuffer.NewRow();
        if GSTR1B2BQuery.Reverse_Charge then begin
            LocationRegNo := GSTR1B2BQuery.Location__Reg__No_;
            AddTextColumn(LocationRegNo);
        end
        else
            AddTextColumn(GSTR1B2BQuery.Buyer_Seller_Reg__No_);

        if GSTR1B2BQuery.Source_No_ <> '' then begin
            Customer.SetRange("No.", GSTR1B2BQuery.Source_No_);
            if Customer.FindFirst() then
                AddTextColumn(Customer.Name);
        end
        else
            AddTextColumn('');

        AddTextColumn(GSTR1B2BQuery.Document_No_);

        if GSTR1B2BQuery.Original_Doc__Type = GSTR1B2BQuery.Original_Doc__Type::"Transfer Shipment" then begin
            AddDateColumn(GSTR1B2BQuery.Posting_Date);
            FillInvoiceValue(GSTR1B2BQuery);
        end
        else begin
            AddDateColumn(GetDocumentDate(GSTR1B2BQuery.Document_No_, "GST Document Type"::Invoice));
            if GSTR1B2BQuery.Finance_Charge_Memo then
                AddNumberColumn(GetInvoiceValueFinCharge(GSTR1B2BQuery.Document_No_))
            else
                AddNumberColumn(GetInvoiceValue(GSTR1B2BQuery.Document_No_, "GST Document Type"::Invoice));
        end;

        if GSTR1B2BQuery.Buyer_Seller_State_Code <> '' then
            AddTextColumn(GSTR1B2BQuery.State_Code__GST_Reg__No__ + '-' + GSTR1B2BQuery.Description)
        else
            AddTextColumn('');

        if GSTR1B2BQuery.Reverse_Charge then
            AddTextColumn(YLbl)
        else
            AddTextColumn(NLbl);

        AddTextColumn('');
        AddTextColumn(GetInvoiceType(GSTR1B2BQuery));

        if GSTR1B2BQuery.e_Comm__Operator_GST_Reg__No_ <> '' then
            AddTextColumn(GSTR1B2BQuery.e_Comm__Operator_GST_Reg__No_)
        else
            AddTextColumn('');

        if GSTR1B2BQuery.GST_Jurisdiction_Type = GSTR1B2BQuery.GST_Jurisdiction_Type::Intrastate then
            AddNumberColumn(2 * GSTR1B2BQuery.GST__)
        else
            AddNumberColumn(GSTR1B2BQuery.GST__);

        if GSTR1B2BQuery.GST_Jurisdiction_Type = GSTR1B2BQuery.GST_Jurisdiction_Type::Intrastate then
            AddNumberColumn(Abs(GSTR1B2BQuery.GST_Base_Amount / 2))
        else
            AddNumberColumn(Abs(GSTR1B2BQuery.GST_Base_Amount));

        GSTR1B2BCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2BCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2BCessAmt.SetRange(GSTR1B2BCessAmt.Document_No_, GSTR1B2BQuery.Document_No_);
        GSTR1B2BCessAmt.SetRange(GSTR1B2BCessAmt.GST_Customer_Type, GSTR1B2BQuery.GST_Customer_Type);
        GSTR1B2BCessAmt.Open();
        if GSTR1B2BCessAmt.Read() then
            AddNumberColumn(Abs(GSTR1B2BCessAmt.GST_Amount))
        else
            AddNumberColumn(0.00);
    end;

    local procedure FillInvoiceValue(GSTR1B2BQuery: Query GSTR1B2BQuery)
    var
        GSTR1B2BTranship: Query GSTR1B2BSalesTranship;
        InvoiceValue: Decimal;
    begin
        GSTR1B2BTranship.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2BTranship.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2BTranship.SetRange(Document_No_, GSTR1B2BQuery.Document_No_);
        GSTR1B2BTranship.Open();
        while GSTR1B2BTranship.Read() do
            if GSTR1B2BQuery.GST_Jurisdiction_Type = GSTR1B2BQuery.GST_Jurisdiction_Type::Intrastate then
                InvoiceValue += ((Abs(GSTR1B2BTranship.GST_Base_Amount) + (Abs(GSTR1B2BTranship.GST_Amount) * 2)) / 2)
            else
                InvoiceValue += Abs(GSTR1B2BTranship.GST_Base_Amount) + Abs(GSTR1B2BTranship.GST_Amount);

        AddNumberColumn(InvoiceValue);
    end;

    local procedure MakeExcelHeaderB2CL()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(InvoiceNoTxt);
        AddTextColumn(InvoiceDateTxt);
        AddTextColumn(InvoiceValueTxt);
        AddTextColumn(PlaceofSupplyTxt);
        AddTextColumn(TaxTxt);
        AddTextColumn(RateTxt);
        AddTextColumn(TaxableValueTxt);
        AddTextColumn(CESSAmountTxt);
        AddTextColumn(ECommGSTINTxt);
    end;

    local procedure MakeExcelBodyB2CL()
    var
        GSTR1B2CLQuery: Query GSTR1B2CLQuery;
    begin
        MakeExcelHeaderB2CL();
        GSTR1B2CLQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CLQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CLQuery.SetRange(GSTR1B2CLQuery.GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR1B2CLQuery.Open();
        while GSTR1B2CLQuery.Read() do
            if GetInvoiceValue(GSTR1B2CLQuery.Document_No_, "GST Document Type"::Invoice) >= B2CLimit then
                FillExcelBufferForB2CL(GSTR1B2CLQuery);
    end;

    local procedure FillExcelBufferForB2CL(GSTR1B2CLQuery: Query GSTR1B2CLQuery)
    var
        GSTR1B2CLPer: Query GSTR1B2CLPer;
        GSTR1B2CLCessAmt: Query GSTR1B2CLCessAmt;
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(GSTR1B2CLQuery.Document_No_);
        AddDateColumn(GSTR1B2CLQuery.Posting_Date);
        AddNumberColumn(GetInvoiceValue(GSTR1B2CLQuery.Document_No_, "GST Document Type"::Invoice));

        if GSTR1B2CLQuery.Buyer_Seller_State_Code <> '' then
            AddTextColumn(GSTR1B2CLQuery.State_Code__GST_Reg__No__ + '-' + GSTR1B2CLQuery.Description)
        else
            AddTextColumn('');

        AddTextColumn('');

        GSTR1B2CLPer.TopNumberOfRows(1);
        GSTR1B2CLPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CLPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CLPer.SetRange(GSTR1B2CLPer.Document_No_, GSTR1B2CLQuery.Document_No_);
        GSTR1B2CLPer.SetRange(GSTR1B2CLPer.GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR1B2CLPer.Open();
        while GSTR1B2CLPer.Read() do
            AddNumberColumn(GSTR1B2CLPer.GST__);

        AddNumberColumn(Abs(GSTR1B2CLQuery.GST_Base_Amount));

        GSTR1B2CLCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CLCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CLCessAmt.SetRange(GSTR1B2CLCessAmt.Document_No_, GSTR1B2CLQuery.Document_No_);
        GSTR1B2CLCessAmt.SetRange(GSTR1B2CLCessAmt.GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR1B2CLCessAmt.Open();
        if GSTR1B2CLCessAmt.Read() then
            AddNumberColumn(Abs(GSTR1B2CLCessAmt.GST_Amount))
        else
            AddNumberColumn(0.00);

        if GSTR1B2CLQuery.e_Comm__Operator_GST_Reg__No_ <> '' then
            AddTextColumn(GSTR1B2CLQuery.e_Comm__Operator_GST_Reg__No_)
        else
            AddTextColumn('');
    end;

    local procedure MakeExcelHeaderB2CS()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(TypeTxt);
        AddTextColumn(PlaceOfSupplyTxt);
        AddTextColumn(TaxTxt);
        AddTextColumn(RateTxt);
        AddTextColumn(TaxableValueTxt);
        AddTextColumn(CESSAmountTxt);
        AddTextColumn(ECommGSTINTxt);
    end;

    local procedure MakeExcelBodyB2CS()
    var
        GSTR1B2CSQuery: Query GSTR1B2CSQuery;
    begin
        MakeExcelHeaderB2CS();
        GSTR1B2CSQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSQuery.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSQuery.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1B2CSQuery.Open();
        while GSTR1B2CSQuery.Read() do
            FillExcelBufferForB2CS(GSTR1B2CSQuery);
    end;

    local procedure FillExcelBufferForB2CS(GSTR1B2CSQuery: Query GSTR1B2CSQuery)
    var
        GSTR1B2CSCessAmt: Query GSTR1B2CSCessAmt;
        GSTR1B2CInterCess: Query GSTR1B2CInterCess;
        GSTR1B2CSIntraAmt: Query GSTR1B2CSIntra;
        GSTR1B2CSInter: Query GSTR1B2CSInter;
        GSTR1B2CSCrMemo: Query GSTR1B2CSCrMemo;
        GSTR1B2CSIntraCess: Query GSTR1B2CIntraCess;
        GSTRB2CSIntraAmount: Decimal;
        GSTR1B2CSInterBaseAmt: Decimal;
        GSTR1IntraCess: Decimal;
        GSTR1InterCess: Decimal;
        TotalBaseAmount: Decimal;
        TotalCessAmount: Decimal;
    begin
        GSTR1B2CSIntraAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSIntraAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSIntraAmt.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSIntraAmt.SetRange(e_Comm__Operator_GST_Reg__No_, GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_);
        GSTR1B2CSIntraAmt.SetRange(Buyer_Seller_State_Code, GSTR1B2CSQuery.Buyer_Seller_State_Code);
        GSTR1B2CSIntraAmt.SetRange(GST__, GSTR1B2CSQuery.GST__);
        GSTR1B2CSIntraAmt.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1B2CSIntraAmt.Open();
        while GSTR1B2CSIntraAmt.Read() do
            GSTRB2CSIntraAmount := GSTR1B2CSIntraAmt.GST_Base_Amount;

        GSTR1B2CSInter.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSInter.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSInter.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSInter.SetRange(e_Comm__Operator_GST_Reg__No_, GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_);
        GSTR1B2CSInter.SetRange(GSTR1B2CSInter.Buyer_Seller_State_Code, GSTR1B2CSQuery.Buyer_Seller_State_Code);
        GSTR1B2CSInter.SetRange(GST__, GSTR1B2CSQuery.GST__);
        GSTR1B2CSInter.SetRange(Document_Type, "GST Document Type"::Invoice);
        GSTR1B2CSInter.Open();
        while GSTR1B2CSInter.Read() do
            GSTR1B2CSInterBaseAmt := GSTR1B2CSInter.GST_Base_Amount;

        GSTR1B2CSCrMemo.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSCrMemo.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSCrMemo.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSCrMemo.SetRange(e_Comm__Operator_GST_Reg__No_, GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_);
        GSTR1B2CSCrMemo.SetRange(GSTR1B2CSCrMemo.Buyer_Seller_State_Code, GSTR1B2CSQuery.Buyer_Seller_State_Code);
        GSTR1B2CSCrMemo.SetRange(GST__, GSTR1B2CSQuery.GST__);
        GSTR1B2CSCrMemo.SetRange(Document_Type, "GST Document Type"::"Credit Memo");
        GSTR1B2CSCrMemo.Open();
        while GSTR1B2CSCrMemo.Read() do
            GSTR1B2CSInterBaseAmt += GSTR1B2CSCrMemo.GST_Base_Amount;
        GSTR1B2CSCrMemo.Close();

        TotalBaseAmount := Abs(GSTR1B2CSInterBaseAmt + GSTRB2CSIntraAmount);

        GSTR1B2CSCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSCessAmt.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSCessAmt.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1B2CSCessAmt.Open();
        if GSTR1B2CSCessAmt.Read() then begin
            GSTR1B2CSIntraCess.SetRange(Location__Reg__No_, LocationGSTIN);
            GSTR1B2CSIntraCess.SetRange(Posting_Date, StartDate, EndDate);
            GSTR1B2CSIntraCess.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
            GSTR1B2CSIntraCess.SetRange(e_Comm__Operator_GST_Reg__No_, GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_);
            GSTR1B2CSIntraCess.SetRange(Buyer_Seller_State_Code, GSTR1B2CSQuery.Buyer_Seller_State_Code);
            GSTR1B2CSIntraCess.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
            GSTR1B2CSIntraCess.Open();
            while GSTR1B2CSIntraCess.Read() do
                GSTR1IntraCess := GSTR1B2CSIntraCess.GST_Amount;

            GSTR1B2CInterCess.SetRange(Location__Reg__No_, LocationGSTIN);
            GSTR1B2CInterCess.SetRange(Posting_Date, StartDate, EndDate);
            GSTR1B2CInterCess.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
            GSTR1B2CInterCess.SetRange(e_Comm__Operator_GST_Reg__No_, GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_);
            GSTR1B2CInterCess.SetRange(Buyer_Seller_State_Code, GSTR1B2CSQuery.Buyer_Seller_State_Code);
            GSTR1B2CInterCess.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
            GSTR1B2CInterCess.Open();
            while GSTR1B2CInterCess.Read() do
                GSTR1InterCess := GSTR1B2CInterCess.GST_Amount;
        end;

        TotalCessAmount := Abs(GSTR1IntraCess + GSTR1InterCess);
        FillExcelForB2cs(GSTR1B2CSQuery, TotalBaseAmount, TotalCessAmount);
    end;

    local procedure FillExcelForB2cs(GSTR1B2CSQuery: Query GSTR1B2CSQuery; TotalBaseAmount: Decimal; TotalCessAmount: Decimal)
    var
        State: Record State;
    begin
        if TotalBaseAmount <> 0 then begin
            TempExcelBuffer.NewRow();
            if GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_ <> '' then
                AddTextColumn(ELbl)
            else
                AddTextColumn(UpperCase(OtherECommTxt));

            if State.Get(GSTR1B2CSQuery.Buyer_Seller_State_Code) then
                AddTextColumn(State."State Code (GST Reg. No.)" + '-' + State.Description)
            else
                AddTextColumn('');

            AddTextColumn('');

            if GSTR1B2CSQuery.GST_Jurisdiction_Type = GSTR1B2CSQuery.GST_Jurisdiction_Type::Intrastate then
                AddNumberColumn(2 * GSTR1B2CSQuery.GST__)
            else
                AddNumberColumn(GSTR1B2CSQuery.GST__);

            AddNumberColumn(TotalBaseAmount);
            AddNumberColumn(TotalCessAmount);

            if GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_ <> '' then
                AddTextColumn(GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_)
            else
                AddTextColumn('');
        end;
    end;

    local procedure MakeExcelHeaderAT()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(PlaceOfSupplyTxt);
        AddTextColumn(TaxTxt);
        AddTextColumn(RateTxt);
        AddTextColumn(GrossAdvanceRcvdTxt);
        AddTextColumn(CESSAmountTxt);
    end;

    local procedure MakeExcelBodyAT()
    var
        GSTR1ATQuery: Query GSTR1ATQuery;
    begin
        MakeExcelHeaderAT();
        GSTR1ATQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATQuery.SetRange(GSTR1ATQuery.Reversed, false);
        GSTR1ATQuery.SetRange(GST_on_Advance_Payment, true);
        GSTR1ATQuery.Open();
        while GSTR1ATQuery.Read() do
            FillExcelBufferForAT(GSTR1ATQuery);
    end;

    local procedure MakeExcelHeaderHSN()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(HSNSACofSupplyTxt);
        AddTextColumn(DescTxt);
        AddTextColumn(UpperCase(UQCTxt));
        AddTextColumn(TotalQtyTxt);
        AddTextColumn(TotalValTxt);
        AddTextColumn(TaxableValueTxt);
        AddTextColumn(IGSTAmountTxt);
        AddTextColumn(CGSTAmountTxt);
        AddTextColumn(SGSTAmountTxt);
        AddTextColumn(CESSAmountTxt);
    end;

    local procedure MakeExcelBodyHSN()
    var
        GSTR1HSNQuery: Query GSTR1HSNQuery;
    begin
        MakeExcelHeaderHSN();
        GSTR1HSNQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1HSNQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1HSNQuery.SetFilter(GSTR1HSNQuery.Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1HSNQuery.Open();
        while GSTR1HSNQuery.Read() do
            FillExcelBufferForHSN(GSTR1HSNQuery);
    end;

    local procedure FillExcelBufferForHSN(GSTR1HSNQuery: Query GSTR1HSNQuery)
    var
        GSTR1HSNGSTAmt: Query GSTR1HSNGSTAmt;
        GSTR1HSNQty: Query GSTR1HSNQty;
        HSNIGSTAmt: Decimal;
        HSNCGSTAmt: Decimal;
        HSNSGSTAmt: Decimal;
        HSNCessAmt: Decimal;
        HSNQty: Decimal;
        HSNGSTBaseAmt: Decimal;
    begin
        GSTR1HSNGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1HSNGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1HSNGSTAmt.SetRange(HSN_SAC_Code, GSTR1HSNQuery.HSN_SAC_Code);
        GSTR1HSNGSTAmt.SetRange(GST_Component_Code, CGSTLbl);
        GSTR1HSNGSTAmt.SetRange(UOM, GSTR1HSNQuery.UOM);
        GSTR1HSNGSTAmt.Open();
        while GSTR1HSNGSTAmt.Read() do
            HSNCGSTAmt := GSTR1HSNGSTAmt.GST_Amount;

        GSTR1HSNGSTAmt.SetRange(GST_Component_Code, SGSTLbl);
        GSTR1HSNGSTAmt.Open();
        while GSTR1HSNGSTAmt.Read() do
            HSNSGSTAmt := GSTR1HSNGSTAmt.GST_Amount;

        GSTR1HSNGSTAmt.SetRange(GST_Component_Code, IGSTLbl);
        GSTR1HSNGSTAmt.Open();
        while GSTR1HSNGSTAmt.Read() do
            HSNIGSTAmt := GSTR1HSNGSTAmt.GST_Amount;

        GSTR1HSNGSTAmt.SetRange(GST_Component_Code, CessLbl);
        GSTR1HSNGSTAmt.Open();
        while GSTR1HSNGSTAmt.Read() do
            HSNCessAmt := GSTR1HSNGSTAmt.GST_Amount;

        GSTR1HSNQty.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1HSNQty.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1HSNQty.SetRange(HSN_SAC_Code, GSTR1HSNQuery.HSN_SAC_Code);
        GSTR1HSNQty.SetRange(UOM, GSTR1HSNQuery.UOM);
        GSTR1HSNQty.Open();
        while GSTR1HSNQty.Read() do
            if GSTR1HSNQty.GST_Jurisdiction_Type = GSTR1HSNQty.GST_Jurisdiction_Type::Intrastate then begin
                HSNQty += GSTR1HSNQty.Quantity / 2;
                HSNGSTBaseAmt += GSTR1HSNQty.GST_Base_Amount / 2;
            end else begin
                HSNQty += GSTR1HSNQty.Quantity;
                HSNGSTBaseAmt += GSTR1HSNQty.GST_Base_Amount;
            end;

        TempExcelBuffer.NewRow();
        AddTextColumn(GSTR1HSNQuery.HSN_SAC_Code);
        if GSTR1HSNQuery.HSN_SAC_Code <> '' then
            AddTextColumn(GSTR1HSNQuery.Description)
        else
            AddTextColumn('');

        AddTextColumn(GSTR1HSNQuery.UOM);
        AddNumberColumn(-(HSNQty));
        AddNumberColumn(-(HSNGSTBaseAmt + HSNIGSTAmt + HSNCGSTAmt + HSNSGSTAmt + HSNCessAmt));
        AddNumberColumn(-(HSNGSTBaseAmt));
        AddNumberColumn(-HSNIGSTAmt);
        AddNumberColumn(-HSNCGSTAmt);
        AddNumberColumn(-HSNSGSTAmt);
        AddNumberColumn(-HSNCessAmt);
    end;

    local procedure MakeExcelHeaderEXP()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(ExportTypeTxt);
        AddTextColumn(InvoiceNoTxt);
        AddTextColumn(InvoiceDateTxt);
        AddTextColumn(InvoiceValueTxt);
        AddTextColumn(PortCodeTxt);
        AddTextColumn(ShipBillNoTxt);
        AddTextColumn(ShipBillDateTxt);
        AddTextColumn(TaxTxt);
        AddTextColumn(RateTxt);
        AddTextColumn(TaxableValueTxt);
        AddTextColumn(CESSAmountTxt);
    end;

    local procedure MakeExcelBodyEXP()
    var
        GSTR1EXPQuery: Query GSTR1ExpQuery;
    begin
        MakeExcelHeaderEXP();
        GSTR1EXPQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1EXPQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1EXPQuery.Open();
        while GSTR1EXPQuery.Read() do
            FillExcelBufferForExport(GSTR1ExpQuery);
    end;

    local procedure FillExcelBufferForExport(GSTR1ExpQuery: Query GSTR1ExpQuery)
    var
        GSTR1ExpPerQuery: Query GSTR1ExpPer;
        GSTR1ExpCessAmt: Query GSTR1ExpCessAmt;
    begin
        TempExcelBuffer.NewRow();
        if GSTR1ExpQuery.GST_Without_Payment_of_Duty then
            AddTextColumn(UpperCase(WOPAYTxt))
        else
            AddTextColumn(UpperCase(WPAYTxt));

        AddTextColumn(GSTR1ExpQuery.Document_No_);
        AddDateColumn(GSTR1ExpQuery.Posting_Date);

        if GSTR1ExpQuery.Finance_Charge_Memo then
            AddNumberColumn(GetInvoiceValueFinCharge(GSTR1ExpQuery.Document_No_))
        else
            AddNumberColumn(GetInvoiceValueForExportCustomerType(GSTR1ExpQuery.Document_No_, "GST Document Type"::Invoice));

        AddTextColumn(GetExitPoint(GSTR1ExpQuery.Document_No_));
        AddTextColumn(GSTR1ExpQuery.Bill_Of_Export_No_);
        AddDateColumn(GSTR1ExpQuery.Bill_Of_Export_Date);
        AddTextColumn('');

        GSTR1ExpPerQuery.TopNumberOfRows(1);
        GSTR1ExpPerQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ExpPerQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ExpPerQuery.SetRange(Document_No_, GSTR1ExpQuery.Document_No_);
        GSTR1ExpPerQuery.Open();
        while GSTR1ExpPerQuery.Read() do
            AddNumberColumn(Abs(GSTR1ExpPerQuery.GST__));

        if GSTR1ExpQuery.GST_Jurisdiction_Type = GSTR1ExpQuery.GST_Jurisdiction_Type::Intrastate then
            AddNumberColumn(Abs(GSTR1ExpQuery.GST_Base_Amount / 2))
        else
            AddNumberColumn(Abs(GSTR1ExpQuery.GST_Base_Amount));

        GSTR1ExpCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ExpCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ExpCessAmt.SetRange(Document_No_, GSTR1ExpQuery.Document_No_);
        GSTR1ExpCessAmt.Open();
        if GSTR1ExpCessAmt.Read() then
            AddNumberColumn(Abs(GSTR1ExpCessAmt.GST_Amount))
        else
            AddNumberColumn(0.00);
    end;

    local procedure GetExitPoint(DocumentNo: Code[20]): Code[10]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.Get(DocumentNo) then
            exit(SalesInvoiceHeader."Exit Point");
    end;

    local procedure MakeExcelHeaderATADJ()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(PlaceOfSupplyTxt);
        AddTextColumn(TaxTxt);
        AddTextColumn(RateTxt);
        AddTextColumn(GrossAdvanceRcvdTxt);
        AddTextColumn(CESSAmountTxt);
    end;

    local procedure MakeExcelBodyATADJ()
    var
        GSTR1ATADJQuery: Query GSTR1ATADJQuery;
    begin
        MakeExcelHeaderATADJ();
        GSTR1ATADJQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATADJQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATADJQuery.SetRange(UnApplied, false);
        GSTR1ATADJQuery.SetRange(Reversed, false);
        GSTR1ATADJQuery.Open();
        while GSTR1ATADJQuery.Read() do
            FillExcelBufferForATADJ(GSTR1ATADJQuery);
    end;

    local procedure FillExcelBufferForATADJ(GSTR1ATADJQuery: Query GSTR1ATADJQuery)
    var
        State: Record State;
        GSTR1ATADJGSTPer: Query GSTR1ATADJGSTPer;
        GSTR1ATADJCessAmt: Query GSTR1ATADJCessAmt;
    begin
        TempExcelBuffer.NewRow();
        if State.Get(GSTR1ATADJQuery.Buyer_Seller_State_Code) then
            AddTextColumn(GSTR1ATADJQuery.State_Code__GST_Reg__No__ + '-' + GSTR1ATADJQuery.Description)
        else
            AddTextColumn('');

        AddTextColumn('');

        GSTR1ATADJGSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATADJGSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATADJGSTPer.SetRange(UnApplied, false);
        GSTR1ATADJGSTPer.SetRange(Reversed, false);
        GSTR1ATADJGSTPer.Open();
        if GSTR1ATADJGSTPer.Read() then
            if GSTR1ATADJGSTPer.GST_Jurisdiction_Type = GSTR1ATADJGSTPer.GST_Jurisdiction_Type::Intrastate then
                AddNumberColumn(2 * GSTR1ATADJGSTPer.GST__)
            else
                AddNumberColumn(GSTR1ATADJGSTPer.GST__);

        if GSTR1ATADJQuery.GST_Jurisdiction_Type = GSTR1ATADJQuery.GST_Jurisdiction_Type::Intrastate then
            AddNumberColumn(Abs(GSTR1ATADJQuery.GST_Base_Amount / 2))
        else
            AddNumberColumn(Abs(GSTR1ATADJQuery.GST_Base_Amount));

        GSTR1ATADJCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATADJCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATADJCessAmt.SetRange(UnApplied, false);
        GSTR1ATADJCessAmt.SetRange(Reversed, false);
        GSTR1ATADJCessAmt.Open();
        if GSTR1ATADJCessAmt.Read() then
            AddNumberColumn(Abs(GSTR1ATADJCessAmt.GST_Amount))
        else
            AddNumberColumn(0.00);
    end;

    local procedure FillExcelBufferForAT(GSTR1ATQuery: Query GSTR1ATQuery)
    var
        State: Record State;
        GSTR1ATPer: Query GSTR1ATPer;
        GSTR1ATCessAmt: Query GSTR1ATCessAmt;
    begin
        TempExcelBuffer.NewRow();
        if State.Get(GSTR1ATQuery.Buyer_Seller_State_Code) then
            AddTextColumn(GSTR1ATQuery.State_Code__GST_Reg__No__ + '-' + GSTR1ATQuery.Description)
        else
            AddTextColumn('');

        AddTextColumn('');

        GSTR1ATPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATPer.SetRange(GST_on_Advance_Payment, true);
        GSTR1ATPer.SetRange(Document_No_, GSTR1ATQuery.Document_No_);
        GSTR1ATPer.SetRange(Reversed, false);
        GSTR1ATPer.Open();
        while GSTR1ATPer.Read() do
            if GSTR1ATPer.GST_Jurisdiction_Type = GSTR1ATPer.GST_Jurisdiction_Type::Intrastate then
                AddNumberColumn(2 * GSTR1ATPer.GST__)
            else
                AddNumberColumn(GSTR1ATPer.GST__);

        if GSTR1ATQuery.GST_Jurisdiction_Type = GSTR1ATQuery.GST_Jurisdiction_Type::Intrastate then
            AddNumberColumn(Abs(GSTR1ATQuery.GST_Base_Amount / 2))
        else
            AddNumberColumn(Abs(GSTR1ATQuery.GST_Base_Amount));

        GSTR1ATCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATCessAmt.SetRange(GST_on_Advance_Payment, true);
        GSTR1ATCessAmt.SetRange(Document_No_, GSTR1ATQuery.Document_No_);
        GSTR1ATCessAmt.SetRange(Reversed, false);
        GSTR1ATCessAmt.Open();
        if GSTR1ATCessAmt.Read() then
            AddNumberColumn(Abs(GSTR1ATCessAmt.GST_Amount))
        else
            AddNumberColumn(0.00);
    end;

    local procedure MakeExcelHeaderCDNR()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(GSTINUINTxt);
        AddTextColumn(ReceiverTxt);
        AddTextColumn(OriginalInvNoTxt);
        AddTextColumn(OriginalInvDateTxt);
        AddTextColumn(DebitNoteNoTxt);
        AddTextColumn(DebitNoteDateTxt);
        AddTextColumn(DocumentTypeTxt);
        AddTextColumn(PlaceOfSupplyTxt);
        AddTextColumn(RefundVoucherValueTxt);
        AddTextColumn(TaxTxt);
        AddTextColumn(RateTxt);
        AddTextColumn(TaxableValueTxt);
        AddTextColumn(CESSAmountTxt);
        AddTextColumn(PreGSTTxt);
    end;

    local procedure MakeExcelBodyCDNR()
    var
        GSTR1CDNRQuery: Query GSTR1CDNRQuery;
    begin
        MakeExcelHeaderCDNR();
        GSTR1CDNRQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNRQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNRQuery.SetFilter(Document_Type, '%1|%2|%3',
            "GST Document Type"::"Credit Memo",
            "GST Document Type"::Invoice,
            "GST Document Type"::Refund);
        GSTR1CDNRQuery.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit",
            "GST Customer Type"::Registered);
        GSTR1CDNRQuery.Open();
        while GSTR1CDNRQuery.Read() do
            if FilterDGLEForCDNR(GSTR1CDNRQuery) then
                FillExcelBufferForCDNR(GSTR1CDNRQuery);
    end;

    local procedure FilterDGLEForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if FilterDGLEDocTypeForCDNR(GSTR1CDNRQuery) or FilterDGLEDocTypeInvForCDNR(GSTR1CDNRQuery) then
            exit(true);
    end;

    local procedure FilterDGLEDocTypeForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if (GSTR1CDNRQuery.Document_Type = GSTR1CDNRQuery.Document_Type::"Credit Memo") or (FilterDGLEForRefundDocType(GSTR1CDNRQuery)) then
            exit(true);
    end;

    local procedure FilterDGLEForRefundDocType(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if (GSTR1CDNRQuery.Document_Type = GSTR1CDNRQuery.Document_Type::Refund) and (not GSTR1CDNRQuery.Adv__Pmt__Adjustment) then
            exit(true);
    end;

    local procedure FilterDGLEDocTypeInvForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if (GSTR1CDNRQuery.Document_Type = GSTR1CDNRQuery.Document_Type::Invoice) and FilterDGLESalesInvForCDNR(GSTR1CDNRQuery) then
            exit(true);
    end;

    local procedure FillExcelBufferForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery)
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        GSTR1CDNRPerQuery: Query GSTR1CDNRPerQuery;
        GSTR1CDNRCess: Query GSTR1CDNRCess;
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(GSTR1CDNRQuery.Buyer_Seller_Reg__No_);

        if GSTR1CDNRQuery.Source_No_ <> '' then
            AddTextColumn(GSTR1CDNRQuery.Name)
        else
            AddTextColumn('');

        if (GSTR1CDNRQuery.Document_Type in [GSTR1CDNRQuery.Document_Type::"Credit Memo", GSTR1CDNRQuery.Document_Type::Invoice]) then begin
            ReferenceInvoiceNo.Reset();
            ReferenceInvoiceNo.SetRange("Document No.", GSTR1CDNRQuery.Document_No_);
            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR1CDNRQuery.Document_Type));
            ReferenceInvoiceNo.SetRange("Source No.", GSTR1CDNRQuery.Source_No_);
            if ReferenceInvoiceNo.FindFirst() then begin
                AddTextColumn(ReferenceInvoiceNo."Reference Invoice Nos.");
                AddDateColumn(GetPostingDate(ReferenceInvoiceNo));
            end else begin
                AddTextColumn('');
                AddTextColumn('');
            end;
        end;

        AddTextColumn(GSTR1CDNRQuery.Document_No_);
        AddDateColumn(GSTR1CDNRQuery.Posting_Date);

        AddTextColumn(GetDocumentTypeTxt(GSTR1CDNRQuery.Document_Type));

        if GSTR1CDNRQuery.Buyer_Seller_State_Code <> '' then
            AddTextColumn(GSTR1CDNRQuery.State_Code__GST_Reg__No__ + '-' + GSTR1CDNRQuery.Description)
        else
            AddTextColumn('');

        if GSTR1CDNRQuery.Document_Type in [GSTR1CDNRQuery.Document_Type::Invoice, GSTR1CDNRQuery.Document_Type::"Credit Memo"] then
            if GSTR1CDNRQuery.Finance_Charge_Memo then
                AddNumberColumn(GetInvoiceValueFinCharge(GSTR1CDNRQuery.Document_No_))
            else
                AddNumberColumn(GetInvoiceValue(GSTR1CDNRQuery.Document_No_, GSTR1CDNRQuery.Document_Type))
        else
            AddNumberColumn(Abs(GSTR1CDNRQuery.GST_Base_Amount) + Abs(GSTR1CDNRCess.GST_Amount));

        AddTextColumn('');

        GSTR1CDNRPerQuery.TopNumberOfRows(1);
        GSTR1CDNRPerQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNRPerQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNRPerQuery.SetRange(Document_No_, GSTR1CDNRQuery.Document_No_);
        GSTR1CDNRPerQuery.SetRange(Document_Type, GSTR1CDNRQuery.Document_Type);
        GSTR1CDNRPerQuery.Open();
        while GSTR1CDNRPerQuery.Read() do
            if GSTR1CDNRPerQuery.GST_Jurisdiction_Type = GSTR1CDNRPerQuery.GST_Jurisdiction_Type::Intrastate then
                AddNumberColumn(2 * GSTR1CDNRPerQuery.GST__)
            else
                AddNumberColumn(GSTR1CDNRPerQuery.GST__);

        if GSTR1CDNRQuery.GST_Jurisdiction_Type = GSTR1CDNRQuery.GST_Jurisdiction_Type::Intrastate then
            AddNumberColumn(Abs(GSTR1CDNRQuery.GST_Base_Amount / 2))
        else
            AddNumberColumn(Abs(GSTR1CDNRQuery.GST_Base_Amount));

        GSTR1CDNRCess.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNRCess.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNRCess.SetRange(GSTR1CDNRCess.Document_No_, GSTR1CDNRQuery.Document_No_);
        GSTR1CDNRCess.SetRange(Document_No_, GSTR1CDNRQuery.Document_No_);
        GSTR1CDNRCess.SetRange(Document_Type, GSTR1CDNRQuery.Document_Type);
        GSTR1CDNRCess.Open();
        if GSTR1CDNRCess.Read() then
            AddNumberColumn(Abs(GSTR1CDNRCess.GST_Amount))
        else
            AddNumberColumn(0.00);

        if CheckPreGSTForCDNR(GSTR1CDNRQuery) then
            AddTextColumn(YLbl)
        else
            AddTextColumn(NLbl);
    end;

    local procedure GetPostingDate(var ReferenceInvoiceNo: Record "Reference Invoice No."): Date
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PostingDate: Date;
    begin
        CustLedgerEntry.SetRange("Customer No.", ReferenceInvoiceNo."Source No.");
        CustLedgerEntry.SetFilter("Document Type", '%1|%2', CustLedgerEntry."Document Type"::Invoice, CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
        if CustLedgerEntry.FindFirst() then
            PostingDate := CustLedgerEntry."Posting Date";
        exit(PostingDate);
    end;

    local procedure GSTDocumentType2DocumentTypeEnum(GSTDocumentType: Enum "GST Document Type"): Enum "Document Type Enum"
    begin
        case GSTDocumentType of
            GSTDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            GSTDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            GSTDocumentType::Refund:
                exit("Document Type Enum"::Refund);
            GSTDocumentType::Payment:
                exit("Document Type Enum"::Payment);
        end;
    end;

    local procedure MakeExcelHeaderCDNUR()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(URTypeTxt);
        AddTextColumn(DebitNoteNoTxt);
        AddTextColumn(DebitNoteDateTxt);
        AddTextColumn(DocumentTypeTxt);
        AddTextColumn(OriginalInvNoTxt);
        AddTextColumn(OriginalInvDateTxt);
        AddTextColumn(PlaceOfSupplyTxt);
        AddTextColumn(RefundVoucherValueTxt);
        AddTextColumn(TaxTxt);
        AddTextColumn(RateTxt);
        AddTextColumn(TaxableValueTxt);
        AddTextColumn(CESSAmountTxt);
        AddTextColumn(PreGSTTxt);
    end;

    local procedure MakeExcelBodyCDNUR()
    var
        GSTR1CDNURQuery: Query GSTR1CDNURQuery;
    begin
        MakeExcelHeaderCDNUR();
        GSTR1CDNURQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNURQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNURQuery.SetFilter(Document_Type, '%1|%2|%3',
            "GST Document Type"::"Credit Memo",
            "GST Document Type"::Invoice,
            "GST Document Type"::Refund);
        GSTR1CDNURQuery.SetFilter(GST_Customer_Type, '%1|%2',
            "GST Customer Type"::Export,
            "GST Customer Type"::Unregistered);
        GSTR1CDNURQuery.Open();
        while GSTR1CDNURQuery.Read() do
            if FilterDGLEForCDNUR(GSTR1CDNURQuery) then
                MakeExcelBodyLinesCDNUR(GSTR1CDNURQuery);
    end;

    local procedure MakeExcelBodyLinesCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery)
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        GSTR1CDNURGSTPer: Query GSTR1CDNURGSTPer;
        GSTR1CDNURCessAmt: Query GSTR1CDNURCessAmt;
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(GetURType(GSTR1CDNURQuery));
        AddTextColumn(GSTR1CDNURQuery.Document_No_);
        AddDateColumn(GSTR1CDNURQuery.Posting_Date);
        AddTextColumn(GetDocumentTypeTxt(GSTR1CDNURQuery.Document_Type));

        if (GSTR1CDNURQuery.Document_Type in [GSTR1CDNURQuery.Document_Type::"Credit Memo", GSTR1CDNURQuery.Document_Type::Invoice]) then begin
            ReferenceInvoiceNo.Reset();
            ReferenceInvoiceNo.SetRange("Document No.", GSTR1CDNURQuery.Document_No_);
            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR1CDNURQuery.Document_Type));
            ReferenceInvoiceNo.SetRange("Source No.", GSTR1CDNURQuery.Source_No_);
            if ReferenceInvoiceNo.FindFirst() then begin
                AddTextColumn(ReferenceInvoiceNo."Reference Invoice Nos.");
                AddDateColumn(GetPostingDate(ReferenceInvoiceNo));
            end else begin
                AddTextColumn('');
                AddTextColumn('');
            end;
        end;

        if GSTR1CDNURQuery.Buyer_Seller_State_Code <> '' then
            AddTextColumn(GetStateCodeGSTRegForCDNUR(GSTR1CDNURQuery) + '-' + GetStateDesForCDNUR(GSTR1CDNURQuery))
        else
            AddTextColumn(GetLocStateCodeRegForCDNUR(GSTR1CDNURQuery) + '-' + GetLocStateDesForCDNUR(GSTR1CDNURQuery));

        if GSTR1CDNURQuery.Document_Type in [GSTR1CDNURQuery.Document_Type::"Credit Memo", GSTR1CDNURQuery.Document_Type::Invoice] then
            if GSTR1CDNURQuery.Finance_Charge_Memo then
                AddNumberColumn(GetInvoiceValueFinCharge(GSTR1CDNURQuery.Document_No_))
            else
                AddNumberColumn(GetInvoiceValue(GSTR1CDNURQuery.Document_No_, GSTR1CDNURQuery.Document_Type))
        else
            AddNumberColumn(Abs(GSTR1CDNURQuery.GST_Base_Amount));

        AddTextColumn('');

        GSTR1CDNURGSTPer.TopNumberOfRows(1);
        GSTR1CDNURGSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNURGSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNURGSTPer.SetRange(Document_No_, GSTR1CDNURQuery.Document_No_);
        GSTR1CDNURGSTPer.SetRange(Document_Type, GSTR1CDNURQuery.Document_Type);
        GSTR1CDNURGSTPer.SetRange(GST_Customer_Type, GSTR1CDNURQuery.GST_Customer_Type);
        GSTR1CDNURGSTPer.Open();
        while GSTR1CDNURGSTPer.Read() do
            if GSTR1CDNURGSTPer.GST_Jurisdiction_Type = GSTR1CDNURGSTPer.GST_Jurisdiction_Type::Intrastate then
                AddNumberColumn(2 * GSTR1CDNURGSTPer.GST__)
            else
                AddNumberColumn(GSTR1CDNURGSTPer.GST__);

        AddNumberColumn(Abs(GSTR1CDNURQuery.GST_Base_Amount));

        GSTR1CDNURCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNURCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNURCessAmt.SetRange(GSTR1CDNURCessAmt.Document_No_, GSTR1CDNURQuery.Document_No_);
        GSTR1CDNURCessAmt.SetRange(Document_Type, GSTR1CDNURQuery.Document_Type);
        GSTR1CDNURCessAmt.SetRange(GST_Customer_Type, GSTR1CDNURQuery.GST_Customer_Type);
        GSTR1CDNURCessAmt.Open();
        if GSTR1CDNURCessAmt.Read() then
            AddNumberColumn(Abs(GSTR1CDNURCessAmt.GST_Amount))
        else
            AddNumberColumn(0.00);

        if CheckPreGSTForCDNUR(GSTR1CDNURQuery) then
            AddTextColumn(YLbl)
        else
            AddTextColumn(NLbl);
    end;

    local procedure FilterDGLEForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if FilterDGLECustTypeForCDNUR(GSTR1CDNURQuery) and (FilterDGLEDocTypeForCDNUR(GSTR1CDNURQuery) or FilterDGLEDocTypeInvForCDNUR(GSTR1CDNURQuery)) then
            exit(true);
    end;

    local procedure FilterDGLECustTypeForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.GST_Customer_Type = GSTR1CDNURQuery.GST_Customer_Type::Export) or (FilterDGLEUnregCustForCDNUR(GSTR1CDNURQuery)) then
            exit(true);
    end;

    local procedure FilterDGLEUnregCustForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.GST_Customer_Type = GSTR1CDNURQuery.GST_Customer_Type::Unregistered) and (GetInvoiceValue(GSTR1CDNURQuery.Document_No_, "GST Document Type"::"Credit Memo") >= B2CLimit) then
            exit(true);
    end;

    local procedure FilterDGLEDocTypeForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.Document_Type = GSTR1CDNURQuery.Document_Type::"Credit Memo") then
            exit(true);
    end;

    local procedure FilterDGLEDocTypeInvForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.Document_Type = GSTR1CDNURQuery.Document_Type::Invoice) and (FilterDGLESalesInvForCDNUR(GSTR1CDNURQuery)) then
            exit(true);
    end;

    local procedure FilterDGLESalesInvForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.Sales_Invoice_Type in [GSTR1CDNURQuery.Sales_Invoice_Type::"Debit Note", GSTR1CDNURQuery.Sales_Invoice_Type::Supplementary]) then
            exit(true);
    end;

    local procedure FilterDGLESalesInvForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if (GSTR1CDNRQuery.Sales_Invoice_Type in [GSTR1CDNRQuery.Sales_Invoice_Type::"Debit Note", GSTR1CDNRQuery.Sales_Invoice_Type::Supplementary]) then
            exit(true);
    end;

    local procedure GetStateCodeGSTRegForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Code[10]
    var
        State: Record State;
        StateGSTRegNo: Code[10];
    begin
        State.SetRange(Code, GSTR1CDNURQuery.Buyer_Seller_State_Code);
        if State.FindFirst() then
            StateGSTRegNo := State."State Code (GST Reg. No.)";
        exit(StateGSTRegNo)
    end;

    local procedure GetStateDesForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Text[50]
    var
        State: Record State;
        Description: Text[50];
    begin
        State.SetRange(Code, GSTR1CDNURQuery.Buyer_Seller_State_Code);
        if State.FindFirst() then
            Description := State.Description;
        exit(Description);
    end;

    local procedure GetLocStateCodeRegForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Code[10]
    var
        State: Record State;
        StateGSTRegNo: Code[10];
    begin
        State.SetRange(Code, GSTR1CDNURQuery.Location_State_Code);
        if State.FindFirst() then
            StateGSTRegNo := State."State Code (GST Reg. No.)";
        exit(StateGSTRegNo)
    end;

    local procedure GetLocStateDesForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Text[50]
    var
        State: Record State;
        Description: Text[50];
    begin
        State.SetRange(Code, GSTR1CDNURQuery.Location_State_Code);
        if State.FindFirst() then
            Description := State.Description;
        exit(Description);
    end;

    local procedure GetDocumentTypeTxt(GSTDocumentType: Enum "GST Document Type"): Text
    begin
        case GSTDocumentType of
            GSTDocumentType::"Credit Memo":
                exit(CLbl);
            GSTDocumentType::Invoice:
                exit(DLbl);
            GSTDocumentType::Refund:
                exit(RLbl);
        end;
    end;

    local procedure MakeExcelHeaderEXEMP()
    begin
        TempExcelBuffer.NewRow();
        AddTextColumn(DespTxt);
        AddTextColumn(NilTxt);
        AddTextColumn(ExmpTxt);
        AddTextColumn(NonGSTxt);
    end;

    local procedure MakeExcelBodyEXEMP()
    begin
        MakeExcelHeaderEXEMP();
        GetInterIntraUnRegAmount();
        GetIntraInterRegAmount();
        GetExmpInterIntraRegAmount();
        GetExmpIntraInterUnRegAmount();
        GetExmpNonGSTInterRegAmt();
        GetExmpNonGSTInterUnRegAmt();

        TempExcelBuffer.NewRow();
        AddTextColumn(InterRegTxt);
        AddNumberColumn(ExpExempInterRegAmt);
        AddNumberColumn(ExempInterRegAmount);
        AddNumberColumn(ExempNonGSTInterRegAmt);

        TempExcelBuffer.NewRow();
        AddTextColumn(IntraRegTxt);
        AddNumberColumn(ExpExempIntraRegAmt);
        AddNumberColumn(ExempIntraRegAmount);
        AddNumberColumn(EXempNonGSTIntraRegAmt);

        TempExcelBuffer.NewRow();
        AddTextColumn(InterUnRegTxt);
        AddNumberColumn(ExpExempInterUnRegAmt);
        AddNumberColumn(ExempCustInterUnRegAmt);
        AddNumberColumn(ExempNonGSTInterUnRegAmt);

        TempExcelBuffer.NewRow();
        AddTextColumn(IntraUnRegTxt);
        AddNumberColumn(ExpExempIntraUnRegAmt);
        AddNumberColumn(ExempCustIntraUnRegAmt);
        AddNumberColumn(ExempNonGSTIntraUnRegAmt);
    end;

    local procedure CheckPreGSTForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        ReferenceInvoiceNo.Reset();
        ReferenceInvoiceNo.SetRange("Document No.", GSTR1CDNRQuery.Document_No_);
        ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR1CDNRQuery.Document_Type));
        ReferenceInvoiceNo.SetRange("Source No.", GSTR1CDNRQuery.Source_No_);
        if not ReferenceInvoiceNo.IsEmpty then
            exit(true);
    end;

    local procedure CheckPreGSTForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        ReferenceInvoiceNo.Reset();
        ReferenceInvoiceNo.SetRange("Document No.", GSTR1CDNURQuery.Document_No_);
        ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR1CDNURQuery.Document_Type));
        ReferenceInvoiceNo.SetRange("Source No.", GSTR1CDNURQuery.Source_No_);
        if not ReferenceInvoiceNo.IsEmpty then
            exit(true);
    end;

    local procedure GetURType(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Text
    begin
        case GSTR1CDNURQuery.GST_Customer_Type of
            GSTR1CDNURQuery.GST_Customer_Type::Unregistered:
                exit(B2CLTxt);
            GSTR1CDNURQuery.GST_Customer_Type::"SEZ Development",
            GSTR1CDNURQuery.GST_Customer_Type::"SEZ Unit",
            GSTR1CDNURQuery.GST_Customer_Type::Export,
            GSTR1CDNURQuery.GST_Customer_Type::"Deemed Export":
                begin
                    if GSTR1CDNURQuery.GST_Without_Payment_of_Duty then
                        exit(UpperCase(EXPWOPayTxt));
                    exit(UpperCase(EXPWPayTxt));
                end;
        end;
    end;

    local procedure GetIntraInterRegAmount()
    var
        GSTR1ExpExemp: Query GSTR1ExpExemp;
    begin
        GSTR1ExpExemp.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ExpExemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ExpExemp.SetRange(GST_Without_Payment_of_Duty, false);
        GSTR1ExpExemp.SetRange(GST_Exempted_Goods, false);
        GSTR1ExpExemp.SetFilter(Document_Type, '%1|%2',
            "GST Document Type"::Invoice,
            "GST Document Type"::"Credit Memo");
        GSTR1ExpExemp.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit",
            "GST Customer Type"::Registered);
        GSTR1ExpExemp.SetFilter(GST__, '=%1', 0);
        GSTR1ExpExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1ExpExemp.Open();
        while GSTR1ExpExemp.Read() do
            ExpExempIntraRegAmt += Abs(GSTR1ExpExemp.GST_Base_Amount / 2);

        GSTR1ExpExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1ExpExemp.Open();
        while GSTR1ExpExemp.Read() do
            ExpExempInterRegAmt += Abs(GSTR1ExpExemp.GST_Base_Amount);
    end;

    local procedure GetInterIntraUnRegAmount()
    var
        GSTR1ExpExemp: Query GSTR1ExpExemp;
    begin
        GSTR1ExpExemp.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ExpExemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ExpExemp.SetRange(GSTR1ExpExemp.GST_Exempted_Goods, false);
        GSTR1ExpExemp.SetFilter(GSTR1ExpExemp.Document_Type, '%1|%2',
            "GST Document Type"::Invoice,
            "GST Document Type"::"Credit Memo");
        GSTR1ExpExemp.SetFilter(GSTR1ExpExemp.GST_Customer_Type, '%1|%2',
            "GST Customer Type"::Unregistered,
            "GST Customer Type"::Export);
        GSTR1ExpExemp.SetFilter(GSTR1ExpExemp.GST__, '=%1', 0);
        GSTR1ExpExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1ExpExemp.Open();
        while GSTR1ExpExemp.Read() do
            ExpExempInterUnRegAmt += Abs(GSTR1ExpExemp.GST_Base_Amount);

        GSTR1ExpExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1ExpExemp.Open();
        while GSTR1ExpExemp.Read() do
            ExpExempIntraUnRegAmt += Abs(GSTR1ExpExemp.GST_Base_Amount / 2);
    end;

    local procedure GetExmpInterIntraRegAmount()
    var
        GSTR1EXEMPQuery: Query GSTR1EXEMPQuery;
    begin
        GSTR1EXEMPQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1EXEMPQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1EXEMPQuery.SetRange(GST_Exempted_Goods, true);
        GSTR1EXEMPQuery.SetFilter(Document_Type, '%1|%2',
            "GST Document Type"::Invoice,
            "GST Document Type"::"Credit Memo");
        GSTR1EXEMPQuery.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit",
            "GST Customer Type"::Registered);
        GSTR1EXEMPQuery.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1EXEMPQuery.Open();
        while GSTR1EXEMPQuery.Read() do
            ExempInterRegAmount += Abs(GSTR1EXEMPQuery.GST_Base_Amount);

        GSTR1EXEMPQuery.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1EXEMPQuery.Open();
        if GSTR1EXEMPQuery.Read() then
            ExempIntraRegAmount += Abs(GSTR1EXEMPQuery.GST_Base_Amount / 2);
    end;

    local procedure GetExmpNonGSTInterRegAmt()
    var
        GSTR1NonGSTExemp: Query GSTR1NonGSTExemp;
        GSTR1NonGSTExempCrMemo: Query GSTR1NonGSTExempCrMemo;
    begin
        GSTR1NonGSTExemp.SetRange(Location_GST_Reg__No_, LocationGSTIN);
        GSTR1NonGSTExemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1NonGSTExemp.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit",
            "GST Customer Type"::Registered);
        GSTR1NonGSTExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1NonGSTExemp.Open();
        while GSTR1NonGSTExemp.Read() do
            ExempNonGSTInterRegAmt += Abs(GSTR1NonGSTExemp.Amount);

        GSTR1NonGSTExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1NonGSTExemp.Open();
        while GSTR1NonGSTExemp.Read() do
            ExempNonGSTIntraRegAmt += Abs(GSTR1NonGSTExemp.Amount);

        GSTR1NonGSTExempCrMemo.SetRange(Location_GST_Reg__No_, LocationGSTIN);
        GSTR1NonGSTExempCrMemo.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1NonGSTExempCrMemo.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit",
            "GST Customer Type"::Registered);
        GSTR1NonGSTExempCrMemo.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1NonGSTExempCrMemo.Open();
        while GSTR1NonGSTExempCrMemo.Read() do
            ExempNonGSTInterRegAmt -= Abs(GSTR1NonGSTExempCrMemo.Amount);

        GSTR1NonGSTExempCrMemo.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1NonGSTExempCrMemo.Open();
        while GSTR1NonGSTExempCrMemo.Read() do
            ExempNonGSTIntraRegAmt -= Abs(GSTR1NonGSTExempCrMemo.Amount);
    end;

    local procedure GetExmpNonGSTInterUnRegAmt()
    var
        GSTR1NonGSTExemp: Query GSTR1NonGSTExemp;
        GSTR1NonGSTExempCrMemo: Query GSTR1NonGSTExempCrMemo;
    begin
        GSTR1NonGSTExemp.SetRange(Location_GST_Reg__No_, LocationGSTIN);
        GSTR1NonGSTExemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1NonGSTExemp.SetFilter(GST_Customer_Type, '%1|%2',
            "GST Customer Type"::Unregistered,
            "GST Customer Type"::Export);
        GSTR1NonGSTExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1NonGSTExemp.Open();
        while GSTR1NonGSTExemp.Read() do
            ExempNonGSTInterUnRegAmt += Abs(GSTR1NonGSTExemp.Amount);

        GSTR1NonGSTExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1NonGSTExemp.Open();
        while GSTR1NonGSTExemp.Read() do
            ExempNonGSTIntraUnRegAmt += Abs(GSTR1NonGSTExemp.Amount);

        GSTR1NonGSTExempCrMemo.SetRange(Location_GST_Reg__No_, LocationGSTIN);
        GSTR1NonGSTExempCrMemo.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1NonGSTExempCrMemo.SetFilter(GST_Customer_Type, '%1|%2',
            "GST Customer Type"::Unregistered,
            "GST Customer Type"::Export);
        GSTR1NonGSTExempCrMemo.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1NonGSTExempCrMemo.Open();
        while GSTR1NonGSTExempCrMemo.Read() do
            ExempNonGSTInterUnRegAmt -= Abs(GSTR1NonGSTExempCrMemo.Amount);

        GSTR1NonGSTExempCrMemo.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1NonGSTExempCrMemo.Open();
        while GSTR1NonGSTExempCrMemo.Read() do
            ExempNonGSTIntraUnRegAmt -= Abs(GSTR1NonGSTExempCrMemo.Amount);
    end;

    local procedure GetExmpIntraInterUnRegAmount()
    var
        GSTR1EXEMPQuery: Query GSTR1EXEMPQuery;
    begin
        GSTR1EXEMPQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1EXEMPQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1EXEMPQuery.SetRange(GST_Exempted_Goods, true);
        GSTR1EXEMPQuery.SetFilter(Document_Type, '%1|%2',
            "GST Document Type"::Invoice,
            "GST Document Type"::"Credit Memo");
        GSTR1EXEMPQuery.SetFilter(GST_Customer_Type, '%1|%2',
            "GST Customer Type"::Unregistered,
            "GST Customer Type"::Export);
        GSTR1EXEMPQuery.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1EXEMPQuery.Open();
        if GSTR1EXEMPQuery.Read() then
            ExempCustIntraUnRegAmt += Abs(GSTR1EXEMPQuery.GST_Base_Amount / 2);

        GSTR1EXEMPQuery.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1EXEMPQuery.Open();
        if GSTR1EXEMPQuery.Read() then
            ExempCustInterUnRegAmt += Abs(GSTR1EXEMPQuery.GST_Base_Amount);
    end;

    local procedure GetInvoiceTypeforTransferShip(GSTR1B2BSalesTranship: Query GSTR1B2BSalesTranship): Text[50]
    begin
        case GSTR1B2BSalesTranship.GST_Customer_Type of
            GSTR1B2BSalesTranship.GST_Customer_Type::Registered:
                exit(RegularTxt);
            GSTR1B2BSalesTranship.GST_Customer_Type::"SEZ Development", GSTR1B2BSalesTranship.GST_Customer_Type::"SEZ Unit":
                begin
                    if GSTR1B2BSalesTranship.GST_Without_Payment_of_Duty then
                        exit(SEZWOPayTxt);
                    exit(SEZWPayTxt);
                end;
            GSTR1B2BSalesTranship.GST_Customer_Type::"Deemed Export":
                exit(DeemedExportTxt);
        end;
    end;

    local procedure GetInvoiceType(GSTR1B2BQuery: Query GSTR1B2BQuery): Text[50]
    begin
        case GSTR1B2BQuery.GST_Customer_Type of
            GSTR1B2BQuery.GST_Customer_Type::Registered:
                exit(RegularTxt);
            GSTR1B2BQuery.GST_Customer_Type::"SEZ Development", GSTR1B2BQuery.GST_Customer_Type::"SEZ Unit":
                begin
                    if GSTR1B2BQuery.GST_Without_Payment_of_Duty then
                        exit(SEZWOPayTxt);
                    exit(SEZWPayTxt);
                end;
            GSTR1B2BQuery.GST_Customer_Type::"Deemed Export":
                exit(DeemedExportTxt);
        end;
    end;

    local procedure GetInvoiceValue(DocumentNo: Code[20]; DocumentType: Enum "GST Document Type"): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", GSTDocumentType2GenJnlDocumentType(DocumentType));
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        if CustLedgerEntry.FindFirst() then
            CustLedgerEntry.CalcFields("Amount (LCY)");
        exit(Abs(CustLedgerEntry."Amount (LCY)"));
    end;

    local procedure GetInvoiceValueForExportCustomerType(DocumentNo: Code[20]; DocumentType: Enum "GST Document Type"): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", GSTDocumentType2GenJnlDocumentType(DocumentType));
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        if CustLedgerEntry.FindFirst() then
            exit(Abs(CustLedgerEntry."Sales (LCY)"));
    end;

    local procedure GSTDocumentType2GenJnlDocumentType(GSTDocumentType: Enum "GST Document Type"): Enum "Gen. Journal Document Type"
    begin
        case GSTDocumentType of
            GSTDocumentType::" ":
                exit("Gen. Journal Document Type"::" ");
            GSTDocumentType::Payment:
                exit("Gen. Journal Document Type"::Payment);
            GSTDocumentType::Invoice:
                exit("Gen. Journal Document Type"::Invoice);
            GSTDocumentType::"Credit Memo":
                exit("Gen. Journal Document Type"::"Credit Memo");
            GSTDocumentType::Refund:
                exit("Gen. Journal Document Type"::Refund);
        end;
    end;

    local procedure GetDocumentDate(DocumentNo: Code[20]; DocumentType: Enum "GST Document Type"): Date
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", GSTDocumentType2GenJnlDocumentType(DocumentType));
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        if CustLedgerEntry.FindFirst() then
            exit(CustLedgerEntry."Document Date");
    end;

    local procedure GetInvoiceValueFinCharge(DocumentNo: Code[20]): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Finance Charge Memo");
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        if CustLedgerEntry.FindFirst() then
            CustLedgerEntry.CalcFields("Amount (LCY)");
        exit(Abs(CustLedgerEntry."Amount (LCY)"));
    end;

    local procedure CreateandOpenExcel(FileFormatTxt: Text[250])
    begin
        TempExcelBuffer.CreateNewBook(FileFormatTxt);
        TempExcelBuffer.WriteSheet(FileFormatTxt, CompanyName(), UserId());
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.OpenExcel();
    end;

    local procedure AddTextColumn(Value: Text)
    begin
        TempExcelBuffer.AddColumn(Value, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure AddDateColumn(Value: Date)
    begin
        TempExcelBuffer.AddColumn(Value, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
    end;

    local procedure AddNumberColumn(Value: Decimal)
    begin
        TempExcelBuffer.AddColumn(Value, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

}

