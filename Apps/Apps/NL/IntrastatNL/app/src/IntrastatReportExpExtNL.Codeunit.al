// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Company;
using Microsoft.Utilities;
using System.IO;
using System.Utilities;

codeunit 11427 "Intrastat Report Exp. Ext. NL"
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
            OutStr.WriteText();

            IsHandled := false;
            OnBeforeAddFooter(Rec, OutStr, IsHandled);
            if not IsHandled then
                OutStr.WriteText(GetFooter());
            Rec.Modify(true);
        end;
    end;

    var
        IntrastatReportManagementNL: Codeunit "Intrastat Report Management NL";
        LocalFunctionalityMgt: Codeunit "Local Functionality Mgt.";

    local procedure GetHeader() HeaderText: Text;
    var
        CompanyInfo: Record "Company Information";
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        CompanyInfo.Get();
        IntrastatReportHeader := IntrastatReportManagementNL.GetIntrastatHeader();

        HeaderText := '9801' +
            CopyStr(CompanyInfo."VAT Registration No.", StrLen(CompanyInfo."VAT Registration No.") - 11) +
            Format(Date2DMY(Today, 3)).Substring(1, 2) + IntrastatReportHeader."Statistics Period" +
            CompanyInfo.Name.PadRight(40) +
            '971635' + '20004' +
            Format(Today, 0, '<Year4><Month,2><Day,2>') +
            Format(Time, 0, '<Hours24,2><Minutes,2><Seconds,2>') +
            CopyStr(LocalFunctionalityMgt.ConvertPhoneNumber(CompanyInfo."Phone No."), 1, 15).PadRight(15) +
            Format('').PadRight(13);
    end;

    local procedure GetFooter() FooterText: Text;
    begin
        FooterText := Format('9899').PadRight(115, ' ');
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