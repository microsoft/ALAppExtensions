#if not CLEANSCHEMA27
namespace Microsoft.DataMigration.BC;

table 4037 "Stg Incoming Document"
{
    ReplicateData = false;
    Extensible = false;
#if not CLEAN24
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '27.0';
#endif
    ObsoleteReason = 'Upgrade has moved away from using the duplicated codeuntis to actual upgrade objets';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(19; URL1; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(20; URL2; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(21; URL3; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(22; URL4; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(60; URL; Text[1024])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}
#endif