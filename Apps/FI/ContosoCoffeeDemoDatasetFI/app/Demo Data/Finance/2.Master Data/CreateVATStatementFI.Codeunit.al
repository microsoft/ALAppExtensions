codeunit 13447 "Create VAT Statement FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVatStatementLine(var Rec: Record "VAT Statement Line")
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
    begin
        if (Rec."Statement Template Name" = CreateVATStatement.VATTemplateName()) and (Rec."Statement Name" = StatementNameLbl) then
            case Rec."Line No." of
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
    end;

    var
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        SalesStandardLbl: Label 'Sales 24 % ', MaxLength = 100;
        SalesStandardFullLbl: Label 'Sales 24 % FULL', MaxLength = 100;
        SalesStandardTotalLbl: Label 'Sales 24 % total', MaxLength = 100;
        SalesReducedLbl: Label 'Sales 17 % ', MaxLength = 100;
        SalesReducedFullLbl: Label 'Sales 17 % FULL', MaxLength = 100;
        SalesReducedTotalLbl: Label 'Sales 17 % total', MaxLength = 100;
        EUStandardLbl: Label '24 % on EU Acquisitions etc.', MaxLength = 100;
        EUStandardTotalLbl: Label '24 % on EU Acquisitions etc. total', MaxLength = 100;
        EUReducedLbl: Label '17 % on EU Acquisitions etc.', MaxLength = 100;
        EUReducedTotalLbl: Label '17 % on EU Acquisitions etc. total', MaxLength = 100;
        PurchaseStandardLbl: Label 'Purchase VAT 24 % Domestic ', MaxLength = 100;
        PurchaseStandardFullLbl: Label 'Purchase VAT 24 % FULL Domestic', MaxLength = 100;
        PurchaseStandardTotalLbl: Label 'Purchase 24 % Domestic Total ', MaxLength = 100;
        PurchaseReducedLbl: Label 'Purchase VAT 17 % Domestic ', MaxLength = 100;
        PurchaseReducedFullLbl: Label 'Purchase 17 % Domestic Total FULL', MaxLength = 100;
        PurchaseReducedTotalLbl: Label 'Purchase 17 % Domestic total ', MaxLength = 100;
        DomesticStandardSalesLbl: Label 'Value of Domestic Sales 24 % ', MaxLength = 100;
        DomesticStandardTotalLbl: Label 'Value of Domestic Sales 24 % total', MaxLength = 100;
        DomesticReducedValueLbl: Label 'Value of Domestic Sales 17 % ', MaxLength = 100;
        DomesticReducedTotalLbl: Label 'Value of Domestic Sales 17 % total', MaxLength = 100;
        EUStandardSuppliesLbl: Label 'Value of EU Supplies 24 % ', MaxLength = 100;
        EUStandardSuppliesTotalLbl: Label 'Value of EU Supplies 24 % total', MaxLength = 100;
        EUReducedSuppliesLbl: Label 'Value of EU Supplies 17 % ', MaxLength = 100;
        EUReducedSuppliesTotalLbl: Label 'Value of EU Supplies 17 % total', MaxLength = 100;
        OverseasSalesValueLbl: Label 'Value of Overseas Sales 24 % ', MaxLength = 100;
        OverseasSalesTotalLbl: Label 'Value of Overseas Sales 24 % total', MaxLength = 100;
        OverseasSalesReducedLbl: Label 'Value of Overseas Sales 17 % ', MaxLength = 100;
        OverseasSalesReducedTotalLbl: Label 'Value of Overseas Sales 17 % total', MaxLength = 100;
        DomesticStandardPurchaseLbl: Label 'Value of Domestic Purchases 24 % ', MaxLength = 100;
        DomesticStandardPurchaseTotalLbl: Label 'Value of Domestic Purchases 24 % total', MaxLength = 100;
        DomesticReducedPurchaseValueLbl: Label 'Value of Domestic Purchases 17 % ', MaxLength = 100;
        DomesticReducedPurchaseTotalLbl: Label 'Value of Domestic Purchases 17 % total', MaxLength = 100;
        EUAcquisitionStandardLbl: Label 'Value of EU Acquisitions 24 % ', MaxLength = 100;
        EUAcquisitionStandardTotalLbl: Label 'Value of EU Acquisitions 24 % Total', MaxLength = 100;
        EUAcquisitionReducedLbl: Label 'Value of EU Acquisitions 17 % ', MaxLength = 100;
        EUAcquisitionReducedTotalLbl: Label 'Value of EU Acquisitions 17 % total', MaxLength = 100;
        OverseasPurchaseValueLbl: Label 'Value of Overseas Purchases 24 % ', MaxLength = 100;
        OverseasPurchaseTotalLbl: Label 'Value of Overseas Purchases 24 % total', MaxLength = 100;
        OverseasPurchaseReducedLbl: Label 'Value of Overseas Purchases 17 % ', MaxLength = 100;
        OverseasPurchaseReducedTotalLbl: Label 'Value of Overseas Purchases 17 % total', MaxLength = 100;
}