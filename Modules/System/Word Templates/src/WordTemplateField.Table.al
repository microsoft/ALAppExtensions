// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

using System.Reflection;

table 9989 "Word Template Field"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "Word Template Code"; Code[30])
        {
            DataClassification = CustomerContent;
            TableRelation = "Word Template";
        }
        field(2; "Table ID"; Integer) // Is 0 in case of unrelated custom field
        {
            DataClassification = SystemMetadata;
            TableRelation = Field.TableNo;
        }
        field(3; "Field Name"; Text[30])
        {
            DataClassification = SystemMetadata;
            TableRelation = Field.FieldName;
            ValidateTableRelation = false; // This may be a custom field
        }
        field(4; "Field No."; Integer) // Is 0 in case of custom field
        {
            DataClassification = SystemMetadata;
            TableRelation = Field."No.";
        }
        field(5; Exclude; Boolean) // This is an exclude field to make sure new fields to the table or new custom fields are automatically included without the user having to manually go enable them whenever we add new fields.
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Primary; "Word Template Code", "Table ID", "Field Name")
        {
            Clustered = true;
        }
        key(FieldNo; "Field No.")
        {
        }
    }
}