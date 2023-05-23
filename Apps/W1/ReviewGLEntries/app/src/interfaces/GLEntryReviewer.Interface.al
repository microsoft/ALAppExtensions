interface "G/L Entry Reviewer"
{
    procedure ReviewEntries(var GLEntry: Record "G/L Entry");
    procedure UnreviewEntries(var GLEntry: Record "G/L Entry");
    procedure ValidateEntries(var GLEntry: Record "G/L Entry");
}