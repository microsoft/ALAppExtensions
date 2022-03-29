page 6090 "FA Ledger Entries Issues"
{
    Caption = 'FA Ledger Entries with rounding issues';
    DataCaptionFields = "FA No.";
    Editable = false;
    PageType = List;
    SourceTable = "FA Ledg. Entry w. Issue";
    SourceTableView = where(Corrected = FILTER(false));
    Permissions = tabledata "FA Ledg. Entry w. Issue" = rimd,
                  tabledata "FA Ledger Entry" = rimd;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("FA Posting Date"; Rec."FA Posting Date")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the posting date of the related fixed asset transaction, such as a depreciation.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the entry document type.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the document number on the entry.';
                }
                field("FA No."; Rec."FA No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the number of the related fixed asset. ';
                }


                field(OriginalAmount; OriginalAmount)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the entry amount in currency.';
                    DecimalPlaces = 0 : 15;
                    Caption = 'Amount';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the entry amount in currency.';
                    Caption = 'Rounded Amount';
                }
                field(Rounding; Rounding)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the entry rounding';
                    DecimalPlaces = 0 : 15;
                    Caption = 'Rounding';

                }

                field("FA Posting Type"; Rec."FA Posting Type")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the posting type, if Account Type field contains Fixed Asset.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies a description of the entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("G/L Entry No."; Rec."G/L Entry No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the G/L number for the entry that was created in the general ledger for this fixed asset transaction.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

            action("&Prepare")
            {
                ApplicationArea = FixedAssets;
                Caption = '&Find Entries with Issues';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Find Entries with Issues';
                trigger OnAction()
                begin
                    Codeunit.run(Codeunit::"FA Ledger Entries Scan");
                end;
            }
            action("&Procces")
            {
                ApplicationArea = FixedAssets;
                Caption = '&Accept Selected';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Acctept correction for selected lines';

                trigger OnAction()
                var
                    FALedgerEntry: Record "FA Ledger Entry";
                    FALedgEntrywIssue: Record "FA Ledg. Entry w. Issue";
                    Currency: Record Currency;
                begin
                    CLEAR(Currency);
                    Currency.InitRoundingPrecision();
                    CurrPage.SetSelectionFilter(FALedgEntrywIssue);
                    if FALedgEntrywIssue.FindSet(true) then
                        repeat
                            FALedgerEntry.get(FALedgEntrywIssue."Entry No.");
                            FALedgerEntry.Amount := ROUND(FALedgerEntry.Amount, Currency."Amount Rounding Precision");
                            if ((FALedgerEntry.Amount > 0) and (not FALedgerEntry.Correction)) or
                               ((FALedgerEntry.Amount < 0) and FALedgerEntry.Correction)
                            then begin
                                FALedgerEntry."Debit Amount" := FALedgerEntry.Amount;
                                FALedgerEntry."Credit Amount" := 0
                            end else begin
                                FALedgerEntry."Debit Amount" := 0;
                                FALedgerEntry."Credit Amount" := -FALedgerEntry.Amount;
                            end;
                            FALedgerEntry.Modify();
                            FALedgEntrywIssue.Corrected := true;
                            FaLedgEntrywIssue.modify();
                        until FALedgEntrywIssue.next() = 0;
                    If Rec.FindFirst() then;
                    Message(EntryHaveBeenCorrectedMsg);
                end;
            }
        }
    }

    var
        OriginalAmount: Decimal;
        Rounding: Decimal;

    trigger OnAfterGetRecord()
    var
        Currency: Record Currency;
    begin
        CLEAR(Currency);
        Currency.InitRoundingPrecision();
        OriginalAmount := Rec.Amount;
        Rounding := ROUND(Rec.Amount, Currency."Amount Rounding Precision") - OriginalAmount;
    end;

    var
        EntryHaveBeenCorrectedMsg: Label 'Entries have been corrected.';
}

