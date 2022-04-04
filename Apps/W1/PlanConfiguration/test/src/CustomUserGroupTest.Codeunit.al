// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132930 "Custom User Group Test"
{
    Subtype = Test;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        FirstCompanyTok: Label '(first company sign-in)', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure VerifyDelegatedAdminUserGroups()
    var
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        PlanIds: Codeunit "Plan Ids";
        PlanConfigurationCard: TestPage "Plan Configuration Card";
    begin
        PlanConfigurationLibrary.ClearPlanConfigurations();
        PlanConfigurationLibrary.AddConfiguration(PlanIds.GetDelegatedAdminPlanId(), false);

        PlanConfigurationCard.Trap();
        PlanConfigurationLibrary.OpenConfiguration(PlanIds.GetDelegatedAdminPlanId());

        // Verify User Groups
        LibraryAssert.IsFalse(PlanConfigurationCard.DefaultUserGroups.Editable(), 'Default user groups part should not be editable');
        PlanConfigurationCard.DefaultUserGroups.Expand(true);
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultUserGroups.First(), 'There should be a default user group');

        LibraryAssert.AreEqual('D365 BACKUP/RESTORE', PlanConfigurationCard.DefaultUserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultUserGroups.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultUserGroups.Next(), 'There should be a default user group');

        LibraryAssert.AreEqual('D365 FULL ACCESS', PlanConfigurationCard.DefaultUserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultUserGroups.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultUserGroups.Next(), 'There should be a default user group');

        LibraryAssert.AreEqual('D365 RAPIDSTART', PlanConfigurationCard.DefaultUserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultUserGroups.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultUserGroups.Next(), 'There should be a default user group');

        LibraryAssert.AreEqual('D365 TROUBLESHOOT', PlanConfigurationCard.DefaultUserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultUserGroups.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultUserGroups.Next(), 'There should be a default user group');

        LibraryAssert.AreEqual('EXCEL EXPORT ACTION', PlanConfigurationCard.DefaultUserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultUserGroups.Company.Value, 'Wrong company');
        LibraryAssert.IsFalse(PlanConfigurationCard.DefaultUserGroups.Next(), 'There should not more user groups');

        // Verify permission sets
        LibraryAssert.IsFalse(PlanConfigurationCard.DefaultPermissionSets.Editable(), 'Default user groups part should not be editable');
        PlanConfigurationCard.DefaultPermissionSets.Expand(true);
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.First(), 'There should be a default user group');

        LibraryAssert.AreEqual('D365 BACKUP/RESTORE', PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.Next(), 'There should be a default permission set');

        LibraryAssert.AreEqual('D365 BASIC', PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.Next(), 'There should be a default permission set');

        LibraryAssert.AreEqual('D365 FULL ACCESS', PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.Next(), 'There should be a default permission set');

        LibraryAssert.AreEqual('D365 RAPIDSTART', PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.Next(), 'There should be a default permission set');

        LibraryAssert.AreEqual('EDIT IN EXCEL - VIEW', PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.Next(), 'There should not more permission sets');

        LibraryAssert.AreEqual('EXPORT REPORT EXCEL', PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.Next(), 'There should not more permission sets');

        LibraryAssert.AreEqual('TROUBLESHOOT TOOLS', PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.IsFalse(PlanConfigurationCard.DefaultPermissionSets.Next(), 'There should be a default permission set');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddUserGroupTpDelegatedAdminPlan()
    var
        UserPermissionsLibrary: Codeunit "User Permissions Library";
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        PlanIds: Codeunit "Plan Ids";
        PlanConfigurationCard: TestPage "Plan Configuration Card";
    begin
        UserPermissionsLibrary.CreateSuperUser(CopyStr(Any.AlphabeticText(50), 1, 50));
        UserPermissionsLibrary.AssignPermissionSetToUser(UserSecurityId(), 'SUPER');

        PlanConfigurationLibrary.ClearPlanConfigurations();
        PlanConfigurationLibrary.AddConfiguration(PlanIds.GetDelegatedAdminPlanId(), false);

        PlanConfigurationCard.Trap();
        PlanConfigurationLibrary.OpenConfiguration(PlanIds.GetDelegatedAdminPlanId());

        // Customize permissions
        PlanConfigurationCard.Customized.SetValue(true);

        // Verify User Groups
        PlanConfigurationCard.UserGroups.Expand(true);
        LibraryAssert.IsTrue(PlanConfigurationCard.UserGroups.First(), 'There should be a custom user group');

        LibraryAssert.AreEqual('D365 BACKUP/RESTORE', PlanConfigurationCard.UserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.UserGroups.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.UserGroups.Next(), 'There should be a custom user group');

        LibraryAssert.AreEqual('D365 FULL ACCESS', PlanConfigurationCard.UserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.UserGroups.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.UserGroups.Next(), 'There should be a custom user group');

        LibraryAssert.AreEqual('D365 RAPIDSTART', PlanConfigurationCard.UserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.UserGroups.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.UserGroups.Next(), 'There should be a custom user group');

        LibraryAssert.AreEqual('D365 TROUBLESHOOT', PlanConfigurationCard.UserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.UserGroups.Company.Value, 'Wrong company');
        LibraryAssert.IsTrue(PlanConfigurationCard.UserGroups.Next(), 'There should be a custom user group');

        LibraryAssert.AreEqual('EXCEL EXPORT ACTION', PlanConfigurationCard.UserGroups."User Group".Value, 'Wrong user group code');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.UserGroups.Company.Value, 'Wrong company');

        // Verify permission sets
        PlanConfigurationCard.CustomPermissionSets.Expand(true);
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.First(), 'There should be a custom permssion set');

        LibraryAssert.AreEqual('D365 BACKUP/RESTORE', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('System Application', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should be a custom permission set');

        LibraryAssert.AreEqual('D365 BASIC', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('Base Application', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should be a custom permission set');

        LibraryAssert.AreEqual('D365 FULL ACCESS', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('Base Application', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should be a custom permission set');

        LibraryAssert.AreEqual('D365 RAPIDSTART', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('Base Application', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should be a custom permission set');

        LibraryAssert.AreEqual('EDIT IN EXCEL - VIEW', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('System Application', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should not more permission sets');

        LibraryAssert.AreEqual('EXPORT REPORT EXCEL', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('System Application', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should not more permission sets');

        LibraryAssert.AreEqual('TROUBLESHOOT TOOLS', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('System Application', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');

        // Add new custom user group
        PlanConfigurationCard.Edit().Invoke();

        PlanConfigurationCard.UserGroups.New();
        PlanConfigurationCard.UserGroups."User Group".SetValue('D365 SECURITY');
        PlanConfigurationCard.UserGroups.Company.SetValue('');
        PlanConfigurationCard.UserGroups.Next(); // Add the new user groups

        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should be a custom permission set');

        LibraryAssert.AreEqual('D365 BASIC', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual('', PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('Base Application', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should be a custom permission set');

        LibraryAssert.AreEqual('D365 MONITOR FIELDS', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual('', PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('Base Application', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should be a custom permission set');

        LibraryAssert.AreEqual('SECURITY', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        LibraryAssert.AreEqual('', PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
    end;
}