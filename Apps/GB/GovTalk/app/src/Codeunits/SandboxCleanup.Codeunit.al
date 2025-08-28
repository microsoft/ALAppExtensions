// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.DataAdministration;

#pragma warning disable AA0247
codeunit 10585 "Sandbox Cleanup"
{

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearConfiguration(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        GovTalkSetup: Record "Gov Talk Setup";
        nullGUID: Guid;
    begin
        if CompanyName() <> CompanyName then
            GovTalkSetup.ChangeCompany(CompanyName);

        GovTalkSetup.ModifyAll(Password, nullGUID);
    end;
}

