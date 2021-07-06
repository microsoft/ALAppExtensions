// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about entities that are related to a source entity of a Word Template.
/// </summary>
table 9990 "Word Templates Related Table"
{
    Access = Internal;
    Extensible = false;

    fields
    {
        field(1; "Code"; Code[30])
        {
            DataClassification = CustomerContent;
            TableRelation = "Word Template";
        }
        field(2; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Related Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Related Table Caption"; Text[249])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Related Table ID")));
        }
        field(5; "Field No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Field Caption"; Text[80])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table ID"), "No." = field("Field No.")));
        }
        field(7; "Related Table Code"; Code[5])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
    }

    keys
    {
        key(PK; Code, "Related Table ID")
        {
            Clustered = true;
        }
        key(Key2; Code, "Related Table Code")
        {
        }
    }
}