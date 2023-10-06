namespace Microsoft.Integration.Shopify;

/// <summary>
/// Interface "Shpfy IBulkOperation."
/// </summary>
interface "Shpfy IBulk Operation"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetInput(): Text;

    /// <summary>
    /// GetName.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetName(): Text[250];

    /// <summary>
    /// GetType.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetType(): Text;
}