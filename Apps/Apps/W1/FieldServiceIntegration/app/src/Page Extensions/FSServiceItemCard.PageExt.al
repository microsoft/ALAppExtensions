// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Service.Item;
using Microsoft.Integration.Dataverse;
using Microsoft.Integration.SyncEngine;

pageextension 6619 "FS Service Item Card" extends "Service Item Card"
{
    actions
    {
        addafter(History)
        {
            group(ActionFS)
            {
                Caption = 'Dynamics 365 Field Service';
                Visible = FSIntegrationEnabled;
                Enabled = (BlockedFilterApplied and (Rec.Blocked = Rec.Blocked::" ")) or not BlockedFilterApplied;

                action(GoToProductFS)
                {
                    ApplicationArea = Suite;
                    Caption = 'Customer Asset';
                    Image = CoupledItem;
                    ToolTip = 'Open the coupled Dynamics 365 Field Service customer asset.';

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
                    ToolTip = 'Send updated data to Dynamics 365 Field Service.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.UpdateOneNow(Rec.RecordId);
                    end;
                }
                group(CouplingFS)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dynamics 365 Field Service record.';
                    action(ManageCouplingFS)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 Field Service product.';

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
                        ToolTip = 'Couple resources to products in Field Service based on matching criteria.';

                        trigger OnAction()
                        var
                            ServiceItem: Record "Service Item";
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(ServiceItem);
                            RecRef.GetTable(ServiceItem);
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
                        ToolTip = 'Delete the coupling to a Dynamics 365 Field Service entity.';

                        trigger OnAction()
                        var
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                        begin
                            CRMCouplingManagement.RemoveCoupling(Rec.RecordId);
                        end;
                    }
                }
                action(FSShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization jobs for the service item table.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(Rec.RecordId);
                    end;
                }
            }
        }

        addlast(Promoted)
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
            }
        }
    }


    var
        FSIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        CRMIntegrationEnabled: Boolean;
        BlockedFilterApplied: Boolean;

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
                IntegrationTableMapping.SetRange("Table ID", Database::"Service Item");
                IntegrationTableMapping.SetRange("Integration Table ID", Database::"FS Customer Asset");
                if IntegrationTableMapping.FindFirst() then
                    BlockedFilterApplied := IntegrationTableMapping.GetTableFilter().Contains('Field40=1(0)');
            end;
        end;
    end;
}