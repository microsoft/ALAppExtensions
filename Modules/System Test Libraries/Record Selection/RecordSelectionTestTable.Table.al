// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Reflection;

table 135536 "Record Selection Test Table"
{
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; SomeInteger; Integer)
        {
        }

        field(2; SomeCode; Code[30])
        {
        }

        field(3; SomeText; Text[250])
        {
        }

        field(4; SomeOtherText; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; SomeInteger, SomeCode)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; SomeInteger, SomeCode, SomeText)
        {
        }
    }
}