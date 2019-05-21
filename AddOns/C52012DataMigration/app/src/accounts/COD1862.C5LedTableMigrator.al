// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1862 "C5 LedTable Migrator"
{
    TableNo = "C5 LedTable";
    SingleInstance = true;

    var
        MaxAccountLength: Integer;

    procedure FillWithLeadingZeros(Value: Text): Code[20]
    var
        MaxLength: Integer;
        VarInteger: Integer;
    begin
        if Evaluate(VarInteger, Value) then begin
            if MaxAccountLength = 0 then
                MaxAccountLength := FindMaxAccountLength();
            MaxLength := MaxAccountLength;

            exit(PADSTR('', MaxLength - StrLen(Value), '0') + Value);
        end else
            exit(CopyStr(Value, 1, 20));
    end;

    procedure RemoveLeadingZeroes(Value: Text): Text
    var
        Result: Text;
    begin
        Result := Value;

        while ((StrLen(Result) <> 1) and (CopyStr(Result, 1, 1) = '0')) do
            Result := CopyStr(Result, 2, StrLen(Result));

        exit(Result);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateGlAccount', '', true, true)]
    procedure OnMigrateGlAccount(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        C5LedTable: Record "C5 LedTable";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"C5 LedTable" then
            exit;
        C5LedTable.Get(RecordIdToMigrate);
        MigrateLedgerDetails(C5LedTable, Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateGlAccountDimensions', '', true, true)]
    procedure OnMigrateGlAccountDimensions(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        C5LedTable: Record "C5 LedTable";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"C5 LedTable" then
            exit;

        C5LedTable.Get(RecordIdToMigrate);
        if C5LedTable.Department <> '' then
            Sender.CreateDefaultDimensionAndRequirementsIfNeeded(
                C5HelperFunctions.GetDepartmentDimensionCodeTxt(),
                C5HelperFunctions.GetDepartmentDimensionDescTxt(),
                C5LedTable.Department,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Department", C5LedTable.Department));
        if C5LedTable.Centre <> '' then
            Sender.CreateDefaultDimensionAndRequirementsIfNeeded(
                C5HelperFunctions.GetCostCenterDimensionCodeTxt(),
                C5HelperFunctions.GetCostCenterDimensionDescTxt(),
                C5LedTable.Centre,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Centre", C5LedTable.Centre));
        if C5LedTable.Purpose <> '' then
            Sender.CreateDefaultDimensionAndRequirementsIfNeeded(
                C5HelperFunctions.GetPurposeDimensionCodeTxt(),
                C5HelperFunctions.GetPurposeDimensionDescTxt(),
                C5LedTable.Purpose,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Purpose", C5LedTable.Purpose));
    end;

    procedure MigrateLedgerDetails(C5LedTable: Record "C5 LedTable"; GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade")
    var
        GLAccountNoWithLeadingZeros: Text;
    begin
        // We are filling with leading zeros because NAV uses alphabetical sorting while c5 uses numerical and the sort order is important in the totalling field
        GLAccountNoWithLeadingZeros := FillWithLeadingZeros(C5LedTable.Account);

        if not GLAccDataMigrationFacade.CreateGLAccountIfNeeded(CopyStr(GLAccountNoWithLeadingZeros, 1, 20), C5LedTable.AccountName, ConvertAccountType(C5LedTable)) then
            exit;

        if C5LedTable.AccountType in [C5LedTable.AccountType::"Counter total", C5LedTable.AccountType::"Heading total"] then
            GLAccDataMigrationFacade.SetTotaling(BuildTotalingFilter(
              FillWithLeadingZeros(C5LedTable.TotalFromAccount), GLAccountNoWithLeadingZeros, C5LedTable.Counterunit, C5LedTable.AccountType));

        GLAccDataMigrationFacade.SetIncomeBalanceType(ConvertIncomeBalance(C5LedTable));
        GLAccDataMigrationFacade.SetDebitCreditType(ConvertDebitCreditType(C5LedTable));
        GLAccDataMigrationFacade.SetExchangeRateAdjustmentType(ConvertExchangeRateAdjutment(C5LedTable));
        GLAccDataMigrationFacade.SetDirectPosting(C5LedTable.Access <> C5LedTable.Access::System);
        GLAccDataMigrationFacade.SetBlocked(C5LedTable.Access = C5LedTable.Access::Locked);
        GLAccDataMigrationFacade.ModifyGLAccount(true);
    end;

    local procedure FindMaxAccountLength() Result: Integer
    var
        C5LedTable: Record "C5 LedTable";
        VarInteger: Integer;
    begin
        if C5LedTable.FindSet() then
            repeat
                if Evaluate(VarInteger, C5LedTable.Account) then
                    if StrLen(C5LedTable.Account) > Result then
                        Result := StrLen(C5LedTable.Account);
            until C5LedTable.Next() = 0;
    end;

    local procedure BuildTotalingFilter(AccountFrom: Text; AccountTo: Text; CounterTotal: Text; AccountType: Option): Text[250]
    var
        C5LedTable: Record "C5 LedTable";
        TotalingFilter: Text;
        NumberOfCounterTotals: Integer;
        Index: Integer;
    begin
        if (CounterTotal = '') or (AccountType = C5LedTable.AccountType::"Heading total") then
            exit(CopyStr(StrSubstNo('%1..%2', FillWithLeadingZeros(AccountFrom), AccountTo), 1, 250));

        if CounterTotal <> DelChr(CounterTotal, '=', '()-*/>') then
            exit('');

        CounterTotal := ConvertStr(CounterTotal, '+', ',');
        NumberOfCounterTotals := GetNumberOfOptions(CounterTotal);
        for Index := 1 to NumberOfCounterTotals do begin
            C5LedTable.SetRange(Counterunit, SelectStr(Index, CounterTotal));
            if C5LedTable.FindSet() then
                repeat
                    if C5LedTable.AccountType = C5LedTable.AccountType::"Heading total" then
                        TotalingFilter += StrSubstNo('%1..%2',
                          FillWithLeadingZeros(C5LedTable.TotalFromAccount),
                          FillWithLeadingZeros(C5LedTable.Account)) + '|'
                    else
                        if C5LedTable.AccountType <> C5LedTable.AccountType::"Counter total" then
                            TotalingFilter += FillWithLeadingZeros(C5LedTable.Account) + '|';
                until C5LedTable.Next() = 0;
        end;

        TotalingFilter := DelChr(TotalingFilter, '>', '|');
        exit(CopyStr(TotalingFilter, 1, 250));
    end;

    local procedure GetNumberOfOptions(OptionString: Text): Integer
    begin
        exit(StrLen(OptionString) - StrLen(DelChr(OptionString, '=', ',')) + 1);
    end;

    local procedure ConvertAccountType(C5LedTable: Record "C5 LedTable"): Option
    var
        AccountType: Option Posting,Heading,Total,"Begin-Total","End-Total";
    begin
        case C5LedTable.AccountType of
            C5LedTable.AccountType::"Balance a/c",
          C5LedTable.AccountType::"P/L a/c",
          C5LedTable.AccountType::Empty:
                exit(AccountType::Posting);

            C5LedTable.AccountType::"Counter total",
          C5LedTable.AccountType::"Heading total":
                exit(AccountType::Total);

            C5LedTable.AccountType::Heading,
          C5LedTable.AccountType::"New page":
                exit(AccountType::Heading);
        end;
    end;

    local procedure ConvertDebitCreditType(C5LedTable: Record "C5 LedTable"): Option
    var
        DebitCreditType: Option Both,Debit,Credit;
    begin
        case C5LedTable.DCproposal of
            C5LedTable.DCproposal::" ":
                exit(DebitCreditType::Both);

            C5LedTable.DCproposal::Credit:
                exit(DebitCreditType::Credit);

            C5LedTable.DCproposal::Debit:
                exit(DebitCreditType::Debit);
        end;
    end;

    local procedure ConvertIncomeBalance(C5LedTable: Record "C5 LedTable"): Option
    var
        IncomeBalanceType: Option "Income Statement","Balance Sheet";
    begin
        if C5LedTable.AccountType = C5LedTable.AccountType::"Balance a/c" then
            exit(IncomeBalanceType::"Balance Sheet")
        else
            exit(IncomeBalanceType::"Income Statement");
    end;

    local procedure ConvertExchangeRateAdjutment(C5LedTable: Record "C5 LedTable"): Option
    var
        ExchangeRateAdjustmentType: Option "No Adjustment","Adjust Amount","Adjust Additional-Currency Amount";
    begin
        if C5LedTable.ExchAdjust = C5LedTable.ExchAdjust::Yes then
            exit(ExchangeRateAdjustmentType::"Adjust Amount")
        else
            exit(ExchangeRateAdjustmentType::"No Adjustment");
    end;
}
