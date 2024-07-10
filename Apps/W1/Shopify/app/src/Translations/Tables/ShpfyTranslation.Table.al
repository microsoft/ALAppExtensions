namespace Microsoft.Integration.Shopify;

using System.Reflection;

table 30157 "Shpfy Translation"
{
    Access = Internal;
    Caption = 'Shopify Translation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Resource Type"; Enum "Shpfy Resource Type")
        {
            Caption = 'Resource Type';
            DataClassification = SystemMetadata;
        }

        field(2; "Resource ID"; BigInteger)
        {
            Caption = 'Resource ID';
            DataClassification = SystemMetadata;
        }
        field(3; "Locale"; text[2])
        {
            Caption = 'Locale';
            DataClassification = SystemMetadata;
        }

        field(4; Name; Text[100])
        {
            Caption = 'Key';
            DataClassification = SystemMetadata;
        }
        field(5; Value; Blob)
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
        field(6; "Transl. Content Digest"; Text[100])
        {
            Caption = 'Transl. Content Digest';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Resource Type", "Resource ID", Locale, Name)
        {
            Clustered = true;
        }
    }

    /// <summary> 
    /// Gets the value of the translation as text
    /// </summary>
    /// <returns>Translation value as text</returns>
    internal procedure GetValue(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(Value);
        Value.CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    /// <summary> 
    /// Sets the value of the translation
    /// </summary>
    /// <param name="NewTranslation">New value of the translation</param>
    internal procedure SetValue(NewTranslation: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Value);
        Value.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewTranslation);
        if Modify(true) then;
    end;

    /// <summary>
    /// Adds a new translation to the record if it's different than the one in the database. 
    /// Resource Type and Id should be already set wher calling this function.
    /// </summary>
    /// <param name="NewLocale">Locale of the translation</param>
    /// <param name="TranslationKey">Key used to destingiush translations in Shopify</param>
    /// <param name="Digest">Digest of the original translatable content</param>
    /// <param name="TranslationText">Text of the translation</param>
    internal procedure AddTranslation(NewLocale: Text[2]; TranslationKey: Text; Digest: Text; TranslationText: Text)
    begin
        Rec.Locale := NewLocale;
        Rec.Name := CopyStr(TranslationKey, 1, MaxStrLen(Rec.Name));
        Rec."Transl. Content Digest" := CopyStr(Digest, 1, MaxStrLen(Rec."Transl. Content Digest"));
        Rec.Insert(false);

        Rec.SetValue(TranslationText);
        if not HasTranslationChanged(Rec) then
            Rec.Delete(false);
    end;

    /// <summary>
    /// Determines if the translation of an item or item variant has changed since last sync.
    /// </summary>
    /// <param name="TempTranslation">Temporary record containing the new translations.</param>
    /// <returns>True if the translation has changed, false otherwise.</returns>
    local procedure HasTranslationChanged(var TempTranslation: Record "Shpfy Translation" temporary): Boolean
    var
        ShpfyTranslation: Record "Shpfy Translation";
        TranslationValue: Text;
    begin
        TranslationValue := TempTranslation.GetValue();
        if TranslationValue = '' then
            exit(false);

        ShpfyTranslation := TempTranslation;
        if ShpfyTranslation.Find() then begin
            if ShpfyTranslation.GetValue() <> TranslationValue then begin
                ShpfyTranslation.SetValue(TranslationValue);
                exit(true);
            end;
        end else begin
            ShpfyTranslation.Insert(true);
            exit(true);
        end;
    end;
}