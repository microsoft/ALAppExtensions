namespace Microsoft.DataMigration.GP.HistoricalData;

page 41001 "Hist. Gen. Journal Lines"
{
    ApplicationArea = All;
    Caption = 'Historical Gen. Journal Lines';
    PageType = List;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Gen. Journal Line";
    UsageCategory = History;
    MultipleNewLines = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                Editable = false;
                ShowCaption = false;

                field("Journal Entry No."; Rec."Journal Entry No.")
                {
                    ToolTip = 'Specifies the value of the Journal Entry No. field.';
                }
                field(Year; Rec.Year)
                {
                    ToolTip = 'Specifies the value of the Year field.';
                }
                field(Closed; Rec.Closed)
                {
                    ToolTip = 'Specifies the value of the Closed field.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the value of the Account No. field.';
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.';
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ToolTip = 'Specifies the value of the Debit Amount field.';
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ToolTip = 'Specifies the value of the Credit Amount field.';
                }
                field("Orig. Document No."; Rec."Orig. Document No.")
                {
                    ToolTip = 'Specifies the value of the Originating Document No. field.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the value of the Source No. field.';
                }
                field("Source Name"; Rec."Source Name")
                {
                    ToolTip = 'Specifies the value of the Source Name field.';
                }
                field("Reference Desc."; Rec."Reference Desc.")
                {
                    ToolTip = 'Specifies the value of the Refererence Desc. field.';
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Orig. Debit Amount"; Rec."Orig. Debit Amount")
                {
                    ToolTip = 'Specifies the value of the Originating Debit Amount field.';
                }
                field("Orig. Credit Amount"; Rec."Orig. Credit Amount")
                {
                    ToolTip = 'Specifies the value of the Originating Credit Amount field.';
                }
                field("Orig. Trx. Source No."; Rec."Orig. Trx. Source No.")
                {
                    ToolTip = 'Specifies the value of the Orig. Trx. Source No. field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sequence No. field.';
                }
                field(Custom1; Rec.Custom1)
                {
                    ToolTip = 'Specifies the value of the Custom 1 field.';
                }
                field(Custom2; Rec.Custom2)
                {
                    ToolTip = 'Specifies the value of the Custom 2 field.';
                }
                field(User; Rec.User)
                {
                    ToolTip = 'Specifies the value of the User field.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ViewDetails)
            {
                ApplicationArea = All;
                Caption = 'View Details';
                ToolTip = 'View more details about this transaction.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Find;
                ShortcutKey = Return;

                trigger OnAction()
                var
                    HistPageNavigationHandler: Codeunit "Hist. Page Navigation Handler";
                begin
                    HistPageNavigationHandler.NavigateToTransactionDetail(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if FilterAccountNo <> '' then
            Rec.SetRange("Account No.", FilterAccountNo);

        if FilterOriginatingTrxSourceNo <> '' then
            Rec.SetRange("Orig. Trx. Source No.", FilterOriginatingTrxSourceNo);
    end;

    procedure SetFilterAccountNo(AccountNo: Code[130])
    begin
        FilterAccountNo := AccountNo;
    end;

    procedure SetFilterOriginatingTrxSourceNo(OriginatingTrxSourceNo: Code[35])
    begin
        FilterOriginatingTrxSourceNo := OriginatingTrxSourceNo;
    end;

    var
        FilterAccountNo: Code[130];
        FilterOriginatingTrxSourceNo: Code[35];
}