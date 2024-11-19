codeunit 10526 "Create GB VAT Statement"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoVatStatement.InsertVATStatementTemplate(VATGBTemplateName(), VATReturnDescLbl, Page::"VAT Statement", Report::"VAT Statement");

        ContosoVatStatement.InsertVATStatementName(VATGBTemplateName(), StatementNameLbl, StatementNameDescLbl);
        CreateVATStatementLine();
    end;

    local procedure CreateVATStatementLine()
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 780000, '001', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '020|030', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, VatDueOnSalesAndOtherOutputsLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 790000, '002', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '090|100', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, VatOnGoodsAcquiredInNorthernIrelandFromEuLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 800000, '003', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '001|002', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalVatDueLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 810000, '004', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '040|050|070|080', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalVatDueInclEuAcquisitionsLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 820000, '005', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '020|030|070|080', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, NetVatToBePaidOrToBeReclaimedLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 830000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 840000, '006', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '110|120|170|180|190|008', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TotalValueOfSalesExclVatInclRow8Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 850000, '007', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '210|220|270|280|290|009', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalValueOfPurchasesExclVatInclRow9Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 860000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 870000, '008', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '140|150', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ValueOfGoodsExVatFromNorthernIrelandToEuLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 880000, '009', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '240|250', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, GoodsExVatAcquiredInNorthernIrelandFromEuLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 890000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 900000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SeperationLineLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 910000, '011', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 0, Sales20Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 920000, '012', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullNormal(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 0, Sales20FullLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 930000, '020', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '011..019', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, Sales20TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 940000, '021', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 0, Sales5Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 950000, '022', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullRed(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 0, Sales5FullLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 960000, '030', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '021..029', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, Sales5TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 970000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 980000, '031', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, EuAcquisitions20Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 990000, '040', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '031..039', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, EuAcquisitions20TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1000000, '041', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, EuAcquisitions5Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1010000, '050', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '041..049', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, EuAcquisitions5TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1020000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1030000, '061', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, PurchaseVat20DomesticLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1040000, '062', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullNormal(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, PurchaseVat20FullDomesticLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1050000, '070', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '061..069', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, Purchase20DomesticTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1060000, '071', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, PurchaseVat5DomesticLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1070000, '072', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.FullRed(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 1, false, 1, Purchase5DomesticTotalFullLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1080000, '080', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '071..079', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, Purchase5DomesticTotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1090000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1100000, '081', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, false, 1, EuAcquisitions20Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1110000, '090', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '081..089', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 1, EuAcquisitions20TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1120000, '091', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, false, 1, EuAcquisitions5Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1130000, '100', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '091..099', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 1, EuAcquisitions5TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1140000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, false, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1150000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1160000, '101', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, ValueOfDomesticSales20Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1170000, '110', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '101..109', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ValueOfDomesticSales20TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1180000, '111', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, ValueOfDomesticSales5Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1190000, '120', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '111..119', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ValueOfDomesticSales5TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1200000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1210000, '131', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, ValueOfEuSupplies20Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1220000, '140', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '131..139', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ValueOfEuSupplies20TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1230000, '141', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, ValueOfEuSupplies5Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1240000, '150', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '141..149', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ValueOfEuSupplies5TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1250000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1260000, '161', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, ValueOfOverseasSales20Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1270000, '170', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '161..169', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ValueOfOverseasSales20TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1280000, '171', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, ValueOfOverseasSales5Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1290000, '180', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '171..179', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ValueOfOverseasSales5TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1300000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1310000, '190', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, true, 1, ValueOfNonVatLiableSalesLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1320000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1330000, '201', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, ValueOfDomesticPurchases20Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1340000, '210', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '201..209', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueOfDomesticPurchases20TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1350000, '211', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, ValueOfDomesticPurchases5Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1360000, '220', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '211..219', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueOfDomesticPurchases5TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1370000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1380000, '231', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, ValueOfEuAcquisitions20Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1390000, '240', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '231..239', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueOfEuAcquisitions20TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1400000, '241', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, ValueOfEuAcquisitions5Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1410000, '250', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '241..249', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueOfEuAcquisitions5TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1420000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1430000, '261', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, ValueOfOverseasPurchases20Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1440000, '270', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '261..269', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueOfOverseasPurchases20TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1450000, '271', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, ValueOfOverseasPurchases5Lbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1460000, '280', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '271..279', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ValueOfOverseasPurchases5TotalLbl);
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1470000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
        ContosoVatStatement.InsertVatStatementLine(VATGBTemplateName(), StatementNameLbl, 1480000, '290', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, true, 0, ValueOfNonVatLiablePurchasesLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "VAT Statement Line")
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
    begin
        if (Rec."Statement Template Name" = CreateVATStatement.VATTemplateName()) and (Rec."Statement Name" = StatementNameLbl) then
            case
                Rec."Line No." of
                10000:
                    Rec.Validate("Box No.", '1');
                20000:
                    Rec.Validate("Box No.", '2');
                40000:
                    Rec.Validate("Box No.", '3');
                50000:
                    Rec.Validate("Box No.", '4');
                70000:
                    begin
                        Rec.Validate(Description, NetVatPaidLbl);
                        Rec.Validate("Box No.", '5');
                    end;
                90000:
                    begin
                        Rec.Validate("Row Totaling", '110|120|170|180|190|008');
                        Rec.Validate("Box No.", '6');
                    end;
                110000:
                    begin
                        Rec.Validate("Row Totaling", '210|220|270|280|290|009');
                        Rec.Validate("Box No.", '7');
                    end;
                140000:
                    Rec.Validate("Box No.", '8');
                160000:
                    Rec.Validate("Box No.", '9');
                200000:
                    Rec.Validate(Description, SalesStandardLbl);
                210000:
                    Rec.Validate(Description, SalesStandardFullLbl);
                220000:
                    Rec.Validate(Description, SalesStandardTotalLbl);
                230000:
                    Rec.Validate(Description, SalesReducedLbl);
                240000:
                    Rec.Validate(Description, SalesReducedFullLbl);
                250000:
                    Rec.Validate(Description, SalesReducedTotalLbl);
                270000:
                    Rec.Validate(Description, EUStandardLbl);
                280000:
                    Rec.Validate(Description, EUStandardTotalLbl);
                290000:
                    Rec.Validate(Description, EUReducedLbl);
                300000:
                    Rec.Validate(Description, EUReducedTotalLbl);
                320000:
                    Rec.Validate(Description, PurchaseStandardLbl);
                330000:
                    Rec.Validate(Description, PurchaseStandardFullLbl);
                340000:
                    Rec.Validate(Description, PurchaseStandardTotalLbl);
                350000:
                    Rec.Validate(Description, PurchaseReducedLbl);
                360000:
                    Rec.Validate(Description, PurchaseReducedFullLbl);
                370000:
                    Rec.Validate(Description, PurchaseReducedTotalLbl);
                390000:
                    Rec.Validate(Description, EUStandardLbl);
                400000:
                    Rec.Validate(Description, EUStandardTotalLbl);
                410000:
                    Rec.Validate(Description, EUReducedLbl);
                420000:
                    Rec.Validate(Description, EUReducedTotalLbl);
                450000:
                    Rec.Validate(Description, DomesticStandardSalesLbl);
                460000:
                    Rec.Validate(Description, DomesticStandardTotalLbl);
                470000:
                    Rec.Validate(Description, DomesticReducedValueLbl);
                480000:
                    Rec.Validate(Description, DomesticReducedTotalLbl);
                500000:
                    Rec.Validate(Description, EUStandardSuppliesLbl);
                510000:
                    Rec.Validate(Description, EUStandardSuppliesTotalLbl);
                520000:
                    Rec.Validate(Description, EUReducedSuppliesLbl);
                530000:
                    Rec.Validate(Description, EUReducedSuppliesTotalLbl);
                550000:
                    Rec.Validate(Description, OverseasSalesValueLbl);
                560000:
                    Rec.Validate(Description, OverseasSalesTotalLbl);
                570000:
                    Rec.Validate(Description, OverseasSalesReducedLbl);
                580000:
                    Rec.Validate(Description, OverseasSalesReducedTotalLbl);
                620000:
                    Rec.Validate(Description, DomesticStandardPurchaseLbl);
                630000:
                    Rec.Validate(Description, DomesticStandardPurchaseTotalLbl);
                640000:
                    Rec.Validate(Description, DomesticReducedPurchaseValueLbl);
                650000:
                    Rec.Validate(Description, DomesticReducedPurchaseTotalLbl);
                670000:
                    Rec.Validate(Description, EUAcquisitionStandardLbl);
                680000:
                    Rec.Validate(Description, EUAcquisitionStandardTotalLbl);
                690000:
                    Rec.Validate(Description, EUAcquisitionReducedLbl);
                700000:
                    Rec.Validate(Description, EUAcquisitionReducedTotalLbl);
                720000:
                    Rec.Validate(Description, OverseasPurchaseValueLbl);
                730000:
                    Rec.Validate(Description, OverseasPurchaseTotalLbl);
                740000:
                    Rec.Validate(Description, OverseasPurchaseReducedLbl);
                750000:
                    Rec.Validate(Description, OverseasPurchaseReducedTotalLbl);
            end;

        if (Rec."Statement Template Name" = VATGBTemplateName()) and (Rec."Statement Name" = StatementNameLbl) then
            case
                Rec."Line No." of
                780000:
                    Rec.Validate("Box No.", '1');
                790000:
                    Rec.Validate("Box No.", '2');
                800000:
                    Rec.Validate("Box No.", '3');
                810000:
                    Rec.Validate("Box No.", '4');
                820000:
                    Rec.Validate("Box No.", '5');
                840000:
                    Rec.Validate("Box No.", '6');
                850000:
                    Rec.Validate("Box No.", '7');
                870000:
                    Rec.Validate("Box No.", '8');
                880000:
                    Rec.Validate("Box No.", '9');
            end;
    end;

    procedure VATGBTemplateName(): Code[10]
    begin
        exit(VatGBTemplateNameTok);
    end;

    var
        ContosoVatStatement: Codeunit "Contoso VAT Statement";
        VatGBTemplateNameTok: Label 'VATGB', Locked = true;
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        StatementNameDescLbl: Label 'Default Statement', MaxLength = 100;
        VATReturnDescLbl: Label 'VAT Return', MaxLength = 80;
        VatDueOnSalesAndOtherOutputsLbl: Label 'VAT due on sales and other outputs', MaxLength = 100;
        VatOnGoodsAcquiredInNorthernIrelandFromEuLbl: Label 'VAT on goods acquired in Northern Ireland from EU', MaxLength = 100;
        TotalVatDueLbl: Label 'Total VAT due', MaxLength = 100;
        TotalVatDueInclEuAcquisitionsLbl: Label 'Total VAT due (incl. EU acquisitions)', MaxLength = 100;
        NetVatToBePaidOrToBeReclaimedLbl: Label 'Net VAT to be paid (+) or to be reclaimed (-)', MaxLength = 100;
        TotalValueOfSalesExclVatInclRow8Lbl: Label 'Total value of sales excl. VAT, incl. Row 8', MaxLength = 100;
        TotalValueOfPurchasesExclVatInclRow9Lbl: Label 'Total value of purchases excl. VAT, incl. Row 9', MaxLength = 100;
        ValueOfGoodsExVatFromNorthernIrelandToEuLbl: Label 'Value of goods ex. VAT from Northern Ireland to EU', MaxLength = 100;
        GoodsExVatAcquiredInNorthernIrelandFromEuLbl: Label 'Goods ex. VAT acquired in Northern Ireland from EU', MaxLength = 100;
        SeperationLineLbl: Label '==================================================', Locked = true;
        Sales20Lbl: Label 'Sales 20 %', MaxLength = 100;
        Sales20FullLbl: Label 'Sales 20 % FULL', MaxLength = 100;
        Sales20TotalLbl: Label 'Sales 20 %  total', MaxLength = 100;
        Sales5Lbl: Label 'Sales 5 %', MaxLength = 100;
        Sales5FullLbl: Label 'Sales 5 % FULL', MaxLength = 100;
        Sales5TotalLbl: Label 'Sales 5 %  total', MaxLength = 100;
        EuAcquisitions20Lbl: Label '20 % on EU Acquisitions etc.', MaxLength = 100;
        EuAcquisitions20TotalLbl: Label '20 % on EU Acquisitions etc. total', MaxLength = 100;
        EuAcquisitions5Lbl: Label '5 % on EU Acquisitions etc.', MaxLength = 100;
        EuAcquisitions5TotalLbl: Label '5 % on EU Acquisitions etc. total', MaxLength = 100;
        PurchaseVat20DomesticLbl: Label 'Purchase VAT 20 % Domestic', MaxLength = 100;
        PurchaseVat20FullDomesticLbl: Label 'Purchase VAT 20 % FULL Domestic', MaxLength = 100;
        Purchase20DomesticTotalLbl: Label 'Purchase 20 % Domestic total', MaxLength = 100;
        PurchaseVat5DomesticLbl: Label 'Purchase VAT 5 % Domestic', MaxLength = 100;
        Purchase5DomesticTotalFullLbl: Label 'Purchase 5 % Domestic total FULL', MaxLength = 100;
        Purchase5DomesticTotalLbl: Label 'Purchase 5 % Domestic total', MaxLength = 100;
        ValueOfDomesticSales20Lbl: Label 'Value of Domestic Sales 20 %', MaxLength = 100;
        ValueOfDomesticSales20TotalLbl: Label 'Value of Domestic Sales 20 % total', MaxLength = 100;
        ValueOfDomesticSales5Lbl: Label 'Value of Domestic Sales 5 %', MaxLength = 100;
        ValueOfDomesticSales5TotalLbl: Label 'Value of Domestic Sales 5 % total', MaxLength = 100;
        ValueOfEuSupplies20Lbl: Label 'Value of EU Supplies 20 %', MaxLength = 100;
        ValueOfEuSupplies20TotalLbl: Label 'Value of EU Supplies 20 % total', MaxLength = 100;
        ValueOfEuSupplies5Lbl: Label 'Value of EU Supplies 5 %', MaxLength = 100;
        ValueOfEuSupplies5TotalLbl: Label 'Value of EU Supplies 5 % total', MaxLength = 100;
        ValueOfOverseasSales20Lbl: Label 'Value of Overseas Sales 20 %', MaxLength = 100;
        ValueOfOverseasSales20TotalLbl: Label 'Value of Overseas Sales 20 % total', MaxLength = 100;
        ValueOfOverseasSales5Lbl: Label 'Value of Overseas Sales 5 %', MaxLength = 100;
        ValueOfOverseasSales5TotalLbl: Label 'Value of Overseas Sales 5 % total', MaxLength = 100;
        ValueOfNonVatLiableSalesLbl: Label 'Value of non-VAT liable sales', MaxLength = 100;
        ValueOfDomesticPurchases20Lbl: Label 'Value of Domestic Purchases 20 %', MaxLength = 100;
        ValueOfDomesticPurchases20TotalLbl: Label 'Value of Domestic Purchases 20 % total', MaxLength = 100;
        ValueOfDomesticPurchases5Lbl: Label 'Value of Domestic Purchases 5 %', MaxLength = 100;
        ValueOfDomesticPurchases5TotalLbl: Label 'Value of Domestic Purchases 5 % total', MaxLength = 100;
        ValueOfEuAcquisitions20Lbl: Label 'Value of EU Acquisitions 20 %', MaxLength = 100;
        ValueOfEuAcquisitions20TotalLbl: Label 'Value of EU Acquisitions 20 % total', MaxLength = 100;
        ValueOfEuAcquisitions5Lbl: Label 'Value of EU Acquisitions 5 %', MaxLength = 100;
        ValueOfEuAcquisitions5TotalLbl: Label 'Value of EU Acquisitions 5 % total', MaxLength = 100;
        ValueOfOverseasPurchases20Lbl: Label 'Value of Overseas Purchases 20 %', MaxLength = 100;
        ValueOfOverseasPurchases20TotalLbl: Label 'Value of Overseas Purchases 20 % total', MaxLength = 100;
        ValueOfOverseasPurchases5Lbl: Label 'Value of Overseas Purchases 5 %', MaxLength = 100;
        ValueOfOverseasPurchases5TotalLbl: Label 'Value of Overseas Purchases 5 % total', MaxLength = 100;
        ValueOfNonVatLiablePurchasesLbl: Label 'Value of non-VAT liable purchases', MaxLength = 100;
        NetVatPaidLbl: Label 'Net VAT to be paid (+); or to be reclaimed (-);', MaxLength = 100;
        SalesStandardLbl: Label 'Sales 20 % ', MaxLength = 100;
        SalesStandardFullLbl: Label 'Sales 20 % FULL', MaxLength = 100;
        SalesStandardTotalLbl: Label 'Sales 20 % total', MaxLength = 100;
        SalesReducedLbl: Label 'Sales 5 % ', MaxLength = 100;
        SalesReducedFullLbl: Label 'Sales 5 % FULL', MaxLength = 100;
        SalesReducedTotalLbl: Label 'Sales 5 % total', MaxLength = 100;
        EUStandardLbl: Label '20 % on EU Acquisitions etc.', MaxLength = 100;
        EUStandardTotalLbl: Label '20 % on EU Acquisitions etc. total', MaxLength = 100;
        EUReducedLbl: Label '5 % on EU Acquisitions etc.', MaxLength = 100;
        EUReducedTotalLbl: Label '5 % on EU Acquisitions etc. total', MaxLength = 100;
        PurchaseStandardLbl: Label 'Purchase VAT 20 % Domestic ', MaxLength = 100;
        PurchaseStandardFullLbl: Label 'Purchase VAT 20 % FULL Domestic', MaxLength = 100;
        PurchaseStandardTotalLbl: Label 'Purchase 20 % Domestic Total ', MaxLength = 100;
        PurchaseReducedLbl: Label 'Purchase VAT 5 % Domestic ', MaxLength = 100;
        PurchaseReducedFullLbl: Label 'Purchase 5 % Domestic Total FULL', MaxLength = 100;
        PurchaseReducedTotalLbl: Label 'Purchase 5 % Domestic total ', MaxLength = 100;
        DomesticStandardSalesLbl: Label 'Value of Domestic Sales 20 % ', MaxLength = 100;
        DomesticStandardTotalLbl: Label 'Value of Domestic Sales 20 % total', MaxLength = 100;
        DomesticReducedValueLbl: Label 'Value of Domestic Sales 5 % ', MaxLength = 100;
        DomesticReducedTotalLbl: Label 'Value of Domestic Sales 5 % total', MaxLength = 100;
        EUStandardSuppliesLbl: Label 'Value of EU Supplies 20 % ', MaxLength = 100;
        EUStandardSuppliesTotalLbl: Label 'Value of EU Supplies 20 % total', MaxLength = 100;
        EUReducedSuppliesLbl: Label 'Value of EU Supplies 5 % ', MaxLength = 100;
        EUReducedSuppliesTotalLbl: Label 'Value of EU Supplies 5 % total', MaxLength = 100;
        OverseasSalesValueLbl: Label 'Value of Overseas Sales 20 % ', MaxLength = 100;
        OverseasSalesTotalLbl: Label 'Value of Overseas Sales 20 % total', MaxLength = 100;
        OverseasSalesReducedLbl: Label 'Value of Overseas Sales 5 % ', MaxLength = 100;
        OverseasSalesReducedTotalLbl: Label 'Value of Overseas Sales 5 % total', MaxLength = 100;
        DomesticStandardPurchaseLbl: Label 'Value of Domestic Purchases 20 % ', MaxLength = 100;
        DomesticStandardPurchaseTotalLbl: Label 'Value of Domestic Purchases 20 % total', MaxLength = 100;
        DomesticReducedPurchaseValueLbl: Label 'Value of Domestic Purchases 5 % ', MaxLength = 100;
        DomesticReducedPurchaseTotalLbl: Label 'Value of Domestic Purchases 5 % total', MaxLength = 100;
        EUAcquisitionStandardLbl: Label 'Value of EU Acquisitions 20 % ', MaxLength = 100;
        EUAcquisitionStandardTotalLbl: Label 'Value of EU Acquisitions 20 % Total', MaxLength = 100;
        EUAcquisitionReducedLbl: Label 'Value of EU Acquisitions 5 % ', MaxLength = 100;
        EUAcquisitionReducedTotalLbl: Label 'Value of EU Acquisitions 5 % total', MaxLength = 100;
        OverseasPurchaseValueLbl: Label 'Value of Overseas Purchases 20 % ', MaxLength = 100;
        OverseasPurchaseTotalLbl: Label 'Value of Overseas Purchases 20 % total', MaxLength = 100;
        OverseasPurchaseReducedLbl: Label 'Value of Overseas Purchases 5 % ', MaxLength = 100;
        OverseasPurchaseReducedTotalLbl: Label 'Value of Overseas Purchases 5 % total', MaxLength = 100;

}