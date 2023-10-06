// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Reflection;

table 138706 "Record Reference Test"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    Caption = 'Record Reference Test Caption';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Description"; Text[30])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Description 2"; Text[30])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Description 3"; Text[30])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PrimaryKey; "Entry No.")
        {
            Clustered = true;
        }
    }
}