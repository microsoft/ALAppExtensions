// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.DataAdministration;
using System.Environment;

codeunit 6398 "Env. Cleanup Subscr."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    local procedure CleanupCompanyConfiguration(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        ConnectionSetup: Record "Connection Setup";
        Participation: Record Participation;
        ParticipationProfiles: Record "Activated Net. Prof.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;

        if CompanyName = '' then
            exit;

        ConnectionSetup.ChangeCompany(CompanyName);
        ConnectionSetup.DeleteAll();

        Participation.ChangeCompany(CompanyName);
        Participation.DeleteAll();

        ParticipationProfiles.ChangeCompany(CompanyName);
        ParticipationProfiles.DeleteAll();
    end;
}