// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>
/// Table that saves settings the Application defines.
/// </summary>
table 9173 "Extra Settings"
{
    Access = Internal;
    InherentEntitlements = rimX;
    InherentPermissions = rimX;
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteTag = '23.0';
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