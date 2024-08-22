namespace Microsoft.Integration.Shopify;

/// <summary>
/// Interface used to for metafield operations related to metafield owner resource.
/// </summary>
interface "Shpfy IMetafield Owner Type"
{
    Access = Internal;

    /// <summary>
    /// Returns the table id where the owner record is stored in BC.
    /// </summary>
    /// <returns>Table id.</returns>
    procedure GetTableId(): Integer

    /// <summary>
    /// Retrieves metafields belonging to the owner resource in a dictionary with the last updated at timestamp.
    /// </summary>
    /// <param name="OwnerId">Id of the owner resource.</param>
    /// <returns>Dictionary of metafield ids and last updated at timestamp.</returns>
    procedure RetrieveMetafieldIdsFromShopify(OwnerId: BigInteger): Dictionary of [BigInteger, DateTime]

    /// <summary>
    /// Retrieves the shop code from the owner resource.
    /// </summary>
    /// <param name="OwnerId">Id of the owner resource.</param>
    /// <returns>Shop code.</returns>
    procedure GetShopCode(OwnerId: BigInteger): Code[20]
}