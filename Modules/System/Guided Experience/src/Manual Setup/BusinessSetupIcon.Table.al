// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1876 "Business Setup Icon"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Caption = 'Business Setup Icon';
    DataPerCompany = false;
#if CLEAN18
    ObsoleteState = Removed;
    ObsoleteTag = '23.0';
#else
    ObsoleteState = Pending;
    ObsoleteTag = '18.0';
#endif
    ObsoleteReason = 'The Manual Setup module and its objects have been consolidated in the Guided Experience module.';
    ReplicateData = false;

    fields
    {
        field(1; "Business Setup Name"; Text[50])
        {
            Caption = 'Business Setup Name';
        }
        field(2; Icon; Media)
        {
            Caption = 'Icon';
        }
        field(3; "Media Resources Ref"; Code[50])
        {
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

