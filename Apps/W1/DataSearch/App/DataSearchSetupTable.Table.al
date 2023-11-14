namespace Microsoft.Foundation.DataSearch;

using System.Environment.Configuration;
using System.Reflection;

table 2681 "Data Search Setup (Table)"
{
    Caption = 'Search Setup (Table)';
    ReplicateData = true;
    InherentEntitlements = RIMDX;
    InherentPermissions = RmX;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = SystemMetadata;
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
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
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
        DataSearchDefaults: codeunit "Data Search Defaults";
    begin
        DataSearchDefaults.AddDefaultFields(Rec."Table No.");
    end;

    /// <summary>
    /// Used for also inserting related records, e.g. for SalesHeader that has several subtypes
    /// </summary>
    internal procedure InsertRec(WithSubTypes: Boolean)
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        SubtypeList: list of [Integer];
        Subtype: Integer;
        SubTableNos: List of [Integer];
        SubTableNo: Integer;
    begin
        if Rec.Insert(true) then;
        DataSearchSetupTable := Rec;
        SubTableNos := DataSearchObjectMapping.GetSubTableNos(Rec."Table No.");
        if SubTableNos.Count > 0 then begin
            foreach SubTableNo in SubtableNos do begin
                Rec."Table No." := SubTableNo;
                Rec."Table/Type ID" := 0; // to assign new sequence no.
                if Rec.Insert(true) then;
            end;
            Rec := DataSearchSetupTable;
        end;
        if Rec.IsTemporary() then
            exit;

        if not WithSubTypes then
            exit;
        DataSearchObjectMapping.GetSubtypes(Rec, SubtypeList);
        SubTableNos.Add(Rec."Table No.");  // so parent table and potential subtables are handled in one loop
        foreach SubTableNo in SubtableNos do
            foreach Subtype in SubtypeList do
                if Subtype <> 0 then begin // zero has already been taken care of
                    DataSearchSetupTable := Rec;
                    DataSearchSetupTable."Table No." := SubTableNo;
                    DataSearchSetupTable."Table Subtype" := Subtype;
                    DataSearchSetupTable."Table/Type ID" := 0; // to assign new sequence no.
                    if DataSearchSetupTable.Insert() then;
                end;
    end;

    /// <summary>
    /// Used for also deleting related records, e.g. for SalesHeader that has several subtypes
    /// </summary>    
    internal procedure DeleteRec(WithSubTypes: Boolean)
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        SubTableNos: List of [Integer];
        SubTableNo: Integer;
    begin
        if not Rec.Find() then
            exit;
        if Rec.Delete(true) then;
        if Rec.IsTemporary() then
            exit;
        SubTableNos := DataSearchObjectMapping.GetSubTableNos(Rec."Table No.");
        SubTableNos.Add(Rec."Table No.");  // so parent table and potential subtables are handled in one loop
        foreach SubTableNo in SubtableNos do begin
            DataSearchSetupTable.SetRange("Role Center ID", Rec."Role Center ID");
            DataSearchSetupTable.SetRange("Table No.", SubTableNo);
            if WithSubTypes then
                DataSearchSetupTable.SetRange("Table Subtype")
            else
                DataSearchSetupTable.SetRange("Table Subtype", Rec."Table Subtype");
            DataSearchSetupTable.DeleteAll();
        end;
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