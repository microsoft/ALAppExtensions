// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Represents the available tables that could be used in a Word template.
/// </summary>
table 9987 "Word Templates Table"
{
    Access = Internal;
    Extensible = false;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Table Caption"; Text[80])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
        }
    }

    keys
    {
        key(PK; "Table ID")
        {
            Clustered = true;
        }
    }
}
