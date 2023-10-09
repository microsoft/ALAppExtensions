// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// A pop-up window for creating a new security group.
/// </summary>
page 9872 "New Security Group"
{
    PageType = NavigatePage;
    Caption = 'New Security Group';
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(CreateSecurityGroup)
            {
                ShowCaption = false;
                Visible = true and true; // Need an expression here. Otherwise the group name will show up as a button on the page.

                group(Info)
                {
                    ShowCaption = false;

                    group(IntroAad)
                    {
                        ShowCaption = false;
                        InstructionalText = 'Create a new Security Group in Business Central corresponding to a Microsoft Entra security group.';
                        Visible = not IsWindowsAuthentication;
                    }
                    group(IntroWindows)
                    {
                        ShowCaption = false;
                        InstructionalText = 'Create a new Security Group in Business Central corresponding to a Windows Active Directory group.';
                        Visible = IsWindowsAuthentication;
                    }
                    field(LearnMore; LearnMoreTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Learn more about this functionality.';

                        trigger OnDrillDown()
                        begin
                            if IsWindowsAuthentication then
                                Hyperlink(LearnMoreWindowsLinkTxt)
                            else
                                Hyperlink(LearnMoreAadLinkTxt);
                        end;
                    }
                }
                field(NewAadSecurityGroupName; NewSecurityGroupNameValue)
                {
                    ApplicationArea = All;
                    Caption = 'Microsoft Entra security group name';
                    ToolTip = 'Specifies the name of the Microsoft Entra security group.';
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
                    Caption = 'Windows group name';
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
                    Caption = 'Code';
                    NotBlank = true;
                    ToolTip = 'Specifies the code of the security group.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateGroup)
            {
                ApplicationArea = All;
                Enabled = (NewSecurityGroupCodeValue <> '') and (NewSecurityGroupNameValue <> '');
                Caption = 'Create';
                ToolTip = 'Create a security group with specified values.';
                InFooterBar = true;
                Image = NextRecord;

                trigger OnAction()
                begin
                    SecurityGroup.Create(NewSecurityGroupCodeValue, NewSecurityGroupIdValue);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        User: Record User;
    begin
        if User.IsEmpty() then
            Error(NoUsersErr);

        IsWindowsAuthentication := SecurityGroup.IsWindowsAuthentication();
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
        NewSecurityGroupCodeValue: Code[20];
        NewSecurityGroupNameValue: Text;
        NewSecurityGroupIdValue: Text;
        NoUsersErr: Label 'There must be at least one user in the system before you can create a security group.';
        LearnMoreTxt: Label 'Learn more';
        LearnMoreWindowsLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2226384', Locked = true;
        LearnMoreAadLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2226617', Locked = true;
        IsWindowsAuthentication: Boolean;
}