// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The main page for interacting with security groups.
/// </summary>
page 9871 "Security Groups"
{
    AdditionalSearchTerms = 'users,permissions,access right';
    ApplicationArea = All;
    Caption = 'Security Groups';
    DataCaptionFields = "Code";
    PageType = List;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Security Group Buffer";
    SourceTableTemporary = true;
    UsageCategory = Lists;
    AboutTitle = 'About security groups';
    AboutText = 'Security groups help you manage permissions for groups of users.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;

                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the security group code.';
                }
                field(Name; Rec."Group Name")
                {
                    Caption = 'Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the security group.';
                }
            }
        }
        area(factboxes)
        {
            part("Sec. Group Permissions Part"; "Sec. Group Permissions Part")
            {
                ApplicationArea = All;
                SubPageLink = "User Security ID" = field("Group User SID");
            }
            part("Security Group Members Part"; "Security Group Members Part")
            {
                ApplicationArea = All;
                SubPageLink = "Security Group Code" = field(Code);
                Visible = CanManageUsersOnTenant;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
            systempart(MyNotes; MyNotes)
            {
                ApplicationArea = All;
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(NewSecurityGroup)
            {
                ApplicationArea = All;
                Image = Add;
                Caption = 'New';
                ToolTip = 'Add a new security group.';

                trigger OnAction()
                begin
                    Page.RunModal(Page::"New Security Group");
                    RefreshData();
                end;
            }
        }
        area(navigation)
        {
            action(SecurityGroupMembersAad)
            {
                ApplicationArea = All;
                Caption = 'Members';
                Image = Users;
                RunObject = Page "Security Group Members";
                RunPageLink = "Security Group Code" = field(Code);
                Scope = Repeater;
                Visible = not IsWindowsAuthentication;
                ToolTip = 'View the members of the security group. Editing group memberships can be done in M365 admin center or the Azure portal.';
                AboutTitle = 'Members of the group';
                AboutText = 'View the people who are in the selected security group. A user can be a member of multiple security groups at the same time. You can manage security group memberships in M365 admin center or the Azure portal.';
            }
            action(SecurityGroupMembersWindows)
            {
                ApplicationArea = All;
                Caption = 'Members';
                Image = Users;
                RunObject = Page "Security Group Members";
                RunPageLink = "Security Group Code" = field(Code);
                Scope = Repeater;
                Visible = IsWindowsAuthentication;
                ToolTip = 'View the members of the security group. Editing group memberships can be done in the ''Local Users and Groups'' section of the ''Computer Management'' tool.';
                AboutTitle = 'Members of the group';
                AboutText = 'View the people who are in the selected security group. A user can be a member of multiple security groups at the same time. You can manage security group memberships in the ''Local Users and Groups'' section of the ''Computer Management'' tool.';
            }
            action(SecurityGroupPermissionSets)
            {
                ApplicationArea = All;
                Caption = 'Permissions';
                Image = Permission;
                Scope = Repeater;
                Enabled = AreRecordsPresent;
                ToolTip = 'View or edit the permission sets that are assigned to the security group.';
                AboutTitle = 'Define permissions for the group';
                AboutText = 'Manage which permissions the members of the selected group get with their membership.';

                trigger OnAction()
                var
                    AccessControl: Record "Access Control";
                    SecurityGroupPermissionSets: Page "Security Group Permission Sets";
                begin
                    AccessControl.SetRange("User Security ID", Rec."Group User SID");
                    SecurityGroupPermissionSets.SetTableView(AccessControl);
                    SecurityGroupPermissionSets.SetGroupCode(Rec.Code);
                    SecurityGroupPermissionSets.Run();
                end;
            }
        }
        area(processing)
        {
            action(CopySecurityGroup)
            {
                ApplicationArea = All;
                Caption = 'Copy existing';
                Scope = Repeater;
                Ellipsis = true;
                Image = Copy;
                ToolTip = 'Create a copy of the current security group.';
                Enabled = AreRecordsPresent;

                trigger OnAction()
                var
                    CopySecurityGroup: Page "Copy Security Group";
                begin
                    CopySecurityGroup.SetSourceGroupCode(Rec.Code);
                    CopySecurityGroup.RunModal();
                    RefreshData();
                end;
            }
            action(ExportSecurityGroups)
            {
                ApplicationArea = All;
                Caption = 'Export Security Group';
                Image = ExportFile;
                ToolTip = 'Export the selected security groups to an XML file.';
                Enabled = AreRecordsPresent;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    OutStr: OutStream;
                    InStr: InStream;
                    ToFile: Text;
                begin
                    TempBlob.CreateOutStream(OutStr);

                    SecurityGroup.Export(GetSelectedGroupCodes(), OutStr);

                    TempBlob.CreateInStream(InStr);
                    ToFile := StrSubstNo(SecurityGroupsExportFileNameTxt, DT2Date(CurrentDateTime()));
                    DownloadFromStream(InStr, ExportTxt, '', '', ToFile);
                end;
            }
            action(ImportSecurityGroups)
            {
                ApplicationArea = All;
                Caption = 'Import Security Group';
                Image = Import;
                ToolTip = 'Import security groups from an XML file.';

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    InStr: InStream;
                    FromFile: Text;
                begin
                    TempBlob.CreateInStream(InStr);
                    if not UploadIntoStream(ImportTxt, '', '', FromFile, InStr) then
                        exit;

                    SecurityGroup.Import(InStr);
                    RefreshData();
                end;
            }
            action(Delete)
            {
                ApplicationArea = All;
                Image = Delete;
                Caption = 'Delete';
                ToolTip = 'Delete the selected security groups.';
                Scope = Repeater;
                Enabled = AreRecordsPresent;

                trigger OnAction()
                var
                    SelectedGroupCode: Code[20];
                begin
                    if not Confirm(ConfirmDeleteGroupQst) then
                        exit;

                    foreach SelectedGroupCode in GetSelectedGroupCodes() do
                        SecurityGroup.Delete(SelectedGroupCode);

                    RefreshData();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'New';
                ShowAs = SplitButton;

                actionref(NewSecurityGroup_Promoted; NewSecurityGroup)
                {
                }
                actionref(CopySecurityGroup_Promoted; CopySecurityGroup)
                {
                }
            }
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Delete_Promoted; Delete)
                {
                }
                actionref(SecurityGroupMembersAad_Promoted; SecurityGroupMembersAad)
                {
                }
                actionref(SecurityGroupMembersWindows_Promoted; SecurityGroupMembersWindows)
                {
                }
                actionref(SecurityGroupPermissionSets_Promoted; SecurityGroupPermissionSets)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        UserPermissions: Codeunit "User Permissions";
    begin
        CanManageUsersOnTenant := UserPermissions.CanManageUsersOnTenant(UserSecurityId());
        FeatureTelemetry.LogUptake('0000JGR', 'Security Groups', Enum::"Feature Uptake Status"::Discovered);
        RefreshData(false);
        IsWindowsAuthentication := SecurityGroup.IsWindowsAuthentication();
        SecurityGroup.SendNotificationForDeletedGroups(Rec);
    end;

    local procedure RefreshData()
    begin
        RefreshData(true);
    end;

    local procedure RefreshData(ShouldRefreshMembers: Boolean)
    var
        NumberOfGroupsBeforeRefresh: Integer;
    begin
        NumberOfGroupsBeforeRefresh := Rec.Count();

        SecurityGroup.GetGroups(Rec);
        AreRecordsPresent := not Rec.IsEmpty();

        if ShouldRefreshMembers then
            if Rec.Count() > NumberOfGroupsBeforeRefresh then
                CurrPage."Security Group Members Part".Page.Refresh();
    end;

    local procedure GetSelectedGroupCodes(): List of [Code[20]];
    var
        SecurityGroupBuffer: Record "Security Group Buffer";
        GroupCodes: List of [Code[20]];
    begin
        SecurityGroupBuffer.Copy(Rec, true);
        CurrPage.SetSelectionFilter(SecurityGroupBuffer);
        if SecurityGroupBuffer.FindSet() then
            repeat
                GroupCodes.Add(SecurityGroupBuffer.Code);
            until SecurityGroupBuffer.Next() = 0;
        exit(GroupCodes);
    end;

    var
        SecurityGroup: Codeunit "Security Group";
        ExportTxt: Label 'Export security groups';
        ImportTxt: Label 'Import security groups';
        ConfirmDeleteGroupQst: Label 'Security group members will lose the permissions associated with the deleted groups. Do you want to continue?';
        SecurityGroupsExportFileNameTxt: Label 'SecurityGroups_%1.xml', Locked = true;
        IsWindowsAuthentication: Boolean;
        CanManageUsersOnTenant: Boolean;

    protected var
        AreRecordsPresent: Boolean;
}

