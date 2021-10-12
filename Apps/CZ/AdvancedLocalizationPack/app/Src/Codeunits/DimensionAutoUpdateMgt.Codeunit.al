codeunit 31395 "Dimension Auto.Update Mgt. CZA"
{
    Permissions = TableData "Dimension Value" = rim,
                  TableData "Default Dimension" = r;
    SingleInstance = true;

    var
        TempChangeLogSetupTable: Record "Change Log Setup (Table)" temporary;
        TempDefaultDimension: Record "Default Dimension" temporary;
        DimChangeSetupRead: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GlobalTriggerManagement", 'OnAfterGetDatabaseTableTriggerSetup', '', false, false)]
    local procedure GetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    begin
        if CompanyName = '' then
            exit;

        CheckChangeSetupRead();

        if TempChangeLogSetupTable.Get(TableId) then begin
            OnDatabaseInsert := true;
            OnDatabaseModify := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GlobalTriggerManagement", 'OnAfterOnDatabaseInsert', '', false, false)]
    local procedure DimensionInsert(RecRef: RecordRef)
    begin
        if RecRef.IsTemporary then
            exit;

        if RecRef.Number = Database::"Default Dimension" then
            ClearSetup();
        CheckChangeSetupRead();
        if not TempChangeLogSetupTable.Get(RecRef.Number) then
            exit;

        UpdateDimensionValue(RecRef, RecRef, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GlobalTriggerManagement", 'OnAfterOnDatabaseModify', '', false, false)]
    local procedure DimensionModify(RecRef: RecordRef)
    var
        xRecRef: RecordRef;
    begin
        if RecRef.IsTemporary then
            exit;

        if RecRef.Number = Database::"Default Dimension" then
            ClearSetup();
        CheckChangeSetupRead();
        if not TempChangeLogSetupTable.Get(RecRef.Number) then
            exit;

        if not xRecRef.Get(RecRef.RecordId) then
            xRecRef := RecRef;

        UpdateDimensionValue(RecRef, xRecRef, false);
    end;

    local procedure UpdateDimensionValue(DimValRecordRef: RecordRef; XDimValRecordRef: RecordRef; IsInsert: Boolean)
    var
        DimensionValue: Record "Dimension Value";
        RecField: Record "Field";
        DescrFieldRef: FieldRef;
        OldDescrFieldRef: FieldRef;
        PrimaryKeyFieldRef: FieldRef;
        PrimaryKeyRef: KeyRef;
        TempValueText: Text;
        OldTempValueText: Text;
        IsUpdate: Boolean;
    begin
        TempDefaultDimension.Reset();
        TempDefaultDimension.SetRange("Table ID", DimValRecordRef.Number);
        TempDefaultDimension.SetRange("Automatic Create CZA", true);
        TempDefaultDimension.SetRange("No.", '');
        TempDefaultDimension.SetFilter("Dim. Description Field ID CZA", '<>%1', 0);
        TempDefaultDimension.SetFilter("Dim. Description Update CZA", '<>%1', TempDefaultDimension."Dim. Description Update CZA"::" ");
        if TempDefaultDimension.FindSet(false, false) then
            repeat
                IsUpdate := false;
                DescrFieldRef := DimValRecordRef.Field(TempDefaultDimension."Dim. Description Field ID CZA");
                PrimaryKeyRef := DimValRecordRef.KeyIndex(1);
                PrimaryKeyFieldRef := PrimaryKeyRef.FieldIndex(1);
                if DimensionValue.Get(TempDefaultDimension."Dimension Code", Format(PrimaryKeyFieldRef.Value)) then begin
                    if RecField.Get(TempDefaultDimension."Table ID", TempDefaultDimension."Dim. Description Field ID CZA") then
                        if RecField.Class = RecField.Class::FlowField then
                            DescrFieldRef.CalcField();
                    TempValueText := Format(DescrFieldRef.Value);
                    if TempDefaultDimension."Dim. Description Format CZA" <> '' then
                        TempValueText := StrSubstNo(TempDefaultDimension."Dim. Description Format CZA", TempValueText);
                    if TempValueText <> '' then
                        TempValueText := CopyStr(TempValueText, 1, MaxStrLen(DimensionValue.Name));
                    if TempDefaultDimension."Dim. Description Update CZA" = TempDefaultDimension."Dim. Description Update CZA"::Create then
                        if (DimensionValue.Name = '') or IsInsert then
                            IsUpdate := true
                        else begin
                            OldDescrFieldRef := XDimValRecordRef.Field(TempDefaultDimension."Dim. Description Field ID CZA");
                            if RecField.Get(TempDefaultDimension."Table ID", TempDefaultDimension."Dim. Description Field ID CZA") then
                                if RecField.Class = RecField.Class::FlowField then
                                    OldDescrFieldRef.CalcField();
                            OldTempValueText := Format(OldDescrFieldRef.Value);
                            if TempDefaultDimension."Dim. Description Format CZA" <> '' then
                                OldTempValueText := StrSubstNo(TempDefaultDimension."Dim. Description Format CZA", OldTempValueText);
                            if OldTempValueText <> '' then
                                OldTempValueText := CopyStr(OldTempValueText, 1, MaxStrLen(DimensionValue.Name));
                            IsUpdate := DimensionValue.Name = OldTempValueText;
                        end
                    else
                        IsUpdate := true;
                    if (DimensionValue.Name <> TempValueText) and IsUpdate then begin
                        DimensionValue.Name := CopyStr(TempValueText, 1, MaxStrLen(DimensionValue.Name));
                        DimensionValue.Modify();
                    end;
                end;
            until TempDefaultDimension.Next() = 0;
    end;

    local procedure CheckChangeSetupRead()
    begin
        if not DimChangeSetupRead then begin
            ReadSetup();
            DimChangeSetupRead := true;
        end;
    end;

    local procedure ReadSetup()
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.SetRange("Automatic Create CZA", true);
        DefaultDimension.SetRange("No.", '');
        DefaultDimension.SetFilter("Dim. Description Field ID CZA", '<>%1', 0);
        DefaultDimension.SetFilter("Dim. Description Update CZA", '<>%1', DefaultDimension."Dim. Description Update CZA"::" ");
        if DefaultDimension.FindSet(false, false) then
            repeat
                if not TempChangeLogSetupTable.Get(DefaultDimension."Table ID") then begin
                    TempChangeLogSetupTable."Table No." := DefaultDimension."Table ID";
                    TempChangeLogSetupTable.Insert();
                end;
                TempDefaultDimension := DefaultDimension;
                TempDefaultDimension.Insert();
            until DefaultDimension.Next() = 0;
    end;

    local procedure ClearSetup()
    begin
        TempChangeLogSetupTable.Reset();
        TempChangeLogSetupTable.DeleteAll(false);
        TempDefaultDimension.Reset();
        TempDefaultDimension.DeleteAll(false);
        DimChangeSetupRead := false;
    end;
}
