// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 4508 "Email - Outlook Account"
{
    DataClassification = CustomerContent;
    DataCaptionFields = "Email Address";

    fields
    {
        field(1; "Id"; Guid)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[250])
        {
            Caption = 'Account Name';
            DataClassification = CustomerContent;
        }
        field(3; "Email Address"; Text[250])
        {
            Caption = 'Email Address';
            DataClassification = CustomerContent;
        }
        field(4; "Outlook API Email Connector"; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Created By"; Text[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            ObsoleteReason = 'Unused, can be replaced by SystemCreatedBy and correlate with the User table''s  User Security Id.';
            ObsoleteState = Removed;
            ObsoleteTag = '20.0';
        }
    }

    keys
    {
        key(PK; Id)
        {
        }
        key(EmailAddress; "Email Address")
        {
            Unique = true;
        }
    }
}