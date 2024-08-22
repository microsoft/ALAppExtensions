namespace Microsoft.Integration.Shopify;

codeunit 30325 "Shpfy Mtfld Type Volume" implements "Shpfy IMetafield Type"
{
    var
        VolumeJsonTemplateTxt: Label '{"value": %1,"unit":"%2"}', Locked = true;

    procedure HasAssistEdit(): Boolean
    begin
        exit(true);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        Volume: Decimal;
        Unit: Enum "Shpfy Metafield Volume Type";
    begin
        exit(TryExtractValues(Value, Volume, Unit));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    var
        MetafieldAssistEdit: Page "Shpfy Metafield Assist Edit";
        Volume: Decimal;
        Unit: Enum "Shpfy Metafield Volume Type";
    begin
        if Value <> '' then
            if not TryExtractValues(Value, Volume, Unit) then begin
                Clear(Volume);
                Clear(Unit);
            end;

        if MetafieldAssistEdit.OpenForVolume(Volume, Unit) then begin
            MetafieldAssistEdit.GetVolumeValue(Volume, Unit);
            Value := StrSubstNo(VolumeJsonTemplateTxt, Format(Volume, 0, 9), GetVolumeTypeName(Unit));
            exit(true);
        end else
            exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit(StrSubstNo(VolumeJsonTemplateTxt, '20.0', 'ml'));
    end;


    [TryFunction]
    local procedure TryExtractValues(Value: Text; var Volume: Decimal; var Unit: Enum "Shpfy Metafield Volume Type")
    var
        JToken: JsonToken;
        JObject: JsonObject;
    begin
        JObject.ReadFrom(Value);
        JObject.SelectToken('value', JToken);
        Volume := JToken.AsValue().AsDecimal();
        JObject.SelectToken('unit', JToken);
        Unit := ConvertToVolumeType(JToken.AsValue().AsText());

        if JObject.Keys.Count() <> 2 then
            Error('');
    end;

    local procedure GetVolumeTypeName(VolumeType: Enum "Shpfy Metafield Volume Type"): Text
    begin
        exit(VolumeType.Names().Get(VolumeType.Ordinals().IndexOf(VolumeType.AsInteger())));
    end;

    local procedure ConvertToVolumeType(Value: Text) Type: Enum "Shpfy Metafield Volume Type"
    begin
        exit(Enum::"Shpfy Metafield Volume Type".FromInteger(Type.Ordinals().Get(Type.Names().IndexOf(Value))));
    end;
}