codeunit 18252 "GST Non Availment Session Mgt"
{
    SingleInstance = true;

    var
#if not CLEAN20
        [Obsolete('Replaced by new implementation in codeunit GST Journal Line Subscribers.', '19.0')]
        CashPaymentGSTAmount: Decimal;
#endif
        QtyToBeInvoiced: Decimal;
        GSTAmountToBeLoaded: Decimal;
        CustomDutyAmount: Decimal;
#if not CLEAN20
        [Obsolete('Replaced by new implementation in codeunit GST Journal Line Subscribers.', '19.0')]
        IsPaymentMethodCodeTransaction: Boolean;
#endif

    procedure SetQtyToBeInvoiced(QtyInvoiced: Decimal)
    begin
        QtyToBeInvoiced := QtyInvoiced;
    end;

    procedure GetQtyToBeInvoiced(): Decimal
    begin
        exit(QtyToBeInvoiced);
    end;

    procedure SetGSTAmountToBeLoaded(GSTAmount: Decimal)
    begin
        GSTAmountToBeLoaded := GSTAmount;
    end;

    procedure GetGSTAmountToBeLoaded(): Decimal
    begin
        exit(GSTAmountToBeLoaded);
    end;

    procedure SetCustomDutyAmount(CustomDutyAmt: Decimal)
    begin
        CustomDutyAmount := CustomDutyAmt;
    end;

    procedure GetCustomDutyAmount(): Decimal
    begin
        exit(CustomDutyAmount);
    end;

#if not CLEAN20
    [Obsolete('Replaced by new implementation in codeunit GST Journal Line Subscribers.', '19.0')]
    procedure SetPaymentMethodCodeTransaction(IsPaymentMethodCodeTrans: Boolean)
    begin
        IsPaymentMethodCodeTransaction := IsPaymentMethodCodeTrans;
    end;

    [Obsolete('Replaced by new implementation in codeunit GST Journal Line Subscribers.', '19.0')]
    procedure GetPaymentMethodCodeTransaction(): Boolean
    begin
        exit(IsPaymentMethodCodeTransaction);
    end;

    [Obsolete('Replaced by new implementation in codeunit GST Journal Line Subscribers.', '19.0')]
    procedure SetCashPaymentGSTAmount(Amt: Decimal)
    begin
        CashPaymentGSTAmount += Amt;
    end;

    [Obsolete('Replaced by new implementation in codeunit GST Journal Line Subscribers.', '19.0')]
    procedure GetCashPaymentGSTAmount(): Decimal
    begin
        exit(CashPaymentGSTAmount);
    end;

    [Obsolete('Replaced by new implementation in codeunit GST Journal Line Subscribers.', '19.0')]
    procedure ClearSessionValues()
    begin
        CashPaymentGSTAmount := 0;
        IsPaymentMethodCodeTransaction := false;
    end;
#endif
}