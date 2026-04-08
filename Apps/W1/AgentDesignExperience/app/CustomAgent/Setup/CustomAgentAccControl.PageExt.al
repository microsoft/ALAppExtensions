// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Security.AccessControl;

pageextension 4350 "Custom Agent Acc Control" extends "Select Agent Permissions Part"
{
    actions
    {
        addlast(Processing)
        {
            action(Assign)
            {
                ApplicationArea = All;
                Caption = 'Assign my permissions';
                ToolTip = 'Assign your permissions to the agent for the current company.';
                Image = Permission;

                trigger OnAction()
                begin
                    AssignMyPermissions();
                end;
            }
        }
    }

    local procedure AssignMyPermissions()
    var
        AccessControl: Record "Access Control";
    begin
        if not GetAccessControlForSingleCompany(GlobalSingleCompanyName) then
            Error(CannotAssignPermissionsMultipleCompaniesErr);

        if not Confirm(AssignMyPermissionsQst, true) then
            exit;

        Rec.Reset();
        Rec.DeleteAll();

        AddAccessControlsForCompany(AccessControl, CompanyName());
        AddAccessControlsForCompany(AccessControl, '');
    end;

    local procedure AddAccessControlsForCompany(var AccessControl: Record "Access Control"; SourceCompanyName: Text)
    var
        TargetCompanyName: Text[30];
    begin
#pragma warning disable AA0139
        TargetCompanyName := CompanyName();
#pragma warning restore AA0139

        AccessControl.Reset();
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Company Name", SourceCompanyName);
        if AccessControl.FindSet() then
            repeat
                Clear(Rec);
                if not Rec.Get(TargetCompanyName, AccessControl.Scope, AccessControl."App ID", AccessControl."Role ID") then begin
                    Rec."Role ID" := AccessControl."Role ID";
                    Rec.Scope := AccessControl.Scope;
                    Rec."App ID" := AccessControl."App ID";
                    Rec."Company Name" := TargetCompanyName;
                    Rec.Insert();
                end;
            until AccessControl.Next() = 0;
    end;

    var
        AssignMyPermissionsQst: Label 'Assigning your permissions for the current company to the agent will clear its existing permissions if any.\\Do you want to continue?';
        GlobalSingleCompanyName: Text[30];
        CannotAssignPermissionsMultipleCompaniesErr: Label 'Cannot assign your permissions for the current company because the agent is set up to work in multiple companies.';
}