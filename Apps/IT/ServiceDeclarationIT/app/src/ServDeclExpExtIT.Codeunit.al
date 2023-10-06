// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using System.IO;
using System.Utilities;

codeunit 12214 "Serv. Decl. Exp. Ext. IT"
{
    TableNo = "Data Exch.";

    var
        LocalServiceDeclarationMgt: Codeunit "Service Declaration Mgt. IT";
        EUROXLbl: Label 'EUROX', Locked = true;
        ExternalContentErr: Label '%1 is empty.', Comment = '%1 - File Content';
        FileNameLbl: Label 'ServiceDeclaration.cee', Locked = true;
        DownloadFromStreamErr: Label 'The file has not been saved.';

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        IsHandled: Boolean;
    begin
        Rec.CalcFields("File Content");
        if not Rec."File Content".HasValue() then
            Error(ExternalContentErr, Rec.FieldCaption("File Content"));

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

        TempBlob.FromRecord(Rec, Rec.FieldNo("File Content"));
        ExportToFile(Rec, TempBlob, FileNameLbl);
    end;

    local procedure ExportToFile(DataExch: Record "Data Exch."; var TempBlob: Codeunit "Temp Blob"; FileName: Text)
    var
        InStr: InStream;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeExportToFile(DataExch, TempBlob, FileName, IsHandled);
        if IsHandled then
            exit;

        TempBlob.CreateInStream(InStr);
        if not DownloadFromStream(InStr, '', '', '', FileName) then
            Error(DownloadFromStreamErr);
    end;

    local procedure GetHeader(DataExch: Record "Data Exch.") HeaderText: Text;
    var
        CompanyInfo: Record "Company Information";
        ServiceDeclarationHeader: Record "Service Declaration Header";
        ServiceDeclarationLine: Record "Service Declaration Line";
        Vendor: Record Vendor;
        InStr: InStream;
        ViewText: Text;
    begin
        CompanyInfo.Get();

        DataExch.CalcFields("Table Filters");
        DataExch."Table Filters".CreateInStream(InStr);
        InStr.ReadText(ViewText);
        ServiceDeclarationLine.SetView(ViewText);
        ServiceDeclarationHeader.Get(ServiceDeclarationLine.GetFilter("Service Declaration No."));

        HeaderText := EUROXLbl;
        HeaderText += LocalServiceDeclarationMgt.GetCompanyRepresentativeVATNo();
        HeaderText += Format(ServiceDeclarationHeader."File Disk No.").PadLeft(6, '0');
        HeaderText += Format('').PadLeft(6, '0');
        HeaderText += GetTypeText(ServiceDeclarationHeader);
        HeaderText += CopyStr(ServiceDeclarationHeader."Statistics Period", 1, 2).PadLeft(2, '0');
        HeaderText += GetPeriodicityText(ServiceDeclarationHeader);
        HeaderText += CopyStr(ServiceDeclarationHeader."Statistics Period", 3, 2).PadLeft(2, '0');
        HeaderText += LocalServiceDeclarationMgt.RemoveLeadingCountryCode(CompanyInfo."VAT Registration No.", CompanyInfo."Country/Region Code").PadLeft(11, '0');
        HeaderText += '00';
        if Vendor.Get(CompanyInfo."Tax Representative No.") then
            HeaderText += LocalServiceDeclarationMgt.RemoveLeadingCountryCode(Vendor."VAT Registration No.", Vendor."Country/Region Code").PadLeft(11, '0')
        else
            HeaderText += Format('').PadLeft(11, '0');
        HeaderText += GetTotals(ServiceDeclarationHeader);
    end;

    local procedure GetTypeText(ServiceDeclarationHeader: Record "Service Declaration Header"): Text
    begin
        if ServiceDeclarationHeader.Type = ServiceDeclarationHeader.Type::Sales then
            exit('C')
        else
            exit('A');
    end;

    local procedure GetPeriodicityText(ServiceDeclarationHeader: Record "Service Declaration Header"): Text
    begin
        if ServiceDeclarationHeader.Periodicity = ServiceDeclarationHeader.Periodicity::Month then
            exit('M')
        else
            if ServiceDeclarationHeader.Periodicity = ServiceDeclarationHeader.Periodicity::Quarter then
                exit('T');
    end;

    local procedure GetTotals(ServiceDeclarationHeader: Record "Service Declaration Header"): Text
    var
        OutText: Text;
        Amount, LineCount : Integer;
    begin
        LocalServiceDeclarationMgt.GetTotals(Amount, LineCount);

        if ServiceDeclarationHeader."Corrective Entry" then begin
            OutText += Format('').PadLeft(54, '0');
            OutText += Format(LineCount).PadLeft(5, '0');
            OutText += Format(Amount).PadLeft(13, '0');
        end else begin
            OutText += Format('').PadLeft(36, '0');
            OutText += Format(LineCount).PadLeft(5, '0');
            OutText += Format(Amount).PadLeft(13, '0');

            if ServiceDeclarationHeader.Type = ServiceDeclarationHeader.Type::Purchases then
                OutText += Format('').PadLeft(13, '0')
            else
                OutText += Format('').PadLeft(18, '0');
        end;

        OutText += Format('').PadLeft(5, '0');
        exit(OutText);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeAddHeader(var DataExch: Record "Data Exch."; var OutStr: OutStream; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportToFile(DataExch: Record "Data Exch."; var TempBlob: Codeunit "Temp Blob"; var FileName: Text; var Handled: Boolean)
    begin
    end;
}
