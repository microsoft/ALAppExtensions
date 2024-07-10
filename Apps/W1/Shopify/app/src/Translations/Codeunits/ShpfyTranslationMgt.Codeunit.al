namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

codeunit 30314 "Shpfy Translation Mgt."
{

    /// <summary>
    /// Returns the translation of an item or item variant.
    /// </summary>
    /// <param name="ItemNo">Item No to find translation for.</param>
    /// <param name="VariantCode">Variant Code to find translation for.</param>
    /// <param name="LanguageCode">Language Code to find translation for.</param>
    /// <returns>Translation of the item or item variant, or blank if not found.</returns>
    internal procedure GetItemTranslation(ItemNo: Code[20]; VariantCode: Code[10]; LanguageCode: Code[10]): Text[100]
    var
        ItemTranslation: Record "Item Translation";
    begin
        ItemTranslation.SetRange("Item No.", ItemNo);
        ItemTranslation.SetRange("Language Code", LanguageCode);
        ItemTranslation.SetRange("Variant Code", VariantCode);
        if ItemTranslation.FindFirst() then
            exit(ItemTranslation.Description);
    end;



}