// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Utilities;
using System.Environment.Configuration;

codeunit 4592 "SOA Events"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        SOASetup: Record "SOA Setup";
        SOAKPIEntry: Record "SOA KPI Entry";
        SOAKPI: Record "SOA KPI";
        SOAEmail: Record "SOA Email";
    begin
        SOASetup.ChangeCompany(NewCompanyName);
        SOASetup.DeleteAll();

        SOAKPIEntry.ChangeCompany(NewCompanyName);
        SOAKPIEntry.DeleteAll();

        SOAKPI.ChangeCompany(NewCompanyName);
        SOAKPI.DeleteAll();

        SOAEmail.ChangeCompany(NewCompanyName);
        SOAEmail.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Classification Eval. Data", 'OnCreateEvaluationDataOnAfterClassifyTablesToNormal', '', false, false)]
    local procedure ClassifyDataSensitivity()
    var
        DataClassificationEvalData: Codeunit "Data Classification Eval. Data";
    begin
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"SOA Setup");
    end;
}