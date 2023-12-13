// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148060 "OIOUBL-File Events Mock"
{
    EventSubscriberInstance = Manual;

    trigger OnRun();
    begin
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    procedure Setup(me: Codeunit "OIOUBL-File Events Mock")
    begin
        LibraryVariableStorage.Clear();
        if UnbindSubscription(me) then;
        BindSubscription(me);
    end;

    procedure PopFilePath(): Text
    begin
        LibraryVariableStorage.AssertPeekAvailable(1);
        exit(LibraryVariableStorage.DequeueText())
    end;

    procedure TearDown(me: Codeunit "OIOUBL-File Events Mock")
    begin
        UnbindSubscription(me);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"OIOUBL-File Events", 'FileCreatedEvent', '', false, false)]
    local procedure SavePathOnFileCreatedEvent(FilePath: Text)
    begin
        LibraryVariableStorage.Enqueue(FilePath);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"OIOUBL-File Events", 'OnBlobCreatedEvent', '', false, false)]
    local procedure SavePathOnBlobCreatedEvent(var TempBlob: Codeunit "Temp Blob")
    var
        FileManagement: Codeunit "File Management";
        FilePath: Text;
    begin
        FilePath := FileManagement.ServerTempFileName('xml');
        FileManagement.BLOBExportToServerFile(TempBlob, FilePath);
        LibraryVariableStorage.Enqueue(FilePath);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"File Management", 'OnBeforeDownloadHandler', '', false, false)]
    local procedure SavePathOnBeforeDownloadHandler(var ToFolder: Text; ToFileName: Text; FromFileName: Text; var IsHandled: Boolean)
    begin
        LibraryVariableStorage.Enqueue(FromFileName);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"File Management", 'OnBeforeBlobExport', '', false, false)]
    local procedure SavePathOnBeforeBlobExportHandler(var TempBlob: Codeunit "Temp Blob"; Name: Text; CommonDialog: Boolean; var IsHandled: Boolean)
    var
        FileManagement: Codeunit "File Management";
        FilePath: Text;
    begin
        FilePath := FileManagement.ServerTempFileName(FileManagement.GetExtension(Name));
        FileManagement.BLOBExportToServerFile(TempBlob, FilePath);
        LibraryVariableStorage.Enqueue(FilePath);
        IsHandled := true;
    end;

}

