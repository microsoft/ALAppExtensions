table 20241 "Tax Attribute"
{
    Caption = 'Tax Attribute';
    LookupPageID = "Tax Attributes";
    DrillDownPageID = "Tax Attributes";
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
            AutoIncrement = true;
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
                if HasBeenUsed() then
                    if not Confirm(RenameUsedAttributeQst) then
                        Error('');
                CheckNameUniqueness(Rec, Name, "Tax Type");
            end;
        }
        field(7; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            InitValue = "Text";
            OptionMembers = Option,Text,Integer,Decimal,Boolean,Date;
            OptionCaption = 'Option,Text,Integer,Decimal,Boolean,Date';

            trigger OnValidate();

            var
                GenericAttributeValue: Record "Tax Attribute Value";
                EntityAttributeMapping: Record "Entity Attribute Mapping";
            begin
                if xRec.Type <> Type then begin
                    GenericAttributeValue.SetRange("Attribute ID", ID);
                    if not GenericAttributeValue.IsEmpty() then
                        Error(ChangingAttributeTypeErr, Name);

                    EntityAttributeMapping.SetRange("Attribute ID", ID);
                    EntityAttributeMapping.SetFilter("Mapping Field Name", '<>%1', '');
                    if EntityAttributeMapping.FindSet() then begin
                        EntityAttributeMapping.ModifyAll("Mapping Field ID", 0);
                        EntityAttributeMapping.ModifyAll("Mapping Field Name", '');
                    end;
                end;
            end;
        }

        field(10; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }

        field(16; "Visible on Interface"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Visible on Interface';
        }
        field(17; "Refrence Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Reference Table ID';
        }
        field(18; "Refrence Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Reference Field ID';
            trigger OnValidate()
            var
                FieldDataType: Enum "Symbol Data Type";
            begin
                if "Refrence Field ID" = 0 then
                    exit;
                FieldDataType := ScriptDataTypeMgmt.GetFieldDatatype("Refrence Table ID", "Refrence Field ID");
                if FieldDataType = GLOBALDATATYPE::OPTION then begin
                    Validate(Type, Type::Option);
                    FillAttributeValues("Tax Type", ID, ScriptDataTypeMgmt.GetFieldOptionString("Refrence Table ID", "Refrence Field ID"));
                end;
            end;
        }
        field(19; "Lookup Page ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Lookup Page ID';
        }
        field(20; "Grouped In SubLedger"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Grouped in SubLedger';
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
        ChangingAttributeTypeErr: Label 'You cannot change the type of attribute ''%1'', because it is either in use or it has predefined values.', Comment = '%1 - arbirtrary text';
        DeleteUsedAttributeQst: Label 'This attribute has been assigned to at least one Tax Entity.\\Are you sure you want to delete it?';
        RenameUsedAttributeQst: Label 'This attribute has been assigned to at least one Tax Entity.\\Are you sure you want to rename it?';
        ChangeToOptionQst: Label 'Predefined values can be defined only for attributes of type Option.\\Do you want to change the type of this attribute to Option?';

    procedure GetValues() Values: Text;
    var
        TaxAttributeValue: Record "Tax Attribute Value";
    begin
        if Type <> Type::Option then
            exit('');
        TaxAttributeValue.SetRange("Attribute ID", ID);
        if TaxAttributeValue.FindSet() then
            repeat
                if Values <> '' then
                    Values += ',';
                Values += TaxAttributeValue.Value;
            until TaxAttributeValue.Next() = 0;
    end;

    procedure HasBeenUsed(): Boolean;
    var
        AttributeValueMapping: Record "Tax Attribute Value Mapping";
    begin
        AttributeValueMapping.SetRange("Attribute ID", ID);
        exit(not AttributeValueMapping.IsEmpty());
    end;

    procedure OpenAttributeValues();
    var
        GenericAttributeValue: Record "Tax Attribute Value";
    begin
        GenericAttributeValue.SetRange("Attribute ID", ID);
        if (Type <> Type::Option) and GenericAttributeValue.IsEmpty() then
            if Confirm(ChangeToOptionQst) then begin
                Validate(Type, Type::Option);
                Modify();
            end;

        if Type = Type::Option then
            Page.Run(Page::"Tax Attribute Values", GenericAttributeValue);
    end;

    local procedure CheckNameUniqueness(GenericAttribute: Record "Tax Attribute"; NameToCheck: Text[250]; TaxType: Code[20]);
    begin
        GenericAttribute.SetRange(Name, NameToCheck);
        GenericAttribute.SetFilter(ID, '<>%1', GenericAttribute.ID);
        GenericAttribute.SetFilter("Tax Type", '%1', TaxType);
        if not GenericAttribute.IsEmpty() then
            Error(NameAlreadyExistsErr, NameToCheck);
    end;

    procedure NameAlreadyExist(NameToCheck: Text[250]; TaxType: Code[20]): Boolean
    var
        TaxAttribute: record "Tax Attribute";
    begin
        TaxAttribute.SetFilter("Tax Type", '%1|%2', TaxType, '');
        TaxAttribute.SetRange(Name, NameToCheck);
        exit(not TaxAttribute.IsEmpty());
    end;

    local procedure DeleteValuesAndMapping();
    var
        GenericAttributeValue: Record "Tax Attribute Value";
        AttributeValueMapping: Record "Tax Attribute Value Mapping";
    begin
        AttributeValueMapping.SetRange("Attribute ID", ID);
        AttributeValueMapping.DeleteAll();

        GenericAttributeValue.SetRange("Attribute ID", ID);
        GenericAttributeValue.DeleteAll();
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

    trigger OnDelete();
    var
        EntityAttributeMapping: Record "Entity Attribute Mapping";
        RecordAttributeMapping: Record "Record Attribute Mapping";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");

        if HasBeenUsed() then
            if not Confirm(DeleteUsedAttributeQst) then
                Error('');

        DeleteValuesAndMapping();

        EntityAttributeMapping.SetRange("Attribute ID", ID);
        if not EntityAttributeMapping.IsEmpty() then
            EntityAttributeMapping.DeleteAll(true);

        RecordAttributeMapping.SetRange("Attribute ID", ID);
        if RecordAttributeMapping.FindFirst() then
            Error(AttributeUsedInRecordErr, Name, Format(RecordAttributeMapping."Attribute Record ID", 9));
    end;

    local procedure FillAttributeValues(TaxType: Code[20]; AttributeID: Integer; OptionString: Text)
    var
        TaxAttributeValue: Record "Tax Attribute Value";
        OptionList: List of [Text];
        Value: Text;
        i: Integer;
        Counter: Integer;
    begin
        TaxAttributeValue.SetRange("Tax Type", TaxType);
        TaxAttributeValue.SetRange("Attribute ID", AttributeID);
        if not TaxAttributeValue.IsEmpty() then
            TaxAttributeValue.DeleteAll();

        ScriptDataTypeMgmt.GetOptionTextList(OptionString, OptionList);
        Counter := 0;
        for i := 1 to OptionList.Count() do begin
            TaxAttributeValue.Init();
            TaxAttributeValue.Validate("Tax Type", TaxType);
            TaxAttributeValue.Validate("Attribute ID", AttributeID);
            TaxAttributeValue.Validate(ID, Counter);
            OptionList.Get(i, Value);
            TaxAttributeValue.Validate(Value, Value);
            TaxAttributeValue.Insert(true);
            Counter += 1;
        end;
    end;

    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        GLOBALDATATYPE: Enum "Symbol Data Type";
        AttributeUsedInRecordErr: Label 'You cannot delete Attribute %1 as it is in use on Record : %2.', Comment = '%1 = attribute name %2 = record name';
}