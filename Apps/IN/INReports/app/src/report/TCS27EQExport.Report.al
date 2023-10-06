// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Sales.Customer;
using System.IO;
using System.Utilities;

report 18018 "TCS 27 EQ Export"
{
    Caption = 'TCS 27 EQ Export';
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
                CreateBookandOpenExcel(TCS27QExportReportLbl);
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
                        ToolTip = 'Species the date from which TCS 27 EQ report is to be generated';
                    }
                    field("Date To"; DateTo)
                    {
                        Caption = 'Date To';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Species the date to which TCS 27 EQ report is to be generated';
                    }
                    field("TCAN No"; TCANNo)
                    {
                        Caption = 'T.C.A.N. No.';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the TAN number on the TDS entry.';
                        TableRelation = "T.C.A.N. No.";
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
        TCANNo: Code[10];
        AssesseeCodeType: Text;
        NonResidentDedcutee: Text;
        ResidentDedcutee: Text;
        YLbl: Label 'Y', Locked = true;
        NLbl: Label 'N', Locked = true;
        INLbl: Label 'IN', Locked = true;
        OneLbl: Label '01', Locked = true;
        TwoLbl: Label '02', Locked = true;
        COMLbl: Label 'COM', Locked = true;
        SNoLbl: Label 'S.No', Locked = true;
        TypeLbl: Label 'Type', Locked = true;
        PANLbl: Label 'P.A.N', Locked = true;
        NameLbl: Label 'Name', Locked = true;
        TransactionValueLbl: Label 'Transaction Value', Locked = true;
        AmtRecvdDrLbl: Label 'Amt Recvd/Dr', Locked = true;
        DateAmtRecvdDrLbl: Label 'Date AmtRecvdDr', Locked = true;
        AmountLbl: Label 'Amount', Locked = true;
        TaxLbl: Label 'TAX', Locked = true;
        SurchargeLbl: Label 'Surcharge', Locked = true;
        ECessLbl: Label 'E Cess', Locked = true;
        TotalTaxDepositedLbl: Label 'Total Tax Deposited', Locked = true;
        TotalTaxCollectedLbl: Label ' Total Tax Collected', Locked = true;
        CollectionDateLbl: Label 'Collection Date', Locked = true;
        CollectionRateLbl: Label 'Collection Rate', Locked = true;
        DeviationReasonTxt: Label 'Deviation Reason', Locked = true;
        DeviationCertificateLbl: Label 'Deviation Certificate', Locked = true;
        NonResidentDedcuteeLbl: Label 'Non resident Dedcutee', Locked = true;
        DeducteeHasEstbInIndiaLbl: Label 'Deductee has Estb in India', Locked = true;
        FromDateErr: Label 'From date cannot be left blank', Locked = true;
        ToDateErr: Label 'To Date cannot be left blank', Locked = true;
        TCANNoErr: Label 'TCAN No. cannot be left blank', Locked = true;
        TCS27QExportReportLbl: Label 'TCS27QExportReportTxt', Locked = true;

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
        TempExcelBuffer.AddColumn(TransactionValueLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AmtRecvdDrLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DateAmtRecvdDrLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AmountLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SurchargeLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ECessLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TotalTaxCollectedLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TotalTaxDepositedLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CollectionDateLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CollectionRateLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DeviationReasonTxt, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DeviationCertificateLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(NonResidentDedcuteeLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DeducteeHasEstbInIndiaLbl, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);

        OnAfterMakeExcelHeader(TempExcelBuffer);
    end;


    local procedure CreateExcelBody()
    var
        Customer: Record Customer;
        TCS27EQQuery: Query "TCS 27 EQ";
        IsHandled: Boolean;
    begin
        Clear(AssesseeCodeType);
        SNo := 0;
        TCS27EQQuery.SetRange(Posting_Date, DateFrom, DateTo);
        if TCANNo <> '' then
            TCS27EQQuery.SetFilter(T_C_A_N__No_, TCANNo);

        OnAfterSetfilterForTDS27EQ(TCS27EQQuery);

        TCS27EQQuery.Open();
        while TCS27EQQuery.Read() do begin
            SNo += 1;
            TempExcelBuffer.NewRow();

            OnBeforeCreateExcelBody(TempExcelBuffer, TCS27EQQuery, IsHandled);
            if IsHandled then
                exit;

            TempExcelBuffer.AddColumn(SNo, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            GetCustomerAssesseeCode(TCS27EQQuery.Assessee_Code);
            TempExcelBuffer.AddColumn(AssesseeCodeType, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(TCS27EQQuery.Customer_P_A_N__No_, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            Customer.Get(TCS27EQQuery.Customer_No_);
            TempExcelBuffer.AddColumn(Customer.Name, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

            TempExcelBuffer.AddColumn(TCS27EQQuery.Invoice_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TCS27EQQuery.Invoice_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TCS27EQQuery.Posting_Date, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Date);
            TempExcelBuffer.AddColumn(TCS27EQQuery.Invoice_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TCS27EQQuery.TCS_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TCS27EQQuery.Surcharge_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TCS27EQQuery.eCESS_Amount, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn((TCS27EQQuery.TCS_Amount + TCS27EQQuery.Surcharge_Amount + TCS27EQQuery.eCESS_Amount), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn((TCS27EQQuery.TCS_Amount + TCS27EQQuery.Surcharge_Amount + TCS27EQQuery.eCESS_Amount), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(TCS27EQQuery.Posting_Date, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Date);
            TempExcelBuffer.AddColumn(TCS27EQQuery.TCS__, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

            GetNonResidentDedcuteeAndEstd(TCS27EQQuery.Customer_No_);
            TempExcelBuffer.AddColumn(NonResidentDedcutee, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(ResidentDedcutee, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

            OnAfterCreateExcelBody(TempExcelBuffer, TCS27EQQuery);
        end;
        TCS27EQQuery.Close();
    end;

    local procedure CreateBookandOpenExcel(FileFormatTxt: Text[250])
    begin
        TempExcelBuffer.CreateNewBook(FileFormatTxt);
        TempExcelBuffer.WriteSheet(FileFormatTxt, CompanyName(), UserId());
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.OpenExcel();
    end;

    local procedure GetCustomerAssesseeCode(AssesseeCode: code[10])
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
        OnBeforeValidationsForBlankValues(DateFrom, DateTo, TCANNo, IsHandled);
        if IsHandled then
            exit;

        if DateFrom = 0D then
            Error(FromDateErr);

        if DateTo = 0D then
            Error(ToDateErr);

        if TCANNo = '' then
            Error(TCANNoErr);
    end;

    local procedure GetNonResidentDedcuteeAndEstd(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then
            if Customer."Country/Region Code" = INLbl then begin
                NonResidentDedcutee := NLbl;
                ResidentDedcutee := YLbl;
            end else begin
                NonResidentDedcutee := YLbl;
                ResidentDedcutee := NLbl;
            end;
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
    local procedure OnBeforeCreateExcelBody(var TempExcelBuffer: Record "Excel Buffer"; TCS27EQ: Query "TCS 27 EQ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateExcelBody(var TempExcelBuffer: Record "Excel Buffer"; TCS27EQ: Query "TCS 27 EQ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidationsForBlankValues(DateFrom: Date; DateTo: Date; TCANNo: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetfilterForTDS27EQ(var TCS27EQQuery: Query "TCS 27 EQ")
    begin
    end;
}
