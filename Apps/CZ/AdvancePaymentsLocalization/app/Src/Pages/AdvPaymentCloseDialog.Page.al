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

    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        PostingDate: Date;
        VATDate: Date;
        CurrencyCode: Code[10];
        ExternalDocumentNo: Code[35];
        CurrencyFactor: Decimal;
        CurrencyEnabled: Boolean;
        ShowExternalDocumentNo: Boolean;

    procedure SetValues(NewPostingDate: Date; NewVATDate: Date; NewCurrencyCode: Code[10]; NewCurrencyFactor: Decimal; NewExternalDocumentNo: Code[35]; NewShowExternalDocumentNo: Boolean)
    begin
        PostingDate := NewPostingDate;
        VATDate := NewVATDate;
        CurrencyCode := NewCurrencyCode;
        ExternalDocumentNo := NewExternalDocumentNo;
        CurrencyEnabled := CurrencyCode <> '';
        if NewCurrencyFactor <> 0 then
            CurrencyFactor := NewCurrencyFactor
        else
            CurrencyFactor := CurrencyExchangeRate.ExchangeRate(PostingDate, CurrencyCode);
        ShowExternalDocumentNo := NewShowExternalDocumentNo;
    end;

    procedure GetValues(var NewPostingDate: Date; var NewVATDate: Date; var NewCurrencyFactor: Decimal)
    begin
        NewPostingDate := PostingDate;
        NewVATDate := VATDate;
        NewCurrencyFactor := CurrencyFactor;
    end;

    procedure GetExternalDocumentNo(): Code[35]
    begin
        exit(ExternalDocumentNo);
    end;
}