codeunit 20129 "AMC Bank PrePost Proc"
{

    trigger OnRun()
    begin
    end;

    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        MissingStmtDateInDataMsg: Label 'The statement date was not found in the data to be imported.';
        MissingClosingBalInDataMsg: Label 'The closing balance was not found in the data to be imported.';
        MissingBankAccNoQst: Label 'Bank account %1 does not have a bank account number.\\Do you want to continue?', Comment = '%1 = Bank Account No';
        BankAccCurrErr: Label 'The bank statement that you are importing contains transactions in currencies other than the %1 %2 of bank account %3.', Comment = '%1 %2 = Currency Code EUR; %3 = Bank Account No.';
        MultipleStmtErr: Label 'The file that you are trying to import contains more than one bank statement.';
        MissingBankAccNoInDataErr: Label 'The bank account number was not found in the data to be imported.';
        BankAccMismatchQst: Label 'Bank account %1 does not have the bank account number %2, as specified in the bank statement file.\\Do you want to continue?', Comment = '%1=Value; %2 = Bank account no.';

        ownbankaccountTxt: Label 'ownbankaccount', Locked = true;
        bankaccountTxt: Label 'bankaccount', Locked = true;
        currencyTxt: Label 'currency', Locked = true;
        balanceenddateTxt: Label 'balanceenddate', Locked = true;
        balanceendTxt: Label 'balanceend', Locked = true;
        statementnoTxt: Label 'statementno', Locked = true;

    procedure PostProcessStatementDate(DataExch: Record "Data Exch."; var RecordRef: RecordRef; FieldNo: Integer)
    var
        TempElementXMLBuffer: Record "XML Buffer" temporary;
        XmlInStream: InStream;
    begin
        DataExch.CalcFields("File Content");
        if (DataExch."File Content".HasValue) then begin
            DataExch."File Content".CreateInStream(XmlInStream);
            TempElementXMLBuffer.LoadFromStream(XmlInStream);

            TempElementXMLBuffer.SetFilter(Name, balanceenddateTxt);
            if (TempElementXMLBuffer.FindFirst()) then
                if (TempElementXMLBuffer.GetValue() <> '') then begin
                    AMCBankingMgt.SetFieldValue(RecordRef, FieldNo, TempElementXMLBuffer.GetValue(), false, false);
                    RecordRef.Modify(true);
                end
                else
                    Message(MissingStmtDateInDataMsg);

        end;
    end;

    procedure PostProcessStatementEndingBalance(DataExch: Record "Data Exch."; var RecordRef: RecordRef; FieldNo: Integer)
    var
        TempElementXMLBuffer: Record "XML Buffer" temporary;
        XmlInStream: InStream;
    begin
        DataExch.CalcFields("File Content");
        if (DataExch."File Content".HasValue) then begin
            DataExch."File Content".CreateInStream(XmlInStream);
            TempElementXMLBuffer.LoadFromStream(XmlInStream);

            TempElementXMLBuffer.SetFilter(Name, balanceendTxt);
            if (TempElementXMLBuffer.FindFirst()) then
                if (TempElementXMLBuffer.GetValue() <> '') then begin
                    AMCBankingMgt.SetFieldValue(RecordRef, FieldNo, TempElementXMLBuffer.GetValue(), false, false);
                    RecordRef.Modify(true);
                end
                else
                    Message(MissingClosingBalInDataMsg);
        end;
    end;

    procedure PreProcessBankAccount(DataExch: Record "Data Exch."; BankAccNo: Code[20])
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get(BankAccNo);
        CheckBankAccNo(DataExch, BankAccount);
        CheckBankAccCurrency(DataExch, BankAccount);
    end;

    procedure PreProcessFile(DataExch: Record "Data Exch.")
    begin
        CheckMultipleStatements(DataExch);
    end;

    local procedure CheckBankAccNo(DataExch: Record "Data Exch."; BankAccount: Record "Bank Account")
    var
        TempOwnBankAcountElementXMLBuffer: Record "XML Buffer" temporary;
        TempElementXMLBuffer: Record "XML Buffer" temporary;
        XmlInStream: InStream;
        BankAccountInXML: Text;
    begin
        if BankAccount.GetBankAccountNo() = '' then begin
            if not Confirm(StrSubstNo(MissingBankAccNoQst, BankAccount."No.")) then
                Error('');
            exit;
        end;

        DataExch.CalcFields("File Content");
        if (DataExch."File Content".HasValue) then begin
            DataExch."File Content".CreateInStream(XmlInStream);
            TempOwnBankAcountElementXMLBuffer.LoadFromStream(XmlInStream);
            TempElementXMLBuffer.CopyImportFrom(TempOwnBankAcountElementXMLBuffer);

            TempOwnBankAcountElementXMLBuffer.SetFilter(Name, ownbankaccountTxt);
            if (TempOwnBankAcountElementXMLBuffer.FindFirst()) then begin
                TempElementXMLBuffer.SetRange("Parent Entry No.", TempOwnBankAcountElementXMLBuffer."Entry No.");
                TempElementXMLBuffer.SetRange(Name, bankaccountTxt);
                if (TempElementXMLBuffer.FindFirst()) then
                    BankAccountInXML := TempElementXMLBuffer.GetValue();

            end;

            if BankAccountInXML = '' then
                Error(MissingBankAccNoInDataErr);

            if (DelChr(BankAccountInXML, '=', '- ') <> DelChr(BankAccount."Bank Account No.", '=', '- ')) and
               (DelChr(BankAccountInXML, '=', '- ') <> DelChr(BankAccount.IBAN, '=', '- '))
            then
                if not Confirm(StrSubstNo(BankAccMismatchQst, BankAccount."No.", BankAccountInXML)) then
                    Error('');
        end;
    end;

    local procedure CheckBankAccCurrency(DataExch: Record "Data Exch."; BankAccount: Record "Bank Account")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempOwnBankAcountElementXMLBuffer: Record "XML Buffer" temporary;
        TempElementXMLBuffer: Record "XML Buffer" temporary;
        XmlInStream: InStream;
        CurrencyInXML: Text;
    begin
        GeneralLedgerSetup.Get();

        DataExch.CalcFields("File Content");
        if (DataExch."File Content".HasValue) then begin
            DataExch."File Content".CreateInStream(XmlInStream);
            TempOwnBankAcountElementXMLBuffer.LoadFromStream(XmlInStream);
            TempElementXMLBuffer.CopyImportFrom(TempOwnBankAcountElementXMLBuffer);

            TempOwnBankAcountElementXMLBuffer.SetFilter(Name, ownbankaccountTxt);
            if (TempOwnBankAcountElementXMLBuffer.FindFirst()) then begin
                TempElementXMLBuffer.SetRange("Parent Entry No.", TempOwnBankAcountElementXMLBuffer."Entry No.");
                TempElementXMLBuffer.SetRange(Name, currencyTxt);
                if (TempElementXMLBuffer.FindFirst()) then
                    CurrencyInXML := TempElementXMLBuffer.GetValue();
            end;

            if ((CurrencyInXML <> '') and (CurrencyInXML <> GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"))) then
                Error(BankAccCurrErr, BankAccount.FieldCaption("Currency Code"),
                  GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"), BankAccount."No.");
        end;
    end;

    local procedure CheckMultipleStatements(DataExch: Record "Data Exch.")
    var
        TempElementXMLBuffer: Record "XML Buffer" temporary;

        XmlInStream: InStream;
    begin

        DataExch.CalcFields("File Content");
        if (DataExch."File Content".HasValue) then begin
            DataExch."File Content".CreateInStream(XmlInStream);
            TempElementXMLBuffer.LoadFromStream(XmlInStream);

            TempElementXMLBuffer.SetRange(Name, statementnoTxt);
            if (TempElementXMLBuffer.Count() > 1) then
                Error(MultipleStmtErr);

        end;
    end;

}

