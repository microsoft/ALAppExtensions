// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Stores the user security IDs of the users who have logged in to the environment.
/// </summary>
table 9011 "User Environment Login"
{
    Access = Internal;
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        field(1; "User SID"; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
    }

    keys
    {
        key(Key1; "User SID")
        {
            Clustered = true;
        }
    }
}
