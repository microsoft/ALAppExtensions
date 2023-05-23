// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Copies a security group.
/// </summary>
page 9873 "Copy Security Group"
{
    Caption = 'Copy Security Group';
    PageType = NavigatePage;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(Intro)
            {
                ShowCaption = false;
                InstructionalText = 'Copy the permissions from an existing Security Group to a new one.';
            }
            field(SourceSecurityGroupCode; SourceSecurityGroupCode)
            {
                ApplicationArea = All;
                Caption = 'Copy from';
                ToolTip = 'Specifies the code the security group to copy the permissions from.';
                Editable = false;
            }
            field(NewAadSecurityGroupName; NewSecurityGroupNameValue)
            {
                ApplicationArea = All;
                Caption = 'New AAD security group name';
                ToolTip = 'Specifies the name of the AAD security group.';
                NotBlank = true;
                Visible = not IsWindowsAuthentication;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    LookupAvailableGroups();
                end;

                trigger OnValidate()
                begin
                    ValidateGroupName();
                end;
            }
            field(NewWindowsSecurityGroupName; NewSecurityGroupNameValue)
            {
                ApplicationArea = All;
                Caption = 'New Windows group name';
                ToolTip = 'Specifies the name of the Windows group.';
                NotBlank = true;
                Visible = IsWindowsAuthentication;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    LookupAvailableGroups();
                end;

                trigger OnValidate()
                begin
                    ValidateGroupName();
                end;
            }
            field(NewSecurityGroupCode; NewSecurityGroupCodeValue)
            {
                ApplicationArea = All;
                Caption = 'New Code';
                NotBlank = true;
                ToolTip = 'Specifies the code of the new security group.';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CopyGroup)
            {
                ApplicationArea = All;
                Enabled = (NewSecurityGroupCodeValue <> '') and (NewSecurityGroupNameValue <> '');
                Caption = 'Copy';
                ToolTip = 'Copy the security group.';
                InFooterBar = true;
                Image = NextRecord;

                trigger OnAction()
                begin
                    SecurityGroup.Copy(SourceSecurityGroupCode, NewSecurityGroupCodeValue, NewSecurityGroupIdValue);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsWindowsAuthentication := SecurityGroup.IsWindowsAuthentication();
    end;

    procedure SetSourceGroupCode(SourceGroupCode: Code[20])
    begin
        SourceSecurityGroupCode := SourceGroupCode;
    end;

    local procedure LookupAvailableGroups()
    var
        SecurityGroupImpl: Codeunit "Security Group Impl.";
        SecurityGroupLookup: Page "Security Group Lookup";
    begin
        SecurityGroupLookup.LookupMode(true);
        if SecurityGroupLookup.RunModal() = Action::LookupOK then begin
            SecurityGroupLookup.GetRecord(SelectedSecurityGroup);
            NewSecurityGroupNameValue := SelectedSecurityGroup."Group Name";
            NewSecurityGroupIdValue := SelectedSecurityGroup."Group ID";
            NewSecurityGroupCodeValue := SecurityGroupImpl.GetDesirableCode(NewSecurityGroupNameValue);
        end;
    end;

    local procedure ValidateGroupName()
    var
        SecurityGroupImpl: Codeunit "Security Group Impl.";
    begin
        if (NewSecurityGroupNameValue = SelectedSecurityGroup."Group Name") and (NewSecurityGroupIdValue = SelectedSecurityGroup."Group ID") then
            exit; // no need to validate values from the lookup

        NewSecurityGroupIdValue := SecurityGroup.GetIdByName(NewSecurityGroupNameValue);
        SecurityGroup.ValidateGroupId(NewSecurityGroupIdValue);
        NewSecurityGroupCodeValue := SecurityGroupImpl.GetDesirableCode(NewSecurityGroupNameValue);
    end;

    var
        SelectedSecurityGroup: Record "Security Group Buffer";
        SecurityGroup: Codeunit "Security Group";
        SourceSecurityGroupCode: Code[20];
        NewSecurityGroupCodeValue: Code[20];
        NewSecurityGroupNameValue: Text;
        NewSecurityGroupIdValue: Text;
        IsWindowsAuthentication: Boolean;
}
