namespace Microsoft.API.V2;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Integration.Graph;

page 30051 "APIV2 - Bank Accounts"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Bank Account';
    EntitySetCaption = 'Bank Accounts';
    DelayedInsert = true;
    EntityName = 'bankAccount';
    EntitySetName = 'bankAccounts';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Bank Account";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(bankAccountNumber; Rec."Bank Account No.")
                {
                    Caption = 'Bank Account Number';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'Currency Code';

                    trigger OnValidate()
                    var
                        Currency: Record "Currency";
                        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
                    begin
                        Rec."Currency Code" := GraphMgtGeneralTools.TranslateCurrencyCodeToNAVCurrencyCode(LCYCurrencyCode, CopyStr(CurrencyCodeTxt, 1, MaxStrLen(LCYCurrencyCode)));

                        if Rec."Currency Code" <> '' then
                            if not Currency.Get(Rec."Currency Code") then
                                Error(CurrencyCodeDoesNotMatchACurrencyErr);

                        if CurrencyCodeId <> '' then begin
                            if Currency.GetBySystemId(CurrencyCodeId) then
                                if Currency.Code <> Rec."Currency Code" then
                                    Error(CurrencyValuesDontMatchErr);
                            exit;
                        end;
                    end;
                }
                field(currencyId; CurrencyCodeId)
                {
                    Caption = 'Currency Id';

                    trigger OnValidate()
                    var
                        Currency: Record "Currency";
                    begin
                        if CurrencyCodeId <> '' then
                            if Currency.GetBySystemId(CurrencyCodeId) then
                                Rec."Currency Code" := Currency.Code
                            else
                                Error(CurrencyIdDoesNotMatchACurrencyErr);
                    end;
                }
                field(iban; Rec.IBAN)
                {
                    Caption = 'IBAN';
                }
                field(intercompanyEnabled; Rec.IntercompanyEnable)
                {
                    Caption = 'Intercompany Enabled';
                }
            }
        }
    }

    var
        CurrencyCodeTxt: Code[10];
        LCYCurrencyCode: Code[10];
        CurrencyCodeId: Guid;
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Comment = 'currencyId is a field name and should not be translated.';
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Comment = 'currencyCode is a field name and should not be translated.';
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.';

    trigger OnAfterGetRecord()
    begin
        LoadCurrencyInformation();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        LoadCurrencyInformation();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        LoadCurrencyInformation();
    end;

    local procedure LoadCurrencyInformation()
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        Rec.LoadFields("Currency Code");
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;
}