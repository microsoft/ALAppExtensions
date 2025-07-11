namespace Microsoft.API.V2;

using Microsoft.Finance.Currency;

page 30085 "APIV2- Currency Exchange Rates"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Currency Exchange Rate';
    EntitySetCaption = 'Currency Exchange Rates';
    EntityName = 'currencyExchangeRate';
    EntitySetName = 'currencyExchangeRates';
    PageType = API;
    SourceTable = "Currency Exchange Rate";
    Extensible = false;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field(exchangeRateAmount; Rec."Exchange Rate Amount")
                {
                    Caption = 'Exchange Rate Amount';
                }
                field(relationalCurrencyCode; Rec."Relational Currency Code")
                {
                    Caption = 'Relational Currency Code';
                }
                field(relationalExchangeRateAmount; Rec."Relational Exch. Rate Amount")
                {
                    Caption = 'Relational Exchange Rate Amount';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
            }
        }
    }

}