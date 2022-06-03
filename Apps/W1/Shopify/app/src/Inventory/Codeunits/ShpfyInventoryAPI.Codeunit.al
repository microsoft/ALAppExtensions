/// <summary>
/// Codeunit Shpfy Inventory API (ID 30195).
/// </summary>
codeunit 30195 "Shpfy Inventory API"
{
    Access = Internal;
    Permissions =
        tabledata Item = r,
        tabledata "Item Unit of Measure" = r;

    var
        ShopifyShop: Record "Shpfy Shop";
        ShopifyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        Events: Codeunit "Shpfy Inventory Events";
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary> 
    /// Get Stock.
    /// </summary>
    /// <param name="ShopInventory">Parameter of type Record "Shopify Shop Inventory".</param>
    /// <returns>Return variable "Stock" of type Decimal.</returns>
    internal procedure GetStock(ShopInventory: Record "Shpfy Shop Inventory") Stock: Decimal
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        ShopLocation: Record "Shpfy Shop Location";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ItemAvailMgt: Codeunit "Item Availability Forms Mgt";
        IsHandled: Boolean;
        UOM: Code[10];
        ExpectedInventory: Decimal;
        GrossRequirement: Decimal;
        PlannedOrderRcpt: Decimal;
        PlannedOrderReleases: Decimal;
        ProjAvailableBalance: Decimal;
        QtyAvailable: Decimal;
        ScheduledRcpt: Decimal;
    begin
        SetShop(ShopInventory."Shop Code");
        if ShopifyProduct.Get(ShopInventory."Product Id") and ShopifyVariant.Get(ShopInventory."Variant Id") then begin
            ShopLocation.SetRange("Shop Code", ShopInventory."Shop Code");
            ShopLocation.SetRange(Id, ShopInventory."Location Id");
            ShopLocation.SetRange(Disabled, false);
            if ShopLocation.FindFirst() and Item.GetBySystemId(ShopifyVariant."Item SystemId") then begin
                Events.OnBeforeCalculationStock(Item, ShopifyShop, ShopLocation."Location Filter", ShopInventory."Shopify Stock", Stock, IsHandled);
                if not IsHandled then begin
                    Item.SetRange("Date Filter", 0D, Today);
                    Item.SetFilter("Location Filter", ShopLocation."Location Filter");
                    if not IsNullGuid(ShopifyVariant."Item Variant SystemId") then begin
                        ShopifyVariant.CalcFields("Variant Code");
                        Item.SetFilter("Variant Filter", ShopifyVariant."Variant Code");
                    end;
                    ItemAvailMgt.CalcAvailQuantities(Item, true, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable);
                    Stock := ProjAvailableBalance;
                    case ShopifyVariant."UoM Option Id" of
                        1:
                            UOM := CopyStr(ShopifyVariant."Option 1 Value", 1, MaxStrLen(UOM));
                        2:
                            UOM := CopyStr(ShopifyVariant."Option 1 Value", 2, MaxStrLen(UOM));
                        3:
                            UOM := CopyStr(ShopifyVariant."Option 1 Value", 3, MaxStrLen(UOM));
                        else
                            UOM := Item."Sales Unit of Measure";
                    end;
                    if (UOM <> '') and (UOM <> Item."Base Unit of Measure") then
                        if ItemUOM.Get(Item."No.", UOM) then
                            Stock := Stock / ItemUOM."Qty. per Unit of Measure";
                    Events.OnAfterCalculationStock(Item, ShopifyShop, ShopLocation."Location Filter", Stock);
                end;
            end;
        end;
    end;

    /// <summary> 
    /// Create Stock As Json.
    /// </summary>
    /// <param name="ShopInventory">Parameter of type Record "Shopify Shop Inventory".</param>
    /// <param name="ShopLocation">Parameter of type Record "Shopify Shop Location".</param>
    /// <returns>Return variable "JInventoryItem" of type JsonObject.</returns>
    local procedure CreateStockAsJson(var ShopInventory: Record "Shpfy Shop Inventory"; ShopLocation: Record "Shpfy Shop Location") JInventoryItem: JsonObject
    var
        Item: Record Item;
        ShopifyVariant: Record "Shpfy Variant";
        Ishandled: Boolean;
    begin
        if ShopifyVariant.Get(ShopInventory."Variant Id") then
            if Item.GetBySystemId(ShopifyVariant."Item SystemId") then begin
                Events.OnBeforeExportStock(Item, ShopifyShop, ShopInventory, ShopLocation, Ishandled);

                if not Ishandled then begin
                    JInventoryItem.Add('location_id', ShopInventory."Location Id");
                    JInventoryItem.Add('inventory_item_id', ShopInventory."Inventory Item Id");
                    ShopInventory.Validate(Stock, Round(GetStock(ShopInventory), 1, '<'));
                    ShopInventory.Modify();
                    JInventoryItem.Add('available', ShopInventory.Stock);
                end;
            end;

    end;


    /// <summary> 
    /// Export Stock.
    /// </summary>
    /// <param name="ShopInventory">Parameter of type Record "Shopify Shop Inventory".</param>
    internal procedure ExportStock(var ShopInventory: Record "Shpfy Shop Inventory")
    var
        DelShopInventory: Record "Shpfy Shop Inventory";
        ShopLocation: Record "Shpfy Shop Location";
        ShopVariant: Record "Shpfy Variant";
        JRequest: JsonToken;
        JResponse: JsonToken;
        Url: Text;
    begin
        ShopVariant.SetRange(Id, ShopInventory."Variant Id");
        if ShopVariant.IsEmpty then begin
            if DelShopInventory.GetBySystemId(ShopInventory.SystemId) then
                DelShopInventory.Delete();
            exit;
        end;

        if ShopLocation.Get(ShopInventory."Shop Code", ShopInventory."Location Id") and (not ShopLocation.Disabled) then begin
            Url := ShopifyCommunicationMgt.CreateWebRequestURL('inventory_levels/set.json');
            JRequest := CreateStockAsJson(ShopInventory, ShopLocation).AsToken();
            if ShopInventory."Shopify Stock" <> ShopInventory.Stock then
                JResponse := ShopifyCommunicationMgt.ExecuteWebRequest(Url, 'POST', JRequest);
        end;
    end;

    /// <summary> 
    /// Get Id.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <returns>Return variable "Result" of type BigInteger.</returns>
    local procedure GetId(JObject: JsonObject) Result: BigInteger
    var
        JValue: JsonValue;
        Path: List of [Text];
        Gid: Text;
    begin
        if JsonHelper.GetJsonValue(JObject, JValue, 'id') then begin
            Gid := JValue.AsText();
            Path := Gid.Split('/');
            Gid := Path.Get(Path.Count());
            if Evaluate(Result, Gid) then;
        end;
    end;

    /// <summary> 
    /// Get Inventory Levels.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="JResult">Parameter of type JsonObject.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure GetInventoryLevels(JObject: JsonObject; var JResult: JsonObject): Boolean;
    var
        JData: JsonObject;
        JLocation: JsonObject;
    begin
        if JsonHelper.GetJsonObject(JObject, JData, 'data') then
            if JsonHelper.GetJsonObject(JData, JLocation, 'location') then
                exit(JsonHelper.GetJsonObject(JLocation, JResult, 'inventoryLevels'));
    end;

    /// <summary> 
    /// Has Next Results.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure HasNextResults(JObject: JsonObject): Boolean
    var
        JPageInfo: JsonObject;
        JValue: JsonValue;
    begin
        if JsonHelper.GetJsonObject(JObject, JPageInfo, 'pageInfo') then
            if JsonHelper.GetJsonValue(JPageInfo, JValue, 'hasNextPage') then
                exit(JValue.AsBoolean());
    end;

    internal procedure ImportInventoryLevels(var ShopLocation: Record "Shpfy Shop Location"; var Parameters: Dictionary of [Text, Text]; var GraphQLType: Enum "Shpfy GraphQL Type"; var JInventoryLevels: JsonObject)
    var
        ShopInventory: Record "Shpfy Shop Inventory";
        ShopVariant: Record "Shpfy Variant";
        InventoryItemId: BigInteger;
        ProductId: BigInteger;
        VariantId: BigInteger;
        Stock: Decimal;
        JArray: JsonArray;
        JInventoryItem: JsonObject;
        JNode: JsonObject;
        JProduct: JsonObject;
        JVariant: JsonObject;
        JItem: JsonToken;
        JValue: JsonValue;
        Cursor: Text;
    begin
        if JsonHelper.GetJsonArray(JInventoryLevels, JArray, 'edges') then begin
            foreach JItem in JArray do begin
                if JsonHelper.GetJsonValue(JItem.AsObject(), JValue, 'cursor') then
                    Cursor := JValue.AsText()
                else
                    Clear(Cursor);
                if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                    if JsonHelper.GetJsonValue(JNode, JValue, 'available') then
                        Stock := JValue.AsInteger()
                    else
                        Stock := 0;
                    InventoryItemId := 0;
                    VariantId := 0;
                    ProductId := 0;
                    if JsonHelper.GetJsonObject(JNode, JInventoryItem, 'item') then begin
                        InventoryItemId := GetId(JInventoryItem);
                        if JsonHelper.GetJsonObject(JInventoryItem, JVariant, 'variant') then begin
                            VariantId := GetId(JVariant);
                            ShopVariant.SetRange(Id, VariantId);
                            if not ShopVariant.IsEmpty then
                                if JsonHelper.GetJsonObject(JVariant, JProduct, 'product') then begin
                                    ProductId := GetId(JProduct);
                                    if ShopInventory.Get(ShopLocation."Shop Code", ProductId, VariantId, ShopLocation.Id) then begin
                                        ShopInventory.Validate("Shopify Stock", Stock);
                                        ShopInventory."Inventory Item Id" := InventoryItemId;
                                        ShopInventory.Modify();
                                    end else begin
                                        Clear(ShopInventory);
                                        ShopInventory."Shop Code" := ShopLocation."Shop Code";
                                        ShopInventory."Product Id" := ProductId;
                                        ShopInventory."Variant Id" := VariantId;
                                        ShopInventory."Location Id" := ShopLocation.Id;
                                        ShopInventory."Inventory Item Id" := InventoryItemId;
                                        ShopInventory.Validate("Shopify Stock", Stock);
                                        ShopInventory.Insert();
                                    end;
                                end;
                        end;
                    end;
                end;
            end;
            GraphQLType := GraphQLType::GetNextInventoryEntries;
            if Parameters.ContainsKey('After') then
                Parameters.Set('After', Cursor)
            else
                Parameters.Add('After', Cursor);
        end;
    end;

    /// <summary> 
    /// Import Stock.
    /// </summary>
    /// <param name="ShopLocation">Parameter of type Record "Shopify Shop Location".</param>
    internal procedure ImportStock(ShopLocation: Record "Shpfy Shop Location")
    var
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JInventoryLevels: JsonObject;
        JResponse: JsonToken;
    begin
        Parameters.Add('LocationId', Format(ShopLocation.Id));
        GraphQLType := GraphQLType::GetInventoryEntries;
        repeat
            JResponse := ShopifyCommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if GetInventoryLevels(JResponse.AsObject(), JInventoryLevels) then
                ImportInventoryLevels(ShopLocation, Parameters, GraphQLType, JInventoryLevels);
        until not HasNextResults(JInventoryLevels);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure SetShop(ShopCode: Code[20])
    begin
        if ShopifyShop.Code <> ShopCode then begin
            ShopifyShop.Get(ShopCode);
            ShopifyCommunicationMgt.SetShop(ShopifyShop);
        end;
    end;
}
