// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.CRM;

using Microsoft.Integration.D365Sales;
using Microsoft.Integration.Dataverse;
using Microsoft.Integration.SyncEngine;
using Microsoft.Sustainability.ESGReporting;
using Microsoft.Sustainability.Setup;
using Microsoft.Utilities;
using System.Environment.Configuration;
using System.Threading;

codeunit 6277 "Sust. Setup Defaults"
{
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        CRMProductName: Codeunit "CRM Product Name";
        JobQueueCategoryLbl: Label 'BCI INTEG', Locked = true;
        OptionJobQueueCategoryLbl: Label 'BCI OPTION', Locked = true;
        CDSConnectionMustBeEnabledErr: Label 'You must enable the connection to Dataverse before you can set up the connection to %1.\\Choose ''Set up Dataverse connection'' in %2 page.', Comment = '%1 = CRM product name, %2 = Assisted Setup page caption.';
        JobQueueEntryNameTok: Label ' %1 - %2 synchronization job.', Comment = '%1 = The Integration Table Name to synchronized (ex. CUSTOMER), %2 = CRM product name';
        IntegrationTablePrefixTok: Label 'Dynamics CRM', Comment = 'Product name', Locked = true;
        ESGStandardTableMappingNameLbl: Label 'ESGSTAND-STANDARD', Locked = true;
        ESGReportingUnitTableMappingNameLbl: Label 'ESGUNIT-UNIT', Locked = true;
        ESGAssessmentTableMappingNameLbl: Label 'ESGNAME-ASSESS', Locked = true;
        ESGAssessmentRequirementTableMappingNameLbl: Label 'ESGLINE-ASSESS', Locked = true;
        ESGPostedFactTableMappingNameLbl: Label 'ESGPOSTED-FACT', Locked = true;

    internal procedure ResetConfiguration(var SustainabilitySetup: Record "Sustainability Setup")
    var
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        AssistedSetup: Page "Assisted Setup";
    begin
        if not (CRMIntegrationManagement.IsCDSIntegrationEnabled() or CRMIntegrationManagement.IsCRMIntegrationEnabled()) then
            Error(CDSConnectionMustBeEnabledErr, CRMProductName.CDSServiceName(), AssistedSetup.Caption());

        CDSIntegrationMgt.RegisterConnection();
        CDSIntegrationMgt.ActivateConnection();

        ResetESGStandardMapping(ESGStandardTableMappingNameLbl, true);
        ResetESGReportingUnitMapping(ESGReportingUnitTableMappingNameLbl, true);
        ResetESGReportingNameAssessmentMapping(ESGAssessmentTableMappingNameLbl, true);
        ResetESGReportingLineAssessmentRequirementMapping(ESGAssessmentRequirementTableMappingNameLbl, true);
        ResetPostedESGReportingLineESGFactMapping(ESGPostedFactTableMappingNameLbl, true);
    end;

    internal procedure ResetESGStandardMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        SustStandard: Record "Sust. Standard";
        ESGStandard: Record "Sust. ESG Standard";
    begin
        SustStandard.Reset();
        SustStandard.SetRange(StateCode, SustStandard.StateCode::Active);

        InsertIntegrationTableMapping(
            IntegrationTableMapping, IntegrationTableMappingName,
            Database::"Sust. ESG Standard", Database::"Sust. Standard",
            SustStandard.FieldNo(StandardId), SustStandard.FieldNo(ModifiedOn),
            '', '', false);

        IntegrationTableMapping.SetIntegrationTableFilter(GetTableFilterFromView(Database::"Sust. Standard", SustStandard.TableCaption(), SustStandard.GetView()));
        IntegrationTableMapping.SetTableFilter(GetTableFilterFromView(Database::"Sust. ESG Standard", ESGStandard.TableCaption(), ESGStandard.GetView()));
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGStandard.FieldNo("No."),
            SustStandard.FieldNo(Name),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGStandard.FieldNo(Description),
            SustStandard.FieldNo(Name),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetESGReportingUnitMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        SustUnit: Record "Sust. Unit";
        ESGReportingUnit: Record "Sust. ESG Reporting Unit";
    begin
        SustUnit.Reset();
        SustUnit.SetRange(StateCode, SustUnit.StateCode::Active);

        InsertIntegrationTableMapping(
            IntegrationTableMapping, IntegrationTableMappingName,
            Database::"Sust. ESG Reporting Unit", Database::"Sust. Unit",
            SustUnit.FieldNo(UnitId), SustUnit.FieldNo(ModifiedOn),
            '', '', false);

        IntegrationTableMapping.SetIntegrationTableFilter(GetTableFilterFromView(Database::"Sust. Unit", SustUnit.TableCaption(), SustUnit.GetView()));
        IntegrationTableMapping.SetTableFilter(GetTableFilterFromView(Database::"Sust. ESG Reporting Unit", ESGReportingUnit.TableCaption(), ESGReportingUnit.GetView()));
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingUnit.FieldNo(Code),
            SustUnit.FieldNo(Name),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingUnit.FieldNo(Description),
            SustUnit.FieldNo(Name),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingUnit.FieldNo("Conversion Factor"),
            SustUnit.FieldNo(ConversionFactor),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingUnit.FieldNo("Base Reporting Unit Code"),
            SustUnit.FieldNo(BaseUnit),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetESGReportingNameAssessmentMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        SustAssessment: Record "Sust. Assessment";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
    begin
        if not ESGReportingTemplate.Get(ESGReportingManagement.GetESGDefaultTemplate()) then
            ESGReportingManagement.InsertDefaultESGReportingTemplate(ESGReportingTemplate);

        SustAssessment.Reset();
        SustAssessment.SetRange(StateCode, SustAssessment.StateCode::Active);

        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          Database::"Sust. ESG Reporting Name", Database::"Sust. Assessment",
          SustAssessment.FieldNo(AssessmentId), SustAssessment.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetIntegrationTableFilter(GetTableFilterFromView(Database::"Sust. Assessment", SustAssessment.TableCaption(), SustAssessment.GetView()));
        IntegrationTableMapping.SetTableFilter(GetTableFilterFromView(Database::"Sust. ESG Reporting Name", ESGReportingName.TableCaption(), ESGReportingName.GetView()));
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingName.FieldNo("ESG Reporting Template Name"),
            0,
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            ESGReportingManagement.GetESGDefaultTemplate(), true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingName.FieldNo(Name),
            SustAssessment.FieldNo(Name),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingName.FieldNo(Description),
            SustAssessment.FieldNo(Name),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingName.FieldNo(Standard),
            SustAssessment.FieldNo(Standard),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingName.FieldNo("Period Name"),
            SustAssessment.FieldNo(Period),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingName.FieldNo("Period Starting Date"),
            SustAssessment.FieldNo(Period),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingName.FieldNo("Period Ending Date"),
            SustAssessment.FieldNo(Period),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetESGReportingLineAssessmentRequirementMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        SustAssessmentRequirement: Record "Sust. Assessment Requirement";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
    begin
        SustAssessmentRequirement.Reset();
        SustAssessmentRequirement.SetRange(StateCode, SustAssessmentRequirement.StateCode::Active);

        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          Database::"Sust. ESG Reporting Line", Database::"Sust. Assessment Requirement",
          SustAssessmentRequirement.FieldNo(AssessmentRequirementId), SustAssessmentRequirement.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetIntegrationTableFilter(GetTableFilterFromView(Database::"Sust. Assessment Requirement", SustAssessmentRequirement.TableCaption(), SustAssessmentRequirement.GetView()));
        IntegrationTableMapping.SetTableFilter(GetTableFilterFromView(Database::"Sust. ESG Reporting Line", ESGReportingLine.TableCaption(), ESGReportingLine.GetView()));
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingLine.FieldNo("ESG Reporting Template Name"),
            0,
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            ESGReportingManagement.GetESGDefaultTemplate(), true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingLine.FieldNo("ESG Reporting Name"),
            SustAssessmentRequirement.FieldNo(Assessment),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingLine.FieldNo("Reporting Code"),
            SustAssessmentRequirement.FieldNo(Name),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingLine.FieldNo(Description),
            SustAssessmentRequirement.FieldNo(StandardRequirement),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingLine.FieldNo(Grouping),
            SustAssessmentRequirement.FieldNo(StandardRequirement),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingLine.FieldNo("Concept Link"),
            SustAssessmentRequirement.FieldNo(StandardRequirement),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            ESGReportingLine.FieldNo(Concept),
            SustAssessmentRequirement.FieldNo(StandardRequirement),
            IntegrationFieldMapping.Direction::FromIntegrationTable,
            '', true, false);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetPostedESGReportingLineESGFactMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        ESGFact: Record "Sust. ESG Fact";
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
    begin
        ESGFact.Reset();
        ESGFact.SetRange(StateCode, ESGFact.StateCode::Active);

        PostedESGReportingLine.Reset();
        PostedESGReportingLine.SetFilter(Concept, '<>%1', '');
        PostedESGReportingLine.SetFilter("Concept Link", '<>%1', '');
        PostedESGReportingLine.SetFilter("Date Filter", '<>%1', 0D);
        PostedESGReportingLine.SetFilter(Description, '<>%1', '');

        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          Database::"Sust. Posted ESG Report Line", Database::"Sust. ESG Fact",
          ESGFact.FieldNo(ESGFactId), ESGFact.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetIntegrationTableFilter(GetTableFilterFromView(Database::"Sust. ESG Fact", ESGFact.TableCaption(), ESGFact.GetView()));
        IntegrationTableMapping.SetTableFilter(GetTableFilterFromView(Database::"Sust. Posted ESG Report Line", PostedESGReportingLine.TableCaption(), PostedESGReportingLine.GetView()));
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            PostedESGReportingLine.FieldNo("Document No."),
            ESGFact.FieldNo(Name),
            IntegrationFieldMapping.Direction::ToIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            PostedESGReportingLine.FieldNo(Concept),
            ESGFact.FieldNo(Concept),
            IntegrationFieldMapping.Direction::ToIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            PostedESGReportingLine.FieldNo("Date Filter"),
            ESGFact.FieldNo(Period),
            IntegrationFieldMapping.Direction::ToIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            PostedESGReportingLine.FieldNo("Posted Amount"),
            ESGFact.FieldNo(Precision),
            IntegrationFieldMapping.Direction::ToIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            PostedESGReportingLine.FieldNo("Posted Amount"),
            ESGFact.FieldNo(NumericValue),
            IntegrationFieldMapping.Direction::ToIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            0,
            ESGFact.FieldNo(FactStatus),
            IntegrationFieldMapping.Direction::ToIntegrationTable,
            Format(ESGFact.FactStatus::Draft), true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            0,
            ESGFact.FieldNo(Source),
            IntegrationFieldMapping.Direction::ToIntegrationTable,
            Format(ESGFact.Source::BusinessCentral), true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            PostedESGReportingLine.FieldNo(Description),
            ESGFact.FieldNo(RichTextValue),
            IntegrationFieldMapping.Direction::ToIntegrationTable,
            '', true, false);

        InsertIntegrationFieldMapping(
            IntegrationTableMappingName,
            PostedESGReportingLine.FieldNo("Reporting Unit"),
            ESGFact.FieldNo(Unit),
            IntegrationFieldMapping.Direction::ToIntegrationTable,
            '', true, false);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    local procedure InsertIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; MappingName: Code[20]; TableNo: Integer; IntegrationTableNo: Integer; IntegrationTableUIDFieldNo: Integer; IntegrationTableModifiedFieldNo: Integer; TableConfigTemplateCode: Code[10]; IntegrationTableConfigTemplateCode: Code[10]; SynchOnlyCoupledRecords: Boolean)
    var
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        UncoupleCodeunitId: Integer;
        Direction: Integer;
    begin
        Direction := GetDefaultDirection(TableNo);
        if Direction in [IntegrationTableMapping.Direction::ToIntegrationTable, IntegrationTableMapping.Direction::Bidirectional] then
            if CDSIntegrationMgt.HasCompanyIdField(IntegrationTableNo) then
                UncoupleCodeunitId := Codeunit::"CDS Int. Table Uncouple";

        IntegrationTableMapping.CreateRecord(MappingName, TableNo, IntegrationTableNo, IntegrationTableUIDFieldNo,
          IntegrationTableModifiedFieldNo, TableConfigTemplateCode, IntegrationTableConfigTemplateCode,
          SynchOnlyCoupledRecords, Direction, IntegrationTablePrefixTok,
          Codeunit::"CRM Integration Table Synch.", UncoupleCodeunitId);
    end;

    local procedure InsertIntegrationFieldMapping(IntegrationTableMappingName: Code[20]; TableFieldNo: Integer; IntegrationTableFieldNo: Integer; SynchDirection: Option; ConstValue: Text; ValidateField: Boolean; ValidateIntegrationTableField: Boolean)
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
    begin
        IntegrationFieldMapping.CreateRecord(IntegrationTableMappingName, TableFieldNo, IntegrationTableFieldNo, SynchDirection,
          ConstValue, ValidateField, ValidateIntegrationTableField);
    end;

    internal procedure CreateJobQueueEntry(IntegrationTableMapping: Record "Integration Table Mapping"; ServiceName: Text): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, Codeunit::"Integration Synch. Job Runner", StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription(), ServiceName)));
    end;

    local procedure CreateJobQueueEntry(var IntegrationTableMapping: Record "Integration Table Mapping"; JobCodeunitId: Integer; JobDescription: Text): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime() + 1000;
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", JobCodeunitId);
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.SetRange("Job Queue Category Code", JobQueueCategoryLbl);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.SetFilter("Earliest Start Date/Time", '<=%1', StartTime);
        if not JobQueueEntry.IsEmpty() then begin
            JobQueueEntry.DeleteTasks();
            Commit();
        end;

        JobQueueEntry.Init();
        Clear(JobQueueEntry.ID); // "Job Queue - Enqueue" is to define new ID
        JobQueueEntry."Earliest Start Date/Time" := StartTime;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := JobCodeunitId;
        JobQueueEntry."Record ID to Process" := IntegrationTableMapping.RecordId();
        JobQueueEntry."Run in User Session" := false;
        JobQueueEntry."Notify On Success" := false;
        JobQueueEntry."Maximum No. of Attempts to Run" := 2;
        JobQueueEntry."Job Queue Category Code" := JobQueueCategoryLbl;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Rerun Delay (sec.)" := 30;
        JobQueueEntry.Description := CopyStr(JobDescription, 1, MaxStrLen(JobQueueEntry.Description));
        OnCreateJobQueueEntryOnBeforeJobQueueEnqueue(JobQueueEntry, IntegrationTableMapping, JobCodeunitId, JobDescription);
        exit(Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry))
    end;

    local procedure RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping: Record "Integration Table Mapping"; IntervalInMinutes: Integer; ShouldRecreateJobQueueEntry: Boolean; InactivityTimeoutPeriod: Integer)
    begin
        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, IntervalInMinutes, ShouldRecreateJobQueueEntry, InactivityTimeoutPeriod, CRMProductName.CDSServiceName(), false);
    end;

    internal procedure RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping: Record "Integration Table Mapping"; IntervalInMinutes: Integer; ShouldRecreateJobQueueEntry: Boolean; InactivityTimeoutPeriod: Integer; ServiceName: Text; IsOption: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.DeleteTasks();

        JobQueueEntry.InitRecurringJob(IntervalInMinutes);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Integration Synch. Job Runner";
        JobQueueEntry."Record ID to Process" := IntegrationTableMapping.RecordId();
        JobQueueEntry."Run in User Session" := false;
        JobQueueEntry.Description :=
          CopyStr(StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.Name, ServiceName), 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."Maximum No. of Attempts to Run" := 10;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Rerun Delay (sec.)" := 30;
        JobQueueEntry."Inactivity Timeout Period" := InactivityTimeoutPeriod;
        if IsOption then
            JobQueueEntry."Job Queue Category Code" := OptionJobQueueCategoryLbl;
        if ShouldRecreateJobQueueEntry then
            Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry)
        else
            JobQueueEntry.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Setup Defaults", 'OnGetCDSTableNo', '', false, false)]
    local procedure ReturnProxyTableNoOnGetCDSTableNo(BCTableNo: Integer; var CDSTableNo: Integer; var Handled: Boolean)
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        if Handled then
            exit;

        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        case BCTableNo of
            Database::"Sust. ESG Standard":
                CDSTableNo := Database::"Sust. Standard";
            Database::"Sust. ESG Reporting Unit":
                CDSTableNo := Database::"Sust. Unit";
            Database::"Sust. ESG Reporting Name":
                CDSTableNo := Database::"Sust. Assessment";
            Database::"Sust. ESG Reporting Line":
                CDSTableNo := Database::"Sust. Assessment Requirement";
            Database::"Sust. Posted ESG Report Line":
                CDSTableNo := Database::"Sust. ESG Fact";
        end;

        if CDSTableNo <> 0 then
            Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Setup Defaults", 'OnAddEntityTableMapping', '', false, false)]
    local procedure AddProxyTablesOnAddEntityTableMapping(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        SustainabilitySetup: Record "Sustainability Setup";
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
    begin
        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        CRMSetupDefaults.AddEntityTableMapping('msdyn_standard', Database::"Sust. ESG Standard", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_standard', Database::"Sust. Standard", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_unit', Database::"Sust. ESG Reporting Unit", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_unit', Database::"Sust. Unit", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_assessment', Database::"Sust. ESG Reporting Name", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_assessment', Database::"Sust. Assessment", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_assessmentrequirement', Database::"Sust. ESG Reporting Line", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_assessmentrequirement', Database::"Sust. Assessment Requirement", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_esgfact', Database::"Sust. Posted ESG Report Line", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_esgfact', Database::"Sust. ESG Fact", TempNameValueBuffer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Setup Defaults", 'OnBeforeGetNameFieldNo', '', false, false)]
    local procedure ReturnNameFieldNoOnBeforeGetNameFieldNo(TableId: Integer; var FieldNo: Integer)
    var
        Assessment: Record "Sust. Assessment";
        ESGStandard: Record "Sust. ESG Standard";
        Standard: Record "Sust. Standard";
        Unit: Record "Sust. Unit";
        ReportingUnit: Record "Sust. ESG Reporting Unit";
        RangePeriod: Record "Sust. Range Period";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        AssessmentRequirement: Record "Sust. Assessment Requirement";
        StandardRequirement: Record "Sust. Standard Requirement";
        RequirementConcept: Record "Sust. Requirement Concept";
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
        ESGFact: Record "Sust. ESG Fact";
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        case TableId of
            Database::"Sust. ESG Reporting Name":
                FieldNo := ESGReportingName.FieldNo(Name);
            Database::"Sust. Assessment":
                FieldNo := Assessment.FieldNo(Name);
            Database::"Sust. ESG Standard":
                FieldNo := ESGStandard.FieldNo("No.");
            Database::"Sust. Standard":
                FieldNo := Standard.FieldNo(Name);
            Database::"Sust. ESG Reporting Unit":
                FieldNo := ReportingUnit.FieldNo(Code);
            Database::"Sust. Unit":
                FieldNo := Unit.FieldNo(Name);
            Database::"Sust. Range Period":
                FieldNo := RangePeriod.FieldNo(Name);
            Database::"Sust. ESG Reporting Line":
                FieldNo := ESGReportingLine.FieldNo("ESG Reporting Name");
            Database::"Sust. Assessment Requirement":
                FieldNo := AssessmentRequirement.FieldNo(Name);
            Database::"Sust. Standard Requirement":
                FieldNo := StandardRequirement.FieldNo(Name);
            Database::"Sust. Requirement Concept":
                FieldNo := RequirementConcept.FieldNo(Name);
            Database::"Sust. Posted ESG Report Line":
                FieldNo := PostedESGReportingLine.FieldNo("Document No.");
            Database::"Sust. ESG Fact":
                FieldNo := ESGFact.FieldNo(Name);
        end;
    end;

    procedure GetDefaultDirection(NAVTableID: Integer): Integer
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        case NAVTableID of
            Database::"Sust. ESG Reporting Name", Database::"Sust. ESG Reporting Line", Database::"Sust. ESG Standard", Database::"Sust. ESG Reporting Unit":
                exit(IntegrationTableMapping.Direction::FromIntegrationTable);
            Database::"Sust. Posted ESG Report Line":
                exit(IntegrationTableMapping.Direction::ToIntegrationTable);
        end;
    end;

    internal procedure GetTableFilterFromView(TableID: Integer; Caption: Text; View: Text): Text
    var
        FilterBuilder: FilterPageBuilder;
    begin
        FilterBuilder.AddTable(Caption, TableID);
        FilterBuilder.SetView(Caption, View);
        exit(FilterBuilder.GetView(Caption, false));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Integration Management", 'OnBeforeHandleCustomIntegrationTableMapping', '', false, false)]
    local procedure OnBeforeHandleCustomIntegrationTableMapping(IntegrationTableMappingName: Code[20]; var IsHandled: Boolean)
    var
        SustainabilitySetup: Record "Sustainability Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        if not IntegrationTableMapping.Get(IntegrationTableMappingName) then
            exit;

        case IntegrationTableMappingName of
            ESGStandardTableMappingNameLbl:
                begin
                    ResetESGStandardMapping(ESGStandardTableMappingNameLbl, true);
                    IsHandled := true;
                end;
            ESGReportingUnitTableMappingNameLbl:
                begin
                    ResetESGReportingUnitMapping(ESGReportingUnitTableMappingNameLbl, true);
                    IsHandled := true;
                end;
            ESGAssessmentTableMappingNameLbl:
                begin
                    ResetESGReportingNameAssessmentMapping(ESGAssessmentTableMappingNameLbl, true);
                    IsHandled := true;
                end;
            ESGAssessmentRequirementTableMappingNameLbl:
                begin
                    ResetESGReportingLineAssessmentRequirementMapping(ESGAssessmentRequirementTableMappingNameLbl, true);
                    IsHandled := true;
                end;
            ESGPostedFactTableMappingNameLbl:
                begin
                    ResetPostedESGReportingLineESGFactMapping(ESGPostedFactTableMappingNameLbl, true);
                    IsHandled := true;
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateJobQueueEntryOnBeforeJobQueueEnqueue(var JobQueueEntry: Record "Job Queue Entry"; var IntegrationTableMapping: Record "Integration Table Mapping"; JobCodeunitId: Integer; JobDescription: Text)
    begin
    end;
}