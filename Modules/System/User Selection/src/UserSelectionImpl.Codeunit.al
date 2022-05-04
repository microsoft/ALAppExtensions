// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9844 "User Selection Impl."
{
    Access = Internal;
    Permissions = tabledata User = r;

    var
        UserNameDoesNotExistErr: Label 'The user name %1 does not exist.', Comment = '%1 username';

    procedure HideExternalUsers(var User: Record User)
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        User.FilterGroup(2);
        if not EnvironmentInformation.IsSaaS() then
            User.SetFilter("License Type", '<>%1', User."License Type"::Application)
        else
            User.SetFilter("License Type", '<>%1&<>%2', User."License Type"::"External User", User."License Type"::Application);
        User.FilterGroup(0);
    end;

    procedure Open(var SelectedUser: Record User): Boolean
    var
        UserLookup: Page "User Lookup";
    begin
        UserLookup.SetTableView(SelectedUser);
        UserLookup.LookupMode := true;
        if UserLookup.RunModal() = ACTION::LookupOK then begin
            UserLookup.GetSelectedUsers(SelectedUser);
            exit(true);
        end;
        exit(false);
    end;

    procedure ValidateUserName(UserName: Code[50])
    var
        User: Record User;
    begin
        if UserName = '' then
            exit;
        if User.IsEmpty() then
            exit;
        User.SetRange("User Name", UserName);
        if User.IsEmpty() then
            Error(UserNameDoesNotExistErr, UserName);
    end;
}

