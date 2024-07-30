namespace Microsoft.Integration.Shopify;

codeunit 30326 "Shpfy Mtfld Type Weight" implements "Shpfy IMetafield Type"
{
    var
        WeightJsonTemplateTxt: Label '{"value": %1,"unit":"%2"}', Locked = true;

    procedure HasAssistEdit(): Boolean
    begin
        exit(true);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        Weight: Decimal;
        Unit: Enum "Shpfy Metafield Weight Type";
    begin
        exit(TryExtractValues(Value, Weight, Unit));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    var
        MetafieldAssistEdit: Page "Shpfy Metafield Assist Edit";
        Weight: Decimal;
        Unit: Enum "Shpfy Metafield Weight Type";
    begin
        if Value <> '' then
            if not TryExtractValues(Value, Weight, Unit) then begin
                Clear(Weight);
                Clear(Unit);
            end;

        if MetafieldAssistEdit.OpenForWeight(Weight, Unit) then begin
            MetafieldAssistEdit.GetWeightValue(Weight, Unit);
            Value := StrSubstNo(WeightJsonTemplateTxt, Format(Weight, 0, 9), GetWeightTypeName(Unit));
            exit(true);
        end else
            exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit(StrSubstNo(WeightJsonTemplateTxt, '2.5', 'kg'));
    end;


    [TryFunction]
    local procedure TryExtractValues(Value: Text; var Weight: Decimal; var Unit: Enum "Shpfy Metafield Weight Type")
    var
        JToken: JsonToken;
        JObject: JsonObject;
    begin
        JObject.ReadFrom(Value);
        JObject.SelectToken('value', JToken);
        Weight := JToken.AsValue().AsDecimal();
        JObject.SelectToken('unit', JToken);
        Unit := ConvertToWeightType(JToken.AsValue().AsText());

        if JObject.Keys.Count() <> 2 then
            Error('');
    end;

    local procedure GetWeightTypeName(WeightType: Enum "Shpfy Metafield Weight Type"): Text
    begin
        exit(WeightType.Names().Get(WeightType.Ordinals().IndexOf(WeightType.AsInteger())));
    end;

    local procedure ConvertToWeightType(Value: Text) Type: Enum "Shpfy Metafield Weight Type"
    begin
        exit(Enum::"Shpfy Metafield Weight Type".FromInteger(Type.Ordinals().Get(Type.Names().IndexOf(Value))));
    end;
}