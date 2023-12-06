codeunit 2687 "Data Search Setup Changes"
{
    EventSubscriberInstance = Manual;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ModifiedTablesSetup: List of [Integer];
        RemovedTablesSetup: List of [Integer];

    internal procedure GetModifiedSetup(): List of [Integer];
    begin
        exit(ModifiedTablesSetup);
    end;

    internal procedure GetRemovedSetup(): List of [Integer];
    begin
        exit(RemovedTablesSetup);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Data Search Setup (Table)", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInserSetupTable(var Rec: Record "Data Search Setup (Table)"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        AddToModifiedList(Rec."Table/Type ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Data Search Setup (Table)", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSetupTable(var Rec: Record "Data Search Setup (Table)"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        AddToRemovedList(Rec."Table/Type ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Data Search Setup (Field)", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInserSetupField(var Rec: Record "Data Search Setup (Field)"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        AddToModifiedListForTable(Rec."Table No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Data Search Setup (Field)", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSetupField(var Rec: Record "Data Search Setup (Field)"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        AddToModifiedListForTable(Rec."Table No.");
    end;

    local procedure AddToModifiedList(TableTypeID: Integer)
    begin
        if not ModifiedTablesSetup.Contains(TableTypeID) then
            ModifiedTablesSetup.Add(TableTypeID);
    end;

    local procedure AddToRemovedList(TableTypeID: Integer)
    begin
        if not RemovedTablesSetup.Contains(TableTypeID) then
            RemovedTablesSetup.Add(TableTypeID);
    end;

    local procedure AddToModifiedListForTable(TableNo: Integer)
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
    begin
        DataSearchSetupTable.SetRange("Role Center ID", DataSearchSetupTable.GetRoleCenterID());
        DataSearchSetupTable.SetRange("Table No.", TableNo);
        DataSearchSetupTable.SetLoadFields("Table/Type ID");
        if DataSearchSetupTable.FindSet() then
            repeat
                AddToModifiedList(DataSearchSetupTable."Table/Type ID");
            until DataSearchSetupTable.Next() = 0;
    end;
}