page 20022 "APIV1 - Dimension Lines"
{
    APIVersion = 'v1.0';
    Caption = 'dimensionLines', Locked = true;
    DelayedInsert = true;
    EntityName = 'dimensionLine';
    EntitySetName = 'dimensionLines';
    PageType = API;
    SourceTable = "Dimension Set Entry Buffer";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(parentId; "Parent Id")
                {
                    Caption = 'parentId', Locked = true;
                }
                field(id; "Dimension Id")
                {
                    Caption = 'id', Locked = true;

                    trigger OnValidate()
                    begin
                        IF NOT GlobalDimension.GetBySystemId("Dimension Id") THEN
                            ERROR(DimensionIdDoesNotMatchADimensionErr);

                        "Dimension Code" := GlobalDimension.Code;
                    end;
                }
                field("code"; "Dimension Code")
                {
                    Caption = 'code', Locked = true;

                    trigger OnValidate()
                    begin
                        IF GlobalDimension.Code <> '' THEN BEGIN
                            IF GlobalDimension.Code <> "Dimension Code" THEN
                                ERROR(DimensionFieldsDontMatchErr);
                            EXIT;
                        END;

                        IF NOT GlobalDimension.GET("Dimension Code") THEN
                            ERROR(DimensionCodeDoesNotMatchADimensionErr);

                        "Dimension Id" := GlobalDimension.SystemId;
                    end;
                }
                field(displayName; "Dimension Name")
                {
                    Caption = 'displayName', Locked = true;
                }
                field(valueId; GlobalDimensionValueId)
                {
                    Caption = 'valueId', Locked = true;
                    ToolTip = 'Specifies the ID of the Dimension value.';

                    trigger OnValidate()
                    begin
                        IF NOT GlobalDimensionValue.GetBySystemId(GlobalDimensionValueId) THEN
                            ERROR(DimensionValueIdDoesNotMatchADimensionValueErr);

                        GlobalDimensionValueCode := GlobalDimensionValue.Code;
                    end;
                }
                field(valueCode; GlobalDimensionValueCode)
                {
                    Caption = 'valueCode', Locked = true;
                    ToolTip = 'Specifies the Code of the Dimension value.';

                    trigger OnValidate()
                    begin
                        IF GlobalDimensionValue.Code <> '' THEN BEGIN
                            IF GlobalDimensionValue.Code <> GlobalDimensionValueCode THEN
                                ERROR(DimensionValueFieldsDontMatchErr);
                            EXIT;
                        END;

                        IF NOT GlobalDimensionValue.GET("Dimension Code", GlobalDimensionValueCode) THEN
                            ERROR(DimensionValueCodeDoesNotMatchADimensionValueErr);

                        GlobalDimensionValueId := GlobalDimensionValue.SystemId;
                    end;
                }
                field(valueDisplayName; "Dimension Value Name")
                {
                    Caption = 'valueDisplayName', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        DELETE(TRUE);
        SaveDimensions();
        EXIT(FALSE);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        ParentIdFilter: Text;
    begin
        ParentIdFilter := GETFILTER("Parent Id");
        IF ParentIdFilter = '' THEN
            ERROR(ParentIDNotSpecifiedErr);
        EXIT(LoadLinesFromFilter(ParentIdFilter));
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        DimensionId: Guid;
        BlankGUID: Guid;
    begin
        IF "Parent Id" = BlankGUID THEN
            ERROR(ParentIDRequiredErr);

        CheckIfValuesAreProperlyFilled();
        AssignDimensionValueToRecord();

        DimensionId := "Dimension Id";
        INSERT(TRUE);

        LoadLinesFromFilter("Parent Id");
        SaveDimensions();

        LoadLinesFromFilter("Parent Id");
        GET("Parent Id", DimensionId);
        SetCalculatedFields();

        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    var
        DimensionId: Guid;
    begin
        EVALUATE(DimensionId, GETFILTER("Dimension Id"));
        IF "Dimension Id" <> DimensionId THEN
            ERROR(IdAndCodeCannotBeModifiedErr);

        AssignDimensionValueToRecord();
        MODIFY(TRUE);

        SaveDimensions();
        LoadLinesFromFilter(GETFILTER("Parent Id"));
        GET("Parent Id", DimensionId);
        SetCalculatedFields();

        EXIT(FALSE);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        GlobalDimension: Record "Dimension";
        GlobalDimensionValue: Record "Dimension Value";
        GlobalDimensionValueId: Guid;
        GlobalDimensionValueCode: Code[20];
        LinesLoaded: Boolean;
        ParentIDNotSpecifiedErr: Label 'You must specify a parent id to get the lines.', Locked = true;
        ParentIDRequiredErr: Label 'The parent ID must be filled in.', Locked = true;
        IdOrCodeShouldBeFilledErr: Label 'The ID or Code field must be filled in.', Locked = true;
        ValueIdOrValueCodeShouldBeFilledErr: Label 'The valueId or valueCode field must be filled in.', Locked = true;
        IdAndCodeCannotBeModifiedErr: Label 'The ID and Code fields cannot be modified.', Locked = true;
        RecordDoesntExistErr: Label 'Could not find the record.', Locked = true;
        DimensionFieldsDontMatchErr: Label 'The dimension field values do not match to a specific Dimension.', Locked = true;
        DimensionIdDoesNotMatchADimensionErr: Label 'The "id" does not match to a Dimension.', Locked = true;
        DimensionCodeDoesNotMatchADimensionErr: Label 'The "code" does not match to a Dimension.', Locked = true;
        DimensionValueFieldsDontMatchErr: Label 'The values of the Dimension Code field and the Dimension ID field do not refer to the same Dmension Value.', Locked = true;
        DimensionValueIdDoesNotMatchADimensionValueErr: Label 'The "valueId" does not match to a Dimension Value.', Locked = true;
        DimensionValueCodeDoesNotMatchADimensionValueErr: Label 'The "valueCode" does not match to a Dimension Value.', Locked = true;

    local procedure LoadLinesFromFilter(ParentIdFilter: Text): Boolean
    var
        FilterView: Text;
    begin
        IF NOT LinesLoaded THEN BEGIN
            FilterView := GETVIEW();
            LoadLinesFromId(ParentIdFilter);
            SETVIEW(FilterView);
            IF NOT FINDFIRST() THEN
                EXIT(FALSE);
            LinesLoaded := TRUE;
        END;

        EXIT(TRUE);
    end;

    local procedure LoadLinesFromId(IntegrationId: Text)
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit "DimensionManagement";
        DimensionSetId: Integer;
    begin
        DimensionSetId := GetSetId(IntegrationId);
        IF DimensionSetId = 0 THEN
            EXIT;

        TempDimensionSetEntry.SETAUTOCALCFIELDS("Dimension Name", "Dimension Value Name");
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, DimensionSetId);

        IF NOT TempDimensionSetEntry.FIND('-') THEN
            EXIT;

        REPEAT
            CLEAR(Rec);
            TRANSFERFIELDS(TempDimensionSetEntry, TRUE);
            "Parent Id" := IntegrationId;
            INSERT(TRUE);
        UNTIL TempDimensionSetEntry.NEXT() = 0;
    end;

    local procedure GetSetId(IntegrationId: Text): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if GenJournalLine.GetBySystemId(IntegrationId) then
            exit(GenJournalLine."Dimension Set ID");

        Error(RecordDoesntExistErr);
    end;

    local procedure SaveDimensions()
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        DimensionManagement: Codeunit "DimensionManagement";
        ParentSystemId: Guid;
    begin
        ParentSystemId := "Parent Id";

        RESET();
        IF FINDFIRST() THEN
            REPEAT
                TempDimensionSetEntry.TRANSFERFIELDS(Rec, TRUE);
                TempDimensionSetEntry."Dimension Set ID" := 0;
                TempDimensionSetEntry.INSERT(TRUE);
            UNTIL NEXT() = 0;

        IF GenJournalLine.GetBySystemId(ParentSystemId) THEN BEGIN
            GenJournalLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
            DimensionManagement.UpdateGlobalDimFromDimSetID(
                GenJournalLine."Dimension Set ID", GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
            GenJournalLine.MODIFY(TRUE);
        END ELSE
            ERROR(RecordDoesntExistErr);
    end;

    local procedure CheckIfValuesAreProperlyFilled()
    begin
        IF "Dimension Code" = '' THEN
            ERROR(IdOrCodeShouldBeFilledErr);

        IF ISNULLGUID(GlobalDimensionValueId) AND
           (GlobalDimensionValueCode = '')
        THEN
            ERROR(ValueIdOrValueCodeShouldBeFilledErr);
    end;

    local procedure AssignDimensionValueToRecord()
    begin
        IF NOT ISNULLGUID(GlobalDimensionValueId) THEN
            VALIDATE("Value Id", GlobalDimensionValueId);

        IF GlobalDimensionValueCode <> '' THEN
            VALIDATE("Dimension Value Code", GlobalDimensionValueCode);
    end;

    local procedure SetCalculatedFields()
    begin
        GlobalDimensionValueId := "Value Id";
        GlobalDimensionValueCode := "Dimension Value Code";
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(GlobalDimensionValueId);
        CLEAR(GlobalDimensionValueCode);
    end;
}











