codeunit 2453 "XS Create Item Data Json"
{
    procedure CreateItemDataJson(var Item: Record Item) ItemDataJsonTxt: Text
    var
        Handled: Boolean;
    begin
        OnBeforeCreateItemDataJson(Item, Handled);

        ItemDataJsonTxt := DoCreateItemDataJson(Item, Handled);

        OnAfterCreateItemDataJson(ItemDataJsonTxt);
    end;

    local procedure DoCreateItemDataJson(var Item: Record Item; var Handled: Boolean) ItemDataJsonTxt: Text
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        ItemJson: JsonObject;
        JObject: JsonObject;
    begin
        if Handled then
            exit;

        JsonObjectHelper.AddValueToJObject(ItemJson, 'Code', Item."No.");
        JsonObjectHelper.AddValueToJObject(ItemJson, 'Name', Item.Description);
        if Item."Description 2" <> '' then
            JsonObjectHelper.AddValueToJObject(ItemJson, 'Description', Item."Description 2")
        else
            JsonObjectHelper.AddValueToJObject(ItemJson, 'Description', Item.Description);

        JsonObjectHelper.AddValueToJObject(ItemJson, 'IsTrackedAsInventory', 'false');
        if Item."Unit Price" <> 0 then
            JsonObjectHelper.AddValueToJObject(ItemJson, 'IsSold', 'true');

        if Item."Unit Price" <> 0 then begin
            JsonObjectHelper.AddValueToJObject(JObject, 'UnitPrice', Item."Unit Price");
            JsonObjectHelper.AddObjectAsValueToJObject(ItemJson, 'SalesDetails', JObject);
            JsonObjectHelper.CleanJsonObject(JObject);
        end;

        ItemJson.WriteTo(ItemDataJsonTxt);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateItemDataJson(var Item: Record Item; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateItemDataJson(var ItemDataJsonTxt: Text);
    begin
    end;
}
