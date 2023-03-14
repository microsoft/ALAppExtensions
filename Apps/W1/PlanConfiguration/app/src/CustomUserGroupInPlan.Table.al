// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 9048 "Custom User Group In Plan"
{
    Caption = 'User Group Plan Assignment';
    Access = Internal;
    DataPerCompany = false;
    ReplicateData = false;
    DataClassification = SystemMetadata;

    fields
    {
        field(5; Id; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(1; "Plan ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Plan ID';
        }
        field(2; "User Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'User Group Code';
            TableRelation = "User Group".Code;
        }
        field(11; "User Group Name"; Text[50])
        {
            CalcFormula = Lookup("User Group".Name Where(Code = Field("User Group Code")));
            Caption = 'User Group Name';
            FieldClass = FlowField;
        }
        field(20; "Company Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Company Name';
            TableRelation = Company;
        }
    }

    keys
    {
        key(PrimaryKey; Id)
        {
            Clustered = true;
        }

        key(UniqueKey; "Plan ID", "User Group Code", "Company Name")
        {
            Unique = true;
        }
    }

    trigger OnInsert()
    begin
        CustomUserGroupInPlan.VerifyUserHasRequiredUserGroup(Rec."User Group Code", Rec."Company Name");

        CustomUserGroupInPlan.AddPermissionSetsFromUserGroup(Rec);
    end;

    trigger OnDelete()
    begin
        CustomUserGroupInPlan.VerifyUserHasRequiredUserGroup(Rec."User Group Code", Rec."Company Name");

        CustomUserGroupInPlan.RemovePermissionSetsFromUserGroup(Rec);
    end;

    trigger OnModify()
    begin
        CustomUserGroupInPlan.VerifyUserHasRequiredUserGroup(Rec."User Group Code", Rec."Company Name");

        CustomUserGroupInPlan.RemovePermissionSetsFromUserGroup(xRec);
        CustomUserGroupInPlan.AddPermissionSetsFromUserGroup(Rec);
    end;

    trigger OnRename()
    begin
        CustomUserGroupInPlan.VerifyUserHasRequiredUserGroup(Rec."User Group Code", Rec."Company Name");

        CustomUserGroupInPlan.RemovePermissionSetsFromUserGroup(xRec);
        CustomUserGroupInPlan.AddPermissionSetsFromUserGroup(Rec);
    end;

    var
        CustomUserGroupInPlan: Codeunit "Custom User Group In Plan";
}
