// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

using System.Reflection;

/// <summary>
/// Holds information about entities in a Word Template.
/// </summary>
table 9991 "Word Templates Related Buffer"
{
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    Access = Internal;
    TableType = Temporary;
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
        field(8; "Source Record ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(10; Position; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(11; Depth; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(12; "Table Caption"; Text[249])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
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
        key(Key3; Position)
        {
        }
    }
}