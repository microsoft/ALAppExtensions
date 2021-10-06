codeunit 31381 "G/L Entry - Edit CZA"
{
    Permissions = tabledata "G/L Entry" = rim;
    TableNo = "G/L Entry";

    trigger OnRun()
    begin
        GLEntry := Rec;
        GLEntry.LockTable();
        GLEntry.Find();
        GLEntry."Applies-to ID CZA" := Rec."Applies-to ID CZA";
        GLEntry.Validate("Amount to Apply CZA", Rec."Amount to Apply CZA");
        GLEntry.Modify();
        Rec := GLEntry;
    end;

    var
        GLEntry: Record "G/L Entry";
}

