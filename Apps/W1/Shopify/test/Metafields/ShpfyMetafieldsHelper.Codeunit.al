codeunit 139549 "Shpfy Metafields Helper"
{
    procedure CreateMetafieldsResult(ResourceID: BigInteger; Namespace: Text; OwnerType: Text; MetafieldKey: Text; MetafieldValue: Text): JsonArray
    var
        JNode: JsonObject;
        JObject: JsonObject;
        JMetafields: JsonArray;
    begin
        JNode.Add('id', StrSubstNo('gid://shopify/Metafield/%2', ResourceID));
        JNode.Add('namespace', Namespace);
        JNode.Add('ownerType', OwnerType);
        JNode.Add('legacyResourceId', ResourceID);
        JNode.Add('key', MetafieldKey);
        JNode.Add('value', MetafieldValue);
        JNode.Add('type', 'string');
        JObject.Add('node', JNode);
        JMetafields.Add(JObject);
        exit(JMetafields);
    end;

    procedure CreateMetafield(var ShpfyMetafield: Record "Shpfy Metafield"; OwnerId: BigInteger; ParentTableId: Integer): BigInteger
    begin
        exit(CreateMetafield(ShpfyMetafield, OwnerId, ParentTableId, '', '', ''));
    end;

    procedure CreateMetafield(var ShpfyMetafield: Record "Shpfy Metafield"; OwnerId: BigInteger; ParentTableId: Integer; Namespace: Text; Name: Text; Value: Text): BigInteger
    begin
        ShpfyMetafield.Init();
        ShpfyMetafield."Owner Id" := OwnerId;
        ShpfyMetafield.Validate("Parent Table No.", ParentTableId);
        ShpfyMetafield.Namespace := Namespace;
        ShpfyMetafield.Name := Name;
        ShpfyMetafield.Value := Value;
        ShpfyMetafield.Insert(true);
        exit(ShpfyMetafield.Id);
    end;

}
