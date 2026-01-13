// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Environment;
using Microsoft.Utilities;

codeunit 10575 "Gov Talk Setup"
{

    trigger OnRun()
    begin
    end;

    var
        GovTalkGatewayTok: Label 'https://transaction-engine.tax.service.gov.uk/submission', Locked = true;
        GovTalkGatewayTestTok: Label 'https://test-transaction-engine.tax.service.gov.uk/submission', Locked = true;
        GovTalkSetupLbl: Label 'GovTalk Setup';
        GovTalkVendorIdTok: Label '7572';

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure RegisterServiceInServiceConnections(var ServiceConnection: Record "Service Connection")
    var
        GovTalkSetup: Record "Gov Talk Setup";
    begin
        if not GovTalkSetup.FindFirst() then begin
            GovTalkSetup.Init();
            GovTalkSetup.Endpoint := EndpointURL();
            GovTalkSetup.Insert();
            GovTalkSetup.SaveVendorID(GovTalkVendorIdTok);
        end;

        if (GovTalkSetup.Endpoint <> '') and (not IsNullGuid(GovTalkSetup.Password)) then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;

        ServiceConnection.InsertServiceConnection(ServiceConnection, GovTalkSetup.RecordId,
          GovTalkSetupLbl, '', PAGE::"Gov Talk Setup");
    end;

    local procedure EndpointURL(): Text[250]
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        if Company."Evaluation Company" then
            exit(GovTalkGatewayTestTok);

        exit(GovTalkGatewayTok);
    end;
}

