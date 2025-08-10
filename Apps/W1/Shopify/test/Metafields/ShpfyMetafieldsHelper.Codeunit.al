// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

codeunit 139549 "Shpfy Metafields Helper"
{
    procedure CreateMetafieldsResult(ResourceID: BigInteger; Namespace: Text; OwnerType: Text; MetafieldKey: Text; MetafieldValue: Text): JsonArray
    var
        JNode: JsonObject;
        JObject: JsonObject;
        JMetafields: JsonArray;
        MetafieldIdLbl: Label 'gid://shopify/Metafield/%2', Comment = '%1 - metafieldId', Locked = true;
    begin
        JNode.Add('id', StrSubstNo(MetafieldIdLbl, ResourceID));
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

    procedure CreateMetafield(var ShpfyMetafield: Record "Shpfy Metafield"; OwnerId: BigInteger; ParentTableId: Integer; Namespace: Text[255]; Name: Text[64]; Value: Text[2048]): BigInteger
    begin
        ShpfyMetafield.Init();
        ShpfyMetafield."Owner Id" := OwnerId;
        ShpfyMetafield.Validate("Parent Table No.", ParentTableId);
        ShpfyMetafield.Namespace := Namespace;
        ShpfyMetafield.Name := Name;
        ShpfyMetafield.Value := Value;
        ShpfyMetafield.Type := ShpfyMetafield.Type::single_line_text_field;
        ShpfyMetafield.Insert(true);
        exit(ShpfyMetafield.Id);
    end;

}