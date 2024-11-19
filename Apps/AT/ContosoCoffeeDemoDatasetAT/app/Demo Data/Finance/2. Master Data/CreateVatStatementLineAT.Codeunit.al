codeunit 11156 "Create VAT Statement Line AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        CreateVATStatementLine();
    end;

    local procedure CreateVATStatementLine()
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateVATStatement: Codeunit "Create VAT Statement";
        CreateVATPostingGroupAT: Codeunit "Create VAT Posting Group AT";

    begin
        ContosoVatStatement.SetOverwriteData(true);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 10000, '1010', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupAT.VAT20(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 1, SalesVAT20outgoingLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 20000, '1019', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1010..1018', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, SalesVAT20outgoingLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 30000, '1020', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupAT.VAT10(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 1, SalesVAT10outgoingLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 40000, '1050', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupAT.VAT20(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, false, 1, VAT20onEUPurchasesetcLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 50000, '1060', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupAT.VAT10(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, false, 1, VAT10onEUPurchasesetcLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 60000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeparationLineLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 70000, '1099', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1010..1090', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 80000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 90000, '1110', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupAT.VAT20(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseVAT20DomesticLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 100000, '1120', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupAT.VAT10(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseVAT10DomesticLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 110000, '1150', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupAT.VAT20(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseVAT20EULbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 120000, '1160', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupAT.VAT10(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseVAT10EULbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 130000, '1179', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1110..1170', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, PurchaseVATingoingLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 140000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 150000, '1180', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, FuelTaxLbl, '7110');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 160000, '1181', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ElectricityTaxLbl, '7120');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 170000, '1182', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, NaturalGasTaxLbl, '7130');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 180000, '1183', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, CoalTaxLbl, '7140');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 190000, '1184', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, CO2TaxLbl, '7150');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 200000, '1185', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, WaterTaxLbl, '7160');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 210000, '1189', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1180..1188', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalTaxesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 220000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeparationLineLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 230000, '1199', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1159|1189', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalDeductionsLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 240000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeparationLineLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 250000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 260000, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1099|1199', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, VATPayableLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 270000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeparationLineLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 280000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 290000, '1210', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupAT.VAT20(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, ValueofEUPurchases20Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 300000, '1220', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupAT.VAT10(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, ValueofEUPurchases10Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 310000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 320000, '1240', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupAT.VAT20(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, ValueofEUSales20Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 330000, '1250', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupAT.VAT10(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, ValueofEUSales10Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 340000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 350000, '1310', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroupAT.VAT20(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, NonVATLiableSalesOverseasLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 360000, '1320', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroupAT.VAT10(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, NonVATLiableSalesOverseasLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 370000, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1310..1330', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, NonVATLiableSalesOverseasLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 380000, '1340', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupAT.NOVAT(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, NonVATLiableSalesDomesticLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), Default(), 390000, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1340..1348', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, NonVATLiableSalesDomesticLbl, '');
        ContosoVatStatement.SetOverwriteData(false);
    end;

    procedure Default(): Code[10]
    begin
        exit(DefaultTok);
    end;

    var
        ContosoVatStatement: Codeunit "Contoso VAT Statement";
        DefaultTok: Label 'DEFAULT', MaxLength = 10;
        SalesVAT20outgoingLbl: Label 'Sales VAT 20 % (outgoing)', MaxLength = 100;
        SalesVAT10outgoingLbl: Label 'Sales VAT 10 % (outgoing)', MaxLength = 100;
        VAT20onEUPurchasesetcLbl: Label 'VAT 20 % % on EU Purchases etc.', MaxLength = 100;
        VAT10onEUPurchasesetcLbl: Label 'VAT 10 % % on EU Purchases etc.', MaxLength = 100;
        TotalLbl: Label 'Total', MaxLength = 100;
        PurchaseVAT20DomesticLbl: Label 'Purchase VAT 20 % Domestic', MaxLength = 100;
        PurchaseVAT10DomesticLbl: Label 'Purchase VAT 10 % Domestic', MaxLength = 100;
        PurchaseVAT20EULbl: Label 'Purchase VAT 20 % EU', MaxLength = 100;
        PurchaseVAT10EULbl: Label 'Purchase VAT 10 % EU', MaxLength = 100;
        PurchaseVATingoingLbl: Label 'Purchase VAT (ingoing)', MaxLength = 100;
        FuelTaxLbl: Label 'Fuel Tax', MaxLength = 100;
        ElectricityTaxLbl: Label 'Electricity Tax', MaxLength = 100;
        NaturalGasTaxLbl: Label 'Natural Gas Tax', MaxLength = 100;
        CoalTaxLbl: Label 'Coal Tax', MaxLength = 100;
        CO2TaxLbl: Label 'CO2 Tax', MaxLength = 100;
        WaterTaxLbl: Label 'Water Tax', MaxLength = 100;
        TotalTaxesLbl: Label 'Total Taxes', MaxLength = 100;
        TotalDeductionsLbl: Label 'Total Deductions', MaxLength = 100;
        VATPayableLbl: Label 'VAT Payable', MaxLength = 100;
        ValueofEUPurchases20Lbl: Label 'Value of EU Purchases 20 %', MaxLength = 100;
        ValueofEUPurchases10Lbl: Label 'Value of EU Purchases 10 %', MaxLength = 100;
        ValueofEUSales20Lbl: Label 'Value of EU Sales 20 %', MaxLength = 100;
        ValueofEUSales10Lbl: Label 'Value of EU Sales 10 %', MaxLength = 100;
        NonVATLiableSalesOverseasLbl: Label 'Non-VAT liable sales, Overseas', MaxLength = 100;
        NonVATLiableSalesDomesticLbl: Label 'Non-VAT liable sales, Domestic', MaxLength = 100;
        SeparationLineLbl: Label '--------------------------------------------------', Locked = true;
}