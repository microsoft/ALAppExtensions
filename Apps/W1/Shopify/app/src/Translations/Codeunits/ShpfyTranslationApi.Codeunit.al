namespace Microsoft.Integration.Shopify;

codeunit 30213 "Shpfy Translation API"
{

    #region Shop Locales
    /// <summary>
    /// Retrieves the languages for a shop from Shopify and updates the table with the new languages. 
    /// </summary>
    /// <remarks>
    /// Primary language is skipped as it is handled by the Shop."Language Code" field.
    /// </remarks>
    internal procedure PullLanguages(ShopCode: Code[20])
    var
        ShpfyLanguage: Record "Shpfy Language";
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        JLocales: JsonArray;
        JLocale: JsonToken;
        LocaleText: Text[2];
        IsPrimary: Boolean;
        CurrentLocales: List of [Text[2]];
    begin
        Shop.Get(ShopCode);
        CommunicationMgt.SetShop(Shop.Code);

        GraphQLType := GraphQLType::ShopLocales;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType);

        CurrentLocales := CollectLocales(Shop.Code);

        JsonHelper.GetJsonArray(JResponse, JLocales, 'data.shopLocales');
        foreach JLocale in JLocales do begin
            CurrentLocales.Remove(LocaleText);
            LocaleText := CopyStr(JsonHelper.GetValueAsText(JLocale, 'locale'), 1, MaxStrLen(LocaleText));
            IsPrimary := JsonHelper.GetValueAsBoolean(JLocale, 'primary');

            if not IsPrimary then // Primary language is handled by Shop."Language Code"
                if not ShpfyLanguage.Get(Shop.Code, LocaleText) then
                    ShpfyLanguage.AddLanguage(Shop, LocaleText);
        end;

        foreach LocaleText in CurrentLocales do begin
            ShpfyLanguage.Get(Shop.Code, LocaleText);
            ShpfyLanguage.Delete(true);
        end;
    end;

    local procedure CollectLocales(ShopCode: Code[20]) Locales: List of [Text[2]]
    var
        ShpfyLanguage: Record "Shpfy Language";
    begin
        ShpfyLanguage.SetRange("Shop Code", ShopCode);
        if ShpfyLanguage.FindSet() then
            repeat
                Locales.Add(ShpfyLanguage.Locale);
            until ShpfyLanguage.Next() = 0;
    end;
    #endregion

    #region Translations
    /// <summary>
    /// Creates or updates a translation for a product in Shopify.
    /// </summary>
    /// <param name="ProductId">Product Id in Shopify</param>
    /// <param name="TempTranslation">Temporary record set with product translations</param>
    internal procedure CreateOrUpdateTranslations(var TempTranslation: Record "Shpfy Translation" temporary): JsonToken
    var
        GraphQuery: TextBuilder;
    begin
        if TempTranslation.FindSet() then begin
            repeat
                CreateTranslationGraphQuery(TempTranslation, GraphQuery);
            until TempTranslation.Next() = 0;

            exit(UpdateTranslations(GetResourceTypeName(TempTranslation."Resource Type"), TempTranslation."Resource ID", GraphQuery.ToText()));
        end;
    end;

    local procedure CreateTranslationGraphQuery(var TempTranslation: Record "Shpfy Translation" temporary; GraphQuery: TextBuilder): Text
    begin
        GraphQuery.Append('{');
        GraphQuery.Append('key: \"');
        GraphQuery.Append(TempTranslation.Name);
        GraphQuery.Append('\",');
        GraphQuery.Append('locale: \"');
        GraphQuery.Append(TempTranslation.Locale);
        GraphQuery.Append('\",');
        GraphQuery.Append('value: \"');
        GraphQuery.Append(EscapeGrapQLData(TempTranslation.GetValue()));
        GraphQuery.Append('\",');
        GraphQuery.Append('translatableContentDigest: \"');
        GraphQuery.Append(TempTranslation."Transl. Content Digest");
        GraphQuery.Append('\",');
        GraphQuery.Append('},');
    end;

    local procedure EscapeGrapQLData(Data: Text): Text
    begin
        exit(Data.Replace('\', '\\\\').Replace('"', '\\\"'));
    end;

    local procedure GetResourceTypeName(Type: Enum "Shpfy Resource Type"): Text
    begin
        exit(Type.Names().Get(Type.Ordinals().IndexOf(Type.AsInteger())));
    end;

    local procedure UpdateTranslations(ResourceType: Text; ResourceId: BigInteger; TranslationsQuery: Text): JsonToken
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
    begin
        Parameters.Add('ResourceType', ResourceType);
        Parameters.Add('ResourceId', Format(ResourceId));
        Parameters.Add('Translations', TranslationsQuery);

        GraphQLType := GraphQLType::TranslationsRegister;
        exit(CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters));
    end;
    #endregion

    #region Translatable Resources

    /// <summary>
    /// Retrieves the translatable content digests for a resource in Shopify.
    /// </summary>
    /// <param name="ResourceType">Type of the resource to retrieve the digests</param>
    /// <param name="ResourceId">Id of the resource to retrieve the digests</param>
    /// <returns>Dictionary with the translatable content digests</returns>
    internal procedure RetrieveTranslatableContentDigests(ResourceType: Enum "Shpfy Resource Type"; ResourceId: BigInteger) Digests: Dictionary of [Text, Text]
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        JTranslatablesContents: JsonArray;
        JTranslatableContent: JsonToken;
    begin
        Parameters.Add('ResourceType', GetResourceTypeName(ResourceType));
        Parameters.Add('ResourceId', Format(ResourceId));

        GraphQLType := GraphQLType::GetTranslResource;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);

        if not JsonHelper.IsNull(JResponse, 'data.translatableResource') then begin
            JsonHelper.GetJsonArray(JResponse, JTranslatablesContents, 'data.translatableResource.translatableContent');
            foreach JTranslatableContent in JTranslatablesContents do
                Digests.Add(JsonHelper.GetValueAsText(JTranslatableContent, 'key'), JsonHelper.GetValueAsText(JTranslatableContent, 'digest'));
        end;
    end;
    #endregion
}