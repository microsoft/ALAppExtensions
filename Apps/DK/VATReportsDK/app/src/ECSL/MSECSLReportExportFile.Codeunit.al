// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using System.Telemetry;
using System.Utilities;

codeunit 13690 "MS - ECSL Report Export File"
{
    TableNo = "VAT Report Header";

    var
        ErrorMessage: Record "Error Message";
        ReportTxt: Text;
        NoDownload: Boolean;
        CompanyVATRegNo: Text;
        ExceedingLenghtErr: Label 'It is not possible to display %1 in a field with a length of %2.', Comment = '%1 = Text to be displayed; %2 = Maximum length for the field';
        InvalidPeriodErr: Label 'The period is not valid.';

    trigger OnRun();
    var
        CompanyInformation: Record "Company Information";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        VATTok: Label 'DK VAT-VIES Reporting', Locked = true;
    begin
        FeatureTelemetry.LogUptake('0000H8R', VATTok, Enum::"Feature Uptake Status"::"Used");
        ErrorMessage.SetContext(RECORDID());
        ErrorMessage.ClearLog();

        if not ValidateReport(Rec) then
            EXIT;

        CompanyInformation.Get();
        CompanyVATRegNo := TrimVatPrefix(CompanyInformation."VAT Registration No.", CompanyInformation."Country/Region Code");
        ExportFile(Rec);

        FeatureTelemetry.LogUsage('0000H8S', VATTok, 'ECSL report exported');
    end;

    local procedure ValidateReport(VATReportHeader: Record "VAT Report Header"): Boolean;
    begin
        if not VATReportHeader.IsPeriodValid() then begin
            ErrorMessage.LogMessage(VATReportHeader, VATReportHeader.FIELDNO("No."), ErrorMessage."Message Type"::Error, InvalidPeriodErr);
            exit(false);
        end;

        exit(true);
    end;

    local procedure ExportFile(VATReportHeader: Record "VAT Report Header");
    var
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        TxtBuilder: TextBuilder;
        CurrentVAT: Text[20];
        SalesAmount: Decimal;
        TriangulatedAmount: Decimal;
        ServiceAmount: Decimal;
        GrandTotal: Decimal;
        Counter: Integer;
    begin
        ECSLVATReportLine.SetRange("Report No.", VATReportHeader."No.");
        ECSLVATReportLine.SetCurrentKey("Customer VAT Reg. No.");
        ECSLVATReportLine.SetAscending("Customer VAT Reg. No.", true);
        ECSLVATReportLine.FindSet();

        AddHeader(TxtBuilder);

        repeat
            CurrentVAT := ECSLVATReportLine."Customer VAT Reg. No.";
            ECSLVATReportLine.SetRange("Customer VAT Reg. No.", CurrentVAT);
            repeat
                GrandTotal += ECSLVATReportLine."Total Value Of Supplies";
                PopulateAmountFromLine(ECSLVATReportLine, SalesAmount, ServiceAmount, TriangulatedAmount);
            until ECSLVATReportLine.Next() = 0;
            ECSLVATReportLine.SetRange("Customer VAT Reg. No.");

            TxtBuilder.AppendLine(
              PopulateLine(
                VATReportHeader,
                ECSLVATReportLine."Country Code",
                TrimVatPrefix(CurrentVAT, ECSLVATReportLine."Country Code"),
                SalesAmount,
                ServiceAmount,
                TriangulatedAmount));

            SalesAmount := 0;
            ServiceAmount := 0;
            TriangulatedAmount := 0;
            Counter += 1;
        until ECSLVATReportLine.Next() = 0;

        AddGrandTotal(TxtBuilder, Counter, GrandTotal);
        ReportTxt := TxtBuilder.ToText();

        if NoDownload then
            exit;

        DownloadAsFile(VATReportHeader."No." + '.txt');
    end;

    local procedure DownloadAsFile(FileName: Text);
    var
        FileObj: File;
        OutStrm: OutStream;
        InStrm: InStream;
    begin
        FileObj.CreateTempFile();
        FileObj.CREATEOUTSTREAM(OutStrm);
        OutStrm.WRITETEXT(ReportTxt);
        FileObj.CreateInStream(InStrm);
        file.DownloadFromStream(InStrm, '', '', '', FileName);
    end;

    local procedure PopulateAmountFromLine(ECSLVATReportLine: Record "ECSL VAT Report Line"; var SalesAmount: Decimal; var ServiceAmount: Decimal; var TriangulatedAmount: Decimal);
    begin
        case ECSLVATReportLine."Transaction Indicator" of
            ECSLVATReportLine."Transaction Indicator"::"B2B Goods":
                SalesAmount := ECSLVATReportLine."Total Value Of Supplies";
            ECSLVATReportLine."Transaction Indicator"::"B2B Services":
                ServiceAmount := ECSLVATReportLine."Total Value Of Supplies";
            ECSLVATReportLine."Transaction Indicator"::"Triangulated Goods":
                TriangulatedAmount := ECSLVATReportLine."Total Value Of Supplies";
        end;
    end;

    local procedure AddHeader(var txtBuilder: TextBuilder);
    var
        HeaderTxt: Label '0,%1,LISTE,,,,,,', Locked = true;
    begin
        txtBuilder.AppendLine(
          StrSubstNo(HeaderTxt, CompanyVATRegNo));
    end;

    local procedure PopulateLine(VATReportHeader: Record "VAT Report Header"; CountryCode: Code[10]; VatRegNo: Text; SalesAmount: Decimal; ServiceAmount: Decimal; TriangulatedAmount: Decimal): Text;
    var
        LineTxt: Label '2,%1,%2,%3,%4,%5,%6,%7,%8', Locked = true;
    begin
        exit(
          StrSubstNo(LineTxt,
            CheckLength(FORMAT(VATReportHeader."No."), 10),
            FormatDate(VATReportHeader."End Date"),
            CompanyVATRegNo,
            CountryCode,
            VatRegNo,
            DecimalNumeralSign(SalesAmount) + DecimalNumeralFormat(SalesAmount, 15),
            DecimalNumeralSign(TriangulatedAmount) + DecimalNumeralFormat(TriangulatedAmount, 15),
            DecimalNumeralSign(ServiceAmount) + DecimalNumeralFormat(ServiceAmount, 15)));
    end;

    local procedure AddGrandTotal(var txtBuilder: TextBuilder; TotalCount: Decimal; TotalAmont: Decimal);
    var
        GrandTotalTxt: Label '10,%1,%2,,,,,,', Locked = true;
    begin
        txtBuilder.AppendLine(
          StrSubstNo(GrandTotalTxt,
            DecimalNumeralFormat(TotalCount, 9),
            DecimalNumeralFormat(TotalAmont, 15)));
    end;

    local procedure DecimalNumeralFormat(DecimalNumeral: Decimal; Length: Integer): Text[16];
    begin
        exit(CheckLength(DELCHR(FORMAT(ROUND(ABS(DecimalNumeral), 1, '<'), 0, 1)), Length));
    end;

    local procedure CheckLength(Txt: Text; Length: Integer): Text[16];
    begin
        if STRLEN(Txt) > Length then
            ERROR(ExceedingLenghtErr, Txt, Length);
        exit(CopyStr(CopyStr(Txt, 1, Length), 1, 16));
    end;

    procedure FillZero(InputText: Text[4]; Length: Integer): Text[4];
    begin
        exit(PADSTR('', Length - STRLEN(InputText), '0') + InputText);
    end;

    local procedure DecimalNumeralSign(DecimalNumeral: Decimal): Text[1];
    begin
        if DecimalNumeral < 0 then
            exit('-');
    end;

    procedure TrimVatPrefix(VatRegNo: Text[20]; CountryCode: Code[10]): Text[20];
    begin
        if STRPOS(VatRegNo, CountryCode) = 1 then
            exit(DELSTR(VatRegNo, 1, STRLEN(CountryCode)));
        exit(VatRegNo);
    end;

    local procedure FormatDate(DateObj: Date): Text;
    begin
        exit(FORMAT(DATE2DMY(DateObj, 3)) + '-' + FillZero(FORMAT(DATE2DMY(DateObj, 2)), 2) + '-' + FillZero(FORMAT(DATE2DMY(DateObj, 1)), 2));
    end;

    procedure GetOutputContent(): Text;
    begin
        exit(ReportTxt);
    end;

    procedure AvoidDownload();
    begin
        NoDownload := true;
    end;
}

