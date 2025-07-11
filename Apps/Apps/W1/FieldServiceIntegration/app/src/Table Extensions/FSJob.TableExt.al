// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Projects.Project.Job;
using Microsoft.Integration.SyncEngine;

tableextension 6610 "FS Job" extends Job
{
    fields
    {
        modify(Blocked)
        {
            trigger OnAfterValidate()
            var
                FSConnectionSetup: Record "FS Connection Setup";
            begin
                if Rec.Blocked <> Rec.Blocked::" " then
                    if FSConnectionSetup.IsEnabled() then
                        MoveFilterOnProjectTaskMapping();
            end;
        }
        modify("Apply Usage Link")
        {
            trigger OnAfterValidate()
            var
                FSConnectionSetup: Record "FS Connection Setup";
            begin
                if FSConnectionSetup.IsEnabled() then
                    MoveFilterOnProjectTaskMapping();
            end;
        }
    }

    local procedure MoveFilterOnProjectTaskMapping()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobTask: Record "Job Task";
    begin
        if Rec.Blocked <> Rec.Blocked::" " then
            exit;

        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::Dataverse);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Table ID", Database::"Job Task");
        IntegrationTableMapping.SetRange("Integration Table ID", Database::"FS Project Task");
        if not IntegrationTableMapping.FindFirst() then
            exit;

        JobTask.SetRange("Job No.", Rec."No.");
        JobTask.SetCurrentKey(SystemCreatedAt);
        JobTask.SetAscending(SystemCreatedAt, true);
        if not JobTask.FindFirst() then
            exit;

        if JobTask.SystemCreatedAt = 0DT then begin
            IntegrationTableMapping."Synch. Int. Tbl. Mod. On Fltr." := 0DT;
            IntegrationTableMapping.Modify();
            exit;
        end;

        if IntegrationTableMapping."Synch. Int. Tbl. Mod. On Fltr." > JobTask.SystemCreatedAt then begin
            IntegrationTableMapping."Synch. Int. Tbl. Mod. On Fltr." := JobTask.SystemCreatedAt;
            IntegrationTableMapping.Modify();
        end;
    end;
}