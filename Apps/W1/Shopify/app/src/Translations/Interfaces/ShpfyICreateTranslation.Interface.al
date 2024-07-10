namespace Microsoft.Integration.Shopify;

interface "Shpfy ICreate Translation"
{
    Access = Internal;

    /// <summary>
    /// Create a translation record for the given resource and language.
    /// Translation record is only created if the translation is not already present in the Shopify.
    /// These records are used to create the query for updating the translation in Shopify.
    /// </summary>
    /// <param name="RecVariant">Variant record of the resource for which the translation is to be created.</param>
    /// <param name="ShpfyLanguage">Language record for which the translation is to be created.</param>
    /// <param name="TempTranslation">Temporary translation record set where the translation will be stored.</param>
    /// <param name="Digests">Dictionary of translatable content digests for the resource.</param>
    procedure CreateTranslation(RecVariant: Variant; ShpfyLanguage: Record "Shpfy Language"; var TempTranslation: Record "Shpfy Translation" temporary; Digests: Dictionary of [Text, Text])
}