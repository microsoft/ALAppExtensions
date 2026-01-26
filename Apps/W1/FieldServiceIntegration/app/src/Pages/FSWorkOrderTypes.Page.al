// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Service.Setup;
using System.Environment.Configuration;

page 6615 "FS Work Order Types"
{
    ApplicationArea = Service;
    Caption = 'Work Order Types - Dynamics 365 Field Service';
    Editable = false;
    PageType = List;
    SourceTable = "FS Work Order Type";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Service;
                    StyleExpr = FirstColumnStyle;
                    ToolTip = 'Specifies the work order type code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the work order type name.';
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
                Image = NewItemNonStock;
                ToolTip = 'Generate the entity from the Field Service work order.';
                Visible = ShowCreateInBC;

                trigger OnAction()
                var
                    FSWorkOrderType: Record "FS Work Order Type";
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    CurrPage.SetSelectionFilter(FSWorkOrderType);
                    CRMIntegrationManagement.CreateNewRecordsFromSelectedCRMRecords(FSWorkOrderType);
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

    trigger OnInit()
    begin
        Codeunit.Run(Codeunit::"CRM Integration Management");
    end;

    trigger OnOpenPage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        LookupCRMTables: Codeunit "Lookup CRM Tables";
    begin
        Rec.FilterGroup(4);
        Rec.SetView(LookupCRMTables.GetIntegrationTableMappingView(Database::"FS Work Order Type"));
        Rec.FilterGroup(0);
        ShowCreateInBC := ApplicationAreaMgmtFacade.IsPremiumExperienceEnabled();
    end;

    trigger OnAfterGetRecord()
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        RecordID: RecordID;
    begin
        if CRMIntegrationRecord.FindRecordIDFromID(Rec.WorkOrderTypeId, Database::"Service Order Type", RecordID) then
            if CurrentlyCoupledFSWorkOrderType.WorkOrderTypeId = Rec.WorkOrderTypeId then begin
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


    var
        CurrentlyCoupledFSWorkOrderType: Record "FS Work Order Type";
        Coupled: Text;
        FirstColumnStyle: Text;
        ShowCreateInBC: Boolean;

    procedure SetCurrentlyCoupledFSWorkOrderType(FSWorkOrderType: Record "FS Work Order Type")
    begin
        CurrentlyCoupledFSWorkOrderType := FSWorkOrderType;
    end;
}

