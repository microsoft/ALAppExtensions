// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 20351 "Connectivity App Country"
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
            DataClassification = SystemMetadata;
        }
        field(2; Country; Enum "Conn. Apps Supported Country")
        {
            DataClassification = SystemMetadata;
        }
        field(3; Category; Enum "Connectivity Apps Category")
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "App Id", Country)
        {
            Clustered = true;
        }
        key(Key2; Country, Category)
        {
        }
    }
}