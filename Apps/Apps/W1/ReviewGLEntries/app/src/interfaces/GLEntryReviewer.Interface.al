namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Ledger;

interface "G/L Entry Reviewer"
{
    procedure ReviewEntries(var GLEntry: Record "G/L Entry");
    procedure UnreviewEntries(var GLEntry: Record "G/L Entry");
    procedure ValidateEntries(var GLEntry: Record "G/L Entry");
}