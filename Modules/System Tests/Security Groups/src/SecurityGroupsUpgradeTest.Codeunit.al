// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Security.AccessControl;

using System.Security.AccessControl;
using System.TestLibraries.Security.AccessControl;
using System.TestLibraries.Utilities;

codeunit 135017 "Security Groups Upgrade Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        UnexpectedGroupCodeErr: Label 'Unexpected security group code.';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestAddExistingSecurityGroups()
    var
        SecurityGroupBuffer: Record "Security Group Buffer";
        SecurityGroup: Codeunit "Security Group";
        SecurityGroupsTestLibrary: Codeunit "Security Groups Test Library";
    begin
        // Note: this cannot be a part of upgrade tests, as it inserts user records

        // [GIVEN] Windows group users have been set up in the past
        SetupWindowsGroupUsers();

        // [WHEN] The security groups upgrade is run
        SecurityGroupsTestLibrary.RunUpgrade();

        // Security Groups have been created as expected
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        Assert.RecordCount(SecurityGroupBuffer, 3);

        SecurityGroupBuffer.FindSet();
        Assert.AreEqual(SecurityGroupBuffer.Code, 'SECURITY GROUP', UnexpectedGroupCodeErr);

        SecurityGroupBuffer.Next();
        Assert.AreEqual(SecurityGroupBuffer.Code, 'SECURITY GROUP_1', UnexpectedGroupCodeErr);

        SecurityGroupBuffer.Next();
        Assert.AreEqual(SecurityGroupBuffer.Code, 'SECURITY GROUP_2', UnexpectedGroupCodeErr);
    end;

    local procedure SetupWindowsGroupUsers()
    var
        SecurityGroupUser: Record User;
        AccessControl: Record "Access Control";
    begin
        SecurityGroupUser."License Type" := SecurityGroupUser."License Type"::"Windows Group";

        SecurityGroupUser."User Security ID" := CreateGuid();
        SecurityGroupUser."Windows Security ID" := CreateGuid();
        SecurityGroupUser."User Name" := 'Windows Group User No Permissions 1';
        SecurityGroupUser.Insert();

        SecurityGroupUser."User Security ID" := CreateGuid();
        SecurityGroupUser."Windows Security ID" := CreateGuid();
        SecurityGroupUser."User Name" := 'Windows Group User With Permissions 2';
        SecurityGroupUser.Insert();

        SecurityGroupUser."User Security ID" := CreateGuid();
        SecurityGroupUser."Windows Security ID" := CreateGuid();
        SecurityGroupUser."User Name" := 'Windows Group User With Permissions';
        SecurityGroupUser.Insert();

        AccessControl."User Security ID" := SecurityGroupUser."User Security ID";
        AccessControl."Role ID" := 'SUPER';
        AccessControl.Insert();
    end;
}