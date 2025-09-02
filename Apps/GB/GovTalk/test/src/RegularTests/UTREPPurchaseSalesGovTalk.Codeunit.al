// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;
using System.TestLibraries.Utilities;
using System.Environment.Configuration;

codeunit 144035 "UT REP Purchase Sales GovTalk"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = IntegrationTest;
#if not CLEAN27
    EventSubscriberInstance = Manual;
#endif

    var
        Assert: Codeunit Assert;
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        CurrentSaveValuesId: Integer;

    [Test]
    [HandlerFunctions('ECSalesListReportRPH')]
    [Scope('OnPrem')]
    procedure ECSalesListRequestPageFieldsBasicApplicationArea()
    begin
        // [FEATURE] [ECSL] [Application Area] [UI] [UT]
        // [SCENARIO 331168] ReportLayout and "Create XML File" fields are enabled on EC Sales List Request page when Application Area = #basic
        Initialize();
#if not CLEAN27
        BindSubscription(this);
#endif

        // [GIVEN] Enabled Application Area = #basic setup
        LibraryApplicationArea.EnableBasicSetup();
        Commit();

        // [WHEN] Run "EC Sales List" report
        // [THEN] ReportLayout and "Create XML File" fields are enabled (check in RPH)
        REPORT.Run(REPORT::"EC Sales List");
        LibraryApplicationArea.DisableApplicationAreaSetup();
#if not CLEAN27
        UnbindSubscription(this);
#endif
    end;

    [Test]
    [HandlerFunctions('ECSalesListReportRPH')]
    [Scope('OnPrem')]
    procedure ECSalesListRequestPageFieldsSuiteApplicationArea()
    begin
        // [FEATURE] [ECSL] [Application Area] [UI] [UT]
        // [SCENARIO 331168] ReportLayout and "Create XML File" fields are enabled on EC Sales List Request page when Application Area = #suite
        Initialize();
#if not CLEAN27
        BindSubscription(this);
#endif
        // [GIVEN] Enabled Application Area = #suite setup
        LibraryApplicationArea.EnableFoundationSetup();
        Commit();

        // [WHEN] Run "EC Sales List" report
        // [THEN] ReportLayout and "Create XML File" fields are enabled (check in RPH)
        REPORT.Run(REPORT::"EC Sales List");
        LibraryApplicationArea.DisableApplicationAreaSetup();
#if not CLEAN27
        UnbindSubscription(this);
#endif
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure ECSalesListReportRPH(var ECSalesList: TestRequestPage "EC Sales List")
    begin
        Assert.IsTrue(ECSalesList."Create XML File GB".Visible(), '');
        Assert.IsTrue(ECSalesList."Create XML File GB".Enabled(), '');
    end;

    local procedure Initialize()
    var
        FeatureKey: Record "Feature Key";
        FeatureKeyUpdateStatus: Record "Feature Data Update Status";
    begin
        LibraryVariableStorage.Clear();
        DeleteObjectOptionsIfNeeded();

        if FeatureKey.Get('ReminderTermsCommunicationTexts') then begin
            FeatureKey.Enabled := FeatureKey.Enabled::None;
            FeatureKey.Modify();
        end;
        if FeatureKeyUpdateStatus.Get('ReminderTermsCommunicationTexts', CompanyName()) then begin
            FeatureKeyUpdateStatus."Feature Status" := FeatureKeyUpdateStatus."Feature Status"::Disabled;
            FeatureKeyUpdateStatus.Modify();
        end;
    end;

    local procedure DeleteObjectOptionsIfNeeded()
    var
        LibraryReportValidation: Codeunit "Library - Report Validation";
    begin
        LibraryReportValidation.DeleteObjectOptions(CurrentSaveValuesId);
    end;

#if not CLEAN27
    [EventSubscriber(ObjectType::Codeunit, Codeunit::GovTalk, OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}

