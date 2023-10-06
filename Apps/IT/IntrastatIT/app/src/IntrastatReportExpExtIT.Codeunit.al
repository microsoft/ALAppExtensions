// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using System.IO;
using System.Utilities;

codeunit 148122 "Intrastat Report Exp. Ext. IT"
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
                OutStr.WriteText(GetHeader());
                OutStr.WriteText();
            end;

            CopyStream(OutStr, InStr);
        end;
    end;

    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportMgtIT: Codeunit "Intrastat Report Management IT";
        EUROXLbl: Label 'EUROX', Locked = true;

    local procedure GetHeader() HeaderText: Text;
    var
        CompanyInfo: Record "Company Information";
        Vendor: Record Vendor;
    begin
        CompanyInfo.Get();
        IntrastatReportHeader := IntrastatReportMgtIT.GetIntrastatHeader();

        HeaderText := EUROXLbl;
        HeaderText += IntrastatReportMgtIT.GetCompanyRepresentativeVATNo();
        HeaderText += Format(IntrastatReportHeader."File Disk No.").PadLeft(6, '0');
        HeaderText += Format('').PadLeft(6, '0');
        HeaderText += GetTypeText(IntrastatReportHeader);
        HeaderText += CopyStr(IntrastatReportHeader."Statistics Period", 1, 2).PadLeft(2, '0');
        HeaderText += GetPeriodicityText(IntrastatReportHeader);
        HeaderText += CopyStr(IntrastatReportHeader."Statistics Period", 3, 2).PadLeft(2, '0');
        HeaderText += IntrastatReportMgtIT.RemoveLeadingCountryCode(CompanyInfo."VAT Registration No.", CompanyInfo."Country/Region Code").PadLeft(11, '0');
        HeaderText += '00';
        if Vendor.Get(CompanyInfo."Tax Representative No.") then
            HeaderText += IntrastatReportMgtIT.RemoveLeadingCountryCode(Vendor."VAT Registration No.", Vendor."Country/Region Code").PadLeft(11, '0')
        else
            HeaderText += Format('').PadLeft(11, '0');
        HeaderText += GetTotals();
    end;

    local procedure GetTypeText(IntrastatReportHeader: Record "Intrastat Report Header"): Text
    begin
        if IntrastatReportHeader.Type = IntrastatReportHeader.Type::Sales then
            exit('C')
        else
            exit('A');
    end;

    local procedure GetPeriodicityText(IntrastatReportHeader: Record "Intrastat Report Header"): Text
    begin
        if IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Month then
            exit('M')
        else
            if IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Quarter then
                exit('T');
    end;

    local procedure GetTotals(): Text
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        OutText: Text;
        Length: Integer;
        Amount, LineCount : Integer;
    begin
        IntrastatReportMgtIT.GetTotals(Amount, LineCount);
        if IntrastatReportHeader."Corrective Entry" then begin
            OutText += Format('').PadLeft(18, '0');
            OutText += Format(LineCount).PadLeft(5, '0');

            IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
            IntrastatReportLine.CalcSums(Amount);
            if IntrastatReportLine.Amount > 0 then
                OutText += Format(Amount).PadLeft(13, '0')
            else
                OutText += ConvertLastDigit(Format(Amount).PadLeft(13, '0'));

            OutText += Format('').PadLeft(36, '0');
        end else begin
            OutText += Format(LineCount).PadLeft(5, '0');
            OutText += Format(Amount).PadLeft(13, '0');

            if IntrastatReportHeader.Type = IntrastatReportHeader.Type::Purchases then
                Length := 49
            else
                Length := 54;

            OutText += Format('').PadLeft(Length, '0');
        end;
        OutText += Format('').PadLeft(5, '0');
        exit(OutText);
    end;

    local procedure ConvertLastDigit(TotalAmount: Text[13]): Text[13]
    var
        OutText: Text[13];
        LastDigit: Text[1];
    begin
        LastDigit := CopyStr(TotalAmount, 13, 1);
        OutText := CopyStr(TotalAmount, 1, 12);
        case LastDigit of
            '0':
                OutText += 'p';
            '1':
                OutText += 'q';
            '2':
                OutText += 'r';
            '3':
                OutText += 's';
            '4':
                OutText += 't';
            '5':
                OutText += 'u';
            '6':
                OutText += 'v';
            '7':
                OutText += 'w';
            '8':
                OutText += 'x';
            '9':
                OutText += 'y';
        end;
        exit(OutText);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeAddHeader(var DataExch: Record "Data Exch."; var OutStr: OutStream; var IsHandled: Boolean);
    begin
    end;
}