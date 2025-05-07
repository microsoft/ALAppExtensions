namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;

page 8088 "Exchange Rate Selection"
{

    Caption = 'Exchange Rate Selection';
    PageType = StandardDialog;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            group(OptionFields)
            {
                Caption = 'Options';
                field(KeyDate; KeyDate)
                {
                    Caption = 'Key Date';
                    ToolTip = 'Specifies the date on the basis of which the exchange rate is determined.';

                    trigger OnValidate()
                    begin
                        if CurrencyCode <> '' then
                            ExchangeRate := CurrExchRate.ExchangeRate(KeyDate, CurrencyCode);
                    end;
                }
                field(ExchangeRate; ExchangeRate)
                {
                    Caption = 'Exchange Rate';
                    ToolTip = 'Specifies the exchange rate that will be used for the conversion.';
                    DecimalPlaces = 0 : 7;
                    Editable = not IsCalledFromServiceObject;
                }
            }
        }
    }
    var
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyCode: Code[10];
        KeyDate: Date;
        ExchangeRate: Decimal;
        MessageTxt: Text;
        IsCalledFromServiceObject: Boolean;

    trigger OnOpenPage()
    begin
        if MessageTxt <> '' then
            Message(MessageTxt);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CurrencyCodeChangePriceMustBeUpdatedErr: Label 'The Currency Code has been changed. The price and Amount need to be converted using a currency factor.';
    begin
        if CloseAction in [Action::LookupCancel, Action::Cancel] then
            if not IsCalledFromServiceObject then
                Error(CurrencyCodeChangePriceMustBeUpdatedErr);
    end;

    internal procedure SetIsCalledFromServiceObject(CalledFromServiceObject: Boolean)
    begin
        IsCalledFromServiceObject := CalledFromServiceObject;
    end;

    internal procedure SetData(NewKeyDate: Date; NewCurrencyCode: Code[10]; NewMessage: Text)
    begin
        KeyDate := NewKeyDate;
        CurrencyCode := NewCurrencyCode;
        if CurrencyCode <> '' then
            ExchangeRate := CurrExchRate.ExchangeRate(KeyDate, CurrencyCode);

        MessageTxt := NewMessage;
    end;

    internal procedure GetData(var NewKeyDate: Date; var NewExchangeRate: Decimal)
    begin
        NewKeyDate := KeyDate;
        NewExchangeRate := ExchangeRate;
    end;
}
