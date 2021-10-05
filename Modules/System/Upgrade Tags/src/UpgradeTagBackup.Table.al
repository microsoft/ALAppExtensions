// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
table 9996 "Upgrade Tag Backup"
{
    Access = Internal;
    Caption = 'Upgrade Tag Backup';
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    Extensible = false;
    ReplicateData = false;

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; Content; Blob)
        {
            Caption = 'Content';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Id; Id)
        {
            Clustered = true;
        }
    }
}