table 20257 "Tax Entity"
{
    Caption = 'Tax Entity';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
        }
        field(2; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(3; "Table Name"; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Table Name';
            trigger OnValidate()
            begin
                AppObjectHelper.SearchObject(ObjectType::Table, "Table ID", "Table Name");
            end;

            trigger OnLookup()
            begin
                AppObjectHelper.OpenObjectLookup(ObjectType::Table, "Table Name", "Table ID", "Table Name");
            end;
        }
        field(4; "Entity Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Entity Type';
            OptionMembers = Master,Transaction;
            OptionCaption = 'Master,Transaction';
        }
    }

    keys
    {
        key(Key1; "Table ID", "Tax Type")
        {
            Clustered = true;
        }
        key(Key2; "Entity Type")
        {
        }
    }

    trigger OnInsert()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    trigger OnModify()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    trigger OnDelete()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    var
        AppObjectHelper: Codeunit "App Object Helper";
}