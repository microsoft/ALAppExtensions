// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135092 "Upgrade Tag Test"
{
    Subtype = Test;
    Permissions = tabledata "Intelligent Cloud" = rmid,
                  tabledata "Upgrade Tags" = rd,
                  tabledata "Upgrade Tag Backup" = rmid;

    var
        PermissionsMock: Codeunit "Permissions Mock";

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
        PermissionsMock.Set('Upgrade Tags View');

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
        PermissionsMock.Set('Upgrade Tags View');

        // [Given] Any Upgrade tag
        NewUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));

        // [When] SetUpgradeTag is called
        UpgradeTag.SetUpgradeTag(NewUpgradeTag);

        // [Then] HasUpgradeTag Should return true
        Assert.IsTrue(UpgradeTag.HasUpgradeTag(NewUpgradeTag), 'Tag should have been set, HasUpgradeTag must return true');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestHasUpgradeTagReturnsTrueWhenTagIsSetOnDatabase()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        NewUpgradeTag: Code[250];
    begin
        // [Scenario] HasUpgradeTag should return true when upgrade tag is set by using SetDatabaseUpgradeTag function
        PermissionsMock.Set('Upgrade Tags View');

        // [Given] Any Upgrade tag
        NewUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));

        // [When] SetUpgradeTag is called
        UpgradeTag.SetDatabaseUpgradeTag(NewUpgradeTag);

        // [Then] HasUpgradeTag Should return true
        Assert.IsTrue(UpgradeTag.HasUpgradeTag(NewUpgradeTag, ''), 'Tag should have been set, HasUpgradeTag must return true');
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
        PermissionsMock.Set('Upgrade Tags View');

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
        PermissionsMock.Set('Upgrade Tags View');

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
        PermissionsMock.Set('Upgrade Tags View');
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
        PermissionsMock.Set('Upgrade Tags View');

        // [Given] All upgrade tags are registered
        UpgradeTag.SetAllUpgradeTags();

        // [Then] No exception is thrown if we call validate. 
        UpgradeTagTags.VerifyAllCompaniesInitialized();
        UpgradeTagTags.VerifyCompanyInitialized('');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestHasUpgradeTagSkippedReturnsFalseWhenTagIsSet()
    var
        UpgradeTags: Record "Upgrade Tags";
        UpgradeTag: Codeunit "Upgrade Tag";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        NewUpgradeTag: Code[250];
    begin
        // [Scenario] HasUpgradeTagSkipped should return true when upgrade tag is skipped set by using SetSkippedUpgrade function
        PermissionsMock.Set('Upgrade Tags View');

        // [Given] Any Upgrade tag and insert into table
        NewUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetUpgradeTag(NewUpgradeTag);

        // [Then] HasUpgradeTag Should return true
        Assert.IsFalse(UpgradeTag.HasUpgradeTagSkipped(NewUpgradeTag, CopyStr(CompanyName(), 1, MaxStrLen(UpgradeTags.Company))), 'Skipped should not have been set, HasUpgradeTagSkipped must return false');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestHasUpgradeTagSkippedReturnsTrueWhenTagIsSet()
    var
        UpgradeTags: Record "Upgrade Tags";
        UpgradeTag: Codeunit "Upgrade Tag";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        NewUpgradeTag: Code[250];
    begin
        // [Scenario] HasUpgradeTagSkipped should return true when upgrade tag is skipped set by using SetSkippedUpgrade function
        PermissionsMock.Set('Upgrade Tags View');

        // [Given] Any Upgrade tag and insert into table
        NewUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetUpgradeTag(NewUpgradeTag);

        // [When] SetSkippedUpgrade is called
        UpgradeTag.SetSkippedUpgrade(NewUpgradeTag, true);

        // [Then] HasUpgradeTag Should return true
        Assert.IsTrue(UpgradeTag.HasUpgradeTagSkipped(NewUpgradeTag, CopyStr(CompanyName(), 1, MaxStrLen(UpgradeTags.Company))), 'Skipped should have been set, HasUpgradeTagSkipped must return true');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBackupUpgradeTags()
    var
        UpgradeTagBackup: Record "Upgrade Tag Backup";
        UpgradeTag: Codeunit "Upgrade Tag";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        UpgradeTagInStream: InStream;
        NewUpgradeTag: Code[250];
        NewUpgradeTag2: Code[250];
        UpgradeTagJson: Text;
        BackupID: Integer;
    begin
        EnableIntelligentCloud();

        // [Scenario] Backup Upgrade Tags should create a backup record
        PermissionsMock.Set('Upgrade Tags View');

        // [Given] Any two Upgrade tag and insert into table
        NewUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetUpgradeTag(NewUpgradeTag);

        NewUpgradeTag2 := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetUpgradeTag(NewUpgradeTag2);

        // [When] Backup Upgrade Tags is called
        BackupID := UpgradeTag.BackupUpgradeTags();

        // [Then] Backup record is created containing all records that were present in the database
        Assert.IsTrue(UpgradeTagBackup.Get(BackupID), 'Backup record was not created');
        UpgradeTagBackup.CalcFields(Content);
        UpgradeTagBackup.Content.CreateInStream(UpgradeTagInStream);
        UpgradeTagInStream.ReadText(UpgradeTagJson);

        Assert.IsTrue(UpgradeTagJson.Contains(NewUpgradeTag), 'First tag was not serialized');
        Assert.IsTrue(UpgradeTagJson.Contains(NewUpgradeTag2), 'Second tag was not serialized');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRestoreUpgradeTagsInsertMissingOnly()
    var
        UpgradeTags: Record "Upgrade Tags";
        TempUpgradeTag: Record "Upgrade Tags" temporary;
        UpgradeTag: Codeunit "Upgrade Tag";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        NewUpgradeTag: Code[250];
        NewUpgradeTag2: Code[250];
        BackupID: Integer;
    begin
        EnableIntelligentCloud();

        // [Scenario] Restoring backed up upgrade tags is inserting back the records
        PermissionsMock.Set('Upgrade Tags View');

        // [Given] Any two Upgrade tag and insert into table
        NewUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetUpgradeTag(NewUpgradeTag);
        AddUpgradeTagToBuffer(TempUpgradeTag, NewUpgradeTag, CompanyName());

        NewUpgradeTag2 := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetUpgradeTag(NewUpgradeTag2);
        AddUpgradeTagToBuffer(TempUpgradeTag, NewUpgradeTag2, CompanyName());

        // [Given] Backup Upgrade Tags was executed called
        BackupID := UpgradeTag.BackupUpgradeTags();

        // [Given] One record was deleted
        UpgradeTags.Get(NewUpgradeTag, CompanyName());
        UpgradeTags.Delete();

        // [When] Restore from Backup is called
        UpgradeTag.RestoreUpgradeTagsFromBackup(BackupID, true);

        // [Then] One record is restored, second record is unchanged
        Assert.IsTrue(UpgradeTags.Get(NewUpgradeTag, CompanyName()), 'First upgrade tag was not restored');
        TempUpgradeTag.Get(NewUpgradeTag, CompanyName());
        VerifyRecordsMatch(TempUpgradeTag, UpgradeTags);

        Assert.IsTrue(UpgradeTags.Get(NewUpgradeTag2, CompanyName()), 'Second upgrade tag was not restored');
        TempUpgradeTag.Get(NewUpgradeTag2, CompanyName());
        VerifyRecordsMatch(TempUpgradeTag, UpgradeTags);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRestoreUpgradeTagsReplacesRecords()
    var
        UpgradeTags: Record "Upgrade Tags";
        TempUpgradeTag: Record "Upgrade Tags" temporary;
        UpgradeTag: Codeunit "Upgrade Tag";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        NewUpgradeTag: Code[250];
        NewUpgradeTag2: Code[250];
        NewUpgradeTag3: Code[250];
        PerDatabaseUpgradeTag: Code[250];
        BackupID: Integer;
    begin
        EnableIntelligentCloud();

        // [Scenario] Restoring backed up upgrade tags is replacing entire table
        PermissionsMock.Set('Upgrade Tags View');

        // [Given] Any three Upgrade tag are registered in database
        NewUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetUpgradeTag(NewUpgradeTag);
        AddUpgradeTagToBuffer(TempUpgradeTag, NewUpgradeTag, CompanyName());

        NewUpgradeTag2 := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetUpgradeTag(NewUpgradeTag2);
        AddUpgradeTagToBuffer(TempUpgradeTag, NewUpgradeTag2, CompanyName());

        PerDatabaseUpgradeTag := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetDatabaseUpgradeTag(PerDatabaseUpgradeTag);
        AddUpgradeTagToBuffer(TempUpgradeTag, PerDatabaseUpgradeTag, '');

        // [Given] Backup Upgrade Tags was executed called
        BackupID := UpgradeTag.BackupUpgradeTags();

        // [Given] Two records were deleted
        UpgradeTags.Get(NewUpgradeTag, CompanyName());
        UpgradeTags.Delete();

        UpgradeTags.Get(PerDatabaseUpgradeTag, '');
        UpgradeTags.Delete();

        // [Given] New tag was inserted
        NewUpgradeTag3 := CopyStr(Any.AlphanumericText(MaxStrLen(NewUpgradeTag)), 1, MaxStrLen(NewUpgradeTag));
        UpgradeTag.SetUpgradeTag(NewUpgradeTag3);

        // [When] Restore from Backup is called
        UpgradeTag.RestoreUpgradeTagsFromBackup(BackupID, false);

        // [Then] Previous record are restored
        Assert.IsTrue(UpgradeTags.Get(NewUpgradeTag, CompanyName()), 'First upgrade tag was not restored');
        TempUpgradeTag.Get(NewUpgradeTag, CompanyName());
        VerifyRecordsMatch(TempUpgradeTag, UpgradeTags);

        Assert.IsTrue(UpgradeTags.Get(NewUpgradeTag2, CompanyName()), 'Second upgrade tag was not restored');
        TempUpgradeTag.Get(NewUpgradeTag2, CompanyName());
        VerifyRecordsMatch(TempUpgradeTag, UpgradeTags);

        Assert.IsTrue(UpgradeTags.Get(PerDatabaseUpgradeTag, ''), 'Second upgrade tag was not restored');
        TempUpgradeTag.Get(PerDatabaseUpgradeTag, '');
        VerifyRecordsMatch(TempUpgradeTag, UpgradeTags);

        // [Then] Record that was inserted before backup is not present
        Assert.IsFalse(UpgradeTags.Get(NewUpgradeTag3, CompanyName()), 'Second upgrade tag was not restored');
    end;

    local procedure AddUpgradeTagToBuffer(var TempUpgradeTag: Record "Upgrade Tags" temporary; UpgradeTag: code[250]; TagCompanyName: Text)
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        UpgradeTags.Get(UpgradeTag, CopyStr(TagCompanyName, 1, MaxStrLen(UpgradeTags.Company)));
        TempUpgradeTag.TransferFields(UpgradeTags, true);
        TempUpgradeTag.SystemId := UpgradeTags.SystemId;
        TempUpgradeTag.Insert();
    end;

    local procedure EnableIntelligentCloud()
    var
        IntellingentCloud: Record "Intelligent Cloud";
    begin
        if not IntellingentCloud.Get() then
            IntellingentCloud.Insert();

        if not IntellingentCloud.Enabled then begin
            IntellingentCloud.Enabled := true;
            IntellingentCloud.Modify();
        end;
    end;

    local procedure VerifyRecordsMatch(ExpectedUpgradeTags: Record "Upgrade Tags"; ActualUpgradeTags: Record "Upgrade Tags")
    var
        Assert: Codeunit "Library Assert";
    begin
        Assert.AreEqual(ExpectedUpgradeTags.Company, ActualUpgradeTags.Company, 'Company field does not match');
        Assert.AreEqual(ExpectedUpgradeTags."Skipped Upgrade", ActualUpgradeTags."Skipped Upgrade", '"Skipped Upgrade" field does not match');
        Assert.AreEqual(ExpectedUpgradeTags.Tag, ActualUpgradeTags.Tag, 'Tag field does not match');
        Assert.AreEqual(ExpectedUpgradeTags."Tag Timestamp", ActualUpgradeTags."Tag Timestamp", 'Tag Timestamp field does not match');
        Assert.AreEqual(ExpectedUpgradeTags.SystemId, ActualUpgradeTags.SystemId, 'SystemId field does not match');
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

