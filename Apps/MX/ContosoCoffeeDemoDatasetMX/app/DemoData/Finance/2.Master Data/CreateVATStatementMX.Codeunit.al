codeunit 14105 "Create VAT Statement MX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    var
        VATStatementLine: Record "VAT Statement Line";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateVATStatement: Codeunit "Create VAT Statement";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateVATPostingGroupsMX: Codeunit "Create VAT Posting Groups MX";
    begin
        ContosoVatStatement.InsertVATStatementName(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, UnrealizedVATDescLbl);

        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 390000, '1010', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), '', Enum::"VAT Statement Line Amount Type"::"Unrealized Amount", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::"Opposite Sign", SalesVat16PercOutgoingLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 400000, '1019', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1010..1018', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", SalesVat16PercOutgoingLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 410000, '1020', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT8(), '', Enum::"VAT Statement Line Amount Type"::"Unrealized Amount", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::"Opposite Sign", SalesVat8PercOutgoingLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 420000, '1029', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1020..1028', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", SalesVat8PercOutgoingLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 430000, '1030', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT16(), '', Enum::"VAT Statement Line Amount Type"::Amount, VATStatementLine."Calculate with"::"Opposite Sign", false, VATStatementLine."Print with"::"Opposite Sign", Vat16PercOnEuPurchasesEtcLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 440000, '1039', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1030..1038', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", Vat16PercOnEuPurchasesEtcLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 450000, '1040', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT8(), '', Enum::"VAT Statement Line Amount Type"::"Unrealized Amount", VATStatementLine."Calculate with"::"Opposite Sign", false, VATStatementLine."Print with"::"Opposite Sign", Vat8PercOnEuPurchasesEtcLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 460000, '1049', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1040..1048', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", Vat8PercOnEuPurchasesEtcLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 470000, '', Enum::"VAT Statement Line Type"::Description, Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, BlankLbl);
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), StatementNameUnrealLbl, 480000, '1099', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1019|1029|1039|1049', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", TotalLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVatStatementLine(var Rec: Record "VAT Statement Line")
    var
        VATStatementLine: Record "VAT Statement Line";
        CreateVATStatement: Codeunit "Create VAT Statement";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateVATPostingGroupsMX: Codeunit "Create VAT Posting Groups MX";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if (Rec."Statement Template Name" = CreateVATStatement.VATTemplateName()) and (Rec."Statement Name" = DefaultStatementNameLbl) then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '1010', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), '', Enum::"VAT Statement Line Amount Type"::"Amount", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::"Opposite Sign", SalesVat16PercOutgoingLbl);
                20000:
                    ValidateRecordFields(Rec, '1020', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT8(), '', Enum::"VAT Statement Line Amount Type"::"Amount", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::"Opposite Sign", SalesVat8PercOutgoingLbl);
                30000:
                    ValidateRecordFields(Rec, '1050', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT16(), '', Enum::"VAT Statement Line Amount Type"::"Amount", VATStatementLine."Calculate with"::"Opposite Sign", false, VATStatementLine."Print with"::"Opposite Sign", Vat16PercOnEuPurchasesEtcLbl);
                40000:
                    ValidateRecordFields(Rec, '1060', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT8(), '', Enum::"VAT Statement Line Amount Type"::"Amount", VATStatementLine."Calculate with"::"Opposite Sign", false, VATStatementLine."Print with"::"Opposite Sign", Vat8PercOnEuPurchasesEtcLbl);
                50000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, BlankLbl);
                60000:
                    ValidateRecordFields(Rec, '1099', Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1010..1090', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", TotalLbl);
                70000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, '');
                80000:
                    ValidateRecordFields(Rec, '1110', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), '', Enum::"VAT Statement Line Amount Type"::"Amount", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::Sign, PurchaseVat16PercDomesticLbl);
                90000:
                    ValidateRecordFields(Rec, '1120', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT8(), '', Enum::"VAT Statement Line Amount Type"::"Amount", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::Sign, PurchaseVat8PercDomesticLbl);
                100000:
                    ValidateRecordFields(Rec, '1150', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT16(), '', Enum::"VAT Statement Line Amount Type"::"Amount", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::Sign, PurchaseVat16PercEuLbl);
                110000:
                    ValidateRecordFields(Rec, '1160', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT8(), '', Enum::"VAT Statement Line Amount Type"::"Amount", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::Sign, PurchaseVat8PercEuLbl);
                120000:
                    ValidateRecordFields(Rec, '1179', Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1110..1170', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", PurchaseVatIngoingLbl);
                130000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, '');
                140000:
                    ValidateRecordFields(Rec, '1180', Enum::"VAT Statement Line Type"::"Account Totaling", CreateGLAccount.FuelTax(), Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", FuelTaxLbl);
                150000:
                    ValidateRecordFields(Rec, '1181', Enum::"VAT Statement Line Type"::"Account Totaling", CreateGLAccount.ElectricityTax(), Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", ElectricityTaxLbl);
                160000:
                    ValidateRecordFields(Rec, '1182', Enum::"VAT Statement Line Type"::"Account Totaling", CreateGLAccount.NaturalGasTax(), Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", NaturalGasTaxLbl);
                170000:
                    ValidateRecordFields(Rec, '1183', Enum::"VAT Statement Line Type"::"Account Totaling", CreateGLAccount.CoalTax(), Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", CoalTaxLbl);
                180000:
                    ValidateRecordFields(Rec, '1184', Enum::"VAT Statement Line Type"::"Account Totaling", CreateGLAccount.Co2Tax(), Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", Co2TaxLbl);
                190000:
                    ValidateRecordFields(Rec, '1185', Enum::"VAT Statement Line Type"::"Account Totaling", CreateGLAccount.WaterTax(), Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", WaterTaxLbl);
                200000:
                    ValidateRecordFields(Rec, '1189', Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1180..1188', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", TotalTaxesLbl);
                210000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, BlankLbl);
                220000:
                    ValidateRecordFields(Rec, '1199', Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1159|1189', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", TotalDeductionsLbl);
                230000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, BlankLbl);
                240000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, '');
                250000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1099|1199', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", VatPayableLbl);
                260000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, BlankLbl);
                270000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, '');
                280000:
                    ValidateRecordFields(Rec, '1210', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT16(), '', Enum::"VAT Statement Line Amount Type"::"Base", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::Sign, ValueOfEuPurchases16PercLbl);
                290000:
                    ValidateRecordFields(Rec, '1220', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT8(), '', Enum::"VAT Statement Line Amount Type"::"Base", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::Sign, ValueOfEuPurchases8PercLbl);
                300000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, '');
                310000:
                    ValidateRecordFields(Rec, '1240', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT16(), '', Enum::"VAT Statement Line Amount Type"::"Base", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::"Opposite Sign", ValueOfEuSales16PercLbl);
                320000:
                    ValidateRecordFields(Rec, '1250', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT8(), '', Enum::"VAT Statement Line Amount Type"::"Base", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::"Opposite Sign", ValueOfEuSales8PercLbl);
                330000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::Sign, '');
                340000:
                    ValidateRecordFields(Rec, '1310', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EXPORT(), CreateVATPostingGroupsMX.VAT16(), '', Enum::"VAT Statement Line Amount Type"::"Base", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::Sign, NonVatLiableSalesOverseasLbl);
                350000:
                    ValidateRecordFields(Rec, '1320', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EXPORT(), CreateVATPostingGroupsMX.VAT8(), '', Enum::"VAT Statement Line Amount Type"::"Base", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::Sign, NonVatLiableSalesOverseasLbl);
                360000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1310..1330', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", NonVatLiableSalesOverseasLbl);
                370000:
                    ValidateRecordFields(Rec, '1340', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.NOVAT(), '', Enum::"VAT Statement Line Amount Type"::"Base", VATStatementLine."Calculate with"::Sign, false, VATStatementLine."Print with"::Sign, NonVatLiableSalesDomesticLbl);
                380000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1340..1348', Enum::"VAT Statement Line Amount Type"::" ", VATStatementLine."Calculate with"::Sign, true, VATStatementLine."Print with"::"Opposite Sign", NonVatLiableSalesDomesticLbl);
            end;
    end;

    local procedure ValidateRecordFields(var VATStatementLine: Record "VAT Statement Line"; StatementRowNo: Code[10]; StatementLineType: Enum "VAT Statement Line Type"; AccountTotaling: Text[30]; GenPostingType: Enum "General Posting Type"; VatBusPostingGrp: Code[20]; VAtProdPostingGrp: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; CalulationWith: Option; StatementPrint: Boolean; PrintWith: Option; StatementDesc: Text[100])
    begin
        VatStatementLine.Validate("Row No.", StatementRowNo);
        VatStatementLine.Validate(Description, StatementDesc);
        VatStatementLine.Validate(Type, StatementLineType);
        VATStatementLine.Validate("Account Totaling", AccountTotaling);
        VatStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VatStatementLine.Validate("VAT Bus. Posting Group", VatBusPostingGrp);
        VatStatementLine.Validate("VAT Prod. Posting Group", VAtProdPostingGrp);
        VatStatementLine.Validate("Row Totaling", RowTotaling);
        VatStatementLine.Validate("Amount Type", AmountType);
        VatStatementLine.Validate("Calculate with", CalulationWith);
        VatStatementLine.Validate(Print, StatementPrint);
        VatStatementLine.Validate("Print with", PrintWith);
    end;

    var
        StatementNameUnrealLbl: Label 'UNREAL.', MaxLength = 10;
        UnrealizedVATDescLbl: Label 'Unrealized VAT', MaxLength = 100;
        DefaultStatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        SalesVat16PercOutgoingLbl: Label 'Sales VAT 16 % (outgoing)', MaxLength = 100;
        SalesVat8PercOutgoingLbl: Label 'Sales VAT 8 % (outgoing)', MaxLength = 100;
        Vat16PercOnEuPurchasesEtcLbl: Label 'VAT 16 % % on EU Purchases etc.', MaxLength = 100;
        Vat8PercOnEuPurchasesEtcLbl: Label 'VAT 8 % % on EU Purchases etc.', MaxLength = 100;
        TotalLbl: Label 'Total', MaxLength = 100;
        PurchaseVat16PercDomesticLbl: Label 'Purchase VAT 16 % Domestic', MaxLength = 100;
        PurchaseVat8PercDomesticLbl: Label 'Purchase VAT 8 % Domestic', MaxLength = 100;
        PurchaseVatIngoingLbl: Label 'Purchase VAT (ingoing)', MaxLength = 100;
        FuelTaxLbl: Label 'Fuel Tax', MaxLength = 100;
        ElectricityTaxLbl: Label 'Electricity Tax', MaxLength = 100;
        NaturalGasTaxLbl: Label 'Natural Gas Tax', MaxLength = 100;
        CoalTaxLbl: Label 'Coal Tax', MaxLength = 100;
        Co2TaxLbl: Label 'CO2 Tax', MaxLength = 100;
        WaterTaxLbl: Label 'Water Tax', MaxLength = 100;
        TotalTaxesLbl: Label 'Total Taxes', MaxLength = 100;
        BlankLbl: Label '--------------------------------------------------', MaxLength = 100;
        TotalDeductionsLbl: Label 'Total Deductions', MaxLength = 100;
        VatPayableLbl: Label 'VAT Payable', MaxLength = 100;
        ValueOfEuPurchases16PercLbl: Label 'Value of EU Purchases 16 %', MaxLength = 100;
        ValueOfEuPurchases8PercLbl: Label 'Value of EU Purchases 8 %', MaxLength = 100;
        ValueOfEuSales16PercLbl: Label 'Value of EU Sales 16 %', MaxLength = 100;
        ValueOfEuSales8PercLbl: Label 'Value of EU Sales 8 %', MaxLength = 100;
        NonVatLiableSalesOverseasLbl: Label 'Non-VAT liable sales, Overseas', MaxLength = 100;
        NonVatLiableSalesDomesticLbl: Label 'Non-VAT liable sales, Domestic', MaxLength = 100;
        PurchaseVAT16PercEULbl: Label 'Purchase VAT 16 % EU', MaxLength = 100;
        PurchaseVAT8PercEULbl: Label 'Purchase VAT 8 % EU', MaxLength = 100;
}