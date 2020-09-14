// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135092 "Upgrade Tag Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [Scope('OnPrem')]
    procedure TestHasUpgradeTagReturnsFalseWhenNotSet()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        NonExistingUpgradeTag: Code[250];
    begin
        // [Scenario] HasUpgradeTag should return false when upgrade tag is not set

        // [Given] Upgrade tag that does not exist
        NonExistingUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NonExistingUpgradeTag)), 1, MaxStrLen(NonExistingUpgradeTag));

        // [When] HasUpgradeTag is called for upgrade tag that is not set
        // [Then] HasUpgradeTag Should return true
        Assert.IsFalse(UpgradeTag.HasUpgradeTag(NonExistingUpgradeTag), 'Tag does not exist, HasUpgradeTag must return false');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestHasUpgradeTagReturnsTrueWhenTagIsSet()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        NewUpgradeTag: Code[250];
    begin
        // [Scenario] HasUpgradeTag should return true when upgrade tag is set by using SetUpgradeTag function

        // [Given] Any Upgrade tag
        NewUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));

        // [When] SetUpgradeTag is called
        UpgradeTag.SetUpgradeTag(NewUpgradeTag);

        // [Then] HasUpgradeTag Should return true
        Assert.IsTrue(UpgradeTag.HasUpgradeTag(NewUpgradeTag), 'Tag should have been set, HasUpgradeTag must return true');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRegisteringUpgradeTagsForNewCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        SetAllUpgradeTagsMock: Codeunit "SetAllUpgradeTags Mock";
        MockedPerCompanyUpgradeTags: List of [Code[250]];
        MockedPerDatabaseUpgradeTags: List of [Code[250]];
    begin
        // [Scenario] HasUpgradeTag should return true when upgrade tag is set by using SetUpgradeTag function

        // [Given] A subscriber that wants to register PerCompany and PerDatabase Upgrade Tags
        SetupSetAllUpgradeTagsMock(SetAllUpgradeTagsMock, MockedPerCompanyUpgradeTags, MockedPerDatabaseUpgradeTags);
        BindSubscription(SetAllUpgradeTagsMock);

        // [When] SetUpgradeTag is called
        UpgradeTag.SetAllUpgradeTags();

        // [Then] All per company and per database upgrade tags are set
        VerifyUpgradeTagsPerCompanyAreRegistered(MockedPerCompanyUpgradeTags);
        VerifyUpgradeTagsPerDatabaseAreRegistered(MockedPerDatabaseUpgradeTags);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRegisteringUpgradeTagsTwice()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        SetAllUpgradeTagsMock: Codeunit "SetAllUpgradeTags Mock";
        MockedPerCompanyUpgradeTags: List of [Code[250]];
        MockedPerDatabaseUpgradeTags: List of [Code[250]];
    begin
        // [Scenario] HasUpgradeTag should return true when upgrade tag is set by using SetUpgradeTag function

        // [Given] A subscriber that wants to register PerCompany and PerDatabase Upgrade Tags
        SetupSetAllUpgradeTagsMock(SetAllUpgradeTagsMock, MockedPerCompanyUpgradeTags, MockedPerDatabaseUpgradeTags);
        BindSubscription(SetAllUpgradeTagsMock);

        // [Given] SetUpgradeTag is already called
        UpgradeTag.SetAllUpgradeTags();

        // [When] SetUpgradeTag is called second time
        UpgradeTag.SetAllUpgradeTags();

        // [Then] No exception is thrown. All per company and per database upgrade tags are set
        VerifyUpgradeTagsPerCompanyAreRegistered(MockedPerCompanyUpgradeTags);
        VerifyUpgradeTagsPerDatabaseAreRegistered(MockedPerDatabaseUpgradeTags);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRegisteringUpgradeTagsNoSubscribers()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        // [Scenario] Register upgrade tags should not trigger any code if there are no subscribers
        // [Given] No active subscribers to SetUpgradeTag methods
        // [When] SetUpgradeTag is called with no subscribers
        UpgradeTag.SetAllUpgradeTags();

        // [Then] No exception is thrown. 
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpgradeTagsPassValidation()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagTags: Codeunit "Upgrade Tag - Tags";
    begin
        // [Scenario] Test upgrade tag validation verifies the setup is correct

        // [Given] All upgrade tags are registered
        UpgradeTag.SetAllUpgradeTags();

        // [Then] No exception is thrown if we call validate. 
        UpgradeTagTags.VerifyAllCompaniesInitialized();
        UpgradeTagTags.VerifyCompanyInitialized('');
    end;

    local procedure SetupSetAllUpgradeTagsMock(var SetAllUpgradeTagsMock: Codeunit "SetAllUpgradeTags Mock"; var MockedPerCompanyUpgradeTags: List of [Code[250]]; var MockedPerDatabaseUpgradeTags: List of [Code[250]])
    var
        Any: Codeunit Any;
        I: Integer;
    begin
        for I := 1 To 10 do
            MockedPerCompanyUpgradeTags.Add(CopyStr(Any.AlphanumericText(250), 1, 250));

        for I := 1 To 10 do
            MockedPerDatabaseUpgradeTags.Add(CopyStr(Any.AlphanumericText(250), 1, 250));

        SetAllUpgradeTagsMock.SetPerCompanyUpgradeTags(MockedPerCompanyUpgradeTags);
        SetAllUpgradeTagsMock.SetPerDatabaseUpgradeTags(MockedPerDatabaseUpgradeTags);
    end;

    local procedure VerifyUpgradeTagsPerCompanyAreRegistered(ExpectedUpgradeTags: List of [Code[250]])
    var
        Assert: Codeunit "Library Assert";
        UpgradeTag: Codeunit "Upgrade Tag";
        CurrentTag: Code[250];
    begin
        foreach CurrentTag in ExpectedUpgradeTags do
            Assert.IsTrue(UpgradeTag.HasUpgradeTag(CurrentTag), StrSubstNo('Have not found the expected upgrade tags. Upgrade tag - %1', CurrentTag));
    end;

    local procedure VerifyUpgradeTagsPerDatabaseAreRegistered(ExpectedUpgradeTags: List of [Code[250]])
    var
        Assert: Codeunit "Library Assert";
        UpgradeTag: Codeunit "Upgrade Tag";
        CurrentTag: Code[250];
    begin
        foreach CurrentTag in ExpectedUpgradeTags do
            Assert.IsTrue(UpgradeTag.HasUpgradeTag(CurrentTag, ''), StrSubstNo('Have not found the expected upgrade tags. Upgrade tag - %1', CurrentTag));
    end;
}

