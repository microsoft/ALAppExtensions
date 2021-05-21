codeunit 20133 "Script Symbols Mgmt."
{
    procedure SearchSymbol(SymbolType: Enum "Symbol Type"; var ID: Integer; var Name: Text[30]);
    var
        InvalidSymbolValueErr: Label 'You cannot enter ''%1'' in %2.', Comment = '%1 = Symbol Name, %2 = Symbol Type';
    begin
        if Name = '' then begin
            ID := 0;
            Exit;
        end;

        InitScriptSymbols();

        TempSymbols.Reset();
        TempSymbols.FilterGroup := 2;
        TempSymbols.SetRange(Type, SymbolType);
        TempSymbols.FilterGroup := 0;
        TempSymbols.SetCurrentKey(Name);
        TempSymbols.SetFilter(Name, '%1', '@' + Name + '*');
        if TempSymbols.FindFirst() then begin
            ID := TempSymbols.ID;
            Name := TempSymbols.Name;
        end else
            Error(InvalidSymbolValueErr, Name, SymbolType);
    end;

    procedure GetSymbolInfo(
        SymbolType: Enum "Symbol Type";
        ID: Integer;
        var Name: Text[30];
        var Datatype: Enum "Symbol Data Type");
    begin
        InitScriptSymbols();
        TempSymbols.GET(SymbolType, ID);
        Name := TempSymbols.Name;
        Datatype := TempSymbols.Datatype;
    end;

    procedure GetSymbolDataType(SymbolType: Enum "Symbol Type"; ID: Integer): Enum "Symbol Data Type";
    begin
        if ID = 0 then
            exit;
        InitScriptSymbols();
        TempSymbols.GET(SymbolType, ID);
        exit(TempSymbols.Datatype);
    end;

    procedure GetSymbolName(SymbolType: Enum "Symbol Type"; ID: Integer): Text[30];
    begin
        if ID = 0 then
            exit('');

        InitScriptSymbols();

        TempSymbols.Reset();
        TempSymbols.FilterGroup := 2;
        TempSymbols.SetRange(Type, SymbolType);
        TempSymbols.FilterGroup := 0;
        TempSymbols.SetRange(ID, ID);
        if TempSymbols.FindFirst() then
            exit(TempSymbols.Name);

        if UseStrictMode then
            Error(SymbolIDNotFoundErr, SymbolType, ID);
        exit('');
    end;

    procedure GetSymbolFormulaID(SymbolType: Enum "Symbol Type"; ID: Integer): Guid
    var
        CanHaveFormula: Boolean;
    begin
        if SymbolType in [
            SymbolType::"Current Record",
            SymbolType::Database,
            SymbolType::"Record Variable",
            SymbolType::System,
            SymbolType::Table]
        then
            exit;

        CanHaveFormula := true;
        OnBeforeGetFormulaID(SymbolType, Id, CanHaveFormula);
        if not CanHaveFormula then
            exit;

        InitScriptSymbols();

        TempSymbols.Reset();
        TempSymbols.FilterGroup := 2;
        TempSymbols.SetRange(Type, SymbolType);
        TempSymbols.FilterGroup := 0;
        TempSymbols.SetRange(ID, ID);
        TempSymbols.SetRange("Value Type", TempSymbols."Value Type"::Formula);
        if TempSymbols.FindFirst() then
            exit(TempSymbols."Formula ID");
    end;

    procedure InsertScriptSymbol(
        SymbolType: Enum "Symbol Type";
        ID: Integer;
        Name: Text[30];
        Datatype: enum "Symbol Data Type");
    begin
        TempSymbols.Init();
        TempSymbols.Type := SymbolType;
        TempSymbols.ID := ID;
        TempSymbols.Name := Name;
        TempSymbols.Datatype := Datatype;
        TempSymbols.Insert();
    end;

    procedure InsertScriptSymbol(
          SymbolType: Enum "Symbol Type";
          ID: Integer;
          Name: Text[30];
          Datatype: enum "Symbol Data Type";
          FormaulID: Guid);
    begin
        TempSymbols.Init();
        TempSymbols.Type := SymbolType;
        TempSymbols.ID := ID;
        TempSymbols.Name := Name;
        TempSymbols.Datatype := Datatype;
        if not IsNullGuid(FormaulID) then
            TempSymbols."Value Type" := TempSymbols."Value Type"::Formula;
        TempSymbols."Formula ID" := FormaulID;
        TempSymbols.Insert();
    end;

    procedure SetContext(NewTaxType: Code[20]; NewCaseID: Guid; NewScriptID: Guid);
    var
        ResetContext: Boolean;
    begin
        ContextInitilized := true;

        if (TaxType <> NewTaxType) then begin
            TaxType := NewTaxType;
            ResetContext := true;
        end else
            if (ScriptID <> NewScriptID) then
                ResetContext := true;

        if (ResetContext) then begin
            CaseID := NewCaseID;
            ScriptID := NewScriptID;

            TempSymbols.Reset();
            TempSymbols.DeleteAll();

            SymbolsInitilized := false;
            InitScriptSymbols();
            TempSymbols.Reset();
        end;
    end;

    procedure SetContext(NewCaseID: Guid; NewScriptID: Guid);
    var
        NewTaxType: Code[20];
        BlankTaxTypeErr: Label 'Tax Type cannot be blank.';
        UseCaseNotFoundErr: Label 'Use Case %1 not found.', Comment = '%1 = Case ID';
        BlankTaxTypeOnUseCaseErr: Label 'Tax Type in Use Case ID %1 should not be blank.', Comment = '%1 = Case ID';
        Handled: Boolean;
        NotFound: Boolean;
    begin
        if IsNullGuid(NewCaseID) then
            exit;

        if (CaseID = NewCaseID) and (ScriptID = NewScriptID) then
            exit;

        OnGetTaxType(NewCaseID, NewTaxType, Handled, NotFound);

        if NewTaxType = '' then begin
            if Handled and NotFound then
                Error(UseCaseNotFoundErr, NewCaseID);

            if Handled and (not NotFound) then
                Error(BlankTaxTypeOnUseCaseErr, NewCaseID);

            Error(BlankTaxTypeErr);
        end;
        SetContext(NewTaxType, NewCaseID, NewScriptID);
    end;

    procedure GetSymbolID(SymbolType: Enum "Symbol Type"; Name: Text[30]): Integer
    begin
        if Name = '' then
            exit(0);

        InitScriptSymbols();

        TempSymbols.Reset();
        TempSymbols.FilterGroup := 2;
        TempSymbols.SetRange(Type, SymbolType);
        TempSymbols.FilterGroup := 0;
        TempSymbols.SetRange(Name, Name);
        if TempSymbols.FindFirst() then
            exit(TempSymbols.ID);

        if UseStrictMode then
            Error(SymbolNameNotFoundErr, SymbolType, Name);

        exit(0);
    end;

    procedure SearchSymbolOfType(
        SymbolType: Enum "Symbol Type";
        Datatype: Enum "Symbol Data Type";
        var ID: Integer;
        var Name: Text[30]);
    var
        InvalidSymbolValueErr: Label 'You cannot enter ''%1'' in %2.', Comment = '%1 = Symbol Name, %2= Symbol Type';
    begin
        InitScriptSymbols();

        TempSymbols.Reset();
        TempSymbols.FilterGroup := 2;
        TempSymbols.SetRange(Type, SymbolType);

        case Datatype of
            "Symbol Data Type"::String:
                TempSymbols.SetFilter(Datatype, '%1', "Symbol Data Type"::String);
            "Symbol Data Type"::Option,
            "Symbol Data Type"::Number:
                TempSymbols.SetFilter(Datatype, '%1|%2', "Symbol Data Type"::Number, "Symbol Data Type"::Option);
            "Symbol Data Type"::Recid:
                TempSymbols.SetFilter(Datatype, '%1|%2', "Symbol Data Type"::Recid, "Symbol Data Type"::String);
            else
                TempSymbols.SetRange(Datatype, Datatype);
        end;

        TempSymbols.FilterGroup := 0;

        TempSymbols.SetFilter(Name, '%1', '@' + Name + '*');
        if TempSymbols.FindFirst() then begin
            ID := TempSymbols.ID;
            Name := TempSymbols.Name;
        end else
            Error(InvalidSymbolValueErr, Name, SymbolType);
    end;

    procedure OpenSymbolsLookup(
        SymbolType: Enum "Symbol Type";
        SearchText: Text;
        var ID: Integer;
        var Name: Text[30]);
    begin
        InitScriptSymbols();

        TempSymbols.Reset();
        TempSymbols.FilterGroup := 2;
        TempSymbols.SetRange(Type, SymbolType);
        TempSymbols.FilterGroup := 0;

        if ID <> 0 then begin
            TempSymbols.ID := ID;
            TempSymbols.Find('=<>');
        end else
            if SearchText <> '' then begin
                TempSymbols.Name := CopyStr(SearchText, 1, 30);
                TempSymbols.Find('=<>');
            end;

        if Page.RunModal(Page::"Script Symbols", TempSymbols) = ACTION::LookupOK then begin
            ID := TempSymbols.ID;
            Name := TempSymbols.Name;
        end;
    end;

    procedure OpenSymbolsLookupOfType(
        SymbolType: Enum "Symbol Type";
        SearchText: Text;
        Datatype: Enum "Symbol Data Type";
        var ID: Integer;
        var Name: Text[30]);
    begin
        InitScriptSymbols();

        TempSymbols.Reset();
        TempSymbols.FilterGroup := 2;
        TempSymbols.SetRange(Type, SymbolType);

        case Datatype of
            "Symbol Data Type"::String:
                TempSymbols.SetRange(Datatype, "Symbol Data Type"::String);
            "Symbol Data Type"::Option,
            "Symbol Data Type"::Number:
                TempSymbols.SetFilter(Datatype, '%1|%2', "Symbol Data Type"::Number, "Symbol Data Type"::Option);
            "Symbol Data Type"::Recid:
                TempSymbols.SetFilter(Datatype, '%1|%2', "Symbol Data Type"::Recid, "Symbol Data Type"::String);
            else
                TempSymbols.SetRange(Datatype, Datatype);
        end;

        TempSymbols.FilterGroup := 0;

        if ID <> 0 then begin
            TempSymbols.ID := ID;
            TempSymbols.Find('<>=');
        end else
            if SearchText <> '' then begin
                TempSymbols.Name := CopyStr(SearchText, 1, 30);
                TempSymbols.Find('<>=');
            end;

        if Page.RunModal(Page::"Script Symbols", TempSymbols) = ACTION::LookupOK then begin
            ID := TempSymbols.ID;
            Name := TempSymbols.Name;
        end;
    end;

    procedure UseStrict()
    begin
        UseStrictMode := true;
    end;

    local procedure InsertDatabaseSymbol(
        SymbolType: Enum "Symbol Type";
        ID: Enum "Database Symbol";
        Name: Text[30];
        Datatype: enum "Symbol Data Type");
    var
        DatabaseSymbolID: Integer;
    begin
        DatabaseSymbolID := ID.AsInteger();
        InsertScriptSymbol(SymbolType, DatabaseSymbolID, Name, Datatype);
    end;

    local procedure InsertSystemSymbol(
            SymbolType: Enum "Symbol Type";
            ID: Enum "System Symbol";
            Name: Text[30];
            Datatype: enum "Symbol Data Type");
    var
        SystemSymbolID: Integer;
    begin
        SystemSymbolID := ID.AsInteger();
        InsertScriptSymbol(SymbolType, SystemSymbolID, Name, Datatype);
    end;

    //[NonDebuggable]
    local procedure InitScriptSymbols();
    var
        ScriptContextNotInitializedErr: Label 'Script context not updated';
    begin
        if SymbolsInitilized then
            Exit;

        if not ContextInitilized then
            Error(ScriptContextNotInitializedErr);

        InsertDatabaseSymbol("Symbol Type"::Database, "Database Symbol"::UserId, 'UserId', "Symbol Data Type"::String);
        InsertDatabaseSymbol("Symbol Type"::Database, "Database Symbol"::COMPANYNAME, 'COMPANYNAME', "Symbol Data Type"::String);
        InsertDatabaseSymbol("Symbol Type"::Database, "Database Symbol"::SERIALNUMBER, 'SERIALNUMBER', "Symbol Data Type"::String);
        InsertDatabaseSymbol("Symbol Type"::Database, "Database Symbol"::TENANTID, 'TENANTID', "Symbol Data Type"::String);
        InsertDatabaseSymbol("Symbol Type"::Database, "Database Symbol"::SESSIONID, 'SESSIONID', "Symbol Data Type"::String);
        InsertDatabaseSymbol("Symbol Type"::Database, "Database Symbol"::SERVICEINSTANCEID, 'SERVICEINSTANCEID', "Symbol Data Type"::String);

        InsertSystemSymbol("Symbol Type"::System, "System Symbol"::Today, 'Today', "Symbol Data Type"::Date);
        InsertSystemSymbol("Symbol Type"::System, "System Symbol"::TIME, 'TIME', "Symbol Data Type"::Time);
        InsertSystemSymbol("Symbol Type"::System, "System Symbol"::WorkDate, 'WorkDate', "Symbol Data Type"::Date);
        InsertSystemSymbol("Symbol Type"::System, "System Symbol"::CURRENTDATETIME, 'CURRENTDATETIME', "Symbol Data Type"::Datetime);

        OnInitScriptSymbols(TaxType, CaseID, ScriptID, TempSymbols);
        SymbolsInitilized := true;
    end;

    [IntegrationEvent(true, false)]
    procedure OnInitScriptSymbols(TaxType: Code[20]; CaseID: Guid; ScriptID: Guid; var Symbols: Record "Script Symbol" temporary);
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnGetTaxType(CaseID: Guid; var TaxType: Code[20]; var Handled: Boolean; var NotFound: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeGetFormulaID(SymbolType: Enum "Symbol Type"; ID: Integer; var CanHaveFormulaID: Boolean)
    begin
    end;

    var
        TempSymbols: Record "Script Symbol" Temporary;
        CaseID: Guid;
        ScriptID: Guid;
        TaxType: Code[20];
        SymbolsInitilized: Boolean;
        ContextInitilized: Boolean;
        UseStrictMode: Boolean;
        SymbolNameNotFoundErr: Label 'Symbol Name does not exist for %1 %2.', Comment = '%1 = Symbol Type, %2= Symbol Name';
        SymbolIDNotFoundErr: Label 'Symbol ID does not exist for %1 %2.', Comment = '%1 = Symbol Type, %2= Symbol ID';
}