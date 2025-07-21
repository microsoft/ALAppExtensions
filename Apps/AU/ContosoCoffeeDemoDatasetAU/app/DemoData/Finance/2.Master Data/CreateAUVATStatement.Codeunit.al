// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.DemoTool.Helpers;

codeunit 17162 "Create AU VAT Statement"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
    begin
        ContosoVatStatement.InsertVATStatementTemplate(BASTemplateName(), BASStatementDescLbl, Page::"VAT Statement", Report::"VAT Statement");

        ContosoVatStatement.InsertVATStatementName(BASTemplateName(), CreateVATStatement.VATStatementName(), StatementNameDescLbl);
    end;

    procedure BASTemplateName(): Code[10]
    begin
        exit(BASTemplateNameTok);
    end;

    var
        ContosoVatStatement: Codeunit "Contoso VAT Statement";
        BASTemplateNameTok: Label 'BAS', Locked = true;
        StatementNameDescLbl: Label 'Default Statement', MaxLength = 100;
        BASStatementDescLbl: Label 'Business Activity Statement', MaxLength = 80;
}
