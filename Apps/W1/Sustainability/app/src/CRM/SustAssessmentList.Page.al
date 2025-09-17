// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.CRM;

using Microsoft.Integration.Dataverse;
using Microsoft.Sustainability.ESGReporting;

page 6290 "Sust. Assessment List"
{
    ApplicationArea = Suite;
    Caption = 'Assessment - Dataverse';
    Editable = false;
    PageType = List;
    SourceTable = "Sust. Assessment";
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
                field(StandardName; Rec.StandardName)
                {
                    ApplicationArea = Suite;
                    Caption = 'Standard';
                    ToolTip = 'Specifies data from a corresponding field in a Dataverse entity. For more information about Dataverse, see Dataverse Help Center.';
                }
                field(PeriodName; Rec.PeriodName)
                {
                    ApplicationArea = Suite;
                    Caption = 'Period';
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
                ToolTip = 'Generate the entity from the coupled Dataverse assessment.';

                trigger OnAction()
                var
                    CRMAssessment: Record "Sust. Assessment";
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    CurrPage.SetSelectionFilter(CRMAssessment);
                    CRMIntegrationManagement.CreateNewRecordsFromCRM(CRMAssessment);
                end;
            }
            action(ShowOnlyUncoupled)
            {
                ApplicationArea = Suite;
                Caption = 'Hide Coupled Assessments';
                Image = FilterLines;
                ToolTip = 'Do not show coupled assessments.';

                trigger OnAction()
                begin
                    Rec.MarkedOnly(true);
                end;
            }
            action(ShowAll)
            {
                ApplicationArea = Suite;
                Caption = 'Show Coupled Assessments';
                Image = ClearFilter;
                ToolTip = 'Show coupled assessments.';

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
        Rec.SetView(LookupCRMTables.GetIntegrationTableMappingView(Database::"Sust. Assessment"));
        Rec.FilterGroup(0);
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;

    var
        CurrentlyCoupledCRMAssessment: Record "Sust. Assessment";
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
        if CRMIntegrationRecord.FindRecordIDFromID(Rec.AssessmentId, Database::"Sust. ESG Reporting Name", RecordID) then
            if CurrentlyCoupledCRMAssessment.AssessmentId = Rec.AssessmentId then begin
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

    procedure SetCurrentlyCoupledCRMAssessment(CRMAssessment: Record "Sust. Assessment")
    begin
        CurrentlyCoupledCRMAssessment := CRMAssessment;
    end;
}