table 40028 "Hybrid DA Approval"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = false;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; PrimaryKey; Integer)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; Status; Option)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            OptionMembers = " ",Granted,Revoked;
        }

        field(4; "Granted By User Security ID"; Guid)
        {
            Caption = 'Granted by User ID';
            DataClassification = EndUserPseudonymousIdentifiers;
            TableRelation = User."User Security ID";
            ValidateTableRelation = false;
        }
        field(5; "Granted By User Email"; Text[250])
        {
            Caption = 'Granted by';
            FieldClass = FlowField;
            CalcFormula = lookup(User."Authentication Email" where("User Security ID" = field("Granted By User Security ID")));
            TableRelation = User."Authentication Email";
        }

        field(6; "Granted Date"; DateTime)
        {
            Caption = 'Granted date';
            DataClassification = SystemMetadata;
        }

        field(7; "Revoked By User Security ID"; Guid)
        {
            Caption = 'Revoked by User ID';
            DataClassification = EndUserPseudonymousIdentifiers;
            TableRelation = User."User Security ID";
            ValidateTableRelation = false;
        }
        field(8; "Revoked Date"; DateTime)
        {
            Caption = 'Revoked date';
            DataClassification = SystemMetadata;
        }

        field(9; "Revoked By User Email"; Text[250])
        {
            Caption = 'Revoked by';
            FieldClass = FlowField;
            CalcFormula = lookup(User."Authentication Email" where("User Security ID" = field("Revoked By User Security ID")));
            TableRelation = User."Authentication Email";
        }
    }

    keys
    {
        key(Key1; PrimaryKey)
        {
            Clustered = true;
        }
    }
}