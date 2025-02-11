// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Service.Document;
using Microsoft.Integration.Dataverse;

pageextension 6627 "FS Service Order Subform" extends "Service Order Subform"
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

    var
        FSIntegrationEnabled: Boolean;
        CRMIntegrationEnabled: Boolean;

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
