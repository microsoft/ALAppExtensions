// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47053 "SL Segment Name"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; "Company Name"; Text[50])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Description = 'Name of the Company that the segment belongs to.';
        }
        field(2; "Segment Number"; Integer)
        {
            Description = 'Number for the segment.';
        }
        field(3; "Segment Name"; Text[30])
        {
            Description = 'Name of the segment.';
        }
    }

    keys
    {
        key(Key1; "Company Name", "Segment Number", "Segment Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Segment Name", "Segment Number")
        {
            Caption = 'Values to display in a dropdown list.';
        }
    }
}