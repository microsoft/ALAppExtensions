namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Fulfillment API (ID 30315).
/// </summary>
codeunit 30315 "Shpfy Fulfillment API"
{
    var
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";

    /// <summary>
    /// Creates a fulfillment for a provided fulfillment order id.
    /// </summary>
    /// <param name="FulfillmentOrderId">Fulfillment order id.</param>
    internal procedure CreateFulfillment(FulfillmentOrderId: Text)
    var
        JResponse: JsonToken;
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := "Shpfy GraphQL Type"::FulfillOrder;
        Parameters.Add('FulfillmentOrderId', FulfillmentOrderId);
        JResponse := ShpfyCommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
    end;

    /// <summary>
    /// Gets fulfillment orders for a provided shopify order id.
    /// </summary>
    /// <param name="OrderId">Shopify order id to get fulfillments from.</param>
    /// <param name="NumberOfLines">Number of fulfillment orders to get.</param>
    /// <returns>Fulfillment orders.</returns>
    internal procedure GetFulfillmentOrders(OrderId: Text; NumberOfLines: Integer) JFulfillments: JsonToken
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := "Shpfy GraphQL Type"::GetFulfillments;
        Parameters.Add('OrderId', OrderId);
        Parameters.Add('NumberOfOrders', Format(NumberOfLines));
        JFulfillments := ShpfyCommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        exit(JFulfillments);
    end;

    /// <summary>
    /// Sets a global shopify shop to be used for fulfillment api functionality.
    /// </summary>
    /// <param name="ShopCode">Shopify shop code to be set.</param>
    internal procedure SetShop(ShopCode: Code[20])
    begin
        ShpfyCommunicationMgt.SetShop(ShopCode);
    end;
}