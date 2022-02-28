// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Implements the "Data Archive Provider" and hence the main parts of the archiving functionality
/// </summary>
codeunit 605 "Data Archive Provider" implements "Data Archive Provider"
{
    Access = Internal;
    Permissions = tabledata "Data Archive" = rimd,
                  tabledata "Data Archive Table" = rimd,
                  tabledata "Data Archive Media Field" = rimd;

    var
        DataArchive: Record "Data Archive";
        DataArchiveDbSubscriber: Codeunit "Data Archive Db Subscriber";
        DataArchiveProvider: Interface "Data Archive Provider";
        CachedDataTableIndex: Dictionary of [Integer, Integer];
        CachedDataTableList: List of [Integer];
        CachedDataRecords: Dictionary of [Integer, JsonArray];
        DataArchiveDbSubscriberBound: Boolean;
        CurrentDataArchiveEntryNo: Integer;
        DataArchiveCategoryLbl: Label 'Data Archive', Locked = true;
        DataArchiveTableLbl: Label 'Archived %1 records from table %2.', Locked = true;
        NotArecordErr: Label 'The function only accepts a record as parameter.';

    procedure Create(Description: Text): Integer
    begin
        DataArchive.Init();
        DataArchive.Description := CopyStr(Description, 1, MaxStrLen(DataArchive.Description));
        DataArchive.Insert(true);
        CurrentDataArchiveEntryNo := DataArchive."Entry No.";
        exit(CurrentDataArchiveEntryNo);
    end;

    procedure Open(ID: Integer)
    begin
        DataArchive.Get(ID);
        CurrentDataArchiveEntryNo := ID;
    end;

    procedure Save()
    var
        TableNo: Integer;
        i: Integer;
    begin
        for i := 1 to CachedDataTableList.Count() do begin
            CachedDataTableList.Get(i, TableNo);
            SaveTable(i, TableNo);
        end;
        Clear(CachedDataTableIndex);
        Clear(CachedDataRecords);
    end;

    local procedure SaveTable(TableIndex: integer; TableNo: Integer)
    var
        DataArchiveTable: Record "Data Archive Table";
    begin
        DataArchiveTable.SetRange("Data Archive Entry No.", DataArchive."Entry No.");
        DataArchiveTable.SetRange("Table No.", TableNo);
        DataArchiveTable.LockTable();
        if DataArchiveTable.FindLast() then;
        DataArchiveTable.Init();
        DataArchiveTable."Data Archive Entry No." := DataArchive."Entry No.";
        DataArchiveTable."Table No." := TableNo;
        DataArchiveTable."Entry No." += 1;
        DataArchiveTable.Insert(true);
        SetTableSchema(DataArchiveTable);
        SetTableContentFromCache(DataArchiveTable, TableIndex);
        DataArchiveTable.Modify(true);
        Session.LogMessage('0000FG3', StrSubstNo(DataArchiveTableLbl, DataArchiveTable."No. of Records", DataArchiveTable."Table No."), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DataArchiveCategoryLbl);
    end;

    procedure DiscardChanges()
    begin
        Clear(CachedDataTableIndex);
        Clear(CachedDataRecords);
    end;


    procedure SaveRecord(RecordVar: Variant)
    var
        RecRef: RecordRef;
    begin
        if not RecordVar.IsRecord then
            Error(NotArecordErr);
        RecRef.GetTable(RecordVar);
        SaveRecord(RecRef);
    end;

    procedure SaveRecord(var RecRef: RecordRef)
    begin
        SaveRecordsToBuffer(RecRef, false);
    end;

    procedure SaveRecords(var RecRef: RecordRef)
    begin
        SaveRecordsToBuffer(RecRef, true);
    end;

    local procedure SaveRecordsToBuffer(var RecRef2: RecordRef; AllWithinFilter: Boolean)
    var
        RecRef: RecordRef;
        TableJson: JsonArray;
        FieldList: List of [Integer];
        TableIndex: Integer;
    begin
        if RecRef2.Number in [Database::"Data Archive", Database::"Data Archive Table", Database::"Data Archive Media Field"] then
            exit;
        if AllWithinFilter then begin
            RecRef.Open(RecRef2.Number);
            RecRef.Copy(RecRef2);
        end else
            RecRef := RecRef2;
        if not CachedDataTableIndex.Get(RecRef.Number, TableIndex) then begin
            TableIndex := CachedDataTableIndex.Count + 1;
            CachedDataTableIndex.Add(RecRef.Number, TableIndex);
            CachedDataTableList.Add(RecRef.Number);
        end;
        GetFieldListFromTable(RecRef.Number, FieldList);
        if CachedDataRecords.Count >= TableIndex then
            CachedDataRecords.Get(TableIndex, TableJson);
        if AllWithinFilter then begin
            if RecRef.FindSet() then
                repeat
                    TableJson.Add(GetRecordJsonFromRecRef(RecRef, FieldList));
                until RecRef.Next() = 0;
        end else
            TableJson.Add(GetRecordJsonFromRecRef(RecRef, FieldList));
        if CachedDataRecords.Count >= TableIndex then
            CachedDataRecords.Set(TableIndex, TableJson)
        else
            CachedDataRecords.Add(TableIndex, TableJson);
        if TableJson.Count() >= 10000 then
            SaveTable(TableIndex, RecRef.Number);
    end;

    procedure StartSubscriptionToDelete()
    begin
        StartSubscriptionToDelete(true);
    end;

    procedure StartSubscriptionToDelete(ResetSession: Boolean)
    var
        SessionSettings: SessionSettings;
    begin
        if DataArchiveDbSubscriberBound then
            exit;
        if ResetSession then
            SessionSettings.RequestSessionUpdate(false);
        DataArchiveDbSubscriber.SetDataArchiveProvider(DataArchiveProvider);
        BindSubscription(DataArchiveDbSubscriber);
        DataArchiveDbSubscriberBound := true;
    end;

    procedure StopSubscriptionToDelete()
    begin
        if not DataArchiveDbSubscriberBound then
            exit;
        UnBindSubscription(DataArchiveDbSubscriber);
        DataArchiveDbSubscriberBound := false;
    end;

    procedure SetDataArchiveProvider(var NewDataArchiveProvider: Interface "Data Archive Provider")
    begin
        DataArchiveProvider := NewDataArchiveProvider;
    end;

    procedure DataArchiveProviderExists(): Boolean
    begin
        exit(true);
    end;

    local procedure GetRecordJsonFromRecRef(var RecRef: RecordRef; var FieldList: List of [Integer]): JsonArray
    var
        FldRef: FieldRef;
        RecordJson: JsonArray;
        FieldJson: JsonObject;
        FieldNo: Integer;
        FieldValueAsText: Text;
    begin

        foreach FieldNo in FieldList do begin
            Clear(FieldJson);
            FldRef := RecRef.Field(FieldNo);
            case format(FldRef.Type) of
                'Option', 'Text', 'Code':
                    FieldValueAsText := format(FldRef.Value);
                'Blob':
                    FieldValueAsText := format(SaveBlobToArchiveMedia(FldRef));
                'Media':
                    FieldValueAsText := format(SaveMediaToArchiveMedia(FldRef));
                'MediaSet':
                    FieldValueAsText := format(SaveMediaToArchiveMediaSet(FldRef));
                else
                    FieldValueAsText := format(FldRef.Value, 0, 9);
            end;

            FieldJson.Add(format(FieldNo, 0, 9), FieldValueAsText);
            RecordJson.Add(FieldJson);
        end;
        exit(RecordJson);
    end;

    local procedure SaveBlobToArchiveMedia(var FldRef: FieldRef): Integer
    var
        DataArchiveMediaField: Record "Data Archive Media Field";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
    begin
        TempBlob.FromFieldRef(FldRef);
        if not TempBlob.HasValue() then
            exit(0);
        TempBlob.CreateInStream(InStr);
        DataArchiveMediaField.InsertNewMedia(InStr, FldRef.Record(), CurrentDataArchiveEntryNo);
        exit(DataArchiveMediaField."Entry No.");
    end;

    local procedure SaveMediaToArchiveMedia(var FldRef: FieldRef): Integer
    var
        DataArchiveMediaField: Record "Data Archive Media Field";
        ItemPictureBuffer: Record "Item Picture Buffer";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        ItemPictureBuffer.Picture := FldRef.Value;
        if not ItemPictureBuffer.Picture.HasValue() then
            exit(0);
        TempBlob.CreateOutStream(OutStr);
        ItemPictureBuffer.Picture.ExportStream(OutStr);
        TempBlob.CreateInStream(InStr);
        DataArchiveMediaField.InsertNewMedia(InStr, FldRef.Record(), CurrentDataArchiveEntryNo);
        exit(DataArchiveMediaField."Entry No.");
    end;

    local procedure SaveMediaToArchiveMediaSet(var FldRef: FieldRef): Integer
    var
        DataArchiveMediaField: Record "Data Archive Media Field";
        ConfigMediaBuffer: Record "Config. Media Buffer";
        TenantMedia: Record "Tenant Media";
        InStr: InStream;
    begin
        ConfigMediaBuffer."Media Set" := FldRef.Value;
        if ConfigMediaBuffer."Media Set".Count = 0 then
            exit(0);
        TenantMedia.SetRange("Company Name", CompanyName);
        TenantMedia.SetRange(ID, ConfigMediaBuffer."Media Set".Item(1));
        TenantMedia.SetAutoCalcfields(Content);
        if not TenantMedia.FindFirst() then
            exit(0);
        if not TenantMedia.Content.HasValue then
            exit(0);
        TenantMedia.Content.CreateInStream(Instr);
        DataArchiveMediaField.InsertNewMedia(InStr, FldRef.Record(), CurrentDataArchiveEntryNo);
        exit(DataArchiveMediaField."Entry No.");
    end;

    local procedure SetTableSchema(var DataArchiveTable: Record "Data Archive Table");
    var
        Field: Record Field;
        TempBlob: codeunit "Temp Blob";
        SchemaJson: JsonArray;
        FieldJson: JsonObject;
        InStr: InStream;
        OutStr: OutStream;
        FieldList: List of [Integer];
        FieldNo: Integer;
    begin
        GetFieldListFromTable(DataArchiveTable."Table No.", FieldList);
        foreach FieldNo in FieldList do begin
            Field.Get(DataArchiveTable."Table No.", FieldNo);
            Clear(FieldJson);
            FieldJson.Add('FieldNumber', format(Field."No.", 0, 9));
            FieldJson.Add('FieldName', Field.FieldName);
            FieldJson.Add('DataType', format(Field.Type));
            FieldJson.Add('DataLength', format(Field.Len, 0, 9));
            SchemaJson.Add(FieldJson);
        end;
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        SchemaJson.WriteTo(OutStr);
        TempBlob.CreateInStream(InStr);
        DataArchiveTable."Table Fields (json)".ImportStream(InStr, '');
    end;

    local procedure GetFieldListFromTable(TableNo: Integer; var FieldList: List of [Integer]);
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableNo);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Clear(FieldList);
        if Field.FindSet() then
            repeat
                FieldList.Add(Field."No.");
            until Field.Next() = 0;
    end;

    local procedure SetTableContentFromCache(var DataArchiveTable: Record "Data Archive Table"; TableIndex: Integer);
    var
        TempBlob: codeunit "Temp Blob";
        jsonArray: JsonArray;
        InStr: InStream;
        OutStr: OutStream;
        RecordAsText: Text;
    begin
        CachedDataRecords.Get(TableIndex, jsonArray);
        jsonArray.WriteTo(RecordAsText);
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(RecordAsText);
        TempBlob.CreateInStream(InStr);
        DataArchiveTable."Table Data (json)".ImportStream(InStr, DataArchiveTable.Description);
        DataArchiveTable."No. of Records" := jsonArray.Count();
        Clear(jsonArray);
        CachedDataRecords.Set(TableIndex, jsonArray);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Archive", 'OnDataArchiveImplementationExists', '', false, false)]
    local procedure OnDataArchiveImplementationExists(var Exists: Boolean)
    begin
        Exists := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Archive", 'OnDataArchiveImplementationBind', '', false, false)]
    local procedure OnDataArchiveImplementationBind(var IDataArchiveProvider: Interface "Data Archive Provider"; var IsBound: Boolean)
    var
        NewDataArchiveProvider: Codeunit "Data Archive Provider";
    begin
        if IsBound then
            exit;
        IDataArchiveProvider := NewDataArchiveProvider;
        IsBound := true;
    end;
}