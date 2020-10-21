page 30022 "APIV2 - Dimension Set Lines"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Dimension Set Line';
    EntitySetCaption = 'Dimension Set Lines';
    DelayedInsert = true;
    EntityName = 'dimensionSetLine';
    EntitySetName = 'dimensionSetLines';
    PageType = API;
    SourceTable = "Dimension Set Entry Buffer";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = "Dimension Id";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; "Dimension Id")
                {
                    Caption = 'Id';

                    trigger OnValidate()
                    begin
                        if not GlobalDimension.GetBySystemId("Dimension Id") then
                            Error(DimensionIdDoesNotMatchADimensionErr);

                        "Dimension Code" := GlobalDimension.Code;
                    end;
                }
                field("code"; "Dimension Code")
                {
                    Caption = 'Code';

                    trigger OnValidate()
                    begin
                        if GlobalDimension.Code <> '' then begin
                            if GlobalDimension.Code <> "Dimension Code" then
                                Error(DimensionFieldsDontMatchErr);
                            exit;
                        end;

                        if not GlobalDimension.Get("Dimension Code") then
                            Error(DimensionCodeDoesNotMatchADimensionErr);

                        "Dimension Id" := GlobalDimension.SystemId;
                    end;
                }
                field(parentId; "Parent Id")
                {
                    Caption = 'Parent Id';
                    Editable = false;
                }
                field(parentType; "Parent Type")
                {
                    Caption = 'Parent Type';
                    Editable = false;
                }
                field(displayName; "Dimension Name")
                {
                    Caption = 'Display Name';
                }
                field(valueId; GlobalDimensionValueId)
                {
                    Caption = 'Value Id';

                    trigger OnValidate()
                    begin
                        if not GlobalDimensionValue.GetBySystemId(GlobalDimensionValueId) then
                            Error(DimensionValueIdDoesNotMatchADimensionValueErr);

                        GlobalDimensionValueCode := GlobalDimensionValue.Code;
                    end;
                }
                field(valueCode; GlobalDimensionValueCode)
                {
                    Caption = 'Value Code';

                    trigger OnValidate()
                    begin
                        if GlobalDimensionValue.Code <> '' then begin
                            if GlobalDimensionValue.Code <> GlobalDimensionValueCode then
                                Error(DimensionValueFieldsDontMatchErr);
                            exit;
                        end;

                        if not GlobalDimensionValue.Get("Dimension Code", GlobalDimensionValueCode) then
                            Error(DimensionValueCodeDoesNotMatchADimensionValueErr);

                        GlobalDimensionValueId := GlobalDimensionValue.SystemId;
                    end;
                }
                field(valueDisplayName; "Dimension Value Name")
                {
                    Caption = 'Value Display Name';
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
    var
        ParentIdFilter: Text;
        ParentTypeFilter: Text;
    begin
        Delete(true);
        SaveDimensions(GetFilter("Parent Id"), GetFilter("Parent Type"));
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        ParentIdFilter: Text;
        ParentTypeFilter: Text;
    begin
        ParentIdFilter := GetFilter("Parent Id");
        ParentTypeFilter := GetFilter("Parent Type");
        if ParentIdFilter = '' then begin
            FilterGroup(4);
            ParentIdFilter := GetFilter("Parent Id");
            ParentTypeFilter := GetFilter("Parent Type");
            FilterGroup(0);
            if ParentIdFilter = '' then
                Error(ParentNotSpecifiedErr);
            if ParentTypeFilter = '' then
                Error(ParentNotSpecifiedErr);
        end;

        exit(LoadLinesFromFilter(ParentIdFilter, ParentTypeFilter));
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        DimensionId: Guid;
        ParentIdFilter: Text;
        ParentTypeFilter: Text;
    begin
        ParentIdFilter := GetFilter("Parent Id");
        ParentTypeFilter := GetFilter("Parent Type");
        if (ParentIdFilter = '') or (ParentTypeFilter = '') then
            Error(ParentIDRequiredErr);

        CheckIfValuesAreProperlyFilled();
        AssignDimensionValueToRecord();
        "Parent Type" := GetParentTypeFromFilter(ParentTypeFilter);

        DimensionId := "Dimension Id";
        Insert(true);

        LoadLinesFromFilter(ParentIdFilter, ParentTypeFilter);
        SaveDimensions(ParentIdFilter, ParentTypeFilter);

        if not NewDimensionSet then
            LoadLinesFromFilter(ParentIdFilter, ParentTypeFilter);
        Get(ParentIdFilter, DimensionId);
        SetCalculatedFields();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Dimension: Record Dimension;
    begin
        Dimension.Get("Dimension Code");
        if (xRec."Dimension Id" <> Rec."Dimension Id") or (xRec."Dimension Id" <> Dimension.SystemId) then
            Error(IdAndCodeCannotBeModifiedErr);

        AssignDimensionValueToRecord();
        Modify(true);

        SaveDimensions(GetFilter("Parent Id"), GetFilter("Parent Type"));
        LoadLinesFromFilter(GetFilter("Parent Id"), GetFilter("Parent Type"));
        Get("Parent Id", Dimension.SystemId);
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
        NewDimensionSet: Boolean;
        ParentNotSpecifiedErr: Label 'You must get to the parent first to get to the dimension set line.';
        ParentIDRequiredErr: Label 'You must get to the parent first to create a dimension set line.';
        IdOrCodeShouldBeFilledErr: Label 'The id or code field must be filled in.', Comment = 'id and code are field names and should not be translated.';
        ValueIdOrValueCodeShouldBeFilledErr: Label 'The valueId or valueCode field must be filled in.', Comment = 'valueId and valueCode are field names and should not be translated.';
        IdAndCodeCannotBeModifiedErr: Label 'The ID and Code fields cannot be modified.', Comment = 'id and code are field names and should not be translated.';
        RecordDoesntExistErr: Label 'Could not find the record.';
        DimensionFieldsDontMatchErr: Label 'The dimension field values do not match to a specific Dimension.';
        DimensionIdDoesNotMatchADimensionErr: Label 'The "id" does not match to a Dimension.', Comment = 'id is a field name and should not be translated.';
        DimensionCodeDoesNotMatchADimensionErr: Label 'The "code" does not match to a Dimension.', Comment = 'id is a field name and should not be translated.';
        DimensionValueFieldsDontMatchErr: Label 'The values of the Dimension Code field and the Dimension ID field do not refer to the same Dimension Value.';
        DimensionValueIdDoesNotMatchADimensionValueErr: Label 'The "valueId" does not match to a Dimension Value.', Comment = 'valueId is a field name and should not be translated.';
        DimensionValueCodeDoesNotMatchADimensionValueErr: Label 'The "valueCode" does not match to a Dimension Value.', Comment = 'valueCode is a field name and should not be translated.';

    local procedure LoadLinesFromFilter(ParentIdFilter: Text; ParentTypeFilter: Text): Boolean
    var
        FilterView: Text;
    begin
        if not LinesLoaded then begin
            FilterView := GetView();
            LoadLinesFromId(ParentIdFilter, ParentTypeFilter);
            SetView(FilterView);
            if not FindFirst() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    local procedure LoadLinesFromId(ParentIdFilter: Text; ParentTypeFilter: Text)
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit "DimensionManagement";
        DimensionSetId: Integer;
    begin
        DimensionSetId := GetSetId(ParentIdFilter, ParentTypeFilter);
        if DimensionSetId = 0 then begin
            NewDimensionSet := true;
            exit;
        end;

        TempDimensionSetEntry.SetAutoCalcFields("Dimension Name", "Dimension Value Name");
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, DimensionSetId);

        if not TempDimensionSetEntry.Find('-') then
            exit;

        repeat
            Clear(Rec);
            TransferFields(TempDimensionSetEntry, true);
            "Parent Id" := ParentIdFilter;
            "Parent Type" := GetParentTypeFromFilter(ParentTypeFilter);
            Insert(true);
        until TempDimensionSetEntry.Next() = 0;
    end;

    local procedure GetSetId(ParentIdFilter: Text; ParentTypeFilter: Text): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchInvEntityAggregate: Record "Purch. Inv. Entity Aggregate";
        PurchInvHeader: Record "Purch. Inv. Header";
        GLEntry: Record "G/L Entry";
        TimeSheetDetail: Record "Time Sheet Detail";
        SalesLine: Record "Sales Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PurchaseLine: Record "Purchase Line";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        case ParentTypeFilter of
            'Journal Line':
                if GenJournalLine.GetBySystemId(ParentIdFilter) then
                    exit(GenJournalLine."Dimension Set ID");
            'Sales Order', 'Sales Quote':
                if SalesHeader.GetBySystemId(ParentIdFilter) then
                    exit(SalesHeader."Dimension Set ID");
            'Sales Credit Memo':
                begin
                    SalesCrMemoEntityBuffer.SetFilter(Id, ParentIdFilter);
                    if SalesCrMemoEntityBuffer.FindFirst() then
                        if not SalesCrMemoEntityBuffer.Posted then begin
                            if SalesHeader.GetBySystemId(ParentIdFilter) then
                                exit(SalesHeader."Dimension Set ID");
                        end else begin
                            SalesCrMemoHeader.SetRange("Draft Cr. Memo SystemId", ParentIdFilter);
                            if SalesCrMemoHeader.FindFirst() then
                                exit(SalesCrMemoHeader."Dimension Set ID");
                        end;
                end;
            'Sales Invoice':
                begin
                    SalesInvoiceEntityAggregate.SetFilter(Id, ParentIdFilter);
                    if SalesInvoiceEntityAggregate.FindFirst() then
                        if not SalesInvoiceEntityAggregate.Posted then begin
                            if SalesHeader.GetBySystemId(ParentIdFilter) then
                                exit(SalesHeader."Dimension Set ID");
                        end else begin
                            SalesInvoiceHeader.SetRange("Draft Invoice SystemId", ParentIdFilter);
                            if SalesInvoiceHeader.FindFirst() then
                                exit(SalesInvoiceHeader."Dimension Set ID");
                        end;
                end;
            'Purchase Invoice':
                begin
                    PurchInvEntityAggregate.SetFilter(Id, ParentIdFilter);
                    if PurchInvEntityAggregate.FindFirst() then
                        if not PurchInvEntityAggregate.Posted then begin
                            if PurchaseHeader.GetBySystemId(ParentIdFilter) then
                                exit(PurchaseHeader."Dimension Set ID");
                        end else begin
                            PurchInvHeader.SetRange("Draft Invoice SystemId", ParentIdFilter);
                            if PurchInvHeader.FindFirst() then
                                exit(PurchInvHeader."Dimension Set ID");
                        end;
                end;
            'General Ledger Entry':
                if GLEntry.GetBySystemId(ParentIdFilter) then
                    exit(GLEntry."Dimension Set ID");
            'Time Registration Entry':
                if TimeSheetDetail.GetBySystemId(ParentIdFilter) then
                    exit(TimeSheetDetail."Dimension Set ID");
            'Sales Order Line', 'Sales Quote Line':
                if SalesLine.GetBySystemId(ParentIdFilter) then
                    exit(SalesLine."Dimension Set ID");
            'Sales Credit Memo Line':
                begin
                    if SalesLine.GetBySystemId(ParentIdFilter) then
                        exit(SalesLine."Dimension Set ID");
                    if SalesCrMemoLine.GetBySystemId(ParentIdFilter) then
                        exit(SalesCrMemoLine."Dimension Set ID");
                end;
            'Sales Invoice Line':
                begin
                    if SalesLine.GetBySystemId(ParentIdFilter) then
                        exit(SalesLine."Dimension Set ID");
                    if SalesInvoiceLine.GetBySystemId(ParentIdFilter) then
                        exit(SalesInvoiceLine."Dimension Set ID");
                end;
            'Purchase Invoice Line':
                begin
                    if PurchaseLine.GetBySystemId(ParentIdFilter) then
                        exit(PurchaseLine."Dimension Set ID");
                    if PurchInvLine.GetBySystemId(ParentIdFilter) then
                        exit(PurchInvLine."Dimension Set ID");
                end;
        end;
        Error(RecordDoesntExistErr);
    end;

    local procedure SaveDimensions(ParentIdFilter: Text; ParentTypeFilter: Text)
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchInvEntityAggregate: Record "Purch. Inv. Entity Aggregate";
        PurchInvHeader: Record "Purch. Inv. Header";
        GLEntry: Record "G/L Entry";
        TimeSheetDetail: Record "Time Sheet Detail";
        SalesLine: Record "Sales Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvLine: Record "Purch. Inv. Line";
        DimensionManagement: Codeunit "DimensionManagement";
    begin
        Reset();
        if FindFirst() then
            repeat
                TempDimensionSetEntry.TransferFields(Rec, true);
                TempDimensionSetEntry."Dimension Set ID" := 0;
                TempDimensionSetEntry.Insert(true);
            until Next() = 0;

        case ParentTypeFilter of
            'Journal Line':
                if GenJournalLine.GetBySystemId(ParentIdFilter) then begin
                    GenJournalLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                    DimensionManagement.UpdateGlobalDimFromDimSetID(
                        GenJournalLine."Dimension Set ID", GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
                    GenJournalLine.Modify(true);
                    exit;
                end;
            'Sales Order', 'Sales Quote':
                if SalesHeader.GetBySystemId(ParentIdFilter) then begin
                    SalesHeader."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                    DimensionManagement.UpdateGlobalDimFromDimSetID(
                        SalesHeader."Dimension Set ID", SalesHeader."Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 2 Code");
                    SalesHeader.Modify(true);
                    exit;
                end;
            'Sales Credit Memo':
                begin
                    SalesCrMemoEntityBuffer.SetFilter(Id, ParentIdFilter);
                    if SalesCrMemoEntityBuffer.FindFirst() then
                        if not SalesCrMemoEntityBuffer.Posted then begin
                            if SalesHeader.GetBySystemId(ParentIdFilter) then begin
                                SalesHeader."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                                DimensionManagement.UpdateGlobalDimFromDimSetID(
                                    SalesHeader."Dimension Set ID", SalesHeader."Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 2 Code");
                                SalesHeader.Modify(true);
                                exit;
                            end;
                        end else begin
                            SalesCrMemoHeader.SetRange("Draft Cr. Memo SystemId", ParentIdFilter);
                            if SalesCrMemoHeader.FindFirst() then begin
                                SalesCrMemoHeader."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                                DimensionManagement.UpdateGlobalDimFromDimSetID(
                                    SalesCrMemoHeader."Dimension Set ID", SalesCrMemoHeader."Shortcut Dimension 1 Code", SalesCrMemoHeader."Shortcut Dimension 2 Code");
                                SalesCrMemoHeader.Modify(true);
                                exit;
                            end;
                        end;
                end;
            'Sales Invoice':
                begin
                    SalesInvoiceEntityAggregate.SetFilter(Id, ParentIdFilter);
                    if SalesInvoiceEntityAggregate.FindFirst() then
                        if not SalesInvoiceEntityAggregate.Posted then begin
                            if SalesHeader.GetBySystemId(ParentIdFilter) then begin
                                SalesHeader."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                                DimensionManagement.UpdateGlobalDimFromDimSetID(
                                    SalesHeader."Dimension Set ID", SalesHeader."Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 2 Code");
                                SalesHeader.Modify(true);
                                exit;
                            end;
                        end else begin
                            SalesInvoiceHeader.SetRange("Draft Invoice SystemId", ParentIdFilter);
                            if SalesInvoiceHeader.FindFirst() then begin
                                SalesInvoiceHeader."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                                DimensionManagement.UpdateGlobalDimFromDimSetID(
                                    SalesInvoiceHeader."Dimension Set ID", SalesInvoiceHeader."Shortcut Dimension 1 Code", SalesInvoiceHeader."Shortcut Dimension 2 Code");
                                SalesInvoiceHeader.Modify(true);
                                exit;
                            end;
                        end;
                end;
            'Purchase Invoice':
                begin
                    PurchInvEntityAggregate.SetFilter(Id, ParentIdFilter);
                    if PurchInvEntityAggregate.FindFirst() then
                        if not PurchInvEntityAggregate.Posted then begin
                            if PurchaseHeader.GetBySystemId(ParentIdFilter) then begin
                                PurchaseHeader."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                                DimensionManagement.UpdateGlobalDimFromDimSetID(
                                    PurchaseHeader."Dimension Set ID", PurchaseHeader."Shortcut Dimension 1 Code", PurchaseHeader."Shortcut Dimension 2 Code");
                                PurchaseHeader.Modify(true);
                                exit;
                            end;
                        end else begin
                            PurchInvHeader.SetRange("Draft Invoice SystemId", ParentIdFilter);
                            if PurchInvHeader.FindFirst() then begin
                                PurchInvHeader."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                                DimensionManagement.UpdateGlobalDimFromDimSetID(
                                    PurchInvHeader."Dimension Set ID", PurchInvHeader."Shortcut Dimension 1 Code", PurchInvHeader."Shortcut Dimension 2 Code");
                                PurchInvHeader.Modify(true);
                                exit;
                            end;
                        end;
                end;
            'Time Registration Entry':
                if TimeSheetDetail.GetBySystemId(ParentIdFilter) then begin
                    TimeSheetDetail."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                    TimeSheetDetail.Modify(true);
                    exit;
                end;
            'Sales Order Line', 'Sales Quote Line':
                if SalesLine.GetBySystemId(ParentIdFilter) then begin
                    SalesLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                    DimensionManagement.UpdateGlobalDimFromDimSetID(
                        SalesLine."Dimension Set ID", SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
                    SalesLine.Modify(true);
                    exit;
                end;
            'Sales Credit Memo Line':
                begin
                    if SalesLine.GetBySystemId(ParentIdFilter) then begin
                        SalesLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                        DimensionManagement.UpdateGlobalDimFromDimSetID(
                            SalesLine."Dimension Set ID", SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
                        SalesLine.Modify(true);
                        exit;
                    end;
                    if SalesCrMemoLine.GetBySystemId(ParentIdFilter) then begin
                        SalesCrMemoLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                        DimensionManagement.UpdateGlobalDimFromDimSetID(
                            SalesCrMemoLine."Dimension Set ID", SalesCrMemoLine."Shortcut Dimension 1 Code", SalesCrMemoLine."Shortcut Dimension 2 Code");
                        SalesCrMemoLine.Modify(true);
                        exit;
                    end;
                end;
            'Sales Invoice Line':
                begin
                    if SalesLine.GetBySystemId(ParentIdFilter) then begin
                        SalesLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                        DimensionManagement.UpdateGlobalDimFromDimSetID(
                            SalesLine."Dimension Set ID", SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
                        SalesLine.Modify(true);
                        exit;
                    end;
                    if SalesInvoiceLine.GetBySystemId(ParentIdFilter) then begin
                        SalesInvoiceLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                        DimensionManagement.UpdateGlobalDimFromDimSetID(
                            SalesInvoiceLine."Dimension Set ID", SalesInvoiceLine."Shortcut Dimension 1 Code", SalesInvoiceLine."Shortcut Dimension 2 Code");
                        SalesInvoiceLine.Modify(true);
                        exit;
                    end;
                end;
            'Purchase Invoice Line':
                begin
                    if PurchaseLine.GetBySystemId(ParentIdFilter) then begin
                        PurchaseLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                        DimensionManagement.UpdateGlobalDimFromDimSetID(
                            PurchaseLine."Dimension Set ID", PurchaseLine."Shortcut Dimension 1 Code", PurchaseLine."Shortcut Dimension 2 Code");
                        PurchaseLine.Modify(true);
                        exit;
                    end;
                    if PurchaseInvLine.GetBySystemId(ParentIdFilter) then begin
                        PurchaseInvLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                        DimensionManagement.UpdateGlobalDimFromDimSetID(
                            PurchaseInvLine."Dimension Set ID", PurchaseInvLine."Shortcut Dimension 1 Code", PurchaseInvLine."Shortcut Dimension 2 Code");
                        PurchaseInvLine.Modify(true);
                        exit;
                    end;
                end;
        end;
        Error(RecordDoesntExistErr);
    end;

    local procedure CheckIfValuesAreProperlyFilled()
    begin
        if "Dimension Code" = '' then
            Error(IdOrCodeShouldBeFilledErr);

        if IsNullGuid(GlobalDimensionValueId) and
           (GlobalDimensionValueCode = '')
        then
            Error(ValueIdOrValueCodeShouldBeFilledErr);
    end;

    local procedure AssignDimensionValueToRecord()
    begin
        if not IsNullGuid(GlobalDimensionValueId) then
            Validate("Value Id", GlobalDimensionValueId);

        if GlobalDimensionValueCode <> '' then
            Validate("Dimension Value Code", GlobalDimensionValueCode);
    end;

    local procedure SetCalculatedFields()
    begin
        GlobalDimensionValueId := "Value Id";
        GlobalDimensionValueCode := "Dimension Value Code";
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(GlobalDimensionValueId);
        Clear(GlobalDimensionValueCode);
    end;

    local procedure GetParentTypeFromFilter(ParentTypeFilter: Text): Enum "Dimension Set Entry Buffer Parent Type"
    var
        DimensionSetEntryBufferParentType: Enum "Dimension Set Entry Buffer Parent Type";
    begin
        case ParentTypeFilter of
            'Journal Line':
                exit(DimensionSetEntryBufferParentType::"Journal Line");
            'Sales Order':
                exit(DimensionSetEntryBufferParentType::"Sales Order");
            'Sales Order Line':
                exit(DimensionSetEntryBufferParentType::"Sales Order Line");
            'Sales Quote':
                exit(DimensionSetEntryBufferParentType::"Sales Quote");
            'Sales Quote Line':
                exit(DimensionSetEntryBufferParentType::"Sales Quote Line");
            'Sales Credit Memo':
                exit(DimensionSetEntryBufferParentType::"Sales Credit Memo");
            'Sales Credit Memo Line':
                exit(DimensionSetEntryBufferParentType::"Sales Credit Memo Line");
            'Sales Invoice':
                exit(DimensionSetEntryBufferParentType::"Sales Invoice");
            'Sales Invoice Line':
                exit(DimensionSetEntryBufferParentType::"Sales Invoice Line");
            'Purchase Invoice':
                exit(DimensionSetEntryBufferParentType::"Purchase Invoice");
            'Purchase Invoice Line':
                exit(DimensionSetEntryBufferParentType::"Purchase Invoice Line");
            'General Ledger Entry':
                exit(DimensionSetEntryBufferParentType::"General Ledger Entry");
            'Time Registration Entry':
                exit(DimensionSetEntryBufferParentType::"Time Registration Entry");
            ' ':
                exit(DimensionSetEntryBufferParentType::" ");
        end;
    end;
}