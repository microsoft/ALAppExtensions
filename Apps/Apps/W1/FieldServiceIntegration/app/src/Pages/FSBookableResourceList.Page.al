// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Projects.Resources.Resource;

#pragma warning disable AS0130
#pragma warning disable PTE0025
page 6610 "FS Bookable Resource List"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    ApplicationArea = Suite;
    Caption = 'Bookable Resources - Dynamics 365 Field Service';
    Editable = false;
    PageType = List;
    SourceTable = "FS Bookable Resource";
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
                    ToolTip = 'Specifies the bookable resource name.';
                }
                field(HourlyRate; Rec.HourlyRate)
                {
                    ApplicationArea = Suite;
                    Caption = 'Hourly Rate';
                    ToolTip = 'Specifies the bookable resource hourly rate.';
                }
                field(ResourceType; Rec.ResourceType)
                {
                    ApplicationArea = Suite;
                    Caption = 'Resource Type';
                    ToolTip = 'Specifies the bookable resource type.';
                }
                field(Coupled; Coupled)
                {
                    ApplicationArea = Suite;
                    Caption = 'Coupled';
                    ToolTip = 'Specifies if the Dynamics 365 Field Service record is coupled to Business Central.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CreateFromFS)
            {
                ApplicationArea = Suite;
                Caption = 'Create in Business Central';
                Image = NewResource;
                ToolTip = 'Generate the entity from the Field Service bookable resource.';

                trigger OnAction()
                var
                    FSBookableResource: Record "FS Bookable Resource";
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    CurrPage.SetSelectionFilter(FSBookableResource);
                    CRMIntegrationManagement.CreateNewRecordsFromSelectedCRMRecords(FSBookableResource);
                end;
            }
            action(ShowOnlyUncoupled)
            {
                ApplicationArea = Suite;
                Caption = 'Hide Coupled Records';
                Image = FilterLines;
                ToolTip = 'Do not show coupled records.';

                trigger OnAction()
                begin
                    Rec.MarkedOnly(true);
                end;
            }
            action(ShowAll)
            {
                ApplicationArea = Suite;
                Caption = 'Show Coupled Records';
                Image = ClearFilter;
                ToolTip = 'Show coupled records.';

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

                actionref(CreateFromFS_Promoted; CreateFromFS)
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

    trigger OnAfterGetRecord()
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        RecordID: RecordID;
    begin
        if CRMIntegrationRecord.FindRecordIDFromID(Rec.BookableResourceId, Database::Resource, RecordID) then
            if CurrentlyCoupledFSBookableResource.BookableResourceId = Rec.BookableResourceId then begin
                Coupled := 'Current';
                FirstColumnStyle := 'Strong';
                Rec.Mark(true);
            end else begin
                Coupled := 'Yes';
                FirstColumnStyle := 'Subordinate';
                Rec.Mark(false);
            end
        else begin
            Coupled := 'No';
            FirstColumnStyle := 'None';
            Rec.Mark(true);
        end;
    end;

    trigger OnInit()
    begin
        Codeunit.Run(Codeunit::"CRM Integration Management");
    end;

    trigger OnOpenPage()
    var
        LookupCRMTables: Codeunit "Lookup CRM Tables";
    begin
        Rec.FilterGroup(4);
        Rec.SetView(LookupCRMTables.GetIntegrationTableMappingView(Database::"FS Bookable Resource"));
        Rec.FilterGroup(0);
    end;

    var
        CurrentlyCoupledFSBookableResource: Record "FS Bookable Resource";
        Coupled: Text;
        FirstColumnStyle: Text;

    procedure SetCurrentlyCoupledFSBookableResource(FSBookableResource: Record "FS Bookable Resource")
    begin
        CurrentlyCoupledFSBookableResource := FSBookableResource;
    end;
}

