// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Security.AccessControl;

using System.Security.AccessControl;
using System;

/// <summary>
/// Test library for the Security Groups module.
/// </summary>
codeunit 135105 "Security Groups Test Library"
{
    EventSubscriberInstance = Manual;

    procedure RunUpgrade()
    var
        SecurityGroupUpgrade: Codeunit "Security Group Upgrade";
    begin
        SecurityGroupUpgrade.CreateSecurityGroups();
    end;

    procedure GetIdByName(GroupName: Text): Text
    var
        SecurityGroup: Codeunit "Security Group";
    begin
        exit(SecurityGroup.GetIdByName(GroupName));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Security Group Impl.", 'OnBeforeCreateAadGroupUserInSaaS', '', false, false)]
    local procedure CreateTestAadGroupUser(var SecurityGroup: Record "Security Group"; GroupId: Text; GroupName: Text; var Handled: Boolean)
    var
        SecurityGroupUser: Record User;
        NavUserAccountHelper: DotNet NavUserAccountHelper;
    begin
        Handled := true;

        SecurityGroupUser."User Security ID" := CreateGuid();
        SecurityGroupUser."User Name" := CopyStr('AAD Group: ' + GroupName, 1, MaxStrLen(SecurityGroupUser."User Name"));
        SecurityGroupUser."License Type" := SecurityGroupUser."License Type"::"AAD Group";
        SecurityGroupUser.Insert();

        NavUserAccountHelper.SetAuthenticationObjectId(SecurityGroupUser."User Security ID", GroupId);
        SecurityGroup."Group User SID" := SecurityGroupUser."User Security ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Security Group Impl.", 'OnIsWindowsAuthentication', '', false, false)]
    local procedure SetWindowsAuthToFalseOnIsWindowsAuthentication(var IsWindowsAuthentication: Boolean; var Handled: Boolean)
    begin
        Handled := true;
        IsWindowsAuthentication := false;
    end;
}