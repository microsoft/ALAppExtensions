namespace Microsoft.Integration.Shopify;

codeunit 30231 "Shpfy Refund Enum Convertor"
{
    SingleInstance = true;
    Access = Internal;

    var
        RestockTypes: Dictionary of [Text, Enum "Shpfy Restock Type"];

    #region "Shpfy Restock Type"
    local procedure FillInRestockTypes()
    var
        EnumValues: List of [Integer];
        EnumNames: List of [Text];
        Index: Integer;
    begin
        if RestockTypes.Count > 0 then
            exit;

        EnumValues := Enum::"Shpfy Restock Type".Ordinals();
        EnumNames := Enum::"Shpfy Restock Type".Names();
        for Index := 1 to EnumValues.Count do
            RestockTypes.Add(EnumNames.Get(Index).Trim().ToUpper().Replace(' ', '_'), Enum::"Shpfy Restock Type".FromInteger(EnumValues.Get(Index)));
    end;

    internal procedure ConvertToReStockType(Value: Text): Enum "Shpfy Restock Type"
    begin
        FillInRestockTypes();
        if RestockTypes.ContainsKey(Value) then
            exit(RestockTypes.Get(Value));
    end;

    internal procedure ConvertToText(Value: Enum "Shpfy Restock Type"): text
    begin
        exit(Value.Names.Get(Value.Ordinals().IndexOf(Value.AsInteger())).Trim().ToUpper().Replace(' ', '_'));
    end;
    #endregion "Shpfy Restock Type"

}