namespace Microsoft.Foundation.DataSearch;

using System.Reflection;

table 2682 "Data Search Setup (Field)"
{
    Caption = 'Search Setup (Field)';
    ReplicateData = true;
    InherentEntitlements = R;
    InherentPermissions = R;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = "Data Search Setup (Table)";
            DataClassification = SystemMetadata;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = field."No." where(TableNo = field("Table No."));
            DataClassification = SystemMetadata;
        }
        field(3; "Field Caption"; Text[100])
        {
            CalcFormula = lookup(field."Field Caption" where(TableNo = field("Table No."),
                                                              "No." = field("Field No.")));
            Caption = 'Field Caption';
            FieldClass = Flowfield;
        }
        field(4; "Enable Search"; Boolean)
        {
            Caption = 'Enable Search';
            DataClassification = SystemMetadata;
        }
        field(9; "Table Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table),
                                                                           "Object ID" = field("Table No.")));
            Caption = 'Table Caption';
            FieldClass = Flowfield;
        }
    }

    keys
    {
        key(Key1; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

}

