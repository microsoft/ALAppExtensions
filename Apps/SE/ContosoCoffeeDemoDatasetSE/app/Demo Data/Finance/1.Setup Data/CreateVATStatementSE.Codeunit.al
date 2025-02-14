codeunit 11248 "Create VAT Statement SE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        CreateVATStatementName();
        CreateVatStatementLine();
    end;

    local procedure CreateVATStatementName()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateVATStatement: Codeunit "Create VAT Statement";
        ContosoVatStatement: Codeunit "Contoso VAT Statement";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoVatStatement.InsertVATStatementName(CreateVATStatement.VATTemplateName(), SESTD(), StatementNameDescLbl);
    end;

    local procedure CreateVatStatementLine()
    var
        ContosoVatStatement: Codeunit "Contoso VAT Statement";
        CreateVATStatement: Codeunit "Create VAT Statement";
        CreateVatPostingGroupsSE: Codeunit "Create Vat Posting Groups SE";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 10000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TurnoverinSwedenLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 20000, '0501', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.VAT25(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, SalesinSweden25Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 30000, '0502', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.VAT12(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, SalesinSweden12Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 40000, '0503', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.VAT6(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, SalesinSweden6Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 50000, '05', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0501..0599', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, SalesSubjectVATEULbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 60000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 70000, '06', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 1, SelfSupplyLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 80000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 90000, '07', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 1, TaxablebasisLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 100000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 110000, '08', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, RentalIncomeLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 120000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, VoluntaryTaxLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 130000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 140000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, OutputVATLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 150000, '10', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.VAT25(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 1, OutputVAT25Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 160000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 170000, '11', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.VAT12(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 1, OutputVAT12Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 180000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 190000, '12', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.VAT6(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 1, OutputVAT6Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 200000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 210000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 220000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, PurchaseSubjectLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 230000, '2001', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT25(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, PurchaseEU25Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 240000, '2002', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT12(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, PurchaseEU12Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 250000, '2003', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT6(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, PurchaseEU6Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 260000, '2004', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.NoVat(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, PurchaseEU0Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 270000, '20', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '2001..2099', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, PurchaseGoodECLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 280000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 290000, '21', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, PurchaseServicesECLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 300000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 310000, '22', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, PurchaseServicesOutsideECLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 320000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 330000, '23', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, PurchaseGoodSELbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 340000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 350000, '24', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, PurchaseServicesSELbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 360000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 370000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 380000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, OutputVATpurchasesLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 390000, '30', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT25(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, true, 1, OutputVAT25Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 400000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 410000, '31', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT12(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, true, 1, OutputVAT12Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 420000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 430000, '32', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT6(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, true, 1, OutputVAT6Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 440000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 450000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 460000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SalesexemptVATLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 470000, '3501', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT25(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, EUSales25Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 480000, '3502', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT12(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, EUSales12Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 490000, '3503', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT6(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, EUSales6Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 500000, '3504', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.NoVat(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, EUSales0Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 510000, '35', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '3501..3599', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, SalesGoodAnotherECLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 520000, '3601', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVatPostingGroupsSE.VAT25(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, ExportSales25Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 530000, '3602', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVatPostingGroupsSE.VAT12(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, ExportSales12Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 540000, '3603', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVatPostingGroupsSE.VAT6(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, ExportSales6Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 550000, '3604', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.NoVat(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 1, EUSales0Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 560000, '36', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '3601..3699', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, SalesOutsideECLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 570000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 580000, '37', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, PurchasemiddlemanLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 590000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 600000, '38', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 1, SalesmiddlemanLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 610000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 620000, '39', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 1, SalesServiceanotherECLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 630000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 640000, '40', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 1, OtherSalesLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 650000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 660000, '41', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, SalesSELbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 670000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 680000, '42', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.NoVat(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, OtherSalesetcLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 690000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 700000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 710000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, FInputVATLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 720000, '4801', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.VAT25(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseSE25Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 730000, '4802', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.VAT12(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseSE12Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 740000, '4803', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.VAT6(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseSE6Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 750000, '4804', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.NoVat(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseSE0Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 760000, '4805', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVatPostingGroupsSE.NoVat(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, false, 0, PurchaseSEOnlyLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 770000, '4810', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT25(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, PurchaseEU25Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 780000, '4811', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT12(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, PurchaseEU12Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 790000, '4812', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.VAT6(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, false, 0, PurchaseEU6Lbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 800000, '48', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVatPostingGroupsSE.NoVat(), '4800..4899', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, InputVATLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 810000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 820000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 830000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, VATpayrefundedLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), SESTD(), 840000, '49', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '10|11|12|30|31|32|48', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, VATpayrefundedLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVatStatementLine(var Rec: Record "VAT Statement Line")
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
        CreateVatPostingGroupsSE: Codeunit "Create Vat Posting Groups SE";
    begin
        if Rec."Statement Template Name" = CreateVATStatement.VATTemplateName() then
            if Rec."Statement Name" = DefaultLbl then
                case Rec."Line No." of
                    200000:
                        UpdateVATStatementLine(Rec, SalesStandardLbl, CreateVatPostingGroupsSE.VAT25());
                    210000:
                        UpdateVATStatementLine(Rec, SalesStandardFullLbl, CreateVatPostingGroupsSE.VAT25());
                    230000:
                        UpdateVATStatementLine(Rec, SalesReducedLbl, CreateVatPostingGroupsSE.VAT12());
                    240000:
                        UpdateVATStatementLine(Rec, SalesReducedFullLbl, CreateVatPostingGroupsSE.VAT25());
                    250000:
                        UpdateVATStatementLine(Rec, SalesReducedTotalLbl, '');
                    270000:
                        UpdateVATStatementLine(Rec, EUStandardLbl, CreateVatPostingGroupsSE.VAT25());
                    290000:
                        UpdateVATStatementLine(Rec, EUReducedLbl, CreateVatPostingGroupsSE.VAT12());
                    300000:
                        UpdateVATStatementLine(Rec, EUReducedTotalLbl, '');
                    320000:
                        UpdateVATStatementLine(Rec, PurchaseStandardLbl, CreateVatPostingGroupsSE.VAT25());
                    330000:
                        UpdateVATStatementLine(Rec, PurchaseStandardFullLbl, CreateVatPostingGroupsSE.VAT25());
                    350000:
                        UpdateVATStatementLine(Rec, PurchaseReducedLbl, CreateVatPostingGroupsSE.VAT12());
                    360000:
                        UpdateVATStatementLine(Rec, PurchaseReducedFullLbl, CreateVatPostingGroupsSE.VAT25());
                    370000:
                        UpdateVATStatementLine(Rec, PurchaseReducedTotalLbl, '');
                    390000:
                        UpdateVATStatementLine(Rec, EUStandardLbl, CreateVatPostingGroupsSE.VAT25());
                    410000:
                        UpdateVATStatementLine(Rec, EUReducedLbl, CreateVatPostingGroupsSE.VAT12());
                    420000:
                        UpdateVATStatementLine(Rec, EUReducedTotalLbl, '');
                    450000:
                        UpdateVATStatementLine(Rec, DomesticStandardSalesLbl, CreateVatPostingGroupsSE.VAT25());
                    470000:
                        UpdateVATStatementLine(Rec, DomesticReducedValueLbl, CreateVatPostingGroupsSE.VAT12());
                    480000:
                        UpdateVATStatementLine(Rec, DomesticReducedTotalLbl, '');
                    500000:
                        UpdateVATStatementLine(Rec, EUStandardSuppliesLbl, CreateVatPostingGroupsSE.VAT25());
                    520000:
                        UpdateVATStatementLine(Rec, EUReducedSuppliesLbl, CreateVatPostingGroupsSE.VAT12());
                    530000:
                        UpdateVATStatementLine(Rec, EUReducedSuppliesTotalLbl, '');
                    550000:
                        UpdateVATStatementLine(Rec, OverseasSalesValueLbl, CreateVatPostingGroupsSE.VAT25());
                    570000:
                        UpdateVATStatementLine(Rec, OverseasSalesReducedLbl, CreateVatPostingGroupsSE.VAT12());
                    580000:
                        UpdateVATStatementLine(Rec, OverseasSalesReducedTotalLbl, '');
                    620000:
                        UpdateVATStatementLine(Rec, DomesticStandardPurchaseLbl, CreateVatPostingGroupsSE.VAT25());
                    640000:
                        UpdateVATStatementLine(Rec, DomesticReducedPurchaseValueLbl, CreateVatPostingGroupsSE.VAT12());
                    650000:
                        UpdateVATStatementLine(Rec, DomesticReducedPurchaseTotalLbl, '');
                    670000:
                        UpdateVATStatementLine(Rec, EUAcquisitionStandardLbl, CreateVatPostingGroupsSE.VAT25());
                    690000:
                        UpdateVATStatementLine(Rec, EUAcquisitionReducedLbl, CreateVatPostingGroupsSE.VAT12());
                    700000:
                        UpdateVATStatementLine(Rec, EUAcquisitionReducedTotalLbl, '');
                    720000:
                        UpdateVATStatementLine(Rec, OverseasPurchaseValueLbl, CreateVatPostingGroupsSE.VAT25());
                    740000:
                        UpdateVATStatementLine(Rec, OverseasPurchaseReducedLbl, CreateVatPostingGroupsSE.VAT12());
                    750000:
                        UpdateVATStatementLine(Rec, OverseasPurchaseReducedTotalLbl, '');
                    770000:
                        UpdateVATStatementLine(Rec, NonVatLiablePurchaseLbl, CreateVatPostingGroupsSE.NoVat());
                end;
    end;

    local procedure UpdateVATStatementLine(var VATStatementLine: Record "VAT Statement Line"; Description: Text[100]; VATProdPostingGroup: Code[20])
    begin
        VATStatementLine.Validate(Description, Description);
        VATStatementLine.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;

    procedure SESTD(): Code[10]
    begin
        exit(SESTDStatementNameTok);
    end;

    var
        SESTDStatementNameTok: Label 'SE STD', MaxLength = 10, Locked = true;
        DefaultLbl: Label 'DEFAULT', MaxLength = 10;
        StatementNameDescLbl: Label 'SE Standard', MaxLength = 100;
        SalesStandardLbl: Label 'Sales 25 % ', MaxLength = 100;
        SalesStandardFullLbl: Label 'Sales 25 % FULL', MaxLength = 100;
        SalesReducedLbl: Label 'Sales 12 % ', MaxLength = 100;
        SalesReducedFullLbl: Label 'Sales 12 % FULL', MaxLength = 100;
        SalesReducedTotalLbl: Label 'Sales 12 % total', MaxLength = 100;
        EUStandardLbl: Label '25 % on EU Acquisitions etc.', MaxLength = 100;
        EUReducedLbl: Label '12 % on EU Acquisitions etc.', MaxLength = 100;
        EUReducedTotalLbl: Label '12 % on EU Acquisitions etc. total', MaxLength = 100;
        PurchaseStandardLbl: Label 'Purchase VAT 25 % Domestic ', MaxLength = 100;
        PurchaseStandardFullLbl: Label 'Purchase VAT 25 % FULL Domestic', MaxLength = 100;
        PurchaseReducedLbl: Label 'Purchase VAT 12 % Domestic ', MaxLength = 100;
        PurchaseReducedFullLbl: Label 'Purchase 12 % Domestic Total FULL', MaxLength = 100;
        PurchaseReducedTotalLbl: Label 'Purchase 12 % Domestic total ', MaxLength = 100;
        DomesticStandardSalesLbl: Label 'Value of Domestic Sales 25 % ', MaxLength = 100;
        DomesticReducedValueLbl: Label 'Value of Domestic Sales 12 % ', MaxLength = 100;
        DomesticReducedTotalLbl: Label 'Value of Domestic Sales 12 % total', MaxLength = 100;
        EUStandardSuppliesLbl: Label 'Value of EU Supplies 25 % ', MaxLength = 100;
        EUReducedSuppliesLbl: Label 'Value of EU Supplies 12 % ', MaxLength = 100;
        EUReducedSuppliesTotalLbl: Label 'Value of EU Supplies 12 % total', MaxLength = 100;
        OverseasSalesValueLbl: Label 'Value of Overseas Sales 25 % ', MaxLength = 100;
        OverseasSalesReducedLbl: Label 'Value of Overseas Sales 12 % ', MaxLength = 100;
        OverseasSalesReducedTotalLbl: Label 'Value of Overseas Sales 12 % total', MaxLength = 100;
        DomesticStandardPurchaseLbl: Label 'Value of Domestic Purchases 25 % ', MaxLength = 100;
        DomesticReducedPurchaseValueLbl: Label 'Value of Domestic Purchases 12 % ', MaxLength = 100;
        DomesticReducedPurchaseTotalLbl: Label 'Value of Domestic Purchases 12 % total', MaxLength = 100;
        EUAcquisitionStandardLbl: Label 'Value of EU Acquisitions 25 % ', MaxLength = 100;
        EUAcquisitionReducedLbl: Label 'Value of EU Acquisitions 12 % ', MaxLength = 100;
        EUAcquisitionReducedTotalLbl: Label 'Value of EU Acquisitions 12 % total', MaxLength = 100;
        OverseasPurchaseValueLbl: Label 'Value of Overseas Purchases 25 % ', MaxLength = 100;
        OverseasPurchaseReducedLbl: Label 'Value of Overseas Purchases 12 % ', MaxLength = 100;
        OverseasPurchaseReducedTotalLbl: Label 'Value of Overseas Purchases 12 % total', MaxLength = 100;
        NonVatLiablePurchaseLbl: Label 'Value of non-VAT liable purchases', MaxLength = 100;
        TurnoverinSwedenLbl: Label 'A. Sales subject to VAT or withdrawals excl. VAT', MaxLength = 100;
        SalesinSweden25Lbl: Label 'National Sale 25%', MaxLength = 100;
        SalesinSweden12Lbl: Label 'National Sale 12 %', MaxLength = 100;
        SalesinSweden6Lbl: Label 'National Sale 6%', MaxLength = 100;
        SalesSubjectVATEULbl: Label 'Sales subject to VAT not included in boxes below', MaxLength = 100;
        SelfSupplyLbl: Label 'Self-supply subject to VAT', MaxLength = 100;
        TaxablebasisLbl: Label 'Taxable basis for profit margin taxation', MaxLength = 100;
        RentalIncomeLbl: Label 'Rental income', MaxLength = 100;
        VoluntaryTaxLbl: Label '- voluntary tax liability', MaxLength = 100;
        OutputVATLbl: Label 'Output VAT on sales or self-supply in boxes 05-08', MaxLength = 100;
        OutputVAT25Lbl: Label 'Output VAT 25%', MaxLength = 100;
        OutputVAT12Lbl: Label 'Output VAT 12%', MaxLength = 100;
        OutputVAT6Lbl: Label 'Output VAT 6%', MaxLength = 100;
        PurchaseSubjectLbl: Label 'Purchases subj to VAT where purchaser subj to VAT', MaxLength = 100;
        PurchaseEU25Lbl: Label 'Purchase EU 25%', MaxLength = 100;
        PurchaseEU12Lbl: Label 'Purchase EU 12%', MaxLength = 100;
        PurchaseEU6Lbl: Label 'Purchase EU 6%', MaxLength = 100;
        PurchaseEU0Lbl: Label 'Purchase EU 0%', MaxLength = 100;
        PurchaseGoodECLbl: Label 'Purchase of goods from another EC country', MaxLength = 100;
        PurchaseServicesECLbl: Label 'Purchases of services from another EC country', MaxLength = 100;
        PurchaseServicesOutsideECLbl: Label 'Purchase of services from a country outside the EC', MaxLength = 100;
        PurchaseGoodSELbl: Label 'Purchases of goods in Sweden', MaxLength = 100;
        PurchaseServicesSELbl: Label 'Purchases of services in Sweden', MaxLength = 100;
        OutputVATpurchasesLbl: Label 'Output VAT on purchases in Boxes 20-24', MaxLength = 100;
        SalesexemptVATLbl: Label 'Sales etc. which are exempt from VAT', MaxLength = 100;
        EUSales25Lbl: Label 'EU Sales 25%', MaxLength = 100;
        EUSales12Lbl: Label 'EU Sales 12%', MaxLength = 100;
        EUSales6Lbl: Label 'EU Sales 6%', MaxLength = 100;
        EUSales0Lbl: Label 'EU Sales 0%', MaxLength = 100;
        SalesGoodAnotherECLbl: Label 'Sales of goods to another EC country', MaxLength = 100;
        ExportSales25Lbl: Label 'Export Sales 25%', MaxLength = 100;
        ExportSales12Lbl: Label 'Export Sales 12%', MaxLength = 100;
        ExportSales6Lbl: Label 'Export Sales 6%', MaxLength = 100;
        SalesOutsideECLbl: Label 'Sales of goods outside the EC', MaxLength = 100;
        PurchasemiddlemanLbl: Label 'Purch. of goods by middleman in triang. trade', MaxLength = 100;
        SalesmiddlemanLbl: Label 'Sales of goods by middleman in triangular trading', MaxLength = 100;
        SalesServiceanotherECLbl: Label 'Service sale with purch. subj. to VAT in ECcountry', MaxLength = 100;
        OtherSalesLbl: Label 'Other sales of services turn-over outside SE', MaxLength = 100;
        SalesSELbl: Label 'Sales in which the purch. is subject to VAT in SE', MaxLength = 100;
        OtherSalesetcLbl: Label 'Other Sales etc.', MaxLength = 100;
        FInputVATLbl: Label 'F. Input VAT', MaxLength = 100;
        PurchaseSE25Lbl: Label 'Purchase Sweden 25%', MaxLength = 100;
        PurchaseSE12Lbl: Label 'Purchase Sweden 12%', MaxLength = 100;
        PurchaseSE6Lbl: Label 'Purchase Sweden 6%', MaxLength = 100;
        PurchaseSE0Lbl: Label 'Purchase Sweden 0%', MaxLength = 100;
        PurchaseSEOnlyLbl: Label 'Purchase Sweden only', MaxLength = 100;
        InputVATLbl: Label 'Input VAT to deduct', MaxLength = 100;
        VATpayrefundedLbl: Label 'VAT to pay or be refunded', MaxLength = 100;
}