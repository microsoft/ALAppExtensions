codeunit 135216 "Sustainability Foundation Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        FieldNoFoundInLedgerEntryErr: Label 'Field %1 not found in Sustainability Ledger Entry', Locked = true;
        FieldNameOrCaptionMismatchErr: Label 'Field %1 name or caption does not match the corresponding field in the Ledger Entry table', Locked = true;

    [Test]
    procedure TestFieldsInJournalLineAndLedgerEntry()
    var
        JournalLineFields, LedgerEntryFields : Record Field;
    begin
        // Check that all fields in the Sustainability Journal Line table are also present in the Sustainability Ledger Entry table
        JournalLineFields.SetRange(TableNo, Database::"Sustainability Jnl. Line");
        JournalLineFields.SetCurrentKey("No.");

        if JournalLineFields.FindSet() then
            repeat
                if not LedgerEntryFields.Get(Database::"Sustainability Ledger Entry", JournalLineFields."No.") then
                    Error(FieldNoFoundInLedgerEntryErr, JournalLineFields."No.");

                if not JournalLineFields.FieldName.StartsWith('Shortcut Dimension') then begin
                    Assert.AreEqual(JournalLineFields.FieldName, LedgerEntryFields.FieldName, StrSubstNo(FieldNameOrCaptionMismatchErr, JournalLineFields.FieldName));
                    Assert.AreEqual(JournalLineFields."Field Caption", LedgerEntryFields."Field Caption", StrSubstNo(FieldNameOrCaptionMismatchErr, JournalLineFields.FieldName));
                end;
            until JournalLineFields.Next() = 0;
    end;
}