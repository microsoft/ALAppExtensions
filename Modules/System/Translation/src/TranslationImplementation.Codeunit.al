// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3712 "Translation Implementation"
{
    Access = Internal;
    Permissions = tabledata Translation = rimd;

    var
        NoRecordIdErr: Label 'The variant passed is not a record.';
        CannotTranslateTempRecErr: Label 'Translations cannot be added or retrieved for temporary records.';
        NotAValidRecordForTranslationErr: Label 'Translations cannot be added for the record on table %1.', Comment = '%1 - Table number';
        DifferentTableErr: Label 'The records cannot belong to different tables.';

    procedure Any(): Boolean
    var
        Translation: Record Translation;
    begin
        exit(not Translation.IsEmpty());
    end;

    procedure Get(RecVariant: Variant; FieldId: Integer; LanguageId: Integer; FallbackToWindows: Boolean): Text
    var
        Translation: Record Translation;
        SystemId: Guid;
        TableNo: Integer;
    begin
        GetSystemIdFromVariant(RecVariant, SystemId, TableNo);
        if Translation.Get(LanguageId, SystemId, FieldId) then
            exit(Translation.Value);

        if FallbackToWindows then
            if Translation.Get(WindowsLanguage(), SystemId, FieldId) then
                exit(Translation.Value);

        exit('');
    end;

    procedure Get(RecVariant: Variant; FieldId: Integer; LanguageId: Integer): Text
    begin
        exit(Get(RecVariant, FieldId, LanguageId, false));
    end;

    procedure Set(RecVariant: Variant; FieldId: Integer; Value: Text[2048])
    begin
        Set(RecVariant, FieldId, GlobalLanguage(), Value);
    end;

    procedure Set(RecVariant: Variant; FieldId: Integer; LanguageId: Integer; Value: Text[2048])
    var
        Translation: Record Translation;
        SystemId: Guid;
        TableNo: Integer;
        Exists: Boolean;
    begin
        GetSystemIdFromVariant(RecVariant, SystemId, TableNo);
        Exists := Translation.Get(LanguageId, SystemId, FieldId);
        if Exists then begin
            if Translation.Value <> Value then begin
                Translation.Value := Value;
                Translation.Modify(true);
            end;
        end else begin
            Translation.Init();
            Translation."Language ID" := LanguageId;
            Translation."System ID" := SystemId;
            Translation."Table ID" := TableNo;
            Translation."Field ID" := FieldId;
            Translation.Value := Value;
            Translation.Insert(true);
        end;
    end;

    procedure Delete(RecVariant: Variant)
    var
        Translation: Record Translation;
    begin
        DeleteTranslations(RecVariant, Translation);
    end;

    procedure Delete(RecVariant: Variant; FieldId: Integer)
    var
        Translation: Record Translation;
    begin
        Translation.SetRange("Field ID", FieldId);
        DeleteTranslations(RecVariant, Translation);
    end;

    procedure Delete(TableID: Integer)
    var
        Translation: Record Translation;
    begin
        Translation.SetRange("Table ID", TableID);
        Translation.DeleteAll(true);
    end;

    procedure Copy(FromRecVariant: Variant; ToRecVariant: Variant; FieldId: Integer)
    var
        Translation: Record Translation;
        FromRecordRef: RecordRef;
        ToRecordRef: RecordRef;
    begin
        GetRecordRefFromVariant(FromRecVariant, FromRecordRef);
        GetRecordRefFromVariant(ToRecVariant, ToRecordRef);
        if FromRecordRef.Number() <> ToRecordRef.Number() then
            Error(DifferentTableErr);
        Translation.SetRange("System Id", GetSystemIdFromRecordRef(FromRecordRef));
        Translation.SetRange("Table ID", FromRecordRef.Number());
        if FieldId <> 0 then
            Translation.SetRange("Field ID", FieldId);
        if Translation.FindSet() then
            repeat
                Set(ToRecVariant, Translation."Field ID", Translation."Language ID", Translation.Value);
            until Translation.Next() = 0;
    end;

    procedure Copy(FromRecVariant: Variant; FromFieldId: Integer; ToRecVariant: Variant; ToFieldId: Integer)
    var
        Translation: Record Translation;
        FromRecordRef: RecordRef;
    begin
        GetRecordRefFromVariant(FromRecVariant, FromRecordRef);
        Translation.SetRange("System Id", GetSystemIdFromRecordRef(FromRecordRef));
        Translation.SetRange("Field ID", FromFieldId);
        if Translation.FindSet() then
            repeat
                Set(ToRecVariant, ToFieldId, Translation."Language ID", Translation.Value);
            until Translation.Next() = 0;
    end;

    local procedure DeleteTranslations(RecVariant: Variant; var TranslationWithFilters: Record Translation)
    var
        RecordRef: RecordRef;
    begin
        GetRecordRefFromVariant(RecVariant, RecordRef);

        TranslationWithFilters.SetRange("Table ID", RecordRef.Number());
        TranslationWithFilters.SetRange("System ID", GetSystemIdFromRecordRef(RecordRef));
        TranslationWithFilters.DeleteAll(true);
    end;

    procedure Show(RecVariant: Variant; FieldId: Integer)
    var
        Translation: Record Translation;
        TranslationPage: Page Translation;
        SystemID: Guid;
        TableNo: Integer;
    begin
        GetSystemIdFromVariant(RecVariant, SystemID, TableNo);
        Translation.SetRange("System ID", SystemID);
        Translation.SetRange("Field ID", FieldId);
        TranslationPage.SetTableId(TableNo);
        TranslationPage.SetCaption(GetRecordIdCaptionFromVariant(RecVariant));
        TranslationPage.SetTableView(Translation);
        TranslationPage.Run();
    end;

    procedure ShowForAllRecords(TableId: Integer; FieldId: Integer)
    var
        Translation: Record Translation;
    begin
        Translation.SetRange("Table ID", TableId);
        Translation.SetRange("Field ID", FieldId);
        PAGE.Run(PAGE::Translation, Translation);
    end;

    local procedure GetRecordIdCaptionFromVariant(RecVariant: Variant): Text
    var
        RecordRef: RecordRef;
        RecordId: RecordId;
    begin
        GetRecordRefFromVariant(RecVariant, RecordRef);
        RecordId := RecordRef.RecordId();
        exit(Format(RecordId, 0, 1));
    end;

    local procedure GetSystemIdFromVariant(RecVariant: Variant; var SystemId: Guid; var TableNo: Integer)
    var
        RecordRef: RecordRef;
    begin
        GetRecordRefFromVariant(RecVariant, RecordRef);
        SystemId := GetSystemIdFromRecordRef(RecordRef);
        TableNo := RecordRef.Number();
    end;

    local procedure GetSystemIdFromRecordRef(RecordRef: RecordRef) SystemId: Guid
    begin
        Evaluate(SystemId, Format(RecordRef.Field(RecordRef.SystemIdNo()).Value())); // TODO: Uptake new method to directly get SystemID from record ref as soon as it is available
    end;

    local procedure GetRecordRefFromVariant(RecVariant: Variant; var RecordRef: RecordRef)
    begin
        if RecVariant.IsRecord() then begin
            RecordRef.GetTable(RecVariant);
            if RecordRef.IsTemporary() then
                Error(CannotTranslateTempRecErr);
            if RecordRef.Number() = 0 then
                Error(NotAValidRecordForTranslationErr, 0);
            exit;
        end;

        if RecVariant.IsRecordRef() then begin
            RecordRef := RecVariant;
            exit;
        end;

        Error(NoRecordIdErr);
    end;
}
