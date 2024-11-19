codeunit 10897 "Create VAT Statement FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateVATRegNoFormat();
        UpdateVatStatementLine();
    end;

    local procedure CreateVATRegNoFormat()
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
        ContosoCountryOrRegion: Codeunit "Contoso Country Or Region";
    begin
        ContosoCountryOrRegion.InsertVATRegNoFormat(CreateCountryRegion.CZ(), 40000, CZFormatLbl);
        ContosoCountryOrRegion.InsertVATRegNoFormat(CreateCountryRegion.CZ(), 50000, CZFormat1Lbl);
        ContosoCountryOrRegion.InsertVATRegNoFormat(CreateCountryRegion.CZ(), 60000, CZFormat2Lbl)
    end;

    local procedure UpdateVatStatementLine()
    var
        ContosoVatStatement: Codeunit "Contoso VAT Statement";
        CreateVATStatement: Codeunit "Create VAT Statement";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoVatStatement.SetOverwriteData(true);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 10000, '1010', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 1, StrSubstNo(SalesVATPERCENToutgoingLbl, 20));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 20000, '1020', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 1, StrSubstNo(SalesVATPERCENToutgoingLbl, 5));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 30000, '1050', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, false, 1, StrSubstNo(VATPERCENTonEUPurchasesetcLbl, 20));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 40000, '1060', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, false, 1, StrSubstNo(VATPERCENTonEUPurchasesetcLbl, 5));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 50000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeperationLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 60000, '1099', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1010..1090', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 70000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 80000, '1110', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, StrSubstNo(PurchaseVATPERCENTDomesticLbl, 20));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 90000, '1120', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, StrSubstNo(PurchaseVATPERCENTDomesticLbl, 5));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 100000, '1150', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, StrSubstNo(PurchaseVATPERCENTEULbl, 20));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 110000, '1160', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, StrSubstNo(PurchaseVATPERCENTEULbl, 5));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 120000, '1179', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1110..1170', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, PurchaseVATingoingLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 130000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeperationLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 140000, '1199', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1159|1189', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalDeductionsLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 150000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeperationLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 160000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 170000, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1099|1199', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, VATPayableLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 180000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeperationLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 190000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 200000, '1210', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, StrSubstNo(ValueofEUPurchasesPERCENTLbl, 20));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 210000, '1220', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, StrSubstNo(ValueofEUPurchasesPERCENTLbl, 5));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 220000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 230000, '1240', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, StrSubstNo(ValueofEUSalesPERCENTLbl, 20));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 240000, '1250', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, StrSubstNo(ValueofEUSalesPERCENTLbl, 5));
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 250000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 260000, '1310', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, NonVATliablesalesOverseasLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 270000, '1320', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, NonVATliablesalesOverseasLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 280000, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1310..1330', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, NonVATliablesalesOverseasLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 290000, '1340', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, NonVATliablesalesDomesticLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 300000, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1340..1348', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, NonVATliablesalesDomesticLbl);
        ContosoVatStatement.SetOverwriteData(false);
    end;

    var
        CZFormatLbl: Label '########', MaxLength = 20, Locked = true;
        CZFormat1Lbl: Label '#########', MaxLength = 20, Locked = true;
        CZFormat2Lbl: Label '##########', MaxLength = 20, Locked = true;
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        SalesVATPERCENToutgoingLbl: Label 'Sales VAT %1 % (outgoing)', Comment = '%1 is Vat Percentage', MaxLength = 100;
        VATPERCENTonEUPurchasesetcLbl: Label 'VAT %1 % % on EU Purchases etc.', Comment = '%1 is Vat Percentage', MaxLength = 100;
        PurchaseVATPERCENTDomesticLbl: Label 'Purchase VAT %1 % Domestic', Comment = '%1 is Vat Percentage', MaxLength = 100;
        PurchaseVATPERCENTEULbl: Label 'Purchase VAT %1 % EU', Comment = '%1 is Vat Percentage', MaxLength = 100;
        ValueofEUPurchasesPERCENTLbl: Label 'Value of EU Purchases %1 %', Comment = '%1 is EU Purchase Percentage', MaxLength = 100;
        ValueofEUSalesPERCENTLbl: Label 'Value of EU Sales %1 %', Comment = '%1 is EU Sales Percentage', MaxLength = 100;
        TotalLbl: Label 'Total', MaxLength = 100;
        PurchaseVATingoingLbl: Label 'Purchase VAT (ingoing)', MaxLength = 100;
        TotalDeductionsLbl: Label 'Total Deductions', MaxLength = 100;
        VATPayableLbl: Label 'VAT Payable', MaxLength = 100;
        NonVATliablesalesOverseasLbl: Label 'Non-VAT liable sales, Overseas', MaxLength = 100;
        NonVATliablesalesDomesticLbl: Label 'Non-VAT liable sales, Domestic', MaxLength = 100;
        SeperationLbl: Label '--------------------------------------------------';
}