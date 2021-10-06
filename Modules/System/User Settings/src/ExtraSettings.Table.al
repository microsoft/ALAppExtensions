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
    
    fields
    {
        field(1;"User Security ID"; Guid)
        {
            DataClassification = EndUserIdentifiableInformation;
        }

        field(2;"Teaching Tips"; Boolean)
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