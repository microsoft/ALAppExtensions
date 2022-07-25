/// <summary>
/// Holds information about storage accounts and corresponding shared access signatures for handling queues.
/// </summary>
table 50100 "Azure Queue Setup"
{
    Caption = 'Azure Queue Setup';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Storage Account Name"; Text[100])
        {
            Caption = 'Azure Storage Account Name';
            Description = 'Name of the Azure Storage Account.';
        }

        field(2; "SAS Key"; Text[255])
        {
            Caption = 'Shared Access Signature Key';
            Description = 'Shared Access Signature Key for the Azure Storage Account.';
        }

    }

    keys
    {
        key(PK; "Storage Account Name")
        {
            Clustered = true;
        }
    }
}