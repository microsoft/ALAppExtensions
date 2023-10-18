// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// The container used for fetching the defined security groups.
/// </summary>
table 9022 "Security Group Buffer"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;
    TableType = Temporary;
    Caption = 'Security Group';

    fields
    {
        /// <summary>
        /// The security group code.
        /// </summary>
        field(1; "Code"; Code[20])
        {
        }
        /// <summary>
        /// User security ID of a special user record that corresponds to a Microsoft Entra security group or Windows group.
        /// </summary>
        field(2; "Group User SID"; Guid)
        {
            TableRelation = User;
        }
        /// <summary>
        /// SID of a Windows group or an object ID of a Microsoft Entra security group.
        /// </summary>
        field(3; "Group ID"; Text[250])
        {
        }
        /// <summary>
        /// Windows group name or a Microsoft Entra security group name.
        /// </summary>
        field(4; "Group Name"; Text[250])
        {
        }
        /// <summary>
        /// Whether the group was retrieved successfully from Graph / Windows Active Directory.
        /// </summary>
        field(5; "Retrieved Successfully"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
}

