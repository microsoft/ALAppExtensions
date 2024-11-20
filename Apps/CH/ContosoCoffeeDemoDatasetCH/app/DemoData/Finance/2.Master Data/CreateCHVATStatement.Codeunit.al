codeunit 11622 "Create CH VAT Statement"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Template", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATStatementTemplate(var Rec: Record "VAT Statement Template")
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
    begin
        case Rec.Name of
            CreateVATStatement.VATTemplateName():
                Rec.Validate("VAT Statement Report ID", Report::"Swiss VAT Statement");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATStatementLine(var Rec: Record "VAT Statement Line")
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateCHVATPostingGroups: Codeunit "Create CH VAT Posting Groups";
    begin
        if (Rec."Statement Template Name" = CreateVATStatement.VATTemplateName()) and (Rec."Statement Name" = StatementNameLbl) then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '0010', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, RevenueLbl);
                20000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                30000:
                    ValidateRecordFields(Rec, '0020', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, SalesLbl);
                40000:
                    ValidateRecordFields(Rec, '0022', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.Normal(), '', Enum::"VAT Statement Line Amount Type"::"Base", 1, true, 0, NormalVATRateLbl);
                50000:
                    ValidateRecordFields(Rec, '0026', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 1, true, 0, ReducedVATRateLbl);
                60000:
                    ValidateRecordFields(Rec, '0032', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Normal(), '', Enum::"VAT Statement Line Amount Type"::"Base", 1, false, 0, ExportAtNormallVATRateLbl);
                70000:
                    ValidateRecordFields(Rec, '0036', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 1, false, 0, ExportAtRedlVATRateLbl);
                80000:
                    ValidateRecordFields(Rec, '0040', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0030..0039', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ExportRevenueLbl);
                90000:
                    ValidateRecordFields(Rec, '0048', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0020..0039', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalRevenueLbl);
                100000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                110000:
                    ValidateRecordFields(Rec, '0060', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, DeductionsLbl);
                120000:
                    ValidateRecordFields(Rec, '0062', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Normal(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, true, 0, ExportAtNormallVATRateLbl);
                130000:
                    ValidateRecordFields(Rec, '0064', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, true, 0, ExportAtRedlVATRateLbl);
                140000:
                    ValidateRecordFields(Rec, '0098', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0060..0097', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalDeductionsLbl);
                150000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                160000:
                    ValidateRecordFields(Rec, '0099', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0048|0098', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TAXABLEREVENUELbl);
                170000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                180000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                190000:
                    ValidateRecordFields(Rec, '0100', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, VATSTATEMENTLbl);
                200000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                210000:
                    ValidateRecordFields(Rec, '0124', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.Normal(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, NormalVATRateLbl);
                220000:
                    ValidateRecordFields(Rec, '0126', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, ReducedVATRateLbl);
                230000:
                    ValidateRecordFields(Rec, '0199', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0101..0198', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TOTALVATLbl);
                240000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                250000:
                    ValidateRecordFields(Rec, '0200', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, AccountablePurchaseVATLbl);
                260000:
                    ValidateRecordFields(Rec, '0222', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.Normal(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, NormalVATRateLbl);
                270000:
                    ValidateRecordFields(Rec, '0224', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, ReducedVATRateLbl);
                280000:
                    ValidateRecordFields(Rec, '0262', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Normal(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, ImportNormalVATRateLbl);
                290000:
                    ValidateRecordFields(Rec, '0264', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Reduced(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, ImportRedVATRateLbl);
                300000:
                    ValidateRecordFields(Rec, '0280', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.Import(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, FullImportTaxToShippingAgentLbl);
                310000:
                    ValidateRecordFields(Rec, '0299', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0200..0298', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalPurchaseVATMatServicesLbl);
                320000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                330000:
                    ValidateRecordFields(Rec, '0300', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.OperatingExpense(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, InvestmentAndBusinessExpensesLbl);
                340000:
                    ValidateRecordFields(Rec, '0310', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.HalfNormal(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, BusinessExpensesWithPurchVATLbl);
                350000:
                    ValidateRecordFields(Rec, '0320', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.Hotel(), '', Enum::"VAT Statement Line Amount Type"::"Amount", 0, true, 0, BusinessExpHotelLbl);
                360000:
                    ValidateRecordFields(Rec, '0399', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0300..0398', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalPurchaseVATBusinessExpenseLbl);
                370000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                380000:
                    ValidateRecordFields(Rec, '0400', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0299|0399', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, TotalPurchVATLbl);
                390000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                400000:
                    ValidateRecordFields(Rec, '0500', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '0199|0400', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, AmountPayableLbl);
                410000:
                    ValidateRecordFields(Rec, '1230', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Normal(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 1, ValueOfEUExportsLbl);
                420000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1230..1238', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ValueOflVATExports16Lbl);
                430000:
                    ValidateRecordFields(Rec, '1240', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Hotel(), '', Enum::"VAT Statement Line Amount Type"::"Base", 1, false, 1, ValueOfEUExportsLbl);
                440000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1240..1248', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ValueOflVATExports7Lbl);
                450000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '');
                460000:
                    ValidateRecordFields(Rec, '1310', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Normal(), '', Enum::"VAT Statement Line Amount Type"::"Base", 0, false, 0, CountryExportOverseasLbl);
                470000:
                    ValidateRecordFields(Rec, '1312', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), CreateCHVATPostingGroups.Hotel(), '', Enum::"VAT Statement Line Amount Type"::"Base", 1, false, 0, CountryExportOverseasLbl);
                480000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1310..1318', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, CountryExportOverseasLbl);
                490000:
                    ValidateRecordFields(Rec, '1320', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), CreateCHVATPostingGroups.NOVAT(), '', Enum::"VAT Statement Line Amount Type"::"Base", 1, false, 0, TaxFreeSalesDomesticLbl);
                500000:
                    ValidateRecordFields(Rec, '', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '1320..1328', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, TaxFreeSalesDomesticLbl);

            end;
    end;


    local procedure ValidateRecordFields(var VATStatementLine: Record "VAT Statement Line"; StatementRowNo: Code[10]; StatementLineType: Enum "VAT Statement Line Type"; GenPostingType: Enum "General Posting Type"; VatBusPostingGrp: Code[20]; VAtProdPostingGrp: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; CalulationWith: Option; StatementPrint: Boolean; PrintWith: Option; StatementDesc: Text[100])
    begin
        VatStatementLine.Validate("Row No.", StatementRowNo);
        VatStatementLine.Validate(Description, StatementDesc);
        VatStatementLine.Validate(Type, StatementLineType);
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
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        RevenueLbl: Label 'I. REVENUE', MaxLength = 100;
        SalesLbl: Label '1. Sales', MaxLength = 100;
        NormalVATRateLbl: Label 'Normal VAT rate', MaxLength = 100;
        ReducedVATRateLbl: Label 'Reduced VAT rate', MaxLength = 100;
        ExportAtNormallVATRateLbl: Label 'Export at normal VAT rate', MaxLength = 100;
        ExportAtRedlVATRateLbl: Label 'Export at red. VAT rate', MaxLength = 100;
        ExportRevenueLbl: Label 'Export Revenue', MaxLength = 100;
        TotalRevenueLbl: Label '3. Total Revenue', MaxLength = 100;
        DeductionsLbl: Label '4. Deductions', MaxLength = 100;
        TotalDeductionsLbl: Label '5. Total Deductions', MaxLength = 100;
        TAXABLEREVENUELbl: Label '6. TAXABLE REVENUE', MaxLength = 100;
        VATSTATEMENTLbl: Label 'II. VAT STATEMENT', MaxLength = 100;
        TOTALVATLbl: Label '10. TOTAL VAT', MaxLength = 100;
        AccountablePurchaseVATLbl: Label '11. Accountable purchase VAT', MaxLength = 100;
        ImportNormalVATRateLbl: Label 'Import normal VAT rate', MaxLength = 100;
        ImportRedVATRateLbl: Label 'Import red. VAT rate', MaxLength = 100;
        FullImportTaxToShippingAgentLbl: Label 'Full import Tax (to shipping agent)', MaxLength = 100;
        TotalPurchaseVATMatServicesLbl: Label '11a Total purchase VAT mat. & services', MaxLength = 100;
        InvestmentAndBusinessExpensesLbl: Label 'Investment and business expenses', MaxLength = 100;
        BusinessExpensesWithPurchVATLbl: Label 'Business expenses with1/2 purch. VAT', MaxLength = 100;
        BusinessExpHotelLbl: Label 'Business exp. Hotel', MaxLength = 100;
        TotalPurchaseVATBusinessExpenseLbl: Label '11b Total purch. VAT business expenses', MaxLength = 100;
        TotalPurchVATLbl: Label '12. Total purch. VAT', MaxLength = 100;
        AmountPayableLbl: Label '15. Amount Payable', MaxLength = 100;
        ValueOflVATExports16Lbl: Label 'Value of EU exports 16%', MaxLength = 100;
        ValueOfEUExportsLbl: Label 'Value of EU exports', MaxLength = 100;
        ValueOflVATExports7Lbl: Label 'Value of EU exports 7%', MaxLength = 100;
        CountryExportOverseasLbl: Label '3rd Country Export, overseas', MaxLength = 100;
        TaxFreeSalesDomesticLbl: Label 'Tax-Free sales, domestic', MaxLength = 100;
}