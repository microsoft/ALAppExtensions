table 20248 "Tax Component Formula Token"
{
    Caption = 'Tax Component Formula Token';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Tax Type"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(3; "Formula Expr. ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Formula Expr. ID';
            TableRelation = "Tax Component Formula".ID;
        }
        field(4; Token; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Token';
        }
        field(5; "Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Value Type';
            OptionMembers = Constant,Component;
        }
        field(6; Value; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Value';
        }
        field(7; "Component ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Component ID';
        }
    }

    keys
    {
        key(K0; "Formula Expr. ID", Token)
        {
            Clustered = True;
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
}