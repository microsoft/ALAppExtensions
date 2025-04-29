// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

table 20353 "Connectivity App Description"
{
    Access = Internal;
    TableType = Temporary;
    Extensible = false;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "App Id"; Guid)
        {
            Caption = 'App Id';
        }
        field(2; "Language Id"; Integer)
        {
            Caption = 'Language Id';
        }
        field(3; Description; Text[2048])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "App Id", "Language Id")
        {
            Clustered = true;
        }
    }
}
