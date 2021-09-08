// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 9999 "Upgrade Tags"
{
    Access = Internal;
    Caption = 'Upgrade Tags';
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; Tag; Code[250])
        {
            Caption = 'Tag';
            DataClassification = SystemMetadata;
        }
        field(2; "Tag Timestamp"; DateTime)
        {
            Caption = 'Tag Timestamp';
            DataClassification = SystemMetadata;
        }
        field(3; Company; Code[30])
        {
            Caption = 'Company';
            DataClassification = SystemMetadata;
        }

        field(4; "Skipped Upgrade"; Boolean)
        {
            Caption = 'Skipped Upgrade';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Tag, Company)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

