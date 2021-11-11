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
            MoveBankDataConversionPmtTypesTableData();
            MovePaymentMethodTableData();
            DeleteOldDataExchangeDefinitions();
            RemoveDataExchangeDefinitionReferences();
        end;
        UpdateNamespaceApiVersion();
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

    local procedure MoveBankDataConversionPmtTypesTableData()
    var
        BankDataConversionPmtType: Record "Bank Data Conversion Pmt. Type";
        AMCBankPmtType: Record "AMC Bank Pmt. Type";
    begin
        if BankDataConversionPmtType.FindSet(false, false) then
            repeat
                clear(AMCBankPmtType);
                AMCBankPmtType.Code := BankDataConversionPmtType.Code;
                AMCBankPmtType.Description := BankDataConversionPmtType.Description;
                AMCBankPmtType.SystemId := BankDataConversionPmtType.SystemId;
                AMCBankPmtType.Insert(true);
            until BankDataConversionPmtType.Next() = 0;
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

    local procedure UpdateNamespaceApiVersion()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankingMgt: codeunit "AMC Banking Mgt.";
        ApiPos: Integer;
    begin
        if (AMCBankingSetup.Get()) then
            if (AMCBankingSetup."Namespace API Version" <> AMCBankingMgt.GetCurrentApiVersion()) then begin
                IF (COPYSTR(AMCBankingSetup."Service URL", STRLEN(AMCBankingSetup."Service URL"), 1) = '/') THEN
                    AMCBankingSetup."Service URL" := CopyStr(LowerCase(AMCBankingSetup."Service URL" + AMCBankingMgt.GetCurrentApiVersion()), 1, 250)
                ELSE begin
                    ApiPos := StrPos(AMCBankingSetup."Service URL", AMCBankingSetup."Namespace API Version");
                    AMCBankingSetup."Service URL" := CopyStr(CopyStr(LowerCase(AMCBankingSetup."Service URL"), 1, ApiPos - 1) + AMCBankingMgt.GetCurrentApiVersion(), 1, 250);
                end;
                AMCBankingSetup."Namespace API Version" := AMCBankingMgt.GetCurrentApiVersion();
                if AMCBankingSetup.Modify() then;
            end;
    end;
}

