// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Company;
using System.IO;
using System.Utilities;

codeunit 13407 "Intrastat Report Exp. Ext. FI"
{
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        IsHandled: Boolean;
    begin
        if Rec."File Content".HasValue() then begin
            TempBlob.FromRecord(Rec, Rec.FieldNo("File Content"));
            TempBlob.CreateInStream(InStr);

            Clear(Rec."File Content");
            Rec."File Content".CreateOutStream(OutStr);

            IsHandled := false;
            OnBeforeAddHeader(Rec, OutStr, IsHandled);
            if not IsHandled then begin
                OutStr.WriteText(GetHeader(Rec));
                OutStr.WriteText();
            end;

            CopyStream(OutStr, InStr);
            OutStr.WriteText();

            IsHandled := false;
            OnBeforeAddFooter(Rec, OutStr, IsHandled);
            if not IsHandled then
                OutStr.WriteText(GetFooter());
            Rec.Modify(true);
        end;
    end;

    var
        IntrastatReportManagementFI: Codeunit "Intrastat Report Management FI";
        FooterTxt: Label 'SUM%1%2', Locked = true, Comment = '1 - Number of lines, 2 - Total rounded amount';
        HeaderTxt: Label 'KON0037%1', Locked = true, Comment = '1 - Business ID code';

    local procedure GetHeader(var DataExch: Record "Data Exch.") HeaderText: Text;
    var
        CompanyInfo: Record "Company Information";
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        BusinessIdCode: Code[20];
        IntrastatReportLineFilters: Text;
        FileType: Text[1];
        CR: Text[2];
        InStreamFilters: InStream;
    begin
        CompanyInfo.Get();
        IntrastatReportSetup.Get();
        CR[1] := 13;
        CR[2] := 10;

        DataExch."Table Filters".CreateInStream(InStreamFilters, TextEncoding::Windows);
        InStreamFilters.ReadText(IntrastatReportLineFilters);
        IntrastatReportLine.SetView(IntrastatReportLineFilters);
        if IntrastatReportLine.GetFilter(Type) = Format(IntrastatReportLine.Type::Receipt) then
            FileType := 'A'
        else
            FileType := 'D';

        BusinessIdCode := DelChr(CompanyInfo."Business Identity Code", '=', '-').Substring(1, 8);
        IntrastatReportHeader := IntrastatReportManagementFI.GetIntrastatHeader();

        if IntrastatReportSetup."Last Transfer Date" = Today then
            IntrastatReportSetup."File No." := IncStr(IntrastatReportSetup."File No.")
        else begin
            IntrastatReportSetup."Last Transfer Date" := Today;
            IntrastatReportSetup."File No." := '001';
        end;
        IntrastatReportSetup.Modify();

        HeaderText :=
            StrSubstNo(HeaderTxt, BusinessIdCode).PadRight(20) + CR;

        HeaderText +=
            'OTS' +
            Format(Today, 0, '<Year,2>') +
            IntrastatReportSetup."Custom Code" +
            Format(Today - CalcDate('<-CY>', Today) + 1).PadLeft(3, '0') +
            IntrastatReportSetup."Company Serial No." +
            IntrastatReportSetup."File No." +
            FileType +
            CopyStr(IntrastatReportHeader."Statistics Period", 1, 4) +
            'T' +
            Format('').PadLeft(15, ' ') +
            'FI' +
            BusinessIdCode +
            Format('').PadLeft(34, ' ') +
            IntrastatReportSetup."Custom Code" +
            Format('').PadLeft(15, ' ') +
            'EUR';
    end;

    local procedure GetFooter() FooterText: Text;
    var
        TotalRoundedAmount, LineCount : Integer;
    begin
        IntrastatReportManagementFI.GetTotals(TotalRoundedAmount, LineCount);
        FooterText := StrSubstNo(FooterTxt, Format(LineCount).PadLeft(18, '0'), Format(TotalRoundedAmount).PadLeft(18, '0'));
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeAddHeader(var DataExch: Record "Data Exch."; var OutStr: OutStream; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeAddFooter(var DataExch: Record "Data Exch."; var OutStr: OutStream; var IsHandled: Boolean);
    begin
    end;
}