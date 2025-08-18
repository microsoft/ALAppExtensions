// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139510 "Delegated Admin Config. Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        FirstCompanyTok: Label '(first company sign-in)', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure VerifyDelegatedAdminPermissionSets()
    var
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        PlanIds: Codeunit "Plan Ids";
        PlanConfigurationCard: TestPage "Plan Configuration Card";
        RoleIds: List of [Text];
    begin
        PlanConfigurationCard.Trap();
        PlanConfigurationLibrary.OpenConfiguration(PlanIds.GetDelegatedAdminPlanId());

        // Verify permission sets
        Assert.IsFalse(PlanConfigurationCard.DefaultPermissionSets.Editable(), 'Default permission sets part should not be editable');
        PlanConfigurationCard.DefaultPermissionSets.Expand(true);

        Assert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.First(), 'There should be a default permission set');
        repeat
            RoleIds.Add(PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value);
            Assert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        until not PlanConfigurationCard.DefaultPermissionSets.Next();

        Assert.IsTrue(RoleIds.Contains('D365 BACKUP/RESTORE'), 'Wrong permission set ID');
        Assert.IsTrue(RoleIds.Contains('D365 FULL ACCESS'), 'Wrong permission set ID');
        Assert.IsTrue(RoleIds.Contains('D365 RAPIDSTART'), 'Wrong permission set ID');
        Assert.IsTrue(RoleIds.Contains('EXCEL EXPORT ACTION'), 'Wrong permission set ID');
        Assert.IsTrue(RoleIds.Contains('TROUBLESHOOT TOOLS'), 'Wrong permission set ID');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddPermissionSetToDelegatedAdminPlan()
    var
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        PlanIds: Codeunit "Plan Ids";
        PlanConfigurationCard: TestPage "Plan Configuration Card";
        RoleIds: List of [Text];
    begin
        PlanConfigurationCard.Trap();
        PlanConfigurationLibrary.OpenConfiguration(PlanIds.GetDelegatedAdminPlanId());

        // Customize permissions
        PlanConfigurationCard.Customized.SetValue(true);

        // Verify permission sets
        PlanConfigurationCard.CustomPermissionSets.Expand(true);

        Assert.IsTrue(PlanConfigurationCard.CustomPermissionSets.First(), 'There should be a default permission set');
        repeat
            RoleIds.Add(PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value);
            Assert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        until (not PlanConfigurationCard.CustomPermissionSets.Next()) or (PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value = '');

        Assert.IsTrue(RoleIds.Contains('D365 BACKUP/RESTORE'), 'Wrong permission set ID');
        Assert.IsTrue(RoleIds.Contains('D365 FULL ACCESS'), 'Wrong permission set ID');
        Assert.IsTrue(RoleIds.Contains('D365 RAPIDSTART'), 'Wrong permission set ID');
        Assert.IsTrue(RoleIds.Contains('EXCEL EXPORT ACTION'), 'Wrong permission set ID');
        Assert.IsTrue(RoleIds.Contains('TROUBLESHOOT TOOLS'), 'Wrong permission set ID');

        // Add new custom permission set
        PlanConfigurationCard.Edit().Invoke();

        PlanConfigurationCard.CustomPermissionSets.New();
        PlanConfigurationCard.CustomPermissionSets.PermissionSetId.SetValue('SECURITY');
        PlanConfigurationCard.CustomPermissionSets.Company.SetValue('');

        Assert.AreEqual('SECURITY', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set ID');
        Assert.AreEqual('', PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        Assert.AreEqual('', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
    end;
}

