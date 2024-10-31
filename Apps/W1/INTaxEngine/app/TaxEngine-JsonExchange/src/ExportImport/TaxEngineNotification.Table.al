// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

table 20364 "Tax Engine Notification"
{
    DataClassification = SystemMetadata;
    Access = Internal;

    fields
    {
        field(1; "Id"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Id';
        }
        field(2; "Message"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Message';
        }
        field(3; Hide; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Hide';
        }
    }

    keys
    {
        key(Key1; "Id")
        {
            Clustered = true;
        }
    }
}
