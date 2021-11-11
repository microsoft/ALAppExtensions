// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 8703 "Feature Uptake"
{
    Access = Internal;

    fields
    {
        field(1; "Feature Name"; Text[250])
        {
            NotBlank = true;
            DataClassification = SystemMetadata;
        }
        field(2; "User Security ID"; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(3; Publisher; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Feature Uptake Status"; Enum "Feature Uptake Status")
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PrimaryKey; "Feature Name", "User Security ID", Publisher)
        {
            Clustered = true;
        }
    }
}