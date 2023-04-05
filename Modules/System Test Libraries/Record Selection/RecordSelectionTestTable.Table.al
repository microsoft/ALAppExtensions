// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 135536 "Record Selection Test Table"
{
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; SomeInteger; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(2; SomeCode; Code[30])
        {
            DataClassification = ToBeClassified;
        }

        field(3; SomeText; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(4; SomeOtherText; Text[250])
        {
            DataClassification = ToBeClassified;
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