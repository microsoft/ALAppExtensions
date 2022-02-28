// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132925 "Default Perm. In Plan Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        FirstCompanyTok: Label '(first company sign-in)';

    [Test]
    [HandlerFunctions('ConfirmResetToDefault')]
    [Scope('OnPrem')]
    procedure CustomizePermissionSetAdd()
    var
        PlanIds: Codeunit "Plan Ids";
        DefaultPermissionSetFetcher: Codeunit "Default Permission Set Fetcher";
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        UserPermissionsLibrary: Codeunit "User Permissions Library";
        PlanConfigurationList: TestPage "Plan Configuration List";
        PlanConfigurationCard: TestPage "Plan Configuration Card";
    begin
        // [Scenario] Open Delegated Admin plan configuration and view default permission set
        // then customize the permission sets by adding AAD Plan View permission set
        // close and reopen the page to verify the permission sets

        // Initialize

        PlanConfigurationLibrary.ClearPlanConfigurations();
        PlanConfigurationLibrary.AddConfiguration(PlanIds.GetDelegatedAdminPlanId(), false);
        BindSubscription(DefaultPermissionSetFetcher);

        UserPermissionsLibrary.CreateSuperUser(CopyStr(Any.AlphabeticText(50), 1, 50));
        UserPermissionsLibrary.AssignPermissionSetToUser(UserSecurityId(), 'SUPER');

        PlanConfigurationList.OpenView();

        LibraryAssert.IsTrue(PlanConfigurationList.First(), 'There should be a configuration on the page');
        LibraryAssert.IsFalse(PlanConfigurationList.Customized.AsBoolean(), 'Customized on the list page should be false');
        LibraryAssert.AreEqual('Delegated Admin agent - Partner', PlanConfigurationList."Plan Name".Value, 'Plan name on list page is wrong');

        PlanConfigurationCard.Trap();
        PlanConfigurationList."Plan Name".Drilldown();

        LibraryAssert.IsFalse(PlanConfigurationCard.Customized.AsBoolean(), 'Delegated Admin configuration should not be customized');

        LibraryAssert.IsFalse(PlanConfigurationCard.DefaultPermissionSets.Editable(), 'Default permission set part should not be editable');
        PlanConfigurationCard.DefaultPermissionSets.Expand(true);

        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.First(), 'There should be one permission set');

        LibraryAssert.AreEqual('SUPER', PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value, 'Wrong permission set');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('', PlanConfigurationCard.DefaultPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.AreEqual('System', PlanConfigurationCard.DefaultPermissionSets.PermissionScope.Value, 'Wrong permission set scope');
        LibraryAssert.IsFalse(PlanConfigurationCard.DefaultPermissionSets.Next(), 'There should not be more permission sets');

        // Customize permissions
        PlanConfigurationCard.Edit().Invoke();
        PlanConfigurationCard.Customized.SetValue(true);

        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Editable(), 'Custom permission sets part should be editable');

        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.First(), 'There should be one permission set');

        LibraryAssert.AreEqual('SUPER', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.AreEqual('System', PlanConfigurationCard.CustomPermissionSets.PermissionScope.Value, 'Wrong permission set scope');
        //LibraryAssert.IsFalse(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should not be more permission sets');

        // Add new permission set
        PlanConfigurationCard.CustomPermissionSets.New();
        PlanConfigurationCard.CustomPermissionSets.PermissionSetId.SetValue('AAD Plan View');
        PlanConfigurationCard.CustomPermissionSets.Company.SetValue('');
        PlanConfigurationCard.CustomPermissionSets.Next();

        PlanConfigurationCard.Close();

        LibraryAssert.IsTrue(PlanConfigurationList.First(), 'There should be a configuration on the page');
        LibraryAssert.IsTrue(PlanConfigurationList.Customized.AsBoolean(), 'Customized on the list page should be false');
        LibraryAssert.AreEqual('Delegated Admin agent - Partner', PlanConfigurationList."Plan Name".Value, 'Plan name on list page is wrong after customized');

        PlanConfigurationCard.Trap();
        PlanConfigurationList."Plan Name".Drilldown();

        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.First(), 'There should be one permission set');

        LibraryAssert.AreEqual('SUPER', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set');
        LibraryAssert.AreEqual(CompanyName(), PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.AreEqual('System', PlanConfigurationCard.CustomPermissionSets.PermissionScope.Value, 'Wrong permission set scope');
        LibraryAssert.IsTrue(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should be more permission sets');

        LibraryAssert.AreEqual('AAD PLAN VIEW', PlanConfigurationCard.CustomPermissionSets.PermissionSetId.Value, 'Wrong permission set');
        LibraryAssert.AreEqual('', PlanConfigurationCard.CustomPermissionSets.Company.Value, 'Wrong company');
        // LibraryAssert.AreEqual('Azure AD Plan Test Library', PlanConfigurationCard.CustomPermissionSets.ExtensionName.Value, 'Wrong extension name');  // Disabled because it could be either 'System Application Test Library' or 'Azure AD Plan Test Library' depending on the whether the test is executed as part of System Application Tests or Azure AD Plan Tests.
        LibraryAssert.AreEqual('System', PlanConfigurationCard.CustomPermissionSets.PermissionScope.Value, 'Wrong permission set scope');
        LibraryAssert.IsFalse(PlanConfigurationCard.CustomPermissionSets.Next(), 'There should not be more permission sets');

        // Reset to default permissions
        PlanConfigurationCard.Customized.SetValue(false);

        LibraryAssert.IsFalse(PlanConfigurationCard.CustomPermissionSets.Editable(), 'Custom permission sets part should not be editable');
        LibraryAssert.IsFalse(PlanConfigurationCard.DefaultPermissionSets.Editable(), 'Default permission sets part should not be editable');

        LibraryAssert.IsFalse(PlanConfigurationCard.CustomPermissionSets.First(), 'There should not be a custom permission set');
        LibraryAssert.IsTrue(PlanConfigurationCard.DefaultPermissionSets.First(), 'There should be a default permission set');

        LibraryAssert.AreEqual('SUPER', PlanConfigurationCard.DefaultPermissionSets."Permission Set".Value, 'Wrong permission set');
        LibraryAssert.AreEqual(FirstCompanyTok, PlanConfigurationCard.DefaultPermissionSets.Company.Value, 'Wrong company');
        LibraryAssert.AreEqual('', PlanConfigurationCard.DefaultPermissionSets.ExtensionName.Value, 'Wrong extension name');
        LibraryAssert.AreEqual('System', PlanConfigurationCard.DefaultPermissionSets.PermissionScope.Value, 'Wrong permission set scope');
        LibraryAssert.IsFalse(PlanConfigurationCard.DefaultPermissionSets.Next(), 'There should not be more permission sets');
    end;

    [ConfirmHandler]
    procedure ConfirmResetToDefault(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryAssert.AreEqual('Restoring the default permissions will delete the customization for the selected license. Do you want to continue?', Question, 'Wrong confirm question');

        Reply := true;
    end;
}