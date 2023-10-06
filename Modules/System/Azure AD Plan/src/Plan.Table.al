// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

/// <summary>
/// Displays a list of plans.
/// </summary>
table 9004 Plan
{
    Caption = 'Subscription Plan';
    DataPerCompany = false;
    ReplicateData = false;
    Access = Internal;
    InherentEntitlements = rX;
    InherentPermissions = rX;

    fields
    {
        field(1; "Plan ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Plan ID';
        }
        field(2; Name; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Name';
        }
        field(3; "Role Center ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Role Center ID';
        }
    }

    keys
    {
        key(Key1; "Plan ID")
        {
            Clustered = true;
        }
        key(Key2; Name)
        {
        }
    }
}