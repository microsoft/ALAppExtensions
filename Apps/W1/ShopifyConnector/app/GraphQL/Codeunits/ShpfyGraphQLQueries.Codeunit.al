/// <summary>
/// Codeunit Shpfy GraphQL Queries (ID 30154).
/// </summary>
codeunit 30154 "Shpfy GraphQL Queries"
{
    Access = Internal;
    SingleInstance = true;

    /// <summary> 
    /// Get Query
    /// </summary>
    /// <param name="GraphQLType">Parameter of type enum "Shopify GraphQL Type".</param>
    /// <param name="Parameters">Parameter of type Dictionary of [Text, Text].</param>
    internal procedure GetQuery(GraphQLType: enum "Shpfy GraphQL Type"; Parameters: Dictionary of [Text, Text]) Result: Text
    var
        ExpectedCost: Integer;
    begin
        exit(GetQuery(GraphQLType, Parameters, ExpectedCost));
    end;

    /// <summary> 
    /// Description for GetQuery.
    /// </summary>
    /// <param name="GraphQLType">Parameter of type enum "Shopify GraphQL Type".</param>
    /// <param name="Parameters">Parameter of type Dictionary of [Text, Text].</param>
    /// <param name="ExpectedCost">Parameter of type Decimal.</param>
    internal procedure GetQuery(GraphQLType: enum "Shpfy GraphQL Type"; Parameters: Dictionary of [Text, Text]; var ExpectedCost: Integer) GraphQL: Text
    var
        Param: Text;
        IGraphQL: Interface "Shpfy IGraphQL";
        IsHandled: Boolean;
    begin
        OnBeforeSetInterfaceCodeunit(GraphQLType, Parameters, IGraphQL, IsHandled);
        if not IsHandled then
            IGraphQL := GraphQLType;

        IsHandled := false;
        OnBeforeGetGrapQLInfo(GraphQLType, Parameters, IGraphQL, GraphQL, ExpectedCost, IsHandled);
        if not IsHandled then begin
            GraphQL := IGraphQL.GetGraphQL();
            ExpectedCost := IGraphQL.GetExpectedCost();
        end;
        OnAfterGetGrapQLInfo(GraphQLType, Parameters, IGraphQL, GraphQL, ExpectedCost);

        IsHandled := false;
        OnBeforeReplaceParameters(GraphQLType, Parameters, GraphQL, ExpectedCost, IsHandled);
        if not IsHandled then
            if (GraphQL <> '') and (Parameters.Count > 0) then
                foreach Param in Parameters.Keys do
                    GraphQL := GraphQL.Replace('{{' + Param + '}}', Parameters.Get(Param));
        OnAfterReplaceParameters(GraphQLType, GraphQL, ExpectedCost);
    end;

    /// <summary>
    /// OnAfterGetGrapQLInfo.
    /// </summary>
    /// <param name="GraphQLType">enum "Shopify GraphQL Type".</param>
    /// <param name="Parameters">VAR Dictionary of [Text, Text].</param>
    /// <param name="IGraphQL">VAR Interface "Shopify IGarphQL".</param>
    /// <param name="GraphQL">VAR Text.</param>
    /// <param name="ExpextedCost">VAR Integer.</param>
    [InternalEvent(false)]
    local procedure OnAfterGetGrapQLInfo(GraphQLType: enum "Shpfy GraphQL Type"; var Parameters: Dictionary of [Text, Text]; var IGraphQL: Interface "Shpfy IGraphQL"; var GraphQL: Text; var ExpextedCost: Integer)
    begin
    end;

    /// <summary>
    /// OnAfterReplaceParameters.
    /// </summary>
    /// <param name="GraphQLType">enum "Shopify GraphQL Type".</param>
    /// <param name="GraphQL">VAR Text.</param>
    /// <param name="ExpextedCost">VAR Integer.</param>
    [InternalEvent(false)]
    local procedure OnAfterReplaceParameters(GraphQLType: enum "Shpfy GraphQL Type"; var GraphQL: Text; var ExpextedCost: Integer)
    begin
    end;

    /// <summary>
    /// OnBeforeGetGrapQLInfo.
    /// </summary>
    /// <param name="GraphQLType">enum "Shopify GraphQL Type".</param>
    /// <param name="Parameters">VAR Dictionary of [Text, Text].</param>
    /// <param name="IGraphQL">VAR Interface "Shopify IGarphQL".</param>
    /// <param name="GraphQL">VAR Text.</param>
    /// <param name="ExpextedCost">VAR Integer.</param>
    /// <param name="IsHandled">Boolean.</param>
    [InternalEvent(false)]
    local procedure OnBeforeGetGrapQLInfo(GraphQLType: enum "Shpfy GraphQL Type"; var Parameters: Dictionary of [Text, Text]; var IGraphQL: Interface "Shpfy IGraphQL"; var GraphQL: Text; var ExpextedCost: Integer; IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// OnBeforeReplaceParameters.
    /// </summary>
    /// <param name="GraphQLType">enum "Shopify GraphQL Type".</param>
    /// <param name="Parameters">VAR Dictionary of [Text, Text].</param>
    /// <param name="GraphQL">VAR Text.</param>
    /// <param name="ExpextedCost">VAR Integer.</param>
    /// <param name="IsHandled">Boolean.</param>
    [InternalEvent(false)]
    local procedure OnBeforeReplaceParameters(GraphQLType: enum "Shpfy GraphQL Type"; var Parameters: Dictionary of [Text, Text]; var GraphQL: Text; var ExpextedCost: Integer; IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// OnBeforeSetInterfaceCodeunit.
    /// </summary>
    /// <param name="GraphQLType">enum "Shopify GraphQL Type".</param>
    /// <param name="Parameters">VAR Dictionary of [Text, Text].</param>
    /// <param name="IGraphQL">VAR Interface "Shopify IGarphQL".</param>
    /// <param name="IsHandled">Boolean.</param>
    [InternalEvent(false)]
    local procedure OnBeforeSetInterfaceCodeunit(GraphQLType: enum "Shpfy GraphQL Type"; var Parameters: Dictionary of [Text, Text]; var IGraphQL: Interface "Shpfy IGraphQL"; IsHandled: Boolean)
    begin
    end;
}