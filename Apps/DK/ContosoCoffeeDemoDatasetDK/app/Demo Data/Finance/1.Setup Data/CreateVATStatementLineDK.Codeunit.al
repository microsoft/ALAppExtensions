codeunit 13704 "Create VAT Statement Line DK"
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
        CreateVATPostingGroupsDK: Codeunit "Create VAT Posting Groups DK";
    begin
        ContosoVatStatement.SetOverwriteData(true);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 10000, '1010', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 1, SalesVAT25outgoingLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 20000, '1019', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1010..1018', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, SalesVAT25outgoingLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 30000, '1030', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, false, 1, VAT25onEUPurchasesetcLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 40000, '1031', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, false, 0, VAT25onforeignpurchasesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 50000, '1039', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1030..1038', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, VAT25ongoodspurchasedabroadLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 60000, '1040', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsDK.Vat25Serv(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, false, 0, VAT25onEUservicepurchasesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 70000, '1041', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Export(), CreateVATPostingGroupsDK.Vat25Serv(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, false, 0, VAT25onforeignservicepurchasesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 80000, '1049', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1040..1048', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, VAT25onforeignservicepurchasesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 90000, '1050', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeparationLineLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 100000, '1070', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1019|1039|1049', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 110000, '1099', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, SeparationLineLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 120000, '1110', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseVAT25DomesticLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 130000, '1130', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseVAT25EULbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 140000, '1131', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, VAT25onforeignpurchasesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 150000, '1140', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsDK.Vat25Serv(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, VAT25onEUservicepurchasesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 160000, '1141', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Export(), CreateVATPostingGroupsDK.Vat25Serv(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, VAT25onservicepurchasesforeignLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 170000, '1159', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1110..1158', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, PurchaseVATingoingLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 180000, '1160', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 190000, '1180', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, FuelTaxLbl, '24210');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 200000, '1181', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ElectricityTaxLbl, '24220');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 210000, '1182', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, NaturalGasTaxLbl, '24240');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 220000, '1183', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, CoalTaxLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 230000, '1184', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, CO2TaxLbl, '24230');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 240000, '1185', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, WaterTaxLbl, '24250');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 250000, '1189', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1180..1188', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalTaxesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 260000, '1190', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1159|1189', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalDeductionsLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 270000, '1194', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeparationLineLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 280000, '1195', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1070|1190', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, VATPayableLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 290000, '1196', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeparationLineLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 300000, '1210', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, ValueofEUPurchases25Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 310000, '1219', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1210..1218', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueofEUPurchases25Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 320000, '1220', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroupsDK.Vat25Serv(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, ValueofEUservicepurchases25Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 330000, '1229', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1220..1228', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueofEUservicepurchases25Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 340000, '1230', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Zero(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, ValueofnonVATliableEUsalesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 350000, '1239', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1230..1238', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueofnonVATliableEUsalesLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 360000, '1240', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, ValueofnonVATliableEUsalesotherLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 370000, '1249', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueofnonVATliableEUsalesotherLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 380000, '1310', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Zero(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, NonVATliablesalesExportLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 390000, '1319', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1310..1318', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, NonVATliablesalesExportLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 400000, '1320', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, NonVATliablesalesDenmarkLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameLbl, 410000, '1329', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1320..1328', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, NonVATliablesalesDenmarkLbl, '');
        ContosoVatStatement.SetOverwriteData(false);
    end;


    var
        ContosoVatStatement: Codeunit "Contoso VAT Statement";
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        SalesVAT25outgoingLbl: Label 'Sales VAT 25 % (outgoing)', MaxLength = 100;
        VAT25onEUPurchasesetcLbl: Label 'VAT 25 % % on EU Purchases etc.', MaxLength = 100;
        VAT25ongoodspurchasedabroadLbl: Label 'VAT 25% on goods purchased abroad', MaxLength = 100;
        VAT25onEUservicepurchasesLbl: Label 'VAT 25% on EU service purchases', MaxLength = 100;
        VAT25onforeignservicepurchasesLbl: Label 'VAT 25% on foreign service purchases', MaxLength = 100;
        TotalLbl: Label 'Total', MaxLength = 100;
        PurchaseVAT25DomesticLbl: Label 'Purchase VAT 25 % Domestic', MaxLength = 100;
        PurchaseVAT25EULbl: Label 'Purchase VAT 25 % EU', MaxLength = 100;
        VAT25onforeignpurchasesLbl: Label 'VAT 25% on foreign purchases', MaxLength = 100;
        VAT25onservicepurchasesforeignLbl: Label 'VAT 25% on service purchases, foreign', MaxLength = 100;
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
        ValueofEUPurchases25Lbl: Label 'Value of EU Purchases 25 %', MaxLength = 100;
        ValueofEUservicepurchases25Lbl: Label 'Value of EU service purchases 25 %', MaxLength = 100;
        ValueofnonVATliableEUsalesLbl: Label 'Value of non-VAT liable EU sales', MaxLength = 100;
        ValueofnonVATliableEUsalesotherLbl: Label 'Value of non-VAT liable EU sales, other', MaxLength = 100;
        NonVATliablesalesExportLbl: Label 'Non-VAT liable sales, Export', MaxLength = 100;
        NonVATliablesalesDenmarkLbl: Label 'Non-VAT liable sales, Denmark', MaxLength = 100;
        SeparationLineLbl: Label '--------------------------------------------------', Locked = true;
}