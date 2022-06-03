tableextension 11745 "Item CZL" extends Item
{
    fields
    {
        field(31066; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZL".Code where("Tariff No." = field("Tariff No."));
            DataClassification = CustomerContent;
        }
        field(31067; "Specific Movement CZL"; Code[10])
        {
            Caption = 'Specific Movement';
            TableRelation = "Specific Movement CZL".Code;
            DataClassification = CustomerContent;
        }
    }

    procedure CheckOpenItemLedgerEntriesCZL()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ChangeErr: Label ' cannot be changed';
    begin
        if "No." = '' then
            exit;
	
        ItemLedgerEntry.SetCurrentKey("Item No.", Open);
        ItemLedgerEntry.SetRange("Item No.", "No.");
        ItemLedgerEntry.SetRange(Open, true);
        if not ItemLedgerEntry.IsEmpty() then
            FieldError("Inventory Posting Group", ChangeErr);

        ItemLedgerEntry.SetRange(Open);
        ItemLedgerEntry.SetRange("Completely Invoiced", false);
        if not ItemLedgerEntry.IsEmpty() then
            FieldError("Inventory Posting Group", ChangeErr);
    end;
}