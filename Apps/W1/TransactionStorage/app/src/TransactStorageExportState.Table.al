namespace System.DataAdministration;

table 6203 "Transact. Storage Export State"
{
    DataClassification = SystemMetadata;
    Access = Internal;
    InherentEntitlements = rimX;
    InherentPermissions = rimX;
    Permissions = tabledata "Transact. Storage Export State" = rim;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
        }
        field(2; "Number Of Attempts"; Integer)
        {
            InitValue = 3;
        }
        field(4; "First Run Date"; Date)
        {
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        Rec."First Run Date" := Today();
    end;

    procedure ResetSetup()
    begin
        if not Rec.Get() then
            Insert(true);
        Rec."Number Of Attempts" := 3;
        Rec.Modify();
    end;
}