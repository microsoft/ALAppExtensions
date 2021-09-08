// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 8903 "Email Recipient"
{
    Access = Internal;

    fields
    {
        field(1; "Email Message Id"; Guid)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Email Message".Id;
        }

        field(2; "Email Address"; Text[250])
        {
            DataClassification = CustomerContent;
        }

        field(3; "Email Recipient Type"; Enum "Email Recipient Type")
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Email Message Id", "Email Address", "Email Recipient Type")
        {
            Clustered = true;
        }
    }
}