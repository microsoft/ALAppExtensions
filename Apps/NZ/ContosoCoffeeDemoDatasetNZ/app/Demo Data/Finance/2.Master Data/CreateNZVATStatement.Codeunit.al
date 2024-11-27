codeunit 17144 "Create NZ VAT Statement"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleLine(var Rec: Record "VAT Statement Line")
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
    begin
        if (Rec."Statement Template Name" = CreateVATStatement.VATTemplateName()) and (Rec."Statement Name" = StatementNameLbl) then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '1010', SalesVat15PercOutgoingLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT15(), '', Enum::"VAT Statement Line Amount Type"::Amount, Rec."Calculate with"::Sign, false, Rec."Print with"::"Opposite Sign", '5');
                20000:
                    ValidateRecordFields(Rec, '1020', SalesVat9PercOutgoingLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT9(), '', Enum::"VAT Statement Line Amount Type"::Amount, Rec."Calculate with"::Sign, false, Rec."Print with"::"Opposite Sign", '6');
                30000:
                    ValidateRecordFields(Rec, '1050', Vat15PercPercOnEuPurchasesEtcLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateNZVATPostingGroup.MISC(), CreateNZVATPostingGroup.VAT15(), '', Enum::"VAT Statement Line Amount Type"::Amount, Rec."Calculate with"::"Opposite Sign", false, Rec."Print with"::"Opposite Sign", '7');
                40000:
                    ValidateRecordFields(Rec, '1060', Vat9PercPercOnEuPurchasesEtcLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateNZVATPostingGroup.MISC(), CreateNZVATPostingGroup.VAT9(), '', Enum::"VAT Statement Line Amount Type"::Amount, Rec."Calculate with"::"Opposite Sign", false, Rec."Print with"::"Opposite Sign", '8');
                50000:
                    ValidateRecordFields(Rec, '', BlankLbl, Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::Sign, '');
                60000:
                    ValidateRecordFields(Rec, '1099', TotalLbl, Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1019|1029|1039|1049', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
                70000:
                    ValidateRecordFields(Rec, '', '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::Sign, '');
                80000:
                    ValidateRecordFields(Rec, '1110', PurchaseVat15PercDomesticLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT15(), '', Enum::"VAT Statement Line Amount Type"::Amount, Rec."Calculate with"::Sign, false, Rec."Print with"::Sign, '9');
                90000:
                    ValidateRecordFields(Rec, '1120', PurchaseVat9PercDomesticLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT9(), '', Enum::"VAT Statement Line Amount Type"::Amount, Rec."Calculate with"::Sign, false, Rec."Print with"::Sign, '10');
                100000:
                    ValidateRecordFields(Rec, '1150', PurchaseVat15PercEuLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateNZVATPostingGroup.MISC(), CreateNZVATPostingGroup.VAT15(), '', Enum::"VAT Statement Line Amount Type"::Amount, Rec."Calculate with"::Sign, false, Rec."Print with"::Sign, '11');
                110000:
                    ValidateRecordFields(Rec, '1160', PurchaseVat9PercEuLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateNZVATPostingGroup.MISC(), CreateNZVATPostingGroup.VAT9(), '', Enum::"VAT Statement Line Amount Type"::Amount, Rec."Calculate with"::Sign, false, Rec."Print with"::Sign, '12');
                120000:
                    ValidateRecordFields(Rec, '1179', PurchaseVatIngoingLbl, Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1110..1170', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '13');
                140000:
                    ValidateRecordFields(Rec, '1180', FuelTaxLbl, Enum::"VAT Statement Line Type"::"Account Totaling", '5630', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '14');
                150000:
                    ValidateRecordFields(Rec, '1181', ElectricityTaxLbl, Enum::"VAT Statement Line Type"::"Account Totaling", '5630', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '15');
                160000:
                    ValidateRecordFields(Rec, '1182', NaturalGasTaxLbl, Enum::"VAT Statement Line Type"::"Account Totaling", '5630', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
                170000:
                    ValidateRecordFields(Rec, '1183', CoalTaxLbl, Enum::"VAT Statement Line Type"::"Account Totaling", '5630', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
                180000:
                    ValidateRecordFields(Rec, '1184', Co2TaxLbl, Enum::"VAT Statement Line Type"::"Account Totaling", '5630', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
                190000:
                    ValidateRecordFields(Rec, '1185', WaterTaxLbl, Enum::"VAT Statement Line Type"::"Account Totaling", '5630', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
                200000:
                    ValidateRecordFields(Rec, '1189', TotalTaxesLbl, Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1180..1188', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
                210000:
                    ValidateRecordFields(Rec, '', BlankLbl, Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::Sign, '');
                220000:
                    ValidateRecordFields(Rec, '1199', TotalDeductionsLbl, Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1159|1189', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
                230000:
                    ValidateRecordFields(Rec, '', BlankLbl, Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::Sign, '');
                240000:
                    ValidateRecordFields(Rec, '', '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::Sign, '');
                250000:
                    ValidateRecordFields(Rec, '', VatPayableLbl, Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1099|1199', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
                260000:
                    ValidateRecordFields(Rec, '', BlankLbl, Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::Sign, '');
                270000:
                    ValidateRecordFields(Rec, '', '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::Sign, '');
                280000:
                    ValidateRecordFields(Rec, '1210', ValueOfEuPurchases15PercLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateNZVATPostingGroup.MISC(), CreateNZVATPostingGroup.VAT15(), '', Enum::"VAT Statement Line Amount Type"::Base, Rec."Calculate with"::Sign, false, Rec."Print with"::Sign, '');
                290000:
                    ValidateRecordFields(Rec, '1220', ValueOfEuPurchases9PercLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Purchase, CreateNZVATPostingGroup.MISC(), CreateNZVATPostingGroup.VAT9(), '', Enum::"VAT Statement Line Amount Type"::Base, Rec."Calculate with"::Sign, false, Rec."Print with"::Sign, '');
                300000:
                    ValidateRecordFields(Rec, '', '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::Sign, '');
                310000:
                    ValidateRecordFields(Rec, '1240', ValueOfEuSales15PercLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateNZVATPostingGroup.MISC(), CreateNZVATPostingGroup.VAT15(), '', Enum::"VAT Statement Line Amount Type"::Base, Rec."Calculate with"::Sign, false, Rec."Print with"::"Opposite Sign", '');
                320000:
                    ValidateRecordFields(Rec, '1250', ValueOfEuSales9PercLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateNZVATPostingGroup.MISC(), CreateNZVATPostingGroup.VAT9(), '', Enum::"VAT Statement Line Amount Type"::Base, Rec."Calculate with"::Sign, false, Rec."Print with"::"Opposite Sign", '');
                330000:
                    ValidateRecordFields(Rec, '', '', Enum::"VAT Statement Line Type"::Description, '', Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::Sign, '');
                340000:
                    ValidateRecordFields(Rec, '1310', NonVatLiableSalesOverseasLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateNZVATPostingGroup.VAT15(), '', Enum::"VAT Statement Line Amount Type"::Base, Rec."Calculate with"::Sign, false, Rec."Print with"::Sign, '');
                350000:
                    ValidateRecordFields(Rec, '1320', NonVatLiableSalesOverseasLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateNZVATPostingGroup.VAT9(), '', Enum::"VAT Statement Line Amount Type"::Base, Rec."Calculate with"::Sign, false, Rec."Print with"::Sign, '');
                360000:
                    ValidateRecordFields(Rec, '', NonVatLiableSalesOverseasLbl, Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1310..1330', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
                370000:
                    ValidateRecordFields(Rec, '1340', NonVatLiableSalesDomesticLbl, Enum::"VAT Statement Line Type"::"VAT Entry Totaling", '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.NoVAT(), '', Enum::"VAT Statement Line Amount Type"::Base, Rec."Calculate with"::Sign, false, Rec."Print with"::Sign, '');
                380000:
                    ValidateRecordFields(Rec, '', NonVatLiableSalesDomesticLbl, Enum::"VAT Statement Line Type"::"Row Totaling", '', Enum::"General Posting Type"::" ", '', '', '1340..1348', Enum::"VAT Statement Line Amount Type"::" ", Rec."Calculate with"::Sign, true, Rec."Print with"::"Opposite Sign", '');
            end;
    end;

    local procedure ValidateRecordFields(var VATStatementLine: Record "VAT Statement Line"; RowNo: Code[10]; Description: Text[100]; Type: Enum "VAT Statement Line Type"; AccountTotaling: Text[30]; GenPostingType: Enum "General Posting Type"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; Calculatewith: Option; Print: Boolean; Printwith: Option; BoxNo: Text[30])
    begin
        VATStatementLine.Validate("Row No.", RowNo);
        VATStatementLine.Validate(Description, Description);
        VATStatementLine.Validate(Type, Type);
        VATStatementLine.Validate("Account Totaling", AccountTotaling);
        VATStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VATStatementLine.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        VATStatementLine.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        VATStatementLine.Validate("Row Totaling", RowTotaling);
        VATStatementLine.Validate("Amount Type", AmountType);
        VATStatementLine.Validate("Calculate with", Calculatewith);
        VATStatementLine.Validate(Print, Print);
        VATStatementLine.Validate("Print with", Printwith);
        VATStatementLine.Validate("Box No.", BoxNo);
    end;

    var
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        SalesVat15PercOutgoingLbl: Label 'Sales VAT 15 % (outgoing)', MaxLength = 100;
        SalesVat9PercOutgoingLbl: Label 'Sales VAT 9 % (outgoing)', MaxLength = 100;
        Vat15PercPercOnEuPurchasesEtcLbl: Label 'VAT 15 % % on EU Purchases etc.', MaxLength = 100;
        Vat9PercPercOnEuPurchasesEtcLbl: Label 'VAT 9 % % on EU Purchases etc.', MaxLength = 100;
        BlankLbl: Label '--------------------------------------------------', MaxLength = 100;
        TotalLbl: Label 'Total', MaxLength = 100;
        PurchaseVat15PercDomesticLbl: Label 'Purchase VAT 15 % Domestic', MaxLength = 100;
        PurchaseVat9PercDomesticLbl: Label 'Purchase VAT 9 % Domestic', MaxLength = 100;
        PurchaseVat15PercEuLbl: Label 'Purchase VAT 15 % EU', MaxLength = 100;
        PurchaseVat9PercEuLbl: Label 'Purchase VAT 9 % EU', MaxLength = 100;
        PurchaseVatIngoingLbl: Label 'Purchase VAT (ingoing)', MaxLength = 100;
        FuelTaxLbl: Label 'Fuel Tax', MaxLength = 100;
        ElectricityTaxLbl: Label 'Electricity Tax', MaxLength = 100;
        NaturalGasTaxLbl: Label 'Natural Gas Tax', MaxLength = 100;
        CoalTaxLbl: Label 'Coal Tax', MaxLength = 100;
        Co2TaxLbl: Label 'CO2 Tax', MaxLength = 100;
        WaterTaxLbl: Label 'Water Tax', MaxLength = 100;
        TotalTaxesLbl: Label 'Total Taxes', MaxLength = 100;
        TotalDeductionsLbl: Label 'Total Deductions', MaxLength = 100;
        VatPayableLbl: Label 'VAT Payable', MaxLength = 100;
        ValueOfEuPurchases15PercLbl: Label 'Value of EU Purchases 15 %', MaxLength = 100;
        ValueOfEuPurchases9PercLbl: Label 'Value of EU Purchases 9 %', MaxLength = 100;
        ValueOfEuSales15PercLbl: Label 'Value of EU Sales 15 %', MaxLength = 100;
        ValueOfEuSales9PercLbl: Label 'Value of EU Sales 9 %', MaxLength = 100;
        NonVatLiableSalesOverseasLbl: Label 'Non-VAT liable sales, Overseas', MaxLength = 100;
        NonVatLiableSalesDomesticLbl: Label 'Non-VAT liable sales, Domestic', MaxLength = 100;
}