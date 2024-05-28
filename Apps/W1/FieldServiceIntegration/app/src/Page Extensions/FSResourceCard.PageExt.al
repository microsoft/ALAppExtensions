// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Integration.SyncEngine;

pageextension 6612 "FS Resource Card" extends "Resource Card"
{
    actions
    {
        modify(ActionGroupCRM)
        {
            Visible = CRMIntegrationEnabled and (not FSIntegrationEnabled);
        }
        addafter(ActionGroupCRM)
        {
            group(ActionFS)
            {
                Caption = 'Dynamics 365 Field Service';
                Visible = FSIntegrationEnabled;
                Enabled = (BlockedFilterApplied and (not Rec.Blocked)) or not BlockedFilterApplied;

                action(GoToProductFS)
                {
                    ApplicationArea = Suite;
                    Caption = 'Bookable Resource';
                    Image = CoupledItem;
                    ToolTip = 'Open the coupled Dynamics 365 Field Service bookable resource.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(Rec.RecordId);
                    end;
                }
                action(SynchronizeNowFS)
                {
                    AccessByPermission = TableData "CRM Integration Record" = IM;
                    ApplicationArea = Suite;
                    Caption = 'Synchronize';
                    Image = Refresh;
                    ToolTip = 'Send updated data to Dynamics 365 Sales.';

                    trigger OnAction()
                    var
                        Resource: Record Resource;
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        ResourceRecordRef: RecordRef;
                    begin
                        CurrPage.SetSelectionFilter(Resource);
                        Resource.Next();

                        if Resource.Count = 1 then
                            CRMIntegrationManagement.UpdateOneNow(Resource.RecordId)
                        else begin
                            ResourceRecordRef.GetTable(Resource);
                            CRMIntegrationManagement.UpdateMultipleNow(ResourceRecordRef);
                        end
                    end;
                }
                group(CouplingFS)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dynamics 365 Sales record.';
                    action(ManageCouplingFS)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 Sales product.';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(Rec.RecordId);
                        end;
                    }
                    action(FSMatchBasedCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Match-Based Coupling';
                        Image = CoupledItem;
                        ToolTip = 'Couple resources to products in Dynamics 365 Sales based on matching criteria.';

                        trigger OnAction()
                        var
                            Resource: Record Resource;
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(Resource);
                            RecRef.GetTable(Resource);
                            CRMIntegrationManagement.MatchBasedCoupling(RecRef);
                        end;
                    }
                    action(DeleteCouplingFS)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = D;
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Enabled = CRMIsCoupledToRecord;
                        Image = UnLinkAccount;
                        ToolTip = 'Delete the coupling to a Dynamics 365 Sales product.';

                        trigger OnAction()
                        var
                            Resource: Record Resource;
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(Resource);
                            RecRef.GetTable(Resource);
                            CRMCouplingManagement.RemoveCoupling(RecRef);
                        end;
                    }
                }
                action(FSShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization jobs for the resource table.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(Rec.RecordId);
                    end;
                }
            }
        }
        addafter(Category_Synchronize)
        {
            group(Category_FS_Synchronize)
            {
                Caption = 'Synchronize';
                Visible = FSIntegrationEnabled;

                group(Category_FS_Coupling)
                {
                    Caption = 'Coupling';
                    ShowAs = SplitButton;

                    actionref(ManageCouplingFS_Promoted; ManageCouplingFS)
                    {
                    }
                    actionref(DeleteCouplingFS_Promoted; DeleteCouplingFS)
                    {
                    }
                    actionref(FSMatchBasedCoupling_Promoted; FSMatchBasedCoupling)
                    {
                    }
                }
                actionref(SynchronizeNowFS_Promoted; SynchronizeNowFS)
                {
                }
                actionref(GoToProductFS_Promoted; GoToProductFS)
                {
                }
                actionref(FSShowLog_Promoted; FSShowLog)
                {
                }
                actionref("Unit Group_FS_Promoted"; "Unit Group")
                {
                }
            }
        }
    }

    var
        FSIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        CRMIntegrationEnabled: Boolean;
        BlockedFilterApplied: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
    begin
        if FSIntegrationEnabled then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(Rec.RecordId);
    end;

    trigger OnOpenPage()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled();
        if CRMIntegrationEnabled then begin
            FSIntegrationEnabled := FSConnectionSetup.IsEnabled();
            if FSIntegrationEnabled then begin
                IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::Dataverse);
                IntegrationTableMapping.SetRange("Delete After Synchronization", false);
                IntegrationTableMapping.SetRange("Table ID", Database::Resource);
                IntegrationTableMapping.SetRange("Integration Table ID", Database::"FS Bookable Resource");
                if IntegrationTableMapping.FindFirst() then
                    BlockedFilterApplied := IntegrationTableMapping.GetTableFilter().Contains('Field38=1(0)');
            end;
        end;
    end;
}