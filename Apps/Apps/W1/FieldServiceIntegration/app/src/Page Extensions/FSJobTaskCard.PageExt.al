// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Projects.Project.Job;
using Microsoft.Integration.Dataverse;

pageextension 6610 "FS Job Task Card" extends "Job Task Card"
{
    actions
    {
        addafter("&Job Task")
        {
            group(ActionFS)
            {
                Caption = 'Dynamics 365 Field Service';
                Enabled = FSActionGroupEnabled;

                action(GoToProductFS)
                {
                    ApplicationArea = Suite;
                    Caption = 'Project Task in Field Service';
                    Image = CoupledItem;
                    ToolTip = 'Open the coupled Dynamics 365 Field Service entity.';

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
                    ToolTip = 'View integration synchronization jobs for the job task table.';

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
        FSActionGroupEnabled: Boolean;
        FSIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        CRMIntegrationEnabled: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
    begin
        if CRMIntegrationEnabled then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(Rec.RecordId);
    end;

    trigger OnOpenPage()
    var
        Job: Record Job;
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        ApplyUsageLink: Boolean;
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled();
        if CRMIntegrationEnabled then
            FSIntegrationEnabled := FSConnectionSetup.IsEnabled();

        if Job.Get(Rec."Job No.") then
            ApplyUsageLink := Job."Apply Usage Link";

        FSActionGroupEnabled := FSIntegrationEnabled and (Rec."Job Task Type" = Rec."Job Task Type"::Posting) and ApplyUsageLink;
    end;
}