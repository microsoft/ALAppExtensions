/// <summary>
/// Codeunit Shpfy GQL FindCustByPhone (ID 30130) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30130 "Shpfy GQL FindCustByPhone" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{customers(first: 1, query:\"phone:{{Phone}}\") {edges {node {id}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(420);
    end;

}
