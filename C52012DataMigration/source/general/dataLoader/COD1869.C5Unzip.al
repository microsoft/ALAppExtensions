// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1869 "C5 Unzip"
{
    TableNo = "Name/Value Buffer";

    var
        SomethingWentWrongErr: Label 'Oops, something went wrong.\Please try again later.';
        ZipExtractionErrorTxt: Label 'There was an error on extracting the zip file.';

    trigger OnRun();
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
        ZipFileInStream: InStream;
    begin
        C5SchemaParameters.GetSingleInstance();

        if not C5SchemaParameters."Zip File Blob".HasValue() then begin
            OnZipFileBlobMissing();
            Error(SomethingWentWrongErr);
        end;

        C5SchemaParameters.CalcFields("Zip File Blob");
        C5SchemaParameters."Zip File Blob".CreateInStream(ZipFileInStream);
        if not CreateNameValueBuffer(ZipFileInStream, Rec) then begin
            OnUnzipFileError();
            Error(ZipExtractionErrorTxt);
        end;
    end;

    /*Create NameValueBuffer where Name is a FileName and Value is the content of it saved as Stream */
    local procedure CreateNameValueBuffer(var ZipFileInStream: InStream; var NameValueBufferOut: Record "Name/Value Buffer"): Boolean
    var
        StreamManagement: Codeunit "Stream Management";
    begin
        if not StreamManagement.CreateNameValueBufferFromZipFileStream(ZipFileInStream, NameValueBufferOut) then
            exit(false);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    procedure OnZipFileBlobMissing()
    begin

    end;

    [IntegrationEvent(false, false)]
    procedure OnUnzipFileError()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExtractFolderMissing()
    begin
    end;
}
