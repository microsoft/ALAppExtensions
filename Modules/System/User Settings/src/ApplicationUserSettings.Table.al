// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Table that stores user settings the Application defines.
/// </summary>
table 9222 "Application User Settings"
{
    Access = Internal;
    DataPerCompany = false;
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