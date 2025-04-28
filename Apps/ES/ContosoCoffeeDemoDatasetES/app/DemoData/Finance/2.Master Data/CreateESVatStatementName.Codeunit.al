// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.VAT.Reporting;

codeunit 10833 "Create ES VAT Statement Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
        ContosoVatStatment: Codeunit "Contoso VAT Statement";
    begin
        ContosoVatStatment.InsertVATStatementName(CreateVATStatement.VATTemplateName(), VATStatement320(), TelematicStatement320DescLbl);
        ContosoVatStatment.InsertVATStatementName(CreateVATStatement.VATTemplateName(), VATStatement392(), TelematicStatement392DescLbl);
        UpdateTemplateType(CreateVATStatement.VATTemplateName(), CreateVATStatement.VATStatementName(), 0);
        UpdateTemplateType(CreateVATStatement.VATTemplateName(), VATStatement320(), 1);
        UpdateTemplateType(CreateVATStatement.VATTemplateName(), VATStatement392(), 1);
    end;

    local procedure UpdateTemplateType(StatementTemplateName: Code[10]; StatementName: Code[10]; TemplateType: option)
    var
        VatStatementName: Record "VAT Statement Name";
    begin
        if not VatStatementName.Get(StatementTemplateName, StatementName) then
            exit;

        VatStatementName.Validate("Template Type", TemplateType);
        VatStatementName.Modify(true);
    end;

    procedure VATStatement320(): Code[10]
    begin
        exit(Statement320Lbl);
    end;

    procedure VATStatement392(): Code[10]
    begin
        exit(Statement392Lbl);
    end;

    var
        Statement320Lbl: Label 'STMT. 320', MaxLength = 10;
        Statement392Lbl: Label 'STMT. 392', MaxLength = 10;
        TelematicStatement320DescLbl: Label '320 Telematic Statement', MaxLength = 100;
        TelematicStatement392DescLbl: Label '392 XML Telematic Statement', MaxLength = 100;
}
