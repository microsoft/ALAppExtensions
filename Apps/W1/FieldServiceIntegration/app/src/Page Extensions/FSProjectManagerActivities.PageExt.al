// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Projects.RoleCenters;
using Microsoft.Integration.SyncEngine;
using Microsoft.Integration.Dataverse;

pageextension 6616 "FS Project Manager Activities" extends "Project Manager Activities"
{
    layout
    {
        addlast(content)
        {
            cuegroup("FS Data Integration")
            {
                Caption = 'Data Integration';
                Visible = ShowFSIntegrationCues;

                field("FS Integration Errors"; Rec."FS Int. Errors")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Integration Errors';
                    DrillDownPageID = "Integration Synch. Error List";
                    ToolTip = 'Specifies the number of errors related to data integration with Dynamics 365 Field Service.';
                    Visible = ShowFSIntegrationCues;
                }
                field("FS Coupled Data Synch Errors"; Rec."Coupled Data Sync Errors")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Coupled Data Synchronization Errors';
                    DrillDownPageID = "CRM Skipped Records";
                    ToolTip = 'Specifies the number of errors that occurred in the latest synchronization of coupled data between Business Central and Dynamics 365 Field Service.';
                    Visible = ShowFSIntegrationCues;
                }
            }
        }
    }

    var
        ShowFSIntegrationCues: Boolean;

    trigger OnOpenPage()
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        ShowFSIntegrationCues := FSConnectionSetup.IsEnabled();
    end;
}