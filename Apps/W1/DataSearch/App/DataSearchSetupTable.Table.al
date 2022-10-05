table 2681 "Data Search Setup (Table)"
{
    Caption = 'Search Setup (Table)';
    ReplicateData = true;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(2; "Table Subtype"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Role Center ID"; Integer)
        {
            Caption = 'Role Center ID';
            DataClassification = SystemMetadata;
        }
        field(4; "No. of Hits"; Integer)
        {
            Caption = 'No. of Hits';
            DataClassification = CustomerContent;
        }
        field(5; "Table/Type ID"; Integer)
        {
            Caption = 'Table/Type ID';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(9; "Table Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table), "Object ID" = FIELD("Table No.")));
            Caption = 'Table Caption';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Role Center ID", "Table No.", "Table Subtype")
        {
            Clustered = true;
        }
        key(Key2; "No. of Hits")
        {
        }
        key(Key3; "Table/Type ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchDefaults: codeunit "Data Search Defaults";
        SubtypeList: list of [Integer];
        Subtype: Integer;
    begin
        if Rec.IsTemporary() then
            exit;
        DataSearchDefaults.AddTextFields(Rec."Table No.");
        DataSearchDefaults.AddIndexedFields(Rec."Table No.");
        if Rec."Table/Type ID" > 0 then
            exit;
        GetSubtypes(SubtypeList);
        foreach Subtype in SubtypeList do
            if Subtype <> 0 then begin // zero has already been taken care of
                DataSearchSetupTable := Rec;
                DataSearchSetupTable."Table Subtype" := Subtype;
                if DataSearchSetupTable.Insert() then;
            end;
    end;

    trigger OnDelete()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
    begin
        if Rec.IsTemporary() then
            exit;
        DataSearchSetupTable.SetRange("Role Center ID", Rec."Role Center ID");
        DataSearchSetupTable.SetRange("Table No.", Rec."Table No.");
        DataSearchSetupTable.SetFilter("Table Subtype", '>0');
        DataSearchSetupTable.DeleteAll();
    end;

    local procedure GetSubtypes(var SubtypeList: list of [Integer])
    begin
        Case Rec."Table No." of
            Database::"Sales Header", Database::"Sales Line":
                GetSubtypesForField(SubtypeList, Database::"Sales Header", 1);
            Database::"Purchase Header", Database::"Purchase Line":
                GetSubtypesForField(SubtypeList, Database::"Purchase Header", 1);
            Database::"Service Header", Database::"Service Line":
                GetSubtypesForField(SubtypeList, Database::"Service Header", 1);
        end;
    end;

    local procedure GetSubtypesForField(var SubtypeList: list of [Integer]; TableNo: Integer; FieldNo: Integer)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        RecRef.Open(TableNo);
        FldRef := RecRef.Field(FieldNo);
        for i := 1 to FldRef.EnumValueCount() do
            SubtypeList.Add(FldRef.GetEnumValueOrdinal(i));
    end;

    internal procedure GetProfileID(): Code[30]
    var
        UserSettingsRec: Record "User Settings";
        UserSettings: Codeunit "User Settings";
    begin
        UserSettings.GetUserSettings(UserSecurityId(), UserSettingsRec);
        exit(UserSettingsRec."Profile ID");
    end;

    procedure GetRoleCenterID(): Integer
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Profile ID", GetProfileID());
        if AllProfile.FindFirst() then;
        exit(AllProfile."Role Center ID");
    end;
}