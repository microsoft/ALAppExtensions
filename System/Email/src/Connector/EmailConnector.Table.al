// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 8905 "Email Connector"
{
    TableType = Temporary;
    Access = Internal;

    fields
    {
        field(1; Connector; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }
        field(2; Logo; Blob)
        {
            DataClassification = SystemMetadata;
            Subtype = Bitmap;
        }
        field(3; Description; Text[250])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Connector)
        {
            Clustered = true;
        }
    }
}