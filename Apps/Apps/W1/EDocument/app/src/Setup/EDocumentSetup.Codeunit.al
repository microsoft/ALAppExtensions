// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;
using System.DataAdministration;

codeunit 6145 "E-Document Setup"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InstallWorkFlowTableRelation();
        AddEDocumentLogToAllowedTables();
    end;

    local procedure AddEDocumentLogToAllowedTables()
    begin
        InsertRetentionPolicySetup(Database::"E-Document Log");
        InsertRetentionPolicySetup(Database::"E-Document Integration Log");
        InsertRetentionPolicySetup(Database::"E-Doc. Data Storage");
        InsertRetentionPolicySetup(Database::"E-Doc. Mapping Log");
    end;

    local procedure InsertRetentionPolicySetup(TableId: Integer)
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        RetenPolAllowedTables.AddAllowedTable(TableId);

        if not RetentionPolicySetup.Get(TableId) then begin
            RetentionPolicySetup.Validate("Table Id", TableId);
            RetentionPolicySetup.Validate("Apply to all records", true);
            RetentionPolicySetup.Validate(Enabled, false);

            RetentionPolicySetup.Insert(true);
        end;
    end;

    local procedure InstallWorkFlowTableRelation()
    var
        WorkflowTableRelation: Record "Workflow - Table Relation";
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        WorkflowTableRelation."Table ID" := Database::"E-Document";
        WorkflowTableRelation."Field ID" := EDocument.FieldNo(EDocument."Entry No");
        WorkflowTableRelation."Related Table ID" := Database::"E-Document Service Status";
        WorkflowTableRelation."Related Field ID" := EDocumentServiceStatus.FieldNo("E-Document Entry No");
        if WorkflowTableRelation.Insert() then;
    end;
}
