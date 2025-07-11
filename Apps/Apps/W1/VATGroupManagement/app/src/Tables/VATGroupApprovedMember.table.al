// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

table 4700 "VAT Group Approved Member"
{
    fields
    {
        field(1; ID; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
            Caption = 'Group Member ID';
        }
        field(2; "Group Member Name"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Group Member Name';
        }
        field(3; "Contact Person Name"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Contact Person Name';
        }
        field(4; "Contact Person Email"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Contact Person Email';
            ExtendedDatatype = EMail;
        }
        field(5; Company; Text[30])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Company';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(GroupMemberName; "Group Member Name")
        {
        }
    }
}
