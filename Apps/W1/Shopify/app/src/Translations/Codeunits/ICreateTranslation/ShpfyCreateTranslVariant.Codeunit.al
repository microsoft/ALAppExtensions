namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

codeunit 30313 "Shpfy Create Transl. Variant" implements "Shpfy ICreate Translation"
{
    Access = Internal;

    procedure CreateTranslation(RecVariant: Variant; ShpfyLanguage: Record "Shpfy Language"; var TempTranslation: Record "Shpfy Translation" temporary; Digests: Dictionary of [Text, Text])
    var
        ItemVariant: Record "Item Variant";
        TranslationMgt: Codeunit "Shpfy Translation Mgt.";
        TranslationText: Text;
        TranslationKey: Text;
        Digest: Text;
    begin
        ItemVariant := RecVariant;

        TranslationText := TranslationMgt.GetItemTranslation(ItemVariant."Item No.", ItemVariant.Code, ShpfyLanguage."Language Code");
        TranslationKey := 'option1';
        if Digests.Get(TranslationKey, Digest) and (TranslationText <> '') then
            TempTranslation.AddTranslation(ShpfyLanguage.Locale, TranslationKey, Digests.Get(TranslationKey), TranslationText);
    end;
}