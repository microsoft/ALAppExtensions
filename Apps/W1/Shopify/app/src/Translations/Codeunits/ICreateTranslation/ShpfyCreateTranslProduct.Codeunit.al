namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

codeunit 30342 "Shpfy Create Transl. Product" implements "Shpfy ICreate Translation"
{
    Access = Internal;

    procedure CreateTranslation(RecVariant: Variant; ShpfyLanguage: Record "Shpfy Language"; var TempTranslation: Record "Shpfy Translation" temporary; Digests: Dictionary of [Text, Text])
    var
        Item: Record Item;
        TranslationMgt: Codeunit "Shpfy Translation Mgt.";
        ProductExport: Codeunit "Shpfy Product Export";
        TranslationText: Text;
        TranslationKey: Text[100];
        Digest: Text;
    begin
        Item := RecVariant;

        TranslationText := TranslationMgt.GetItemTranslation(Item."No.", '', ShpfyLanguage."Language Code");
        TranslationKey := 'title';
        if Digests.Get(TranslationKey, Digest) and (TranslationText <> '') then
            TempTranslation.AddTranslation(ShpfyLanguage.Locale, TranslationKey, Digests.Get(TranslationKey), TranslationText);

        TranslationKey := 'body_html';
        TranslationText := ProductExport.CreateProductBody(Item."No.", ShpfyLanguage."Language Code");
        if Digests.Get(TranslationKey, Digest) and (TranslationText <> '') then
            TempTranslation.AddTranslation(ShpfyLanguage.Locale, TranslationKey, Digest, TranslationText);
    end;
}