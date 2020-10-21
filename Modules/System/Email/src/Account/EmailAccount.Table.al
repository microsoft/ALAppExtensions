// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A common representation of an email account.
/// </summary>
table 8902 "Email Account"
{
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(1; "Account Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }

        field(2; Name; Text[250])
        {
            DataClassification = SystemMetadata; // Field only in Memory
        }

        field(3; "Email Address"; Text[250])
        {
            DataClassification = SystemMetadata; // Field only in Memory
        }

        field(4; Connector; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }

        field(5; Logo; Media)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }

        field(6; LogoBlob; Blob)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Subtype = Bitmap;
        }
    }

    keys
    {
        key(PK; "Account Id", Connector)
        {
            Clustered = true;
        }

        key(Name; Name)
        {
            Description = 'Used for sorting';
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Logo, Name, "Email Address")
        {

        }
    }

}