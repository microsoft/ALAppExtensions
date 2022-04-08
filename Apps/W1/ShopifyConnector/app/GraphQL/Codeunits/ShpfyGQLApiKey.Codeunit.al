/// <summary>
/// Codeunit Shpfy GQL ApiKey (ID 30126) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30126 "Shpfy GQL ApiKey" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "{app {apiKey installation {activeSubscriptions {currentPeriodEnd test status name}}}}"}');
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
