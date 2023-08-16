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
        InventoryEvents: Codeunit "Shpfy Inventory Events";
        JsonHelper: Codeunit "Shpfy Json Helper";
        InventoryIds: List of [Guid];

    /// <summary> 
    /// Get Stock.
    /// </summary>
    /// <param name="ShopInventory">Parameter of type Record "Shopify Shop Inventory".</param>
    /// <returns>Return variable "Stock" of type Decimal.</returns>
    internal procedure GetStock(ShopInventory: Record "Shpfy Shop Inventory") Stock: Decimal
    var
        Item: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ShopLocation: Record "Shpfy Shop Location";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        StockCalculation: Interface "Shpfy Stock Calculation";
        UOM: Code[10];
    begin
        SetShop(ShopInventory."Shop Code");
        if ShopifyProduct.Get(ShopInventory."Product Id") and ShopifyVariant.Get(ShopInventory."Variant Id") then begin
            ShopLocation.SetRange("Shop Code", ShopInventory."Shop Code");
            ShopLocation.SetRange(Id, ShopInventory."Location Id");
            ShopLocation.SetFilter("Stock Calculation", '<>%1', ShopLocation."Stock Calculation"::Disabled);
            if ShopLocation.FindFirst() and Item.GetBySystemId(ShopifyVariant."Item SystemId") then
                Item.SetRange("Date Filter", 0D, Today);
            Item.SetFilter("Location Filter", ShopLocation."Location Filter");
            if not IsNullGuid(ShopifyVariant."Item Variant SystemId") then begin
                ShopifyVariant.CalcFields("Variant Code");
                Item.SetFilter("Variant Filter", ShopifyVariant."Variant Code");
            end;

            StockCalculationFactory(StockCalculation, ShopLocation."Stock Calculation");
            Stock := StockCalculation.GetStock(Item);

            case ShopifyVariant."UoM Option Id" of
                1:
                    UOM := CopyStr(ShopifyVariant."Option 1 Value", 1, MaxStrLen(UOM));
                2:
                    UOM := CopyStr(ShopifyVariant."Option 2 Value", 1, MaxStrLen(UOM));
                3:
                    UOM := CopyStr(ShopifyVariant."Option 3 Value", 1, MaxStrLen(UOM));
                else
                    UOM := Item."Sales Unit of Measure";
            end;
            if (UOM <> '') and (UOM <> Item."Base Unit of Measure") then
                if ItemUnitofMeasure.Get(Item."No.", UOM) then
                    Stock := Stock / ItemUnitofMeasure."Qty. per Unit of Measure";
            InventoryEvents.OnAfterCalculationStock(Item, ShopifyShop, ShopLocation."Location Filter", Stock);
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

    local procedure SetInventoryIds()
    var
        ShopInventory: Record "Shpfy Shop Inventory";
    begin
        Clear(InventoryIds);
        ShopInventory.SetRange("Shop Code", ShopifyShop.Code);
        ShopInventory.LoadFields(SystemId);
        if ShopInventory.FindSet() then
            repeat
                InventoryIds.Add(ShopInventory.SystemId);
            until ShopInventory.Next() = 0;
    end;

    internal procedure RemoveUnusedInventoryIds()
    var
        ShopInventory: Record "Shpfy Shop Inventory";
        Id: Guid;
    begin
        ShopInventory.LoadFields(SystemId);
        foreach Id in InventoryIds do
            if ShopInventory.GetBySystemId(Id) then
                ShopInventory.Delete();
    end;

    internal procedure ExportStock(var ShopInventory: Record "Shpfy Shop Inventory")
    var
        IGraphQL: Interface "Shpfy IGraphQL";
        JGraphQL: JsonObject;
        JSetQuantities: JsonArray;
        JSetQunatity: JsonObject;
    begin
        if ShopInventory.FindSet() then begin
            IGraphQL := Enum::"Shpfy GraphQL Type"::ModifyInventory;
            JGraphQL.ReadFrom(IGraphQL.GetGraphQL());
            JSetQuantities := JsonHelper.GetJsonArray(JGraphQL, 'variables.input.setQuantities');

            repeat
                JSetQunatity := CalcStock(ShopInventory);
                if JSetQunatity.Keys.Count = 3 then
                    JSetQuantities.Add(JSetQunatity);
            until ShopInventory.Next() = 0;

            ShopifyCommunicationMgt.ExecuteGraphQL(Format(JGraphQL), IGraphQL.GetExpectedCost());
        end;
    end;

    local procedure CalcStock(var ShopInventory: Record "Shpfy Shop Inventory") JSetQuantity: JsonObject
    var
        Item: Record Item;
        DelShopInventory: Record "Shpfy Shop Inventory";
        ShopLocation: Record "Shpfy Shop Location";
        ShopifyVariant: Record "Shpfy Variant";
        IStockAvailable: Interface "Shpfy IStock Available";
        InventoryItemIdTxt: Label 'gid://shopify/InventoryItem/%1', Locked = true, Comment = '%1 = The inventory Item Id';
        LocationIdTxt: Label 'gid://shopify/Location/%1', Locked = true, Comment = '%1 = The Location Id';

    begin
        ShopifyVariant.SetRange(Id, ShopInventory."Variant Id");
        if ShopifyVariant.IsEmpty then begin
            if DelShopInventory.GetBySystemId(ShopInventory.SystemId) then
                DelShopInventory.Delete();
            exit;
        end;

        if ShopifyVariant.Get(ShopInventory."Variant Id") then
            if Item.GetBySystemId(ShopifyVariant."Item SystemId") then begin
                ShopInventory.Validate(Stock, Round(GetStock(ShopInventory), 1, '<'));
                ShopInventory.Modify();
                if ShopInventory.Stock <> ShopInventory."Shopify Stock" then
                    if ShopLocation.Get(ShopInventory."Shop Code", ShopInventory."Location Id") then begin
                        IStockAvailable := ShopLocation."Stock Calculation";
                        if IStockAvailable.CanHaveStock() then begin
                            JSetQuantity.Add('inventoryItemId', StrSubstNo(InventoryItemIdTxt, ShopInventory."Inventory Item Id"));
                            JSetQuantity.Add('locationId', StrSubstNo(LocationIdTxt, ShopLocation.Id));
                            JSetQuantity.Add('quantity', ShopInventory.Stock);
                        end;
                    end;
            end;
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
                                        InventoryIds.Remove(ShopInventory.SystemId);
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
        SetInventoryIds();
    end;

    local procedure StockCalculationFactory(var StockCalculation: Interface "Shpfy Stock Calculation"; CalculationType: Enum "Shpfy Stock Calculation")
    begin
        StockCalculation := CalculationType;
    end;
}
