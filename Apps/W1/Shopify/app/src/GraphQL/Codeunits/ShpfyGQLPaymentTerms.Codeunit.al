
namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy GQL Payment Terms (ID 30357) implements Interface Shpfy IGraphQL.
/// </summary>
codeunit 30357 "Shpfy GQL Payment Terms" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{paymentTermsTemplates{id name paymentTermsType dueInDays description translatedName}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(1);
    end;
}
