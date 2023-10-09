// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Imports or exports a security group.
/// </summary>
xmlport 9001 "Export/Import Security Groups"
{
    Caption = 'Export/Import Security Groups';
    UseRequestPage = false;
    Permissions = tabledata "Security Group" = r;

    schema
    {
        textelement(SecurityGroups)
        {
            tableelement("Security Group"; "Security Group")
            {
                XmlName = 'SecurityGroup';
                AutoSave = false;

                fieldelement(Code; "Security Group".Code)
                {
                }
                textelement(GroupID)
                {
                    trigger OnBeforePassVariable()
                    begin
                        GroupID := SecurityGroup.GetId("Security Group".Code);
                    end;

                    trigger OnAfterAssignVariable()
                    begin
                        SecurityGroup.ValidateGroupId(GroupID);
                    end;
                }

                tableelement("Access Control"; "Access Control")
                {
                    LinkFields = "User Security ID" = field("Group User SID");
                    LinkTable = "Security Group";
                    MinOccurs = Zero;
                    XmlName = 'AccessControl';
                    SourceTableView = sorting("Role ID", "App ID") order(ascending);

                    fieldelement(RoleId; "Access Control"."Role ID")
                    {
                        FieldValidate = no;
                    }
                    fieldelement(Scope; "Access Control".Scope)
                    {
                    }
                    fieldelement(AppID; "Access Control"."App ID")
                    {
                    }
                    fieldelement(CompanyName; "Access Control"."Company Name")
                    {
                        FieldValidate = no;
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        "Access Control"."User Security ID" := SecurityGroup.GetGroupUserSecurityId("Security Group".Code)
                    end;

                    trigger OnAfterInsertRecord()
                    begin
                        NoOfSecurityGroupPermissionSetsInserted += 1;
                    end;
                }

                trigger OnBeforeInsertRecord()
                begin
                    IsImport := true;
                    SecurityGroup.Create("Security Group".Code, GroupID);
                end;

                trigger OnAfterInsertRecord()
                begin
                    NoOfSecurityGroupsInserted += 1;
                end;
            }
        }
    }

    trigger OnPostXmlPort()
    begin
        if GuiAllowed() then
            if IsImport then
                Message(InsertedMsg, NoOfSecurityGroupsInserted, NoOfSecurityGroupPermissionSetsInserted);
    end;

    var
        SecurityGroup: Codeunit "Security Group";
        IsImport: Boolean;
        NoOfSecurityGroupsInserted: Integer;
        NoOfSecurityGroupPermissionSetsInserted: Integer;
        InsertedMsg: Label '%1 security groups with a total of %2 permission sets were inserted.', Comment = '%1 and %2 are numbers/quantities.';
}

