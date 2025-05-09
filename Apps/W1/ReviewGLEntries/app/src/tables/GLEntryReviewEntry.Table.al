namespace Microsoft.Finance.GeneralLedger.Review;

table 22216 "G/L Entry Review Entry"
{
    fields
    {
        field(1; "G/L Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Reviewed Identifier"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Reviewed By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Remaining Amount"; Decimal) //TODO: Conversion from the amount in older entries
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(GLEntryNo; "G/L Entry No.")
        {
            Unique = false;
            Clustered = true;
        }
    }
}