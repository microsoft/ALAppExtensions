// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139483 "Feature Uptake Telemetry Test"
{
    Subtype = Test;
    Permissions = tabledata "Feature Uptake" = rimd;

    var
        FeatureUptake: Record "Feature Uptake";
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        FeatureUptakeStatusImpl: Codeunit "Feature Uptake Status Impl.";
        TestFeatureNameTxt: Label 'Test feature', Locked = true;
        FeatureUptakeStatus: Enum "Feature Uptake Status";

    [Test]
    procedure TestUptakeInOrderIsSuccessful()
    var
        NullGuid: Guid;
        CurrentPublisher: Text;
    begin
        // [GIVEN] The user has enough permissions to send feature uptake telemetry
        PermissionsMock.Set('Telemetry Exec');
        CurrentPublisher := GetCurrentPublisher();

        // [GIVEN] There is no record of any feature uptakes
        FeatureUptake.DeleteAll();

        // [WHEN] The feature uptake status for the feature TestFeatureNameTxt changes to Discovered
        // [THEN] The update is as expected and the state is stored correctly in the Feature Telemetry Uptake table
        Assert.IsTrue(FeatureUptakeStatusImpl.UpdateFeatureUptakeStatus(TestFeatureNameTxt, FeatureUptakeStatus::Discovered, false, false, CurrentPublisher), 'The update should have been expected: the status should have successfully changed to Discovered.');
        FeatureUptake.Get(TestFeatureNameTxt, NullGuid, CurrentPublisher);
        Assert.AreEqual(FeatureUptakeStatus::Discovered, FeatureUptake."Feature Uptake Status", 'Wrong feature uptake status is stored.');

        // [WHEN] The feature uptake status for the feature TestFeatureNameTxt changes to Set up
        // [THEN] The update is as expected and the state is stored correctly in the Feature Telemetry Uptake table
        Assert.IsTrue(FeatureUptakeStatusImpl.UpdateFeatureUptakeStatus(TestFeatureNameTxt, FeatureUptakeStatus::"Set up", false, false, CurrentPublisher), 'The update should have been expected: the status should have successfully changed to Set up.');
        FeatureUptake.Get(TestFeatureNameTxt, NullGuid, CurrentPublisher);
        Assert.AreEqual(FeatureUptakeStatus::"Set up", FeatureUptake."Feature Uptake Status", 'Wrong feature uptake status is stored.');

        // [WHEN] The feature uptake status for the feature TestFeatureNameTxt changes to Used
        // [THEN] The update is as expected and the state is stored correctly in the Feature Telemetry Uptake table
        Assert.IsTrue(FeatureUptakeStatusImpl.UpdateFeatureUptakeStatus(TestFeatureNameTxt, FeatureUptakeStatus::Used, false, false, CurrentPublisher), 'The update should have been expected: the status should have successfully changed to Used.');
        FeatureUptake.Get(TestFeatureNameTxt, NullGuid, CurrentPublisher);
        Assert.AreEqual(FeatureUptakeStatus::Used, FeatureUptake."Feature Uptake Status", 'Wrong feature uptake status is stored.');

        // [WHEN] The feature uptake status for the feature TestFeatureNameTxt changes to Undiscovered
        // [THEN] The UpdateFeatureUptakeStatus returns false (an unexpected update), as the state of the feature is now reset
        Assert.IsFalse(FeatureUptakeStatusImpl.UpdateFeatureUptakeStatus(TestFeatureNameTxt, FeatureUptakeStatus::Undiscovered, false, false, CurrentPublisher), 'The update should have been not expected.');
        // [THEN] The record is deleted from the Feature Telemetry Uptake table
        Assert.IsFalse(FeatureUptake.Get(TestFeatureNameTxt, NullGuid, CurrentPublisher), 'The record should have been deleted.');
    end;

    [Test]
    procedure TestUptakeOutOfOrderIsUnsuccessful()
    var
        NullGuid: Guid;
    begin
        // [GIVEN] The user has enough permissions to send feature uptake telemetry
        PermissionsMock.Set('Telemetry Exec');

        // [GIVEN] There is no record of any feature uptakes
        FeatureUptake.DeleteAll();

        // [WHEN] The feature uptake status for the feature TestFeatureNameTxt changes to Set up
        // [THEN] The UpdateFeatureUptakeStatus returns false (an unexpected update), because the TestFeatureNameTxt feature has never been discovered
        Assert.IsFalse(FeatureUptakeStatusImpl.UpdateFeatureUptakeStatus(TestFeatureNameTxt, FeatureUptakeStatus::"Set up", false, false, GetCurrentPublisher()), 'The update should have been not expected.');

        // [THEN] The state is still stored correctly in the Feature Telemetry Uptake table
        FeatureUptake.Get(TestFeatureNameTxt, NullGuid, GetCurrentPublisher());
        Assert.AreEqual(FeatureUptakeStatus::"Set up", FeatureUptake."Feature Uptake Status", 'Wrong feature uptake status is stored.');
    end;

    [Test]
    procedure TestSameUptakeStatusTwice()
    begin
        // [GIVEN] The user has enough permissions to send feature uptake telemetry
        PermissionsMock.Set('Telemetry Exec');

        // [GIVEN] There is no record of any feature uptakes
        FeatureUptake.DeleteAll();

        // [WHEN] The feature uptake status for the feature TestFeatureNameTxt changes to Discovered
        // [THEN] The update is as expected and the state is stored correctly in the Feature Telemetry Uptake table
        Assert.IsTrue(FeatureUptakeStatusImpl.UpdateFeatureUptakeStatus(TestFeatureNameTxt, FeatureUptakeStatus::Discovered, false, false, GetCurrentPublisher()), 'The status should have successfully changed to Set up.');

        // [WHEN] The feature uptake status for the feature TestFeatureNameTxt is set to Discovered again
        // [THEN] The UpdateFeatureUptakeStatus returns false (an unexpected update)
        Assert.IsFalse(FeatureUptakeStatusImpl.UpdateFeatureUptakeStatus(TestFeatureNameTxt, FeatureUptakeStatus::Discovered, false, false, GetCurrentPublisher()), 'The status should have not changed.');
    end;

    local procedure GetCurrentPublisher(): Text
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        exit(CurrentModuleInfo.Publisher);
    end;
}

