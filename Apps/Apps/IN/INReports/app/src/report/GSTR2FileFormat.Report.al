// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using System.IO;
using System.Utilities;

report 18050 "GSTR_2 File Format"
{
    Caption = 'GSTR-2 File Format';
    ProcessingOnly = true;
    UseRequestPage = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem(Integer; Integer)
        {
            dataItemTableView = sorting(Number)
                                where(Number = const(1));
            trigger OnAfterGetRecord()
            begin
                case TypeOfSupply of
                    TypeOfSupply::B2B:
                        begin
                            MakeExcelBodyB2B();
                            createbookandopenExcel(B2BTxt);
                        end;
                    TypeOfSupply::IMPS:
                        begin
                            MakeExcelBodyIMPS();
                            createbookandopenExcel(IMPSTxt);
                        end;
                    TypeOfSupply::IMPG:
                        begin
                            MakeExcelBodyIMPG();
                            createbookandopenExcel(IMPGTxt);
                        end;

                    TypeOfSupply::B2BUR:
                        begin
                            MakeExcelBodyB2BUR();
                            createbookandopenExcel(B2BURTxt);
                        end;
                    TypeOfSupply::CDNR:
                        begin
                            MakeExcelBodyCDNR();
                            createbookandopenExcel(CDNRTxt);
                        end;
                    TypeOfSupply::CDNUR:
                        begin
                            MakeExcelBodyCDNUR();
                            createbookandopenExcel(CDNURTxt);
                        end;
                    TypeOfSupply::AT:
                        begin
                            MakeExcelBodyAT();
                            createbookandopenExcel(ATTxt);
                        end;
                    TypeOfSupply::EXEMP:
                        begin
                            MakeExcelHeaderEXEMP();
                            CreateExcelBufferExemp();
                            createbookandopenExcel(EXEMPTxt);
                        end;
                    TypeOfSupply::ATADJ:
                        begin
                            MakeExcelBodyATADJ();
                            createbookandopenExcel(ATADJTxt);
                        end;
                    TypeOfSupply::HSNSUM:
                        begin
                            MakeExcelBodyHSNSUM();
                            createbookandopenExcel(HSNSUMTxt);
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
                        Caption = 'GSTIN of the location';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the GST registration number for which the report will be generated.';
                        TableRelation = "GST Registration Nos.".Code;
                    }
                    field(Date; TransactionDate)
                    {
                        Caption = 'Date';
                        ApplicationArea = all;
                        ToolTip = 'Specifies the date for which the GST of the month will be generated';

                        trigger OnValidate()
                        begin
                            StartDate := CalcDate('<-CM>', TransactionDate);
                            EndDate := CalcDate('<+CM>', TransactionDate);
                        end;
                    }
                    field(FileFormat; TypeofSupply)
                    {
                        Caption = 'File Format';
                        ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                        ApplicationArea = all;
                    }
                }
            }
        }
    }
    trigger OnPostReport()
    begin
        TempExcelBuffer.OpenExcel();
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        StartDate: Date;
        EndDate: Date;
        TransactionDate: Date;
        TypeOfSupply: Enum "Type of Supply";
        GSTBaseAmtIntra: Decimal;
        GSTBaseAmtInter: Decimal;

        DocumentNumber: Text;
        //GstRate: Integer;
        B2BTxt: Label 'B2B';
        IMPSTxt: Label 'IMPS';
        IMPGTxt: Label 'IMPG';
        B2BURTxt: Label 'B2BUR';
        CDNRTxt: Label 'CDNR';
        CDNURTxt: Label 'CDNUR';
        ATTxt: Label 'AT';
        EXEMPTxt: Label 'EXEMP';
        ATADJTxt: Label 'ATADJ';
        HSNSUMTxt: Label 'HSN SUM';
        GSTINUINTxt: Label 'GSTIN of Supplier';
        InvoiceNoTxt: Label 'Invoice Number';
        InvoiceDateTxt: Label 'Invoice Date';
        InvoiceValueTxt: Label 'Invoice Value';
        InvoiceTypeTxt: Label 'Invoice Type';
        InvoiceNoRegTxt: Label 'Invoice Number Of Reg Recipient';
        SupplyTypeTxt: Label 'Supply Type';
        SupplierNameTxt: Label 'Supplier Name';
        PlaceofSupplyTxt: Label 'Place of Supply';
        ReverseChargeTxt: Label 'Reverse Charge';
        RateTxt: Label 'Rate';
        PortCodeTxt: Label 'Port Code';
        RefundVoucherNoTxt: Label 'Note/Refund Voucher Number';
        NoteVoucherNoTxt: Label 'Note/Voucher Number';
        NoteVoucherDateTxt: Label 'Note/Voucher Date';
        RefundVoucherDateTxt: Label 'Note/Refund Voucher Date';
        InvVoucherNoTxt: Label 'Invoice/Advance Payment Voucher Number';
        InvVoucherDateTxt: Label 'Invoice/Advance Payment Voucher Date';
        PreGSTTxt: Label 'Pre GST';
        ReasonForIssuingNoteTxt: Label 'Reason For Issuing Document';
        RefundVoucherValueTxt: Label 'Refund Voucher Value';
        BillOfEntryNoTxt: Label 'Bill Of Entry Number';
        BillOfEntryValueTxt: Label 'Bill Of Entry Value';
        BillOfEntryDateTxt: Label 'Bill Of Entry Date';
        DocumentTypeTxt: Label 'Document Type';
        GSTINSEZTxt: Label 'GSTIN Of SEZ Supplier';
        TaxableValueTxt: Label 'Taxable Value';
        GrossAdvancePaidTxt: Label 'Gross Advance Paid';
        GrossAdvanceAdjustedTxt: Label 'Gross Advance Paid To Be Adjusted';
        CessAdjustedTxt: Label 'Cess Adjusted';
        IntegratedTaxPaidTxt: Label 'Integrated Tax Paid';
        IntegratedTaxAmtTxt: Label 'Integrated Tax Amount';
        CentralTaxPaidTxt: Label 'Central Tax Paid';
        CentralTaxAmtTxt: Label 'Central Tax Amount';
        StateTaxPaidTxt: Label 'State/UT Tax Paid';
        StateTaxAmtTxt: Label 'State/UT Tax Amount';
        CessPaidTxt: Label 'Cess Paid';
        CessAmountTxt: Label 'Cess Amount';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        CessLbl: Label 'CESS';
        RegularTxt: Label 'Regular';
        YTxt: Label 'Y';
        NTxt: Label 'N';
        CTxt: Label 'C';
        DTxt: Label 'D';
        RTxt: Label 'R';
        SEZWOPayTxt: Label 'SEZ Without Pay';
        SEZWPayTxt: Label 'SEZ With Pay';
        EligibilityITCTxt: Label 'Eligibility for ITC';
        AvailedItcIntegratedTaxTxt: Label 'Availed ITC Integrated Tax';
        AvailedITCCentralTaxTxt: Label 'Availed ITC Central Tax';
        AvailedITCStateTaxTxt: Label 'Availed ITC State/UT Tax';
        AvailedITCCessTxt: Label 'Availed ITC Cess';
        DescriptionTxt: Label 'Description';
        CompTaxablePersonTxt: Label 'Composition Taxable Person';
        NilRatedSuppliesTxt: Label 'Nil Rated Supply';
        ExemptedTxt: Label 'Exmpted (other than Nil Rated/ non-GST supplies)';
        NonGSTSuppliesTxt: Label 'Non GST Supplies';
        HSNSACofSupplyTxt: Label 'HSN/SAC Of Supply';
        UQCTxt: Label 'UQC';
        TotalQtyTxt: Label 'Total Quantity';
        TotalValTxt: Label 'Total Value';
        LocationGSTIN: Code[15];
        PurchaseInterAmt: Decimal;
        PurchaseIntraAmt: Decimal;
        CGSTAmount: Decimal;
        IGSTAmount: Decimal;
        SGSTAmount: Decimal;
        CESSAmount: Decimal;
        TotalValue: Decimal;

    local procedure MakeExcelHeaderB2B()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTINUINTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ReverseChargeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(IntegratedTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CentralTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(StateTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(EligibilityITCTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCIntegratedTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCentralTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCStateTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCessTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyB2B()
    var
        GSTR2B2BQuery: Query GSTR2B2BQuery;
    begin
        MakeExcelHeaderB2B();
        GSTR2B2BQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2B2BQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2B2BQuery.SetFilter(GST_Vendor_Type, '%1|%2', "GST Vendor Type"::Registered, "GST Vendor Type"::SEZ);
        GSTR2B2BQuery.SetFilter(GST_Group_Type, '%1|%2', "GST Group Type"::Goods, "GST Group Type"::Service);
        GSTR2B2BQuery.SetFilter(GST__, '<> %1', 0);
        GSTR2B2BQuery.Open();
        while GSTR2B2BQuery.Read() do
            if (GSTR2B2BQuery.GST_Vendor_Type = GSTR2B2BQuery.GST_Vendor_Type::Registered) then begin
                if (GSTR2B2BQuery.Reverse_Charge = true) and (GSTR2B2BQuery.Entry_Type = GSTR2B2BQuery.Entry_Type::Application) then
                    CreateExcelBufferB2B(GSTR2B2BQuery)
                else
                    if (GSTR2B2BQuery.Reverse_Charge = false) and (GSTR2B2BQuery.Entry_Type = GSTR2B2BQuery.Entry_Type::"Initial Entry") then
                        CreateExcelBufferB2B(GSTR2B2BQuery);
            end else
                if (GSTR2B2BQuery.GST_Vendor_Type = GSTR2B2BQuery.GST_Vendor_Type::SEZ) and (GSTR2B2BQuery.GST_Group_Type = GSTR2B2BQuery.GST_Group_Type::Goods) and (GSTR2B2BQuery.Without_Bill_Of_Entry = true) then begin
                    if (GSTR2B2BQuery.Reverse_Charge = true) and (GSTR2B2BQuery.Entry_Type = GSTR2B2BQuery.Entry_Type::Application) then
                        CreateExcelBufferB2B(GSTR2B2BQuery)
                    else
                        if (GSTR2B2BQuery.Reverse_Charge = false) and (GSTR2B2BQuery.Entry_Type = GSTR2B2BQuery.Entry_Type::"Initial Entry") then
                            CreateExcelBufferB2B(GSTR2B2BQuery);
                end else
                    if (GSTR2B2BQuery.GST_Vendor_Type = GSTR2B2BQuery.GST_Vendor_Type::SEZ) and (GSTR2B2BQuery.GST_Group_Type = GSTR2B2BQuery.GST_Group_Type::Service) then
                        if (GSTR2B2BQuery.Reverse_Charge = true) and (GSTR2B2BQuery.Entry_Type = GSTR2B2BQuery.Entry_Type::Application) then
                            CreateExcelBufferB2B(GSTR2B2BQuery)
                        else
                            if (GSTR2B2BQuery.Reverse_Charge = false) and (GSTR2B2BQuery.Entry_Type = GSTR2B2BQuery.Entry_Type::"Initial Entry") then
                                CreateExcelBufferB2B(GSTR2B2BQuery);
    end;

    Local procedure CreateExcelBufferB2B(GSTR2B2BQuery: Query GSTR2B2BQuery)
    var
        State: Record State;
        GSTR2GSTPer: Query GSTR2GSTPer;
        GSTR2BaseAmt: Query GSTR2BaseAmt;
        GSTR2IGST: Query GSTR2IGST;
        GSTR2CGSTAmt: Query GSTR2CGSTAmt;
        GSTR2SGSTAmt: Query GSTR2SGSTAmt;
        CessAmt: Decimal;
        CessAmountCrAvailed: Decimal;
        pDate: Date;
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTR2B2BQuery.Buyer_Seller_Reg__No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR2B2BQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GetPostingDateImps(pDate, GSTR2B2BQuery.Document_No_);
        if pDate = 0D then
            pDate := GSTR2B2BQuery.Posting_Date;
        TempExcelBuffer.AddColumn(pDate, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
        TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR2B2BQuery.Document_No_, "GST Document Type"::Invoice), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        if State.Get(GSTR2B2BQuery.Buyer_Seller_State_Code) then
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR2B2BQuery.Reverse_Charge then
            TempExcelBuffer.AddColumn(YTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn(NTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn(GetInvoiceType(GSTR2B2BQuery), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2GSTPer.TopNumberOfRows(1);
        GSTR2GSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2GSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2GSTPer.SetRange(Document_No_, GSTR2B2BQuery.Document_No_);
        GSTR2GSTPer.Open();
        while GSTR2GSTPer.Read() do
            if GSTR2GSTPer.GST_Jurisdiction_Type = GSTR2GSTPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR2B2BQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR2B2BQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2BaseAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2BaseAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2BaseAmt.SetRange(Document_No_, GSTR2B2BQuery.Document_No_);
        GSTR2BaseAmt.Open();
        while GSTR2BaseAmt.Read() do
            if GSTR2BaseAmt.GST_Jurisdiction_Type = GSTR2BaseAmt.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(Abs(GSTR2B2BQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(Abs(GSTR2B2BQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2IGST.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IGST.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IGST.SetRange(Document_No_, GSTR2B2BQuery.Document_No_);
        GSTR2IGST.SetRange(GST_Vendor_Type, GSTR2B2BQuery.GST_Vendor_Type);
        GSTR2IGST.SetRange(Eligibility_for_ITC, GSTR2B2BQuery.Eligibility_for_ITC);
        GSTR2IGST.SetRange(GST__, GSTR2B2BQuery.GST__);
        GSTR2IGST.Open();
        if GSTR2IGST.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2IGST.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2CGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CGSTAmt.SetRange(Document_No_, GSTR2B2BQuery.Document_No_);
        GSTR2CGSTAmt.SetRange(GST_Vendor_Type, GSTR2B2BQuery.GST_Vendor_Type);
        GSTR2CGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BQuery.Eligibility_for_ITC);
        GSTR2CGSTAmt.SetRange(GST__, GSTR2B2BQuery.GST__);
        GSTR2CGSTAmt.Open();
        if GSTR2CGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2SGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2SGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2SGSTAmt.SetRange(Document_No_, GSTR2B2BQuery.Document_No_);
        GSTR2SGSTAmt.SetRange(GST_Vendor_Type, GSTR2B2BQuery.GST_Vendor_Type);
        GSTR2SGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BQuery.Eligibility_for_ITC);
        GSTR2SGSTAmt.SetRange(GST__, GSTR2B2BQuery.GST__);
        GSTR2SGSTAmt.Open();
        if GSTR2SGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2SGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        CessAmt := GetCessAmt(GSTR2B2BQuery.Document_No_, GSTR2B2BQuery.GST__);
        if (CessAmt <> 0) then
            TempExcelBuffer.AddColumn(Abs(CessAmount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.AddColumn(GSTR2B2BQuery.Eligibility_for_ITC, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2IGST.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IGST.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IGST.SetRange(Document_No_, GSTR2B2BQuery.Document_No_);
        GSTR2IGST.SetRange(GST_Vendor_Type, GSTR2B2BQuery.GST_Vendor_Type);
        GSTR2IGST.SetRange(Eligibility_for_ITC, GSTR2B2BQuery.Eligibility_for_ITC);
        GSTR2IGST.SetRange(GST__, GSTR2B2BQuery.GST__);
        GSTR2IGST.SetRange(Credit_Availed, true);
        GSTR2IGST.Open();
        if GSTR2IGST.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2IGST.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CGSTAmt.SetRange(Document_No_, GSTR2B2BQuery.Document_No_);
        GSTR2CGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BQuery.Eligibility_for_ITC);
        GSTR2CGSTAmt.SetRange(GST_Vendor_Type, GSTR2B2BQuery.GST_Vendor_Type);
        GSTR2CGSTAmt.SetRange(GST__, GSTR2B2BQuery.GST__);
        GSTR2CGSTAmt.SetRange(Credit_Availed, true);
        GSTR2CGSTAmt.Open();
        if GSTR2CGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2SGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2SGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2SGSTAmt.SetRange(Document_No_, GSTR2B2BQuery.Document_No_);
        GSTR2SGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BQuery.Eligibility_for_ITC);
        GSTR2SGSTAmt.SetRange(GST_Vendor_Type, "GST Vendor Type"::Registered, "GST Vendor Type"::SEZ);
        GSTR2SGSTAmt.SetRange(GST__, GSTR2B2BQuery.GST__);
        GSTR2SGSTAmt.SetRange(Credit_Availed, true);
        GSTR2SGSTAmt.Open();
        if GSTR2SGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2SGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        CessAmountCrAvailed := GetCessAmtCreditAvailed(GSTR2B2BQuery.Document_No_, GSTR2B2BQuery.GST__);
        if (CessAmountCrAvailed <> 0) then
            TempExcelBuffer.AddColumn(Abs(CessAmountCrAvailed), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);


    end;

    local procedure GetInvoiceType(GSTR2B2BQuery: Query GSTR2B2BQuery): Text[50]
    begin
        case GSTR2B2BQuery.GST_Vendor_Type of
            GSTR2B2BQuery.GST_Vendor_Type::Registered:
                exit(RegularTxt);
            GSTR2B2BQuery.GST_Vendor_Type::SEZ:
                begin
                    if GSTR2B2BQuery.GST_Without_Payment_of_Duty then
                        exit(SEZWOPayTxt);
                    exit(SEZWPayTxt);
                end;
        end;
    end;

    local procedure GetInvoiceValue(DocumentNo: Code[20]; DocumentType: Enum "GST Document Type"): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Document Type", DocumentType);
        VendorLedgerEntry.SetRange("Document No.", DocumentNo);
        if VendorLedgerEntry.FindFirst() then
            VendorLedgerEntry.CalcFields("Amount (LCY)");
        exit(Abs(VendorLedgerEntry."Amount (LCY)"));
    end;

    local procedure MakeExcelHeaderIMPS()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(InvoiceNoRegTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SupplyTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(IntegratedTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(EligibilityITCTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCIntegratedTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCessTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;



    local procedure MakeExcelBodyIMPS()
    var
        GSTR2IMPSQuery: Query GSTR2IMPSQuery;
    begin
        MakeExcelHeaderIMPS();
        GSTR2IMPSQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IMPSQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IMPSQuery.SetRange(GST_Vendor_Type, "GST Vendor Type"::Import);
        GSTR2IMPSQuery.SetRange(GST_Group_Type, "GST Group Type"::Service);
        GSTR2IMPSQuery.SetFilter(Entry_Type, '%1|%2', "Detail Ledger Entry Type"::Application, "Detail Ledger Entry Type"::"Initial Entry");
        GSTR2IMPSQuery.SetRange(UnApplied, false);
        GSTR2IMPSQuery.Open();
        while GSTR2IMPSQuery.Read() do
            if (GSTR2IMPSQuery.Reverse_Charge = true) and (GSTR2IMPSQuery.Entry_Type = GSTR2IMPSQuery.Entry_Type::Application) then
                CreateExcelBufferIMPS(GSTR2IMPSQuery)
            else
                if (GSTR2IMPSQuery.Reverse_Charge = false) and (GSTR2IMPSQuery.Entry_Type = GSTR2IMPSQuery.Entry_Type::"Initial Entry") then
                    CreateExcelBufferIMPS(GSTR2IMPSQuery);
    end;

    local procedure CreateExcelBufferIMPS(GSTR2IMPSQuery: Query GSTR2IMPSQuery)
    var
        State: Record State;
        GSTR2GSTPer: Query GSTR2GSTPer;
        GSTR2BaseAmt: Query GSTR2BaseAmt;
        GSTR2IMPSIGSTAmt: Query GSTR2IMPSIGSTAmt;
        GSTR2CessAmt: Query GSTR2CessAmt;
        pDate: Date;
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTR2IMPSQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GetPostingDateImps(pDate, GSTR2IMPSQuery.Document_No_);
        if pDate = 0D then
            pDate := GSTR2IMPSQuery.Posting_Date;
        TempExcelBuffer.AddColumn(pDate, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);

        TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR2IMPSQuery.Document_No_, "GST Document Type"::Invoice), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        if (GSTR2IMPSQuery.GST_Vendor_Type = GSTR2IMPSQuery.GST_Vendor_Type::SEZ) then
            if State.Get(GSTR2IMPSQuery.Buyer_Seller_State_Code) then
                TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
            else
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            State.Get(GSTR2IMPSQuery.Location_State_Code);
        if ((GSTR2IMPSQuery.GST_Vendor_Type = GSTR2IMPSQuery.GST_Vendor_Type::Import)) then
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn(GSTR2IMPSQuery.GST_Jurisdiction_Type, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2GSTPer.TopNumberOfRows(1);
        GSTR2GSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2GSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2GSTPer.SetRange(Document_No_, GSTR2IMPSQuery.Document_No_);
        GSTR2GSTPer.Open();
        if GSTR2GSTPer.Read() then
            if GSTR2GSTPer.GST_Jurisdiction_Type = GSTR2GSTPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR2IMPSQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR2IMPSQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2BaseAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2BaseAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2BaseAmt.SetRange(Document_No_, GSTR2IMPSQuery.Document_No_);
        GSTR2BaseAmt.Open();
        if GSTR2BaseAmt.Read() then
            if GSTR2BaseAmt.GST_Jurisdiction_Type = GSTR2BaseAmt.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(Abs(GSTR2IMPSQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(Abs(GSTR2IMPSQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2IMPSIGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IMPSIGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IMPSIGSTAmt.SetRange(Document_No_, GSTR2IMPSQuery.Document_No_);
        GSTR2IMPSIGSTAmt.SetFilter(GST_Vendor_Type, '%1|%2', "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2IMPSIGSTAmt.SetRange(Eligibility_for_ITC, GSTR2IMPSQuery.Eligibility_for_ITC);
        GSTR2IMPSIGSTAmt.SetRange(GST__, GSTR2IMPSQuery.GST__);
        GSTR2IMPSIGSTAmt.Open();
        if GSTR2IMPSIGSTAmt.Read() then
            TempExcelBuffer.AddColumn(GSTR2IMPSIGSTAmt.GST_Amount, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CessAmt.SetRange(Document_No_, GSTR2IMPSQuery.Document_No_);
        GSTR2CessAmt.SetFilter(GST_Vendor_Type, '%1|%2', "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2CessAmt.SetRange(Eligibility_for_ITC, GSTR2IMPSQuery.Eligibility_for_ITC);
        GSTR2CessAmt.Open();
        if GSTR2CessAmt.Read() then
            TempExcelBuffer.AddColumn(GSTR2CessAmt.GST_Amount, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.AddColumn(GSTR2IMPSQuery.Eligibility_for_ITC, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2IMPSIGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IMPSIGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IMPSIGSTAmt.SetRange(Document_No_, GSTR2IMPSQuery.Document_No_);
        GSTR2IMPSIGSTAmt.SetFilter(GST_Vendor_Type, '%1|%2', "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2IMPSIGSTAmt.SetRange(Eligibility_for_ITC, GSTR2IMPSQuery.Eligibility_for_ITC);
        GSTR2IMPSIGSTAmt.SetRange(GST__, GSTR2IMPSQuery.GST__);
        GSTR2IMPSIGSTAmt.SetRange(Credit_Availed, true);
        GSTR2IMPSIGSTAmt.Open();
        if GSTR2IMPSIGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2IMPSIGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CessAmt.SetRange(Document_No_, GSTR2IMPSQuery.Document_No_);
        GSTR2CessAmt.SetFilter(GST_Vendor_Type, '%1|%2', "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2CessAmt.SetRange(Eligibility_for_ITC, GSTR2IMPSQuery.Eligibility_for_ITC);
        GSTR2CessAmt.SetRange(Credit_Availed, true);
        GSTR2CessAmt.Open();
        if GSTR2CessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure GetPostingDateIMPS(var PostingDate: date; DocNo: Code[20])
    var
        DtldGSTLedgeEntry: Record "Detailed GST Ledger Entry";
        GSTR2IMPSQuery: Query GSTR2IMPSQuery;
    begin
        DtldGSTLedgeEntry.Reset();
        DtldGSTLedgeEntry.SetRange("Document No.", DocNo);
        if DtldGSTLedgeEntry.FindFirst() then
            if (DtldGSTLedgeEntry."Entry Type" = DtldGSTLedgeEntry."Entry Type"::"Initial Entry") then
                PostingDate := DtldGSTLedgeEntry."Posting Date"
            else
                PostingDate := GSTR2IMPSQuery.Posting_Date;
    end;

    local procedure MakeExcelHeaderIMPG()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(PortCodeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(BillOfEntryNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(BillOfEntryDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(BillOfEntryValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DocumentTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTINSEZTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(IntegratedTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(EligibilityITCTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCIntegratedTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCessTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyIMPG()
    var
        GSTR2IMPGQuery: Query GSTR2IMPGQuery;
    begin
        MakeExcelHeaderIMPG();
        GSTR2IMPGQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IMPGQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IMPGQuery.SetFilter(GST_Vendor_Type, '%1|%2', "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2IMPGQuery.SetRange(GST_Group_Type, "GST Group Type"::Goods);
        GSTR2IMPGQuery.Open();
        while GSTR2IMPGQuery.Read() do
            if (GSTR2IMPGQuery.GST_Vendor_Type = GSTR2IMPGQuery.GST_Vendor_Type::Import) then
                CreateExcelBufferIMPG(GSTR2IMPGQuery)
            else
                if (GSTR2IMPGQuery.GST_Vendor_Type = GSTR2IMPGQuery.GST_Vendor_Type::SEZ) and (GSTR2IMPGQuery.Without_Bill_Of_Entry = false) then
                    CreateExcelBufferIMPG(GSTR2IMPGQuery);
    end;

    local procedure GetCessAmt(DocumentNo: code[20]; GstRate: Decimal): Decimal
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryCess: Record "Detailed GST Ledger Entry";
        CessAmt: Decimal;
        DocLineNo: Integer;
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("GST %", GstRate);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if DocLineNo <> DetailedGSTLedgerEntry."Document Line No." then begin
                    DocLineNo := DetailedGSTLedgerEntry."Document Line No.";
                    DetailedGSTLedgerEntryCess.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
                    DetailedGSTLedgerEntryCess.SetRange("Document Line No.", DetailedGSTLedgerEntry."Document Line No.");
                    DetailedGSTLedgerEntryCess.SetFilter("Entry No.", '<>%1', DetailedGSTLedgerEntry."Entry No.");
                    DetailedGSTLedgerEntryCess.SetRange("GST Component Code", CessLbl);
                    if DetailedGSTLedgerEntryCess.FindSet() then
                        repeat
                            CessAmt += DetailedGSTLedgerEntryCess."GST Amount";
                        until DetailedGSTLedgerEntryCess.Next() = 0;
                end;
            until DetailedGSTLedgerEntry.Next() = 0;
        exit(CessAmt);
    end;

    local procedure GetCessAmtCreditAvailed(DocumentNo: code[20]; GstRate: Decimal): Decimal
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryCess: Record "Detailed GST Ledger Entry";
        CessAmt: Decimal;
        DocLineNo: Integer;
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("GST %", GstRate);
        DetailedGSTLedgerEntry.SetRange("Credit Availed", true);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if DocLineNo <> DetailedGSTLedgerEntry."Document Line No." then begin
                    DocLineNo := DetailedGSTLedgerEntry."Document Line No.";
                    DetailedGSTLedgerEntryCess.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
                    DetailedGSTLedgerEntryCess.SetRange("Document Line No.", DetailedGSTLedgerEntry."Document Line No.");
                    DetailedGSTLedgerEntryCess.SetFilter("Entry No.", '<>%1', DetailedGSTLedgerEntry."Entry No.");
                    DetailedGSTLedgerEntryCess.SetRange("GST Component Code", CessLbl);
                    if DetailedGSTLedgerEntryCess.FindSet() then
                        repeat
                            CessAmt += DetailedGSTLedgerEntryCess."GST Amount";
                        until DetailedGSTLedgerEntryCess.Next() = 0;
                end;
            until DetailedGSTLedgerEntry.Next() = 0;
        exit(CessAmt);
    end;

    local procedure CreateExcelBufferIMPG(GSTR2IMPGQuery: Query GSTR2IMPGQuery)
    var
        PurchaseHeader: Record "Purchase Header";
        GSTR2GSTper: Query GSTR2GSTPer;
        GSTR2IMPGBaseAmt: Query GSTR2IMPGBaseAmt;
        GSTR2IMPSIGSTAmt: Query GSTR2IMPSIGSTAmt;
        CessAmt: Decimal;
        CessAmountCrAvailed: Decimal;
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(PurchaseHeader."Entry Point", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR2IMPGQuery.Bill_of_Entry_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(GSTR2IMPGQuery.Bill_of_Entry_Date, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
        TempExcelBuffer.AddColumn(GetBillOfEntryValue(GSTR2IMPGQuery.Document_No_), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(GSTR2IMPGQuery.GST_Vendor_Type, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR2IMPGQuery.Buyer_Seller_Reg__No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2GSTPer.TopNumberOfRows(1);
        GSTR2GSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2GSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2GSTPer.SetRange(Document_No_, GSTR2IMPGQuery.Document_No_);
        GSTR2GSTPer.Open();
        while GSTR2GSTPer.Read() do begin
            if GSTR2GSTPer.GST_Jurisdiction_Type = GSTR2GSTPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR2IMPGQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR2IMPGQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GSTR2GSTper.Close();
        end;

        GSTR2IMPGBaseAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IMPGBaseAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IMPGBaseAmt.SetRange(Document_No_, GSTR2IMPGQuery.Document_No_);
        GSTR2IMPGBaseAmt.SetRange(GST__, GSTR2IMPGQuery.GST__);
        GSTR2IMPGBaseAmt.Open();
        while GSTR2IMPGBaseAmt.Read() do
            if GSTR2IMPGBaseAmt.GST_Jurisdiction_Type = GSTR2IMPGBaseAmt.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(Abs(GSTR2IMPGQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(Abs(GSTR2IMPGQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2IMPSIGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IMPSIGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IMPSIGSTAmt.SetRange(Document_No_, GSTR2IMPGQuery.Document_No_);
        GSTR2IMPSIGSTAmt.SetRange(GST_Vendor_Type, GSTR2IMPGQuery.GST_Vendor_Type);
        GSTR2IMPSIGSTAmt.SetRange(Eligibility_for_ITC, GSTR2IMPGQuery.Eligibility_for_ITC);
        GSTR2IMPSIGSTAmt.SetRange(GST__, GSTR2IMPGQuery.GST__);
        GSTR2IMPSIGSTAmt.Open();
        if GSTR2IMPSIGSTAmt.Read() then
            TempExcelBuffer.AddColumn(GSTR2IMPSIGSTAmt.GST_Amount, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        CessAmt := GetCessAmt(GSTR2IMPGQuery.Document_No_, GSTR2IMPGQuery.GST__);
        if (CessAmt <> 0) then
            TempExcelBuffer.AddColumn(CessAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.AddColumn(GSTR2IMPGQuery.Eligibility_for_ITC, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2IMPSIGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IMPSIGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IMPSIGSTAmt.SetRange(Document_No_, GSTR2IMPGQuery.Document_No_);
        GSTR2IMPSIGSTAmt.SetRange(GST_Vendor_Type, GSTR2IMPGQuery.GST_Vendor_Type);
        GSTR2IMPSIGSTAmt.SetRange(GST__, GSTR2IMPGQuery.GST__);
        GSTR2IMPSIGSTAmt.SetRange(Eligibility_for_ITC, GSTR2IMPGQuery.Eligibility_for_ITC);
        GSTR2IMPSIGSTAmt.SetRange(Credit_Availed, true);
        GSTR2IMPSIGSTAmt.Open();
        if GSTR2IMPSIGSTAmt.Read() then
            TempExcelBuffer.AddColumn(GSTR2IMPSIGSTAmt.GST_Amount, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        CessAmountCrAvailed := GetCessAmtCreditAvailed(GSTR2IMPGQuery.Document_No_, GSTR2IMPGQuery.GST__);
        if (CessAmountCrAvailed <> 0) then
            TempExcelBuffer.AddColumn(CessAmountCrAvailed, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure GetBillOfEntryValue(DocumentNo: Code[20]): Decimal
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.SetRange("No.", DocumentNo);
        if PurchInvHeader.FindFirst() then
            PurchInvHeader.CalcSums("Bill of Entry Value");
        exit(Abs(PurchInvHeader."Bill of Entry Value"));
    end;

    local procedure MakeExcelHeaderB2BUR()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(SupplierNameTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SupplyTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(IntegratedTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CentralTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(StateTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(EligibilityITCTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCIntegratedTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCentralTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCStateTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCessTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyB2BUR()
    var
        GSTR2B2BURQuery: Query GSTR2B2BURQuery;
    begin
        MakeExcelHeaderB2BUR();
        GSTR2B2BURQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2B2BURQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2B2BURQuery.SetFilter(GST_Vendor_Type, '%1', "GST Vendor Type"::Unregistered);
        GSTR2B2BURQuery.SetFilter(Entry_Type, '%1|%2', "Detail Ledger Entry Type"::"Initial Entry", "Detail Ledger Entry Type"::Application);
        GSTR2B2BURQuery.Open();
        while GSTR2B2BURQuery.Read() do
            if (GSTR2B2BURQuery.Reverse_Charge = true) and (GSTR2B2BURQuery.Entry_Type = GSTR2B2BURQuery.Entry_Type::Application) then
                CreateExcelBufferB2BUR(GSTR2B2BURQuery)
            else
                if (GSTR2B2BURQuery.Reverse_Charge = false) and (GSTR2B2BURQuery.Entry_Type = GSTR2B2BURQuery.Entry_Type::"Initial Entry") then
                    CreateExcelBufferB2BUR(GSTR2B2BURQuery);
    end;

    local procedure CreateExcelBufferB2BUR(GSTR2B2BURQuery: Query GSTR2B2BURQuery)
    var
        GSTR2GSTPer: Query GSTR2GSTPer;
        GSTR2BaseAmt: Query GSTR2BaseAmt;
        GSTR2IGSTAmt: Query GSTR2IGST;
        GSTR2CGSTAmt: Query GSTR2CGSTAmt;
        GSTR2SGSTAmt: Query GSTR2SGSTAmt;
        GSTR2CessAmt: Query GSTR2CessAmt;
        pDate: Date;
    begin
        TempExcelBuffer.NewRow();
        if GSTR2B2BURQuery.Source_No_ <> '' then
            TempExcelBuffer.AddColumn(GSTR2B2BURQuery.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn(GSTR2B2BURQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GetPostingDateImps(pDate, GSTR2B2BURQuery.Document_No_);
        if pDate = 0D then
            pDate := GSTR2B2BURQuery.Posting_Date;
        TempExcelBuffer.AddColumn(pDate, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);

        TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR2B2BURQuery.Document_No_, "GST Document Type"::Invoice), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        if GSTR2B2BURQuery.Buyer_Seller_State_Code <> '' then
            TempExcelBuffer.AddColumn(GSTR2B2BURQuery.State_Code__GST_Reg__No__ + '-' + GSTR2B2BURQuery.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn(GSTR2B2BURQuery.GST_Jurisdiction_Type, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2GSTPer.TopNumberOfRows(1);
        GSTR2GSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2GSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2GSTPer.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2GSTPer.Open();
        while GSTR2GSTPer.Read() do
            if GSTR2GSTPer.GST_Jurisdiction_Type = GSTR2GSTPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR2B2BURQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR2B2BURQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2BaseAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2BaseAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2BaseAmt.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2BaseAmt.Open();
        while GSTR2BaseAmt.Read() do
            if GSTR2BaseAmt.GST_Jurisdiction_Type = GSTR2BaseAmt.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(Abs(GSTR2B2BURQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(Abs(GSTR2B2BURQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2IGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IGSTAmt.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2IGSTAmt.SetRange(GST_Vendor_Type, GSTR2B2BURQuery.GST_Vendor_Type);
        GSTR2IGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BURQuery.Eligibility_for_ITC);
        GSTR2IGSTAmt.SetRange(GST__, GSTR2B2BURQuery.GST__);
        GSTR2IGSTAmt.Open();
        if GSTR2IGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2IGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CGSTAmt.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2CGSTAmt.SetRange(GST_Vendor_Type, GSTR2B2BURQuery.GST_Vendor_Type);
        GSTR2CGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BURQuery.Eligibility_for_ITC);
        GSTR2CGSTAmt.SetRange(GST__, GSTR2B2BURQuery.GST__);
        GSTR2CGSTAmt.Open();
        if GSTR2CGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2SGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2SGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2SGSTAmt.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2SGSTAmt.SetRange(GST_Vendor_Type, GSTR2B2BURQuery.GST_Vendor_Type);
        GSTR2SGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BURQuery.Eligibility_for_ITC);
        GSTR2SGSTAmt.SetRange(GST__, GSTR2B2BURQuery.GST__);
        GSTR2SGSTAmt.Open();
        if GSTR2SGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2SGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CessAmt.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2CessAmt.SetRange(GST_Vendor_Type, GSTR2B2BURQuery.GST_Vendor_Type);
        GSTR2CessAmt.SetRange(Eligibility_for_ITC, GSTR2B2BURQuery.Eligibility_for_ITC);
        GSTR2CessAmt.Open();
        if GSTR2CessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.AddColumn(GSTR2B2BURQuery.Eligibility_for_ITC, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2IGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IGSTAmt.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2IGSTAmt.SetRange(GST_Vendor_Type, GSTR2B2BURQuery.GST_Vendor_Type);
        GSTR2IGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BURQuery.Eligibility_for_ITC);
        GSTR2IGSTAmt.SetRange(GST__, GSTR2B2BURQuery.GST__);
        GSTR2IGSTAmt.SetRange(Credit_Availed, true);
        GSTR2IGSTAmt.Open();
        if GSTR2IGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2IGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CGSTAmt.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2CGSTAmt.SetRange(GST_Vendor_Type, GSTR2B2BURQuery.GST_Vendor_Type);
        GSTR2CGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BURQuery.Eligibility_for_ITC);
        GSTR2CGSTAmt.SetRange(GST__, GSTR2B2BURQuery.GST__);
        GSTR2CGSTAmt.SetRange(Credit_Availed, true);
        GSTR2CGSTAmt.Open();
        if GSTR2CGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2SGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2SGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2SGSTAmt.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2SGSTAmt.SetRange(GST_Vendor_Type, GSTR2B2BURQuery.GST_Vendor_Type);
        GSTR2SGSTAmt.SetRange(Eligibility_for_ITC, GSTR2B2BURQuery.Eligibility_for_ITC);
        GSTR2SGSTAmt.SetRange(GST__, GSTR2B2BURQuery.GST__);
        GSTR2SGSTAmt.SetRange(Credit_Availed, true);
        GSTR2SGSTAmt.Open();
        if GSTR2SGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2SGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CessAmt.SetRange(Document_No_, GSTR2B2BURQuery.Document_No_);
        GSTR2CessAmt.SetRange(GST_Vendor_Type, GSTR2B2BURQuery.GST_Vendor_Type);
        GSTR2CessAmt.SetRange(Eligibility_for_ITC, GSTR2B2BURQuery.Eligibility_for_ITC);
        GSTR2CessAmt.SetRange(Credit_Availed, true);
        GSTR2CessAmt.Open();
        if GSTR2CessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure CreateBookandOpenExcel(FileFormatTxt: Text[250])
    begin
        TempExcelBuffer.CreateNewBook(FileFormatTxt);
        TempExcelBuffer.WriteSheet(FileFormatTxt, CompanyName(), UserId());
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.OpenExcel();
    end;

    local procedure MakeExcelHeaderCDNR()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTINUINTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RefundVoucherNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RefundVoucherDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvVoucherNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvVoucherDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PreGSTTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DocumentTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ReasonForIssuingNoteTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SupplyTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RefundVoucherValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(IntegratedTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CentralTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(StateTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(EligibilityITCTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCIntegratedTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCentralTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCStateTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCessTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

    end;



    local procedure MakeExcelBodyCDNR()
    var
        GSTR2CDNRQuery: Query GSTR2CDNRQuery;
    begin
        MakeExcelHeaderCDNR();
        GSTR2CDNRQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CDNRQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CDNRQuery.SetFilter(GST_Vendor_Type, '%1|%2', "GST Vendor Type"::Registered, "GST Vendor Type"::SEZ);
        GSTR2CDNRQuery.SetFilter(Document_Type, '%1|%2|%3', "GST Document Type"::Invoice, "GST Document Type"::Refund, "GST Document Type"::"Credit Memo");
        GSTR2CDNRQuery.Open();
        while GSTR2CDNRQuery.Read() do
            if (GSTR2CDNRQuery.Document_Type = GSTR2CDNRQuery.Document_Type::"Credit Memo")
                or (GSTR2CDNRQuery.Document_Type = GSTR2CDNRQuery.Document_Type::Refund)
                or (GSTR2CDNRQuery.Document_Type = GSTR2CDNRQuery.Document_Type::Invoice) and (GSTR2CDNRQuery.Purchase_Invoice_Type = GSTR2CDNRQuery.Purchase_Invoice_Type::"Debit Note") or (GSTR2CDNRQuery.Purchase_Invoice_Type = GSTR2CDNRQuery.Purchase_Invoice_Type::Supplementary) then
                if (GSTR2CDNRQuery.Reverse_Charge = true) and (GSTR2CDNRQuery.Entry_Type = GSTR2CDNRQuery.Entry_Type::Application) then
                    CreateExcelBufferCDNR(GSTR2CDNRQuery)
                else
                    if (GSTR2CDNRQuery.Reverse_Charge = false) and (GSTR2CDNRQuery.Entry_Type = GSTR2CDNRQuery.Entry_Type::"Initial Entry") then
                        CreateExcelBufferCDNR(GSTR2CDNRQuery);
    end;

    local procedure CreateExcelBufferCDNR(GSTR2CDNRQuery: Query GSTR2CDNRQuery)
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        GSTR2GSTPer: Query GSTR2GSTPer;
        GSTR2IGSTAmt: Query GSTR2IGST;
        GSTR2CGSTAmt: Query GSTR2CGSTAmt;
        GSTR2SGSTAmt: Query GSTR2SGSTAmt;
        GSTR2CessAmt: Query GSTR2CessAmt;
        CessAmt: Decimal;
        CessAmountCrAvailed: Decimal;

    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTR2CDNRQuery.Buyer_Seller_Reg__No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR2CDNRQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR2CDNRQuery.Posting_Date, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);

        if (GSTR2CDNRQuery.Document_Type in [GSTR2CDNRQuery.Document_Type::"Credit Memo", GSTR2CDNRQuery.Document_Type::Invoice]) then begin
            ReferenceInvoiceNo.Reset();
            ReferenceInvoiceNo.SetRange("Document No.", GSTR2CDNRQuery.Document_No_);
            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR2CDNRQuery.Document_Type));
            ReferenceInvoiceNo.SetRange("Source No.", GSTR2CDNRQuery.Source_No_);
            if ReferenceInvoiceNo.FindFirst() then begin
                TempExcelBuffer.AddColumn(ReferenceInvoiceNo."Reference Invoice Nos.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(GetPostingDate(ReferenceInvoiceNo), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            end else begin
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            end;
        end;

        TempExcelBuffer.AddColumn(NTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        case GSTR2CDNRQuery.Document_Type of
            GSTR2CDNRQuery.Document_Type::"Credit Memo":
                TempExcelBuffer.AddColumn(CTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            GSTR2CDNRQuery.Document_Type::Refund:
                TempExcelBuffer.AddColumn(RTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            GSTR2CDNRQuery.Document_Type::Invoice:
                TempExcelBuffer.AddColumn(DTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        end;
        TempExcelBuffer.AddColumn(GSTR2CDNRQuery.GST_Reason_Type, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR2CDNRQuery.GST_Jurisdiction_Type, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR2CDNRQuery.Document_Type in [GSTR2CDNRQuery.Document_Type::Invoice, GSTR2CDNRQuery.Document_Type::"Credit Memo"] then
            if GSTR2CDNRQuery.Finance_Charge_Memo then
                TempExcelBuffer.AddColumn(GetInvoiceValueFinCharge(GSTR2CDNRQuery.Document_No_), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR2CDNRQuery.Document_No_, GSTR2CDNRQuery.Document_Type), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR2CDNRQuery.GST_Base_Amount) + Abs(GSTR2CessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2GSTPer.TopNumberOfRows(1);
        GSTR2GSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2GSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2GSTPer.SetRange(Document_No_, GSTR2CDNRQuery.Document_No_);
        GSTR2GSTPer.Open();
        if GSTR2GSTPer.Read() then
            if GSTR2GSTPer.GST_Jurisdiction_Type = GSTR2GSTPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR2CDNRQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR2CDNRQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        if GSTR2CDNRQuery.GST_Jurisdiction_Type = GSTR2CDNRQuery.GST_Jurisdiction_Type::Intrastate then
            TempExcelBuffer.AddColumn(Abs(GSTR2CDNRQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR2CDNRQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2IGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IGSTAmt.SetRange(Document_No_, GSTR2CDNRQuery.Document_No_);
        GSTR2IGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNRQuery.Eligibility_for_ITC);
        GSTR2IGSTAmt.SetRange(GST__, GSTR2CDNRQuery.GST__);
        GSTR2IGSTAmt.Open();
        if GSTR2IGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2IGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2CGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CGSTAmt.SetRange(Document_No_, GSTR2CDNRQuery.Document_No_);
        GSTR2CGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNRQuery.Eligibility_for_ITC);
        GSTR2CGSTAmt.SetRange(GST__, GSTR2CDNRQuery.GST__);
        GSTR2CGSTAmt.Open();
        if GSTR2CGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2SGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2SGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2SGSTAmt.SetRange(Document_No_, GSTR2CDNRQuery.Document_No_);
        GSTR2SGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNRQuery.Eligibility_for_ITC);
        GSTR2SGSTAmt.SetRange(GST__, GSTR2CDNRQuery.GST__);
        GSTR2SGSTAmt.Open();
        if GSTR2SGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2SGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        CessAmt := GetCessAmt(GSTR2CDNRQuery.Document_No_, GSTR2CDNRQuery.GST__);
        if (CessAmt <> 0) then
            TempExcelBuffer.AddColumn(Abs(CessAmt), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.AddColumn(GSTR2CDNRQuery.Eligibility_for_ITC, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2IGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IGSTAmt.SetRange(Document_No_, GSTR2CDNRQuery.Document_No_);
        GSTR2IGSTAmt.SetRange(Credit_Availed, true);
        GSTR2IGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNRQuery.Eligibility_for_ITC);
        GSTR2IGSTAmt.SetRange(GST__, GSTR2CDNRQuery.GST__);
        GSTR2IGSTAmt.Open();
        if GSTR2IGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2IGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CGSTAmt.SetRange(Document_No_, GSTR2CDNRQuery.Document_No_);
        GSTR2CGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNRQuery.Eligibility_for_ITC);
        GSTR2CGSTAmt.SetRange(Credit_Availed, true);
        GSTR2CGSTAmt.Open();
        if GSTR2CGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2SGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2SGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2SGSTAmt.SetRange(Document_No_, GSTR2CDNRQuery.Document_No_);
        GSTR2SGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNRQuery.Eligibility_for_ITC);
        GSTR2SGSTAmt.SetRange(Credit_Availed, true);
        GSTR2SGSTAmt.Open();
        if GSTR2SGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2SGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        CessAmountCrAvailed := GetCessAmtCreditAvailed(GSTR2CDNRQuery.Document_No_, GSTR2CDNRQuery.GST__);
        if (CessAmountCrAvailed <> 0) then
            TempExcelBuffer.AddColumn(Abs(CessAmountCrAvailed), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure GetPostingDate(var ReferenceInvoiceNo: Record "Reference Invoice No."): Date
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
        PostingDate: Date;
    begin
        VendLedgerEntry.SetRange("Vendor No.", ReferenceInvoiceNo."Source No.");
        VendLedgerEntry.SetFilter("Document Type", '%1|%2', VendLedgerEntry."Document Type"::Invoice, VendLedgerEntry."Document Type"::"Credit Memo");
        VendLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
        if VendLedgerEntry.FindFirst() then
            PostingDate := VendLedgerEntry."Posting Date";
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

    local procedure GetInvoiceValueFinCharge(DocumentNo: Code[20]): Decimal
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::"Finance Charge Memo");
        VendLedgerEntry.SetRange("Document No.", DocumentNo);
        if VendLedgerEntry.FindFirst() then
            VendLedgerEntry.CalcFields("Amount (LCY)");
        exit(Abs(VendLedgerEntry."Amount (LCY)"));
    end;

    local procedure MakeExcelHeaderCDNUR()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(NoteVoucherNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(NoteVoucherDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvVoucherNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvVoucherDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PreGSTTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DocumentTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ReasonForIssuingNoteTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SupplyTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RefundVoucherValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(IntegratedTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CentralTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(StateTaxPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessPaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(EligibilityITCTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCIntegratedTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCentralTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCStateTaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AvailedITCCessTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyCDNUR()
    var

        GSTR2CDNURQuery: Query GSTR2CDNURQuery;
    begin
        MakeExcelHeaderCDNUR();
        GSTR2CDNURQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CDNURQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CDNURQuery.SetFilter(GST_Vendor_Type, '%1|%2', "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import);
        GSTR2CDNURQuery.SetFilter(Document_Type, '%1|%2|%3', "GST Document Type"::Invoice, "GST Document Type"::Refund, "GST Document Type"::"Credit Memo");
        GSTR2CDNURQuery.Open();
        while GSTR2CDNURQuery.Read() do
            if (GSTR2CDNURQuery.Document_Type = GSTR2CDNURQuery.Document_Type::"Credit Memo")
                or (GSTR2CDNURQuery.Document_Type = GSTR2CDNURQuery.Document_Type::Refund)
                or (GSTR2CDNURQuery.Document_Type = GSTR2CDNURQuery.Document_Type::Invoice) and (GSTR2CDNURQuery.Purchase_Invoice_Type = GSTR2CDNURQuery.Purchase_Invoice_Type::"Debit Note") or (GSTR2CDNURQuery.Purchase_Invoice_Type = GSTR2CDNURQuery.Purchase_Invoice_Type::Supplementary) then
                if (GSTR2CDNURQuery.Reverse_Charge = true) and (GSTR2CDNURQuery.Entry_Type = GSTR2CDNURQuery.Entry_Type::Application) then
                    CreateExcelBufferCDNUR(GSTR2CDNURQuery)
                else
                    if (GSTR2CDNURQuery.Reverse_Charge = false) and (GSTR2CDNURQuery.Entry_Type = GSTR2CDNURQuery.Entry_Type::"Initial Entry") then
                        CreateExcelBufferCDNUR(GSTR2CDNURQuery)
                    else
                        if (GSTR2CDNURQuery.Reverse_Charge = true) and (GSTR2CDNURQuery.Entry_Type = GSTR2CDNURQuery.Entry_Type::"Initial Entry") then
                            CreateExcelBufferCDNUR(GSTR2CDNURQuery);
    end;

    local procedure CreateExcelBufferCDNUR(GSTR2CDNURQuery: Query GSTR2CDNURQuery)
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTR2GSTPer: Query GSTR2GSTPer;
        GSTR2IGSTAmt: Query GSTR2IGST;
        GSTR2CGSTAmt: Query GSTR2CGSTAmt;
        GSTR2SGSTAmt: Query GSTR2SGSTAmt;
        GSTR2CessAmt: Query GSTR2CessAmt;
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTR2CDNURQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR2CDNURQuery.Posting_Date, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);

        if (GSTR2CDNURQuery.Document_Type in [GSTR2CDNURQuery.Document_Type::"Credit Memo", GSTR2CDNURQuery.Document_Type::Invoice]) then begin
            ReferenceInvoiceNo.Reset();
            ReferenceInvoiceNo.SetRange("Document No.", GSTR2CDNURQuery.Document_No_);
            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR2CDNURQuery.Document_Type));
            ReferenceInvoiceNo.SetRange("Source No.", GSTR2CDNURQuery.Source_No_);
            if ReferenceInvoiceNo.FindFirst() then begin
                TempExcelBuffer.AddColumn(ReferenceInvoiceNo."Reference Invoice Nos.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(GetPostingDate(ReferenceInvoiceNo), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            end else begin
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            end;
        end;

        TempExcelBuffer.AddColumn(NTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        case GSTR2CDNURQuery.Document_Type of
            GSTR2CDNURQuery.Document_Type::"Credit Memo":
                TempExcelBuffer.AddColumn(CTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            GSTR2CDNURQuery.Document_Type::Refund:
                TempExcelBuffer.AddColumn(RTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            GSTR2CDNURQuery.Document_Type::Invoice:
                TempExcelBuffer.AddColumn(DTxt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        end;

        TempExcelBuffer.AddColumn(GSTR2CDNURQuery.GST_Reason_Type, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR2CDNURQuery.GST_Jurisdiction_Type, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GetGSTAmount(DetailedGSTLedgerEntry);
        if (GSTR2CDNURQuery.Document_Type = GSTR2CDNURQuery.Document_Type::"Credit Memo") or (GSTR2CDNURQuery.Document_Type = GSTR2CDNURQuery.Document_Type::Refund) then
            TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR2CDNURQuery.Document_No_, GSTR2CDNURQuery.Document_Type) + (GetGSTAmount(DetailedGSTLedgerEntry)), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs((GetGSTAmount(DetailedGSTLedgerEntry)) + GetInvoiceValue(GSTR2CDNURQuery.Document_No_, GSTR2CDNURQuery.Document_Type)), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);


        GSTR2GSTPer.TopNumberOfRows(1);
        GSTR2GSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2GSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2GSTPer.SetRange(Document_No_, GSTR2CDNURQuery.Document_No_);
        GSTR2GSTPer.Open();
        while GSTR2GSTPer.Read() do
            if GSTR2GSTPer.GST_Jurisdiction_Type = GSTR2GSTPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR2CDNURQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR2CDNURQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        if GSTR2CDNURQuery.GST_Jurisdiction_Type = GSTR2CDNURQuery.GST_Jurisdiction_Type::Intrastate then
            TempExcelBuffer.AddColumn(Abs(GSTR2CDNURQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR2CDNURQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2IGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IGSTAmt.SetRange(Document_No_, GSTR2CDNURQuery.Document_No_);
        GSTR2IGSTAmt.SetFilter(GST_Vendor_Type, '%1|%2|%3', "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2IGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNURQuery.Eligibility_for_ITC);
        GSTR2IGSTAmt.SetRange(GST__, GSTR2CDNURQuery.GST__);
        GSTR2IGSTAmt.Open();
        if GSTR2IGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2IGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2CGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CGSTAmt.SetRange(Document_No_, GSTR2CDNURQuery.Document_No_);
        GSTR2CGSTAmt.SetFilter(GST_Vendor_Type, '%1|%2|%3', "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2CGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNURQuery.Eligibility_for_ITC);
        GSTR2CGSTAmt.SetRange(GST__, GSTR2CDNURQuery.GST__);
        GSTR2CGSTAmt.Open();
        if GSTR2CGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2SGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2SGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2SGSTAmt.SetRange(Document_No_, GSTR2CDNURQuery.Document_No_);
        GSTR2SGSTAmt.SetFilter(GST_Vendor_Type, '%1|%2|%3', "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2SGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNURQuery.Eligibility_for_ITC);
        GSTR2SGSTAmt.SetRange(GST__, GSTR2CDNURQuery.GST__);
        GSTR2SGSTAmt.Open();
        if GSTR2SGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2SGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR2CessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CessAmt.SetRange(Document_No_, GSTR2CDNURQuery.Document_No_);
        GSTR2CessAmt.SetFilter(GST_Vendor_Type, '%1|%2|%3', "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2CessAmt.SetRange(Eligibility_for_ITC, GSTR2CDNURQuery.Eligibility_for_ITC);
        GSTR2CessAmt.Open();
        if GSTR2CessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.AddColumn(GSTR2CDNURQuery.Eligibility_for_ITC, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR2IGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2IGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2IGSTAmt.SetRange(Document_No_, GSTR2CDNURQuery.Document_No_);
        GSTR2IGSTAmt.SetFilter(GST_Vendor_Type, '%1|%2|%3', "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2IGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNURQuery.Eligibility_for_ITC);
        GSTR2IGSTAmt.SetRange(GST__, GSTR2CDNURQuery.GST__);
        GSTR2IGSTAmt.SetRange(Credit_Availed, true);
        GSTR2IGSTAmt.Open();
        if GSTR2IGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2IGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CGSTAmt.SetRange(Document_No_, GSTR2CDNURQuery.Document_No_);
        GSTR2CGSTAmt.SetFilter(GST_Vendor_Type, '%1|%2|%3', "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2CGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNURQuery.Eligibility_for_ITC);
        GSTR2CGSTAmt.SetRange(GST__, GSTR2CDNURQuery.GST__);
        GSTR2CGSTAmt.SetRange(Credit_Availed, true);
        GSTR2CGSTAmt.Open();
        if GSTR2CGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2SGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2SGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2SGSTAmt.SetRange(Document_No_, GSTR2CDNURQuery.Document_No_);
        GSTR2SGSTAmt.SetFilter(GST_Vendor_Type, '%1|%2|%3', "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2SGSTAmt.SetRange(Eligibility_for_ITC, GSTR2CDNURQuery.Eligibility_for_ITC);
        GSTR2SGSTAmt.SetRange(GST__, GSTR2CDNURQuery.GST__);
        GSTR2SGSTAmt.SetRange(Credit_Availed, true);
        GSTR2SGSTAmt.Open();
        if GSTR2SGSTAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2SGSTAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR2CessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2CessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2CessAmt.SetRange(Document_No_, GSTR2CDNURQuery.Document_No_);
        GSTR2CessAmt.SetFilter(GST_Vendor_Type, '%1|%2|%3', "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        GSTR2CessAmt.SetRange(Eligibility_for_ITC, GSTR2CDNURQuery.Eligibility_for_ITC);
        GSTR2CessAmt.SetRange(Credit_Availed, true);
        GSTR2CessAmt.Open();
        if GSTR2CessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR2CessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure GetGSTAmount(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"): Decimal
    var
        DetailedGSTLedgEntry: Record "Detailed GST Ledger Entry";
    begin
        Clear(IGSTAmount);
        Clear(CGSTAmount);
        Clear(SGSTAmount);
        Clear(CESSAmount);
        Clear(TotalValue);
        DetailedGSTLedgEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type");
        DetailedGSTLedgEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type");
        DetailedGSTLedgEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type");
        DetailedGSTLedgEntry.SetRange("GST Vendor Type", DetailedGSTLedgerEntry."GST Vendor Type");
        DetailedGSTLedgEntry.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
        DetailedGSTLedgEntry.SetRange("GST %", DetailedGSTLedgerEntry."GST %");
        if DetailedGSTLedgEntry.FindSet() then
            repeat
                if (DetailedGSTLedgEntry."GST Component Code" = 'IGST') then
                    IGSTAmount += (DetailedGSTLedgEntry."GST Amount");
                if (DetailedGSTLedgEntry."GST Component Code" = 'CGST') then
                    CGSTAmount += (DetailedGSTLedgEntry."GST Amount");
                if (DetailedGSTLedgEntry."GST Component Code" = 'SGST') then
                    SGSTAmount += (DetailedGSTLedgEntry."GST Amount");
                if (DetailedGSTLedgEntry."GST Component Code" = 'Cess') then
                    CESSAmount += (DetailedGSTLedgEntry."GST Amount");

                TotalValue := (IGSTAmount + CGSTAmount + SGSTAmount + CESSAmount);
            until DetailedGSTLedgEntry.Next() = 0;
        exit(TotalValue);
    end;

    local procedure MakeExcelHeaderAT()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GrossAdvancePaidTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyAT()
    begin
        MakeExcelHeaderAT();
        SetFilterforATQueryforIntrastate();
        SetFilterforATQueryforInterstate();
    end;

    local procedure FillExcelBodyAT(GSTR2ATQuery: Query GSTR2ATQuery)
    var
        State: Record State;
        GSTBaseAmtInters: Decimal;
    begin
        GSTR2ATQuery.SetRange(GST__, 18);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do begin
            TempExcelBuffer.NewRow();
            State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            if GSTR2ATQuery.GST_Component_Code = CessLbl then
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GSTR2ATQuery.Close();
        end;

        Clear(GSTBaseAmtInters);
        Clear(GSTBaseAmtInter);
        GSTR2ATQuery.SetRange(GST__, 18);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtInters := GetBaseAmountforPaymentType(GSTR2ATQuery.Document_No_);
        if GSTBaseAmtInters <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtInters), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 12);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do begin
            TempExcelBuffer.NewRow();
            State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            if GSTR2ATQuery.GST_Component_Code = CessLbl then
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GSTR2ATQuery.Close();
        end;

        Clear(GSTBaseAmtInters);
        Clear(GSTBaseAmtInter);
        GSTR2ATQuery.SetRange(GST__, 12);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtInters := GetBaseAmountforPaymentType(GSTR2ATQuery.Document_No_);
        if GSTBaseAmtInters <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtInters), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 5);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do begin
            TempExcelBuffer.NewRow();
            State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            if GSTR2ATQuery.GST_Component_Code = CessLbl then
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GSTR2ATQuery.Close();
        end;

        Clear(GSTBaseAmtInters);
        Clear(GSTBaseAmtInter);
        GSTR2ATQuery.SetRange(GST__, 5);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtInters := GetBaseAmountforPaymentType(GSTR2ATQuery.Document_No_);
        if GSTBaseAmtInters <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtInters), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 28);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do begin
            TempExcelBuffer.NewRow();
            State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            if GSTR2ATQuery.GST_Component_Code = CessLbl then
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GSTR2ATQuery.Close();
        end;

        Clear(GSTBaseAmtInter);
        Clear(GSTBaseAmtInters);
        GSTR2ATQuery.SetRange(GST__, 28);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtInters := GetBaseAmountforPaymentType(GSTR2ATQuery.Document_No_);
        if GSTBaseAmtInters <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtInters), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();
    end;

    local procedure CreateExcelBodyATIntra(GSTR2ATQuery: Query GSTR2ATQuery)
    var
        State: Record State;
        GSTBaseAmtIntras: Decimal;
    begin
        GSTR2ATQuery.SetRange(GST__, 9);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do begin
            TempExcelBuffer.NewRow();
            State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(2 * GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            if GSTR2ATQuery.GST_Component_Code = CessLbl then
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GSTR2ATQuery.Close();
        end;

        Clear(GSTBaseAmtIntras);
        Clear(GSTBaseAmtIntra);
        GSTR2ATQuery.SetRange(GST__, 9);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtIntras := GetBaseAmountforPaymentType(GSTR2ATQuery.Document_No_);
        if GSTBaseAmtIntras <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtIntras), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 6);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do begin
            TempExcelBuffer.NewRow();
            State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(2 * GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            if GSTR2ATQuery.GST_Component_Code = CessLbl then
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GSTR2ATQuery.Close();
        end;

        Clear(GSTBaseAmtIntras);
        Clear(GSTBaseAmtIntra);
        GSTR2ATQuery.SetRange(GST__, 6);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtIntras := GetBaseAmountforPaymentType(GSTR2ATQuery.Document_No_);
        if GSTBaseAmtIntras <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtIntras), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 2.5);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do begin
            TempExcelBuffer.NewRow();
            State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(2 * GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            if GSTR2ATQuery.GST_Component_Code = CessLbl then
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GSTR2ATQuery.Close();
        end;

        Clear(GSTBaseAmtIntras);
        Clear(GSTBaseAmtIntra);
        GSTR2ATQuery.SetRange(GST__, 2.5);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtIntras := GetBaseAmountforPaymentType(GSTR2ATQuery.Document_No_);
        if GSTBaseAmtIntras <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtIntras), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 14);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do begin
            TempExcelBuffer.NewRow();
            State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(2 * GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            if GSTR2ATQuery.GST_Component_Code = CessLbl then
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GSTR2ATQuery.Close();
        end;

        Clear(GSTBaseAmtIntras);
        Clear(GSTBaseAmtIntra);
        GSTR2ATQuery.SetRange(GST__, 14);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtIntras := GetBaseAmountforPaymentType(GSTR2ATQuery.Document_No_);
        if GSTBaseAmtIntras <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtIntras), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();
    end;

    local procedure SetFilterforATQueryforIntrastate()
    var
        GSTR2ATQuery: Query GSTR2ATQuery;
    begin
        GSTR2ATQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2ATQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2ATQuery.SetRange(GST_on_Advance_Payment, true);
        GSTR2ATQuery.SetRange(Paid, true);
        GSTR2ATQuery.SetRange(GST_Jurisdiction_Type, "GST Jurisdiction Type"::Intrastate);
        GSTR2ATQuery.SetRange(GST_Component_Code, CGSTLbl);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            CreateExcelBodyATIntra(GSTR2ATQuery);
    end;

    local procedure SetFilterforATQueryforInterstate()
    var
        GSTR2ATQuery: Query GSTR2ATQuery;
    begin
        GSTR2ATQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2ATQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2ATQuery.SetRange(GST_on_Advance_Payment, true);
        GSTR2ATQuery.SetRange(Paid, true);
        GSTR2ATQuery.SetRange(GSTR2ATQuery.GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            FillExcelBodyAT(GSTR2ATQuery);
    end;

    local procedure MakeExcelHeaderEXEMP()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(DescriptionTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CompTaxablePersonTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ExemptedTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(NilRatedSuppliesTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(NonGSTSuppliesTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure CreateExcelBufferExemp()
    var
        GSTR2Exemp: Query GSTR2Exemp;
        GSTBaseAmt: Decimal;
    begin
        //Composition for Intrastate
        Clear(PurchaseInterAmt);
        Clear(PurchaseIntraAmt);
        Clear(GSTBaseAmt);
        GSTR2Exemp.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2Exemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2Exemp.SetRange(GST_Jurisdiction_Type, "GST Jurisdiction Type"::Intrastate);
        GSTR2Exemp.SetRange(GST_Vendor_Type, "GST Vendor Type"::Composite);
        GSTR2Exemp.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR2Exemp.SetFilter(GST__, '<> %1', 0);
        GSTR2Exemp.Open();
        while GSTR2Exemp.Read() do
            GSTBaseAmt := GetPurchaseValue(GSTR2Exemp.Document_No_);
        GSTR2Exemp.Close();
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn("GST Jurisdiction Type"::Intrastate, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTBaseAmt, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        //Exempted for intrastate
        Clear(PurchaseInterAmt);
        Clear(PurchaseIntraAmt);
        Clear(GSTBaseAmt);
        GSTR2Exemp.SetRange(GST_Exempted_Goods, true);
        GSTR2Exemp.Open();
        while GSTR2Exemp.Read() do
            GSTBaseAmt := GetPurchaseValue(GSTR2Exemp.Document_No_);
        GSTR2Exemp.Close();
        TempExcelBuffer.AddColumn(GSTBaseAmt, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        NilRatedSupplisforIntrastate();
    end;

    local procedure NilRatedSupplisforIntrastate()
    var
        GSTR2Exemp: Query GSTR2Exemp;
        GSTBaseAmt: Decimal;
    begin
        //Nil Rated for intrastate
        Clear(PurchaseInterAmt);
        Clear(PurchaseIntraAmt);
        Clear(GSTBaseAmt);
        GSTR2Exemp.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2Exemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2Exemp.SetRange(GST_Jurisdiction_Type, "GST Jurisdiction Type"::Intrastate);
        GSTR2Exemp.SetFilter(GST_Vendor_Type, '%1|%2',
                             "GST Vendor Type"::Registered,
                             "GST Vendor Type"::Unregistered);
        GSTR2Exemp.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR2Exemp.SetRange(GST__, 0);
        GSTR2Exemp.Open();
        while GSTR2Exemp.Read() do
            GSTBaseAmt := GetPurchaseValue(GSTR2Exemp.Document_No_);
        GSTR2Exemp.Close();
        TempExcelBuffer.AddColumn(GSTBaseAmt, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        NonGSTSuppliesforIntrastate();
    end;

    //Non- GST Supplies intrastate
    local procedure NonGSTSuppliesforIntrastate()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        GSTBaseAmount: Decimal;
        GSTBaseAmount1: Decimal;
    begin
        Clear(PurchaseInterAmt);
        Clear(PurchaseIntraAmt);
        Clear(GSTBaseAmount);
        PurchInvHeader.Reset();
        PurchInvHeader.SetRange("Location GST Reg. No.", LocationGSTIN);
        PurchInvHeader.SetRange("Posting Date", StartDate, EndDate);
        if PurchInvHeader.FindSet() then
            repeat
                PurchInvLine.Reset();
                PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                PurchInvLine.SetRange("GST Jurisdiction Type", PurchInvLine."GST Jurisdiction Type"::Intrastate);
                PurchInvLine.SetRange("GST Group Code", '');
                if PurchInvLine.FindSet() then
                    repeat
                        GSTBaseAmount1 := GetPurchaseValueforNonGstSupplies(PurchInvLine."Document No.");
                    until PurchInvLine.Next() = 0;
            until PurchInvHeader.Next() = 0;

        PurchCrMemoHdr.Reset();
        PurchCrMemoHdr.SetRange("Location GST Reg. No.", LocationGSTIN);
        PurchCrMemoHdr.SetRange("Posting Date", StartDate, EndDate);
        if PurchCrMemoHdr.FindSet() then
            repeat
                PurchCrMemoLine.Reset();
                PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
                PurchCrMemoLine.SetRange("GST Jurisdiction Type", PurchCrMemoLine."GST Jurisdiction Type"::Intrastate);
                PurchCrMemoLine.SetRange("GST Group Code", '');
                if PurchCrMemoLine.FindSet() then
                    repeat
                        GSTBaseAmount := GetPurchaseValueforNonGstSupplies(PurchCrMemoLine."Document No.");
                    until PurchCrMemoLine.Next() = 0;
            until PurchCrMemoHdr.Next() = 0;

        if GSTBaseAmount <> 0 then
            TempExcelBuffer.AddColumn(GSTBaseAmount, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(GSTBaseAmount1, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GetInterStateExempValues();

    end;

    local procedure GetInterStateExempValues()
    var
        GSTR2Exemp: Query GSTR2Exemp;
        GSTBaseAmt: Decimal;
    begin
        //Composite For Interstate
        Clear(PurchaseInterAmt);
        Clear(PurchaseIntraAmt);
        Clear(GSTBaseAmt);
        GSTR2Exemp.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2Exemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2Exemp.SetRange(GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR2Exemp.SetRange(GST_Vendor_Type, "GST Vendor Type"::Composite);
        GSTR2Exemp.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR2Exemp.SetFilter(GST__, '<> %1', 0);
        GSTR2Exemp.Open();
        while GSTR2Exemp.Read() do
            GSTBaseAmt := GetPurchaseValue(GSTR2Exemp.Document_No_);
        GSTR2Exemp.Close();
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn("GST Jurisdiction Type"::Interstate, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTBaseAmt, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        //Exempeted for Exempeted
        Clear(PurchaseInterAmt);
        Clear(PurchaseIntraAmt);
        Clear(GSTBaseAmt);
        GSTR2Exemp.SetRange(GST_Exempted_Goods, true);
        GSTR2Exemp.Open();
        while GSTR2Exemp.Read() do
            GSTBaseAmt := GetPurchaseValue(GSTR2Exemp.Document_No_);
        GSTR2Exemp.Close();
        TempExcelBuffer.AddColumn(GSTBaseAmt, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        NilRatedSuppliesforInterstate();
    end;

    local procedure NilRatedSuppliesforInterstate()
    var
        GSTR2Exemp: Query GSTR2Exemp;
        GSTBaseAmt: Decimal;
    begin
        //Nil rated Interstate
        Clear(PurchaseInterAmt);
        Clear(PurchaseIntraAmt);
        Clear(GSTBaseAmt);
        GSTR2Exemp.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2Exemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2Exemp.SetRange(GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR2Exemp.SetFilter(Document_Type, '%1|%2',
                             "GST Document Type"::Invoice,
                              "GST Document Type"::"Credit Memo");
        GSTR2Exemp.SetRange(Transaction_Type, "Detail Ledger Transaction Type"::Purchase);
        GSTR2Exemp.SetRange(Entry_Type, "Detail Ledger Entry Type"::"Initial Entry");
        GSTR2Exemp.SetFilter(GST_Vendor_Type, '%1|%2',
                             "GST Vendor Type"::Registered,
                             "GST Vendor Type"::Unregistered);
        GSTR2Exemp.SetRange(GST__, 0);
        GSTR2Exemp.Open();
        while GSTR2Exemp.Read() do
            GSTBaseAmt := GetPurchaseValue(GSTR2Exemp.Document_No_);
        GSTR2Exemp.Close();
        TempExcelBuffer.AddColumn(GSTBaseAmt, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        NonGSTSuppliesforInterstate();
    end;
    //Non- GST Supplies intrastate
    local procedure NonGSTSuppliesforInterstate()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        GSTBaseAmount1: Decimal;
        GSTBaseAmount: Decimal;
    begin
        Clear(PurchaseInterAmt);
        Clear(PurchaseIntraAmt);
        Clear(GSTBaseAmount);
        PurchInvHeader.Reset();
        PurchInvHeader.SetRange("Location GST Reg. No.", LocationGSTIN);
        PurchInvHeader.SetRange("Posting Date", StartDate, EndDate);
        if PurchInvHeader.FindSet() then
            repeat
                PurchInvLine.Reset();
                PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                PurchInvLine.SetRange("GST Jurisdiction Type", PurchInvLine."GST Jurisdiction Type"::Interstate);
                PurchInvLine.SetRange("GST Group Code", '');
                if PurchInvLine.FindSet() then
                    repeat
                        GSTBaseAmount1 := GetPurchaseValueforNonGstSupplies(PurchInvLine."Document No.");
                    until PurchInvLine.Next() = 0;
            until PurchInvHeader.Next() = 0;

        PurchCrMemoHdr.Reset();
        PurchCrMemoHdr.SetRange("Location GST Reg. No.", LocationGSTIN);
        PurchCrMemoHdr.SetRange("Posting Date", StartDate, EndDate);
        if PurchCrMemoHdr.FindSet() then
            repeat
                PurchCrMemoLine.Reset();
                PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
                PurchCrMemoLine.SetRange("GST Jurisdiction Type", PurchCrMemoLine."GST Jurisdiction Type"::Interstate);
                PurchCrMemoLine.SetRange("GST Group Code", '');
                if PurchCrMemoLine.FindSet() then
                    repeat
                        GSTBaseAmount := GetPurchaseValueforNonGstSupplies(PurchCrMemoLine."Document No.");
                    until PurchCrMemoLine.Next() = 0;
            until PurchCrMemoHdr.Next() = 0;

        if GSTBaseAmount <> 0 then
            TempExcelBuffer.AddColumn(GSTBaseAmount, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(GSTBaseAmount1, false, '', true, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure GetPurchaseValue(DocumentNo: Text): Decimal
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        PurchInvHeader.Reset();
        PurchInvHeader.SetRange("No.", DocumentNo);
        IF PurchInvHeader.FindFirst() THEN
            if DocumentNumber <> DocumentNo then begin
                PurchInvLine.Reset();
                PurchInvLine.SETRANGE("Document No.", PurchInvHeader."No.");
                IF PurchInvLine.FINDSET() THEN
                    REPEAT
                        case PurchInvLine."GST Jurisdiction Type" of
                            "GST Jurisdiction Type"::Intrastate:
                                PurchaseIntraAmt += PurchInvLine."Line Amount";
                            "GST Jurisdiction Type"::Interstate:
                                PurchaseInterAmt += PurchInvLine."Line Amount";
                        end;
                    UNTIL PurchInvLine.NEXT() = 0;

                PurchInvLine.Reset();
                PurchInvLine.SETRANGE("Document No.", PurchInvHeader."No.");
                if PurchInvLine."GST Jurisdiction Type" = PurchInvLine."GST Jurisdiction Type"::Interstate then begin
                    DocumentNumber := DocumentNo;
                    exit(PurchaseInterAmt);
                end
                else begin
                    DocumentNumber := DocumentNo;
                    exit(PurchaseIntraAmt);
                end;
            end;

        PurchCrMemoHdr.Reset();
        PurchCrMemoHdr.SetRange("No.", DocumentNo);
        IF PurchCrMemoHdr.FindFirst() then
            if DocumentNumber <> DocumentNo then begin
                PurchCrMemoLine.Reset();
                PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHdr."No.");
                IF PurchCrMemoLine.FINDSET() then
                    REPEAT
                        case PurchCrMemoLine."GST Jurisdiction Type" of
                            "GST Jurisdiction Type"::Intrastate:
                                PurchaseIntraAmt -= PurchCrMemoLine."Line Amount";
                            "GST Jurisdiction Type"::Interstate:
                                PurchaseInterAmt -= PurchCrMemoLine."Line Amount";
                        end;
                    UNTIL PurchCrMemoLine.NEXT() = 0;
            end;

        PurchCrMemoLine.Reset();
        PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHdr."No.");
        if PurchCrMemoLine."GST Jurisdiction Type" = PurchCrMemoLine."GST Jurisdiction Type"::Interstate then begin
            DocumentNumber := DocumentNo;
            exit(PurchaseInterAmt);
        end
        else begin
            DocumentNumber := DocumentNo;
            exit(PurchaseIntraAmt);
        end;
    end;

    local procedure GetPurchaseValueforNonGstSupplies(DocumentNo: Text): Decimal
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        PurchInvHeader.Reset();
        PurchInvHeader.SetRange("No.", DocumentNo);
        IF PurchInvHeader.FindFirst() THEN
            if DocumentNumber <> DocumentNo then begin
                PurchInvLine.Reset();
                PurchInvLine.SETRANGE("Document No.", PurchInvHeader."No.");
                IF PurchInvLine.FINDSET() THEN
                    REPEAT
                        case PurchInvLine."GST Jurisdiction Type" of
                            "GST Jurisdiction Type"::Intrastate:
                                PurchaseIntraAmt += PurchInvLine."Line Amount";
                            "GST Jurisdiction Type"::Interstate:
                                PurchaseInterAmt += PurchInvLine."Line Amount";
                        end;
                    UNTIL PurchInvLine.NEXT() = 0;
            end;
        PurchInvLine.Reset();
        PurchInvLine.SETRANGE("Document No.", DocumentNo);
        if PurchInvLine.FindFirst() then
            if PurchInvLine."GST Jurisdiction Type" = PurchInvLine."GST Jurisdiction Type"::Interstate then begin
                DocumentNumber := DocumentNo;
                exit(PurchaseInterAmt);
            end
            else begin
                DocumentNumber := DocumentNo;
                exit(PurchaseIntraAmt);
            end;

        PurchCrMemoHdr.Reset();
        PurchCrMemoHdr.SetRange("No.", DocumentNo);
        IF PurchCrMemoHdr.FindFirst() then
            if DocumentNumber <> DocumentNo then begin
                PurchCrMemoLine.Reset();
                PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHdr."No.");
                IF PurchCrMemoLine.FINDSET() then
                    REPEAT
                        case PurchCrMemoLine."GST Jurisdiction Type" of
                            "GST Jurisdiction Type"::Intrastate:
                                PurchaseIntraAmt -= PurchCrMemoLine."Line Amount";
                            "GST Jurisdiction Type"::Interstate:
                                PurchaseInterAmt -= PurchCrMemoLine."Line Amount";
                        end;
                    UNTIL PurchCrMemoLine.NEXT() = 0;
            end;

        PurchCrMemoLine.Reset();
        PurchCrMemoLine.SETRANGE("Document No.", DocumentNo);
        if PurchCrMemoLine.FindFirst() then
            if PurchCrMemoLine."GST Jurisdiction Type" = PurchCrMemoLine."GST Jurisdiction Type"::Interstate then begin
                DocumentNumber := DocumentNo;
                exit(PurchaseInterAmt);
            end
            else begin
                DocumentNumber := DocumentNo;
                exit(PurchaseIntraAmt);
            end;
    end;

    local procedure MakeExcelHeaderATADJ()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GrossAdvanceAdjustedTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessAdjustedTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyATADJ()
    begin
        MakeExcelHeaderATADJ();
        SetFilterforATADJQueryforIntrastate();
        SetFilterforATADJQueryforInterstate();
    end;

    local procedure CreateExcelBodyATADJ(GSTR2ATQuery: Query GSTR2ATADJ)
    var
        State: Record State;
        GSTBaseAmtInters: Decimal;
    begin
        GSTR2ATQuery.SetRange(GST__, 18);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            if GSTR2ATQuery.Buyer_Seller_State_Code <> '' then begin
                TempExcelBuffer.NewRow();
                State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
                TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                if GSTR2ATQuery.GST_Component_Code = CessLbl then
                    TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                GSTR2ATQuery.Close();
            end;

        Clear(GSTBaseAmtInters);
        Clear(GSTBaseAmtInter);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtInters := GSTBaseAmount(GSTR2ATQuery.Original_Doc__No_, GSTR2ATQuery.Document_No_);
        if GSTBaseAmtInters <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtInters), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 12);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            if GSTR2ATQuery.Buyer_Seller_State_Code <> '' then begin
                TempExcelBuffer.NewRow();
                State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
                TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                if GSTR2ATQuery.GST_Component_Code = CessLbl then
                    TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                GSTR2ATQuery.Close();
            end;

        Clear(GSTBaseAmtInters);
        Clear(GSTBaseAmtInter);
        GSTR2ATQuery.SetRange(GST__, 12);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtInters := GSTBaseAmount(GSTR2ATQuery.Original_Doc__No_, GSTR2ATQuery.Document_No_);
        if GSTBaseAmtInters <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtInters), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 5);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            if GSTR2ATQuery.Buyer_Seller_State_Code <> '' then begin
                TempExcelBuffer.NewRow();
                State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
                TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                if GSTR2ATQuery.GST_Component_Code = CessLbl then
                    TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                GSTR2ATQuery.Close();
            end;

        Clear(GSTBaseAmtInters);
        Clear(GSTBaseAmtInter);
        GSTR2ATQuery.SetRange(GST__, 5);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtInters := GSTBaseAmount(GSTR2ATQuery.Original_Doc__No_, GSTR2ATQuery.Document_No_);
        if GSTBaseAmtInters <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtInters), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 28);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            if GSTR2ATQuery.Buyer_Seller_State_Code <> '' then begin
                TempExcelBuffer.NewRow();
                State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
                TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                if GSTR2ATQuery.GST_Component_Code = CessLbl then
                    TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                GSTR2ATQuery.Close();
            end;

        Clear(GSTBaseAmtInter);
        Clear(GSTBaseAmtInters);
        GSTR2ATQuery.SetRange(GST__, 28);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtInters := GSTBaseAmount(GSTR2ATQuery.Original_Doc__No_, GSTR2ATQuery.Document_No_);
        if GSTBaseAmtInters <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtInters), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

    end;

    local procedure CreateExcelBodyATADJIntra(GSTR2ATQuery: Query GSTR2ATADJ)
    var
        State: Record State;
        GSTBaseAmtIntras: Decimal;
    begin
        GSTR2ATQuery.SetRange(GST__, 9);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            if GSTR2ATQuery.Buyer_Seller_State_Code <> '' then begin
                TempExcelBuffer.NewRow();
                State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
                TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(2 * GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                if GSTR2ATQuery.GST_Component_Code = CessLbl then
                    TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                GSTR2ATQuery.Close();
            end;

        Clear(GSTBaseAmtIntras);
        Clear(GSTBaseAmtIntra);
        GSTR2ATQuery.SetRange(GST__, 9);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtIntras := GSTBaseAmount(GSTR2ATQuery.Original_Doc__No_, GSTR2ATQuery.Document_No_);
        if GSTBaseAmtIntras <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtIntras), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 6);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            if GSTR2ATQuery.Buyer_Seller_State_Code <> '' then begin
                TempExcelBuffer.NewRow();
                State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
                TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(2 * GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                if GSTR2ATQuery.GST_Component_Code = CessLbl then
                    TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                GSTR2ATQuery.Close();
            end;

        Clear(GSTBaseAmtIntras);
        Clear(GSTBaseAmtIntra);
        GSTR2ATQuery.SetRange(GST__, 6);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtIntras := GSTBaseAmount(GSTR2ATQuery.Original_Doc__No_, GSTR2ATQuery.Document_No_);
        if GSTBaseAmtIntras <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtIntras), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 2.5);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            if GSTR2ATQuery.Buyer_Seller_State_Code <> '' then begin
                TempExcelBuffer.NewRow();
                State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
                TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(2 * GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                if GSTR2ATQuery.GST_Component_Code = CessLbl then
                    TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                GSTR2ATQuery.Close();
            end;

        Clear(GSTBaseAmtIntras);
        Clear(GSTBaseAmtIntra);
        GSTR2ATQuery.SetRange(GST__, 2.5);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtIntras := GSTBaseAmount(GSTR2ATQuery.Original_Doc__No_, GSTR2ATQuery.Document_No_);
        if GSTBaseAmtIntras <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtIntras), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();

        GSTR2ATQuery.SetRange(GST__, 14);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            if GSTR2ATQuery.Buyer_Seller_State_Code <> '' then begin
                TempExcelBuffer.NewRow();
                State.Get(GSTR2ATQuery.Buyer_Seller_State_Code);
                TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(2 * GSTR2ATQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                if GSTR2ATQuery.GST_Component_Code = CessLbl then
                    TempExcelBuffer.AddColumn(GSTR2ATQuery.GST_Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                GSTR2ATQuery.Close();
            end;

        Clear(GSTBaseAmtIntras);
        Clear(GSTBaseAmtIntra);
        GSTR2ATQuery.SetRange(GST__, 14);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            GSTBaseAmtIntras := GSTBaseAmount(GSTR2ATQuery.Original_Doc__No_, GSTR2ATQuery.Document_No_);
        if GSTBaseAmtIntras <> 0 then
            TempExcelBuffer.AddColumn(Abs(GSTBaseAmtIntras), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        GSTR2ATQuery.Close();
    end;

    local procedure SetFilterforATADJQueryforIntrastate()
    var
        GSTR2ATQuery: Query GSTR2ATADJ;
    begin
        GSTR2ATQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2ATQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2ATQuery.SetRange(Credit_Availed, true);
        GSTR2ATQuery.SetRange(GST_Jurisdiction_Type, "GST Jurisdiction Type"::Intrastate);
        GSTR2ATQuery.SetRange(GST_Component_Code, CGSTLbl);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            CreateExcelBodyATADJIntra(GSTR2ATQuery);
    end;

    local procedure SetFilterforATADJQueryforInterstate()
    var
        GSTR2ATQuery: Query GSTR2ATADJ;
    begin
        GSTR2ATQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2ATQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2ATQuery.SetRange(Credit_Availed, true);
        GSTR2ATQuery.SetRange(GSTR2ATQuery.GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR2ATQuery.Open();
        while GSTR2ATQuery.Read() do
            CreateExcelBodyATADJ(GSTR2ATQuery);
    end;

    local procedure GSTBaseAmount(OriginalDocNo: Text; DocumentNo: Text): Decimal
    var
        DetailedGstLedgerEntry: Record "Detailed GST Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange("Document No.", OriginalDocNo);
        VendorLedgerEntry.SetRange("GST on Advance Payment", true);
        if VendorLedgerEntry.FindFirst() then begin
            DetailedGstLedgerEntry.Reset();
            DetailedGstLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGstLedgerEntry.SetRange("Entry Type", DetailedGstLedgerEntry."Entry Type"::Application);
            if DetailedGstLedgerEntry.FindFirst() then
                case DetailedGstLedgerEntry."GST Jurisdiction Type" of
                    "GST Jurisdiction Type"::Intrastate:
                        begin
                            GSTBaseAmtIntra += DetailedGstLedgerEntry."GST Base Amount";
                            exit(GSTBaseAmtIntra);
                        end;
                    "GST Jurisdiction Type"::Interstate:
                        begin
                            GSTBaseAmtInter += DetailedGstLedgerEntry."GST Base Amount";
                            exit(GSTBaseAmtInter);
                        end;
                end;
        end;
        DetailedGstLedgerEntry.Reset();
        DetailedGstLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGstLedgerEntry.SetRange("Entry Type", DetailedGstLedgerEntry."Entry Type"::Application);
        if DetailedGstLedgerEntry.FindFirst() then
            case DetailedGstLedgerEntry."GST Jurisdiction Type" of
                "GST Jurisdiction Type"::Intrastate:
                    exit(GSTBaseAmtIntra);
                "GST Jurisdiction Type"::Interstate:
                    exit(GSTBaseAmtInter);
            end;
    end;

    local procedure GetBaseAmountforPaymentType(DocumentNo: Text): Decimal
    var
        DetailedGstLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGstLedgerEntry.Reset();
        DetailedGstLedgerEntry.SetRange("Document No.", DocumentNo);
        if DetailedGstLedgerEntry.FindFirst() then
            if (DetailedGstLedgerEntry."Document Type" = DetailedGstLedgerEntry."Document Type"::Payment) then
                case DetailedGstLedgerEntry."GST Jurisdiction Type" of
                    "GST Jurisdiction Type"::Intrastate:
                        begin
                            GSTBaseAmtIntra += DetailedGstLedgerEntry."GST Base Amount";
                            exit(GSTBaseAmtIntra);
                        end;
                    "GST Jurisdiction Type"::Interstate:
                        begin
                            GSTBaseAmtInter += DetailedGstLedgerEntry."GST Base Amount";
                            exit(GSTBaseAmtInter);
                        end;
                end;
    end;

    local procedure MakeExcelHeaderHSNSUM()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(HSNSACofSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DescriptionTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(UPPERCASE(UQCTxt), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TotalQtyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TotalValTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(IntegratedTaxAmtTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CentralTaxAmtTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(StateTaxAmtTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyHSNSUM()
    var
        GSTR2HSNQuery: Query GSTR2HSNQuery;
    begin
        MakeExcelHeaderHSNSUM();
        GSTR2HSNQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2HSNQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2HSNQuery.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR2HSNQuery.Open();
        while GSTR2HSNQuery.Read() do
            CreateExcelBufferHSNSUM(GSTR2HSNQuery);
    end;

    local procedure CreateExcelBufferHSNSUM(GSTR2HSNQuery: Query GSTR2HSNQuery)
    var
        GSTR2HSNGSTAmt: Query GSTR2HSNGSTAmt;
        GSTR2HSNQty: Query GSTR2HSNQty;
        HSNIGSTAmt: Decimal;
        HSNCGSTAmt: Decimal;
        HSNSGSTAmt: Decimal;
        HSNCessAmt: Decimal;
        HSNQty: Decimal;
        HSNGSTBaseAmt: Decimal;
    begin
        Clear(HSNGSTBaseAmt);
        Clear(HSNQty);
        GSTR2HSNGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2HSNGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2HSNGSTAmt.SetRange(HSN_SAC_Code, GSTR2HSNQuery.HSN_SAC_Code);
        GSTR2HSNGSTAmt.SetRange(GST_Component_Code, CGSTLbl);
        GSTR2HSNGSTAmt.SetRange(UOM, GSTR2HSNQuery.UOM);
        GSTR2HSNGSTAmt.Open();
        while GSTR2HSNGSTAmt.Read() do
            HSNCGSTAmt := GSTR2HSNGSTAmt.GST_Amount;

        GSTR2HSNGSTAmt.SetRange(GST_Component_Code, SGSTLbl);
        GSTR2HSNGSTAmt.Open();
        while GSTR2HSNGSTAmt.Read() do
            HSNSGSTAmt := GSTR2HSNGSTAmt.GST_Amount;

        GSTR2HSNGSTAmt.SetRange(GST_Component_Code, IGSTLbl);
        GSTR2HSNGSTAmt.Open();
        while GSTR2HSNGSTAmt.Read() do
            HSNIGSTAmt := GSTR2HSNGSTAmt.GST_Amount;

        GSTR2HSNGSTAmt.SetRange(GST_Component_Code, CessLbl);
        GSTR2HSNGSTAmt.Open();
        while GSTR2HSNGSTAmt.Read() do
            HSNCessAmt := GSTR2HSNGSTAmt.GST_Amount;

        GSTR2HSNQty.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR2HSNQty.SetRange(Posting_Date, StartDate, EndDate);
        GSTR2HSNQty.SetRange(HSN_SAC_Code, GSTR2HSNQuery.HSN_SAC_Code);
        GSTR2HSNQty.SetRange(UOM, GSTR2HSNQuery.UOM);
        GSTR2HSNQty.Open();
        while GSTR2HSNQty.Read() do
            if (GSTR2HSNQty.GST_Jurisdiction_Type = GSTR2HSNQty.GST_Jurisdiction_Type::Intrastate) and (GSTR2HSNQty.Document_Type In [(GSTR2HSNQty.Document_Type::Invoice), (GSTR2HSNQty.Document_Type::Payment), (GSTR2HSNQty.Document_Type::Refund)]) then begin
                HSNQty += GSTR2HSNQty.Quantity / 2;
                HSNGSTBaseAmt += GSTR2HSNQty.GST_Base_Amount / 2;
            end else
                if (GSTR2HSNQty.GST_Jurisdiction_Type = GSTR2HSNQty.GST_Jurisdiction_Type::Interstate) and (GSTR2HSNQty.Document_Type In [(GSTR2HSNQty.Document_Type::Invoice), (GSTR2HSNQty.Document_Type::Payment), (GSTR2HSNQty.Document_Type::Refund)]) then begin
                    HSNQty += GSTR2HSNQty.Quantity;
                    HSNGSTBaseAmt += GSTR2HSNQty.GST_Base_Amount;
                end else
                    if (GSTR2HSNQty.GST_Jurisdiction_Type = GSTR2HSNQty.GST_Jurisdiction_Type::Intrastate) and (GSTR2HSNQty.Document_Type = GSTR2HSNQty.Document_Type::"Credit Memo") then begin
                        HSNQty := HSNQty - GSTR2HSNQty.Quantity / 2;
                        HSNGSTBaseAmt += GSTR2HSNQty.GST_Base_Amount / 2;
                    end else
                        if (GSTR2HSNQty.GST_Jurisdiction_Type = GSTR2HSNQty.GST_Jurisdiction_Type::Interstate) and (GSTR2HSNQty.Document_Type = GSTR2HSNQty.Document_Type::"Credit Memo") then begin
                            HSNQty := HSNQty - GSTR2HSNQty.Quantity;
                            HSNGSTBaseAmt += GSTR2HSNQty.GST_Base_Amount;
                        end;

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTR2HSNQuery.HSN_SAC_Code, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR2HSNQuery.HSN_SAC_Code <> '' then
            TempExcelBuffer.AddColumn(GSTR2HSNQuery.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn(GSTR2HSNQuery.UOM, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(Abs(HSNQty), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(Abs(HSNGSTBaseAmt + HSNIGSTAmt + HSNCGSTAmt + HSNSGSTAmt + HSNCessAmt), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(Abs(HSNGSTBaseAmt), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(Abs(HSNIGSTAmt), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(Abs(HSNCGSTAmt), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(Abs(HSNSGSTAmt), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(Abs(HSNCessAmt), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;
}


