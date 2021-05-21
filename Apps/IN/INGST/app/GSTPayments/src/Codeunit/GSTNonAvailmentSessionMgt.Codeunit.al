codeunit 18252 "GST Non Availment Session Mgt"
{
    SingleInstance = true;

    var
        QtyToBeInvoiced: Decimal;
        GSTAmountToBeLoaded: Decimal;
        CustomDutyAmount: Decimal;

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
}
