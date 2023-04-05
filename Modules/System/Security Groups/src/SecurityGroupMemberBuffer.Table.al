// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The container used for fetching security group memberships.
/// </summary>
table 9021 "Security Group Member Buffer"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;
    TableType = Temporary;
    Caption = 'Security Group Member';

    fields
    {
        field(1; "Security Group Code"; Code[20])
        {
            Caption = 'Security Group Code';
        }
        field(2; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
        }
        field(3; "Security Group Name"; Text[250])
        {
            Caption = 'Security Group Name';
        }
        field(4; "User Name"; Code[50])
        {
            CalcFormula = lookup(User."User Name" where("User Security ID" = field("User Security ID")));
            Caption = 'User Name';
            FieldClass = FlowField;
        }
        field(5; "User Full Name"; Text[80])
        {
            CalcFormula = lookup(User."Full Name" where("User Security ID" = field("User Security ID")));
            Caption = 'User Full Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Security Group Code", "User Security ID")
        {
            Clustered = true;
        }
    }
}

