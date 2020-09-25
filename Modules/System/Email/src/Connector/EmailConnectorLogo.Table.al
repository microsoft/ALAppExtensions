// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 8887 "Email Connector Logo"
{
    DataClassification = SystemMetadata;
    Access = Internal;

    fields
    {
        field(1; Connector; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }
        field(2; Logo; Media)
        {
            DataClassification = CustomerContent;
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