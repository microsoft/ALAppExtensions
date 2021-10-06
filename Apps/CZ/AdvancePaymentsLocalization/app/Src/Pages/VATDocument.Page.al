# pragma warning disable AW0006
page 31185 "VAT Document CZZ"
{
    PageType = StandardDialog;
    Caption = 'VAT Document';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(DocumentNo; DocumentNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies document no.';
                    Editable = DocumentNoEditable;

                    trigger OnValidate()
                    begin
                        if DocumentNo <> InitDocumentNo then
                            NoSeriesManagement.TestManual(NoSeriesCode);
                    end;

                    trigger OnAssistEdit()
                    var
                        NoSeriesManagement2: Codeunit NoSeriesManagement;
                    begin
                        if NoSeriesManagement2.SelectSeries(InitNoSeriesCode, NoSeriesCode, NoSeriesCode) then begin
                            Clear(NoSeriesManagement);

                            DocumentNo := NoSeriesManagement.GetNextNo(NoSeriesCode, PostingDate, false);
                            InitDocumentNo := DocumentNo;
                        end;
                    end;
                }
                field(PostingDate; PostingDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies posting date.';

                    trigger OnValidate()
                    var
                        CurrencyExchangeRate: Record "Currency Exchange Rate";
                        CurrFactor: Decimal;
                        CurrencyDate: Date;
                    begin
                        if CurrencyCode <> '' then begin
                            if PostingDate <> 0D then
                                CurrencyDate := PostingDate
                            else
                                CurrencyDate := WorkDate();

                            CurrFactor := CurrencyExchangeRate.ExchangeRate(CurrencyDate, CurrencyCode);
                            UpdateCurrencyFactor(CurrFactor);
                        end;
                    end;
                }
                field(DocumentDate; DocumentDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document Date';
                    ToolTip = 'Specifies document date.';
                }
                field(VATDate; VATDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Date';
                    ToolTip = 'Specifies VAT date.';
                }
                field(ExternalDocumentNo; ExternalDocumentNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'External Document No.';
                    ToolTip = 'Specifies external document no.';
                }
                field(CurrencyCode; CurrencyCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies currency code.';
                    Visible = CurrencyCode <> '';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        if PostingDate <> 0D then
                            ChangeExchangeRate.SetParameter(CurrencyCode, CurrencyFactor, PostingDate)
                        else
                            ChangeExchangeRate.SetParameter(CurrencyCode, CurrencyFactor, WorkDate());
                        if ChangeExchangeRate.RunModal() = Action::OK then
                            UpdateCurrencyFactor(ChangeExchangeRate.GetParameter());
                    end;
                }
            }
            part(Lines; "VAT Document Line CZZ")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DocumentNo: Code[20];
        InitDocumentNo: Code[20];
        ExternalDocumentNo: Code[35];
        NoSeriesCode: Code[20];
        InitNoSeriesCode: Code[20];
        CurrencyCode: Code[10];
        PostingDate: Date;
        DocumentDate: Date;
        VATDate: Date;
        CurrencyFactor: Decimal;
        DocumentNoEditable: Boolean;

#pragma warning disable AL0432
    procedure InitDocument(NewNoSeriesCode: Code[20]; NewDocumentNo: Code[20]; NewPostingDate: Date; NewVATDate: Date; NewCurrencyCode: Code[10]; NewCurrencyFactor: Decimal; NewExternalDocumentNo: Code[35]; var InvoicePostBuffer: Record "Invoice Post. Buffer")
#pragma warning restore AL0432
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        NoSeriesCode := NewNoSeriesCode;
        InitNoSeriesCode := NewNoSeriesCode;
        PostingDate := NewPostingDate;
        DocumentDate := NewPostingDate;
        ExternalDocumentNo := NewExternalDocumentNo;
        CurrencyCode := NewCurrencyCode;
        CurrencyFactor := NewCurrencyFactor;
        VATDate := NewVATDate;
        if VATDate = 0D then
            case PurchasesPayablesSetup."Default VAT Date CZL" of
                PurchasesPayablesSetup."Default VAT Date CZL"::"Posting Date":
                    VATDate := PostingDate;
                PurchasesPayablesSetup."Default VAT Date CZL"::"Document Date":
                    VATDate := DocumentDate;
                PurchasesPayablesSetup."Default VAT Date CZL"::Blank:
                    VATDate := 0D;
            end;
        CurrPage.Lines.Page.InitDocumentLines(NewCurrencyCode, NewCurrencyFactor, InvoicePostBuffer);

        if NewDocumentNo <> '' then begin
            DocumentNo := NewDocumentNo;
            DocumentNoEditable := false;
        end else begin
            DocumentNo := NoSeriesManagement.GetNextNo(NoSeriesCode, PostingDate, false);
            DocumentNoEditable := true;
        end;
        InitDocumentNo := DocumentNo;
    end;

#pragma warning disable AL0432
    procedure GetDocument(var NewDocumentNo: Code[20]; var NewPostingDate: Date; var NewDocumentDate: Date; var NewVATDate: Date; var NewExternalDocumentNo: Code[35]; var InvoicePostBuffer: Record "Invoice Post. Buffer")
#pragma warning restore AL0432
    begin
        NewDocumentNo := DocumentNo;
        NewPostingDate := PostingDate;
        NewDocumentDate := DocumentDate;
        NewVATDate := VATDate;
        NewExternalDocumentNo := ExternalDocumentNo;
        CurrPage.Lines.Page.GetDocumentLines(InvoicePostBuffer);
    end;

    procedure SaveNoSeries()
    begin
        NoSeriesManagement.SaveNoSeries();
    end;

    local procedure UpdateCurrencyFactor(NewCurrencyFactor: Decimal)
    begin
        CurrencyFactor := NewCurrencyFactor;
        CurrPage.Lines.Page.UpdateCurrencyFactor(CurrencyFactor);
    end;
}