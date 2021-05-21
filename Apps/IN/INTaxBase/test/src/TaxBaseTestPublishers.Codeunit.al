codeunit 18598 "Tax Base Test Publishers"
{

    [IntegrationEvent(false, false)]
    procedure InsertTCSSetup(Customer: Record Customer; var TCSNOC: Code[10]; var ConcessionalCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure ModifyLocationTCAN(LocationCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure ModifyCustomerNOC(Customer: Record Customer; ThresholdOverlook: Boolean; SurchargeOverlook: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterGetTCSSetupCode(var TCSTaxTypeCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure ModifySalesLineWithTCSNOC(var SalesLine: Record "Sales Line"; TCSNOC: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure InsertJournalVoucherPostingSetup(VoucherType: Enum "Gen. Journal Template Type"; TransactionDirection: Option " ",Debit,Credit,Both)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure InsertJournalVoucherPostingSetupWithLocationCode(VoucherType: Enum "Gen. Journal Template Type"; LocationCode: Code[20]; TransactionDirection: Option " ",Debit,Credit,Both)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure InsertVoucherDebitAccountNo(VoucherType: Enum "Gen. Journal Template Type"; var AccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure InsertVoucherCreditAccountNo(VoucherType: Enum "Gen. Journal Template Type"; var AccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure InsertVoucherDebitAccountNoWithLocationCode(VoucherType: Enum "Gen. Journal Template Type"; LocationCode: Code[20]; var AccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure InsertVoucherCreditAccountNoWithLocationCode(VoucherType: Enum "Gen. Journal Template Type"; LocationCode: Code[20]; var AccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure CreateTDSSetupStale(var TDSSection: Code[10]; var Vendor: Record Vendor)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure CreateGenJournalLineWithTDSStale(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor; var TDSSection: Code[10])
    begin
    end;
}