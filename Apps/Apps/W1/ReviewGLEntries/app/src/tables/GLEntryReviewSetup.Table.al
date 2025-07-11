namespace Microsoft.Finance.GeneralLedger.Review;

table 22217 "G/L Entry Review Setup"
{

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; GLEntryReviewer; Enum "G/L Entry Reviewer")
        {
            Caption = 'G/L Entry Reviewer';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}