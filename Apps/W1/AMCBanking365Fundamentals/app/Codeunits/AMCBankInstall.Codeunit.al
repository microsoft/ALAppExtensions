codeunit 20116 "AMC Bank Install"
{
    Subtype = install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion() = Version.Create('0.0.0.0') then begin
            MoveBankAccountTableData();
            MoveBankDataConvPmtTypesTableData();
            MovePaymentMethodTableData();
            DeleteOldDataExchangeDefinitions();
            RemoveDataExchangeDefinitionReferences();
        end;
    end;

    local procedure MoveBankAccountTableData()
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccount.FindSet(true, false) then
            repeat
                BankAccount."AMC Bank Name" := BankAccount."Bank Name - Data Conversion";
                BankAccount.Modify(true);
            until BankAccount.Next() = 0;
    end;

    local procedure MovePaymentMethodTableData()
    var
        PaymentMethod: Record "Payment Method";
    begin
        if PaymentMethod.FindSet(true, false) then
            repeat
                PaymentMethod."AMC Bank Pmt. Type" := PaymentMethod."Bank Data Conversion Pmt. Type";
                PaymentMethod.Modify(true);
            until PaymentMethod.Next() = 0;
    end;

    local procedure MoveBankDataConvPmtTypesTableData()
    var
        BankDataConvPmtType: Record "Bank Data Conversion Pmt. Type";
        AmcBankPmtType: Record "AMC Bank Pmt. Type";
    begin
        if BankDataConvPmtType.FindSet(false, false) then
            repeat
                clear(AmcBankPmtType);
                AmcBankPmtType.Code := BankDataConvPmtType.Code;
                AmcBankPmtType.Description := BankDataConvPmtType.Description;
                AmcBankPmtType.SystemId := BankDataConvPmtType.SystemId;
                AmcBankPmtType.Insert(true);
            until BankDataConvPmtType.Next() = 0;
    end;

    local procedure DeleteOldDataExchangeDefinitions()
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        if DataExchDef.Get('BANKDATACONVSERVCT') then
            DataExchDef.Delete(true);
        if DataExchDef.Get('BANKDATACONVSERVSTMT') then
            DataExchDef.Delete(true);
    end;

    local procedure RemoveDataExchangeDefinitionReferences()
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        PaymentMethod: Record "Payment Method";
    begin
        BankExportImportSetup.SetFilter("Data Exch. Def. Code", '%1|%2', 'BANKDATACONVSERVCT', 'BANKDATACONVSERVSTMT');
        BankExportImportSetup.ModifyAll("Processing Codeunit ID", Codeunit::"AMC Bank Upg. Notification");
        BankExportImportSetup.ModifyAll("Data Exch. Def. Code", '');

        PaymentMethod.SetFilter("Pmt. Export Line Definition", '%1|%2', 'BANKDATACONVSERVCT', 'BANKDATACONVSERVSTMT');
        PaymentMethod.ModifyAll("Pmt. Export Line Definition", '');
    end;
}

