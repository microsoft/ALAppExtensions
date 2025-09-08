// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.CRM;

using Microsoft.Integration.Dataverse;
using Microsoft.Sustainability.Setup;

codeunit 6275 "Sust. Lookup CRM Tables"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Lookup CRM Tables", 'OnLookupCRMTables', '', false, false)]
    local procedure HandleOnLookupCRMTables(CRMTableID: Integer; NAVTableId: Integer; SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text; var Handled: Boolean)
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        if Handled then
            exit;

        if not SustainabilitySetup.IsDataverseIntegrationEnabled() then
            exit;

        case CRMTableID of
            Database::"Sust. Standard":
                Handled := LookupStandard(SavedCRMId, CRMId, IntTableFilter);
            Database::"Sust. Range Period":
                Handled := LookupRangePeriod(SavedCRMId, CRMId, IntTableFilter);
            Database::"Sust. Unit":
                Handled := LookupUnit(SavedCRMId, CRMId, IntTableFilter);
            Database::"Sust. Assessment":
                Handled := LookupAssessment(SavedCRMId, CRMId, IntTableFilter);
            Database::"Sust. Standard Requirement":
                Handled := LookupStandardRequirement(SavedCRMId, CRMId, IntTableFilter);
            Database::"Sust. Concept":
                Handled := LookupConcept(SavedCRMId, CRMId, IntTableFilter);
            Database::"Sust. Requirement Concept":
                Handled := LookupRequirementConcept(SavedCRMId, CRMId, IntTableFilter);
            Database::"Sust. Assessment Requirement":
                Handled := LookupAssessmentRequirement(SavedCRMId, CRMId, IntTableFilter);
            Database::"Sust. ESG Fact":
                Handled := LookupESGFact(SavedCRMId, CRMId, IntTableFilter);
        end;
    end;

    local procedure LookupStandard(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        Standard: Record "Sust. Standard";
        OriginalStandard: Record "Sust. Standard";
        StandardList: Page "Sust. Standard List";
    begin
        if not IsNullGuid(CRMId) then begin
            if Standard.Get(CRMId) then
                StandardList.SetRecord(Standard);
            if not IsNullGuid(SavedCRMId) then
                if OriginalStandard.Get(SavedCRMId) then
                    StandardList.SetCurrentlyCoupledCRMStandard(OriginalStandard);
        end;

        Standard.SetView(IntTableFilter);
        StandardList.SetTableView(Standard);
        StandardList.LookupMode(true);
        Commit();

        if StandardList.RunModal() = Action::LookupOK then begin
            StandardList.GetRecord(Standard);
            CRMId := Standard.StandardId;
            exit(true);
        end;

        exit(false);
    end;

    local procedure LookupRangePeriod(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        RangePeriod: Record "Sust. Range Period";
        OriginalRangePeriod: Record "Sust. Range Period";
        RangePeriodList: Page "Sust. Range Period List";
    begin
        if not IsNullGuid(CRMId) then begin
            if RangePeriod.Get(CRMId) then
                RangePeriodList.SetRecord(RangePeriod);
            if not IsNullGuid(SavedCRMId) then
                if OriginalRangePeriod.Get(SavedCRMId) then
                    RangePeriodList.SetCurrentlyCoupledCRMRangePeriod(OriginalRangePeriod);
        end;

        RangePeriod.SetView(IntTableFilter);
        RangePeriodList.SetTableView(RangePeriod);
        RangePeriodList.LookupMode(true);
        Commit();

        if RangePeriodList.RunModal() = Action::LookupOK then begin
            RangePeriodList.GetRecord(RangePeriod);
            CRMId := RangePeriod.RangePeriodId;
            exit(true);
        end;

        exit(false);
    end;

    local procedure LookupUnit(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        Unit: Record "Sust. Unit";
        OriginalUnit: Record "Sust. Unit";
        UnitList: Page "Sust. ESG Unit List";
    begin
        if not IsNullGuid(CRMId) then begin
            if Unit.Get(CRMId) then
                UnitList.SetRecord(Unit);
            if not IsNullGuid(SavedCRMId) then
                if OriginalUnit.Get(SavedCRMId) then
                    UnitList.SetCurrentlyCoupledCRMUnit(OriginalUnit);
        end;

        Unit.SetView(IntTableFilter);
        UnitList.SetTableView(Unit);
        UnitList.LookupMode(true);
        Commit();

        if UnitList.RunModal() = Action::LookupOK then begin
            UnitList.GetRecord(Unit);
            CRMId := Unit.UnitId;
            exit(true);
        end;

        exit(false);
    end;

    local procedure LookupAssessment(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        Assessment: Record "Sust. Assessment";
        OriginalAssessment: Record "Sust. Assessment";
        AssessmentList: Page "Sust. Assessment List";
    begin
        if not IsNullGuid(CRMId) then begin
            if Assessment.Get(CRMId) then
                AssessmentList.SetRecord(Assessment);
            if not IsNullGuid(SavedCRMId) then
                if OriginalAssessment.Get(SavedCRMId) then
                    AssessmentList.SetCurrentlyCoupledCRMAssessment(OriginalAssessment);
        end;

        Assessment.SetView(IntTableFilter);
        AssessmentList.SetTableView(Assessment);
        AssessmentList.LookupMode(true);
        Commit();

        if AssessmentList.RunModal() = Action::LookupOK then begin
            AssessmentList.GetRecord(Assessment);
            CRMId := Assessment.AssessmentId;
            exit(true);
        end;

        exit(false);
    end;

    local procedure LookupStandardRequirement(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        StandardRequirement: Record "Sust. Standard Requirement";
        OriginalStandardRequirement: Record "Sust. Standard Requirement";
        StandardRequirementList: Page "Sust. Std. Requirement List";
    begin
        if not IsNullGuid(CRMId) then begin
            if StandardRequirement.Get(CRMId) then
                StandardRequirementList.SetRecord(StandardRequirement);
            if not IsNullGuid(SavedCRMId) then
                if OriginalStandardRequirement.Get(SavedCRMId) then
                    StandardRequirementList.SetCurrentlyCoupledCRMStandardRequirement(OriginalStandardRequirement);
        end;

        StandardRequirement.SetView(IntTableFilter);
        StandardRequirementList.SetTableView(StandardRequirement);
        StandardRequirementList.LookupMode(true);
        Commit();

        if StandardRequirementList.RunModal() = Action::LookupOK then begin
            StandardRequirementList.GetRecord(StandardRequirement);
            CRMId := StandardRequirement.StandardRequirementId;
            exit(true);
        end;

        exit(false);
    end;

    local procedure LookupConcept(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        Concept: Record "Sust. Concept";
        OriginalConcept: Record "Sust. Concept";
        ConceptList: Page "Sust. Concept List";
    begin
        if not IsNullGuid(CRMId) then begin
            if Concept.Get(CRMId) then
                ConceptList.SetRecord(Concept);
            if not IsNullGuid(SavedCRMId) then
                if OriginalConcept.Get(SavedCRMId) then
                    ConceptList.SetCurrentlyCoupledCRMConcept(OriginalConcept);
        end;

        Concept.SetView(IntTableFilter);
        ConceptList.SetTableView(Concept);
        ConceptList.LookupMode(true);
        Commit();

        if ConceptList.RunModal() = Action::LookupOK then begin
            ConceptList.GetRecord(Concept);
            CRMId := Concept.ConceptId;
            exit(true);
        end;

        exit(false);
    end;

    local procedure LookupRequirementConcept(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        RequirementConcept: Record "Sust. Requirement Concept";
        OriginalRequirementConcept: Record "Sust. Requirement Concept";
        RequirementConceptList: Page "Sust. Requirement Concept List";
    begin
        if not IsNullGuid(CRMId) then begin
            if RequirementConcept.Get(CRMId) then
                RequirementConceptList.SetRecord(RequirementConcept);
            if not IsNullGuid(SavedCRMId) then
                if OriginalRequirementConcept.Get(SavedCRMId) then
                    RequirementConceptList.SetCurrentlyCoupledCRMRequirementConcept(OriginalRequirementConcept);
        end;

        RequirementConcept.SetView(IntTableFilter);
        RequirementConceptList.SetTableView(RequirementConcept);
        RequirementConceptList.LookupMode(true);
        Commit();

        if RequirementConceptList.RunModal() = Action::LookupOK then begin
            RequirementConceptList.GetRecord(RequirementConcept);
            CRMId := RequirementConcept.ConceptId;
            exit(true);
        end;

        exit(false);
    end;

    local procedure LookupAssessmentRequirement(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        AssessmentRequirement: Record "Sust. Assessment Requirement";
        OriginalAssessmentRequirement: Record "Sust. Assessment Requirement";
        AssessmentReqList: Page "Sust. Assessment Req. List";
    begin
        if not IsNullGuid(CRMId) then begin
            if AssessmentRequirement.Get(CRMId) then
                AssessmentReqList.SetRecord(AssessmentRequirement);
            if not IsNullGuid(SavedCRMId) then
                if OriginalAssessmentRequirement.Get(SavedCRMId) then
                    AssessmentReqList.SetCurrentlyCoupledCRMAssessmentRequirement(OriginalAssessmentRequirement);
        end;

        AssessmentRequirement.SetView(IntTableFilter);
        AssessmentReqList.SetTableView(AssessmentRequirement);
        AssessmentReqList.LookupMode(true);
        Commit();

        if AssessmentReqList.RunModal() = Action::LookupOK then begin
            AssessmentReqList.GetRecord(AssessmentRequirement);
            CRMId := AssessmentRequirement.AssessmentRequirementId;
            exit(true);
        end;

        exit(false);
    end;

    local procedure LookupESGFact(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        ESGFact: Record "Sust. ESG Fact";
        OriginalESGFact: Record "Sust. ESG Fact";
        ESGFactList: Page "Sust. ESG Fact List";
    begin
        if not IsNullGuid(CRMId) then begin
            if ESGFact.Get(CRMId) then
                ESGFactList.SetRecord(ESGFact);
            if not IsNullGuid(SavedCRMId) then
                if OriginalESGFact.Get(SavedCRMId) then
                    ESGFactList.SetCurrentlyCoupledCRMFact(OriginalESGFact);
        end;

        ESGFact.SetView(IntTableFilter);
        ESGFactList.SetTableView(ESGFact);
        ESGFactList.LookupMode(true);
        Commit();

        if ESGFactList.RunModal() = Action::LookupOK then begin
            ESGFactList.GetRecord(ESGFact);
            CRMId := ESGFact.ESGFactId;
            exit(true);
        end;

        exit(false);
    end;
}