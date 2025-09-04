namespace Microsoft.Bank.StatementImport;

using System.Reflection;

page 8851 "Bank Statement Import Preview"
{
    PageType = List;
    SourceTable = "Bank Statement Import Preview";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group1)
            {
                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                    Caption = 'Date';
                    ToolTip = 'Specifies the transaction date.';
                    Style = Unfavorable;
                    StyleExpr = not IsValidDate;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Amount';
                    ToolTip = 'Specifies the transaction amount.';
                    Style = Unfavorable;
                    StyleExpr = not IsValidAmount;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        TypeHelper: Codeunit "Type Helper";
        AmountVariant: Variant;
        DateVariant: Variant;
    begin
        AmountVariant := 0.00;
        if Rec.Amount.Contains('''') then   // remove thousands separator as it prevents decimal from being evaluated by default
            Rec.Amount := DelChr(Rec.Amount, '=', '''');
        if TypeHelper.Evaluate(AmountVariant, Rec.Amount, '', Rec."Amount Format") then begin
            IsValidAmount := true;
            Rec.Amount := Format(AmountVariant);
        end else
            IsValidAmount := false;

        DateVariant := 0D;
        if TypeHelper.Evaluate(DateVariant, Rec.Date, Rec."Date Format", Rec."Amount Format") then begin
            IsValidDate := true;
            Rec.Date := Format(DateVariant);
        end else
            IsValidDate := false;

        Rec.Modify();
    end;

    var
        IsValidDate: Boolean;
        IsValidAmount: Boolean;
}