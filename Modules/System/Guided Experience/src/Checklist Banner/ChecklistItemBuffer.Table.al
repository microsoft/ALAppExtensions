// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1995 "Checklist Item Buffer"
{
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(1; ID; Guid)
        {
            Caption = 'ID';
            DataClassification = SystemMetadata;
        }
        field(2; Code; Code[300])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(3; Version; Integer)
        {
            Caption = 'Version';
            DataClassification = SystemMetadata;
        }
        field(4; "Object Type to Run"; Enum "Guided Experience Object Type")
        {
            Caption = 'Object Type to Run';
            DataClassification = SystemMetadata;
        }
        field(5; "Object ID to Run"; Integer)
        {
            Caption = 'Object ID to Run';
            DataClassification = SystemMetadata;
        }
        field(6; Link; Text[250])
        {
            Caption = 'External Link';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(7; Title; Text[2048])
        {
            Caption = 'Title';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(8; "Short Title"; Text[50])
        {
            Caption = 'Short Title';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(9; Description; Text[1024])
        {
            Caption = 'Description';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(10; "Expected Duration"; Integer)
        {
            Caption = 'Expected Duration';
            DataClassification = SystemMetadata;
        }
        field(11; "Extension Name"; Text[250])
        {
            Caption = 'Extension Name';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(12; "Guided Experience Type"; Enum "Guided Experience Type")
        {
            Caption = 'Guided Experience Type';
            DataClassification = SystemMetadata;
        }
        field(13; Status; Enum "Checklist Item Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(14; "Order ID"; Integer)
        {
            Caption = 'Order ID';
            DataClassification = SystemMetadata;
        }
        field(15; "Completion Requirements"; Enum "Checklist Completion Requirements")
        {
            Caption = 'Completion Requirements';
            DataClassification = SystemMetadata;
        }
        field(16; "Assigned To"; Text[50])
        {
            Caption = 'Assigned To';
            DataClassification = SystemMetadata;
        }
        field(17; "Spotlight Tour Type"; Enum "Spotlight Tour Type")
        {
            Caption = 'Spotlight Tour Type';
            DataClassification = SystemMetadata;
        }
        field(18; "Video Url"; Text[250])
        {
            Caption = 'Video';
            DataClassification = OrganizationIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
        key(Key2; Code, Version)
        {
            Clustered = false;
            Unique = true;
        }
        key(key3; "Order ID")
        {

        }
    }
}