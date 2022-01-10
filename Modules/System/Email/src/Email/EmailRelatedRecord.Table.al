// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

///<summary>
/// Holds the relations between emails and records.
/// </summary>
table 8909 "Email Related Record"
{
    DataClassification = SystemMetadata;
    Access = Internal;

    fields
    {
        field(1; "Email Message Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Table Id"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "System Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Relation Type"; Enum "Email Relation Type")
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// The origin of this relation. When or how it was added to the email.
        /// </summary>
        field(5; "Relation Origin"; Enum "Email Relation Origin")
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Table Id", "System Id", "Email Message Id")
        {
            Clustered = true;
        }
    }
}