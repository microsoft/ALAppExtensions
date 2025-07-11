// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.TaxBase;
using Microsoft.Purchases.Vendor;
using System.IO;
using System.Utilities;

report 18007 "TDS 27Q Export"
{
    Caption = 'TDS 27Q Export';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem(Integer; Integer)
        {
            dataItemTableView = sorting(Number)
                                where(Number = const(1));

            trigger OnPreDataItem()
            begin
                ValidationsForBlankValues();
                TempExcelBuffer.DeleteAll();
                MakeExcelHeader();
            end;

            trigger OnAfterGetRecord()
            begin
                CreateExcelBody();
                CreateBookandOpenExcel(TDS27QExportReportLbl);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Option)
                {
                    field("Date From"; DateFrom)
                    {
                        Caption = 'Date From';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Species the date from which TDS 27 Q report is to be generated';
                    }
                    field("Date To"; DateTo)
                    {
                        Caption = 'Date To';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Species the date to which TDS 27 Q report is to be generated';
                    }
                    field("TAN No"; TANNo)
                    {
                        Caption = 'T.A.N. No.';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the TAN number on the TDS entry.';
                        TableRelation = "TAN Nos.";
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
        SNo: Integer;
        DateFrom: Date;
        DateTo: Date;
        TANNo: Code[10];
        AssesseeCodeType: Text;
        OneLbl: Label '01', Locked = true;
        TwoLbl: Label '02', Locked = true;
        COMLbl: Label 'COM', Locked = true;
        TDS27QExportReportLbl: Label 'TDS27QExportReportTxt', Locked = true;
        SNoLbl: Label 'S.No', Locked = true;
        TypeLbl: Label 'Type', Locked = true;
        PANLbl: Label 'P.A.N', Locked = true;
        NameLbl: Label 'Name', Locked = true;
        SectionLbl: Label 'Section', Locked = true;
        PmtCrDateLbl: Label 'Pmt/Cr Date', Locked = true;
        AmountLbl: Label 'Amount', Locked = true;
        TaxLbl: Label 'TAX', Locked = true;
        SurchargeLbl: Label 'Surcharge', Locked = true;
        ECessLbl: Label 'E Cess', Locked = true;
        TotalTaxDeductedLbl: Label 'Total Tax Deducted', Locked = true;
        TotalTaxDepositedLbl: Label ' Total Tax Deposited', Locked = true;
        DeductionDateLbl: Label 'Deduction Date', Locked = true;
        DeductionRateLbl: Label 'Deduction Rate', Locked = true;
        DeviationReasonTxt: Label 'Deviation Reason', Locked = true;
        DeviationCertificateLbl: Label 'Deviation Certificate', Locked = true;
        NatureofRemmitLbl: Label 'Nature of Remmit', Locked = true;
        RemitToCountryLbl: Label 'Remit to Country', Locked = true;
        DedcuteeMailidLbl: Label 'Dedcutee Mail id', Locked = true;
        DedcuteePhoneLbl: Label 'Dedcutee Phone', Locked = true;
        DedcuteeAddressLbl: Label 'Dedcutee Address', Locked = true;
        DeducteeTaxUniqueIDLbl: Label 'DeducteeTax/ unique ID', Locked = true;
        FromDateErr: Label 'From date cannot be left blank', Locked = true;
        ToDateErr: Label 'To Date cannot be left blank', Locked = true;
        TANNoErr: Label 'TAN No. cannot be left blank', Locked = true;

    local procedure MakeExcelHeader()
    var
        IsHandled: Boolean;
    begin
        TempExcelBuffer.NewRow();

        OnBeforeMakeExcelHeader(TempExcelBuffer, IsHandled);
        if IsHandled then
            exit;

        TempExcelBuffer.AddColumn(SNoLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TypeLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PANLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(NameLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SectionLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PmtCrDateLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AmountLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SurchargeLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ECessLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TotalTaxDeductedLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TotalTaxDepositedLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DeductionDateLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DeductionRateLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DeviationReasonTxt, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DeviationCertificateLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(NatureofRemmitLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RemitToCountryLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DedcuteeMailidLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DedcuteePhoneLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DedcuteeAddressLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DeducteeTaxUniqueIDLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);

        OnAfterMakeExcelHeader(TempExcelBuffer);
    end;

    local procedure CreateExcelBody();
    var
        Vendor: Record Vendor;
        TDS27QQuery: Query "TDS 27Q";
        IsHandled: Boolean;
    begin
        Clear(AssesseeCodeType);
        SNo := 0;
        TDS27QQuery.SetRange(Posting_Date, DateFrom, DateTo);
        if TANNo <> '' then
            TDS27QQuery.SetFilter(T_A_N__No_, TANNo);

        TDS27QQuery.SetFilter(Assessee_Code, '=%1', 'NRI');

        OnAfterSetfilterForTDS27QQuery(TDS27QQuery);

        TDS27QQuery.Open();
        while TDS27QQuery.Read() do begin
            SNo += 1;
            TempExcelBuffer.NewRow();

            IsHandled := false;
            OnBeforeCreateExcelBody(TempExcelBuffer, TDS27QQuery, IsHandled);
            if IsHandled then
                exit;

            TempExcelBuffer.AddColumn(SNo, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);

            GetVendorAssesseeCode(TDS27QQuery.Assessee_Code);
            TempExcelBuffer.AddColumn(AssesseeCodeType, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(TDS27QQuery.Deductee_PAN_No_, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            Vendor.Get(TDS27QQuery.Vendor_No_);
            TempExcelBuffer.AddColumn(Vendor.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

            TempExcelBuffer.AddColumn(TDS27QQuery.Section, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(TDS27QQuery.Posting_Date, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Date);
            TempExcelBuffer.AddColumn(TDS27QQuery.TDS_Base_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TDS27QQuery.TDS_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TDS27QQuery.Surcharge_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TDS27QQuery.eCess_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn((TDS27QQuery.TDS_Amount + TDS27QQuery.Surcharge_Amount + TDS27QQuery.eCess_Amount), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TDS27QQuery.TDS_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TDS27QQuery.Posting_Date, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Date);
            TempExcelBuffer.AddColumn(TDS27QQuery.TDS__, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(TDS27QQuery.Nature_of_Remittance, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(Vendor."Country/Region Code", false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(Vendor."E-Mail", false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(Vendor."Phone No.", false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(Vendor.Address, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(Vendor."P.A.N. No.", false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

            OnAfterCreateExcelBody(TempExcelBuffer, TDS27QQuery);
        end;
        TDS27QQuery.Close();
    end;

    local procedure CreateBookandOpenExcel(FileFormatTxt: Text[250])
    begin
        TempExcelBuffer.CreateNewBook(FileFormatTxt);
        TempExcelBuffer.WriteSheet(FileFormatTxt, CompanyName(), UserId());
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.OpenExcel();
    end;

    local procedure GetVendorAssesseeCode(AssesseeCode: code[10])
    begin
        case AssesseeCode of
            COMLbl:
                AssesseeCodeType := OneLbl
            else
                AssesseeCodeType := TwoLbl;
        end;
    end;

    local procedure ValidationsForBlankValues()
    var
        IsHandled: Boolean;
    begin
        OnBeforeValidationsForBlankValues(DateFrom, DateTo, TANNo, IsHandled);
        if IsHandled then
            exit;

        if DateFrom = 0D then
            Error(FromDateErr);

        if DateTo = 0D then
            Error(ToDateErr);

        if TANNo = '' then
            Error(TANNoErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMakeExcelHeader(var TempExcelBuffer: Record "Excel Buffer"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeExcelHeader(var TempExcelBuffer: Record "Excel Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateExcelBody(var TempExcelBuffer: Record "Excel Buffer"; TDS27Q: Query "TDS 27Q"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateExcelBody(var TempExcelBuffer: Record "Excel Buffer"; TDS27Q: Query "TDS 27Q")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidationsForBlankValues(DateFrom: Date; DateTo: Date; TANNo: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetfilterForTDS27QQuery(var TTDS27QQuery: Query "TDS 27Q")
    begin
    end;
}
