// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Bank;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31200 "Create Gen. Jnl. Batch CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
        CreateGenJnlTemplateCZ: Codeunit "Create Gen. Jnl. Template CZ";
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
    begin
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJnlTemplateCZ.Recurring(), CreateGenJournalBatch.Default(), DefaultJournalBatchLbl);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJnlTemplateCZ.Closing(), OPBALSHT(), OpenBalanceSheetLbl);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJnlTemplateCZ.Closing(), CLBALSHT(), CloseBalanceSheetLbl);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJnlTemplateCZ.Closing(), CLINCSTMT(), CloseIncomeStatementLbl);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJnlTemplateCZ.Banks(), WWBEUR(), WorldWideBankLbl, "Gen. Journal Account Type"::"Bank Account", '', '', true);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJnlTemplateCZ.Banks(), NBL(), NewBankofLondonLbl, "Gen. Journal Account Type"::"Bank Account", '', '', true);
    end;

    procedure OPBALSHT(): Code[10]
    begin
        exit(OPBALSHTTok);
    end;

    procedure CLBALSHT(): Code[10]
    begin
        exit(CLBALSHTTok);
    end;

    procedure CLINCSTMT(): Code[10]
    begin
        exit(CLINCSTMTTok);
    end;

    procedure WWBEUR(): Code[10]
    begin
        exit(CopyStr(CreateBankAccountCZ.WWBEUR(), 1, 10));
    end;

    procedure NBL(): Code[10]
    begin
        exit(CopyStr(CreateBankAccountCZ.NBL(), 1, 10));
    end;

    var
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
        DefaultJournalBatchLbl: Label 'Default Journal Batch', MaxLength = 100;
        OPBALSHTTok: Label 'OPBALSHT', MaxLength = 10;
        OpenBalanceSheetLbl: Label 'Open Balance Sheet', MaxLength = 100;
        CLBALSHTTok: Label 'CLBALSHT', MaxLength = 10;
        CloseBalanceSheetLbl: Label 'Close Balance Sheet', MaxLength = 100;
        CLINCSTMTTok: Label 'CLINCSTMT', MaxLength = 10;
        CloseIncomeStatementLbl: Label 'Close Income Satement', MaxLength = 100;
        NewBankofLondonLbl: Label 'New Bank of London', MaxLength = 100;
        WorldWideBankLbl: Label 'World Wide Bank', MaxLength = 100;
}
