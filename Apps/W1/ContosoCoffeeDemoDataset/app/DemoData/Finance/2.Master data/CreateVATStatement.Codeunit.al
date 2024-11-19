codeunit 5630 "Create VAT Statement"
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

        ContosoVatStatement.InsertVATStatementTemplate(VATTemplateName(), VATStatementDescLbl, Page::"VAT Statement", Report::"VAT Statement");

        ContosoVatStatement.InsertVATStatementName(VATTemplateName(), StatementNameLbl, StatementNameDescLbl);
        CreateVATStatementLine();
    end;

    local procedure CreateVATStatementLine()
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 10000, '001', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '020|030', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, VatSalesDueLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 20000, '002', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '090|100', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, VatAcquisitionDueLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 30000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, MemberStatesECLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 40000, '003', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '001|002', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalVatDueLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 50000, '004', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '040|050|070|080', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, VatReclaimedLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 60000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, InputsAcquisitionECLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 70000, '005', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '020|030|070|080', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, NetVatPaidLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 80000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 90000, '006', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '110|120|170|180|008', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalValueSalesLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 100000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ExcludingVatLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 110000, '007', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '210|220|270|280|009', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalValuePurchaseLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 120000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ExcludingVatLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 130000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 140000, '008', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '140|150', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalValueSuppliesLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 150000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ECMemberStatesLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 160000, '009', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '240|250', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalValueAcquisitionLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 170000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ExcludingVatECLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 180000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, MemberStatesLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 190000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeparationLineLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 200000, '011', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 0, SalesStandardLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 210000, '012', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullNormal(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 0, SalesStandardFullLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 220000, '020', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '011..019', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SalesStandardTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 230000, '021', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 0, SalesReducedLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 240000, '022', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullRed(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 0, SalesReducedFullLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 250000, '030', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '021..029', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SalesReducedTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 260000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 270000, '031', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, EUStandardLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 280000, '040', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '031..039', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, EUStandardTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 290000, '041', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, EUReducedLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 300000, '050', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '041..049', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, EUReducedTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 310000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 320000, '061', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, PurchaseStandardLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 330000, '062', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullNormal(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, PurchaseStandardFullLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 340000, '070', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '061..069', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, PurchaseStandardTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 350000, '071', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, PurchaseReducedLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 360000, '072', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullRed(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, PurchaseReducedFullLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 370000, '080', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '071..079', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, PurchaseReducedTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 380000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 390000, '081', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, false, 1, EUStandardLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 400000, '090', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '081..089', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 1, EUStandardTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 410000, '091', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, false, 1, EUReducedLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 420000, '100', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '091..099', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 1, EUReducedTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 430000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 440000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 450000, '101', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, DomesticStandardSalesLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 460000, '110', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '101..109', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, DomesticStandardTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 470000, '111', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, DomesticReducedValueLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 480000, '120', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '111..119', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, DomesticReducedTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 490000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 500000, '131', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, EUStandardSuppliesLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 510000, '140', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '131..139', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, EUStandardSuppliesTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 520000, '141', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, EUReducedSuppliesLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 530000, '150', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '141..149', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, EUReducedSuppliesTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 540000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 550000, '161', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, OverseasSalesValueLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 560000, '170', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '161..169', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, OverseasSalesTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 570000, '171', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, OverseasSalesReducedLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 580000, '180', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '171..179', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, OverseasSalesReducedTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 590000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 600000, '190', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', '', Enum::"VAT Statement Line Amount Type"::"Base", 0, true, 1, NonVatLiableSalesLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 610000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 620000, '201', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, DomesticStandardPurchaseLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 630000, '210', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '201..209', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, DomesticStandardPurchaseTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 640000, '211', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, DomesticReducedPurchaseValueLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 650000, '220', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '211..219', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, DomesticReducedPurchaseTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 660000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 670000, '231', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, EUAcquisitionStandardLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 680000, '240', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '231..239', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, EUAcquisitionStandardTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 690000, '241', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, EUAcquisitionReducedLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 700000, '250', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '241..249', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, EUAcquisitionReducedTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 710000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 720000, '261', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, OverseasPurchaseValueLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 730000, '270', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '261..269', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, OverseasPurchaseTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 740000, '271', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, OverseasPurchaseReducedLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 750000, '280', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '271..279', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, OverseasPurchaseReducedTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 760000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATTemplateName(), StatementNameLbl, 770000, '290', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, true, 0, NonVatLiablePurchaseLbl);
    end;

    procedure VATTemplateName(): Code[10]
    begin
        exit(VatTemplateNameTok);
    end;

    var
        ContosoVatStatement: Codeunit "Contoso VAT Statement";
        VatTemplateNameTok: Label 'VAT', Locked = true;
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        StatementNameDescLbl: Label 'Default Statement', MaxLength = 100;
        VATStatementDescLbl: Label 'VAT Statement', MaxLength = 80;
        VatSalesDueLbl: Label 'VAT due in the period on sales and other outputs', MaxLength = 100;
        VatAcquisitionDueLbl: Label 'VAT due in the period on acquisitions from other', MaxLength = 100;
        MemberStatesECLbl: Label 'member states of the EC', MaxLength = 100;
        TotalVatDueLbl: Label 'Total VAT due', MaxLength = 100;
        VatReclaimedLbl: Label 'VAT reclaimed in the period on purchases and other', MaxLength = 100;
        InputsAcquisitionECLbl: Label 'inputs (including acquisitions from the EC)', MaxLength = 100;
        NetVatPaidLbl: Label 'Net VAT to be paid (+) or to be reclaimed (-)', MaxLength = 100;
        TotalValueSalesLbl: Label 'Total value of sales and all other outputs ', MaxLength = 100;
        TotalValuePurchaseLbl: Label 'Total value of purchases and all other inputs ', MaxLength = 100;
        ExcludingVatLbl: Label 'excluding any VAT', MaxLength = 100;
        TotalValueSuppliesLbl: Label 'Total value of all supplies of goods and related', MaxLength = 100;
        ECMemberStatesLbl: Label 'costs, excluding any VAT to other EC member states', MaxLength = 100;
        TotalValueAcquisitionLbl: Label 'total value of all acquisitions of goods and ', MaxLength = 100;
        ExcludingVatECLbl: Label 'related costs, excluding any VAT, from other EC ', MaxLength = 100;
        MemberStatesLbl: Label 'member states', MaxLength = 100;
        SalesStandardLbl: Label 'Sales 25 % ', MaxLength = 100;
        SalesStandardFullLbl: Label 'Sales 25 % FULL', MaxLength = 100;
        SalesStandardTotalLbl: Label 'Sales 25 % total', MaxLength = 100;
        SalesReducedLbl: Label 'Sales 10 % ', MaxLength = 100;
        SalesReducedFullLbl: Label 'Sales 10 % FULL', MaxLength = 100;
        SalesReducedTotalLbl: Label 'Sales 10 % total', MaxLength = 100;
        EUStandardLbl: Label '25 % on EU Acquisitions etc.', MaxLength = 100;
        EUStandardTotalLbl: Label '25 % on EU Acquisitions etc. total', MaxLength = 100;
        EUReducedLbl: Label '10 % on EU Acquisitions etc.', MaxLength = 100;
        EUReducedTotalLbl: Label '10 % on EU Acquisitions etc. total', MaxLength = 100;
        PurchaseStandardLbl: Label 'Purchase VAT 25 % Domestic ', MaxLength = 100;
        PurchaseStandardFullLbl: Label 'Purchase VAT 25 % FULL Domestic', MaxLength = 100;
        PurchaseStandardTotalLbl: Label 'Purchase 25 % Domestic Total ', MaxLength = 100;
        PurchaseReducedLbl: Label 'Purchase VAT 10 % Domestic ', MaxLength = 100;
        PurchaseReducedFullLbl: Label 'Purchase 10 % Domestic Total FULL', MaxLength = 100;
        PurchaseReducedTotalLbl: Label 'Purchase 10 % Domestic total ', MaxLength = 100;
        DomesticStandardSalesLbl: Label 'Value of Domestic Sales 25 % ', MaxLength = 100;
        DomesticStandardTotalLbl: Label 'Value of Domestic Sales 25 % total', MaxLength = 100;
        DomesticReducedValueLbl: Label 'Value of Domestic Sales 10 % ', MaxLength = 100;
        DomesticReducedTotalLbl: Label 'Value of Domestic Sales 10 % total', MaxLength = 100;
        EUStandardSuppliesLbl: Label 'Value of EU Supplies 25 % ', MaxLength = 100;
        EUStandardSuppliesTotalLbl: Label 'Value of EU Supplies 25 % total', MaxLength = 100;
        EUReducedSuppliesLbl: Label 'Value of EU Supplies 10 % ', MaxLength = 100;
        EUReducedSuppliesTotalLbl: Label 'Value of EU Supplies 10 % total', MaxLength = 100;
        OverseasSalesValueLbl: Label 'Value of Overseas Sales 25 % ', MaxLength = 100;
        OverseasSalesTotalLbl: Label 'Value of Overseas Sales 25 % total', MaxLength = 100;
        OverseasSalesReducedLbl: Label 'Value of Overseas Sales 10 % ', MaxLength = 100;
        OverseasSalesReducedTotalLbl: Label 'Value of Overseas Sales 10 % total', MaxLength = 100;
        NonVatLiableSalesLbl: Label 'Value of non-VAT liable sales', MaxLength = 100;
        DomesticStandardPurchaseLbl: Label 'Value of Domestic Purchases 25 % ', MaxLength = 100;
        DomesticStandardPurchaseTotalLbl: Label 'Value of Domestic Purchases 25 % total', MaxLength = 100;
        DomesticReducedPurchaseValueLbl: Label 'Value of Domestic Purchases 10 % ', MaxLength = 100;
        DomesticReducedPurchaseTotalLbl: Label 'Value of Domestic Purchases 10 % total', MaxLength = 100;
        EUAcquisitionStandardLbl: Label 'Value of EU Acquisitions 25 % ', MaxLength = 100;
        EUAcquisitionStandardTotalLbl: Label 'Value of EU Acquisitions 25 % Total', MaxLength = 100;
        EUAcquisitionReducedLbl: Label 'Value of EU Acquisitions 10 % ', MaxLength = 100;
        EUAcquisitionReducedTotalLbl: Label 'Value of EU Acquisitions 10 % total', MaxLength = 100;
        OverseasPurchaseValueLbl: Label 'Value of Overseas Purchases 25 % ', MaxLength = 100;
        OverseasPurchaseTotalLbl: Label 'Value of Overseas Purchases 25 % total', MaxLength = 100;
        OverseasPurchaseReducedLbl: Label 'Value of Overseas Purchases 10 % ', MaxLength = 100;
        OverseasPurchaseReducedTotalLbl: Label 'Value of Overseas Purchases 10 % total', MaxLength = 100;
        NonVatLiablePurchaseLbl: Label 'Value of non-VAT liable purchases', MaxLength = 100;
        SeparationLineLbl: Label '================================================', Locked = true;
}