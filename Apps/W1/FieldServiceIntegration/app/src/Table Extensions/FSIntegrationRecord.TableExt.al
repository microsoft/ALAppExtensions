// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;

tableextension 6618 "FS Integration Record" extends "CRM Integration Record"
{
    fields
    {
        field(12000; "Archived Service Order"; Boolean)
        {
            Caption = 'Archived Service Order';
            DataClassification = SystemMetadata;
        }
        field(12001; "Archived Service Order Updated"; Boolean)
        {
            Caption = 'Archived Service Order Updated';
            DataClassification = SystemMetadata;
        }
        field(12002; "Archived Service Header Id"; Guid)
        {
            Caption = 'Archived Service Header Id';
            DataClassification = SystemMetadata;
        }
        field(12003; "Archived Service Line Id"; Guid)
        {
            Caption = 'Archived Service Line Id';
            DataClassification = SystemMetadata;
        }
        field(12004; "Skip Reimport"; Boolean)
        {
            Caption = 'Skip Reimport';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Archived Service Header Id")
        {
        }
        key(Key2; "Archived Service Line Id")
        {
        }
    }
}
