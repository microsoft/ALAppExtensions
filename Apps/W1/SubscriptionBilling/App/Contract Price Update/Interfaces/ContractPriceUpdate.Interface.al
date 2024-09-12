namespace Microsoft.SubscriptionBilling;

interface "Contract Price Update"
{
    Access = internal;

    /// <summary>
    /// This method sets minimal needed parameters for updating the contract prices.
    /// </summary>
    /// <param name="PriceUpdateTemplate">Price Update Template by which the update is executed</param>
    /// <param name="IncludeContractLinesUpToDate">Filter for date </param>
    /// <param name="PerformUpdateOnDate"></param>
    procedure SetPriceUpdateParameters(PriceUpdateTemplate: Record "Price Update Template"; IncludeContractLinesUpToDate: Date; PerformUpdateOnDate: Date)

    /// <summary>
    /// The method applies filters on Service commitments which should be processed for price update.
    /// </summary>
    procedure ApplyFilterOnServiceCommitments()

    /// <summary>
    /// The metod creates implemented price update proposal.
    /// </summary>
    procedure CreatePriceUpdateProposal()

    /// <summary>
    /// The method calculates the New Price in Contract Price Update Line parameter based on Update Percent Value.
    /// </summary>
    /// <param name="UpdatePercentValue">Decimal percentage value for calculation of the New Price</param>
    /// <param name="NewContractPriceUpdateLine">The Record on which New Price is calculated</param>
    procedure CalculateNewPrice(UpdatePercentValue: Decimal; var NewContractPriceUpdateLine: Record "Contract Price Update Line")
}
