// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Temporary table that holds information about entities accessible from the address book.
/// </summary>
table 8945 "Address Entity"
{
    Access = Public;
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Source Name"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(2; SourceTable; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Source Name", SourceTable)
        {
            Clustered = true;
        }
    }

}