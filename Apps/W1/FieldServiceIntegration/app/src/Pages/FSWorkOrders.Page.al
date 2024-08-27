// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Service.Setup;
using System.Environment.Configuration;
using Microsoft.Integration.D365Sales;
using Microsoft.Service.Document;

page 6616 "FS Work Orders"
{
    ApplicationArea = Service;
    Caption = 'Work Orders - Dynamics 365 Field Service';
    Editable = false;
    PageType = List;
    SourceTable = "FS Work Order";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Service;
                    StyleExpr = FirstColumnStyle;
                    ToolTip = 'Specifies the work order type code.';
                }
                field(WorkOrderType; Rec.WorkOrderType)
                {
                    ApplicationArea = Service;
                    Visible = false;
                    ToolTip = 'Specifies the work order type.';
                }
                field(WorkOrderTypeName; FSWorkOrderType.Name)
                {
                    Caption = 'Work Order Type';
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the work order type.';
                }
                field(StatusCode; Rec.StatusCode)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the status of the work order.';
                }
                field(CreatedOn; Rec.CreatedOn)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the date and time when the work order was created.';
                }
                field(ServiceAccount; Rec.ServiceAccount)
                {
                    ApplicationArea = Service;
                    Visible = false;
                    ToolTip = 'Specifies the service account for the work order.';
                }
                field(ServiceAccountName; CRMAccountService.Name)
                {
                    Caption = 'Service Account';
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the service account for the work order.';
                }
                field(Address1; Rec.Address1)
                {
                    ApplicationArea = Service;
                    Visible = false;
                    ToolTip = 'Specifies the address for the work order.';
                }
                field(Address2; Rec.Address2)
                {
                    ApplicationArea = Service;
                    Visible = false;
                    ToolTip = 'Specifies the address for the work order.';
                }
                field(Address3; Rec.Address3)
                {
                    ApplicationArea = Service;
                    Visible = false;
                    ToolTip = 'Specifies the address for the work order.';
                }
                field(PostalCode; Rec.PostalCode)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the address for the work order.';
                    Visible = false;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the address for the work order.';
                    Visible = false;
                }
                field(BillingAccount; Rec.BillingAccount)
                {
                    ApplicationArea = Service;
                    Visible = false;
                    ToolTip = 'Specifies the billing account for the work order.';
                }
                field(BillingAccountName; CRMAccountBilling.Name)
                {
                    Caption = 'Billing Account';
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the billing account for the work order.';
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
                    FSWorkOrder: Record "FS Work Order";
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    CurrPage.SetSelectionFilter(FSWorkOrder);
                    CRMIntegrationManagement.CreateNewRecordsFromSelectedCRMRecords(FSWorkOrder);
                end;
            }
            action(OpenInBC)
            {
                ApplicationArea = Suite;
                Caption = 'Open in Business Central';
                Image = Document;
                ToolTip = 'Opens the entity in Business Central.';
                Visible = ShowOpenInBC;

                trigger OnAction()
                var
                    ServiceHeader: Record "Service Header";
                begin
                    RecordID.GetRecord().SetTable(ServiceHeader);
                    Page.Run(Page::"Service Order", ServiceHeader);
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
                actionref(OpenInBC_Promoted; OpenInBC)
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
        Rec.SetView(LookupCRMTables.GetIntegrationTableMappingView(Database::"FS Work Order"));
        Rec.FilterGroup(0);
        ShowCreateInBC := ApplicationAreaMgmtFacade.IsPremiumExperienceEnabled();
    end;

    trigger OnAfterGetRecord()
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if CRMIntegrationRecord.FindRecordIDFromID(Rec.WorkOrderId, Database::"Service Header", RecordID) then begin
            if CurrentlyCoupledFSWorkOrder.WorkOrderId = Rec.WorkOrderId then begin
                Coupled := 'Current';
                FirstColumnStyle := 'Strong';
                Rec.Mark(true);
            end else begin
                Coupled := 'Yes';
                FirstColumnStyle := 'Subordinate';
                Rec.Mark(false);
            end;
            ShowOpenInBC := true;
        end else begin
            Coupled := 'No';
            FirstColumnStyle := 'None';
            ShowOpenInBC := false;
            Rec.Mark(true);
        end;

        if not CRMAccountService.Get(Rec.ServiceAccount) then
            Clear(CRMAccountService);
        if not CRMAccountBilling.Get(Rec.ServiceAccount) then
            Clear(CRMAccountBilling);
        if not FSWorkOrderType.Get(Rec.WorkOrderType) then
            Clear(FSWorkOrderType);
    end;


    var
        CurrentlyCoupledFSWorkOrder: Record "FS Work Order";
        FSWorkOrderType: Record "FS Work Order Type";
        CRMAccountService: Record "CRM Account";
        CRMAccountBilling: Record "CRM Account";
        RecordID: RecordID;
        Coupled: Text;
        FirstColumnStyle: Text;
        ShowCreateInBC: Boolean;
        ShowOpenInBC: Boolean;

    procedure SetCurrentlyCoupledFSWorkOrder(FSWorkOrder: Record "FS Work Order")
    begin
        CurrentlyCoupledFSWorkOrder := FSWorkOrder;
    end;
}

