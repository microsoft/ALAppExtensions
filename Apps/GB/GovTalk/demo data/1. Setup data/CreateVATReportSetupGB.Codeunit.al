// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.VAT.GovTalk;

codeunit 10550 "Create VAT Report Setup GB"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        CreateVATReportSetup: Codeunit "Create VAT Report Setup";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        ContosoVATStatement.InsertVATReportConfiguration(Enum::"VAT Report Configuration"::"VAT Return", GovTalkVersion(), Codeunit::"VAT Report Suggest Lines", Codeunit::"GovTalk Validate VAT Report");
        if VATReportsConfiguration.Get(VATReportsConfiguration."VAT Report Type"::"EC Sales List", CreateVATReportSetup.CurrentVersion()) then begin
            VATReportsConfiguration.Validate("Submission Codeunit ID", Codeunit::"EC Sales List Submit GB");
            VATReportsConfiguration.Modify(true);
        end;
        if VATReportsConfiguration.Get(VATReportsConfiguration."VAT Report Type"::"VAT Return", GovTalkVersion()) then begin
            VATReportsConfiguration.Validate("Content Codeunit ID", Codeunit::"Create VAT Declaration Req.");
            VATReportsConfiguration.Validate("Submission Codeunit ID", Codeunit::"Submit VAT Declaration Req.");
            VATReportsConfiguration.Modify(true);
        end;
    end;

    procedure GovTalkVersion(): Code[10]
    begin
        exit(GovTalkVersionTok);
    end;

    var
        GovTalkVersionTok: Label 'GOVTALK', MaxLength = 10;
}
