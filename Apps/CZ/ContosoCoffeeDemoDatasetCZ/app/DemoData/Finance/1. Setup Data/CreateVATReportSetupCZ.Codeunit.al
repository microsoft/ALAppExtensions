// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoTool.Helpers;

codeunit 31281 "Create VAT Report Setup CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "VAT Report Setup" = rim;

    trigger OnRun()
    begin
        CreateVATReportsConfiguration();
        UpdateVATReportSetup();
    end;

    local procedure UpdateVATReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        VATReportSetup.Get();
        VATReportSetup.Validate("VAT Return No. Series", CreateNoSeriesCZ.VATReturn());
        VATReportSetup.Validate("VAT Return Period No. Series", CreateNoSeriesCZ.VATReturnPeriod());
        VATReportSetup.Validate("Report Version", CZVersion());
        Evaluate(VATReportSetup."Period Reminder Calculation", '<5D>');
        VATReportSetup.Validate("Report VAT Note", true);
        VATReportSetup.Modify(true);
    end;

    local procedure CreateVATReportsConfiguration()
    var
        ContosoVATStatementCZ: Codeunit "Contoso VAT Statement CZ";
        CreateVATStatement: Codeunit "Create VAT Statement";
    begin
        ContosoVATStatementCZ.InsertVATReportConfiguration(Enum::"VAT Report Configuration"::"VAT Return", CZVersion(), Codeunit::"VAT Report Suggest Lines CZL", Codeunit::"VAT Report Export CZL", Codeunit::"VAT Report Submit CZL", Codeunit::"VAT Report Validate CZL", CreateVATStatement.VATTemplateName(), CreateVATStatement.VATStatementName());
    end;

    procedure CZVersion(): Code[10]
    begin
        exit(CZVersionTok);
    end;

    var
        CZVersionTok: Label 'CZ', MaxLength = 10;
}
