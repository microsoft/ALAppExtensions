namespace Microsoft.API.V1;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;

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
                field(parentId; Rec."Parent Id")
                {
                    Caption = 'parentId', Locked = true;
                }
                field(id; Rec."Dimension Id")
                {
                    Caption = 'id', Locked = true;

                    trigger OnValidate()
                    begin
                        if not GlobalDimension.GetBySystemId(Rec."Dimension Id") then
                            error(DimensionIdDoesNotMatchADimensionErr);

                        Rec."Dimension Code" := GlobalDimension.Code;
                    end;
                }
                field("code"; Rec."Dimension Code")
                {
                    Caption = 'code', Locked = true;

                    trigger OnValidate()
                    begin
                        if GlobalDimension.Code <> '' then begin
                            if GlobalDimension.Code <> Rec."Dimension Code" then
                                error(DimensionFieldsDontMatchErr);
                            exit;
                        end;

                        if not GlobalDimension.GET(Rec."Dimension Code") then
                            error(DimensionCodeDoesNotMatchADimensionErr);

                        Rec."Dimension Id" := GlobalDimension.SystemId;
                    end;
                }
                field(displayName; Rec."Dimension Name")
                {
                    Caption = 'displayName', Locked = true;
                }
                field(valueId; GlobalDimensionValueId)
                {
                    Caption = 'valueId', Locked = true;
                    ToolTip = 'Specifies the ID of the Dimension value.';

                    trigger OnValidate()
                    begin
                        if not GlobalDimensionValue.GetBySystemId(GlobalDimensionValueId) then
                            error(DimensionValueIdDoesNotMatchADimensionValueErr);

                        GlobalDimensionValueCode := GlobalDimensionValue.Code;
                    end;
                }
                field(valueCode; GlobalDimensionValueCode)
                {
                    Caption = 'valueCode', Locked = true;
                    ToolTip = 'Specifies the Code of the Dimension value.';

                    trigger OnValidate()
                    begin
                        if GlobalDimensionValue.Code <> '' then begin
                            if GlobalDimensionValue.Code <> GlobalDimensionValueCode then
                                error(DimensionValueFieldsDontMatchErr);
                            exit;
                        end;

                        if not GlobalDimensionValue.GET(Rec."Dimension Code", GlobalDimensionValueCode) then
                            error(DimensionValueCodeDoesNotMatchADimensionValueErr);

                        GlobalDimensionValueId := GlobalDimensionValue.SystemId;
                    end;
                }
                field(valueDisplayName; Rec."Dimension Value Name")
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
        Rec.DELETE(true);
        SaveDimensions();
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        ParentIdFilter: Text;
    begin
        ParentIdFilter := Rec.GetFilter("Parent Id");
        if ParentIdFilter = '' then
            error(ParentIDNotSpecifiedErr);
        exit(LoadLinesFromFilter(ParentIdFilter));
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        DimensionId: Guid;
        BlankGUID: Guid;
    begin
        if Rec."Parent Id" = BlankGUID then
            error(ParentIDRequiredErr);

        CheckIfValuesAreProperlyFilled();
        AssignDimensionValueToRecord();

        DimensionId := Rec."Dimension Id";
        Rec.insert(true);

        LoadLinesFromFilter(Rec."Parent Id");
        SaveDimensions();

        LoadLinesFromFilter(Rec."Parent Id");
        Rec.GET(Rec."Parent Id", DimensionId);
        SetCalculatedFields();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        DimensionId: Guid;
    begin
        EVALUATE(DimensionId, Rec.GetFilter("Dimension Id"));
        if Rec."Dimension Id" <> DimensionId then
            error(IdAndCodeCannotBeModifiedErr);

        AssignDimensionValueToRecord();
        Rec.Modify(true);

        SaveDimensions();
        LoadLinesFromFilter(Rec.GetFilter("Parent Id"));
        Rec.GET(Rec."Parent Id", DimensionId);
        SetCalculatedFields();

        exit(false);
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
        if not LinesLoaded then begin
            FilterView := Rec.GetView();
            LoadLinesFromId(ParentIdFilter);
            Rec.SETVIEW(FilterView);
            if not Rec.FINDFIRST() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    local procedure LoadLinesFromId(IntegrationId: Text)
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit "DimensionManagement";
        DimensionSetId: Integer;
    begin
        DimensionSetId := GetSetId(IntegrationId);
        if DimensionSetId = 0 then
            exit;

        TempDimensionSetEntry.SETAUTOCALCfieldS("Dimension Name", "Dimension Value Name");
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, DimensionSetId);

        if not TempDimensionSetEntry.FIND('-') then
            exit;

        repeat
            CLEAR(Rec);
            Rec.TransferFields(TempDimensionSetEntry, true);
            Rec."Parent Id" := IntegrationId;
            Rec.insert(true);
        until TempDimensionSetEntry.NEXT() = 0;
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
        ParentSystemId := Rec."Parent Id";

        Rec.RESET();
        if Rec.FINDFIRST() then
            repeat
                TempDimensionSetEntry.TransferFields(Rec, true);
                TempDimensionSetEntry."Dimension Set ID" := 0;
                TempDimensionSetEntry.insert(true);
            until Rec.NEXT() = 0;

        if GenJournalLine.GetBySystemId(ParentSystemId) then begin
            GenJournalLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
            DimensionManagement.UpdateGlobalDimFromDimSetID(
                GenJournalLine."Dimension Set ID", GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
            GenJournalLine.Modify(true);
        end else
            error(RecordDoesntExistErr);
    end;

    local procedure CheckIfValuesAreProperlyFilled()
    begin
        if Rec."Dimension Code" = '' then
            error(IdOrCodeShouldBeFilledErr);

        if ISNULLGUID(GlobalDimensionValueId) and
           (GlobalDimensionValueCode = '')
        then
            error(ValueIdOrValueCodeShouldBeFilledErr);
    end;

    local procedure AssignDimensionValueToRecord()
    begin
        if not ISNULLGUID(GlobalDimensionValueId) then
            Rec.Validate("Value Id", GlobalDimensionValueId);

        if GlobalDimensionValueCode <> '' then
            Rec.Validate("Dimension Value Code", GlobalDimensionValueCode);
    end;

    local procedure SetCalculatedFields()
    begin
        GlobalDimensionValueId := Rec."Value Id";
        GlobalDimensionValueCode := Rec."Dimension Value Code";
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(GlobalDimensionValueId);
        CLEAR(GlobalDimensionValueCode);
    end;
}












