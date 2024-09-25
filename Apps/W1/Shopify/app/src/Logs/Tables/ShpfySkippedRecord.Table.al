namespace Microsoft.Integration.Shopify;

using System.Reflection;


table 30159 "Shpfy Skipped Record"
{
    Caption = 'Shpfy Skipped Record';
    DataClassification = SystemMetadata;
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Shopify Id"; BigInteger)
        {
            Caption = 'Skipped Record Id';
            DataClassification = SystemMetadata;
        }
        field(3; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Table Name" := GetTableCaption();
            end;
        }
        field(4; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            DataClassification = SystemMetadata;
        }
        field(5; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(6; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }




    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    local procedure GetTableCaption(): Text[250]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if "Table ID" <> 0 then
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, "Table ID") then
                exit(AllObjWithCaption."Object Caption");
    end;
}
