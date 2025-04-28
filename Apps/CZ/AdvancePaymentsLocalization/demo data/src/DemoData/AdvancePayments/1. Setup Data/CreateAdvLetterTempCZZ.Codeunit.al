#pragma warning disable AA0247
codeunit 31427 "Create Adv. Letter Temp. CZZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAdvancePaymentsCZZ: Codeunit "Contoso Advance Payments CZZ";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        ContosoAdvancePaymentsCZZ.InsertAdvanceLetterTemplate(PurchaseDomestic(), Enum::"Advance Letter Type CZZ"::Purchase, DomesticPurchaseAdvancesLbl, CreateGLAccountCZ.PurchaseAdvancesDomestic(), true, CreateNoSeriesCZ.DomesticPurchaseAdvance(), CreateNoSeriesCZ.PurchaseAdvanceVATInvoice(), CreateNoSeriesCZ.PurchaseAdvanceVATCreditMemo());
        ContosoAdvancePaymentsCZZ.InsertAdvanceLetterTemplate(PurchaseForeign(), Enum::"Advance Letter Type CZZ"::Purchase, ForeignPurchaseAdvancesLbl, CreateGLAccountCZ.PurchaseAdvancesForeign(), true, CreateNoSeriesCZ.ForeignPurchaseAdvance(), CreateNoSeriesCZ.PurchaseAdvanceVATInvoice(), CreateNoSeriesCZ.PurchaseAdvanceVATCreditMemo());
        ContosoAdvancePaymentsCZZ.InsertAdvanceLetterTemplate(PurchaseEU(), Enum::"Advance Letter Type CZZ"::Purchase, EUPurchaseAdvancesLbl, CreateGLAccountCZ.PurchaseAdvancesEU(), true, CreateNoSeriesCZ.EUPurchaseAdvance(), CreateNoSeriesCZ.PurchaseAdvanceVATInvoice(), CreateNoSeriesCZ.PurchaseAdvanceVATCreditMemo());
        ContosoAdvancePaymentsCZZ.InsertAdvanceLetterTemplate(SalesDomestic(), Enum::"Advance Letter Type CZZ"::Sales, DomesticSalesAdvancesLbl, CreateGLAccountCZ.SalesAdvancesDomestic(), true, CreateNoSeriesCZ.DomesticSalesAdvance(), CreateNoSeriesCZ.SalesAdvanceVATInvoice(), CreateNoSeriesCZ.SalesAdvanceVATCreditMemo());
        ContosoAdvancePaymentsCZZ.InsertAdvanceLetterTemplate(SalesForeign(), Enum::"Advance Letter Type CZZ"::Sales, ForeignSalesAdvancesLbl, CreateGLAccountCZ.SalesAdvancesForeign(), true, CreateNoSeriesCZ.ForeignSalesAdvance(), CreateNoSeriesCZ.SalesAdvanceVATInvoice(), CreateNoSeriesCZ.SalesAdvanceVATCreditMemo());
        ContosoAdvancePaymentsCZZ.InsertAdvanceLetterTemplate(SalesEU(), Enum::"Advance Letter Type CZZ"::Sales, EUSalesAdvancesLbl, CreateGLAccountCZ.SalesAdvancesEU(), true, CreateNoSeriesCZ.EUSalesAdvance(), CreateNoSeriesCZ.SalesAdvanceVATInvoice(), CreateNoSeriesCZ.SalesAdvanceVATCreditMemo());
    end;

    procedure PurchaseDomestic(): Code[20]
    begin
        exit(PurchaseDomesticLbl);
    end;

    procedure PurchaseForeign(): Code[20]
    begin
        exit(PurchaseForeignLbl);
    end;

    procedure PurchaseEU(): Code[20]
    begin
        exit(PurchaseEULbl);
    end;

    procedure SalesDomestic(): Code[20]
    begin
        exit(SalesDomesticLbl);
    end;

    procedure SalesForeign(): Code[20]
    begin
        exit(SalesForeignLbl);
    end;

    procedure SalesEU(): Code[20]
    begin
        exit(SalesEULbl);
    end;

    var
        PurchaseDomesticLbl: Label 'P_Domestic', MaxLength = 20;
        PurchaseForeignLbl: Label 'P_Foreign', MaxLength = 20;
        PurchaseEULbl: Label 'P_EU', MaxLength = 20;
        SalesDomesticLbl: Label 'S_Domestic', MaxLength = 20;
        SalesForeignLbl: Label 'S_Foreign', MaxLength = 20;
        SalesEULbl: Label 'S_EU', MaxLength = 20;
        DomesticPurchaseAdvancesLbl: Label 'Domestic Purchase Advances', MaxLength = 50;
        ForeignPurchaseAdvancesLbl: Label 'Foreign Purchase Advances', MaxLength = 50;
        EUPurchaseAdvancesLbl: Label 'EU Purchase Advances', MaxLength = 50;
        DomesticSalesAdvancesLbl: Label 'Domestic Sales Advances', MaxLength = 50;
        ForeignSalesAdvancesLbl: Label 'Foreign Sales Advances', MaxLength = 50;
        EUSalesAdvancesLbl: Label 'EU Sales Advances', MaxLength = 50;
}
