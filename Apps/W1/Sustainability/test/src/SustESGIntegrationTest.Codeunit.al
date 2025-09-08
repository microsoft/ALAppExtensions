// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Test.Sustainability;

using Microsoft.Integration.D365Sales;
using Microsoft.Integration.Dataverse;
using Microsoft.Integration.SyncEngine;
using Microsoft.Sustainability.CRM;
using Microsoft.Sustainability.ESGReporting;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;
using System.Security.AccessControl;
using System.Security.Encryption;
using System.TestLibraries.Utilities;
using System.Threading;

codeunit 148213 "Sust. ESG Integration Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Integration] [Connection Setup]
    end;

    var
        Assert: Codeunit Assert;
        CRMProductName: Codeunit "CRM Product Name";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryCRMIntegration: Codeunit "Library - CRM Integration";
        LibrarySustainability: Codeunit "Library - Sustainability";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        IsInitialized: Boolean;
        JobQueueEntryStatusOnHoldErr: Label 'Job Queue Entry status should be On Hold.';
        SetupSuccessfulMsg: Label 'The default setup for %1 synchronization has completed successfully.', Comment = '%1 = CRM product name';
        WrongControlVisibilityErr: Label 'Wrong control visibility.';
        RecordMustBeCoupledErr: Label '%1 %2 must be coupled to %3.', Comment = '%1 = Table Caption, %2 = primary key value, %3 - service name';

    [Test]
    procedure EnableConnectionCanResetIntegrationTableMappingsIfEmpty()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        // [SCENARIO 546883] Verify the "Integration Table Mapping" must be reset When "Is Dataverse Int. Enabled" is Enabled.
        Initialize();

        // [GIVEN] Register Test Table Connection.
        LibraryCRMIntegration.RegisterTestTableConnection();
        LibraryCRMIntegration.EnsureCRMSystemUser();
        LibraryCRMIntegration.CreateCRMOrganization();

        // [GIVEN] Table Mapping is empty.
        Assert.TableIsEmpty(Database::"Integration Table Mapping");

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Connection is disabled.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(false);

        // [WHEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [THEN] "Integration Table Mapping" is filled.
        Assert.RecordCount(IntegrationTableMapping, 9);
    end;

    [Test]
    [HandlerFunctions('ConfirmYes,MessageOk')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure InvokeResetConfigurationCreatesNewMappings()
    var
        JobQueueEntry: Record "Job Queue Entry";
        IntegrationTableMapping: Record "Integration Table Mapping";
        SustainabilitySetup: TestPage "Sustainability Setup";
    begin
        // [SCENARIO 546883] Verify the "Integration Table Mapping" must be reset When "ResetConfiguration" action is invoked.
        Initialize();

        // [GIVEN] Connection to CRM established.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        LibraryCRMIntegration.ConfigureCRM();

        // [GIVEN] No "Integration Table Mapping" and "Job Queue Entry" records.
        IntegrationTableMapping.DeleteAll(true);
        JobQueueEntry.DeleteAll();

        // [GIVEN] Enable the connection.
        InitSetup(true);

        // [GIVEN] Open Sustainability Setup.
        SustainabilitySetup.OpenEdit();

        // [WHEN] "Use Default Synchronization Setup" action is invoked.
        SustainabilitySetup.ResetConfiguration.Invoke();

        // [THEN] Integration Table Mapping and Job Queue Entry tables are not empty.
        Assert.RecordCount(IntegrationTableMapping, 9);
        Assert.RecordCount(JobQueueEntry, 9);

        // [THEN] Verify Message "The default setup for Dynamics 365 Sales synchronization has completed successfully." should appears.
        Assert.ExpectedMessage(StrSubstNo(SetupSuccessfulMsg, CRMProductName.CDSServiceName()), LibraryVariableStorage.DequeueText());
    end;

    [Test]
    procedure DisableJobQueueEntriesOnDisableSustConnection()
    begin
        // [SCENARIO 546883] Verify disabling CRM Connection move Sustainability CRM Job Queue Entries in "On Hold" status.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [WHEN] Connection is disabled.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(false);

        // [THEN] All Job Queue Entries has Status = Ready.
        VerifyJobQueueEntriesStatusIsOnHold();
    end;

    [Test]
    procedure TestReportingUnitIsCreatedFromUnit()
    var
        CRMUnit: Record "Sust. Unit";
        ReportingUnit: Record "Sust. ESG Reporting Unit";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        // [SCENARIO 546883] Verify Reporting Unit should be created from Dataverse Unit.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create Unit in Dataverse.
        LibrarySustainability.CreateCRMUnit(CRMUnit);

        // [WHEN] Synchronize CRM Unit to Reporting Unit.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        CRMUnit.SetRange(UnitId, CRMUnit.UnitId);
        CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMUnit);
        LibraryCRMIntegration.RunJobQueueEntry(Database::"Sust. Unit", CRMUnit.GetView(), IntegrationTableMapping);

        // [THEN] Verify Reporting Unit should be created from Dataverse Unit.
        ReportingUnit.SetRange(Code, CRMUnit.Name);
        Assert.RecordIsNotEmpty(ReportingUnit);
    end;

    [Test]
    procedure TestReportingListCRMControlsVisibility()
    var
        ReportingUnit: Record "Sust. ESG Reporting Unit";
        ReportingUnitPage: TestPage "Sust. ESG Reporting Units";
    begin
        // [SCENARIO 546883] Verify CRM related controls on Reporting Unit List page must not be visible when CRM Connection is not configured.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create "Reporting Unit" in Dataverse.
        LibrarySustainability.CreateReportingUnit(ReportingUnit);

        // [WHEN] Open "Reporting Unit" Page.
        ReportingUnitPage.OpenView();
        ReportingUnitPage.FILTER.SetFilter("Code", ReportingUnit.Code);

        // [VERIFY] Verify CRM related controls are visible on Reporting Unit List page.
        Assert.AreEqual(true, ReportingUnitPage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ReportingUnitPage.CRMGotoUnit.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ReportingUnitPage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ReportingUnitPage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ReportingUnitPage.ShowLog.Visible(), WrongControlVisibilityErr);
        ReportingUnitPage.Close();

        // [GIVEN] Disable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(false);

        // [WHEN] Open "Reporting Unit" Page.
        ReportingUnitPage.OpenView();
        ReportingUnitPage.FILTER.SetFilter("Code", ReportingUnit.Code);

        // [VERIFY] Verify CRM related controls are not visible on Reporting Unit List page.
        Assert.AreEqual(false, ReportingUnitPage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ReportingUnitPage.CRMGotoUnit.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ReportingUnitPage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ReportingUnitPage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ReportingUnitPage.ShowLog.Visible(), WrongControlVisibilityErr);
        ReportingUnitPage.Close();
    end;

    [Test]
    procedure TestReportingUnitIsCreatedFromUnitMustBeCoupled()
    var
        CRMUnit: Record "Sust. Unit";
        CRMIntegrationRecord: Record "CRM Integration Record";
        ReportingUnit: Record "Sust. ESG Reporting Unit";
        IntegrationTableMapping: Record "Integration Table Mapping";
        ReportingUnitRecId: RecordId;
    begin
        // [SCENARIO 546883] Verify Reporting Unit should be created from Dataverse Unit must be coupled.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create Unit in Dataverse.
        LibrarySustainability.CreateCRMUnit(CRMUnit);

        // [WHEN] Synchronize CRM Unit to Reporting Unit.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        CRMUnit.SetRange(UnitId, CRMUnit.UnitId);
        CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMUnit);
        LibraryCRMIntegration.RunJobQueueEntry(Database::"Sust. Unit", CRMUnit.GetView(), IntegrationTableMapping);

        // [THEN] Verify Reporting Unit should be created from Dataverse Unit must be coupled.
        Assert.IsTrue(
            CRMIntegrationRecord.FindRecordIDFromID(CRMUnit.UnitId, Database::"Sust. ESG Reporting Unit", ReportingUnitRecId),
            StrSubstNo(RecordMustBeCoupledErr, CRMUnit.TableCaption(), Format(CRMUnit.UnitId), ReportingUnit.TableCaption));
    end;

    [Test]
    procedure TestCRMBaseUnitIsNotCoupledToReportingUnit()
    var
        CRMUnit: Record "Sust. Unit";
        CRMBaseUnit: Record "Sust. Unit";
        ReportingUnit: Record "Sust. ESG Reporting Unit";
        IntegrationTableMapping: Record "Integration Table Mapping";
        CRMIntegrationRecord: Record "CRM Integration Record";
        ReportingUnitRecId: RecordId;
    begin
        // [SCENARIO 546883] Verify Reporting Unit should be created from Dataverse Unit.
        Initialize();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create Unit in Dataverse.
        LibrarySustainability.CreateCRMUnit(CRMUnit);

        // [GIVEN] Create Base Unit in Dataverse.
        LibrarySustainability.CreateCRMUnit(CRMBaseUnit);

        // [GIVEN] Update Base Unit.
        CRMUnit.IsBaseUnit := true;
        CRMUnit.BaseUnit := CRMBaseUnit.UnitId;
        CRMUnit.Modify();

        // [WHEN] Synchronize CRM Unit to Reporting Unit.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        CRMUnit.SetRange(UnitId, CRMUnit.UnitId);
        CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMUnit);
        LibraryCRMIntegration.RunJobQueueEntry(Database::"Sust. Unit", CRMUnit.GetView(), IntegrationTableMapping);

        // [THEN] Verify Reporting Unit should be created from Base Dataverse Unit must be coupled.
        Assert.IsTrue(
            CRMIntegrationRecord.FindRecordIDFromID(CRMBaseUnit.UnitId, Database::"Sust. ESG Reporting Unit", ReportingUnitRecId),
            StrSubstNo(RecordMustBeCoupledErr, CRMUnit.TableCaption(), Format(CRMBaseUnit.UnitId), ReportingUnit.TableCaption));
    end;

    [Test]
    procedure TestStandardIsCreatedFromCRM()
    var
        CRMStandard: Record "Sust. Standard";
        Standard: Record "Sust. ESG Standard";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        // [SCENARIO 546883] Verify Standard should be created from CRM.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create Standard in Dataverse.
        LibrarySustainability.CreateCRMStandard(CRMStandard);

        // [WHEN] Synchronize CRM Standard to BC.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        CRMStandard.SetRange(StandardId, CRMStandard.StandardId);
        CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMStandard);
        LibraryCRMIntegration.RunJobQueueEntry(Database::"Sust. Standard", CRMStandard.GetView(), IntegrationTableMapping);

        // [THEN] Verify Standard should be created from CRM.
        Standard.SetRange("Standard ID", CRMStandard.StandardId);
        Assert.RecordIsNotEmpty(Standard);
    end;

    [Test]
    procedure TestStandardListCRMControlsVisibility()
    var
        Standard: Record "Sust. ESG Standard";
        StandardPage: TestPage "Sust. ESG Standards";
    begin
        // [SCENARIO 546883] Verify CRM related controls on Standard List page must not be visible when CRM Connection is not configured.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create "Standard" in BC.
        LibrarySustainability.CreateStandard(Standard);

        // [WHEN] Open "Standard" Page.
        StandardPage.OpenView();
        StandardPage.FILTER.SetFilter("No.", Standard."No.");

        // [VERIFY] Verify CRM related controls are visible on Standard List page.
        Assert.AreEqual(true, StandardPage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, StandardPage.CRMGotoStandard.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, StandardPage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, StandardPage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, StandardPage.ShowLog.Visible(), WrongControlVisibilityErr);
        StandardPage.Close();

        // [GIVEN] Disable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(false);

        // [WHEN] Open "Standard" Page.
        StandardPage.OpenView();
        StandardPage.FILTER.SetFilter("No.", Standard."No.");

        // [VERIFY] Verify CRM related controls are not visible on Standard List page.
        Assert.AreEqual(false, StandardPage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, StandardPage.CRMGotoStandard.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, StandardPage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, StandardPage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, StandardPage.ShowLog.Visible(), WrongControlVisibilityErr);
        StandardPage.Close();
    end;

    [Test]
    procedure TestStandardIsCreatedFromCRMMustBeCoupled()
    var
        CRMStandard: Record "Sust. Standard";
        CRMIntegrationRecord: Record "CRM Integration Record";
        Standard: Record "Sust. ESG Standard";
        IntegrationTableMapping: Record "Integration Table Mapping";
        StandardRecId: RecordId;
    begin
        // [SCENARIO 546883] Verify Standard should be created from Dataverse must be coupled.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create Standard in Dataverse.
        LibrarySustainability.CreateCRMStandard(CRMStandard);

        // [WHEN] Synchronize CRM Standard to BC.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        CRMStandard.SetRange(StandardId, CRMStandard.StandardId);
        CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMStandard);
        LibraryCRMIntegration.RunJobQueueEntry(Database::"Sust. Standard", CRMStandard.GetView(), IntegrationTableMapping);

        // [THEN] Verify Standard should be created from Dataverse must be coupled.
        Assert.IsTrue(
            CRMIntegrationRecord.FindRecordIDFromID(CRMStandard.StandardId, Database::"Sust. ESG Standard", StandardRecId),
            StrSubstNo(RecordMustBeCoupledErr, CRMStandard.TableCaption(), Format(CRMStandard.StandardId), Standard.TableCaption));
    end;

    [Test]
    procedure TestESGReportingNameIsCreatedFromCRM()
    var
        CRMAssessment: Record "Sust. Assessment";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        IntegrationTableMapping: Record "Integration Table Mapping";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
    begin
        // [SCENARIO 546883] Verify ESG Reporting Name should be created from CRM.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create Assessment in Dataverse.
        LibrarySustainability.CreateCRMAssessment(CRMAssessment);

        // [WHEN] Synchronize CRM Assessment to BC.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        CRMAssessment.SetRange(AssessmentId, CRMAssessment.AssessmentId);
        CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMAssessment);
        LibraryCRMIntegration.RunJobQueueEntry(Database::"Sust. Assessment", CRMAssessment.GetView(), IntegrationTableMapping);

        // [THEN] Verify Reporting Name should be created from CRM.
        ESGReportingName.SetRange("ESG Reporting Template Name", ESGReportingManagement.GetESGDefaultTemplate());
        ESGReportingName.SetRange(Name, CRMAssessment.Name);
        Assert.RecordIsNotEmpty(ESGReportingName);
    end;

    [Test]
    procedure TestReportingNameListCRMControlsVisibility()
    var
        ReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingNamePage: TestPage "Sust. ESG Reporting Names";
    begin
        // [SCENARIO 546883] Verify CRM related controls on Reporting Name List page must not be visible when CRM Connection is not configured.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create "Reporting Name" in BC.
        LibrarySustainability.CreateESGReportingName(ReportingName);

        // [WHEN] Open "Reporting Name" Page.
        ESGReportingNamePage.OpenView();
        ESGReportingNamePage.FILTER.SetFilter(Name, ReportingName.Name);

        // [VERIFY] Verify CRM related controls are visible on ESG Reporting Name List page.
        Assert.AreEqual(true, ESGReportingNamePage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ESGReportingNamePage.CRMGotoAssessment.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ESGReportingNamePage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ESGReportingNamePage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ESGReportingNamePage.ShowLog.Visible(), WrongControlVisibilityErr);
        ESGReportingNamePage.Close();

        // [GIVEN] Disable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(false);

        // [WHEN] Open "Reporting Name" Page.
        ESGReportingNamePage.OpenView();
        ESGReportingNamePage.FILTER.SetFilter(Name, ReportingName.Name);

        // [VERIFY] Verify CRM related controls are not visible on Reporting Name List page.
        Assert.AreEqual(false, ESGReportingNamePage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ESGReportingNamePage.CRMGotoAssessment.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ESGReportingNamePage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ESGReportingNamePage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ESGReportingNamePage.ShowLog.Visible(), WrongControlVisibilityErr);
        ESGReportingNamePage.Close();
    end;

    [Test]
    procedure TestReportingNameIsCreatedFromCRMMustBeCoupled()
    var
        CRMAssessment: Record "Sust. Assessment";
        CRMIntegrationRecord: Record "CRM Integration Record";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        IntegrationTableMapping: Record "Integration Table Mapping";
        ReportingNameRecId: RecordId;
    begin
        // [SCENARIO 546883] Verify Reporting Name should be created from Dataverse must be coupled.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create Assessment in Dataverse.
        LibrarySustainability.CreateCRMAssessment(CRMAssessment);

        // [WHEN] Synchronize CRM Assessment to BC.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        CRMAssessment.SetRange(AssessmentId, CRMAssessment.AssessmentId);
        CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMAssessment);
        LibraryCRMIntegration.RunJobQueueEntry(Database::"Sust. Assessment", CRMAssessment.GetView(), IntegrationTableMapping);

        // [THEN] Verify Reporting Name should be created from Dataverse must be coupled.
        Assert.IsTrue(
            CRMIntegrationRecord.FindRecordIDFromID(CRMAssessment.AssessmentId, Database::"Sust. ESG Reporting Name", ReportingNameRecId),
            StrSubstNo(RecordMustBeCoupledErr, CRMAssessment.TableCaption(), Format(CRMAssessment.AssessmentId), ESGReportingName.TableCaption));
    end;

    [Test]
    procedure TestESGReportingLineIsCreatedFromCRM()
    var
        CRMAssessmentRequirement: Record "Sust. Assessment Requirement";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        IntegrationTableMapping: Record "Integration Table Mapping";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
    begin
        // [SCENARIO 546883] Verify ESG Reporting Line should be created from CRM.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create Assessment Requirement in Dataverse.
        LibrarySustainability.CreateCRMAssessmentRequirement(CRMAssessmentRequirement);

        // [WHEN] Synchronize CRM Assessment Requirement to BC.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        CRMAssessmentRequirement.SetRange(AssessmentRequirementId, CRMAssessmentRequirement.AssessmentRequirementId);
        CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMAssessmentRequirement);
        LibraryCRMIntegration.RunJobQueueEntry(Database::"Sust. Assessment Requirement", CRMAssessmentRequirement.GetView(), IntegrationTableMapping);

        // [THEN] Verify Reporting Line should be created from CRM.
        ESGReportingLine.SetRange("ESG Reporting Template Name", ESGReportingManagement.GetESGDefaultTemplate());
        ESGReportingLine.SetRange("ESG Reporting Name", '');
        ESGReportingLine.SetRange("Reporting Code", CRMAssessmentRequirement.Name);
        Assert.RecordIsNotEmpty(ESGReportingLine);
    end;

    [Test]
    procedure TestReportingLineListCRMControlsVisibility()
    var
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingLinePage: TestPage "Sust. ESG Reporting Lines";
    begin
        // [SCENARIO 546883] Verify CRM related controls on Reporting Line List page must not be visible when CRM Connection is not configured.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);
        ESGReportingName.Validate("Period Name", Format(Date2DMY(WorkDate(), 3)));
        ESGReportingName.Validate("Period Starting Date", CalcDate('<-CY>', WorkDate()));
        ESGReportingName.Validate("Period Ending Date", CalcDate('<CY>', WorkDate()));
        ESGReportingName.Modify();

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine,
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine."Value Settings"::Sum,
            '',
            ESGReportingLine."Row Type"::"Net Change",
            '',
            ESGReportingLine."Calculate with"::Sign,
            true,
            ESGReportingLine."Show with"::Sign);

        // [WHEN] Open "Reporting Line" Page.
        ESGReportingLinePage.OpenView();
        ESGReportingLinePage.FILTER.SetFilter("ESG Reporting Template Name", ESGReportingTemplate.Name);
        ESGReportingLinePage.FILTER.SetFilter("ESG Reporting Name", ESGReportingName.Name);

        // [VERIFY] Verify CRM related controls are visible on ESG Reporting Line List page.
        Assert.AreEqual(true, ESGReportingLinePage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ESGReportingLinePage.CRMGotoAssessmentRequirement.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ESGReportingLinePage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ESGReportingLinePage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, ESGReportingLinePage.ShowLog.Visible(), WrongControlVisibilityErr);
        ESGReportingLinePage.Close();

        // [GIVEN] Disable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(false);

        // [WHEN] Open "Reporting Line" Page.
        ESGReportingLinePage.OpenView();
        ESGReportingLinePage.FILTER.SetFilter("ESG Reporting Template Name", ESGReportingTemplate.Name);
        ESGReportingLinePage.FILTER.SetFilter("ESG Reporting Name", ESGReportingName.Name);

        // [VERIFY] Verify CRM related controls are not visible on Reporting Line List page.
        Assert.AreEqual(false, ESGReportingLinePage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ESGReportingLinePage.CRMGotoAssessmentRequirement.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ESGReportingLinePage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ESGReportingLinePage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, ESGReportingLinePage.ShowLog.Visible(), WrongControlVisibilityErr);
        ESGReportingLinePage.Close();
    end;

    [Test]
    procedure TestReportingLineIsCreatedFromCRMMustBeCoupled()
    var
        CRMAssessmentRequirement: Record "Sust. Assessment Requirement";
        CRMIntegrationRecord: Record "CRM Integration Record";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        IntegrationTableMapping: Record "Integration Table Mapping";
        ReportingNameRecId: RecordId;
    begin
        // [SCENARIO 546883] Verify Reporting Line should be created from Dataverse must be coupled.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create Assessment Requirement in Dataverse.
        LibrarySustainability.CreateCRMAssessmentRequirement(CRMAssessmentRequirement);

        // [WHEN] Synchronize CRM Assessment Requirement to BC.
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        CRMAssessmentRequirement.SetRange(AssessmentRequirementId, CRMAssessmentRequirement.AssessmentRequirementId);
        CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMAssessmentRequirement);
        LibraryCRMIntegration.RunJobQueueEntry(Database::"Sust. Assessment Requirement", CRMAssessmentRequirement.GetView(), IntegrationTableMapping);

        // [THEN] Verify Reporting Line should be created from Dataverse must be coupled.
        Assert.IsTrue(
            CRMIntegrationRecord.FindRecordIDFromID(CRMAssessmentRequirement.AssessmentRequirementId, Database::"Sust. ESG Reporting Line", ReportingNameRecId),
            StrSubstNo(RecordMustBeCoupledErr, CRMAssessmentRequirement.TableCaption(), Format(CRMAssessmentRequirement.AssessmentRequirementId), ESGReportingLine.TableCaption));
    end;

    [Test]
    [HandlerFunctions('ConfirmYes,MessageOk')]
    procedure TestPostedReportingLineListCRMControlsVisibility()
    var
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        PostedESGReportingLinePage: TestPage "Sust. Posted ESG Report Lines";
    begin
        // [SCENARIO 546883] Verify CRM related controls on Posted Reporting Line List page must not be visible when CRM Connection is not configured.
        Initialize();

        // [GIVEN] Update "ESG Standard Nos." in Sustainability Setup.
        LibrarySustainability.UpdateESGStandardReportingNoInSustainabilitySetup();

        // [GIVEN] Update "Posted ESG Reporting Nos." in Sustainability Setup.
        LibrarySustainability.UpdatePostedESGReportingNoInSustainabilitySetup();

        // [GIVEN] Enable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(true);

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);
        ESGReportingName.Validate("Period Name", Format(Date2DMY(WorkDate(), 3)));
        ESGReportingName.Validate("Period Starting Date", CalcDate('<-CY>', WorkDate()));
        ESGReportingName.Validate("Period Ending Date", CalcDate('<CY>', WorkDate()));
        ESGReportingName.Modify();

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine,
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine."Value Settings"::Sum,
            '',
            ESGReportingLine."Row Type"::"Net Change",
            '',
            ESGReportingLine."Calculate with"::Sign,
            true,
            ESGReportingLine."Show with"::Sign);

        // [GIVEN] Open ESG Reporting Aggregation.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);

        // [WHEN] Open Calculate and Post ESG Report.
        ESGReportingAggregation."Calc. and Post ESG Report".Invoke();

        // [WHEN] Open "Posted Reporting Line" Page.
        PostedESGReportingLinePage.OpenView();
        PostedESGReportingLinePage.FILTER.SetFilter("ESG Reporting Template Name", ESGReportingTemplate.Name);
        PostedESGReportingLinePage.FILTER.SetFilter("ESG Reporting Name", ESGReportingName.Name);

        // [VERIFY] Verify CRM related controls are visible on Posted ESG Reporting Line List page.
        Assert.AreEqual(true, PostedESGReportingLinePage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, PostedESGReportingLinePage.CRMGotoFact.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, PostedESGReportingLinePage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, PostedESGReportingLinePage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(true, PostedESGReportingLinePage.ShowLog.Visible(), WrongControlVisibilityErr);
        PostedESGReportingLinePage.Close();

        // [GIVEN] Disable the connection.
        LibrarySustainability.UpdateDataverseIntegrationInSustainabilitySetup(false);

        // [WHEN] Open "Posted Reporting Line" Page.
        PostedESGReportingLinePage.OpenView();
        PostedESGReportingLinePage.FILTER.SetFilter("ESG Reporting Template Name", ESGReportingTemplate.Name);
        PostedESGReportingLinePage.FILTER.SetFilter("ESG Reporting Name", ESGReportingName.Name);

        // [VERIFY] Verify CRM related controls are not visible on Posted Reporting Line List page.
        Assert.AreEqual(false, PostedESGReportingLinePage.CRMSynchronizeNow.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, PostedESGReportingLinePage.CRMGotoFact.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, PostedESGReportingLinePage.DeleteCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, PostedESGReportingLinePage.ManageCRMCoupling.Visible(), WrongControlVisibilityErr);
        Assert.AreEqual(false, PostedESGReportingLinePage.ShowLog.Visible(), WrongControlVisibilityErr);
        PostedESGReportingLinePage.Close();
    end;

    local procedure Initialize()
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        LibrarySustainability.CleanUpBeforeTesting();
        LibraryCRMIntegration.ResetEnvironment();
        LibraryVariableStorage.Clear();
        if CryptographyManagement.IsEncryptionEnabled() then
            CryptographyManagement.DisableEncryption(true);
        Assert.IsFalse(EncryptionEnabled(), 'Encryption should be disabled');

        UnregisterTableConnection(TableConnectionType::CRM, '');
        UnregisterTableConnection(TableConnectionType::CRM, GetDefaultTableConnection(TableConnectionType::CRM));
        Assert.AreEqual(
          '', GetDefaultTableConnection(TableConnectionType::CRM),
          'DEFAULTTABLECONNECTION should not be registered');

        InitializeCDSConnectionSetup();

        if IsInitialized then
            exit;

        IsInitialized := true;
        SetTenantLicenseStateToTrial();
    end;

    local procedure InitializeCDSConnectionSetup()
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        ClearClientSecret: Text;
        ClientSecret: SecretText;
    begin
        CDSConnectionSetup.DeleteAll();
        CDSConnectionSetup."Is Enabled" := true;
        CDSConnectionSetup."Server Address" := '@@test@@';
        CDSConnectionSetup."User Name" := 'user@test.net';
        CDSConnectionSetup."Authentication Type" := CDSConnectionSetup."Authentication Type"::Office365;
        CDSConnectionSetup."Proxy Version" := LibraryCRMIntegration.GetLastestSDKVersion();
        CDSConnectionSetup.Validate("Client Id", 'ClientId');
        CDSConnectionSetup.Validate("Redirect URL", 'RedirectURL');
        ClearClientSecret := 'ClientSecret';
        ClientSecret := ClearClientSecret;
        CDSConnectionSetup.SetClientSecret(ClientSecret);
    end;

    local procedure SetTenantLicenseStateToTrial()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        TenantLicenseState."Start Date" := CurrentDateTime;
        TenantLicenseState.State := TenantLicenseState.State::Trial;
        TenantLicenseState.Insert();
    end;

    local procedure InitSetup(DataverseIntegration: Boolean)
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        SustainabilitySetup."Is Dataverse Int. Enabled" := DataverseIntegration;
        SustainabilitySetup.Modify();
    end;

    local procedure VerifyJobQueueEntriesStatusIsOnHold()
    var
        JobQueueEntry: Record "Job Queue Entry";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        JobQueueEntry.FindSet();
        repeat
            if IntegrationTableMapping.Get(JobQueueEntry."Record ID to Process") then
                Assert.IsTrue(JobQueueEntry.Status = JobQueueEntry.Status::"On Hold", JobQueueEntryStatusOnHoldErr);
        until JobQueueEntry.Next() = 0;
    end;

    [ConfirmHandler]
    procedure ConfirmYes(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageOk(Message: Text)
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;
}