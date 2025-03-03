// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

table 6441 "SignUp Metadata Profile"
{
    Caption = 'MetadataProfile';
    Access = Internal;
    DataClassification = CustomerContent;
    LookupPageId = "SignUp Metadata Profiles";

    fields
    {
        field(1; "Profile ID"; Integer)
        {
            Caption = 'Profile ID';
            Tooltip = 'Specifies the unique identifier for the metadata profile.';
        }
        field(2; "Profile Name"; Text[250])
        {
            Caption = 'Profile Name';
            Tooltip = 'Specifies the common name of the metadata profile.';
        }
        field(3; "Process Identifier Scheme"; Text[250])
        {
            Caption = 'Process Identifier Scheme';
            Tooltip = 'Specifies the scheme of the process identifier.';
        }
        field(4; "Process Identifier Value"; Text[2048])
        {
            Caption = 'Process Identifier Value';
            Tooltip = 'Specifies the value of the process identifier.';
        }
        field(5; "Document Identifier Scheme"; Text[250])
        {
            Caption = 'Document Identifier Scheme';
            Tooltip = 'Specifies the scheme of the document identifier.';
        }
        field(6; "Document Identifier Value"; Text[2048])
        {
            Caption = 'Document Identifier Value';
            Tooltip = 'Specifies the value of the document identifier.';
        }
    }

    keys
    {
        key(PK; "Profile ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Profile Id", "Profile Name")
        {
        }
    }
}