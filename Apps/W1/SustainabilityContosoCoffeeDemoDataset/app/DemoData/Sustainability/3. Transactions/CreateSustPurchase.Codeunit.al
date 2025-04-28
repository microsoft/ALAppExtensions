#pragma warning disable AA0247
codeunit 5259 "Create Sust. Purchase"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreatePurchaseInvoiceWithGL();
        CreatePurchaseInvoiceWithItem();
    end;

    local procedure CreatePurchaseInvoiceWithGL()
    var
        PurchHeader: Record "Purchase Header";
        CreateSustVendor: Codeunit "Create Sust. Vendor";
        CreateSustGLAccount: Codeunit "Create Sustainability Account";
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreateCommonPostingGroup: Codeunit "Create Common Posting Group";
    begin
        PurchHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Invoice, CreateSustVendor.SustVendor64000(), SustainabilityYourReference(), '', ContosoUtilities.AdjustDate(19030410D), '', '124GH68', CreatePaymentTerms.PaymentTermsDAYS21(), CreatePaymentMethod.Cash());
        ContosoPurchase.InsertPurchaseLineWithGL(PurchHeader, CreateSustGLAccount.UtilitiesExpensePowerPlant(), 1, CreateUnitOfMeasure.Piece(), 4600);
        ConsotoSustainability.UpdateSustainabilityPurchLine(PurchHeader, CreateSustainabilityAccount.PurchasedElectricityWideWorldImporters(), 1253.43, 0, 0, CreateCommonPostingGroup.NonTaxable());
    end;

    local procedure CreatePurchaseInvoiceWithItem()
    var
        PurchHeader: Record "Purchase Header";
        CreateVendor: Codeunit "Create Vendor";
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreateCommonPostingGroup: Codeunit "Create Common Posting Group";
    begin
        PurchHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Invoice, CreateVendor.EUGraphicDesign(), SustainabilityYourReference(), '', ContosoUtilities.AdjustDate(19030410D), '', '23DF43F', CreatePaymentTerms.PaymentTermsCM(), CreatePaymentMethod.Cash());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchHeader, CreateSustItem.SustItemCC1000(), 1, CreateUnitOfMeasure.Piece(), 240);
        ConsotoSustainability.UpdateSustainabilityPurchLine(PurchHeader, CreateSustainabilityAccount.CarbonCreditScope1(), 3000, 0, 0, CreateCommonPostingGroup.NonTaxable());
    end;

    procedure SustainabilityYourReference(): Code[35]
    begin
        exit(SustainabilityYourReferenceLbl);
    end;

    var
        ContosoPurchase: Codeunit "Contoso Purchase";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateSustItem: Codeunit "Create Sust. Item";
        ConsotoSustainability: Codeunit "Contoso Sustainability";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateSustainabilityAccount: Codeunit "Create Sustainability Account";
        SustainabilityYourReferenceLbl: Label 'Sustainability', MaxLength = 35;
}
