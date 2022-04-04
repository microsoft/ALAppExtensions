// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Temporary table that holds email address suggestions.
/// Table is used when user lookup addresses in the email editor.
/// </summary>
table 8944 "Email Address Lookup"
{
    Access = Public;
    TableType = Temporary;

    fields
    {
        /// <summary>
        /// Name of suggested contact.
        /// </summary>
        field(1; Name; Text[250])
        {
            DataClassification = CustomerContent;
        }
        /// <summary>
        /// Email address of suggested contact.
        /// </summary>
        field(2; "E-Mail Address"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        /// <summary>
        /// Company that suggested contact works for.
        /// </summary>
        field(3; Company; Text[250])
        {
            DataClassification = CustomerContent;
        }
        /// <summary>
        /// Table id for suggested record.
        /// </summary>
        field(4; "Source Table Number"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// System id for suggested record.
        /// </summary>
        field(5; "Source System Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// Records entity type.
        /// </summary>
        field(6; "Entity type"; Enum "Email Address Entity")
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "E-Mail Address", "Name", "Entity type")
        {
            Clustered = true;
        }
        key(Key2; Company, Name)
        {
        }
    }

}