namespace Microsoft.Finance.GeneralLedger.Review;

table 22216 "G/L Entry Review Entry"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Use "G/L Entry Review Log" instead.';
    ObsoleteTag = '27.0';
    //TODO: Create data conversion codeunit to convert existing entries to the new table
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
        field(4; "Reviewed Amount"; Decimal)
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