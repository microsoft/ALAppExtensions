// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1993 "Checklist Item User"
{
    Access = Internal;
    Caption = 'Checklist Item User';

    fields
    {
        field(1; Code; Code[300])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            TableRelation = "Checklist Item".Code;
        }
        field(2; Version; Integer)
        {
            Caption = 'Version';
            DataClassification = SystemMetadata;
            TableRelation = "Guided Experience Item".Version;
        }
        field(3; "User ID"; Code[50])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(4; "Checklist Item Status"; Enum "Checklist Item Status")
        {
            Caption = 'Checklist Item Status';
            DataClassification = SystemMetadata;
        }
        field(5; "Is Visible"; Boolean)
        {
            Caption = 'Is Visible';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(6; "Assigned to User"; Boolean)
        {
            Caption = 'Assigned to User';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; Code, "User ID")
        {
            Clustered = true;
        }
        key(Key2; "User ID", "Is Visible")
        {

        }
    }

    fieldgroups
    {
    }
}