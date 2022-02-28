// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Table that saves settings the Application defines.
/// </summary>
table 9173 "Extra Settings"
{
    Access = Internal;
    DataPerCompany = false;
#if not CLEAN20
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '23.0';
#endif
    ObsoleteReason = 'Replaced with table 9222 "Application User Settings".';
    ReplicateData = false;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            DataClassification = EndUserIdentifiableInformation;
        }

        field(2; "Teaching Tips"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "User Security ID")
        {
            Clustered = true;
        }
    }
}