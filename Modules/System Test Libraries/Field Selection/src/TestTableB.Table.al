// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Reflection;

table 135037 "Test Table B"
{
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; MyField; Integer)
        {
            DataClassification = SystemMetadata;

        }

        field(2; MyField2; Decimal)
        {
            DataClassification = SystemMetadata;

        }

        field(3; MyField3; Text[50])
        {
            DataClassification = SystemMetadata;

        }
    }

    keys
    {
        key(PK; MyField)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}