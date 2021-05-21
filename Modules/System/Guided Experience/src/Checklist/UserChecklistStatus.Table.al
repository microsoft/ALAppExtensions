// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1994 "User Checklist Status"
{
    Access = Internal;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(2; "Role ID"; Code[30])
        {
            Caption = 'Role ID';
            DataClassification = SystemMetadata;
            TableRelation = "All Profile"."Profile ID";
        }
        field(3; "Checklist Status"; Enum "Checklist Status")
        {
            Caption = 'Checklist Status';
            DataClassification = SystemMetadata;
        }
        field(4; "Is Current Role Center"; Boolean)
        {
            Caption = 'Is Current Role Center';
            DataClassification = SystemMetadata;
        }
        field(5; "Is Visible"; Boolean)
        {
            Caption = 'Is Visible';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "User ID", "Role ID")
        {
            Clustered = true;
        }
        key(Key2; "User ID", "Is Current Role Center")
        {
        }
    }
}