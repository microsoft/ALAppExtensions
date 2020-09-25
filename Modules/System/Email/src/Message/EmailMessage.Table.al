// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary></summary>
table 8900 "Email Message"
{
    Access = Internal;

    fields
    {
        field(1; Id; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(2; Subject; Text[2048])
        {
            DataClassification = CustomerContent;
        }
        field(3; Body; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(4; Editable; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "HTML Formatted Body"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = True;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}