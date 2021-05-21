table 20140 "Lookup Field Filter"
{
    Caption = 'Lookup Field Filter';
    DataClassification = CustomerContent;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
        }
        field(2; "Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Script ID';
        }
        field(3; "Table Filter ID"; Guid)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Lookup Table Filter".ID where("Case ID" = field("Case ID"));
            Caption = 'Table Filter ID';
        }
        field(4; "Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            NotBlank = true;
            TableRelation = Field."No." where(TableNo = field("Table ID"));
            Caption = 'Field ID';
        }
        field(5; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            TableRelation = AllObj."Object ID" where("Object Type" = const(Table));
            Caption = 'Table ID';
        }
        field(6; "Filter Type"; Enum "Conditional Operator")
        {
            DataClassification = CustomerContent;
            Caption = 'Filter Type';
            trigger OnValidate()
            begin
                ValidateDataType();
            end;
        }
        field(7; "Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = Constant,"Lookup";
            Caption = 'Value Type';
        }
        field(8; Value; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Value Text';
            trigger OnValidate();
            begin
                ValidateValue();
            end;
        }
        field(9; "Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", "Table Filter ID", "Field ID")
        {
            Clustered = True;
        }
    }

    local procedure ValidateValue();
    var
        FieldDatatype: Enum "Symbol Data Type";
        OptionString: Text;
        OptionIndex: Integer;
    begin
        if "Value Type" = "Value Type"::Constant then begin
            TestField("Table ID");
            TestField("Field ID");
            FieldDatatype := DataTypeMgmt.GetFieldDatatype("Table ID", "Field ID");
            if FieldDatatype = "Symbol Data Type"::Option then begin
                OptionString := DataTypeMgmt.GetFieldOptionString("Table ID", "Field ID");
                if TypeHelper.IsNumeric(Value) then
                    Value := DataTypeMgmt.GetOptionText(OptionString, DataTypeMgmt.Text2Number(Value))
                else begin
                    OptionIndex := TypeHelper.GetOptionNo(UPPERCASE(Value), UPPERCASE(OptionString));
                    if OptionIndex <> -1 then
                        Value := DataTypeMgmt.GetOptionText(OptionString, OptionIndex);
                end;
            end;
        end;
    end;

    local procedure ValidateDataType()
    var
        Datatype: Enum "Symbol Data Type";
        InvalidDatatypeOnFilterErr: Label '%1 is not allowed with %2', Comment = '%1 = Filter Type,%2 = Datatype';
    begin
        Datatype := DataTypeMgmt.GetFieldDatatype("Table ID", "Field ID");

        case Datatype of
            "Symbol Data Type"::String:
                if "Filter Type" in [
                    "Filter Type"::"Is Greater Than",
                    "Filter Type"::"Is Greater Than Or Equals To",
                    "Filter Type"::"Is Less Than",
                    "Filter Type"::"Is Less Than Or Equals To"]
                then
                    Error(InvalidDatatypeOnFilterErr, "Filter Type", Datatype);
            "Symbol Data Type"::Number:
                if "Filter Type" in [
                    "Filter Type"::"Begins With",
                    "Filter Type"::"Does Not Begin With",
                    "Filter Type"::"Ends With",
                    "Filter Type"::"Does Not End With",
                    "Filter Type"::Contains,
                    "Filter Type"::"Does Not Contain",
                    "Filter Type"::"Equals Ignore Case",
                    "Filter Type"::"Contains Ignore Case"]
                then
                    Error(InvalidDatatypeOnFilterErr, "Filter Type", Datatype);
            "Symbol Data Type"::Date,
            "Symbol Data Type"::Time:
                if "Filter Type" in [
                    "Filter Type"::"Begins With",
                    "Filter Type"::"Does Not Begin With",
                    "Filter Type"::"Ends With",
                    "Filter Type"::"Does Not End With",
                    "Filter Type"::Contains,
                    "Filter Type"::"Does Not Contain",
                    "Filter Type"::"Equals Ignore Case",
                    "Filter Type"::"Contains Ignore Case"]
                then
                    Error(InvalidDatatypeOnFilterErr, "Filter Type", Datatype);
            else
                if not ("Filter Type" in ["Filter Type"::Equals, "Filter Type"::"Not Equals"]) then
                    Error(InvalidDatatypeOnFilterErr, "Filter Type", Datatype);
        end;
    end;

    trigger OnInsert()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnModify();
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnDelete();
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
        if "Value Type" = "Value Type"::Lookup then
            EntityMgmt.DeleteLookup("Case ID", "Script ID", "Lookup ID");
    end;

    var
        EntityMgmt: Codeunit "Lookup Entity Mgmt.";
        TypeHelper: Codeunit "Type Helper";
        DataTypeMgmt: Codeunit "Script Data Type Mgmt.";
}