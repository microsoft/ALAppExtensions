codeunit 20345 "Tax Posting Handler"
{
    procedure GetCurrency(CurrencyCode: Code[10]; var Currency: Record Currency)
    begin
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    [EventSubscriber(ObjectType::Page, page::"Switch Statements", 'OnMappingAssitEdit', '', false, false)]
    local procedure OnMappingAssitEdit(var SwitchCase: Record "Switch Case")
    var
        UseCase: Record "Tax Use Case";
    begin
        UseCase.Get(SwitchCase."Case ID");
        if SwitchCase."Action Type" = SwitchCase."Action Type"::"Insert Record" then begin
            if IsNullGuid(SwitchCase."Action ID") then begin
                SwitchCase."Action ID" := TaxPostingHelper.CreateInsertRecord(
                    SwitchCase."Case ID",
                    UseCase."Posting Script ID");
                Commit();
            end;

            TaxPostingHelper.OpenInsertRecordDialog(
                SwitchCase."Case ID",
                UseCase."Posting Script ID",
                SwitchCase."Action ID");
        end;
    end;

    [EventSubscriber(ObjectType::Page, page::"Switch Statements", 'OnSwitchCaseFormat', '', false, false)]
    local procedure OnSwitchCaseFormat(var LookupValue: Text; SwitchCase: Record "Switch Case")
    var
        UseCase: Record "Tax Use Case";
    begin
        if SwitchCase."Action Type" = SwitchCase."Action Type"::"Insert Record" then begin
            UseCase.Get(SwitchCase."Case ID");
            LookupValue := TaxPostingHelper.InsertRecordToString(
                SwitchCase."Case ID",
                UseCase."Posting Script ID",
                SwitchCase."Action ID");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Switch Case", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeSwitchCaseDeleteEvent(var Rec: Record "Switch Case")
    var
        UseCase: Record "Tax Use Case";
        CompanyInformation: Record "Company Information";
    begin
        if Rec.IsTemporary() then
            exit;

        if not CompanyInformation.get() then
            exit;

        if (not IsNullGuid(Rec."Action ID")) and (Rec."Action Type" = Rec."Action Type"::"Insert Record") then begin
            UseCase.Get(Rec."Case ID");
            TaxPostingHelper.DeleteInsertRecord(Rec."Case ID", UseCase."Posting Script ID", Rec."Action ID");
        end;
    end;

    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Script Symbols Mgmt.",
        'OnInitScriptSymbols',
        '',
        false,
        false)]
    procedure OnInitScriptSymbols(
        var sender: Codeunit "Script Symbols Mgmt.";
        TaxType: Code[20];
        ScriptID: Guid;
        var Symbols: Record "Script Symbol" temporary);
    begin
        sender.InsertScriptSymbol(
            "Symbol Type"::"Posting Field",
            "Posting Field Symbol"::"Gen. Bus. Posting Group".AsInteger(),
            'Gen. Bus. Posting Group',
            "Symbol Data Type"::STRING);

        sender.InsertScriptSymbol(
            "Symbol Type"::"Posting Field",
            "Posting Field Symbol"::"Gen. Prod. Posting Group".AsInteger(),
            'Gen. Prod. Posting Group',
            "Symbol Data Type"::STRING);

        sender.InsertScriptSymbol(
            "Symbol Type"::"Posting Field",
            "Posting Field Symbol"::"Dimension Set ID".AsInteger(),
            'Dimension Set ID',
            "Symbol Data Type"::NUMBER);

        sender.InsertScriptSymbol(
            "Symbol Type"::"Posting Field",
            "Posting Field Symbol"::"Posted Document No.".AsInteger(),
            'Posted Document No.',
            "Symbol Data Type"::STRING);

        sender.InsertScriptSymbol(
            "Symbol Type"::"Posting Field",
            "Posting Field Symbol"::"Posted Document Line No.".AsInteger(),
            'Posted Document Line No.',
            "Symbol Data Type"::NUMBER);

        sender.InsertScriptSymbol(
            "Symbol Type"::"Posting Field",
            "Posting Field Symbol"::"G/L Entry No.".AsInteger(),
            'G/L Entry No.',
            "Symbol Data Type"::NUMBER);

        sender.InsertScriptSymbol(
            "Symbol Type"::"Posting Field",
            "Posting Field Symbol"::"G/L Entry Transaction No.".AsInteger(),
            'G/L Entry Transaction No.',
            "Symbol Data Type"::NUMBER);
    end;

    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Script Symbol Store",
        'OnInitSymbols',
        '',
        false,
        false)]
    local procedure OnInitSymbols(
        sender: Codeunit "Script Symbol Store";
        CaseID: Guid;
        ScriptID: Guid;
        var Symbols: Record "Script Symbol Value")
    begin
        InitTaxPostingFields(sender, Symbols);
    end;

    local procedure InitTaxPostingFields(
        sender: Codeunit "Script Symbol Store";
        var Symbols: Record "Script Symbol Value");
    var
        PostingFields: Enum "Posting Field Symbol";
    begin
        InsertTaxPostingField(sender, PostingFields::"Gen. Bus. Posting Group", Symbols, "Symbol Data Type"::STRING);
        InsertTaxPostingField(sender, PostingFields::"Gen. Prod. Posting Group", Symbols, "Symbol Data Type"::STRING);
        InsertTaxPostingField(sender, PostingFields::"Dimension Set ID", Symbols, "Symbol Data Type"::NUMBER);
        InsertTaxPostingField(sender, PostingFields::"G/L Entry No.", Symbols, "Symbol Data Type"::NUMBER);
        InsertTaxPostingField(sender, PostingFields::"G/L Entry Transaction No.", Symbols, "Symbol Data Type"::NUMBER);
        InsertTaxPostingField(sender, PostingFields::"Posted Document No.", Symbols, "Symbol Data Type"::STRING);
        InsertTaxPostingField(sender, PostingFields::"Posted Document Line No.", Symbols, "Symbol Data Type"::NUMBER);
    end;

    local procedure InsertTaxPostingField(
        sender: Codeunit "Script Symbol Store";
        ID: Enum "Posting Field Symbol";
        var Symbols: Record "Script Symbol Value" Temporary;
        Datatype: Enum "Symbol Data Type")
    var
        Value: Variant;
    begin
        Symbols.SetRange("Symbol ID", ID);
        Symbols.SetRange(Type, Symbols.Type::"Posting Field");
        if Symbols.FindFirst() then begin
            sender.GetSymbolValue(Symbols, Value);
            sender.InsertSymbolValue("Symbol Type"::"Posting Field", Datatype, ID.AsInteger(), Value);
        end else
            sender.InsertSymbolValue("Symbol Type"::"Posting Field", Datatype, ID.AsInteger());
    end;

    [EventSubscriber(ObjectType::Page, Page::"Script Symbol Lookup Dialog", 'OnIsSourceTypeSymbolType', '', false, false)]
    local procedure OnIsSourceTypeSymbolType(
        SymbolType: Enum "Symbol Type";
        var IsHandled: Boolean;
        var IsSymbol: Boolean)
    begin
        case SymbolType of
            SymbolType::"Posting Field":
                begin
                    IsHandled := true;
                    IsSymbol := true;
                end;
        end;
    end;

    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Script Symbol Store",
        'OnGetLookupValue',
        '',
        false,
        false)]
    local procedure OnGetLookupValue(
        sender: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        var IsHandled: Boolean; var Value: Variant)
    begin
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::"Posting Field":
                begin
                    sender.GetSymbolOfType(
                        ScriptSymbolLookup."Source Type",
                        ScriptSymbolLookup."Source Field ID",
                        Value);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Use Case", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteTaxUseCase(var Rec: Record "Tax Use Case")
    var
        TaxPostingSetup: Record "Tax Posting Setup";
        ActionContainer: Record "Action Container";
        ScriptVariable: Record "Script Variable";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
    begin
        if Rec.IsTemporary() then
            exit;

        ScriptVariable.Reset();
        ScriptVariable.SetRange("Script ID", Rec."Posting Script ID");
        if not ScriptVariable.IsEmpty() then
            ScriptVariable.DeleteAll(true);

        if not IsNullGuid(Rec."Posting Script ID") then begin
            ActionContainer.SetRange("Script ID", Rec."Posting Script ID");
            ActionContainer.SetRange("Container Type", "Container Action Type"::USECASE);
            ActionContainer.SetRange("Container Action ID", Rec.ID);
            if not ActionContainer.IsEmpty() then
                ActionContainer.DeleteAll(true);
        end;

        if not IsNullGuid(Rec."Posting Table Filter ID") then
            LookupEntityMgmt.DeleteTableFilters(Rec.ID, EmptyGuid, Rec."Posting Table Filter ID");

        TaxPostingSetup.SetRange("Case ID", Rec.ID);
        if not TaxPostingSetup.IsEmpty() then
            TaxPostingSetup.DeleteAll(true);

        ScriptSymbolLookup.SetRange("Case ID", Rec.ID);
        ScriptSymbolLookup.SetRange("Script ID", Rec."Posting Script ID");
        if not ScriptSymbolLookup.IsEmpty() then
            ScriptSymbolLookup.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Use Case", 'OnAfterValidateEvent', 'Posting Table ID', false, false)]
    local procedure OnAfterValidatePostingTableID(var Rec: Record "Tax Use Case"; var xRec: Record "Tax Use Case")
    var
        TaxPostingSetup: Record "Tax Posting Setup";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        PostingTableNameChangedErr: Label 'You have to delete related Tax posting setup lines before changing Posting Table';
    begin
        if (xRec."Posting Table ID" = 0) then
            exit;

        if xRec."Posting Table ID" <> Rec."Posting Table ID" then begin
            TaxPostingSetup.SetRange("Case ID", Rec.ID);
            if not TaxPostingSetup.IsEmpty() then
                Error(PostingTableNameChangedErr);

            if not IsNullGuid(Rec."Posting Table Filter ID") then
                LookupEntityMgmt.DeleteTableFilters(Rec.ID, EmptyGuid, Rec."Posting Table Filter ID");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Mgmt.", 'OnAfterOpenPostingSetup', '', false, false)]
    local procedure OnAfterOpenPostingSetup(var TaxUseCase: Record "Tax Use Case")
    begin
        Page.Run(Page::"Use Case Posting", TaxUseCase);
    end;

    var
        TaxPostingHelper: Codeunit "Tax Posting Helper";
        EmptyGuid: Guid;
}