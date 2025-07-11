// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Currency;

page 31177 "Adv. Payment Close Dialog CZZ"
{
    PageType = StandardDialog;
    Caption = 'Advance Payment Close Dialog';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(PostingDate; PostingDate)
                {
                    Caption = 'Posting Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies posting date.';

                    trigger OnValidate()
                    begin
                        if CurrencyCode <> '' then
                            CurrencyFactor := CurrencyExchangeRate.ExchangeRate(PostingDate, CurrencyCode);
                    end;
                }
                field(VATDate; VATDate)
                {
                    Caption = 'VAT Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT date.';
                }
                field(OriginalDocumentVATDate; OriginalDocumentVATDate)
                {
                    Caption = 'Original Document VAT Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies original document VAT date.';
                    Visible = ShowOriginalDocumentVATDate;
                }
                field(CurrencyCode; CurrencyCode)
                {
                    Caption = 'Currency Code';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies currency code.';
                    TableRelation = Currency;
                    Editable = false;
                    Enabled = CurrencyEnabled;

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: page "Change Exchange Rate";
                    begin
                        if PostingDate <> 0D then
                            ChangeExchangeRate.SetParameter(CurrencyCode, CurrencyFactor, PostingDate)
                        else
                            ChangeExchangeRate.SetParameter(CurrencyCode, CurrencyFactor, WorkDate());
                        if ChangeExchangeRate.RunModal() = Action::OK then
                            CurrencyFactor := ChangeExchangeRate.GetParameter();
                    end;
                }
                field(AdditionalCurrencyCodeCZL; GeneralLedgerSetup.GetAdditionalCurrencyCodeCZL())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Additional Currency Code';
                    ToolTip = 'Specifies the exchange rate to be used if you post in an additional currency.';
                    Visible = AddCurrencyEnabled;
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: page "Change Exchange Rate";
                    begin
                        if PostingDate <> 0D then
                            ChangeExchangeRate.SetParameter(GeneralLedgerSetup.GetAdditionalCurrencyCodeCZL(), AddCurrencyFactor, PostingDate)
                        else
                            ChangeExchangeRate.SetParameter(GeneralLedgerSetup.GetAdditionalCurrencyCodeCZL(), AddCurrencyFactor, WorkDate());
                        if ChangeExchangeRate.RunModal() = Action::OK then
                            AddCurrencyFactor := ChangeExchangeRate.GetParameter();
                    end;
                }
                field(ExternalDocumentNo; ExternalDocumentNo)
                {
                    Caption = 'External Document No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies external document no.';
                    Visible = ShowExternalDocumentNo;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        AddCurrencyEnabled := GeneralLedgerSetup.IsAdditionalCurrencyEnabledCZL();
    end;

    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PostingDate: Date;
        VATDate: Date;
        OriginalDocumentVATDate: Date;
        CurrencyCode: Code[10];
        ExternalDocumentNo: Code[35];
        CurrencyFactor: Decimal;
        AddCurrencyFactor: Decimal;
        CurrencyEnabled: Boolean;
        AddCurrencyEnabled: Boolean;
        ShowExternalDocumentNo: Boolean;
        ShowOriginalDocumentVATDate: Boolean;

    procedure SetValues(NewPostingDate: Date; NewVATDate: Date; NewCurrencyCode: Code[10]; NewCurrencyFactor: Decimal; NewExternalDocumentNo: Code[35]; NewShowExternalDocumentNo: Boolean)
    begin
        SetValues(NewPostingDate, NewVATDate, NewCurrencyCode, NewCurrencyFactor, 0, NewExternalDocumentNo, NewShowExternalDocumentNo);
    end;

    procedure SetValues(NewPostingDate: Date; NewVATDate: Date; NewCurrencyCode: Code[10]; NewCurrencyFactor: Decimal; NewAddCurrencyFactor: Decimal; NewExternalDocumentNo: Code[35]; NewShowExternalDocumentNo: Boolean)
    begin
        PostingDate := NewPostingDate;
        VATDate := NewVATDate;
        OriginalDocumentVATDate := VATDate;
        CurrencyCode := NewCurrencyCode;
        ExternalDocumentNo := NewExternalDocumentNo;
        CurrencyEnabled := CurrencyCode <> '';
        CurrencyFactor := NewCurrencyFactor;
        if CurrencyFactor = 0 then
            CurrencyFactor := CurrencyExchangeRate.ExchangeRate(PostingDate, CurrencyCode);
        AddCurrencyFactor := NewAddCurrencyFactor;
        if AddCurrencyFactor = 0 then
            AddCurrencyFactor := GeneralLedgerSetup.GetAdditionalCurrencyFactorCZL(PostingDate);
        ShowExternalDocumentNo := NewShowExternalDocumentNo;
        ShowOriginalDocumentVATDate := ShowExternalDocumentNo;
    end;

    procedure GetValues(var NewPostingDate: Date; var NewVATDate: Date; var NewCurrencyFactor: Decimal)
    begin
        NewPostingDate := PostingDate;
        NewVATDate := VATDate;
        NewCurrencyFactor := CurrencyFactor;
    end;

    procedure GetValues(var NewPostingDate: Date; var NewVATDate: Date; var NewCurrencyFactor: Decimal; var NewAddCurrencyFactor: Decimal)
    begin
        GetValues(NewPostingDate, NewVATDate, NewCurrencyFactor);
        NewAddCurrencyFactor := AddCurrencyFactor;
    end;

    procedure GetValues(var NewPostingDate: Date; var NewVATDate: Date; var NewOriginalDocumentVATDate: Date; var NewCurrencyFactor: Decimal)
    begin
        GetValues(NewPostingDate, NewVATDate, NewCurrencyFactor);
        NewOriginalDocumentVATDate := OriginalDocumentVATDate;
    end;

    procedure GetValues(var NewPostingDate: Date; var NewVATDate: Date; var NewOriginalDocumentVATDate: Date; var NewCurrencyFactor: Decimal; var NewAddCurrencyFactor: Decimal)
    begin
        GetValues(NewPostingDate, NewVATDate, NewOriginalDocumentVATDate, NewCurrencyFactor);
        NewAddCurrencyFactor := AddCurrencyFactor;
    end;

    procedure GetExternalDocumentNo(): Code[35]
    begin
        exit(ExternalDocumentNo);
    end;
}
