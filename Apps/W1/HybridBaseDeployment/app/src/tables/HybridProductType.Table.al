// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

table 4000 "Hybrid Product Type"
{
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "ID"; Text[250])
        {
            Description = 'The id used to identify the product';
            DataClassification = SystemMetadata;
        }
        field(2; "Display Name"; Text[250])
        {
            Description = 'The display name of the product';
            DataClassification = SystemMetadata;
        }
        field(3; "App ID"; Guid)
        {
            Description = 'The product extension app id';
            DataClassification = SystemMetadata;
        }
        field(4; "Custom Migration Provider"; Enum "Custom Migration Provider")
        {
            Caption = 'Custom Migration Provider';
            Description = 'Specifies the custom migration provider associated with this product type.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}