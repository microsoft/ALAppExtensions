namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.Purchases.Document;
using Microsoft.Finance.Currency;
using Microsoft.eServices.EDocument;

page 6171 "E-Doc. Create Purch Order Line"
{
    PageType = Card;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Purchase Line";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            field(Type; Rec.Type)
            {
                Caption = 'Type';
                ToolTip = 'Specifies the line type.';

                trigger OnValidate()
                begin
                    SetEDocumentMatchingValues();
                    CheckAndShowCannotSaveMatchNotification();
                end;
            }
            field("No."; Rec."No.")
            {
                Caption = 'No.';
                ToolTip = 'Specifies what you received, such as a product or a general ledger account.';

                trigger OnValidate()
                begin
                    SetEDocumentMatchingValues();
                end;
            }
            field(Description; Rec.Description)
            {
                Caption = 'Description';
                ToolTip = 'Specifies the description of what was received.';
            }
            field("Unit Of Measure Code"; Rec."Unit Of Measure Code")
            {
                Caption = 'Unit Of Measure Code';
                ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours.';
                Editable = false;
            }
            field(Quantity; Rec.Quantity)
            {
                Caption = 'Quantity';
                ToolTip = 'Specifies the quantity that was received.';
                MinValue = 0;

                trigger OnValidate()
                begin
                    if Rec.Quantity = 0 then
                        Error(QuantityZeroErr);
                    Rec."Direct Unit Cost" := TempEDocImportedLine."Direct Unit Cost" * TempEDocImportedLine.Quantity * (1 - TempEDocImportedLine."Line Discount %" / 100) / (Rec.Quantity * (1 - Rec."Line Discount %" / 100));
                    Message(UnitCostRecalculatedMsg);
                end;
            }
            field("Unit Price"; Rec."Direct Unit Cost")
            {
                Caption = 'Unit Price';
                ToolTip = 'Specifies the price of one unit of what you received.';
                Editable = false;
            }
            field("Discount %"; Rec."Line Discount %")
            {
                Caption = 'Discount %';
                ToolTip = 'Specifies the discount percentage that is granted for the line.';
                Editable = false;
            }
            field(TotalAmount; TotalAmount)
            {
                Caption = 'Total Amount';
                ToolTip = 'Specifies the total amount of the line.';
                StyleExpr = StyleTxt;
                Editable = false;
            }
            field(IncomingEDocumentLineTotalAmount; IncomingEDocumentLineTotalAmount)
            {
                Caption = 'Incoming E-Document Line Total Amount';
                ToolTip = 'Specifies the total amount of the incoming e-document line.';
                StyleExpr = StyleTxt;
                Editable = false;
            }
            field("Learn matching rule"; SaveMatch)
            {
                Caption = 'Learn matching rule';
                Tooltip = 'Specifies whether a matching rule should be created. Item references are created for Items and Text To Account mappings are created for G/L Accounts.';

                trigger OnValidate()
                begin
                    CheckAndShowCannotSaveMatchNotification();
                end;
            }
        }
    }

    protected var
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempEDocImportedLine: Record "E-Doc. Imported Line" temporary;
        SaveMatch: Boolean;
        CannotSaveMatchNotificationSent: Boolean;
        TotalAmount: Decimal;
        IncomingEDocumentLineTotalAmount: Decimal;
        StyleTxt: Text;
        UnitCostRecalculatedMsg: Label 'The unit cost has been recalculated in order to maintain the total unit price from the incoming line.';
        QuantityZeroErr: Label 'The Quantity must be greater than 0.';
        CannotSaveMatchNotificationMsg: Label 'Matching rules can only be created for lines of type Item and G/L Account.';
        SelectPurchaseLineTypeErr: Label 'You must select a line type.';

    trigger OnOpenPage()
    begin
        Rec.Copy(TempPurchaseLine, true);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        EDocument: Record "E-Document";
        EDocLineMatching: Codeunit "E-Doc. Line Matching";
    begin
        if CloseAction <> CloseAction::LookupOK then
            exit(true);

        if Rec.Type = Enum::"Purchase Line Type"::" " then
            Error(SelectPurchaseLineTypeErr);
        Rec.TestField("No.");

        if SaveMatch then begin
            EDocument.Get(TempEDocImportedLine."E-Document Entry No.");
            EDocLineMatching.CreateMatchingRule(Rec, EDocument, TempEDocImportedLine);
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetEDocumentMatchingValues();
    end;

    procedure SetEDocumentMatchingValues()
    var
        Currency: Record Currency;
    begin
        Rec."Unit of Measure Code" := CopyStr(TempEDocImportedLine."Unit of Measure Code", 1, MaxStrLen(Rec."Unit of Measure Code"));
        Rec.Quantity := TempEDocImportedLine.Quantity;
        Rec."Direct Unit Cost" := TempEDocImportedLine."Direct Unit Cost";
        Rec."Line Discount %" := TempEDocImportedLine."Line Discount %";

        Currency.Initialize(Rec."Currency Code");
        TotalAmount := Round(Rec."Direct Unit Cost" * Rec.Quantity * (1 - Rec."Line Discount %" / 100), Currency."Amount Rounding Precision");
        IncomingEDocumentLineTotalAmount := TempEDocImportedLine."Direct Unit Cost" * TempEDocImportedLine.Quantity * (1 - TempEDocImportedLine."Line Discount %" / 100);
    end;

    local procedure CheckAndShowCannotSaveMatchNotification()
    var
        CannotSaveMatchNotification: Notification;
    begin
        if CannotSaveMatchNotificationSent then
            exit;

        if not SaveMatch then
            exit;

        if Rec.Type in [Enum::"Purchase Line Type"::" ", Enum::"Purchase Line Type"::"G/L Account", Enum::"Purchase Line Type"::Item] then
            exit;

        CannotSaveMatchNotification.Message := CannotSaveMatchNotificationMsg;
        CannotSaveMatchNotification.Send();

        CannotSaveMatchNotificationSent := true;
    end;

    internal procedure SetSharedTable(var TempPurchaseLineToSet: Record "Purchase Line" temporary)
    begin
        this.TempPurchaseLine.Copy(TempPurchaseLineToSet, true);
    end;

    internal procedure SetEDocImportedLine(TempEDocImportedLineToSet: Record "E-Doc. Imported Line" temporary)
    begin
        this.TempEDocImportedLine := TempEDocImportedLineToSet;
    end;
}
