// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3712 "Translation Implementation"
{
    Access = Internal;

    var
        NoRecordIdErr: Label 'The variant passed is not a record.';

    [Scope('OnPrem')]
    procedure Any(): Boolean
    var
        Translation: Record Translation;
    begin
        exit(not Translation.IsEmpty());
    end;

    [Scope('OnPrem')]
    procedure GetForLanguageOrFirst("Record": Variant; FieldId: Integer; LanguageId: Integer; FindAlternative: Boolean): Text
    var
        Translation: Record Translation;
        RecordId: RecordID;
    begin
        GetRecordIdFromVariant(Record, RecordId);
        if Translation.Get(LanguageId, RecordId, FieldId) then
            exit(Translation.Value);

        if FindAlternative then begin
            Translation.SetRange("Record ID", RecordId);
            Translation.SetRange("Field ID", FieldId);
            if Translation.FindFirst() then
                exit(Translation.Value);
        end;
    end;

    [Scope('OnPrem')]
    procedure GetForLanguage("Record": Variant; FieldId: Integer; LanguageId: Integer): Text
    begin
        exit(GetForLanguageOrFirst(Record, FieldId, LanguageId, false));
    end;

    [Scope('OnPrem')]
    procedure Set("Record": Variant; FieldId: Integer; Value: Text[2048])
    begin
        SetForLanguage(Record, FieldId, GlobalLanguage(), Value);
    end;

    [Scope('OnPrem')]
    procedure SetForLanguage("Record": Variant; FieldId: Integer; LanguageId: Integer; Value: Text[2048])
    var
        Translation: Record Translation;
        RecordId: RecordID;
        Exists: Boolean;
    begin
        GetRecordIdFromVariant(Record, RecordId);
        Exists := Translation.Get(LanguageId, RecordId, FieldId);
        if Exists then begin
            Translation.Value := Value;
            Translation.Modify(true);
        end else begin
            Translation.Init();
            Translation."Language ID" := LanguageId;
            Translation."Record ID" := RecordId;
            Translation."Table ID" := RecordId.TableNo();
            Translation."Field ID" := FieldId;
            Translation.Value := Value;
            Translation.Insert(true);
        end;
    end;

    [Scope('OnPrem')]
    procedure Delete("Record": Variant)
    var
        Translation: Record Translation;
        RecordRef: RecordRef;
    begin
        GetRecordRefFromVariant(Record, RecordRef);
        if RecordRef.IsTemporary() then
            exit;

        Translation.SetRange("Record ID", RecordRef.RecordId());
        Translation.DeleteAll(true);
    end;

    [Scope('OnPrem')]
    procedure Rename("Record": Variant; OldRecordID: RecordID)
    var
        Translation: Record Translation;
        RecordRef: RecordRef;
    begin
        GetRecordRefFromVariant(Record, RecordRef);
        if RecordRef.IsTemporary() then
            exit;

        Translation.SetRange("Record ID", OldRecordID);
        if Translation.FindSet() then
            repeat
                Translation.Rename(Translation."Language ID", RecordRef.RecordId(), Translation."Field ID");
            until Translation.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure Show("Record": Variant; FieldId: Integer)
    var
        Translation: Record Translation;
        TranslationPage: Page Translation;
        RecordId: RecordID;
    begin
        GetRecordIdFromVariant(Record, RecordId);
        Translation.SetRange("Record ID", RecordId);
        Translation.SetRange("Field ID", FieldId);
        TranslationPage.SetCaption(Format(RecordId));
        TranslationPage.SetTableView(Translation);
        TranslationPage.Run();
    end;

    [Scope('OnPrem')]
    procedure ShowForAllRecords(TableId: Integer; FieldId: Integer)
    var
        Translation: Record Translation;
    begin
        Translation.SetRange("Table ID", TableId);
        Translation.SetRange("Field ID", FieldId);
        PAGE.Run(PAGE::Translation, Translation);
    end;

    local procedure GetRecordIdFromVariant("Record": Variant; var RecordID: RecordID)
    var
        RecordRef: RecordRef;
    begin
        GetRecordRefFromVariant(Record, RecordRef);
        RecordID := RecordRef.RecordId();
    end;

    local procedure GetRecordRefFromVariant("Record": Variant; var RecordRef: RecordRef)
    begin
        if Record.IsRecord() then begin
            RecordRef.GetTable(Record);
            exit;
        end;

        if Record.IsRecordRef() then begin
            RecordRef := Record;
            exit;
        end;

        Error(NoRecordIdErr);
    end;
}

