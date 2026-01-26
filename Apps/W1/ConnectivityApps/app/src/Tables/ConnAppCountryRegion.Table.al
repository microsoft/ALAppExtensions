// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

table 20351 "Conn. App Country/Region"
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
        field(2; "Country/Region"; Enum "Conn. Apps Country/Region")
        {
            Caption = 'Country/Region';
        }
        field(3; Category; Enum "Connectivity Apps Category")
        {
        }
        field(4; Localization; Enum "Connectivity Apps Localization")
        {
            Caption = 'Localization';
        }
    }

    keys
    {
        key(Key1; "App Id", "Country/Region", Localization)
        {
            Clustered = true;
        }
        key(Key2; "Country/Region", Category, Localization)
        {
        }
    }
}
