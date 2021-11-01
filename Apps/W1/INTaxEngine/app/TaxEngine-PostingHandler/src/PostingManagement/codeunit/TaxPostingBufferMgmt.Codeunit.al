codeunit 20343 "Tax Posting Buffer Mgmt."
{
    SingleInstance = true;
    procedure SetSalesPurchLcy(GenJnlLineSalesPurchLcyAmount: Decimal)
    begin
        SalesPurchLcyAmount := GenJnlLineSalesPurchLcyAmount
    end;

    procedure GetSalesPurchLcy(): Decimal
    begin
        exit(SalesPurchLcyAmount);
    end;

    procedure SetDocument(Record: Variant)
    begin
        PostingDocument := Record;
    end;

    procedure GetDocument(var Record: Variant)
    begin
        Record := PostingDocument;
    end;

    procedure UpdateUseCaseVariables(
        TaxTransactionValue: Record "Tax Transaction Value";
        var Symbols: Record "Script Symbol Value" temporary)
    var
        TaxAttribute: Record "Tax Attribute";
        TaxComponent: Record "Tax Component";
        TaxRateColumn: Record "Tax Rate Column Setup";
        TaxAttributeMgmt: Codeunit "Tax Attribute Management";
        Value: Variant;
        AttributeId: Integer;
    begin
        case TaxTransactionValue."Value Type" of
            TaxTransactionValue."Value Type"::ATTRIBUTE:
                begin
                    TaxAttribute.SetFilter("Tax Type", '%1|%2', TaxTransactionValue."Tax Type", '');
                    TaxAttribute.SetRange(ID, TaxTransactionValue."Value ID");
                    TaxAttribute.FindFirst();

                    if TaxAttribute.Type = TaxAttribute.Type::Option then
                        Value := TaxAttributeMgmt.GetAttributeOptionIndex(
                            TaxAttribute."Tax Type",
                            TaxAttribute.ID,
                            CopyStr(TaxTransactionValue."Column Value", 1, 30))
                    else
                        Value := TaxTransactionValue."Column Value";

                    OnBeforeSetAttribtueDefaultValue(TaxTransactionValue."Tax Record ID", TaxTransactionValue."Tax Type", Symbols, TaxAttribute, Value);

                    SymbolStore.SetDefaultSymbolValue(
                        Symbols,
                        Symbols.Type::"Tax Attributes",
                        TaxTransactionValue."Value ID",
                        Value,
                        DataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxAttribute.Type));
                end;
            TaxTransactionValue."Value Type"::COLUMN:
                begin
                    TaxRateColumn.SetFilter("Tax Type", '%1|%2', TaxTransactionValue."Tax Type", '');
                    TaxRateColumn.SetRange("Column ID", TaxTransactionValue."Value ID");
                    if TaxRateColumn.FindFirst() then begin
                        if TaxRateColumn.Type = TaxRateColumn.Type::Option then begin
                            if TaxRateColumn."Linked Attribute ID" <> 0 then
                                AttributeId := TaxRateColumn."Linked Attribute ID"
                            else
                                AttributeId := TaxRateColumn."Attribute ID";

                            TaxAttribute.Reset();
                            TaxAttribute.SetFilter("Tax Type", '%1|%2', TaxTransactionValue."Tax Type", '');
                            TaxAttribute.SetRange(ID, TaxTransactionValue."Value ID");
                            TaxAttribute.FindFirst();
                            if TaxAttribute.Type = TaxAttribute.Type::Option then
                                Value := TaxAttributeMgmt.GetAttributeOptionIndex(
                                    TaxAttribute."Tax Type",
                                    AttributeId,
                                    copystr(TaxTransactionValue."Column Value", 1, 30))
                            else
                                Value := TaxTransactionValue."Column Value";
                        end else
                            Value := TaxTransactionValue."Column Value";

                        OnBeforeSetColumnDefaultValue(TaxTransactionValue."Tax Record ID", TaxTransactionValue."Tax Type", Symbols, TaxRateColumn, Value);

                        SymbolStore.SetDefaultSymbolValue(
                            Symbols,
                            Symbols.Type::Column,
                            TaxTransactionValue."Value ID",
                            Value,
                            DataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxRateColumn.Type));
                    end;
                end;
            TaxTransactionValue."Value Type"::COMPONENT:
                begin
                    TaxComponent.SetFilter("Tax Type", '%1|%2', TaxTransactionValue."Tax Type", '');
                    TaxComponent.SetRange(ID, TaxTransactionValue."Value ID");
                    TaxComponent.FindFirst();
                    if TaxComponent."Component Type" = TaxComponent."Component Type"::Normal then begin
                        SymbolStore.SetDefaultSymbolValue(
                            Symbols,
                            Symbols.Type::Component,
                            TaxTransactionValue."Value ID",
                            TaxTransactionValue.Amount,
                            "Symbol Data Type"::Number);

                        SymbolStore.SetDefaultSymbolValue(
                            Symbols,
                            Symbols.Type::"Component Amount (LCY)",
                            TaxTransactionValue."Value ID",
                            TaxTransactionValue."Amount (LCY)",
                            "Symbol Data Type"::Number);
                    end else begin
                        SymbolStore.SetDefaultSymbolValue(
                            Symbols,
                            Symbols.Type::Component,
                            TaxTransactionValue."Value ID",
                            0,
                            "Symbol Data Type"::Number);

                        SymbolStore.SetDefaultSymbolValue(
                            Symbols,
                            Symbols.Type::"Component Amount (LCY)",
                            TaxTransactionValue."Value ID",
                            0,
                            "Symbol Data Type"::Number);
                    end;

                    SymbolStore.SetDefaultSymbolValue(
                        Symbols,
                        Symbols.Type::"Component Percent",
                        TaxTransactionValue."Value ID",
                        TaxTransactionValue.Percent,
                        DataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxComponent.Type));
                end;
        end;
    end;

    procedure UpdateFormulaComponent(
        var FormulaTransactionValue: Record "Tax Transaction Value" temporary;
        var Symbols: Record "Script Symbol Value" temporary;
        CurrencyCode: Code[20];
        CurrencyFactor: Decimal)
    var
        TaxComponent: Record "Tax Component";
        TaxRateComputation: Codeunit "Tax Rate Computation";
        Value: Variant;
        ValueLCY: Variant;
    begin
        if FormulaTransactionValue."Value Type" <> FormulaTransactionValue."Value Type"::COMPONENT then
            exit;
        TaxComponent.Reset();
        TaxComponent.SetFilter("Tax Type", '%1|%2', FormulaTransactionValue."Tax Type", '');
        TaxComponent.SetRange(ID, FormulaTransactionValue."Value ID");
        TaxComponent.FindFirst();
        if TaxComponent."Component Type" = TaxComponent."Component Type"::Formula then begin
            SymbolStore.InitSymbolContext(FormulaTransactionValue."Tax Type", FormulaTransactionValue."Case ID");
            Symbols.Get("Symbol Type"::Component, TaxComponent.ID);
            SymbolStore.GetSymbolValue(Symbols, Value);
            FormulaTransactionValue.Amount := Value;

            Symbols.Get("Symbol Type"::"Component Amount (LCY)", TaxComponent.ID);
            SymbolStore.GetSymbolValue(Symbols, ValueLCY);

            FormulaTransactionValue."Amount (LCY)" := TaxRateComputation.RoundAmount(
                ValueLCY,
                TaxComponent."Rounding Precision",
                TaxComponent.Direction);
            FormulaTransactionValue.Modify();
        end;
    end;

    procedure FillTaxBuffer(TaxID: Guid; DimensionSetID: Integer; GenBusPostingGrp: Code[20]; GenProdPostingGrp: Code[20]; TaxRecordID: RecordId; TaxTransactionValue: Record "Tax Transaction Value"; CurrencyCode: Code[20]; CurrencyFactor: Decimal; GlAccNo: Code[20]; PostingImpact: Option; ReverseCharge: Boolean; ReversaleGlAcc: Code[20]; Quantity: Decimal; InvoiceQty: Decimal; PostedDocNo: Code[20]; PostedDocLineNo: Integer)
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.Get(TaxTransactionValue."Tax Type", TaxTransactionValue."Value ID");

        TempTaxPostingBuffer.Init();
        TempTaxPostingBuffer.Id := CreateGuid();
        TempTaxPostingBuffer."Tax Id" := TaxID;
        TempTaxPostingBuffer."Case ID" := TaxTransactionValue."Case ID";
        TempTaxPostingBuffer."Tax Type" := TaxTransactionValue."Tax Type";
        TempTaxPostingBuffer.Validate(TempTaxPostingBuffer."Account No.", GlAccNo);
        TempTaxPostingBuffer.Validate(TempTaxPostingBuffer."Gen. Bus. Posting Group", GenBusPostingGrp);
        TempTaxPostingBuffer.Validate(TempTaxPostingBuffer."Gen. Prod. Posting Group", GenProdPostingGrp);
        TempTaxPostingBuffer.Validate(TempTaxPostingBuffer."Component ID", TaxTransactionValue."Value ID");
        TempTaxPostingBuffer."Dimension Set ID" := DimensionSetID;
        TempTaxPostingBuffer."Currency Code" := CurrencyCode;
        TempTaxPostingBuffer."Currency Factor" := CurrencyFactor;
        TempTaxPostingBuffer."Tax Record ID" := TaxRecordID;
        TempTaxPostingBuffer."Skip Posting" := TaxComponent."Skip Posting";
        TempTaxPostingBuffer."Posted Document No." := PostedDocNo;
        TempTaxPostingBuffer."Posted Document Line No." := PostedDocLineNo;
        TempTaxPostingBuffer."Reverse Charge" := ReverseCharge;
        TempTaxPostingBuffer."Reverse Charge G/L Account" := ReversaleGlAcc;
        if PostingImpact = 0 then begin
            TempTaxPostingBuffer.Amount := TaxTransactionValue.Amount;
            TempTaxPostingBuffer."Amount (LCY)" := TaxTransactionValue."Amount (LCY)";
        end else begin
            TempTaxPostingBuffer.Amount := -TaxTransactionValue.Amount;
            TempTaxPostingBuffer."Amount (LCY)" := -TaxTransactionValue."Amount (LCY)";
        end;
        if not TaxComponent."Skip Posting" then
            TotalTaxAmount += TempTaxPostingBuffer.Amount;
        TempTaxPostingBuffer.Insert();
        FillGroupedTaxBuffer(TempTaxPostingBuffer, Quantity, InvoiceQty);
    end;

    procedure FillGroupedTaxBuffer(
        TempTaxPostingBuffer: Record "Transaction Posting Buffer" temporary;
        Quantity: Decimal;
        InvoiceQty: Decimal)
    begin
        TempGroupTaxPostingBuffer.Reset();
        TempGroupTaxPostingBuffer.SetRange("Tax Id", TempTaxPostingBuffer."Tax Id");
        TempGroupTaxPostingBuffer.SetRange("Tax Type", TempTaxPostingBuffer."Tax Type");
        TempGroupTaxPostingBuffer.SetRange("Posted Document No.", TempTaxPostingBuffer."Posted Document No.");
        TempGroupTaxPostingBuffer.SetRange("Account No.", TempTaxPostingBuffer."Account No.");
        TempGroupTaxPostingBuffer.SetRange("Gen. Bus. Posting Group", TempTaxPostingBuffer."Gen. Bus. Posting Group");
        TempGroupTaxPostingBuffer.SetRange("Gen. Prod. Posting Group", TempTaxPostingBuffer."Gen. Prod. Posting Group");
        TempGroupTaxPostingBuffer.SetRange("Component ID", TempTaxPostingBuffer."Component ID");
        TempGroupTaxPostingBuffer.SetRange("Dimension Set ID", TempTaxPostingBuffer."Dimension Set ID");
        if not TempGroupTaxPostingBuffer.FindFirst() then begin
            TempGroupTaxPostingBuffer := TempTaxPostingBuffer;
            TempGroupTaxPostingBuffer."Group ID" := CreateGuid();
            TempGroupTaxPostingBuffer.Insert();
            TransferTransactionValue(
                TempGroupTaxPostingBuffer."Group ID",
                TempTaxPostingBuffer,
                Quantity,
                InvoiceQty);
        end else begin
            TempGroupTaxPostingBuffer.Amount += TempTaxPostingBuffer.Amount;
            TempGroupTaxPostingBuffer."Amount (LCY)" += TempTaxPostingBuffer."Amount (LCY)";
            TempGroupTaxPostingBuffer.Modify();
            TransferTransactionValue(
                TempGroupTaxPostingBuffer."Group ID",
                TempTaxPostingBuffer,
                Quantity,
                InvoiceQty);
        end;

    end;

    procedure GetGroupTaxJournal(TaxID: Guid; var TempGroupTaxPostingBuffer2: Record "Transaction Posting Buffer")
    begin
        TempGroupTaxPostingBuffer2.Reset();
        TempGroupTaxPostingBuffer2.DeleteAll();

        TempGroupTaxPostingBuffer.Reset();
        TempGroupTaxPostingBuffer.SetRange("Tax Id", TaxID);
        TempGroupTaxPostingBuffer.SetRange("Skip Posting", false);
        if TempGroupTaxPostingBuffer.FindSet() then
            repeat
                TempGroupTaxPostingBuffer2.Init();
                TempGroupTaxPostingBuffer2 := TempGroupTaxPostingBuffer;
                TempGroupTaxPostingBuffer2.Insert();
            until TempGroupTaxPostingBuffer.Next() = 0;
    end;

    procedure GetComponentTaxJournal(
        TaxID: Guid;
        var TempTaxPostingBuffer2: Record "Transaction Posting Buffer";
        RecID: RecordId)
    begin
        TempTaxPostingBuffer2.Reset();
        TempTaxPostingBuffer2.DeleteAll();

        TempTaxPostingBuffer.Reset();
        TempTaxPostingBuffer.SetRange("Tax Id", TaxID);
        TempTaxPostingBuffer.SetRange("Skip Posting", false);
        TempTaxPostingBuffer.SetRange("Tax Record ID", RecID);
        if TempTaxPostingBuffer.FindSet() then
            repeat
                TempTaxPostingBuffer2.Init();
                TempTaxPostingBuffer2 := TempTaxPostingBuffer;
                TempTaxPostingBuffer2.Insert();
            until TempTaxPostingBuffer.Next() = 0;
    end;

    procedure GetTaxAmount(TaxID: Guid): Decimal
    begin
        TempGroupTaxPostingBuffer.Reset();
        TempGroupTaxPostingBuffer.SetRange("Tax Id", TaxID);
        TempGroupTaxPostingBuffer.SetRange("Skip Posting", false);
        TempGroupTaxPostingBuffer.SetRange("Reverse Charge", false);
        if not TempGroupTaxPostingBuffer.IsEmpty() then begin
            TempGroupTaxPostingBuffer.CalcSums("Amount (LCY)");
            exit(TempGroupTaxPostingBuffer."Amount (LCY)");
        end;

        exit(0);
    end;

    local procedure TransferTransactionValue(
        GroupID: Guid;
        TempTaxPostingBuffer: Record "Transaction Posting Buffer" temporary;
        Quantity: Decimal;
        InvoiceQty: Decimal)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        NextID: Integer;
    begin
        TempTransactionValue.Reset();
        NextID := TempTransactionValue.Count();

        TaxTransactionValue.SetRange("Tax Record ID", TempTaxPostingBuffer."Tax Record ID");
        TaxTransactionValue.SetRange("Case ID", TempTaxPostingBuffer."Case ID");
        if TaxTransactionValue.FindSet() then
            repeat
                NextID += 1;
                TempTransactionValue := TaxTransactionValue;
                TempTransactionValue."Case ID" := GroupID;
                TempTransactionValue.ID := NextID;
                if TaxTransactionValue."Value Type" = TaxTransactionValue."Value Type"::COMPONENT then
                    DivideComponentAmount(
                        TempTransactionValue,
                        Quantity,
                        InvoiceQty,
                        TempTaxPostingBuffer."Currency Code",
                        TempTaxPostingBuffer."Currency Factor");

                TempTransactionValue.Insert();
            until TaxTransactionValue.Next() = 0;
    end;

    procedure DivideComponentAmount(
        var TaxTransactionValue: Record "Tax Transaction Value";
        Quantity: Decimal;
        InvoiceQty: Decimal;
        CurrencyCode: Code[20];
        CurrencyFactor: Decimal)
    var
        TaxComponent: Record "Tax Component";
        TaxRateComputation: Codeunit "Tax Rate Computation";
    begin
        TaxComponent.get(TaxTransactionValue."Tax Type", TaxTransactionValue."Value ID");

        TaxTransactionValue."Amount (LCY)" := (TaxTransactionValue."Amount (LCY)" / Quantity) * InvoiceQty;
        TaxTransactionValue."Amount (LCY)" := TaxRateComputation.RoundAmount(TaxTransactionValue."Amount (LCY)", TaxComponent."Rounding Precision", TaxComponent.Direction);

        if CurrencyCode = '' then
            TaxTransactionValue.Amount := TaxTransactionValue."Amount (LCY)"
        else
            TaxTransactionValue.Amount := TaxTransactionValue."Amount (LCY)" * CurrencyFactor;
    end;

    procedure GetTransactionValues(GroupID: Guid; var TempTransactionValues2: Record "Tax Transaction Value" temporary)
    begin
        TempTransactionValues2.Reset();
        TempTransactionValues2.DeleteAll();

        TempTransactionValue.Reset();
        TempTransactionValue.FilterGroup(4);
        TempTransactionValue.SetRange("Case ID", GroupID);
        TempTransactionValue.FilterGroup(0);
        if TempTransactionValue.FindSet() then
            repeat
                TempTransactionValues2.Init();
                TempTransactionValues2 := TempTransactionValue;
                TempTransactionValues2.Insert();
            until TempTransactionValue.Next() = 0;
    end;

    procedure ClearPostingInstance()
    begin
        ClearAll();

        TempTaxPostingBuffer.Reset();
        if not TempTaxPostingBuffer.IsEmpty() then
            TempTaxPostingBuffer.DeleteAll();

        TempGroupTaxPostingBuffer.Reset();
        if not TempGroupTaxPostingBuffer.IsEmpty() then
            TempGroupTaxPostingBuffer.DeleteAll();

        TempTransactionValue.Reset();
        if not TempTransactionValue.IsEmpty() then
            TempTransactionValue.DeleteAll();
    end;

    procedure ClearNonGlComponents(TaxID: Guid)
    begin
        TempGroupTaxPostingBuffer.SetRange("Tax Id", TaxID);
        if not TempGroupTaxPostingBuffer.IsEmpty() then
            TempGroupTaxPostingBuffer.DeleteAll();
    end;

    procedure ClearGroupingBuffers(TempTransPostingBuffer: Record "Transaction Posting Buffer"; Transactionvalue: Record "Tax Transaction Value")
    begin
        TempTransactionValue.SetRange("Case ID", Transactionvalue."Case ID");
        if not TempTransactionValue.IsEmpty() then
            TempTransactionValue.DeleteAll();

        TempGroupTaxPostingBuffer.Get(TempTransPostingBuffer.Id);
        TempGroupTaxPostingBuffer.Delete();
    end;

    procedure ClearLineBuffers(TaxID: Guid)
    begin
        TempTaxPostingBuffer.Reset();
        TempTaxPostingBuffer.SetRange("Tax Id", TaxID);
        if not TempTaxPostingBuffer.IsEmpty() then
            TempTaxPostingBuffer.DeleteAll();
    end;

    procedure CreateTaxID()
    begin
        TransactionTaxID := CreateGuid();
    end;

    procedure GetTaxID(): Guid
    begin
        exit(TransactionTaxID);
    end;

    procedure GetTotalTaxAmount(): Decimal
    begin
        exit(Abs(TotalTaxAmount));
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSetColumnDefaultValue(RecID: RecordId; TaxTypeCode: Code[20]; var Symbols: Record "Script Symbol Value" temporary; TaxRateColumnSetup: Record "Tax Rate Column Setup"; var Value: Variant)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSetAttribtueDefaultValue(RecID: RecordId; TaxTypeCode: Code[20]; var Symbols: Record "Script Symbol Value" temporary; TaxAttribute: Record "Tax Attribute"; var Value: Variant)
    begin
    end;

    var
        TempTaxPostingBuffer: Record "Transaction Posting Buffer" temporary;
        TempGroupTaxPostingBuffer: Record "Transaction Posting Buffer" temporary;
        TempTransactionValue: Record "Tax Transaction Value" temporary;
        SymbolStore: Codeunit "Script Symbol Store";
        DataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
        TransactionTaxID: Guid;
        PostingDocument: Variant;
        TotalTaxAmount: Decimal;
        SalesPurchLcyAmount: Decimal;
}