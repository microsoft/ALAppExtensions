codeunit 18076 "GST TCS Library"
{

    var
        TaxBaseTestPublishers: Codeunit "Tax Base Test Publishers";

    procedure CreateGSTTCSSetup(
        var Customer: Record Customer;
        var TCSNOC: Code[10];
        var TCSConcessionalCode: Code[10];
        LocationCode: Code[10])
    begin
        TaxBaseTestPublishers.InsertTCSSetup(Customer, TCSNOC, TCSConcessionalCode);
        TaxBaseTestPublishers.ModifyLocationTCAN(LocationCode);
    end;

    procedure UpdateCustomerNOC(
        var Customer: Record Customer;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    begin
        TaxBaseTestPublishers.ModifyCustomerNOC(Customer, ThresholdOverlook, SurchargeOverlook);
    end;

    procedure GetTCSTaxTypeCode(): Code[20]
    var
        TCSTaxTypeCode: Code[20];
    begin
        TaxBaseTestPublishers.OnAfterGetTCSSetupCode(TCSTaxTypeCode);
        exit(TCSTaxTypeCode);
    end;

    procedure UpdateSalesLineWithTCSNOC(
        var SalesLine: Record "Sales Line";
        TCSNOC: Code[10])
    begin
        TaxBaseTestPublishers.ModifySalesLineWithTCSNOC(SalesLine, TCSNOC);
    end;

    procedure CalculateTCS(GenJnlLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJnlLine, GenJnlLine)
    end;
}