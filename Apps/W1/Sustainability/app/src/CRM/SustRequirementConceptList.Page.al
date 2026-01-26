// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.CRM;

using Microsoft.Integration.Dataverse;
using Microsoft.Sustainability.ESGReporting;

page 6343 "Sust. Requirement Concept List"
{
    ApplicationArea = Suite;
    Caption = 'Requirement Concept - Dataverse';
    Editable = false;
    PageType = List;
    SourceTable = "Sust. Requirement Concept";
    SourceTableView = sorting(Name);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = Suite;
                    Caption = 'Name';
                    StyleExpr = FirstColumnStyle;
                    ToolTip = 'Specifies data from a corresponding field in a Dataverse entity. For more information about Dataverse, see Dataverse Help Center.';
                }
                field(StandardRequirement; Rec.StandardRequirement)
                {
                    ApplicationArea = Suite;
                    Caption = 'Standard Requirement';
                    StyleExpr = FirstColumnStyle;
                    ToolTip = 'Specifies data from a corresponding field in a Dataverse entity. For more information about Dataverse, see Dataverse Help Center.';
                }
                field(ConceptId; Rec.ConceptId)
                {
                    ApplicationArea = Suite;
                    Caption = 'Concept ID';
                    StyleExpr = FirstColumnStyle;
                    ToolTip = 'Specifies data from a corresponding field in a Dataverse entity. For more information about Dataverse, see Dataverse Help Center.';
                }
                field(Coupled; Coupled)
                {
                    ApplicationArea = Suite;
                    Caption = 'Coupled';
                    ToolTip = 'Specifies if the Dataverse record is coupled to Business Central.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CreateFromCRM)
            {
                ApplicationArea = Suite;
                Caption = 'Create in Business Central';
                Image = NewRow;
                ToolTip = 'Generate the entity from the coupled Dataverse requirement concept.';

                trigger OnAction()
                var
                    CRMRequirementConcept: Record "Sust. Requirement Concept";
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    CurrPage.SetSelectionFilter(CRMRequirementConcept);
                    CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMRequirementConcept);
                end;
            }
            action(ShowOnlyUncoupled)
            {
                ApplicationArea = Suite;
                Caption = 'Hide Coupled Requirement Concepts';
                Image = FilterLines;
                ToolTip = 'Do not show coupled requirement concepts.';

                trigger OnAction()
                begin
                    Rec.MarkedOnly(true);
                end;
            }
            action(ShowAll)
            {
                ApplicationArea = Suite;
                Caption = 'Show Coupled Requirement Concepts';
                Image = ClearFilter;
                ToolTip = 'Show coupled requirement concepts.';

                trigger OnAction()
                begin
                    Rec.MarkedOnly(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CreateFromCRM_Promoted; CreateFromCRM)
                {
                }
                actionref(ShowOnlyUncoupled_Promoted; ShowOnlyUncoupled)
                {
                }
                actionref(ShowAll_Promoted; ShowAll)
                {
                }
            }
        }
    }

    trigger OnInit()
    begin
        Codeunit.Run(Codeunit::"CRM Integration Management");
        Commit();
    end;

    trigger OnOpenPage()
    var
        LookupCRMTables: Codeunit "Lookup CRM Tables";
    begin
        Rec.FilterGroup(4);
        Rec.SetView(LookupCRMTables.GetIntegrationTableMappingView(Database::"Sust. Requirement Concept"));
        Rec.FilterGroup(0);
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;

    var
        CurrentlyCoupledCRMRequirementConcept: Record "Sust. Requirement Concept";
        Coupled: Text;
        FirstColumnStyle: Text;
        CurrentLbl: Label 'Current';
        StrongLbl: Label 'Strong';
        NoLbl: Label 'No';
        YesLbl: Label 'Yes';
        NoneLbl: Label 'None';
        SubordinateLbl: Label 'Subordinate';

    local procedure SetControlAppearance()
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        RecordID: RecordID;
        EmptyRecordID: RecordID;
    begin
        if CRMIntegrationRecord.FindRecordIDFromID(Rec.RequirementConceptId, Database::"Sust. ESG Requirement Concept", RecordID) then
            if CurrentlyCoupledCRMRequirementConcept.RequirementConceptId = Rec.RequirementConceptId then begin
                Coupled := CurrentLbl;
                FirstColumnStyle := StrongLbl;
                Rec.Mark(true);
            end else begin
                Coupled := YesLbl;
                FirstColumnStyle := SubordinateLbl;
                Rec.Mark(false);
            end;

        if RecordID = EmptyRecordID then begin
            Coupled := NoLbl;
            FirstColumnStyle := NoneLbl;
            Rec.Mark(true);
        end;
    end;

    procedure SetCurrentlyCoupledCRMRequirementConcept(CRMRequirementConcept: Record "Sust. Requirement Concept")
    begin
        CurrentlyCoupledCRMRequirementConcept := CRMRequirementConcept;
    end;
}