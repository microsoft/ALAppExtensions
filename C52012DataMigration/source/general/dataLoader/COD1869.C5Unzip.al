// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1869 "C5 Unzip"
{
    TableNo = "Name/Value Buffer";

    var
        SomethingWentWrongErr: Label 'Oops, something went wrong.\Please try again later.';  
        EmptyZipFileErr: Label 'Oops, it seems the zip file does not contain any files.';
        ZipFileMissingErrorTxt: Label 'There was an error on uploading the zip file.';
        ZipExtractionErrorTxt: Label 'There was an error on extracting the zip file.';
        UnzipFileErr: Label 'There was an error on uziping the file. Please try again and if this error persists try creating the zip file again.';

    trigger OnRun();
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
        FileManagement: Codeunit "File Management";
        UnzipLocation: Text;
    begin
        C5SchemaParameters.GetSingleInstance();
        if not FileManagement.ServerFileExists(C5SchemaParameters."Zip File") then begin
            OnZipFileMissing();
            Error(SomethingWentWrongErr);
        end;

        UnzipLocation := FileManagement.ServerCreateTempSubDirectory();
        if not FileManagement.ServerDirectoryExists(UnzipLocation) then begin
            OnExtractFolderMissing();
            Error(SomethingWentWrongErr);
        end;

        if not FileManagement.ExtractZipFile(C5SchemaParameters."Zip File", UnzipLocation) then begin
            OnUnzipFileError();
            Error(UnzipFileErr);
        end;

        FileManagement.GetServerDirectoryFilesListInclSubDirs(Rec, UnzipLocation);
        if Rec.FindFirst() then begin
            C5SchemaParameters."Unziped Folder" := CopyStr(FileManagement.GetDirectoryName(Rec.Name), 1, 250);
            C5SchemaParameters.Modify();
        end else begin
            OnEmptyZipFile();
            Error(EmptyZipFileErr);
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnZipFileMissing()
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

    [IntegrationEvent(false, false)]
    local procedure OnEmptyZipFile()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Unzip", 'OnEmptyZipFile', '', false, false)] 
    local procedure OnEmptyZipFileSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001DF', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, EmptyZipFileErr, DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Unzip", 'OnUnzipFileError', '', false, false)] 
    local procedure OnUnzipFileErrorSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001IL', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, GetLastErrorText(), DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Unzip", 'OnZipFileMissing', '', false, false)] 
    local procedure OnZipFileMissingSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001DD', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, ZipFileMissingErrorTxt, DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Unzip", 'OnExtractFolderMissing', '', false, false)] 
    local procedure OnExtractFolderMissingSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001DE', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, ZipExtractionErrorTxt, DataClassification::SystemMetadata);
    end;

}
