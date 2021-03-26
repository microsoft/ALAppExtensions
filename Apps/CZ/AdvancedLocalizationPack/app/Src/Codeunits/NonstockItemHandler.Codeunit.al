codeunit 31260 "Nonstock Item Handler CZA"
{
    var
        NonstockItemSetup: Record "Nonstock Item Setup";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Catalog Item Management", 'OnBeforeGetNewItemNo', '', false, false)]
    local procedure ItemNoFromItemSeriesOnBeforeGetNewItemNo(var NewItemNo: Code[20]; var IsHandled: Boolean)
    var
        NewItem: Record Item;
        AssistEditErr: Label 'Item No. Serie was not selected.';
    begin
        NonstockItemSetup.Get();
        if NonstockItemSetup."No. Format" <> NonstockItemSetup."No. Format"::"Item No. Series CZA" then
            exit;

        NewItem.Init();
        if not NewItem.AssistEdit() then
            Error(AssistEditErr);
        NewItemNo := NewItem."No.";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Nonstock Item", 'OnModifyOnBeforeError', '', false, false)]
    local procedure CheckItemOnModifyOnBeforeError(var IsHandled: Boolean)
    begin
        NonstockItemSetup.Get();
        if NonstockItemSetup."No. Format" = NonstockItemSetup."No. Format"::"Item No. Series CZA" then
            IsHandled := true;
    end;
}
