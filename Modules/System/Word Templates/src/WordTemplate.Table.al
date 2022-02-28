// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about a Word template.
/// </summary>
table 9988 "Word Template"
{
    Access = Public;
    Extensible = false;

    fields
    {
        field(1; "Code"; Code[30])
        {
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; Template; Media)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Table Caption"; Text[80])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
        }
        field(6; "Language Code"; Code[10])
        {
            DataClassification = SystemMetadata;
            TableRelation = Language;
        }
        field(7; "Language Name"; Text[80])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Language.Name where(Code = field("Language Code")));
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }

        key(Language; "Language Code")
        {
        }
    }
}
