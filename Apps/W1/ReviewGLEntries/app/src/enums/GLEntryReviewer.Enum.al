namespace Microsoft.Finance.GeneralLedger.Review;

enum 22202 "G/L Entry Reviewer" implements "G/L Entry Reviewer"
{
    Extensible = true;
    DefaultImplementation = "G/L Entry Reviewer" = "Review G/L Entry";
    UnknownValueImplementation = "G/L Entry Reviewer" = "Review G/L Entry";

    value(0; "Review G/L Entry")
    {
        Implementation = "G/L Entry Reviewer" = "Review G/L Entry";
    }
}