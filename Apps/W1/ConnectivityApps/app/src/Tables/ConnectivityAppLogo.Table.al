// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 20352 "Connectivity App Logo"
{
    Access = Internal;
    Extensible = false;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "App Id"; Guid)
        {
            Caption = 'App Id';
            DataClassification = SystemMetadata;
        }
        field(2; Logo; Media)
        {
            Caption = 'Logo';
            DataClassification = SystemMetadata;
        }
        field(3; "AppSource URL"; Text[2048])
        {
            Caption = 'AppSource URL';
            DataClassification = SystemMetadata;
        }
        field(4; "Expiry Date"; DateTime)
        {
            Caption = 'Expiry Date';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "App Id")
        {
            Clustered = true;
        }
    }
}