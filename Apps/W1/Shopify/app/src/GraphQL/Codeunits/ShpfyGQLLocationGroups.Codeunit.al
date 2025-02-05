namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL LocationGroups (ID 30379) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30379 "Shpfy GQL LocationGroups" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ deliveryProfile(id: \"gid://shopify/DeliveryProfile/{{DeliveryProfileId}}\") { profileLocationGroups { locationGroup { id } } } }"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(3);
    end;
}
