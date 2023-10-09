namespace Microsoft.Integration.Shopify;

table 30148 "Shpfy Bulk Operation"
{
    Caption = 'Shopify Bulk Operation';
    DataClassification = SystemMetadata;
    Access = Internal;

    fields
    {
        field(1; "Bulk Operation Id"; BigInteger)
        {
            Caption = 'Bulk Operation Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Shop".Code;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionMembers = mutation,query;
            OptionCaption = 'mutation,query';
        }
        field(4; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(5; Status; Enum "Shpfy Bulk Operation Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(6; "Completed At"; DateTime)
        {
            Caption = 'Completed At';
            DataClassification = SystemMetadata;
        }
        field(7; "Error Code"; Text[250])
        {
            Caption = 'Error Code';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Bulk Operation Id", "Shop Code", Type)
        {
            Clustered = true;
        }
        key(Key2; SystemCreatedAt)
        {
        }
    }
}