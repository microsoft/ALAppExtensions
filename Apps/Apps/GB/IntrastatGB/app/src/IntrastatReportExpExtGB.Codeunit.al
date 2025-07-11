// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Company;
using System.IO;
using System.Utilities;

codeunit 10502 "Intrastat Report Exp. Ext. GB"
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

            Rec.Modify(true);
        end;
    end;

    var
        IntrastatReportManagementGB: Codeunit "Intrastat Report Management GB";
        WorkDateFormatTxt: Label '<Day,2><Month,2><Year,2>', Locked = true;

    local procedure GetHeader(var DataExch: Record "Data Exch.") HeaderText: Text;
    var
        CompanyInfo: Record "Company Information";
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportLineFilters: Text;
        FileType, HasData : Text[1];
        InStreamFilters: InStream;
    begin
        CompanyInfo.Get();

        DataExch."Table Filters".CreateInStream(InStreamFilters, TextEncoding::Windows);
        InStreamFilters.ReadText(IntrastatReportLineFilters);
        IntrastatReportLine.SetView(IntrastatReportLineFilters);
        if IntrastatReportLine.GetFilter(Type) = Format(IntrastatReportLine.Type::Receipt) then
            FileType := 'A'
        else
            FileType := 'D';

        if IntrastatReportLine.IsEmpty() then
            HasData := 'N'
        else
            HasData := 'X';

        IntrastatReportHeader := IntrastatReportManagementGB.GetIntrastatHeader();

        HeaderText := 'T,';
        HeaderText += CompanyInfo."VAT Registration No." + ',';
        HeaderText += ',';
        HeaderText += CopyStr(CompanyInfo.Name, 1, 30) + ',';
        HeaderText += HasData + ',';
        HeaderText += FileType + ',';
        HeaderText += Format(WorkDate(), 0, WorkDateFormatTxt) + ',';
        HeaderText += CopyStr(IntrastatReportHeader."Statistics Period", 3, 2) + CopyStr(IntrastatReportHeader."Statistics Period", 1, 2) + ',';
        HeaderText += 'CSV02';
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeAddHeader(var DataExch: Record "Data Exch."; var OutStr: OutStream; var IsHandled: Boolean);
    begin
    end;

}