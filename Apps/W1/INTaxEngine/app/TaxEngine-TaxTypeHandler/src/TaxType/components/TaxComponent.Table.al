table 20246 "Tax Component"
{
    Caption = 'Tax Component';
    LookupPageID = "Tax Components";
    DrillDownPageID = "Tax Components";
    DataCaptionFields = Name;
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
            NotBlank = true;
        }
        field(2; Name; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
            NotBlank = true;

            trigger OnValidate();
            begin
                if xRec.Name = Name then
                    Exit;

                TestField(Name);
                CheckNameUniqueness(Rec, Name, "Tax Type");
            end;
        }
        field(3; "Visible On Interface"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Visible On Interface';
        }
        field(7; Type; Option)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Type';
            InitValue = "Text";
            OptionMembers = Option,Text,Integer,Decimal,Boolean,Date;
            OptionCaption = 'Option,Text,Integer,Decimal,Boolean,Date';
        }
        field(10; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(20; "Rounding Precision"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision';
            DecimalPlaces = 0 : 5;
            InitValue = 0.01;
        }
        field(21; "Skip Posting"; Boolean)
        {
            AutoFormatType = 1;
            DataClassification = CustomerContent;
            Caption = 'Skip Posting';
        }
        field(22; Direction; Enum "Rounding Direction")
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
        }
        field(23; "Component Type"; Option)
        {
            Caption = 'Component Type';
            DataClassification = CustomerContent;
            OptionMembers = Normal,Formula;
            trigger OnValidate()
            var
                TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
            begin
                if (xRec."Component Type" <> rec."Component Type") then
                    if not IsNullGuid("Formula ID") then begin
                        TaxTypeObjHelper.DeleteComponentFormula("Formula ID");
                        Clear("Formula ID");
                    end;
            end;
        }
        field(24; "Formula ID"; Guid)
        {
            Caption = 'Formula ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(K0; "Tax Type", ID)
        {
            Clustered = True;
        }
        key(K1; Name)
        {
        }
    }

    var
        NameAlreadyExistsErr: Label 'The attribute with name ''%1'' already exists.', Comment = '%1 - arbitrary name';

    trigger OnDelete()
    var
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
        if not IsNullGuid("Formula ID") then begin
            TaxTypeObjHelper.DeleteComponentFormula("Formula ID");
            Clear("Formula ID");
        end;
    end;

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

    local procedure CheckNameUniqueness(TaxComponent: Record "Tax Component"; NameToCheck: Text[250]; TaxType: Code[20]);
    begin
        TaxComponent.SetRange(Name, NameToCheck);
        TaxComponent.SetFilter(ID, '<>%1', TaxComponent.ID);
        TaxComponent.SetFilter("Tax Type", '%1', TaxType);
        if not TaxComponent.IsEmpty() then
            Error(NameAlreadyExistsErr, NameToCheck);
    end;
}