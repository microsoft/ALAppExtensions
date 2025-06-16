namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL GetStaffMembers (ID 30400).
/// Implements the IGraphQL interface for retrieving Shopify staff members using GraphQL.
/// </summary>
codeunit 30400 "Shpfy GQL GetStaffMembers" implements "Shpfy IGraphQL"
{
    Access = Internal;
    
    /// <summary>
    /// Returns the GraphQL query for retrieving staff members.
    /// </summary>
    /// <returns>The GraphQL query as a text string.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ staffMembers (first: 20) { edges { node { accountType active email exists firstName id initials isShopOwner lastName locale name phone } } pageInfo { hasPreviousPage hasNextPage startCursor endCursor } } }"}');
    end;

    /// <summary>
    /// Returns the expected cost of the GraphQL query.
    /// </summary>
    /// <returns>The expected cost as an integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(7);
    end;
}