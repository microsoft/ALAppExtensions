/// <summary>
/// Codeunit Shpfy GQL FindCustByEMail (ID 30129) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30129 "Shpfy GQL FindCustByEMail" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{customers(first: 1, query:\"email:{{EMail}}\") {edges {node {id}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(5);
    end;

}
