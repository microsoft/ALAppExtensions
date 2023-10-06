// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

table 1876 "Business Setup Icon"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Caption = 'Business Setup Icon';
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteTag = '23.0';
    ObsoleteReason = 'The Manual Setup module and its objects have been consolidated in the Guided Experience module.';
    ReplicateData = false;

    fields
    {
        field(1; "Business Setup Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Business Setup Name';
        }
        field(2; Icon; Media)
        {
            DataClassification = CustomerContent;
            Caption = 'Icon';
        }
        field(3; "Media Resources Ref"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Media Resources Ref';
        }
    }

    keys
    {
        key(Key1; "Business Setup Name")
        {
            Clustered = true;
        }
    }

}

