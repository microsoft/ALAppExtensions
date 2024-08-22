namespace Microsoft.Integration.Shopify;

codeunit 30351 "Shpfy Mtfld Type Dimension" implements "Shpfy IMetafield Type"
{
    var
        DimensionJsonTemplateTxt: Label '{"value": %1, "unit": "%2"}', Locked = true;

    procedure HasAssistEdit(): Boolean
    begin
        exit(true);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        Dimension: Decimal;
        Unit: Enum "Shpfy Metafield Dimension Type";
    begin
        exit(TryExtractValues(Value, Dimension, Unit));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    var
        MetafieldAssistEdit: Page "Shpfy Metafield Assist Edit";
        Dimension: Decimal;
        Unit: Enum "Shpfy Metafield Dimension Type";
    begin
        if Value <> '' then
            if not TryExtractValues(Value, Dimension, Unit) then begin
                Clear(Dimension);
                Clear(Unit);
            end;

        if MetafieldAssistEdit.OpenForDimension(Dimension, Unit) then begin
            MetafieldAssistEdit.GetDimensionValue(Dimension, Unit);
            Value := StrSubstNo(DimensionJsonTemplateTxt, Format(Dimension, 0, 9), GetDimensionTypeName(Unit));
        end else
            exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit(StrSubstNo(DimensionJsonTemplateTxt, '1.5', 'cm'));
    end;

    [TryFunction]
    local procedure TryExtractValues(Value: Text; var Dimension: Decimal; var Unit: Enum "Shpfy Metafield Dimension Type")
    var
        JToken: JsonToken;
        JObject: JsonObject;
    begin
        JObject.ReadFrom(Value);
        JObject.SelectToken('value', JToken);
        Dimension := JToken.AsValue().AsDecimal();
        JObject.SelectToken('unit', JToken);
        Unit := ConvertToDimensionType(JToken.AsValue().AsText());

        if JObject.Keys.Count() <> 2 then
            Error('');
    end;

    local procedure GetDimensionTypeName(DimensionType: Enum "Shpfy Metafield Dimension Type"): Text
    begin
        exit(DimensionType.Names().Get(DimensionType.Ordinals().IndexOf(DimensionType.AsInteger())));
    end;

    local procedure ConvertToDimensionType(Value: Text) Type: Enum "Shpfy Metafield Dimension Type"
    begin
        exit(Enum::"Shpfy Metafield Dimension Type".FromInteger(Type.Ordinals().Get(Type.Names().IndexOf(Value))));
    end;
}