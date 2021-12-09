codeunit 31404 "Cash Flow Handler CZZ"
{
    var
        SourceDataDoesNotExistErr: Label 'Source data does not exist for %1: %2.', Comment = '%1 = caption of table, %2 = code of record, example: Source data doesn''t exist for G/L Account: 8210.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Management", 'OnShowSourceLocalSourceTypeCase', '', false, false)]
    local procedure ShowAdvanceLettersOnShowSourceLocalSourceTypeCase(SourceType: Enum "Cash Flow Source Type"; SourceNo: Code[20]; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        IsHandled := true;
        case SourceType of
            Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ":
                ShowSalesAdvanceLetters(SourceNo);
            Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ":
                ShowPurchAdvanceLetters(SourceNo);
            else
                IsHandled := false;
        end
    end;

    local procedure ShowSalesAdvanceLetters(SourceNo: Code[20])
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvanceLetterCZZ: Page "Sales Advance Letter CZZ";
    begin
        SalesAdvLetterHeaderCZZ.SetRange("No.", SourceNo);
        if not SalesAdvLetterHeaderCZZ.FindFirst() then
            Error(SourceDataDoesNotExistErr, SalesAdvanceLetterCZZ.Caption, SourceNo);
        SalesAdvanceLetterCZZ.SetTableView(SalesAdvLetterHeaderCZZ);
        SalesAdvanceLetterCZZ.Run();
    end;

    local procedure ShowPurchAdvanceLetters(SourceNo: Code[20])
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvanceLetterCZZ: Page "Purch. Advance Letter CZZ";
    begin
        PurchAdvLetterHeaderCZZ.SetRange("No.", SourceNo);
        if not PurchAdvLetterHeaderCZZ.FindFirst() then
            Error(SourceDataDoesNotExistErr, PurchAdvanceLetterCZZ.Caption, SourceNo);
        PurchAdvanceLetterCZZ.SetTableView(PurchAdvLetterHeaderCZZ);
        PurchAdvanceLetterCZZ.Run();
    end;
}