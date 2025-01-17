// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.NoSeries;

#pragma warning disable AW0006
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
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if DocumentNo <> InitDocumentNo then
                            NoSeries.TestManual(NoSeriesCode);
                    end;

                    trigger OnAssistEdit()
                    var
                        NoSeries: Codeunit "No. Series";
                    begin
                        if NoSeries.LookupRelatedNoSeries(InitNoSeriesCode, NoSeriesCode, NoSeriesCode) then begin
                            DocumentNo := NoSeriesBatch.GetNextNo(NoSeriesCode, PostingDate);
                            InitDocumentNo := DocumentNo;
                        end;
                    end;
                }
                field(PostingDate; PostingDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies posting date.';
                    ShowMandatory = true;
                    Editable = not IsSalesDocument;

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
                    Visible = not IsSalesDocument;
                    Enabled = not IsSalesDocument;
                }
                field(VATDate; VATDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Date';
                    ToolTip = 'Specifies VAT date.';
                    ShowMandatory = true;
                    Editable = not IsSalesDocument;
                }
                field(OriginalDocumentVATDate; OriginalDocumentVATDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Original Document VAT Date';
                    ToolTip = 'Specifies original document VAT date.';
                    Visible = not IsSalesDocument;
                    Enabled = not IsSalesDocument;
                    ShowMandatory = true;
                }
                field(ExternalDocumentNo; ExternalDocumentNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'External Document No.';
                    ToolTip = 'Specifies external document no.';
                    Visible = not IsSalesDocument;
                    Enabled = not IsSalesDocument;
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

    trigger OnOpenPage()
    begin
        if DocumentNo = '' then
            DocumentNo := NoSeriesBatch.GetNextNo(NoSeriesCode, PostingDate);
    end;

    var
        NoSeriesBatch: Codeunit "No. Series - Batch";
        NoSeries: Codeunit "No. Series";
        DocumentNo: Code[20];
        InitDocumentNo: Code[20];
        ExternalDocumentNo: Code[35];
        NoSeriesCode: Code[20];
        InitNoSeriesCode: Code[20];
        CurrencyCode: Code[10];
        PostingDate: Date;
        DocumentDate: Date;
        VATDate: Date;
        OriginalDocumentVATDate: Date;
        CurrencyFactor: Decimal;
        DocumentNoEditable: Boolean;
        IsSalesDocument: Boolean;

    procedure InitDocument(NewNoSeriesCode: Code[20]; NewDocumentNo: Code[20]; NewDocumentDate: Date; NewPostingDate: Date; NewVATDate: Date; NewOriginalDocumentVATDate: Date; NewCurrencyCode: Code[10]; NewCurrencyFactor: Decimal; NewExternalDocumentNo: Code[35]; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        NoSeriesCode := NewNoSeriesCode;
        InitNoSeriesCode := NewNoSeriesCode;
        PostingDate := NewPostingDate;
        DocumentDate := NewDocumentDate;
        ExternalDocumentNo := NewExternalDocumentNo;
        CurrencyCode := NewCurrencyCode;
        CurrencyFactor := NewCurrencyFactor;
        VATDate := NewVATDate;
        if VATDate = 0D then
            VATDate := GeneralLedgerSetup.GetVATDate(PostingDate, DocumentDate);
        OriginalDocumentVATDate := NewOriginalDocumentVATDate;
        if OriginalDocumentVATDate = 0D then
            OriginalDocumentVATDate :=
                GeneralLedgerSetup.GetOriginalDocumentVATDateCZL(PostingDate, VATDate, DocumentDate);
        CurrPage.Lines.Page.InitDocumentLines(NewCurrencyCode, NewCurrencyFactor, AdvancePostingBufferCZZ);

        DocumentNo := NewDocumentNo;
        DocumentNoEditable := NewDocumentNo = '';
        InitDocumentNo := DocumentNo;
    end;

    procedure InitSalesDocument(NewNoSeriesCode: Code[20]; NewDocumentNo: Code[20]; NewDocumentDate: Date; NewPostingDate: Date; NewVATDate: Date; NewOriginalDocumentVATDate: Date; NewCurrencyCode: Code[10]; NewCurrencyFactor: Decimal; NewExternalDocumentNo: Code[35]; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    begin
        IsSalesDocument := true;
        InitDocument(NewNoSeriesCode, NewDocumentNo, NewDocumentDate, NewPostingDate, NewVATDate, NewOriginalDocumentVATDate, NewCurrencyCode, NewCurrencyFactor, NewExternalDocumentNo, AdvancePostingBufferCZZ);
    end;

    procedure GetDocument(var NewDocumentNo: Code[20]; var NewPostingDate: Date; var NewDocumentDate: Date; var NewVATDate: Date; var NewOriginalDocumentVATDate: Date; var NewExternalDocumentNo: Code[35]; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    begin
        NewDocumentNo := DocumentNo;
        NewPostingDate := PostingDate;
        NewDocumentDate := DocumentDate;
        NewVATDate := VATDate;
        NewOriginalDocumentVATDate := OriginalDocumentVATDate;
        NewExternalDocumentNo := ExternalDocumentNo;
        CurrPage.Lines.Page.GetDocumentLines(AdvancePostingBufferCZZ);
    end;

    procedure GetDocument(var NewDocumentNo: Code[20]; var NewPostingDate: Date; var NewVATDate: Date; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    begin
        NewDocumentNo := DocumentNo;
        NewPostingDate := PostingDate;
        NewVATDate := VATDate;
        CurrPage.Lines.Page.GetDocumentLines(AdvancePostingBufferCZZ);
    end;

    procedure SaveNoSeries()
    begin
        NoSeriesBatch.SaveState();
    end;

    local procedure UpdateCurrencyFactor(NewCurrencyFactor: Decimal)
    begin
        CurrencyFactor := NewCurrencyFactor;
        CurrPage.Lines.Page.UpdateCurrencyFactor(CurrencyFactor);
    end;
}
