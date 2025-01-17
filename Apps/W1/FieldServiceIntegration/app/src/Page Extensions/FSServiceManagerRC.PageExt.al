// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Service.RoleCenters;

pageextension 6621 "FS Service Manager RC" extends "Service Manager Role Center"
{
    actions
    {
        addlast(sections)
        {
            group(GroupFS)
            {
                Caption = 'Dynamics 365 Field Service';

                action("Bookable Resources - Field Service")
                {
                    ApplicationArea = Suite;
                    Caption = 'Bookable Resources - Dynamics 365 Field Service';
                    RunObject = Page "FS Bookable Resource List";
                }
                action("Customer Assets - Field Service")
                {
                    ApplicationArea = Suite;
                    Caption = 'Customer Assets - Dynamics 365 Field Service';
                    RunObject = Page "FS Customer Asset List";
                }
                action("Records Skipped For Synch.")
                {
                    ApplicationArea = Suite;
                    Caption = 'Coupled Data Synchronization Errors';
                    RunObject = Page "CRM Skipped Records";
                    AccessByPermission = TableData "CRM Integration Record" = R;
                }
            }
        }
    }
}