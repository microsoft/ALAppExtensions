namespace System.DataAdministration;

table 6201 "Transaction Storage Setup"
{
    DataClassification = OrganizationIdentifiableInformation;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
        }
        field(2; "Earliest Start Time"; Time)
        {
            InitValue = 020000T;
        }
        field(3; "Max. Number of Hours"; Integer)
        {
            InitValue = 3;
            MinValue = 3;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}