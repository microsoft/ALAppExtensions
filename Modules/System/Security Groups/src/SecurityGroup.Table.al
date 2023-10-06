// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

table 9020 "Security Group"
{
    Access = Internal;
    InherentEntitlements = rX;
    InherentPermissions = rX;
    Caption = 'Security Group';
    DataPerCompany = false;
    LookupPageID = "Security Groups";
    ReplicateData = false;

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        // User security ID of a user record that represents a Microsoft Entra group or a Windows group 
        field(2; "Group User SID"; Guid)
        {
            TableRelation = User;
            NotBlank = true;
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        // object ID of a Microsoft Entra security group
        field(3; "AAD Group ID"; Text[80])
        {
            CalcFormula = lookup("User Property"."Authentication Object ID" where("User Security ID" = field("Group User SID")));
            Editable = false;
            FieldClass = FlowField;
        }
        // Windows security ID of a Windows group
        field(4; "Windows Group ID"; Text[119])
        {
            CalcFormula = lookup(User."Windows Security ID" where("User Security ID" = field("Group User SID")));
            Editable = false;
            FieldClass = FlowField;
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

