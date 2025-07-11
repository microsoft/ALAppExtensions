// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using System.IO;
using System.Utilities;

codeunit 10892 "Local Serv. Decl. Exp. Ext."
{
    TableNo = "Data Exch.";

    var
        ExternalContentErr: Label '%1 is empty.', Comment = '%1 - File Content';
        DownloadFromStreamErr: Label 'The file has not been saved.';

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        Rec.CalcFields("File Content");
        if not Rec."File Content".HasValue() then
            Error(ExternalContentErr, Rec.FieldCaption("File Content"));
        TempBlob.FromRecord(Rec, Rec.FieldNo("File Content"));
        ExportToFile(Rec, TempBlob, 'ServiceDeclaration.xml');
    end;

    local procedure ExportToFile(DataExch: Record "Data Exch."; var TempBlob: Codeunit "Temp Blob"; FileName: Text)
    var
        FileMgt: Codeunit "File Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeExportToFile(DataExch, TempBlob, FileName, IsHandled);
        if IsHandled then
            exit;

        if FileMgt.BLOBExport(TempBlob, FileName, true) = '' then
            Error(DownloadFromStreamErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportToFile(DataExch: Record "Data Exch."; var TempBlob: Codeunit "Temp Blob"; var FileName: Text; var Handled: Boolean)
    begin
    end;
}
