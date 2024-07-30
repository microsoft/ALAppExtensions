namespace Microsoft.Integration.Shopify;

using System.Globalization;

table 30156 "Shpfy Language"
{
    Caption = 'Shopify Language';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Shpfy Shop";
        }

        field(2; Locale; text[2])
        {
            Caption = 'Locale';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(3; "Sync Translations"; Boolean)
        {
            Caption = 'Sync translations';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec.TestField("Language Code");
            end;
        }
        field(4; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec.TestField("Sync Translations", false);
            end;
        }
    }

    keys
    {
        key(PK; "Shop Code", Locale)
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Adds a language to the table.
    /// </summary>
    /// <param name="Shop">Shop the language belongs to.</param>
    /// <param name="LocaleText">Locale of the language.</param>
    internal procedure AddLanguage(Shop: Record "Shpfy Shop"; NewLocale: Text[2])
    var
        ShpfyLanguage: Record "Shpfy Language";
    begin
        ShpfyLanguage.Init();
        ShpfyLanguage."Shop Code" := Shop.Code;
        ShpfyLanguage.Locale := NewLocale;
        ShpfyLanguage.Insert(true);
    end;
}