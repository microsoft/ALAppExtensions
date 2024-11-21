codeunit 14630 "Create VAT Statement IS"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnbeforeInsertVatReportingSetup(var Rec: Record "VAT Statement Line")
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
    begin
        if Rec."Statement Template Name" = CreateVATStatement.VATTemplateName() then
            case Rec."Line No." of
                200000:
                    Rec.Validate(Description, SalesStandardLbl);
                210000:
                    Rec.Validate(Description, SalesStandardFullLbl);
                220000:
                    Rec.Validate(Description, SalesStandardTotalLbl);
                270000:
                    Rec.Validate(Description, EUStandardLbl);
                280000:
                    Rec.Validate(Description, EUStandardTotalLbl);
                320000:
                    Rec.Validate(Description, PurchaseStandardLbl);
                330000:
                    Rec.Validate(Description, PurchaseStandardFullLbl);
                340000:
                    Rec.Validate(Description, PurchaseStandardTotalLbl);
                390000:
                    Rec.Validate(Description, EUStandardLbl);
                400000:
                    Rec.Validate(Description, EUStandardTotalLbl);
                450000:
                    Rec.Validate(Description, DomesticStandardSalesLbl);
                460000:
                    Rec.Validate(Description, DomesticStandardTotalLbl);
                500000:
                    Rec.Validate(Description, EUStandardSuppliesLbl);
                510000:
                    Rec.Validate(Description, EUStandardSuppliesTotalLbl);
                550000:
                    Rec.Validate(Description, OverseasSalesValueLbl);
                560000:
                    Rec.Validate(Description, OverseasSalesTotalLbl);
                620000:
                    Rec.Validate(Description, DomesticStandardPurchaseLbl);
                630000:
                    Rec.Validate(Description, DomesticStandardPurchaseTotalLbl);
                670000:
                    Rec.Validate(Description, EUAcquisitionStandardLbl);
                680000:
                    Rec.Validate(Description, EUAcquisitionStandardTotalLbl);
                720000:
                    Rec.Validate(Description, OverseasPurchaseValueLbl);
                730000:
                    Rec.Validate(Description, OverseasPurchaseTotalLbl);
            end;
    end;

    var
        SalesStandardLbl: Label 'Sales 24 % ', MaxLength = 100;
        SalesStandardFullLbl: Label 'Sales 24 % FULL', MaxLength = 100;
        SalesStandardTotalLbl: Label 'Sales 24 % total', MaxLength = 100;
        PurchaseStandardLbl: Label 'Purchase VAT 24 % Domestic ', MaxLength = 100;
        PurchaseStandardFullLbl: Label 'Purchase VAT 24 % FULL Domestic', MaxLength = 100;
        PurchaseStandardTotalLbl: Label 'Purchase 24 % Domestic Total ', MaxLength = 100;
        DomesticStandardSalesLbl: Label 'Value of Domestic Sales 24 % ', MaxLength = 100;
        DomesticStandardTotalLbl: Label 'Value of Domestic Sales 24 % total', MaxLength = 100;
        EUStandardSuppliesLbl: Label 'Value of EU Supplies 24 % ', MaxLength = 100;
        EUStandardSuppliesTotalLbl: Label 'Value of EU Supplies 24 % total', MaxLength = 100;
        OverseasSalesValueLbl: Label 'Value of Overseas Sales 24 % ', MaxLength = 100;
        OverseasSalesTotalLbl: Label 'Value of Overseas Sales 24 % total', MaxLength = 100;
        DomesticStandardPurchaseLbl: Label 'Value of Domestic Purchases 24 % ', MaxLength = 100;
        DomesticStandardPurchaseTotalLbl: Label 'Value of Domestic Purchases 24 % total', MaxLength = 100;
        EUAcquisitionStandardLbl: Label 'Value of EU Acquisitions 24 % ', MaxLength = 100;
        EUAcquisitionStandardTotalLbl: Label 'Value of EU Acquisitions 24 % Total', MaxLength = 100;
        OverseasPurchaseValueLbl: Label 'Value of Overseas Purchases 24 % ', MaxLength = 100;
        OverseasPurchaseTotalLbl: Label 'Value of Overseas Purchases 24 % total', MaxLength = 100;
        EUStandardLbl: Label '24 % on EU Acquisitions etc.', MaxLength = 100;
        EUStandardTotalLbl: Label '24 % on EU Acquisitions etc. total', MaxLength = 100;
}