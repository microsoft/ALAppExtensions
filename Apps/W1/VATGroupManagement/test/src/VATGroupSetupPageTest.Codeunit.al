codeunit 139524 "VAT Group Setup Page Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryVATGroup: Codeunit "Library - VAT Group";
        ControlShouldBeVisibleTxt: Label 'Control should be visible.';
        ControlShouldNotBeVisibleTxt: Label 'Control should not be visible.';
        ValueShouldBeMaskedTxt: Label 'Value should be masked.';

    [Test]
    procedure TestVATReportSetupNoRolePageBehavior()
    var
        TestPageVATReportSetup: TestPage "VAT Report Setup";
    begin
        // [SCENARIO 374187] VAT Report Setup No Role Page Behavior

        // [GIVEN] The VAT Report Setup page is open
        TestPageVATReportSetup.OpenEdit();

        // [WHEN] No VAT Group role is selected
        TestPageVATReportSetup.VATGroupRole.SetValue(0);

        // [THEN] No page controls and buttons related to any VAT Group role should be displayed
        Assert.IsFalse(TestPageVATReportSetup.VATGroupAuthenticationType.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.VATGroupAuthenticationTypeSaas.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.MemberIdentifier.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.APIURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.GroupRepresentativeBCVersion.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.GroupRepresentativeCompany.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.UserName.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.WebserviceAccessKey.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ClientId.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ClientSecret.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.AuthorityURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ResourceURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.RedirectURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ApprovedMembers.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.RenewToken.Visible(), ControlShouldNotBeVisibleTxt);
    end;

    [Test]
    procedure TestVATReportSetupRepresentativePageBehavior()
    var
        TestPageVATReportSetup: TestPage "VAT Report Setup";
        TestPageVATGroupApprovedMemberList: TestPage "VAT Group Approved Member List";
    begin
        // [SCENARIO 374187] VAT Report Setup Representative Page Behavior

        // [GIVEN] There are no approved vat group members
        LibraryVATGroup.ClearApprovedMembers();

        // [GIVEN] The VAT Report Setup page is open
        TestPageVATReportSetup.OpenEdit();

        // [WHEN] Representative VAT Group role is selected
        TestPageVATReportSetup.VATGroupRole.SetValue(1);

        // [THEN] Only 1 control should be visible
        Assert.IsFalse(TestPageVATReportSetup.VATGroupAuthenticationType.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.VATGroupAuthenticationTypeSaas.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.MemberIdentifier.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.APIURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.GroupRepresentativeBCVersion.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.GroupRepresentativeCompany.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.UserName.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.WebserviceAccessKey.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ClientId.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ClientSecret.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.AuthorityURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ResourceURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.RedirectURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.ApprovedMembers.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.RenewToken.Visible(), ControlShouldNotBeVisibleTxt);

        // [THEN] The Approved Members should reflect the count of how many members are approved.
        Assert.AreEqual(0, TestPageVATReportSetup.ApprovedMembers.AsInteger(), 'Should be 0 members');

        // [THEN] Clicking on the Approved Members control should open the VATGroupApprovedMember List Page
        TestPageVATGroupApprovedMemberList.Trap();
        TestPageVATReportSetup.ApprovedMembers.Drilldown();

        // [THEN] Inserting an approved member in that page should reflect on the value in the approved member control
        TestPageVATGroupApprovedMemberList.New();
        TestPageVATGroupApprovedMemberList.ID.SetValue(CreateGuid());
        TestPageVATGroupApprovedMemberList."Group Member Name".SetValue('TEST Member');
        TestPageVATGroupApprovedMemberList.New();
        TestPageVATGroupApprovedMemberList.Close();

        TestPageVATReportSetup.View().Invoke();
        Assert.AreEqual(1, TestPageVATReportSetup.ApprovedMembers.AsInteger(), 'Should be 1 member after the insert');
    end;

    [Test]
    procedure TestVATReportSetupMemberWindowsPageBehavior()
    var
        TestPageVATReportSetup: TestPage "VAT Report Setup";
    begin
        // [SCENARIO 374187] VAT Report Setup Member Windows Page Behavior

        // [GIVEN] The VAT Report Setup page is open
        TestPageVATReportSetup.OpenEdit();

        // [GIVEN] The Member role is selected
        TestPageVATReportSetup.VATGroupRole.SetValue(2);

        // [WHEN] Windows authentication is selected
        TestPageVATReportSetup.VATGroupAuthenticationType.SetValue(2);

        // [THEN] Only page controls related to this role and authentication method should be visible
        Assert.IsTrue(TestPageVATReportSetup.VATGroupAuthenticationType.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.VATGroupAuthenticationTypeSaas.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.MemberIdentifier.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.APIURL.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.GroupRepresentativeBCVersion.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.GroupRepresentativeCompany.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.UserName.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.WebserviceAccessKey.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ClientId.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ClientSecret.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.AuthorityURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ResourceURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.RedirectURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ApprovedMembers.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.RenewToken.Visible(), ControlShouldNotBeVisibleTxt);
    end;

    [Test]
    procedure TestVATReportSetupMemberOnSaaSPageBehavior()
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        TestPageVATReportSetup: TestPage "VAT Report Setup";
    begin
        // [SCENARIO 374187] VAT Report Setup Member On SaaS Page Behavior

        // [GIVEN] The environment is SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] The VAT Report Setup page is open
        TestPageVATReportSetup.OpenEdit();

        // [WHEN] The Member role is selected
        TestPageVATReportSetup.VATGroupRole.SetValue(2);

        // [THEN] The SaaS specific authentication type control should be visible
        Assert.IsFalse(TestPageVATReportSetup.VATGroupAuthenticationType.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.VATGroupAuthenticationTypeSaas.Visible(), ControlShouldBeVisibleTxt);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    procedure TestVATReportSetupMemberWSAKPageBehavior()
    var
        TestPageVATReportSetup: TestPage "VAT Report Setup";
    begin
        // [SCENARIO 374187] VAT Report Setup Member WSAK Page Behavior

        // [GIVEN] The VAT Report Setup page is open
        TestPageVATReportSetup.OpenEdit();

        // [GIVEN] The Member role is selected
        TestPageVATReportSetup.VATGroupRole.SetValue(2);

        // [WHEN] Windows authentication is selected
        TestPageVATReportSetup.VATGroupAuthenticationType.SetValue(0);

        // [WHEN] Secret values are inputed
        TestPageVATReportSetup.WebserviceAccessKey.SetValue('testkey');
        TestPageVATReportSetup.UserName.SetValue('testuser');

        // [THEN] Only page controls related to this role and authentication method should be visible
        Assert.IsTrue(TestPageVATReportSetup.VATGroupAuthenticationType.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.VATGroupAuthenticationTypeSaas.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.MemberIdentifier.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.GroupRepresentativeBCVersion.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.APIURL.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.GroupRepresentativeCompany.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.UserName.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.WebserviceAccessKey.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ClientId.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ClientSecret.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.AuthorityURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ResourceURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.RedirectURL.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ApprovedMembers.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.RenewToken.Visible(), ControlShouldNotBeVisibleTxt);

        // [THEN] Secret values should be obfuscated
        Assert.AreEqual('●●●●●●●●●●', TestPageVATReportSetup.UserName.Value(), ValueShouldBeMaskedTxt);
        Assert.AreEqual('●●●●●●●●●●', TestPageVATReportSetup.WebserviceAccessKey.Value(), ValueShouldBeMaskedTxt);
    end;

    [Test]
    procedure TestVATReportSetupMemberOAUTHPageBehavior()
    var
        TestPageVATReportSetup: TestPage "VAT Report Setup";
    begin
        // [SCENARIO 374187] VAT Report Setup Member OAUTH Page Behavior

        // [GIVEN] The VAT Report Setup page is open
        TestPageVATReportSetup.OpenEdit();

        // [GIVEN] The Member role is selected
        TestPageVATReportSetup.VATGroupRole.SetValue(2);

        // [WHEN] Windows authentication is selected
        TestPageVATReportSetup.VATGroupAuthenticationType.SetValue(1);

        // [WHEN] Secret values are inputed
        TestPageVATReportSetup.ClientId.SetValue('testkey');
        TestPageVATReportSetup.ClientSecret.SetValue('testuser');

        // [THEN] Only page controls related to this role and authentication method should be visible
        Assert.IsTrue(TestPageVATReportSetup.VATGroupAuthenticationType.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.VATGroupAuthenticationTypeSaas.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.MemberIdentifier.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.GroupRepresentativeBCVersion.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.APIURL.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.GroupRepresentativeCompany.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.UserName.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.WebserviceAccessKey.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.ClientId.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.ClientSecret.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.AuthorityURL.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.ResourceURL.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.RedirectURL.Visible(), ControlShouldBeVisibleTxt);
        Assert.IsFalse(TestPageVATReportSetup.ApprovedMembers.Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsTrue(TestPageVATReportSetup.RenewToken.Visible(), ControlShouldBeVisibleTxt);

        // [THEN] Secret values should be obfuscated
        Assert.AreEqual('●●●●●●●●●●', TestPageVATReportSetup.ClientId.Value(), ValueShouldBeMaskedTxt);
        Assert.AreEqual('●●●●●●●●●●', TestPageVATReportSetup.ClientSecret.Value(), ValueShouldBeMaskedTxt);
    end;
}