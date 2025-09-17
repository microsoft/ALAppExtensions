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

codeunit 6276 "Sust. Int. Table Subscriber"
{
    var
        SustainabilitySetup: Record "Sustainability Setup";
        CRMSynchHelper: Codeunit "CRM Synch. Helper";
        DoesNotExistErr: Label '%1 %2 doesn''t exist in %3', Comment = '%1 = a table name, %2 - a guid, %3 = Field Service service name';
        NotCoupledToTableErr: Label 'The %1 %2 is not coupled to a %3.', Comment = '%1 = Table Caption, %2 = primary key value, %3 = Table Caption';
        RecordMustBeCoupledErr: Label '%1 %2 must be coupled to %3.', Comment = '%1 = Table Caption, %2 = primary key value, %3 - service name';
        CannotSynchErr: Label 'Cannot synchronize the %1 %2.', Comment = '%1 = Table Caption, %2 = primary key value';
        IsAlreadySynchedErr: Label '%1 %2 is already synchronized.', Comment = '%1 = Table Caption, %2 = primary key value';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Synch.", 'OnTransferFieldData', '', true, false)]
    local procedure OnTransferFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    begin
        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        if IsValueFound then
            exit;

        if SourceFieldRef.Number() = DestinationFieldRef.Number() then
            if SourceFieldRef.Record().Number() = DestinationFieldRef.Record().Number() then
                exit;

        TransferFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Int. Table. Subscriber", 'OnFindNewValueForCoupledRecordPK', '', true, false)]
    local procedure OnFindNewValueForCoupledRecordPK(IntegrationTableMapping: Record "Integration Table Mapping"; SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean)
    var
        NeedsConversion: Boolean;
    begin
        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        if IsValueFound then
            exit;

        TransferFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeInsertRecord', '', true, false)]
    local procedure HandleOnBeforeInsertRecord(SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        AssessmentRequirement: Record "Sust. Assessment Requirement";
        Standard: Record "Sust. Standard";
        ESGStandard: Record "Sust. ESG Standard";
    begin
        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        if (SourceRecordRef.Number = Database::"Sust. Assessment Requirement") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Reporting Line")
        then begin
            SourceRecordRef.SetTable(AssessmentRequirement);
            DestinationRecordRef.SetTable(ESGReportingLine);

            ESGReportingLine."Line No." :=
                GetLastESGReportingLineNo(ESGReportingLine."ESG Reporting Template Name", ESGReportingLine."ESG Reporting Name") + 10000;

            DestinationRecordRef.GetTable(ESGReportingLine);
        end;

        if (SourceRecordRef.Number = Database::"Sust. Standard") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Standard")
        then begin
            SourceRecordRef.SetTable(Standard);

            ESGStandard.SetRange("Standard ID", Standard.StandardId);
            if not ESGStandard.IsEmpty() then
                Error(IsAlreadySynchedErr, Standard.TableCaption(), Standard.StandardId);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterInsertRecord', '', true, false)]
    local procedure HandleOnAfterInsertRecord(SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        ESGFact: Record "Sust. ESG Fact";
        PostedESGReportLine: Record "Sust. Posted ESG Report Line";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        AssessmentRequirement: Record "Sust. Assessment Requirement";
        RequirementConcept: Record "Sust. Requirement Concept";
        ESGRequirementConcept: Record "Sust. ESG Requirement Concept";
    begin
        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        if (SourceRecordRef.Number = Database::"Sust. Posted ESG Report Line") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Fact")
        then begin
            SourceRecordRef.SetTable(PostedESGReportLine);
            DestinationRecordRef.SetTable(ESGFact);

            InsertAssessmentReqFact(ESGFact, PostedESGReportLine);

            DestinationRecordRef.GetTable(ESGFact);
        end;

        if (SourceRecordRef.Number = Database::"Sust. Requirement Concept") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Requirement Concept")
        then begin
            SourceRecordRef.SetTable(RequirementConcept);
            DestinationRecordRef.SetTable(ESGRequirementConcept);

            SyncESGReportingLineIfRequirementConceptIsModified(ESGRequirementConcept);

            DestinationRecordRef.GetTable(ESGRequirementConcept);
        end;

        if (SourceRecordRef.Number = Database::"Sust. Assessment Requirement") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Reporting Line")
        then begin
            SourceRecordRef.SetTable(AssessmentRequirement);
            DestinationRecordRef.SetTable(ESGReportingLine);

            PopulateESGReportingByConcept(ESGReportingLine);

            DestinationRecordRef.GetTable(ESGReportingLine);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterModifyRecord', '', true, false)]
    local procedure HandleOnAfterModifyRecord(SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        RangePeriod: Record "Sust. Range Period";
        ESGRangePeriod: Record "Sust. ESG Range Period";
        StandardRequirement: Record "Sust. Standard Requirement";
        ESGStandardRequirement: Record "Sust. ESG Standard Requirement";
        RequirementConcept: Record "Sust. Requirement Concept";
        ESGRequirementConcept: Record "Sust. ESG Requirement Concept";
        Concept: Record "Sust. Concept";
        ESGConcept: Record "Sust. ESG Concept";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        AssessmentRequirement: Record "Sust. Assessment Requirement";
    begin
        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        if (SourceRecordRef.Number = Database::"Sust. Range Period") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Range Period")
        then begin
            SourceRecordRef.SetTable(RangePeriod);
            DestinationRecordRef.SetTable(ESGRangePeriod);

            SyncESGReportingNameIfRangePeriodIsModified(ESGRangePeriod);

            DestinationRecordRef.GetTable(ESGRangePeriod);
        end;

        if (SourceRecordRef.Number = Database::"Sust. Standard Requirement") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Standard Requirement")
        then begin
            SourceRecordRef.SetTable(StandardRequirement);
            DestinationRecordRef.SetTable(ESGStandardRequirement);

            SyncESGReportingLineIfStandardRequirementIsModified(ESGStandardRequirement);

            DestinationRecordRef.GetTable(ESGStandardRequirement);
        end;

        if (SourceRecordRef.Number = Database::"Sust. Requirement Concept") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Requirement Concept")
        then begin
            SourceRecordRef.SetTable(RequirementConcept);
            DestinationRecordRef.SetTable(ESGRequirementConcept);

            SyncESGReportingLineIfRequirementConceptIsModified(ESGRequirementConcept);

            DestinationRecordRef.GetTable(ESGRequirementConcept);
        end;

        if (SourceRecordRef.Number = Database::"Sust. Concept") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Concept")
        then begin
            SourceRecordRef.SetTable(Concept);
            DestinationRecordRef.SetTable(ESGConcept);

            SyncESGReportingLineIfConceptIsModified(ESGConcept);

            DestinationRecordRef.GetTable(ESGConcept);
        end;

        if (SourceRecordRef.Number = Database::"Sust. Assessment Requirement") and
           (DestinationRecordRef.Number = Database::"Sust. ESG Reporting Line")
        then begin
            SourceRecordRef.SetTable(AssessmentRequirement);
            DestinationRecordRef.SetTable(ESGReportingLine);

            PopulateESGReportingByConcept(ESGReportingLine);

            DestinationRecordRef.GetTable(ESGReportingLine);
        end;
    end;

    local procedure TransferFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    begin
        if (SourceFieldRef.Record().Number = Database::"Sust. Unit") and (DestinationFieldRef.Record().Number = Database::"Sust. ESG Reporting Unit") then
            TransferUnitFieldData(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);

        if (SourceFieldRef.Record().Number = Database::"Sust. ESG Reporting Unit") and (DestinationFieldRef.Record().Number = Database::"Sust. Unit") then
            TransferESGReportingUnitFieldData(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);

        if (SourceFieldRef.Record().Number = Database::"Sust. Assessment") and (DestinationFieldRef.Record().Number = Database::"Sust. ESG Reporting Name") then
            TransferAssessmentFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);

        if (SourceFieldRef.Record().Number = Database::"Sust. ESG Reporting Name") and (DestinationFieldRef.Record().Number = Database::"Sust. Assessment") then
            TransferESGReportingNameFieldData(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);

        if (SourceFieldRef.Record().Number = Database::"Sust. Standard Requirement") and (DestinationFieldRef.Record().Number = Database::"Sust. ESG Standard Requirement") then
            TransferStandardRequirementFieldData(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);

        if (SourceFieldRef.Record().Number = Database::"Sust. Requirement Concept") and (DestinationFieldRef.Record().Number = Database::"Sust. ESG Requirement Concept") then
            TransferRequirementConceptFieldData(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);

        if (SourceFieldRef.Record().Number = Database::"Sust. Assessment Requirement") and (DestinationFieldRef.Record().Number = Database::"Sust. ESG Reporting Line") then
            TransferAssessmentRequirementFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);

        if (SourceFieldRef.Record().Number = Database::"Sust. ESG Reporting Line") and (DestinationFieldRef.Record().Number = Database::"Sust. Assessment Requirement") then
            TransferESGReportingLineFieldData(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);

        if (SourceFieldRef.Record().Number = Database::"Sust. Posted ESG Report Line") and (DestinationFieldRef.Record().Number = Database::"Sust. ESG Fact") then
            TransferPostedESGReportLineFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
    end;

    local procedure TransferUnitFieldData(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        Unit: Record "Sust. Unit";
    begin
        if IsValueFound then
            exit;

        case SourceFieldRef.Name() of
            Unit.FieldName(BaseUnit):
                TransferBaseUnitFieldDataFromUnit(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferBaseUnitFieldDataFromUnit(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        ESGReportingUnit: Record "Sust. ESG Reporting Unit";
        Unit: Record "Sust. Unit";
        CRMIntegrationRecord: Record "CRM Integration Record";
        SourceRecordRef: RecordRef;
        NAVReportingUnitRecordId: RecordId;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(Unit);

        NewValue := '';
        if not IsNullGuid(Unit.BaseUnit) then begin
            if not CRMIntegrationRecord.FindRecordIDFromID(Unit.BaseUnit, Database::"Sust. ESG Reporting Unit", NAVReportingUnitRecordId) then
                if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Reporting Unit", Database::"Sust. Unit", Unit.BaseUnit) then
                    Error(CannotSynchErr, Unit.TableCaption(), Unit.BaseUnit)
                else
                    if not CRMIntegrationRecord.FindRecordIDFromID(Unit.BaseUnit, Database::"Sust. ESG Reporting Unit", NAVReportingUnitRecordId) then
                        Error(RecordMustBeCoupledErr, Unit.TableCaption(), Format(Unit.BaseUnit), ESGReportingUnit.TableCaption());

            if not ESGReportingUnit.Get(NAVReportingUnitRecordId) then
                Error(NotCoupledToTableErr, ESGReportingUnit.TableCaption(), Format(NAVReportingUnitRecordId), Unit.TableCaption());
        end;

        NewValue := ESGReportingUnit.Code;
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferESGReportingUnitFieldData(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        ESGReportingUnit: Record "Sust. ESG Reporting Unit";
    begin
        if IsValueFound then
            exit;

        if SourceFieldRef.Name() = ESGReportingUnit.FieldName("Base Reporting Unit Code") then
            TransferBaseReportingUnitFieldDataFromESGReportingUnit(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
    end;

    local procedure TransferBaseReportingUnitFieldDataFromESGReportingUnit(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        Unit: Record "Sust. Unit";
        ESGReportingUnit: Record "Sust. ESG Reporting Unit";
        SourceRecordRef: RecordRef;
        EmptyGuid: Guid;
        ReportingUnitId: Guid;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(ESGReportingUnit);

        NewValue := EmptyGuid;
        if ESGReportingUnit."Base Reporting Unit Code" <> '' then begin
            if not CRMIntegrationRecord.FindIDFromRecordID(GetReportingUnitRecordId(ESGReportingUnit."Base Reporting Unit Code"), ReportingUnitId) then
                Error(RecordMustBeCoupledErr, ESGReportingUnit.TableCaption(), ESGReportingUnit."Base Reporting Unit Code", Unit.TableCaption());

            if not Unit.Get(ReportingUnitId) then
                Error(NotCoupledToTableErr, Unit.TableCaption(), Format(ReportingUnitId), ESGReportingUnit.TableCaption());
        end;

        NewValue := Unit.UnitId;
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferAssessmentFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        Assessment: Record "Sust. Assessment";
    begin
        if IsValueFound then
            exit;

        case SourceFieldRef.Name() of
            Assessment.FieldName(Standard):
                TransferStandardFieldDataFromAssessment(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
            Assessment.FieldName(Period):
                TransferPeriodFieldDataFromAssessment(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferStandardFieldDataFromAssessment(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        Standard: Record "Sust. Standard";
        ESGStandard: Record "Sust. ESG Standard";
        Assessment: Record "Sust. Assessment";
        CRMIntegrationRecord: Record "CRM Integration Record";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        SourceRecordRef: RecordRef;
        NAVStandardRecordId: RecordId;
    begin
        if DestinationFieldRef.Name <> ESGReportingName.FieldName(Standard) then
            exit;

        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(Assessment);

        NewValue := '';
        if not IsNullGuid(Assessment.Standard) then begin
            if not CRMIntegrationRecord.FindRecordIDFromID(Assessment.Standard, Database::"Sust. ESG Standard", NAVStandardRecordId) then
                if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Standard", Database::"Sust. Standard", Assessment.Standard) then
                    Error(CannotSynchErr, Standard.TableCaption(), Assessment.Standard)
                else
                    if not CRMIntegrationRecord.FindRecordIDFromID(Assessment.Standard, Database::"Sust. ESG Standard", NAVStandardRecordId) then
                        Error(RecordMustBeCoupledErr, Standard.TableCaption(), Format(Assessment.Standard), ESGStandard.TableCaption());

            if not ESGStandard.Get(NAVStandardRecordId) then
                Error(NotCoupledToTableErr, ESGStandard.TableCaption(), Format(NAVStandardRecordId), Standard.TableCaption());
        end;

        NewValue := ESGStandard."No.";
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferPeriodFieldDataFromAssessment(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        Assessment: Record "Sust. Assessment";
        RangePeriod: Record "Sust. Range Period";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        SourceRecordRef: RecordRef;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(Assessment);

        case DestinationFieldRef.Name of
            ESGReportingName.FieldName("Period Name"):
                NewValue := '';
            ESGReportingName.FieldName("Period Starting Date"):
                NewValue := 0D;
            ESGReportingName.FieldName("Period Ending Date"):
                NewValue := 0D;
            else
                exit;
        end;

        if not IsNullGuid(Assessment.Period) then
            if not RangePeriod.Get(Assessment.Period) then
                Error(DoesNotExistErr, Assessment.FieldCaption(Period), Format(Assessment.Period), RangePeriod.TableCaption())
            else
                case DestinationFieldRef.Name of
                    ESGReportingName.FieldName("Period Name"):
                        NewValue := RangePeriod.Name;
                    ESGReportingName.FieldName("Period Starting Date"):
                        NewValue := RangePeriod.From;
                    ESGReportingName.FieldName("Period Ending Date"):
                        NewValue := RangePeriod."To";
                end;

        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferESGReportingNameFieldData(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        ESGReportingName: Record "Sust. ESG Reporting Name";
    begin
        if IsValueFound then
            exit;

        case SourceFieldRef.Name() of
            ESGReportingName.FieldName(Standard):
                TransferStandardFieldDataFromESGReportingName(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
            ESGReportingName.FieldName("Period Name"):
                TransferPeriodFieldDataFromESGReportingName(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferStandardFieldDataFromESGReportingName(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGStandard: Record "Sust. ESG Standard";
        Standard: Record "Sust. Standard";
        SourceRecordRef: RecordRef;
        EmptyGuid: Guid;
        StandardId: Guid;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(ESGReportingName);

        NewValue := EmptyGuid;
        if ESGReportingName.Standard <> '' then begin
            if not CRMIntegrationRecord.FindIDFromRecordID(GetStandardRecordId(ESGReportingName.Standard), StandardId) then
                Error(RecordMustBeCoupledErr, ESGStandard.TableCaption(), ESGReportingName.Standard, Standard.TableCaption());

            if not Standard.Get(StandardId) then
                Error(NotCoupledToTableErr, Standard.TableCaption(), Format(StandardId), ESGStandard.TableCaption());
        end;

        NewValue := Standard.StandardId;
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferPeriodFieldDataFromESGReportingName(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        RangePeriod: Record "Sust. Range Period";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        SourceRecordRef: RecordRef;
        EmptyGuid: Guid;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(ESGReportingName);

        NewValue := EmptyGuid;
        if ESGReportingName."Period Name" <> '' then begin
            RangePeriod.SetRange(Name, ESGReportingName."Period Name");
            if not RangePeriod.FindFirst() then
                Error(DoesNotExistErr, ESGReportingName.FieldCaption("Period Name"), Format(ESGReportingName."Period Name"), RangePeriod.TableCaption());
        end;

        NewValue := RangePeriod.RangePeriodId;
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferStandardRequirementFieldData(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        StandardRequirement: Record "Sust. Standard Requirement";
    begin
        if IsValueFound then
            exit;

        case SourceFieldRef.Name() of
            StandardRequirement.FieldName(ParentStdRequirementId):
                TransferParentStandardRequirementFieldData(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferParentStandardRequirementFieldData(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        ESGStandardRequirement: Record "Sust. ESG Standard Requirement";
        StandardRequirement: Record "Sust. Standard Requirement";
        CRMIntegrationRecord: Record "CRM Integration Record";
        SourceRecordRef: RecordRef;
        NAVStdRequirementRecordId: RecordId;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(StandardRequirement);

        NewValue := '';
        if not IsNullGuid(StandardRequirement.ParentStdRequirementId) then begin
            if not CRMIntegrationRecord.FindRecordIDFromID(StandardRequirement.ParentStdRequirementId, Database::"Sust. ESG Standard Requirement", NAVStdRequirementRecordId) then
                if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Standard Requirement", Database::"Sust. Standard Requirement", StandardRequirement.ParentStdRequirementId) then
                    Error(CannotSynchErr, StandardRequirement.TableCaption(), StandardRequirement.ParentStdRequirementId)
                else
                    if not CRMIntegrationRecord.FindRecordIDFromID(StandardRequirement.ParentStdRequirementId, Database::"Sust. ESG Standard Requirement", NAVStdRequirementRecordId) then
                        Error(RecordMustBeCoupledErr, StandardRequirement.TableCaption(), Format(StandardRequirement.ParentStdRequirementId), ESGStandardRequirement.TableCaption());

            if not ESGStandardRequirement.Get(NAVStdRequirementRecordId) then
                Error(NotCoupledToTableErr, ESGStandardRequirement.TableCaption(), Format(NAVStdRequirementRecordId), StandardRequirement.TableCaption());
        end;

        NewValue := ESGStandardRequirement."No.";
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferRequirementConceptFieldData(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        RequirementConcept: Record "Sust. Requirement Concept";
    begin
        if IsValueFound then
            exit;

        case SourceFieldRef.Name() of
            RequirementConcept.FieldName(StandardRequirement):
                TransferStandardRequirementFieldDataFromRequirementConcept(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
            RequirementConcept.FieldName(ConceptId):
                TransferConceptFieldDataFromRequirementConcept(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferStandardRequirementFieldDataFromRequirementConcept(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        ESGStandardRequirement: Record "Sust. ESG Standard Requirement";
        StandardRequirement: Record "Sust. Standard Requirement";
        RequirementConcept: Record "Sust. Requirement Concept";
        CRMIntegrationRecord: Record "CRM Integration Record";
        SourceRecordRef: RecordRef;
        NAVStdRequirementRecordId: RecordId;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(RequirementConcept);

        NewValue := '';
        if not IsNullGuid(RequirementConcept.StandardRequirement) then begin
            if not CRMIntegrationRecord.FindRecordIDFromID(RequirementConcept.StandardRequirement, Database::"Sust. ESG Standard Requirement", NAVStdRequirementRecordId) then
                if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Standard Requirement", Database::"Sust. Standard Requirement", RequirementConcept.StandardRequirement) then
                    Error(CannotSynchErr, StandardRequirement.TableCaption(), RequirementConcept.StandardRequirement)
                else
                    if not CRMIntegrationRecord.FindRecordIDFromID(RequirementConcept.StandardRequirement, Database::"Sust. ESG Standard Requirement", NAVStdRequirementRecordId) then
                        Error(RecordMustBeCoupledErr, StandardRequirement.TableCaption(), Format(RequirementConcept.StandardRequirement), ESGStandardRequirement.TableCaption());

            if not ESGStandardRequirement.Get(NAVStdRequirementRecordId) then
                Error(NotCoupledToTableErr, ESGStandardRequirement.TableCaption(), Format(NAVStdRequirementRecordId), StandardRequirement.TableCaption());

            NewValue := ESGStandardRequirement."No.";
            IsValueFound := true;
            NeedsConversion := false;
        end;
    end;

    local procedure TransferConceptFieldDataFromRequirementConcept(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        ESGConcept: Record "Sust. ESG Concept";
        Concept: Record "Sust. Concept";
        RequirementConcept: Record "Sust. Requirement Concept";
        CRMIntegrationRecord: Record "CRM Integration Record";
        SourceRecordRef: RecordRef;
        NAVConceptRecordId: RecordId;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(RequirementConcept);

        NewValue := '';
        if not IsNullGuid(RequirementConcept.ConceptId) then begin
            if not CRMIntegrationRecord.FindRecordIDFromID(RequirementConcept.ConceptId, Database::"Sust. ESG Concept", NAVConceptRecordId) then
                if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Concept", Database::"Sust. Concept", RequirementConcept.ConceptId) then
                    Error(CannotSynchErr, Concept.TableCaption(), RequirementConcept.ConceptId)
                else
                    if not CRMIntegrationRecord.FindRecordIDFromID(RequirementConcept.ConceptId, Database::"Sust. ESG Concept", NAVConceptRecordId) then
                        Error(RecordMustBeCoupledErr, Concept.TableCaption(), Format(RequirementConcept.ConceptId), ESGConcept.TableCaption());

            if not ESGConcept.Get(NAVConceptRecordId) then
                Error(NotCoupledToTableErr, ESGConcept.TableCaption(), Format(NAVConceptRecordId), Concept.TableCaption());

            NewValue := ESGConcept."No.";
            IsValueFound := true;
            NeedsConversion := false;
        end;
    end;

    local procedure TransferESGReportingLineFieldData(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        if IsValueFound then
            exit;

        case SourceFieldRef.Name() of
            ESGReportingLine.FieldName("ESG Reporting Name"):
                TransferESGReportingNameFieldDataFromESGReportingLine(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
            ESGReportingLine.FieldName(Grouping):
                TransferGroupingFieldDataFromESGReportingLine(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferESGReportingNameFieldDataFromESGReportingLine(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        Assessment: Record "Sust. Assessment";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        SourceRecordRef: RecordRef;
        EmptyGuid: Guid;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(ESGReportingLine);

        NewValue := EmptyGuid;
        if ESGReportingLine."ESG Reporting Name" <> '' then begin
            Assessment.SetRange(Name, ESGReportingLine."ESG Reporting Name");
            if not Assessment.FindFirst() then
                Error(DoesNotExistErr, ESGReportingLine.FieldCaption("ESG Reporting Name"), ESGReportingLine."ESG Reporting Name", Assessment.TableCaption());
        end;

        NewValue := Assessment.AssessmentId;
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferGroupingFieldDataFromESGReportingLine(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        StandardRequirement: Record "Sust. Standard Requirement";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        SourceRecordRef: RecordRef;
        EmptyGuid: Guid;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(ESGReportingLine);

        NewValue := EmptyGuid;
        if ESGReportingLine.Grouping <> '' then begin
            StandardRequirement.SetRange(ParentStdRequirementIdName, ESGReportingLine.Grouping);
            if not StandardRequirement.FindFirst() then
                Error(DoesNotExistErr, ESGReportingLine.FieldCaption(Grouping), Format(ESGReportingLine.Grouping), StandardRequirement.TableCaption());
        end;

        NewValue := StandardRequirement.StandardRequirementId;
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferAssessmentRequirementFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        AssessmentRequirement: Record "Sust. Assessment Requirement";
    begin
        if IsValueFound then
            exit;

        case SourceFieldRef.Name() of
            AssessmentRequirement.FieldName(Assessment):
                TransferAssessmentFieldDataFromAssessmentRequirement(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
            AssessmentRequirement.FieldName(StandardRequirement):
                TransferStandardRequirementFieldDataFromAssessmentRequirement(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferAssessmentFieldDataFromAssessmentRequirement(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        Assessment: Record "Sust. Assessment";
        AssessmentRequirement: Record "Sust. Assessment Requirement";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        CRMIntegrationRecord: Record "CRM Integration Record";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        SourceRecordRef: RecordRef;
        NAVReportingNameRecordId: RecordId;
    begin
        if DestinationFieldRef.Name <> ESGReportingLine.FieldName("ESG Reporting Name") then
            exit;

        NewValue := '';
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(AssessmentRequirement);
        if not IsNullGuid(AssessmentRequirement.Assessment) then begin
            if not CRMIntegrationRecord.FindRecordIDFromID(AssessmentRequirement.Assessment, Database::"Sust. ESG Reporting Name", NAVReportingNameRecordId) then
                if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Reporting Name", Database::"Sust. Assessment", AssessmentRequirement.Assessment) then
                    Error(CannotSynchErr, Assessment.TableCaption(), AssessmentRequirement.Assessment)
                else
                    if not CRMIntegrationRecord.FindRecordIDFromID(AssessmentRequirement.Assessment, Database::"Sust. ESG Reporting Name", NAVReportingNameRecordId) then
                        Error(RecordMustBeCoupledErr, Assessment.TableCaption(), Format(AssessmentRequirement.Assessment), ESGReportingName.TableCaption());

            if not ESGReportingName.Get(NAVReportingNameRecordId) then
                Error(NotCoupledToTableErr, ESGReportingName.TableCaption(), Format(NAVReportingNameRecordId), Assessment.TableCaption());
        end;

        NewValue := ESGReportingName.Name;
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferStandardRequirementFieldDataFromAssessmentRequirement(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        AssessmentRequirement: Record "Sust. Assessment Requirement";
        StandardRequirement: Record "Sust. Standard Requirement";
        ESGStandardRequirement: Record "Sust. ESG Standard Requirement";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        CRMIntegrationRecord: Record "CRM Integration Record";
        SourceRecordRef: RecordRef;
        NAVStdRequirementRecordId: RecordId;
    begin
        if DestinationFieldRef.Name = ESGReportingLine.FieldName("Standard Requirement ID") then
            exit;

        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(AssessmentRequirement);

        if not IsNullGuid(AssessmentRequirement.StandardRequirement) then begin
            if not CRMIntegrationRecord.FindRecordIDFromID(AssessmentRequirement.StandardRequirement, Database::"Sust. ESG Standard Requirement", NAVStdRequirementRecordId) then
                if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Standard Requirement", Database::"Sust. Standard Requirement", AssessmentRequirement.StandardRequirement) then
                    Error(CannotSynchErr, StandardRequirement.TableCaption(), AssessmentRequirement.StandardRequirement)
                else
                    if not CRMIntegrationRecord.FindRecordIDFromID(AssessmentRequirement.StandardRequirement, Database::"Sust. ESG Standard Requirement", NAVStdRequirementRecordId) then
                        Error(RecordMustBeCoupledErr, StandardRequirement.TableCaption(), Format(AssessmentRequirement.StandardRequirement), ESGStandardRequirement.TableCaption());

            if not ESGStandardRequirement.Get(NAVStdRequirementRecordId) then
                Error(NotCoupledToTableErr, ESGStandardRequirement.TableCaption(), Format(NAVStdRequirementRecordId), StandardRequirement.TableCaption());

            TransferStandardRequirementFieldDataFromAssessmentRequirement(AssessmentRequirement, ESGStandardRequirement, DestinationFieldRef, NewValue);
            IsValueFound := true;
            NeedsConversion := false;
        end;
    end;

    local procedure TransferStandardRequirementFieldDataFromAssessmentRequirement(AssessmentRequirement: Record "Sust. Assessment Requirement"; ESGStandardRequirement: Record "Sust. ESG Standard Requirement"; DestinationFieldRef: FieldRef; var NewValue: Variant)
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        RequirementConcept: Record "Sust. Requirement Concept";
        CRMIntegrationRecord: Record "CRM Integration Record";
        StandardRequirement: Record "Sust. Standard Requirement";
        ESGParentStandardRequirement: Record "Sust. ESG Standard Requirement";
        ESGRequirementConcept: Record "Sust. ESG Requirement Concept";
        Concept: Record "Sust. Concept";
        ESGConcept: Record "Sust. ESG Concept";
        NAVStdRequirementRecordId: RecordId;
        NAVRequirementConceptRecordId: RecordId;
        NAVConceptRecordId: RecordId;
        EmptyGuid: Guid;
    begin
        case DestinationFieldRef.Name of
            ESGReportingLine.FieldName(Description):
                NewValue := ESGStandardRequirement.Description;
            ESGReportingLine.FieldName(Grouping):
                begin
                    NewValue := '';
                    if not IsNullGuid(ESGStandardRequirement."Parent Std. Requirement ID") then begin
                        if not CRMIntegrationRecord.FindRecordIDFromID(ESGStandardRequirement."Parent Std. Requirement ID", Database::"Sust. ESG Standard Requirement", NAVStdRequirementRecordId) then
                            if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Standard Requirement", Database::"Sust. Standard Requirement", ESGStandardRequirement."Parent Std. Requirement ID") then
                                Error(CannotSynchErr, StandardRequirement.TableCaption(), ESGStandardRequirement."Parent Std. Requirement ID")
                            else
                                if not CRMIntegrationRecord.FindRecordIDFromID(ESGStandardRequirement."Parent Std. Requirement ID", Database::"Sust. ESG Standard Requirement", NAVStdRequirementRecordId) then
                                    Error(RecordMustBeCoupledErr, StandardRequirement.TableCaption(), Format(ESGStandardRequirement."Parent Std. Requirement ID"), ESGStandardRequirement.TableCaption());

                        if not ESGParentStandardRequirement.Get(NAVStdRequirementRecordId) then
                            Error(NotCoupledToTableErr, ESGParentStandardRequirement.TableCaption(), Format(NAVStdRequirementRecordId), StandardRequirement.TableCaption());

                        NewValue := CopyStr(ESGParentStandardRequirement.Name, 1, 100);
                    end;
                end;
            ESGReportingLine.FieldName("Concept Link"):
                begin
                    NewValue := '';

                    DestinationFieldRef.Record().SetTable(ESGReportingLine);
                    if not IsNullGuid(ESGReportingLine."Requirement Concept ID") then begin
                        if not CRMIntegrationRecord.FindRecordIDFromID(ESGReportingLine."Requirement Concept ID", Database::"Sust. ESG Requirement Concept", NAVRequirementConceptRecordId) then
                            if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Requirement Concept", Database::"Sust. Requirement Concept", ESGReportingLine."Requirement Concept ID") then
                                Error(CannotSynchErr, RequirementConcept.TableCaption(), ESGReportingLine."Requirement Concept ID")
                            else
                                if not CRMIntegrationRecord.FindRecordIDFromID(ESGReportingLine."Requirement Concept ID", Database::"Sust. ESG Requirement Concept", NAVRequirementConceptRecordId) then
                                    Error(RecordMustBeCoupledErr, RequirementConcept.TableCaption(), Format(ESGReportingLine."Requirement Concept ID"), ESGRequirementConcept.TableCaption());

                        if not ESGRequirementConcept.Get(NAVRequirementConceptRecordId) then
                            Error(NotCoupledToTableErr, ESGRequirementConcept.TableCaption(), Format(NAVRequirementConceptRecordId), RequirementConcept.TableCaption());

                        NewValue := ESGRequirementConcept.Description;
                    end;
                end;
            ESGReportingLine.FieldName(Concept):
                begin
                    NewValue := '';

                    DestinationFieldRef.Record().SetTable(ESGReportingLine);
                    if not IsNullGuid(ESGReportingLine."Concept ID") then begin
                        if not CRMIntegrationRecord.FindRecordIDFromID(ESGReportingLine."Concept ID", Database::"Sust. ESG Concept", NAVConceptRecordId) then
                            if not CRMSynchHelper.SynchRecordIfMappingExists(Database::"Sust. ESG Concept", Database::"Sust. Concept", ESGReportingLine."Concept ID") then
                                Error(CannotSynchErr, Concept.TableCaption(), ESGReportingLine."Concept ID")
                            else
                                if not CRMIntegrationRecord.FindRecordIDFromID(ESGReportingLine."Concept ID", Database::"Sust. ESG Concept", NAVConceptRecordId) then
                                    Error(RecordMustBeCoupledErr, Concept.TableCaption(), Format(ESGReportingLine."Concept ID"), ESGConcept.TableCaption());

                        if not ESGConcept.Get(NAVConceptRecordId) then
                            Error(NotCoupledToTableErr, ESGConcept.TableCaption(), Format(NAVConceptRecordId), Concept.TableCaption());

                        NewValue := ESGConcept.Description;
                    end;
                end;
            ESGReportingLine.FieldName("Requirement Concept ID"):
                begin
                    NewValue := EmptyGuid;

                    RequirementConcept.SetRange(StandardRequirement, AssessmentRequirement.StandardRequirement);
                    if RequirementConcept.FindFirst() then
                        NewValue := RequirementConcept.RequirementConceptId;
                end;
            ESGReportingLine.FieldName("Concept ID"):
                begin
                    NewValue := EmptyGuid;

                    RequirementConcept.SetRange(StandardRequirement, AssessmentRequirement.StandardRequirement);
                    if RequirementConcept.FindFirst() then
                        NewValue := RequirementConcept.ConceptId;
                end;
            ESGReportingLine.FieldName("Parent Standard Requirement ID"):
                NewValue := StandardRequirement.ParentStdRequirementId;
        end;
    end;

    local procedure TransferPostedESGReportLineFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
    begin
        if IsValueFound then
            exit;

        case SourceFieldRef.Name() of
            PostedESGReportingLine.FieldName("Document No."):
                TransferDocumentNoFieldDataFromPostedESGReportLine(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
            PostedESGReportingLine.FieldName("Date Filter"):
                TransferDateFilterDataFromPostedESGReportLine(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
            PostedESGReportingLine.FieldName("Posted Amount"):
                TransferPostedAmountDataFromPostedESGReportLine(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
            PostedESGReportingLine.FieldName("Reporting Unit"):
                TransferReportingUnitDataFromPostedESGReportLine(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferDocumentNoFieldDataFromPostedESGReportLine(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
        SourceRecordRef: RecordRef;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(PostedESGReportingLine);

        NewValue := CopyStr(PostedESGReportingLine."Document No." + ' - ' + CopyStr(PostedESGReportingLine.Description, 1, 300) + '-' + CopyStr(PostedESGReportingLine.Concept, 1, 150), 1, DestinationFieldRef.Length());
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferDateFilterDataFromPostedESGReportLine(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        PostedESGReportingHeader: Record "Sust. Posted ESG Report Header";
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
        SourceRecordRef: RecordRef;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(PostedESGReportingLine);
        PostedESGReportingHeader.Get(PostedESGReportingLine."Document No.");

        NewValue := PostedESGReportingHeader."Range Period ID";
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferPostedAmountDataFromPostedESGReportLine(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        ESGFact: Record "Sust. ESG Fact";
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
        SourceRecordRef: RecordRef;
    begin
        if DestinationFieldRef.Name() <> ESGFact.FieldName(Precision) then
            exit;

        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(PostedESGReportingLine);

        NewValue := CountDecimalPlaces(PostedESGReportingLine."Posted Amount");
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferReportingUnitDataFromPostedESGReportLine(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        Unit: Record "Sust. Unit";
        ESGReportingUnit: Record "Sust. ESG Reporting Unit";
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
        SourceRecordRef: RecordRef;
        EmptyGuid: Guid;
        ReportingUnitId: Guid;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(PostedESGReportingLine);

        NewValue := EmptyGuid;
        if PostedESGReportingLine."Reporting Unit" <> '' then begin
            if not CRMIntegrationRecord.FindIDFromRecordID(GetReportingUnitRecordId(PostedESGReportingLine."Reporting Unit"), ReportingUnitId) then
                Error(RecordMustBeCoupledErr, ESGReportingUnit.TableCaption(), PostedESGReportingLine."Reporting Unit", Unit.TableCaption());

            if not Unit.Get(ReportingUnitId) then
                Error(NotCoupledToTableErr, Unit.TableCaption(), Format(ReportingUnitId), ESGReportingUnit.TableCaption());
        end;

        NewValue := Unit.UnitId;
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure InsertAssessmentReqFact(ESGFact: Record "Sust. ESG Fact"; PostedESGReportLine: Record "Sust. Posted ESG Report Line")
    var
        AssessmentReqFact: Record "Sust. Assessment Req. Fact";
    begin
        AssessmentReqFact.Init();
        AssessmentReqFact.Name := ESGFact.Name;
        AssessmentReqFact.AssessmentRequirement := PostedESGReportLine."Assessment Requirement ID";
        AssessmentReqFact.RequirementConcept := PostedESGReportLine."Requirement Concept ID";
        AssessmentReqFact."Esg Fact" := ESGFact.ESGFactId;
        AssessmentReqFact.Insert();
    end;

    local procedure GetLastESGReportingLineNo(ESGReportingTemplateName: Code[10]; ESGReportingName: Code[10]): Integer
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        ESGReportingLine.SetRange("ESG Reporting Template Name", ESGReportingTemplateName);
        ESGReportingLine.SetRange("ESG Reporting Name", ESGReportingName);
        if ESGReportingLine.FindLast() then
            exit(ESGReportingLine."Line No.");
    end;

    local procedure CountDecimalPlaces(Amount: Decimal): Integer
    var
        DecimalPosition: Integer;
    begin
        DecimalPosition := StrPos(Format(Amount), '.');
        if DecimalPosition = 0 then
            exit(0);

        if DecimalPosition > 0 then
            exit(StrLen(DelStr(Format(Amount), 1, DecimalPosition)))
    end;

    local procedure GetStandardRecordId(No: Code[20]): RecordId
    var
        ESGStandard: Record "Sust. ESG Standard";
    begin
        if ESGStandard.Get(No) then
            exit(ESGStandard.RecordId);
    end;

    local procedure GetReportingUnitRecordId(No: Code[20]): RecordId
    var
        ESGReportingUnit: Record "Sust. ESG Reporting Unit";
    begin
        if ESGReportingUnit.Get(No) then
            exit(ESGReportingUnit.RecordId());
    end;

    local procedure SyncESGReportingNameIfRangePeriodIsModified(ESGRangePeriod: Record "Sust. ESG Range Period")
    var
        CRMAssessment: Record "Sust. Assessment";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        AssessmentRecordRef: RecordRef;
    begin
        if IsNullGuid(ESGRangePeriod."Range Period ID") then
            exit;

        CRMAssessment.SetRange(StateCode, CRMAssessment.StateCode::Active);
        CRMAssessment.SetRange(Period, ESGRangePeriod."Range Period ID");
        AssessmentRecordRef.GetTable(CRMAssessment);
        if AssessmentRecordRef.Count > 0 then
            CRMIntegrationTableSynch.SynchRecordsFromIntegrationTable(AssessmentRecordRef, Database::"Sust. ESG Reporting Name", true, false);
    end;

    local procedure SyncESGReportingLineIfStandardRequirementIsModified(ESGStandardRequirement: Record "Sust. ESG Standard Requirement")
    var
        CRMAssessmentRequirement: Record "Sust. Assessment Requirement";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        AssessmentRequirementRecordRef: RecordRef;
        AssessmentRequirementId: Guid;
        AssessmentRequirementIdList: List of [Guid];
        AssessmentRequirementIdFilter: Text;
    begin
        if IsNullGuid(ESGStandardRequirement."Standard Requirement ID") then
            exit;

        ESGReportingLine.SetRange("Standard Requirement ID", ESGStandardRequirement."Standard Requirement ID");
        if ESGReportingLine.FindSet() then
            repeat
                if not IsNullGuid(ESGReportingLine."Assessment Requirement ID") then
                    AssessmentRequirementIdList.Add(ESGReportingLine."Assessment Requirement ID");
            until ESGReportingLine.Next() = 0;

        if AssessmentRequirementIdList.Count = 0 then
            exit;

        foreach AssessmentRequirementId in AssessmentRequirementIdList do
            AssessmentRequirementIdFilter += AssessmentRequirementId + '|';
        AssessmentRequirementIdFilter := AssessmentRequirementIdFilter.TrimEnd('|');

        CRMAssessmentRequirement.SetFilter(AssessmentRequirementId, AssessmentRequirementIdFilter);
        AssessmentRequirementRecordRef.GetTable(CRMAssessmentRequirement);
        CRMIntegrationTableSynch.SynchRecordsFromIntegrationTable(AssessmentRequirementRecordRef, Database::"Sust. ESG Reporting Line", true, false);
    end;

    local procedure SyncESGReportingLineIfRequirementConceptIsModified(ESGRequirementConcept: Record "Sust. ESG Requirement Concept")
    var
        CRMAssessmentRequirement: Record "Sust. Assessment Requirement";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        AssessmentRequirementRecordRef: RecordRef;
        AssessmentRequirementId: Guid;
        AssessmentRequirementIdList: List of [Guid];
        AssessmentRequirementIdFilter: Text;
    begin
        if IsNullGuid(ESGRequirementConcept."Requirement Concept ID") then
            exit;

        ESGReportingLine.SetRange("Requirement Concept ID", ESGRequirementConcept."Requirement Concept ID");
        if ESGReportingLine.FindSet() then
            repeat
                if not IsNullGuid(ESGReportingLine."Assessment Requirement ID") then
                    AssessmentRequirementIdList.Add(ESGReportingLine."Assessment Requirement ID");
            until ESGReportingLine.Next() = 0;

        if AssessmentRequirementIdList.Count = 0 then
            exit;

        foreach AssessmentRequirementId in AssessmentRequirementIdList do
            AssessmentRequirementIdFilter += AssessmentRequirementId + '|';
        AssessmentRequirementIdFilter := AssessmentRequirementIdFilter.TrimEnd('|');

        CRMAssessmentRequirement.SetFilter(AssessmentRequirementId, AssessmentRequirementIdFilter);
        AssessmentRequirementRecordRef.GetTable(CRMAssessmentRequirement);
        CRMIntegrationTableSynch.SynchRecordsFromIntegrationTable(AssessmentRequirementRecordRef, Database::"Sust. ESG Reporting Line", true, false);
    end;

    local procedure SyncESGReportingLineIfConceptIsModified(ESGConcept: Record "Sust. ESG Concept")
    var
        CRMAssessmentRequirement: Record "Sust. Assessment Requirement";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        AssessmentRequirementRecordRef: RecordRef;
        AssessmentRequirementId: Guid;
        AssessmentRequirementIdList: List of [Guid];
        AssessmentRequirementIdFilter: Text;
    begin
        if IsNullGuid(ESGConcept."Concept ID") then
            exit;

        ESGReportingLine.SetRange("Concept ID", ESGConcept."Concept ID");
        if ESGReportingLine.FindSet() then
            repeat
                if not IsNullGuid(ESGReportingLine."Assessment Requirement ID") then
                    AssessmentRequirementIdList.Add(ESGReportingLine."Assessment Requirement ID");
            until ESGReportingLine.Next() = 0;

        if AssessmentRequirementIdList.Count = 0 then
            exit;

        foreach AssessmentRequirementId in AssessmentRequirementIdList do
            AssessmentRequirementIdFilter += AssessmentRequirementId + '|';
        AssessmentRequirementIdFilter := AssessmentRequirementIdFilter.TrimEnd('|');

        CRMAssessmentRequirement.SetFilter(AssessmentRequirementId, AssessmentRequirementIdFilter);
        AssessmentRequirementRecordRef.GetTable(CRMAssessmentRequirement);
        CRMIntegrationTableSynch.SynchRecordsFromIntegrationTable(AssessmentRequirementRecordRef, Database::"Sust. ESG Reporting Line", true, false);
    end;

    local procedure PopulateESGReportingByConcept(OriginalESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        RequirementConcept: Record "Sust. Requirement Concept";
        RequirementConceptIdList: List of [Guid];
    begin
        DeleteReportingLineIfStandardRequirementIsUpdatedInOriginalReportingLine(OriginalESGReportingLine);

        if IsNullGuid(OriginalESGReportingLine."Standard Requirement ID") then
            exit;

        RequirementConcept.SetRange(StandardRequirement, OriginalESGReportingLine."Standard Requirement ID");
        RequirementConcept.SetFilter(RequirementConceptId, '<>%1', OriginalESGReportingLine."Requirement Concept ID");
        if RequirementConcept.FindSet() then
            repeat
                RequirementConceptIdList.Add(RequirementConcept.RequirementConceptId);

                if ShouldCreateESGReportingLineForConcept(OriginalESGReportingLine, RequirementConcept) then
                    InsertESGReportingLineFromRequirementConcept(OriginalESGReportingLine, RequirementConcept)
                else
                    UpdateESGReportingLineFromRequirementConcept(OriginalESGReportingLine, RequirementConcept);
            until RequirementConcept.Next() = 0;

        RemoveDeltaReportingLineFromBCAndDataverse(OriginalESGReportingLine, RequirementConceptIdList);
    end;

    local procedure DeleteReportingLineIfStandardRequirementIsUpdatedInOriginalReportingLine(OriginalESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        ESGReportingLine.SetRange("Derived From SystemId", OriginalESGReportingLine.SystemId);
        ESGReportingLine.SetRange("Assessment Requirement ID", OriginalESGReportingLine."Assessment Requirement ID");
        ESGReportingLine.SetFilter("Standard Requirement ID", '<>%1', OriginalESGReportingLine."Standard Requirement ID");
        if not ESGReportingLine.IsEmpty then
            ESGReportingLine.DeleteAll();
    end;

    local procedure RemoveDeltaReportingLineFromBCAndDataverse(OriginalESGReportingLine: Record "Sust. ESG Reporting Line"; RequirementConceptIdList: List of [Guid])
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        RequirementConceptId: Guid;
        RequirementConceptIdFilter: Text;
    begin
        if RequirementConceptIdList.Count = 0 then begin
            ESGReportingLine.SetRange("Derived From SystemId", OriginalESGReportingLine.SystemId);
            ESGReportingLine.SetRange("Assessment Requirement ID", OriginalESGReportingLine."Assessment Requirement ID");
            if not ESGReportingLine.IsEmpty() then
                ESGReportingLine.DeleteAll();

            exit;
        end;

        foreach RequirementConceptId in RequirementConceptIdList do
            RequirementConceptIdFilter += '<>' + RequirementConceptId + '&';

        RequirementConceptIdFilter := RequirementConceptIdFilter.TrimEnd('&');

        ESGReportingLine.SetRange("Derived From SystemId", OriginalESGReportingLine.SystemId);
        ESGReportingLine.SetRange("Assessment Requirement ID", OriginalESGReportingLine."Assessment Requirement ID");
        ESGReportingLine.SetFilter("Requirement Concept ID", RequirementConceptIdFilter);
        if not ESGReportingLine.IsEmpty() then
            ESGReportingLine.DeleteAll();
    end;

    local procedure InsertESGReportingLineFromRequirementConcept(OriginalESGReportingLine: Record "Sust. ESG Reporting Line"; RequirementConcept: Record "Sust. Requirement Concept")
    var
        NewESGReportingLine: Record "Sust. ESG Reporting Line";
        Concept: Record "Sust. Concept";
    begin
        NewESGReportingLine.Init();
        NewESGReportingLine := OriginalESGReportingLine;
        NewESGReportingLine."Line No." := GetLastESGReportingLineNoFromRequirementConcept(OriginalESGReportingLine) + 1;
        NewESGReportingLine."Derived From SystemId" := OriginalESGReportingLine.SystemId;
        NewESGReportingLine."Concept Link" := RequirementConcept.Name;
        NewESGReportingLine."Requirement Concept ID" := RequirementConcept.RequirementConceptId;
        NewESGReportingLine."Concept ID" := RequirementConcept.ConceptId;

        Concept := GetConcept(RequirementConcept.ConceptId);
        NewESGReportingLine."Concept" := Concept.Name;

        NewESGReportingLine.Insert();
    end;

    local procedure UpdateESGReportingLineFromRequirementConcept(OriginalESGReportingLine: Record "Sust. ESG Reporting Line"; RequirementConcept: Record "Sust. Requirement Concept")
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        Concept: Record "Sust. Concept";
    begin
        ESGReportingLine.SetRange("Assessment Requirement ID", OriginalESGReportingLine."Assessment Requirement ID");
        ESGReportingLine.SetRange("Requirement Concept ID", RequirementConcept.RequirementConceptId);
        if not ESGReportingLine.FindFirst() then
            exit;

        ESGReportingLine."Reporting Code" := OriginalESGReportingLine."Reporting Code";
        ESGReportingLine.Description := OriginalESGReportingLine.Description;
        ESGReportingLine.Grouping := OriginalESGReportingLine.Grouping;
        ESGReportingLine."Concept Link" := RequirementConcept.Name;
        ESGReportingLine."Standard Requirement ID" := OriginalESGReportingLine."Standard Requirement ID";
        ESGReportingLine."Parent Standard Requirement ID" := OriginalESGReportingLine."Parent Standard Requirement ID";
        ESGReportingLine."Requirement Concept ID" := RequirementConcept.RequirementConceptId;
        ESGReportingLine."Concept ID" := RequirementConcept.ConceptId;

        Concept := GetConcept(RequirementConcept.ConceptId);
        ESGReportingLine."Concept" := Concept.Name;

        ESGReportingLine.Modify();
    end;

    local procedure GetConcept(Id: Guid) Concept: Record "Sust. Concept"
    begin
        if IsNullGuid(Id) then
            exit;

        Concept.Get(Id);
    end;

    local procedure ShouldCreateESGReportingLineForConcept(OriginalESGReportingLine: Record "Sust. ESG Reporting Line"; RequirementConcept: Record "Sust. Requirement Concept"): Boolean
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        ESGReportingLine.SetRange("Assessment Requirement ID", OriginalESGReportingLine."Assessment Requirement ID");
        ESGReportingLine.SetRange("Requirement Concept ID", RequirementConcept.RequirementConceptId);

        exit(ESGReportingLine.IsEmpty());
    end;

    local procedure GetLastESGReportingLineNoFromRequirementConcept(OriginalESGReportingLine: Record "Sust. ESG Reporting Line"): Integer
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        ESGReportingLine.SetRange("Assessment Requirement ID", OriginalESGReportingLine."Assessment Requirement ID");
        if ESGReportingLine.FindLast() then
            exit(ESGReportingLine."Line No.")
        else
            exit(OriginalESGReportingLine."Line No.");
    end;
}