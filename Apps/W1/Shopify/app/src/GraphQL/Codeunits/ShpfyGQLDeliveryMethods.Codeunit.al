// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL DeliveryMethods (ID 30376) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30376 "Shpfy GQL DeliveryMethods" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ deliveryProfile(id: \"gid://shopify/DeliveryProfile/{{DeliveryProfileId}}\") { profileLocationGroups(locationGroupId: \"gid://shopify/DeliveryLocationGroup/{{DeliveryLocationGroupId}}\") { locationGroupZones(first: 20) { pageInfo { hasNextPage } edges { cursor node { methodDefinitions(first: 50) { edges { node { active name } } } } } } } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(54);
    end;
}
