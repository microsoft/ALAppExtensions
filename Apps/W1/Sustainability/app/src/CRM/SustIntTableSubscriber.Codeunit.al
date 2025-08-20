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
        DoesNotExistErr: Label '%1 %2 doesn''t exist in %3', Comment = '%1 = a table name, %2 - a guid, %3 = Field Service service name';
        NotCoupledToTableErr: Label 'The %1 %2 is not coupled to a %3.', Comment = '%1 = Table Caption, %2 = primary key value, %3 = Table Caption';
        RecordMustBeCoupledErr: Label '%1 %2 must be coupled to %3.', Comment = '%1 = Table Caption, %2 = primary key value, %3 - service name';

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
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterInsertRecord', '', true, false)]
    local procedure HandleOnAfterInsertRecord(SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        ESGFact: Record "Sust. ESG Fact";
        PostedESGReportLine: Record "Sust. Posted ESG Report Line";
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
                TransferStandardFieldDataFromAssessment(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
            Assessment.FieldName(Period):
                TransferPeriodFieldDataFromAssessment(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferStandardFieldDataFromAssessment(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        Standard: Record "Sust. Standard";
        ESGStandard: Record "Sust. ESG Standard";
        Assessment: Record "Sust. Assessment";
        CRMIntegrationRecord: Record "CRM Integration Record";
        SourceRecordRef: RecordRef;
        NAVStandardRecordId: RecordId;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(Assessment);

        NewValue := '';
        if not IsNullGuid(Assessment.Standard) then begin
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
                TransferAssessmentFieldDataFromAssessmentRequirement(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
            AssessmentRequirement.FieldName(StandardRequirement):
                TransferStandardRequirementFieldDataFromAssessmentRequirement(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
        end;
    end;

    local procedure TransferAssessmentFieldDataFromAssessmentRequirement(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        Assessment: Record "Sust. Assessment";
        AssessmentRequirement: Record "Sust. Assessment Requirement";
        SourceRecordRef: RecordRef;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(AssessmentRequirement);

        NewValue := '';
        if not IsNullGuid(AssessmentRequirement.Assessment) then
            if not Assessment.Get(AssessmentRequirement.Assessment) then
                Error(DoesNotExistErr, AssessmentRequirement.FieldCaption(Assessment), Format(AssessmentRequirement.Assessment), Assessment.TableCaption())
            else
                NewValue := Assessment.Name;

        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferStandardRequirementFieldDataFromAssessmentRequirement(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        AssessmentRequirement: Record "Sust. Assessment Requirement";
        StandardRequirement: Record "Sust. Standard Requirement";
        SourceRecordRef: RecordRef;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(AssessmentRequirement);

        NewValue := '';
        if not IsNullGuid(AssessmentRequirement.StandardRequirement) then
            if not StandardRequirement.Get(AssessmentRequirement.StandardRequirement) then
                Error(DoesNotExistErr, AssessmentRequirement.FieldCaption(StandardRequirement), Format(AssessmentRequirement.StandardRequirement), StandardRequirement.TableCaption())
            else
                TransferStandardRequirementFieldDataFromAssessmentRequirement(AssessmentRequirement, StandardRequirement, DestinationFieldRef, NewValue);

        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferStandardRequirementFieldDataFromAssessmentRequirement(AssessmentRequirement: Record "Sust. Assessment Requirement"; StandardRequirement: Record "Sust. Standard Requirement"; DestinationFieldRef: FieldRef; var NewValue: Variant)
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        RequirementConcept: Record "Sust. Requirement Concept";
        Concept: Record "Sust. Concept";
        InStream: InStream;
        FieldValue: Text;
    begin
        case DestinationFieldRef.Name of
            ESGReportingLine.FieldName(Description):
                if StandardRequirement.Description.HasValue then begin
                    StandardRequirement.CalcFields(Description);
                    StandardRequirement.Description.CreateInStream(InStream, TextEncoding::UTF16);
                    InStream.ReadText(FieldValue);
                    NewValue := FieldValue;
                end;
            ESGReportingLine.FieldName(Grouping):
                begin
                    StandardRequirement.CalcFields(ParentStdRequirementIdName);
                    NewValue := StandardRequirement.ParentStdRequirementIdName;
                end;
            ESGReportingLine.FieldName("Concept Link"):
                begin
                    RequirementConcept.SetRange(StandardRequirement, AssessmentRequirement.StandardRequirement);
                    if RequirementConcept.FindFirst() then
                        NewValue := RequirementConcept.Name;
                end;
            ESGReportingLine.FieldName(Concept):
                begin
                    RequirementConcept.SetRange(StandardRequirement, AssessmentRequirement.StandardRequirement);
                    if RequirementConcept.FindFirst() then
                        if Concept.Get(RequirementConcept.ConceptId) then
                            NewValue := Concept.Name;
                end;
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
            PostedESGReportingLine.FieldName(Concept):
                TransferConceptFieldDataFromPostedESGReportLine(SourceFieldRef, NewValue, IsValueFound, NeedsConversion);
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

        NewValue := CopyStr(PostedESGReportingLine."Document No." + ' - ' + PostedESGReportingLine.Description, 1, DestinationFieldRef.Length());
        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferConceptFieldDataFromPostedESGReportLine(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
        Concept: Record "Sust. Concept";
        SourceRecordRef: RecordRef;
        EmptyGuid: Guid;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(PostedESGReportingLine);

        NewValue := EmptyGuid;
        if PostedESGReportingLine.Concept <> '' then begin
            Concept.SetRange(Name, PostedESGReportingLine.Concept);
            if not Concept.FindFirst() then
                Error(DoesNotExistErr, PostedESGReportingLine.FieldCaption(Concept), PostedESGReportingLine.Concept, Concept.TableCaption())
            else
                NewValue := Concept.ConceptId;
        end;

        IsValueFound := true;
        NeedsConversion := false;
    end;

    local procedure TransferDateFilterDataFromPostedESGReportLine(SourceFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        RangePeriod: Record "Sust. Range Period";
        PostedESGReportingHeader: Record "Sust. Posted ESG Report Header";
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
        SourceRecordRef: RecordRef;
        EmptyGuid: Guid;
    begin
        SourceRecordRef := SourceFieldRef.Record();
        SourceRecordRef.SetTable(PostedESGReportingLine);
        PostedESGReportingHeader.Get(PostedESGReportingLine."Document No.");

        NewValue := EmptyGuid;
        if PostedESGReportingHeader."Period Name" <> '' then begin
            RangePeriod.SetRange(Name, PostedESGReportingHeader."Period Name");
            if not RangePeriod.FindFirst() then
                Error(DoesNotExistErr, PostedESGReportingHeader.FieldCaption("Period Name"), Format(PostedESGReportingHeader."Period Name"), RangePeriod.TableCaption());
        end;

        NewValue := RangePeriod.RangePeriodId;
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
        AssessmentReqFact.AssessmentRequirement := GetAssessmentRequirementId(PostedESGReportLine);
        AssessmentReqFact.RequirementConcept := GetRequirementConceptId(PostedESGReportLine);
        AssessmentReqFact."Esg Fact" := ESGFact.ESGFactId;
        AssessmentReqFact.Insert();
    end;

    local procedure GetAssessmentRequirementId(PostedESGReportLine: Record "Sust. Posted ESG Report Line"): Guid
    var
        AssessmentRequirement: Record "Sust. Assessment Requirement";
    begin
        AssessmentRequirement.SetRange(Name, PostedESGReportLine."Reporting Code");
        if AssessmentRequirement.FindFirst() then
            exit(AssessmentRequirement.AssessmentRequirementId);
    end;

    local procedure GetRequirementConceptId(PostedESGReportLine: Record "Sust. Posted ESG Report Line"): Guid
    var
        RequirementConcept: Record "Sust. Requirement Concept";
    begin
        RequirementConcept.SetRange(Name, PostedESGReportLine."Concept Link");
        if RequirementConcept.FindFirst() then
            exit(RequirementConcept.RequirementConceptId);
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
}