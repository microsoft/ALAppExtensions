namespace Microsoft.SubscriptionBilling;

using System.Globalization;
using System.Reflection;

table 8000 "Field Translation"
{
    Caption = 'Field Translation';
    DataClassification = CustomerContent;
    DrillDownPageId = "Field Translations";
    LookupPageId = "Field Translations";
    Access = Internal;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            NotBlank = true;
        }
        field(3; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language.Code;
            NotBlank = true;
        }
        field(4; "Source SystemId"; Guid)
        {
            Caption = 'Source SystemId';
            NotBlank = true;
        }
        field(10; Translation; Text[250])
        {
            Caption = 'Translation';

            trigger OnValidate()
            var
                tblField: Record Field;
                TranslationTooLongErr: Label 'The length of the translation must not exceed %1 characters (current length: %2).';
            begin
                if Translation <> '' then begin
                    Rec.TestField("Table ID");
                    Rec.TestField("Field No.");
                    tblField.Get("Table ID", "Field No.");
                    if StrLen(Rec.Translation) > tblField.Len then
                        Error(TranslationTooLongErr, tblField.Len, StrLen(Rec.Translation));
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Field No.", "Language Code", "Source SystemId")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Table ID", "Field No.", "Language Code", Translation) { }
        fieldgroup(Brick; "Language Code", Translation) { }
    }

    trigger OnInsert()
    begin
        Rec.TestField("Table ID");
        Rec.TestField("Field No.");
        Rec.TestField("Language Code");
        Rec.TestField("Source SystemId");
    end;

    procedure GetSourceText() SourceText: Text
    var
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        SourceText := '';
        if (Rec."Table ID" <> 0) and (Rec."Field No." <> 0) then begin
            RecRef.Open("Table ID");
            if RecRef.GetBySystemId(Rec."Source SystemId") then begin
                FRef := RecRef.Field(Rec."Field No.");
                SourceText := Format(FRef.Value());
            end;
            RecRef.Close();
        end;
    end;

    procedure GetNumberOfTranslations(SourceRecord: Variant; TargetFieldID: Integer): Integer
    begin
        if not FilterTranslationsForField(SourceRecord, TargetFieldID) then
            exit(0);
        exit(Rec.Count());
    end;

    procedure OpenTranslationsForField(SourceRecord: Variant; TargetFieldID: Integer)
    begin
        if not FilterTranslationsForField(SourceRecord, TargetFieldID) then
            exit;
        Page.RunModal(0, Rec);
    end;

    procedure DeleteRelatedTranslations(SourceRecord: Variant; TargetFieldID: Integer)
    begin
        if not FilterTranslationsForField(SourceRecord, TargetFieldID) then
            exit;
        if not Rec.IsEmpty() then
            Rec.DeleteAll(true);
    end;

    local procedure FilterTranslationsForField(SourceRecord: Variant; TargetFieldID: Integer): Boolean
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        if TargetFieldID = 0 then
            exit(false);
        if not DataTypeMgt.GetRecordRef(SourceRecord, RecRef) then
            exit(false);
        FRef := RecRef.Field(RecRef.SystemIdNo);
        Rec.Reset();
        Rec.SetRange("Table ID", RecRef.Number);
        Rec.SetRange("Field No.", TargetFieldID);
        Rec.SetRange("Source SystemId", FRef.Value);
        exit(true);
    end;

    procedure FindTranslation(SourceRecord: Variant; TargetFieldID: Integer; LanguageCode: Code[10]): Text
    var
        WindowsLanguage: Record "Windows Language";
        DataTypeMgt: Codeunit "Data Type Management";
        Language: Codeunit Language;
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        DataTypeMgt.GetRecordRef(SourceRecord, RecRef);
        if LanguageCode <> '' then begin
            FilterTranslationsForField(SourceRecord, TargetFieldID);
            Rec.SetRange("Language Code", LanguageCode);
            if Rec.FindFirst() then
                exit(Rec.Translation);
            if WindowsLanguage.Get(Language.GetLanguageId(LanguageCode)) then begin
                Rec.SetRange("Language Code", Language.GetLanguageCode(WindowsLanguage."Primary Language ID"));
                if Rec.FindFirst() then
                    exit(Rec.Translation);
            end;
        end;
        FRef := RecRef.Field(TargetFieldID);
        exit(FRef.Value);
    end;
}