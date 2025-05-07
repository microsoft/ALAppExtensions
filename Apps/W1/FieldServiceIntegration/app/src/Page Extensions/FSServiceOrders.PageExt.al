// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Service.Document;
using Microsoft.Integration.Dataverse;

pageextension 6624 "FS Service Orders" extends "Service Orders"
{
    layout
    {
        addlast(Control1)
        {
            field("Coupled to FS"; Rec."Coupled to FS")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the entity is coupled to an entity in Field Service.';
                Visible = FSIntegrationEnabled;
            }
        }
    }

    actions
    {
        addlast(navigation)
        {
            group(ActionFS)
            {
                Caption = 'Dynamics 365 Field Service';
                Enabled = FSIntegrationEnabled;

                action(GoToProductFS)
                {
                    ApplicationArea = Suite;
                    Caption = 'Work Order';
                    Image = ViewServiceOrder;
                    ToolTip = 'Open the coupled Dynamics 365 Field Service record.';

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
                        ServiceHeader: Record "Service Header";
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        ServiceHeaderRecordRef: RecordRef;
                    begin
                        CurrPage.SetSelectionFilter(ServiceHeader);
                        ServiceHeader.Next();

                        if ServiceHeader.Count = 1 then
                            CRMIntegrationManagement.UpdateOneNow(ServiceHeader.RecordId)
                        else begin
                            ServiceHeaderRecordRef.GetTable(ServiceHeader);
                            CRMIntegrationManagement.UpdateMultipleNow(ServiceHeaderRecordRef);
                        end
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
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 Field Service record.';

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
                        ToolTip = 'Couple service orders to work orders in Dynamics 365 Field Service record based on matching criteria.';

                        trigger OnAction()
                        var
                            ServiceHeader: Record "Service Header";
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(ServiceHeader);
                            RecRef.GetTable(ServiceHeader);
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
                        ToolTip = 'Delete the coupling to a Dynamics 365 Field Service record.';

                        trigger OnAction()
                        var
                            ServiceHeader: Record "Service Header";
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                            ServiceHeaderRecordRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(ServiceHeader);
                            ServiceHeaderRecordRef.GetTable(ServiceHeader);
                            CRMCouplingManagement.RemoveCoupling(ServiceHeaderRecordRef);
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
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled();
        if CRMIntegrationEnabled then
            FSIntegrationEnabled := FSConnectionSetup.IsEnabled();
    end;
}
