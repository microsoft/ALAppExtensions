// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Shipping Methods (ID 30193).
/// </summary>
codeunit 30193 "Shpfy Shipping Methods"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary> 
    /// Description for GetShippingMethods.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure GetShippingMethods(var ShopifyShop: Record "Shpfy Shop")
    var
        Shop: Record "Shpfy Shop";
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JDeliveryProfiles: JsonArray;
        JDeliveryProfile: JsonToken;
        JResponse: JsonToken;
    begin
        if ShopifyShop.GetFilters = '' then begin
            Shop := ShopifyShop;
            Shop.SetRecFilter();
        end else
            Shop.CopyFilters(ShopifyShop);
        if Shop.FindFirst() then begin
            CommunicationMgt.SetShop(Shop);
            GraphQLType := GraphQLType::GetDeliveryProfiles;
            repeat
                JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
                if JsonHelper.GetJsonArray(JResponse, JDeliveryProfiles, 'data.deliveryProfiles.edges') then
                    foreach JDeliveryProfile in JDeliveryProfiles do
                        GetProfileLocationGroups(JDeliveryProfile, Shop);

                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', JsonHelper.GetValueAsText(JDeliveryProfile.AsObject(), 'cursor'))
                else
                    Parameters.Add('After', JsonHelper.GetValueAsText(JDeliveryProfile.AsObject(), 'cursor'));
                GraphQLType := GraphQLType::GetNextDeliveryProfiles;
            until not JsonHelper.GetValueAsBoolean(JResponse, 'data.deliveryProfiles.pageInfo.hasNextPage');
        end;
    end;

    local procedure GetProfileLocationGroups(JDeliveryProfile: JsonToken; Shop: Record "Shpfy Shop")
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        DeliveryProfileId: BigInteger;
        Parameters: Dictionary of [Text, Text];
        JProfileLocationGroups: JsonArray;
        JProfileLocationGroup: JsonToken;
        JResponse: JsonToken;
    begin
        DeliveryProfileId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JDeliveryProfile.AsObject(), 'node.id'));
        Parameters.Add('DeliveryProfileId', Format(DeliveryProfileId));
        GraphQLType := GraphQLType::GetLocationGroups;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        if JsonHelper.GetJsonArray(JResponse, JProfileLocationGroups, 'data.deliveryProfile.profileLocationGroups') then
            foreach JProfileLocationGroup in JProfileLocationGroups do
                GetDeliveryMethods(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JProfileLocationGroup.AsObject(), 'locationGroup.id')), DeliveryProfileId, Shop);
    end;

    local procedure GetDeliveryMethods(ProfileLocationGroupId: BigInteger; DeliveryProfileId: BigInteger; Shop: Record "Shpfy Shop")
    var
        ShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        GraphQLType: Enum "Shpfy GraphQL Type";
        Name: Text;
        Active: Boolean;
        Parameters: Dictionary of [Text, Text];
        JProfileLocationGroups: JsonArray;
        JProfileLocationGroup: JsonToken;
        JLocationGroupZones: JsonArray;
        JLocationGroupZone: JsonToken;
        JMethodDefinitions: JsonArray;
        JMethodDefinition: JsonToken;
        HasNextPage: Boolean;
        JResponse: JsonToken;
    begin
        GraphQLType := GraphQLType::GetDeliveryMethods;
        Parameters.Add('DeliveryProfileId', Format(DeliveryProfileId));
        Parameters.Add('DeliveryLocationGroupId', Format(ProfileLocationGroupId));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JProfileLocationGroups, 'data.deliveryProfile.profileLocationGroups') then
                if JProfileLocationGroups.Count = 1 then begin
                    JProfileLocationGroups.Get(0, JProfileLocationGroup);
                    if JsonHelper.GetJsonArray(JProfileLocationGroup, JLocationGroupZones, 'locationGroupZones.edges') then
                        if JLocationGroupZones.Count > 0 then begin
                            foreach JLocationGroupZone in JLocationGroupZones do
                                if JsonHelper.GetJsonArray(JLocationGroupZone, JMethodDefinitions, 'node.methodDefinitions.edges') then
                                    foreach JMethodDefinition in JMethodDefinitions do begin
                                        Name := JsonHelper.GetValueAsText(JMethodDefinition, 'node.name', MaxStrLen(ShipmentMethodMapping.Name));
                                        Active := JsonHelper.GetValueAsBoolean(JMethodDefinition, 'node.active');
                                        if Active and (Name <> '') then
                                            if not ShipmentMethodMapping.Get(Shop.Code, Name) then begin
                                                Clear(ShipmentMethodMapping);
                                                ShipmentMethodMapping."Shop Code" := Shop.Code;
                                                ShipmentMethodMapping.Name := CopyStr(Name, 1, MaxStrLen(ShipmentMethodMapping.Name));
                                                ShipmentMethodMapping.Insert();
                                            end;
                                    end;
                            if Parameters.ContainsKey('After') then
                                Parameters.Set('After', JsonHelper.GetValueAsText(JLocationGroupZone.AsObject(), 'cursor'))
                            else
                                Parameters.Add('After', JsonHelper.GetValueAsText(JLocationGroupZone.AsObject(), 'cursor'));
                            HasNextPage := JsonHelper.GetValueAsBoolean(JProfileLocationGroup, 'locationGroupZones.pageInfo.hasNextPage');
                        end;
                end;
            GraphQLType := GraphQLType::GetNextDeliveryMethods;
        until not HasNextPage;
    end;
}