// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Security.AccessControl;

using System.TestLibraries.Environment;
using System.TestLibraries.Azure.ActiveDirectory;
using System.TestLibraries.Security.AccessControl;
using System.TestLibraries.Mocking;
using System.Security.AccessControl;
using System;
using System.Utilities;
using System.TestLibraries.Utilities;

codeunit 135016 "Security Groups Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        AzureADGraphTestLibrary: Codeunit "Azure AD Graph Test Library";
        SecurityGroupsTestLibrary: Codeunit "Security Groups Test Library";
        MockGraphQueryTestLibrary: Codeunit "MockGraphQuery Test Library";
        TestSecurityGroupCodeTxt: Label 'TEST_SG';
        TestRoleIdTxt: Label 'TEST_PS';
        TestCompanyNameTxt: Label 'TestCompany';
        TestSecurityGroupIdTxt: Label 'security group test ID';
        TestSecurityGroupNameTxt: Label 'Test AAD group';
        InvalidAadGroupErr: Label 'The group ID %1 does not correspond to a valid Microsoft Entra group.', Comment = '%1 = Microsoft Entra security group ID';
        InsertedMsg: Label '%1 security groups with a total of %2 permission sets were inserted.', Comment = '%1 and %2 are numbers/quantities.';
        ExpectedTheSameValueErr: Label 'Expected the values to be the same';
        Scope: Option System,Tenant;
        NullAppId: Guid;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestValidateGroupIdYes()
    var
        SecurityGroup: Codeunit "Security Group";
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [WHEN] The group ID is validated
        SecurityGroup.ValidateGroupId(TestSecurityGroupIdTxt);

        // [THEN] No error occurs

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestValidateGroupIdNo()
    var
        SecurityGroup: Codeunit "Security Group";
    begin
        Initialize();

        // [WHEN] A non-existent group ID is validated
        // [THEN] A validation error occurs
        asserterror SecurityGroup.ValidateGroupId(TestSecurityGroupIdTxt);

        Assert.ExpectedError(StrSubstNo(InvalidAadGroupErr, TestSecurityGroupIdTxt));

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetIdByName()
    var
        SecurityGroupTestLibrary: Codeunit "Security Groups Test Library";
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [WHEN] GetId is called
        // [THEN] The returned ID is as expected
        Assert.AreEqual(TestSecurityGroupIdTxt, SecurityGroupTestLibrary.GetIdByName(TestSecurityGroupNameTxt), 'Expected the ID to be the same.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetId()
    var
        SecurityGroup: Codeunit "Security Group";
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [GIVEN] A BC security group is created
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);

        // [WHEN] GetId is called
        // [THEN] The returned ID is as expected
        Assert.AreEqual(TestSecurityGroupIdTxt, SecurityGroup.GetId(TestSecurityGroupCodeTxt), 'Expected the ID to be the same.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetName()
    var
        SecurityGroup: Codeunit "Security Group";
        GroupName: Text[250];
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [GIVEN] A BC security group is created
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);

        // [WHEN] GetName is called
        // [THEN] The returned name is as expected
        Assert.IsTrue(SecurityGroup.GetName(TestSecurityGroupCodeTxt, GroupName), 'Expected GetName to succeed.');
        Assert.AreEqual(TestSecurityGroupNameTxt, GroupName, 'Expected the name to be the same.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetGroups()
    var
        SecurityGroupBuffer: Record "Security Group Buffer";
        SecurityGroup: Codeunit "Security Group";
        Sg1CodeTxt: Label 'SG1';
        Sg2CodeTxt: Label 'SG2';
        Sg3CodeTxt: Label 'SG3';
        Sg1IdTxt: Label 'AAD SG1 ID';
        Sg2IdTxt: Label 'AAD SG2 ID';
        Sg3IdTxt: Label 'AAD SG3 ID';
        Sg1NameTxt: Label 'AAD SG1 Name';
        Sg2NameTxt: Label 'AAD SG2 Name';
        Sg3NameTxt: Label 'AAD SG3 Name';
    begin
        Initialize();

        // [GIVEN] 3 AAD security group exist
        MockGraphQueryTestLibrary.AddGroup(Sg1NameTxt, Sg1IdTxt);
        MockGraphQueryTestLibrary.AddGroup(Sg2NameTxt, Sg2IdTxt);
        MockGraphQueryTestLibrary.AddGroup(Sg3NameTxt, Sg3IdTxt);

        // [WHEN] A BC security group is created for each of them
        SecurityGroup.Create(Sg1CodeTxt, Sg1IdTxt);
        SecurityGroup.Create(Sg2CodeTxt, Sg2IdTxt);
        SecurityGroup.Create(Sg3CodeTxt, Sg3IdTxt);

        // [THEN] GetGroups returns expected results
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        Assert.RecordCount(SecurityGroupBuffer, 3);

        SecurityGroupBuffer.FindSet();
        Assert.AreEqual(Sg1CodeTxt, SecurityGroupBuffer.Code, ExpectedTheSameValueErr);
        Assert.AreEqual(Sg1IdTxt, SecurityGroupBuffer."Group ID", ExpectedTheSameValueErr);
        Assert.AreEqual(Sg1NameTxt, SecurityGroupBuffer."Group Name", ExpectedTheSameValueErr);

        SecurityGroupBuffer.Next();
        Assert.AreEqual(Sg2CodeTxt, SecurityGroupBuffer.Code, ExpectedTheSameValueErr);
        Assert.AreEqual(Sg2IdTxt, SecurityGroupBuffer."Group ID", ExpectedTheSameValueErr);
        Assert.AreEqual(Sg2NameTxt, SecurityGroupBuffer."Group Name", ExpectedTheSameValueErr);

        SecurityGroupBuffer.Next();
        Assert.AreEqual(Sg3CodeTxt, SecurityGroupBuffer.Code, ExpectedTheSameValueErr);
        Assert.AreEqual(Sg3IdTxt, SecurityGroupBuffer."Group ID", ExpectedTheSameValueErr);
        Assert.AreEqual(Sg3NameTxt, SecurityGroupBuffer."Group Name", ExpectedTheSameValueErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetGroupMembers()
    var
        User: Record User;
        SecurityGroupMemberBuffer: Record "Security Group Member Buffer";
        SecurityGroup: Codeunit "Security Group";
        NavUserAccountHelper: DotNet NavUserAccountHelper;
        GraphUser1: DotNet UserInfo;
        GraphUser2: DotNet UserInfo;
        GraphUser3: DotNet UserInfo;
        User1SecId: Guid;
        User2SecId: Guid;
        User3SecId: Guid;
        Sg1CodeTxt: Label 'SG1';
        Sg2CodeTxt: Label 'SG2';
        Sg3CodeTxt: Label 'SG3';
        Sg1IdTxt: Label 'AAD SG1 ID';
        Sg2IdTxt: Label 'AAD SG2 ID';
        Sg3IdTxt: Label 'AAD SG3 ID';
        Sg1NameTxt: Label 'AAD SG1 Name';
        Sg2NameTxt: Label 'AAD SG2 Name';
        Sg3NameTxt: Label 'AAD SG3 Name';
    begin
        // [SCENARIO] SG1 has 2 members, SG2 has 1 member and SG3 has no members

        Initialize();

        // [GIVEN] 3 AAD security group exist
        MockGraphQueryTestLibrary.AddGroup(Sg1NameTxt, Sg1IdTxt);
        MockGraphQueryTestLibrary.AddGroup(Sg2NameTxt, Sg2IdTxt);
        MockGraphQueryTestLibrary.AddGroup(Sg3NameTxt, Sg3IdTxt);

        // [GIVEN] A BC security group is created for each of them
        SecurityGroup.Create(Sg1CodeTxt, Sg1IdTxt);
        SecurityGroup.Create(Sg2CodeTxt, Sg2IdTxt);
        SecurityGroup.Create(Sg3CodeTxt, Sg3IdTxt);

        // [GIVEN] No users are group members
        // [THEN] GetMembers returns an empty list
        SecurityGroup.GetMembers(SecurityGroupMemberBuffer);
        Assert.RecordIsEmpty(SecurityGroupMemberBuffer);

        // [WHEN] Users are added to groups in M365

        // Create users in M365 and BC
        User1SecId := '121f65a7-146c-48a7-9d36-e68cea8965bb'; // making sure User1SecId goes before User2SecId in sorting order
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUser1, CreateGuid(), '', '', '');
        User."User Security ID" := User1SecId;
        User."User Name" := Format(User1SecId);
        User.Insert();
        NavUserAccountHelper.SetAuthenticationObjectId(User1SecId, GraphUser1.ObjectId);

        User2SecId := 'F21f65a7-146c-48a7-9d36-e68cea8965bb';
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUser2, CreateGuid(), '', '', '');
        User."User Security ID" := User2SecId;
        User."User Name" := Format(User2SecId);
        User.Insert();
        NavUserAccountHelper.SetAuthenticationObjectId(User2SecId, GraphUser2.ObjectId);

        User3SecId := CreateGuid();
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUser3, CreateGuid(), '', '', '');
        User."User Security ID" := User3SecId;
        User."User Name" := Format(User3SecId);
        User.Insert();
        NavUserAccountHelper.SetAuthenticationObjectId(User3SecId, GraphUser3.ObjectId);

        // Add users to groups in M365
        MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUser1, Sg1NameTxt, Sg1IdTxt);
        MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUser2, Sg1NameTxt, Sg1IdTxt);
        MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUser3, Sg2NameTxt, Sg2IdTxt);

        // [THEN] GetMembers returns expected results
        SecurityGroup.GetMembers(SecurityGroupMemberBuffer);
        Assert.RecordCount(SecurityGroupMemberBuffer, 3);

        SecurityGroupMemberBuffer.FindSet();
        Assert.AreEqual(Sg1CodeTxt, SecurityGroupMemberBuffer."Security Group Code", ExpectedTheSameValueErr);
        Assert.AreEqual(User1SecId, SecurityGroupMemberBuffer."User Security ID", ExpectedTheSameValueErr);
        Assert.AreEqual(Sg1NameTxt, SecurityGroupMemberBuffer."Security Group Name", ExpectedTheSameValueErr);

        SecurityGroupMemberBuffer.Next();
        Assert.AreEqual(Sg1CodeTxt, SecurityGroupMemberBuffer."Security Group Code", ExpectedTheSameValueErr);
        Assert.AreEqual(User2SecId, SecurityGroupMemberBuffer."User Security ID", ExpectedTheSameValueErr);
        Assert.AreEqual(Sg1NameTxt, SecurityGroupMemberBuffer."Security Group Name", ExpectedTheSameValueErr);

        SecurityGroupMemberBuffer.Next();
        Assert.AreEqual(Sg2CodeTxt, SecurityGroupMemberBuffer."Security Group Code", ExpectedTheSameValueErr);
        Assert.AreEqual(User3SecId, SecurityGroupMemberBuffer."User Security ID", ExpectedTheSameValueErr);
        Assert.AreEqual(Sg2NameTxt, SecurityGroupMemberBuffer."Security Group Name", ExpectedTheSameValueErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCreateSecurityGroup()
    var
        SecurityGroupBuffer: Record "Security Group Buffer";
        SecurityGroupTemplateUser: Record User;
        SecurityGroupUserProperty: Record "User Property";
        SecurityGroup: Codeunit "Security Group";
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [WHEN] A BC security group is created
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);

        // [THEN] Records in the appropriate tables are as expected
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        Assert.RecordCount(SecurityGroupBuffer, 1);

        SecurityGroupTemplateUser.SetRange("User Security ID", SecurityGroupBuffer."Group User SID");
        Assert.RecordIsNotEmpty(SecurityGroupTemplateUser);

        SecurityGroupUserProperty.SetRange("User Security ID", SecurityGroupBuffer."Group User SID");
        Assert.RecordIsNotEmpty(SecurityGroupUserProperty);
        SecurityGroupUserProperty.FindFirst();
        Assert.AreEqual(TestSecurityGroupIdTxt, SecurityGroupUserProperty."Authentication Object ID", 'Expected the user property to contain the AAD group ID.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetGroupUserSecurityId()
    var
        SecurityGroupBuffer: Record "Security Group Buffer";
        SecurityGroup: Codeunit "Security Group";
        SecurityGroupUserTemplateId: Guid;
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [GIVEN] A BC security group is created
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);

        // [WHEN] GetGroupUserSecurityId is called
        SecurityGroupUserTemplateId := SecurityGroup.GetGroupUserSecurityId(TestSecurityGroupCodeTxt);

        // [THEN] The user security ID of the template user for the security group is as expected
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        Assert.AreEqual(SecurityGroupBuffer."Group User SID", SecurityGroupUserTemplateId, 'Unexpected user security ID for the AAD group user.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestAddPermissionSetToSecurityGroup()
    var
        AccessControl: Record "Access Control";
        SecurityGroup: Codeunit "Security Group";
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [GIVEN] A BC security group is created
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);

        // [WHEN] A permission set is added to the security group
        SecurityGroup.AddPermissionSet(TestSecurityGroupCodeTxt, TestRoleIdTxt, TestCompanyNameTxt, Scope::Tenant, NullAppId);

        // [THEN] The permission set is added to access control for the user corresponding to the security group
        AccessControl.SetRange("User Security ID", SecurityGroup.GetGroupUserSecurityId(TestSecurityGroupCodeTxt));
        Assert.RecordCount(AccessControl, 1);
        AccessControl.FindFirst();
        Assert.AreEqual(TestRoleIdTxt, AccessControl."Role ID", 'Unexpected role ID was added.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestRemovePermissionSetFromSecurityGroup()
    var
        AccessControl: Record "Access Control";
        SecurityGroup: Codeunit "Security Group";
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [GIVEN] A BC security group is created
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);

        // [GIVEN] A permission set is added to the security group
        SecurityGroup.AddPermissionSet(TestSecurityGroupCodeTxt, TestRoleIdTxt, TestCompanyNameTxt, Scope::Tenant, NullAppId);

        // [WHEN] The same permission set is removed
        SecurityGroup.RemovePermissionSet(TestSecurityGroupCodeTxt, TestRoleIdTxt, TestCompanyNameTxt, Scope::Tenant, NullAppId);

        // [THEN] There is no record for this permission set in Access Control
        AccessControl.SetRange("User Security ID", SecurityGroup.GetGroupUserSecurityId(TestSecurityGroupCodeTxt));
        Assert.RecordIsEmpty(AccessControl);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestDeleteSecurityGroup()
    var
        SecurityGroupBuffer: Record "Security Group Buffer";
        SecurityGroupUser: Record User;
        SecurityGroupUserProperty: Record "User Property";
        AccessControl: Record "Access Control";
        SecurityGroup: Codeunit "Security Group";
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [GIVEN] A security group is created
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);

        SecurityGroupUser.SetRange("User Security ID", SecurityGroup.GetGroupUserSecurityId(TestSecurityGroupCodeTxt));
        SecurityGroupUserProperty.SetRange("User Security ID", SecurityGroup.GetGroupUserSecurityId(TestSecurityGroupCodeTxt));
        AccessControl.SetRange("User Security ID", SecurityGroup.GetGroupUserSecurityId(TestSecurityGroupCodeTxt));

        // [GIVEN] A permission set is added to the security group
        SecurityGroup.AddPermissionSet(TestSecurityGroupCodeTxt, TestRoleIdTxt, TestCompanyNameTxt, Scope::Tenant, NullAppId);

        // [WHEN] The security group is deleted
        SecurityGroup.Delete(TestSecurityGroupCodeTxt);

        // [THEN] There are no traces of the security group in the relevant tables
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        Assert.RecordIsEmpty(SecurityGroupBuffer);

        Assert.RecordIsEmpty(SecurityGroupUser);
        Assert.RecordIsEmpty(SecurityGroupUserProperty);
        Assert.RecordIsEmpty(AccessControl);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CopySecurityGroupHandler')]
    procedure TestCopy()
    var
        AccessControl: Record "Access Control";
        SecurityGroupBuffer: Record "Security Group Buffer";
        SecurityGroup: Codeunit "Security Group";
        CopySecurityGroup: Page "Copy Security Group";
        DestinationSgIdTxt: Label 'AAD SG2 ID';
        DestinationSgNameTxt: Label 'AAD SG2 Name';
    begin
        Initialize();

        // [GIVEN] A source and a destination AAD security groups exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);
        MockGraphQueryTestLibrary.AddGroup(DestinationSgNameTxt, DestinationSgIdTxt);

        // [GIVEN] A source security group is created
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);

        // [GIVEN] A permission set is added to the security group
        SecurityGroup.AddPermissionSet(TestSecurityGroupCodeTxt, TestRoleIdTxt, TestCompanyNameTxt, Scope::Tenant, NullAppId);

        // [WHEN] The source security group is copied
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        CopySecurityGroup.SetSourceGroupCode(SecurityGroupBuffer.Code);
        CopySecurityGroup.RunModal();
        // Set the required values on the request page: new security group code and name inside CopySecurityGroupHandler

        // [THEN] The source group has been copied successfully
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        Assert.RecordCount(SecurityGroupBuffer, 2);

        SecurityGroupBuffer.Get('SG2');
        Assert.AreEqual(DestinationSgIdTxt, SecurityGroupBuffer."Group ID", ExpectedTheSameValueErr);
        Assert.AreEqual(DestinationSgNameTxt, SecurityGroupBuffer."Group Name", ExpectedTheSameValueErr);
        Assert.AreNotEqual(SecurityGroup.GetGroupUserSecurityId(TestSecurityGroupCodeTxt), SecurityGroupBuffer."Group User SID", 'Expected a new group user security ID for the copied group.');

        AccessControl.SetRange("User Security ID", SecurityGroupBuffer."Group User SID");
        Assert.RecordCount(AccessControl, 1);
        AccessControl.FindFirst();
        Assert.AreEqual(TestRoleIdTxt, AccessControl."Role ID", ExpectedTheSameValueErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCopyPermissions()
    var
        AccessControl: Record "Access Control";
        SecurityGroup: Codeunit "Security Group";
        DestinationSgCodeTxt: Label 'SG2';
        DestinationSgIdTxt: Label 'AAD SG2 ID';
        DestinationSgNameTxt: Label 'AAD SG2 Name';
    begin
        Initialize();

        // [GIVEN] A source and a destination AAD security groups exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);
        MockGraphQueryTestLibrary.AddGroup(DestinationSgNameTxt, DestinationSgIdTxt);

        // [GIVEN] A source and destination security groups are created
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);
        SecurityGroup.Create(DestinationSgCodeTxt, DestinationSgIdTxt);

        // [GIVEN] A permission set is added to the security group
        SecurityGroup.AddPermissionSet(TestSecurityGroupCodeTxt, TestRoleIdTxt, TestCompanyNameTxt, Scope::Tenant, NullAppId);

        // [WHEN] The permissions from the first security group are copied to the destination security group
        SecurityGroup.CopyPermissions(TestSecurityGroupCodeTxt, DestinationSgCodeTxt);

        // [THEN] The permissions have been copied successfully
        AccessControl.SetRange("User Security ID", SecurityGroup.GetGroupUserSecurityId(DestinationSgCodeTxt));
        Assert.RecordCount(AccessControl, 1);
        AccessControl.FindFirst();
        Assert.AreEqual(TestRoleIdTxt, AccessControl."Role ID", ExpectedTheSameValueErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCreateWithOrphanedSecurityGroups()
    var
        SecurityGroupBuffer: Record "Security Group Buffer";
        SecurityGroupUser: Record User;
        SecurityGroup: Codeunit "Security Group";
        NavUserAccountHelper: DotNet NavUserAccountHelper;
    begin
        Initialize();

        // [GIVEN] An AAD security group exists
        MockGraphQueryTestLibrary.AddGroup(TestSecurityGroupNameTxt, TestSecurityGroupIdTxt);

        // [GIVEN] There is an orphaned record in the User table (this can happen, because changes to the user table are not correctly rolled back on errors)
        SecurityGroupUser."User Security ID" := CreateGuid();
        SecurityGroupUser."User Name" := CopyStr('AAD Group: ' + TestSecurityGroupNameTxt, 1, MaxStrLen(SecurityGroupUser."User Name"));
        SecurityGroupUser."License Type" := SecurityGroupUser."License Type"::"AAD Group";
        SecurityGroupUser.Insert();

        NavUserAccountHelper.SetAuthenticationObjectId(SecurityGroupUser."User Security ID", TestSecurityGroupIdTxt);

        // [WHEN] A BC security group that corresponds to the orphaned user is created
        // [THEN] No error happens
        SecurityGroup.Create(TestSecurityGroupCodeTxt, TestSecurityGroupIdTxt);

        // [THEN] There is one properly defined security group in the system
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        Assert.RecordCount(SecurityGroupBuffer, 1);

        TearDown();
    end;

    [ModalPageHandler]
    procedure CopySecurityGroupHandler(var CopySecurityGroup: TestPage "Copy Security Group")
    begin
        CopySecurityGroup.NewAadSecurityGroupName.SetValue('AAD SG2 Name');
        CopySecurityGroup.NewSecurityGroupCode.SetValue('SG2');
        CopySecurityGroup.CopyGroup.Invoke();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestExport()
    var
        SecurityGroup: Codeunit "Security Group";
        TempBlob: Codeunit "Temp Blob";
        DestinationOutStream: OutStream;
        GroupCodes: List of [Code[20]];
        Sg1CodeTxt: Label 'SG1';
        Sg2CodeTxt: Label 'SG2';
        Sg3CodeTxt: Label 'SG3';
        Sg1IdTxt: Label 'AAD SG1 ID';
        Sg2IdTxt: Label 'AAD SG2 ID';
        Sg3IdTxt: Label 'AAD SG3 ID';
        Sg1NameTxt: Label 'AAD SG1 Name';
        Sg2NameTxt: Label 'AAD SG2 Name';
        Sg3NameTxt: Label 'AAD SG3 Name';
        RoleId1Txt: Label 'PS1';
        RoleId2Txt: Label 'PS2';
        RoleId3Txt: Label 'PS3';
    begin
        // [SCENARIO] Exporting multiple security groups. SG1 has 2 permission sets, SG2 has 1 permission set and SG3 has none.
        Initialize();

        // [GIVEN] 3 AAD security group exist
        MockGraphQueryTestLibrary.AddGroup(Sg1NameTxt, Sg1IdTxt);
        MockGraphQueryTestLibrary.AddGroup(Sg2NameTxt, Sg2IdTxt);
        MockGraphQueryTestLibrary.AddGroup(Sg3NameTxt, Sg3IdTxt);

        // [GIVEN] A BC security group is created for each of them
        SecurityGroup.Create(Sg1CodeTxt, Sg1IdTxt);
        SecurityGroup.Create(Sg2CodeTxt, Sg2IdTxt);
        SecurityGroup.Create(Sg3CodeTxt, Sg3IdTxt);

        // [GIVEN] Permission sets are assigned to the security groups
        SecurityGroup.AddPermissionSet(Sg1CodeTxt, RoleId1Txt, TestCompanyNameTxt, Scope::Tenant, NullAppId);
        SecurityGroup.AddPermissionSet(Sg1CodeTxt, RoleId2Txt, TestCompanyNameTxt, Scope::Tenant, NullAppId);
        SecurityGroup.AddPermissionSet(Sg2CodeTxt, RoleId3Txt, TestCompanyNameTxt, Scope::Tenant, NullAppId);

        // [WHEN] The all 3 security groups are exported
        GroupCodes.Add(Sg1CodeTxt);
        GroupCodes.Add(Sg2CodeTxt);
        GroupCodes.Add(Sg3CodeTxt);
        TempBlob.CreateOutStream(DestinationOutStream);

        SecurityGroup.Export(GroupCodes, DestinationOutStream);

        // [THEN] The exported content is as expected
        Assert.AreEqual(GetTestSecurityGroupsXmlContent(), GetXmlBlobContent(TempBlob), 'Unexpected content in the exported XML.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure TestImport()
    var
        TenantPermissionSet: Record "Tenant Permission Set";
        AccessControl: Record "Access Control";
        SecurityGroupBuffer: Record "Security Group Buffer";
        SecurityGroup: Codeunit "Security Group";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        Sg1CodeTxt: Label 'SG1';
        Sg2CodeTxt: Label 'SG2';
        Sg3CodeTxt: Label 'SG3';
        Sg1IdTxt: Label 'AAD SG1 ID';
        Sg2IdTxt: Label 'AAD SG2 ID';
        Sg3IdTxt: Label 'AAD SG3 ID';
        Sg1NameTxt: Label 'AAD SG1 Name';
        Sg2NameTxt: Label 'AAD SG2 Name';
        Sg3NameTxt: Label 'AAD SG3 Name';
        RoleId1Txt: Label 'PS1';
        RoleId2Txt: Label 'PS2';
        RoleId3Txt: Label 'PS3';
    begin
        // [SCENARIO] Importing the groups exported in the TestExport produces the same setup. SG1 has 2 permission sets, SG2 has 1 permission set and SG3 has none.
        Initialize();

        // [GIVEN] 3 AAD security group exist
        MockGraphQueryTestLibrary.AddGroup(Sg1NameTxt, Sg1IdTxt);
        MockGraphQueryTestLibrary.AddGroup(Sg2NameTxt, Sg2IdTxt);
        MockGraphQueryTestLibrary.AddGroup(Sg3NameTxt, Sg3IdTxt);

        TenantPermissionSet."App ID" := NullAppId;
        TenantPermissionSet."Role ID" := RoleId1Txt;
        TenantPermissionSet.Insert();
        TenantPermissionSet."App ID" := NullAppId;
        TenantPermissionSet."Role ID" := RoleId2Txt;
        TenantPermissionSet.Insert();
        TenantPermissionSet."App ID" := NullAppId;
        TenantPermissionSet."Role ID" := RoleId3Txt;
        TenantPermissionSet.Insert();

        // [WHEN] The security groups are imported
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF16);
        OutStr.Write(GetTestSecurityGroupsXmlContent());
        ImportBlobContent(TempBlob);

        // [THEN] The message confirms the groups being inserted. Verified inside MessageHandler.

        // [THEN] The imported security groups are as expected
        // Verify groups have been created
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        Assert.RecordCount(SecurityGroupBuffer, 3);

        SecurityGroupBuffer.FindSet();
        Assert.AreEqual(Sg1CodeTxt, SecurityGroupBuffer.Code, ExpectedTheSameValueErr);
        Assert.AreEqual(Sg1IdTxt, SecurityGroupBuffer."Group ID", ExpectedTheSameValueErr);
        Assert.AreEqual(Sg1NameTxt, SecurityGroupBuffer."Group Name", ExpectedTheSameValueErr);

        SecurityGroupBuffer.Next();
        Assert.AreEqual(Sg2CodeTxt, SecurityGroupBuffer.Code, ExpectedTheSameValueErr);
        Assert.AreEqual(Sg2IdTxt, SecurityGroupBuffer."Group ID", ExpectedTheSameValueErr);
        Assert.AreEqual(Sg2NameTxt, SecurityGroupBuffer."Group Name", ExpectedTheSameValueErr);

        SecurityGroupBuffer.Next();
        Assert.AreEqual(Sg3CodeTxt, SecurityGroupBuffer.Code, ExpectedTheSameValueErr);
        Assert.AreEqual(Sg3IdTxt, SecurityGroupBuffer."Group ID", ExpectedTheSameValueErr);
        Assert.AreEqual(Sg3NameTxt, SecurityGroupBuffer."Group Name", ExpectedTheSameValueErr);

        // Verify permission sets have been added
        AccessControl.SetRange("User Security ID", SecurityGroup.GetGroupUserSecurityId(Sg1CodeTxt));
        Assert.RecordCount(AccessControl, 2);

        AccessControl.FindSet();
        Assert.AreEqual(RoleId1Txt, AccessControl."Role ID", ExpectedTheSameValueErr);

        AccessControl.Next();
        Assert.AreEqual(RoleId2Txt, AccessControl."Role ID", ExpectedTheSameValueErr);

        AccessControl.SetRange("User Security ID", SecurityGroup.GetGroupUserSecurityId(Sg2CodeTxt));
        Assert.RecordCount(AccessControl, 1);

        AccessControl.FindFirst();
        Assert.AreEqual(RoleId3Txt, AccessControl."Role ID", ExpectedTheSameValueErr);

        AccessControl.SetRange("User Security ID", SecurityGroup.GetGroupUserSecurityId(Sg3CodeTxt));
        Assert.RecordIsEmpty(AccessControl);

        TearDown();
    end;

    [MessageHandler]
    internal procedure MessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(StrSubstNo(InsertedMsg, 3, 3), Message, 'Unexpected message after importing security groups.')
    end;

    local procedure ImportBlobContent(var TempBlob: Codeunit "Temp Blob")
    var
        SecurityGroup: Codeunit "Security Group";
        MemoryStreamOriginal: DotNet MemoryStream;
        MemoryStreamWithoutNull: DotNet MemoryStream;
        InputArray: DotNet Array;
    begin
        // Importing the stream normally will fail with "hexadecimal value 0x00, is an invalid character".
        // Remove the 0x00 byte at the end of the stream to make sure importing is successful.
        MemoryStreamOriginal := MemoryStreamOriginal.MemoryStream();
        CopyStream(MemoryStreamOriginal, TempBlob.CreateInStream(TextEncoding::UTF16));
        InputArray := MemoryStreamOriginal.ToArray();

        MemoryStreamWithoutNull := MemoryStreamWithoutNull.MemoryStream();
        MemoryStreamWithoutNull.Write(InputArray, 0, InputArray.Length - 1);
        SecurityGroup.Import(MemoryStreamWithoutNull);
    end;

    local procedure GetXmlBlobContent(var TempBlob: Codeunit "Temp Blob"): Text
    var
        InStr: InStream;
        XmlContentTextBuilder: TextBuilder;
        XmlContentLine: Text;
    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF16);
        while not InStr.EOS() do begin
            InStr.Read(XmlContentLine);
            XmlContentTextBuilder.Append(XmlContentLine)
        end;
        exit(XmlContentTextBuilder.ToText());
    end;

    local procedure GetTestSecurityGroupsXmlContent(): Text
    var
        TB: TextBuilder;
    begin
        TB.AppendLine('<?xml version="1.0" encoding="UTF-16" standalone="no"?>');
        TB.AppendLine('<SecurityGroups>');
        TB.AppendLine('  <SecurityGroup>');
        TB.AppendLine('    <Code>SG1</Code>');
        TB.AppendLine('    <GroupID>AAD SG1 ID</GroupID>');
        TB.AppendLine('    <AccessControl>');
        TB.AppendLine('      <RoleId>PS1</RoleId>');
        TB.AppendLine('      <Scope>Tenant</Scope>');
        TB.AppendLine('      <AppID>{00000000-0000-0000-0000-000000000000}</AppID>');
        TB.AppendLine('      <CompanyName>TestCompany</CompanyName>');
        TB.AppendLine('    </AccessControl>');
        TB.AppendLine('    <AccessControl>');
        TB.AppendLine('      <RoleId>PS2</RoleId>');
        TB.AppendLine('      <Scope>Tenant</Scope>');
        TB.AppendLine('      <AppID>{00000000-0000-0000-0000-000000000000}</AppID>');
        TB.AppendLine('      <CompanyName>TestCompany</CompanyName>');
        TB.AppendLine('    </AccessControl>');
        TB.AppendLine('  </SecurityGroup>');
        TB.AppendLine('  <SecurityGroup>');
        TB.AppendLine('    <Code>SG2</Code>');
        TB.AppendLine('    <GroupID>AAD SG2 ID</GroupID>');
        TB.AppendLine('    <AccessControl>');
        TB.AppendLine('      <RoleId>PS3</RoleId>');
        TB.AppendLine('      <Scope>Tenant</Scope>');
        TB.AppendLine('      <AppID>{00000000-0000-0000-0000-000000000000}</AppID>');
        TB.AppendLine('      <CompanyName>TestCompany</CompanyName>');
        TB.AppendLine('    </AccessControl>');
        TB.AppendLine('  </SecurityGroup>');
        TB.AppendLine('  <SecurityGroup>');
        TB.AppendLine('    <Code>SG3</Code>');
        TB.AppendLine('    <GroupID>AAD SG3 ID</GroupID>');
        TB.AppendLine('  </SecurityGroup>');
        TB.Append('</SecurityGroups>');
        exit(TB.ToText());
    end;

    local procedure Initialize()
    var
        User: Record User;
        UserProperty: Record "User Property";
    begin
        UserProperty.DeleteAll();
        User.DeleteAll();

        Clear(AzureADGraphTestLibrary);
        Clear(MockGraphQueryTestLibrary);

        BindSubscription(AzureADGraphTestLibrary);
        BindSubscription(SecurityGroupsTestLibrary);

        MockGraphQueryTestLibrary.SetupMockGraphQuery();
        AzureADGraphTestLibrary.SetMockGraphQuery(MockGraphQueryTestLibrary);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
    end;

    local procedure TearDown()
    begin
        UnbindSubscription(SecurityGroupsTestLibrary);
        UnbindSubscription(AzureADGraphTestLibrary);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;
}