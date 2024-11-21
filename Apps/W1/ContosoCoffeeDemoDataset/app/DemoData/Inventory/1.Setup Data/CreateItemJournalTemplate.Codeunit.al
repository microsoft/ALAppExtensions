codeunit 5423 "Create Item Journal Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SourceCodeSetup: Record "Source Code Setup";
        ContosoItem: Codeunit "Contoso Item";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        SourceCodeSetup.Get();

        ContosoItem.InsertItemJournalTemplate(ItemJournalTemplate(), ItemJournalLbl, Enum::"Item Journal Template Type"::Item, false, SourceCodeSetup."Item Journal", Report::"Inventory Posting - Test", Page::"Item Journal", Report::"Item Register - Quantity", CreateNoSeries.ItemJournal(), Report::"Warehouse Register - Quantity");
    end;

    procedure ItemJournalTemplate(): Code[10]
    begin
        exit(ItemTok);
    end;

    var
        ItemTok: Label 'ITEM', MaxLength = 10;
        ItemJournalLbl: Label 'Item Journal', MaxLength = 80;
}