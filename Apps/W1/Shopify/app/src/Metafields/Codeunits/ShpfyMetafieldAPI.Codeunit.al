namespace Microsoft.Integration.Shopify;

codeunit 30316 "Shpfy Metafield API"
{
    Access = Internal;

    var
        JsonHelper: Codeunit "Shpfy Json Helper";

    #region To Shopify
    /// <summary>
    /// Creates or updates the metafields in Shopify.
    /// </summary>
    /// <remarks>
    /// Only metafields that have been updated in BC since last update in Shopify will be updated.
    /// MetafieldSet mutation only accepts 25 metafields at a time, so the function will create multiple queries if needed.
    /// </remarks>
    /// <param name="ParentTableId"></param>
    /// <param name="OwnerId"></param>
    internal procedure CreateOrUpdateMetafieldsInShopify(ParentTableId: Integer; OwnerId: BigInteger)
    var
        TempMetafieldSet: Record "Shpfy Metafield" temporary;
        MetafieldIds: Dictionary of [BigInteger, DateTime];
        Continue: Boolean;
        Count: Integer;
        GraphQuery: TextBuilder;
    begin
        MetafieldIds := RetrieveMetafieldsFromShopify(ParentTableId, OwnerId);
        CollectMetafieldsInBC(ParentTableId, OwnerId, TempMetafieldSet, MetafieldIds);

        // MetafieldsSet mutation only accepts 25 metafields at a time
        Continue := true;
        if TempMetafieldSet.FindSet() then
            while Continue do begin
                Count := 0;
                Continue := false;
                GraphQuery.Clear();

                repeat
                    if Count = GetMaxMetafieldsToUpdate() then begin
                        Continue := true;
                        Clear(Count);
                        break;
                    end;

                    CreateMetafieldQuery(TempMetafieldSet, GraphQuery);
                    Count += 1;
                until TempMetafieldSet.Next() = 0;

                UpdateMetafields(GraphQuery.ToText());
            end;
    end;

    local procedure GetMaxMetafieldsToUpdate(): Integer
    begin
        exit(25);
    end;

    local procedure RetrieveMetafieldsFromShopify(ParentTableId: Integer; OwnerId: BigInteger): Dictionary of [BigInteger, DateTime]
    var
        Metafield: Record "Shpfy Metafield";
        IMetafieldOwnerType: Interface "Shpfy IMetafield Owner Type";
    begin
        IMetafieldOwnerType := Metafield.GetOwnerType(ParentTableId);
        exit(IMetafieldOwnerType.RetrieveMetafieldIdsFromShopify(OwnerId));
    end;

    local procedure CollectMetafieldsInBC(ParentTableId: Integer; OwnerId: BigInteger; var TempMetafieldSet: Record "Shpfy Metafield" temporary; MetafieldIds: Dictionary of [BigInteger, DateTime])
    var
        Metafield: Record "Shpfy Metafield";
        UpdatedAt: DateTime;
    begin
        Metafield.SetRange("Parent Table No.", ParentTableId);
        Metafield.SetRange("Owner Id", OwnerId);
        if Metafield.FindSet() then
            repeat
                if MetafieldIds.Get(Metafield.Id, UpdatedAt) then begin
                    if Metafield."Last Updated by BC" > UpdatedAt then begin
                        TempMetafieldSet := Metafield;
                        TempMetafieldSet.Insert(false);
                    end;
                end else begin
                    TempMetafieldSet := Metafield;
                    TempMetafieldSet.Insert(false);
                end;
            until Metafield.Next() = 0;
    end;

    /// <summary>
    /// Updates the metafields in Shopify.
    /// </summary>
    /// <param name="MetafieldsQuery">GraphQL query for the metafields.</param>
    internal procedure UpdateMetafields(MetafieldsQuery: Text) JResponse: JsonToken
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        Parameters: Dictionary of [Text, Text];
    begin
        Parameters.Add('Metafields', MetafieldsQuery);
        JResponse := CommunicationMgt.ExecuteGraphQL(Enum::"Shpfy GraphQL Type"::MetafieldSet, Parameters);
    end;

    /// <summary>
    /// Creates a GraphQL query for a metafield.
    /// </summary>
    /// <param name="MetafieldSet">Metafield record to create the query for.</param>
    /// <param name="GraphQuery">Return value: TextBuilder to append the query to.</param>
    internal procedure CreateMetafieldQuery(MetafieldSet: Record "Shpfy Metafield"; GraphQuery: TextBuilder)
    begin
        GraphQuery.Append('{');
        GraphQuery.Append('key: \"');
        GraphQuery.Append(MetafieldSet.Name);
        GraphQuery.Append('\",');
        GraphQuery.Append('namespace: \"');
        GraphQuery.Append(MetafieldSet."Namespace");
        GraphQuery.Append('\",');
        GraphQuery.Append('ownerId: \"gid://shopify/');
        GraphQuery.Append(MetafieldSet.GetOwnerTypeName());
        GraphQuery.Append('/');
        GraphQuery.Append(Format(MetafieldSet."Owner Id"));
        GraphQuery.Append('\",');
        GraphQuery.Append('value: \"');
        GraphQuery.Append(EscapeGrapQLData(MetafieldSet.Value));
        GraphQuery.Append('\",');
        GraphQuery.Append('type: \"');
        GraphQuery.Append(GetTypeName(MetafieldSet.Type));
        GraphQuery.Append('\"');
        GraphQuery.Append('},');
    end;

    local procedure EscapeGrapQLData(Data: Text): Text
    begin
        exit(Data.Replace('\', '\\\\').Replace('"', '\\\"'));
    end;

    local procedure GetTypeName(Type: Enum "Shpfy Metafield Type"): Text
    begin
        exit(Enum::"Shpfy Metafield Type".Names().Get(Enum::"Shpfy Metafield Type".Ordinals().IndexOf(Type.AsInteger())));
    end;
    #endregion

    #region From Shopify
    /// <summary>
    /// Updates the metafields in Business Central from Shopify.
    /// </summary>
    /// <remarks>
    /// Metafields with a value longer than 2048 characters will not be imported.
    /// Some metafield types are unsupported in Business Central (i.e. Rating).
    ///</remarks>
    /// <param name="JMetafields">JSON array of metafields from Shopify.</param>
    /// <param name="ParentTableNo">Table id of the parent resource.</param>
    /// <param name="OwnerId">Id of the parent resource.</param>
    internal procedure UpdateMetafieldsFromShopify(JMetafields: JsonArray; ParentTableNo: Integer; OwnerId: BigInteger)
    var
        JNode: JsonObject;
        JItem: JsonToken;
        MetafieldIds: List of [BigInteger];
        MetafieldId: BigInteger;
    begin
        CollectMetafieldIds(OwnerId, MetafieldIds);

        foreach JItem in JMetafields do begin
            JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node');
            MetafieldId := UpdateMetadataField(ParentTableNo, OwnerId, JNode);
            MetafieldIds.Remove(MetafieldId);
        end;

        DeleteUnusedMetafields(MetafieldIds);
    end;

    local procedure UpdateMetadataField(ParentTableNo: Integer; OwnerId: BigInteger; JNode: JsonObject): BigInteger
    var
        Metafield: Record "Shpfy Metafield";
        ValueText: Text;
        Type: Enum "Shpfy Metafield Type";
    begin
        // Shopify has no limit on the length of the value, but Business Central has a limit of 2048 characters.
        // If the value is longer than 2048 characters, Metafield is not imported.
        ValueText := JsonHelper.GetValueAsText(JNode, 'value');
        if StrLen(ValueText) > MaxStrLen(Metafield.Value) then
            exit(0);

        // Some metafield types are unsupported in Business Central (i.e. Rating)
        if not ConvertToMetafieldType(JsonHelper.GetValueAsText(JNode, 'type'), Type) then
            exit(0);


        Metafield.Validate("Parent Table No.", ParentTableNo);
        Metafield."Owner Id" := OwnerId;
        Metafield.Id := JsonHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');
        Metafield.Type := Type;
#pragma warning disable AA0139
        Metafield."Namespace" := JsonHelper.GetValueAsText(JNode, 'namespace');
        Metafield.Name := JsonHelper.GetValueAsText(JNode, 'key');
        Metafield.Value := ValueText;
#pragma warning restore AA0139
        if not Metafield.Modify(false) then
            Metafield.Insert(false);

        exit(Metafield.Id);
    end;

    local procedure ConvertToMetafieldType(Value: Text; var Type: Enum "Shpfy Metafield Type"): Boolean
    var
        EnumOrdinal: Integer;
    begin
        // Some metafield types are unsupported in Business Central (i.e. Rating)
        if not Enum::"Shpfy Metafield Type".Ordinals().Get(Enum::"Shpfy Metafield Type".Names().IndexOf(Value), EnumOrdinal) then
            exit(false);

        Type := Enum::"Shpfy Metafield Type".FromInteger(EnumOrdinal);
        exit(true);
    end;

    local procedure CollectMetafieldIds(ProductId: BigInteger; MetafieldIds: List of [BigInteger])
    var
        Metafield: Record "Shpfy Metafield";
    begin
        MetaField.SetRange("Parent Table No.", Database::"Shpfy Product");
        Metafield.SetRange("Owner Id", ProductId);
        if Metafield.FindSet() then
            repeat
                MetafieldIds.Add(Metafield.Id);
            until Metafield.Next() = 0;
    end;

    local procedure DeleteUnusedMetafields(MetafieldIds: List of [BigInteger])
    var
        Metafield: Record "Shpfy Metafield";
        MetafieldId: BigInteger;
    begin
        foreach MetafieldId in MetafieldIds do begin
            Metafield.Get(MetafieldId);
            Metafield.Delete(false);
        end;
    end;
    #endregion
}