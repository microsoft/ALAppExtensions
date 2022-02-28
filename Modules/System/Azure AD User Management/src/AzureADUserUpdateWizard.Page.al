// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Administrators can use this page to synchronize information about users from Microsoft 365 to Business Central.
/// </summary>
page 9515 "Azure AD User Update Wizard"
{
    Caption = 'Update users from Microsoft 365';
    PageType = NavigatePage;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Administration;
    SourceTable = "Azure AD User Update Buffer";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(Welcome)
            {
                Visible = WelcomeVisible;
                Caption = 'Welcome to user updates';
                group(HeaderText)
                {
                    ShowCaption = false;
                    Caption = 'Description';
                    InstructionalText = 'Bring changes to user information from your Microsoft 365 organization to Business Central. Update license assignments, name changes, email addresses, preferred languages, and user access.';
                }
                group(NoteGroup)
                {
                    Caption = 'Note:';
                    InstructionalText = 'It can take up to 72 hours for a change in Microsoft 365 to become available to Business Central.';
                }

                group(LinkToLicenseConfigurationGroup)
                {
                    Caption = 'Before you get started';
                    InstructionalText = 'You might want to configure custom permissions for each license type to speed up how you configure users.';

                    field(LinkToLicenseConfiguration; LinkToLicenseConfigurationTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Caption = ' ';
                        ToolTip = 'Configure permissions per license so you won''t have to manually configure every user.';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Plan Configuration List");
                        end;
                    }
                }
            }
            group("No Updates")
            {
                Visible = NoAvailableUpdatesVisible;
                Caption = 'No updates';
                InstructionalText = 'There are no updates from Microsoft 365. You can exit this guide.';
                ShowCaption = false;
            }
            group("Total Updates To Confirm")
            {
                Visible = TotalUpdatesToConfirmVisible;
                Caption = 'License updates to confirm';

                label(TotalUpdatesToConfirmLbl)
                {
                    ApplicationArea = All;
                    CaptionClass = TotalUpdatesToConfirm;
                    ShowCaption = false;
                }
            }
            group("Total Updates Ready To Apply")
            {
                Visible = TotalUpdatesReadyToApplyVisible;
                Caption = 'Available updates';

                label(TotalUpdatesReadyToApplyLbl)
                {
                    ApplicationArea = All;
                    CaptionClass = TotalUpdatesReadyToApply;
                    ShowCaption = false;
                }
            }
            group(ConfirmPermissionChanges)
            {
                Visible = ConfirmPermissionChangesVisible;
                Caption = 'Confirm permission changes';
                InstructionalText = 'For each update with Select in the Action column, you must either choose Keep current to disregard the updated permissions, or Append to update the user permissions.';
                group(PermissionsGroup)
                {
                    ShowCaption = false;
                    repeater(Permissions)
                    {
                        field(DisplayName; "Display Name")
                        {
                            ToolTip = 'The display name';
                            ApplicationArea = All;
                        }
                        field(CurrentLicense; "Current Value")
                        {
                            Caption = 'Current plan';
                            ToolTip = 'The current of user entity';
                            Editable = false;
                            ApplicationArea = All;
                        }
                        field(NewLicense; "New Value")
                        {
                            Caption = 'New plan';
                            ToolTip = 'The new value of user entity';
                            Editable = false;
                            ApplicationArea = All;
                        }
                        field(PermissionAction; "Permission Change Action")
                        {
                            Caption = 'Action';
                            ToolTip = 'Choose how this license change should be handled';
                            ApplicationArea = All;
                            Enabled = "Update Type" = "Update Type"::Change;

                            trigger OnValidate()
                            begin
                                SetDoneSelectingPermissionsButtonEnabled();
                            end;
                        }
                    }
                }
            }
            group(ListOfChanges)
            {
                Visible = ListOfChangesVisible;
                Caption = 'List of changes';
                InstructionalText = 'To apply the changes, choose Finish.';
                group(ChangesGroup)
                {
                    ShowCaption = false;
                    repeater(Changes)
                    {
                        field("Display Name"; "Display Name")
                        {
                            ToolTip = 'The display name';
                            ApplicationArea = All;
                        }
                        field("Authentication Object ID"; "Authentication Object ID")
                        {
                            ToolTip = 'The AAD user ID';
                            ApplicationArea = All;
                            Visible = false;
                        }
                        field("Update Type"; "Update Type")
                        {
                            ToolTip = 'The type of update';
                            ApplicationArea = All;
                        }
                        field("Information"; "Update Entity")
                        {
                            ToolTip = 'The user information that will be updated';
                            ApplicationArea = All;
                        }
                        field("Current Value"; "Current Value")
                        {
                            ToolTip = 'The current value';
                            ApplicationArea = All;
                        }
                        field("New Value"; "New Value")
                        {
                            ToolTip = 'The value to replace the user information';
                            ApplicationArea = All;
                        }
                    }
                }
            }
            group(Finished)
            {
                Visible = FinishedVisible;
                Caption = 'Good work!';
                group(NumberOfUpdatesAppliedGroup)
                {
                    Caption = 'Summary';
                    label(NumberOfUpdatesApplied)
                    {
                        ApplicationArea = All;
                        CaptionClass = NumberOfUpdatesApplied;
                        ShowCaption = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Cancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                ToolTip = 'Cancel the user updates';
                Image = Cancel;
                Visible = CancelButtonVisible;
                InFooterBar = true;

                trigger OnAction()
                var
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if ConfirmManagement.GetResponse(ConfirmCancelQst, false) then
                        CurrPage.Close();
                end;
            }
            action(Back)
            {
                ApplicationArea = All;
                Caption = 'Back';
                ToolTip = 'See overview of all the changes';
                Image = PreviousRecord;
                Visible = BackButtonVisible;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ShowOverview();
                end;
            }
            action(DoneSelectingPermissions)
            {
                ApplicationArea = All;
                Caption = 'Next';
                ToolTip = 'Proceed to applying the user updates';
                Image = NextRecord;
                Visible = DoneSelectingPermissionsButtonVisible;
                Enabled = DoneSelectingPermissionsButtonEnabled;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ShowOverview();
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                ToolTip = 'See the available updates';
                Image = NextRecord;
                Visible = NextButtonVisible;
                InFooterBar = true;

                trigger OnAction()
                var
                    AzureADUserMgtImpl: Codeunit "Azure AD User Mgmt. Impl.";
                begin
                    AzureADUserMgtImpl.FetchUpdatesFromAzureGraph(Rec);

                    ShowOverview();
                end;
            }
            action(ManagePermissionUpdates)
            {
                ApplicationArea = All;
                Caption = 'Next';
                ToolTip = 'Confirm the permission updates to be applied';
                Visible = ManagePermissionUpdatesButtonVisible;
                Image = Questionaire;
                InFooterBar = true;

                trigger OnAction()
                begin
                    MakeAllGroupsInvisible();
                    SetVisiblityOnActions();
                    BackButtonVisible := false;
                    DoneSelectingPermissionsButtonVisible := true;
                    DoneSelectingPermissionsButtonEnabled := false;
                    ManagePermissionUpdatesButtonVisible := false;
                    ConfirmPermissionChangesVisible := true;
                    SetRange("Update Entity", "Update Entity"::Plan);
                end;
            }
            action(ViewChanges)
            {
                ApplicationArea = All;
                Caption = 'View changes';
                ToolTip = 'View a list of changes that will be applied';
                Visible = ViewChangesButtonVisible;
                Image = Change;
                InFooterBar = true;

                trigger OnAction()
                begin
                    MakeAllGroupsInvisible();
                    ListOfChangesVisible := true;
                    SetVisiblityOnActions();
                    BackButtonVisible := true;
                    ViewChangesButtonVisible := false;
                    SetRange("Needs User Review", false);
                end;
            }
            action(ApplyUpdates)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                ToolTip = 'Apply the user updates';
                Visible = ApplyUpdatesButtonVisible;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                var
                    AzureADUserMgtImpl: Codeunit "Azure AD User Mgmt. Impl.";
                    GuidedExperience: Codeunit "Guided Experience";
                    SuccessCount: Integer;
                begin
                    Reset();
                    SuccessCount := AzureADUserMgtImpl.ApplyUpdatesFromAzureGraph(Rec);
                    NumberOfUpdatesApplied := StrSubstNo(NumberOfUpdatesAppliedTxt, SuccessCount, Count());
                    DeleteAll();

                    GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Azure AD User Update Wizard");

                    MakeAllGroupsInvisible();
                    FinishedVisible := true;
                    SetVisiblityOnActions();
                    ApplyUpdatesButtonVisible := false;
                    CancelButtonVisible := false;
                    CloseButtonVisible := true;
                end;
            }
            action(Close)
            {
                ApplicationArea = All;
                Caption = 'Close';
                ToolTip = 'Closes this window';
                Image = Close;
                Visible = CloseButtonVisible;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        [InDataSet]
        WelcomeVisible: Boolean;
        [InDataSet]
        ConfirmPermissionChangesVisible: Boolean;
        [InDataSet]
        ListOfChangesVisible: Boolean;
        [InDataSet]
        FinishedVisible: Boolean;

        [InDataSet]
        CancelButtonVisible: Boolean;
        [InDataSet]
        BackButtonVisible: Boolean;
        [InDataSet]
        NextButtonVisible: Boolean;
        [InDataSet]
        ManagePermissionUpdatesButtonVisible: Boolean;
        [InDataSet]
        ViewChangesButtonVisible: Boolean;
        [InDataSet]
        ApplyUpdatesButtonVisible: Boolean;
        [InDataSet]
        CloseButtonVisible: Boolean;
        [InDataSet]
        DoneSelectingPermissionsButtonVisible: Boolean;
        [InDataSet]
        DoneSelectingPermissionsButtonEnabled: Boolean;

        CountOfManagedPermissionUpdates: Integer;
        CountOfApplicableUpdates: Integer;

        ConfirmCancelQst: Label 'Are you sure you wish to cancel the updates?';
        NumberOfUpdatesApplied: Text;
        NumberOfUpdatesAppliedTxt: Label '%1 out of %2 updates have been applied in Business Central. You can close this guide.', Comment = '%1 = An integer count of total updates applied; %2 = total count of updates';

        [InDataSet]
        NoAvailableUpdatesVisible: Boolean;

        TotalUpdatesToConfirm: Text;
        [InDataSet]
        TotalUpdatesToConfirmVisible: Boolean;
        TotalUpdatesToConfirmSingularTxt: Label 'We found %1 license update for a user who has customized permissions. Before continuing, you must either keep the current permissions or add the permissions associated with the new license for the user.', Comment = '%1 = An integer count of total updates to get confirmation on';
        TotalUpdatesToConfirmPluralTxt: Label 'We found %1 license updates for users who have customized permissions. Before continuing, you must either keep the current permissions or add the permissions associated with the new license for those users.', Comment = '%1 = An integer count of total updates to get confirmation on';

        TotalUpdatesReadyToApply: Text;
        [InDataSet]
        TotalUpdatesReadyToApplyVisible: Boolean;
        TotalUpdatesReadyToApplyTxt: Label 'Number of updates ready to be applied: %1. These can be name, email address, preferred language, and user access changes. Choose View changes to see the list.', Comment = '%1 = An integer count of total updates ready to apply';

        LinkToLicenseConfigurationTxt: Label 'Configure permissions per license';
        CannotUpdateUsersFromOfficeErr: Label 'Your user account does not give you permission to fetch users from Microsoft 365. Please contact your administrator.';

    trigger OnOpenPage()
    var
        UserPermissions: Codeunit "User Permissions";
    begin
        if not UserPermissions.CanManageUsersOnTenant(UserSecurityId()) then
            error(CannotUpdateUsersFromOfficeErr);

        MakeAllGroupsInvisible();
        WelcomeVisible := true;

        SetVisiblityOnActions();
        NextButtonVisible := true;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if DoneSelectingPermissionsButtonVisible then
            SetDoneSelectingPermissionsButtonEnabled();
    end;

    local procedure SetDoneSelectingPermissionsButtonEnabled()
    var
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
    begin
        if Rec."Permission Change Action" = Rec."Permission Change Action"::Select then begin
            DoneSelectingPermissionsButtonEnabled := false;
            exit;
        end;

        TempAzureADUserUpdateBuffer.Copy(Rec, true); // share the same table
        TempAzureADUserUpdateBuffer.SetRange("Permission Change Action", TempAzureADUserUpdateBuffer."Permission Change Action"::Select);
        // exclude the current record
        TempAzureADUserUpdateBuffer.SetFilter("Authentication Object ID", '<>%1', Rec."Authentication Object ID");

        // if all of the update actions are chosen, enable the "Next" button.
        if TempAzureADUserUpdateBuffer.IsEmpty() then
            DoneSelectingPermissionsButtonEnabled := true;
    end;

    local procedure MakeAllGroupsInvisible()
    begin
        WelcomeVisible := false;
        TotalUpdatesToConfirmVisible := false;
        ConfirmPermissionChangesVisible := false;
        TotalUpdatesReadyToApplyVisible := false;
        NoAvailableUpdatesVisible := false;
        ListOfChangesVisible := false;
        FinishedVisible := false;
    end;

    local procedure ShowOverview()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        MakeAllGroupsInvisible();
        SetVisiblityOnActions();
        TotalUpdatesToConfirmVisible := CountOfManagedPermissionUpdates > 0;
        if CountOfManagedPermissionUpdates = 1 then
            TotalUpdatesToConfirm := StrSubstNo(TotalUpdatesToConfirmSingularTxt, CountOfManagedPermissionUpdates)
        else
            TotalUpdatesToConfirm := StrSubstNo(TotalUpdatesToConfirmPluralTxt, CountOfManagedPermissionUpdates);
        TotalUpdatesReadyToApplyVisible := (CountOfApplicableUpdates > 0) and (not TotalUpdatesToConfirmVisible);
        TotalUpdatesReadyToApply := StrSubstNo(TotalUpdatesReadyToApplyTxt, CountOfApplicableUpdates);
        if (not TotalUpdatesReadyToApplyVisible) and (not TotalUpdatesToConfirmVisible) then begin
            NoAvailableUpdatesVisible := true;
            GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Azure AD User Update Wizard");
        end;
    end;

    local procedure SetVisiblityOnActions()
    var
        TotalNumberOfUpdates: Integer;
    begin
        Reset();
        CancelButtonVisible := true;
        BackButtonVisible := false;
        NextButtonVisible := false;
        CloseButtonVisible := false;
        DoneSelectingPermissionsButtonVisible := false;
        TotalNumberOfUpdates := Count();

        SetRange("Needs User Review", true);
        CountOfManagedPermissionUpdates := Count();
        CountOfApplicableUpdates := TotalNumberOfUpdates - CountOfManagedPermissionUpdates;

        ApplyUpdatesButtonVisible := (CountOfManagedPermissionUpdates = 0) and (CountOfApplicableUpdates > 0);
        ManagePermissionUpdatesButtonVisible := CountOfManagedPermissionUpdates > 0;
        ViewChangesButtonVisible := (CountOfApplicableUpdates > 0) and (not ManagePermissionUpdatesButtonVisible);
        SetRange("Needs User Review");
        if CountOfApplicableUpdates + CountOfManagedPermissionUpdates = 0 then begin
            CloseButtonVisible := true;
            CancelButtonVisible := false;
        end;
    end;
}