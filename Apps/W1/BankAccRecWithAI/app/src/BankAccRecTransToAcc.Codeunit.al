namespace Microsoft.Bank.Reconciliation;

using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.AuditCodes;
using System.AI;
using System.Telemetry;

codeunit 7251 "Bank Acc. Rec. Trans. to Acc."
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;

#if not CLEAN21
#pragma warning disable AL0432
#endif
    procedure GetMostAppropriateGLAccountNos(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Dictionary of [Integer, Code[20]];
#if not CLEAN21
#pragma warning restore AL0432
#endif
    var
        GLAccount: Record "G/L Account";
        TexttoAccountMapping: Record "Text-to-Account Mapping";
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CompletionAnswerTxt: Text;
        BestGLAccountNo: Code[20];
        Result: Dictionary of [Integer, Code[20]];
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Bank Account Reconciliation") then
            exit;

        GLAccount.SetRange("Direct Posting", true);
        if not GLAccount.FindSet() then begin
            Session.LogMessage('0000LEY', TelemetryNoDirectPostingGLAccountsErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
            error(NoDirectPostingGLAccountsErr);
        end;

        if not BankAccReconciliationLine.FindSet() then
            exit(Result);

        FeatureTelemetry.LogUptake('0000LEV', BankRecAIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::"Set up");
        FeatureTelemetry.LogUptake('0000LEW', BankRecAIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000LEX', BankRecAIMatchingImpl.FeatureName(), 'Transfer to G/L Account proposals');

        // for bank account reconciliation lines whose description is mapped to a G/L Account in Text-to Account Mapping, add the result immediately
        // mark bank account reconciliation lines whose description is not mapped to a G/L Account in Text-to Account Mapping
        repeat
            BestGLAccountNo := '';
            TexttoAccountMapping.SetFilter("Mapping Text", '%1', '@' + RecordMatchMgt.Trim(BankAccReconciliationLine.Description));
            TexttoAccountMapping.SetRange("Bal. Source Type", TexttoAccountMapping."Bal. Source Type"::"G/L Account");
            if TexttoAccountMapping.FindFirst() then begin
                if TexttoAccountMapping."Debit Acc. No." <> '' then
                    BestGLAccountNo := TexttoAccountMapping."Debit Acc. No."
                else
                    if TexttoAccountMapping."Credit Acc. No." <> '' then
                        BestGLAccountNo := TexttoAccountMapping."Credit Acc. No.";
                if BestGLAccountNo <> '' then begin
                    if not Result.ContainsKey(BankAccReconciliationLine."Statement Line No.") then
                        Result.Add(BankAccReconciliationLine."Statement Line No.", BestGLAccountNo);
                    BankAccReconciliationLine.Mark(false);
                end
            end else
                BankAccReconciliationLine.Mark(true);
        until BankAccReconciliationLine.Next() = 0;

        BestGLAccountNo := '';
        BankAccReconciliationLine.MarkedOnly(true);
        if not BankAccReconciliationLine.IsEmpty() then begin
            AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT40613());
            AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Bank Account Reconciliation");
            AOAIChatCompletionParams.SetMaxTokens(BankRecAIMatchingImpl.MaxTokens());
            AOAIChatCompletionParams.SetTemperature(0);
            InputWithReservedWordsFound := false;
            AOAIChatMessages.AddSystemMessage(BuildBankRecCompletionPrompt(BuildMostAppropriateGLAccountPromptTask(), BuildBankRecStatementLines(BankAccReconciliationLine, TempBankStatementMatchingBuffer), BuildGLAccounts(GLAccount)));
            AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
            if AOAIOperationResponse.IsSuccess() then
                CompletionAnswerTxt := AOAIOperationResponse.GetResult()
            else begin
                Session.LogMessage('0000LEZ', StrSubstNo(TelemetryChatCompletionErr, AOAIOperationResponse.GetStatusCode()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
                Error(AOAIOperationResponse.GetError());
            end;

            ProcessCompletionAnswer(CompletionAnswerTxt, Result);
        end;
        BankAccReconciliationLine.MarkedOnly(false);
        exit(Result);
    end;

    procedure ProcessCompletionAnswer(var CompletionAnswerTxt: Text; var Result: Dictionary of [Integer, Code[20]])
    var
        BestGLAccountNoTxt: Text;
        BestGLAccountNo: Code[20];
        LineNo: Integer;
        FirstOpenParenthesisPos: Integer;
        FirstClosedParenthesisPos: Integer;
        LineNoTxt: Text;
        MatchCoupleTxt: Text;
    begin
        FirstOpenParenthesisPos := StrPos(CompletionAnswerTxt, '(');
        FirstClosedParenthesisPos := StrPos(CompletionAnswerTxt, ')');
        while (FirstClosedParenthesisPos - FirstOpenParenthesisPos > 1) do begin
            MatchCoupleTxt := CopyStr(CompletionAnswerTxt, FirstOpenParenthesisPos + 1, FirstClosedParenthesisPos - FirstOpenParenthesisPos - 1).Trim();
            LineNoTxt := CopyStr(MatchCoupleTxt, 1, StrPos(MatchCoupleTxt, ',') - 1).Trim();
            Evaluate(LineNo, LineNoTxt);
            BestGLAccountNoTxt := CopyStr(MatchCoupleTxt, StrPos(MatchCoupleTxt, ',') + 1).Trim();
            if BestGLAccountNoTxt <> '' then begin
                BestGLAccountNo := CopyStr(UpperCase(BestGLAccountNoTxt), 1, MaxStrLen(BestGLAccountNo));
                if not Result.ContainsKey(LineNo) then
                    Result.Add(LineNo, BestGLAccountNo);
            end;
            if (FirstOpenParenthesisPos > 0) and (FirstClosedParenthesisPos < StrLen(CompletionAnswerTxt)) then begin
                CompletionAnswerTxt := CopyStr(CompletionAnswerTxt, FirstClosedParenthesisPos + 1);
                FirstOpenParenthesisPos := StrPos(CompletionAnswerTxt, '(');
                FirstClosedParenthesisPos := StrPos(CompletionAnswerTxt, ')');
            end
            else
                CompletionAnswerTxt := '';
        end;
    end;

    procedure InsertTextToAccountMapping(var TempBankAccRecAIPropBuf: Record "Bank Acc. Rec. AI Prop. Buf." temporary)
    var
        TextToAccMapping: Record "Text-to-Account Mapping";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        LastLineNo: Integer;
        MappingText: Text[140];
    begin
        if TempBankAccRecAIPropBuf."G/L Account No." = '' then
            exit;

        if not BankAccReconciliationLine.Get(TempBankAccRecAIPropBuf."Statement Type", TempBankAccRecAIPropBuf."Bank Account No.", TempBankAccRecAIPropBuf."Statement No.", TempBankAccRecAIPropBuf."Statement Line No.") then
            exit;

        MappingText := BankAccReconciliationLine.Description;
        if RecordMatchMgt.Trim(MappingText) <> '' then begin
            TextToAccMapping.SetFilter("Mapping Text", '%1', '@' + RecordMatchMgt.Trim(MappingText));
            if not TextToAccMapping.FindFirst() then begin
                TextToAccMapping.Reset();
                if TextToAccMapping.FindLast() then
                    LastLineNo := TextToAccMapping."Line No.";

                TextToAccMapping.Init();
                TextToAccMapping."Line No." := LastLineNo + 10000;
                TextToAccMapping.Validate("Mapping Text", MappingText);

                TextToAccMapping."Bal. Source Type" := TextToAccMapping."Bal. Source Type"::"G/L Account";
                TextToAccMapping."Debit Acc. No." := TempBankAccRecAIPropBuf."G/L Account No.";
                TextToAccMapping."Credit Acc. No." := TempBankAccRecAIPropBuf."G/L Account No.";

                if TextToAccMapping."Mapping Text" <> '' then
                    TextToAccMapping.Insert();
            end;
            TextToAccMapping.Reset();
            Commit();
        end;

        PAGE.RunModal(PAGE::"Text-to-Account Mapping", TextToAccMapping);
    end;

    [NonDebuggable]
    procedure BuildMostAppropriateGLAccountPromptTask(): Text
    var
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        CompletionTaskTxt: Text;
        CompletionTaskPartTxt: Text;
        CompletionTaskBuildingFromKeyVaultFailed: Boolean;
    begin
        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount1') then
            CompletionTaskTxt := CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount2') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount3') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount4') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount5') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount6') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if CompletionTaskBuildingFromKeyVaultFailed then begin
            Session.LogMessage('0000LFI', TelemetryConstructingPromptFailedErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
            Error(ConstructingPromptFailedErr);
        end;

        exit(CompletionTaskTxt);
    end;

    procedure BuildGLAccounts(var GLAccount: Record "G/L Account"): Text
    var
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        GLAccountsTxt: Text;
    begin
        if (GLAccountsTxt = '') then
            GLAccountsTxt := '**G/L Accounts**:\n"""\n';

        repeat
            if not BankRecAIMatchingImpl.HasReservedWords(GLAccount.Name) then begin
                GLAccountsTxt += '#Id: ' + GLAccount."No.";
                GLAccountsTxt += ', Name: ' + GLAccount.Name;
                GLAccountsTxt += '\n'
            end else
                InputWithReservedWordsFound := true;
        until (GLAccount.Next() = 0);
        exit(GLAccountsTxt);
    end;

#if not CLEAN21
#pragma warning disable AL0432
#endif
    procedure BuildBankRecStatementLines(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Text
#if not CLEAN21
#pragma warning restore AL0432
#endif
    var
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        StatementLines: Text;
    begin
        if (StatementLines = '') then
            StatementLines := '**Statement Lines**:\n"""\n';

        if BankAccReconciliationLine.FindSet() then
            repeat
                if not BankRecAIMatchingImpl.HasReservedWords(BankAccReconciliationLine.Description) then begin
                    TempBankStatementMatchingBuffer.Reset();
                    TempBankStatementMatchingBuffer.SetRange("Line No.", BankAccReconciliationLine."Statement Line No.");
                    if TempBankStatementMatchingBuffer.IsEmpty() then begin
                        StatementLines += '#Id: ' + Format(BankAccReconciliationLine."Statement Line No.");
                        StatementLines += ', Description: ' + BankAccReconciliationLine.Description;
                        StatementLines += '\n';
                    end
                end else
                    InputWithReservedWordsFound := true;
            until BankAccReconciliationLine.Next() = 0;

        exit(StatementLines);
    end;

#if not CLEAN21
#pragma warning disable AL0432
#endif
    procedure GenerateTransferToGLAccountProposals(var TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary)
#if not CLEAN21
#pragma warning restore AL0432
#endif
    var
        GLAccount: Record "G/L Account";
        MostSuitableGLAccountCodes: Dictionary of [Integer, Code[20]];
        MostSuitableGLAccountCode: Code[20];
    begin
        BankAccReconciliationLine.SetFilter(Difference, '<>0');
        MostSuitableGLAccountCodes := GetMostAppropriateGLAccountNos(BankAccReconciliationLine, TempBankStatementMatchingBuffer);
        BankAccReconciliationLine.FindSet();
        repeat
            if MostSuitableGLAccountCodes.ContainsKey(BankAccReconciliationLine."Statement Line No.") then begin
                MostSuitableGLAccountCode := MostSuitableGLAccountCodes.Get(BankAccReconciliationLine."Statement Line No.");
                if MostSuitableGLAccountCode <> '' then
                    if GLAccount.Get(MostSuitableGLAccountCode) then begin
                        TempBankAccRecAIProposal."Statement Type" := BankAccReconciliationLine."Statement Type";
                        TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliationLine."Bank Account No.";
                        TempBankAccRecAIProposal."Statement No." := BankAccReconciliationLine."Statement No.";
                        TempBankAccRecAIProposal."Statement Line No." := BankAccReconciliationLine."Statement Line No.";
                        TempBankAccRecAIProposal."Document No." := BankAccReconciliationLine."Document No.";
                        TempBankAccRecAIProposal.Description := BankAccReconciliationLine.Description;
                        TempBankAccRecAIProposal."Transaction Date" := BankAccReconciliationLine."Transaction Date";
                        TempBankAccRecAIProposal.Difference := BankAccReconciliationLine.Difference;
                        TempBankAccRecAIProposal.Validate("G/L Account No.", MostSuitableGLAccountCode);
                        TempBankAccRecAIProposal."Bank Account Ledger Entry No." := 0;
                        TempBankAccRecAIProposal.Insert();
                    end;
            end
            else begin
                TempBankAccRecAIProposal."Statement Type" := BankAccReconciliationLine."Statement Type";
                TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliationLine."Bank Account No.";
                TempBankAccRecAIProposal."Statement No." := BankAccReconciliationLine."Statement No.";
                TempBankAccRecAIProposal."Statement Line No." := BankAccReconciliationLine."Statement Line No.";
                TempBankAccRecAIProposal."Document No." := BankAccReconciliationLine."Document No.";
                TempBankAccRecAIProposal.Description := BankAccReconciliationLine.Description;
                TempBankAccRecAIProposal."Transaction Date" := BankAccReconciliationLine."Transaction Date";
                TempBankAccRecAIProposal.Difference := BankAccReconciliationLine.Difference;
                TempBankAccRecAIProposal."G/L Account No." := '';
                TempBankAccRecAIProposal."AI Proposal" := ChooseGLAccountLbl;
                TempBankAccRecAIProposal."Bank Account Ledger Entry No." := 0;
                TempBankAccRecAIProposal.Insert();
            end;
        until BankAccReconciliationLine.Next() = 0;
    end;

#if not CLEAN21
#pragma warning disable AL0432
#endif
    procedure PostNewPaymentsToProposedGLAccounts(var TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Integer
#if not CLEAN21
#pragma warning restore AL0432
#endif
    var
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlLine: Record "Gen. Journal Line";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        MatchBankRecLines: Codeunit "Match Bank Rec. Lines";
        StatementLines: List of [Integer];
    begin
        TempBankAccRecAIProposal.Reset();
        TempBankAccRecAIProposal.SetFilter("G/L Account No.", '<>''''');
        if TempBankAccRecAIProposal.FindSet() then begin
            repeat
                if BankAccReconciliationLine.Get(TempBankAccRecAIProposal."Statement Type", TempBankAccRecAIProposal."Bank Account No.", TempBankAccRecAIProposal."Statement No.", TempBankAccRecAIProposal."Statement Line No.") then begin
                    GenJnlLine.Init();
                    GenJnlLine.Validate("Posting Date", TempBankAccRecAIProposal."Transaction Date");
                    SourceCodeSetup.Get();

                    GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"Bank Account");
                    GenJnlLine.Validate("Bal. Account No.", TempBankAccRecAIProposal."Bank Account No.");
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                    if TempBankAccRecAIProposal."Document No." <> '' then
                        GenJnlLine."Document No." := TempBankAccRecAIProposal."Document No.";
                    GenJnlLine.Validate(Amount, -TempBankAccRecAIProposal.Difference);
                    GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                    GenJnlLine."Account No." := TempBankAccRecAIProposal."G/L Account No.";
                    GenJnlLine.Description := TempBankAccRecAIProposal.Description;
                    GenJnlLine."Keep Description" := true;
                    GenJnlLine."Source Code" := SourceCodeSetup."Trans. Bank Rec. to Gen. Jnl.";
                    GenJnlPostLine.RunWithoutCheck(GenJnlLine);
                    BankAccountLedgerEntry.Reset();
                    BankAccountLedgerEntry.SetAscending("Entry No.", true);
                    BankAccountLedgerEntry.SetRange(Open, true);
                    BankAccountLedgerEntry.SetRange("Bank Account No.", TempBankAccRecAIProposal."Bank Account No.");
                    BankAccountLedgerEntry.SetFilter("Document No.", '=%1', GenJnlLine."Document No.");
                    BankAccountLedgerEntry.SetRange("Posting Date", GenJnlLine."Posting Date");
                    BankAccountLedgerEntry.SetFilter("Source Code", '=%1', GenJnlLine."Source Code");
                    if BankAccountLedgerEntry.FindLast() then begin
                        TempBankStatementMatchingBuffer."Line No." := BankAccReconciliationLine."Statement Line No.";
                        TempBankStatementMatchingBuffer."Entry No." := BankAccountLedgerEntry."Entry No.";
                        TempBankStatementMatchingBuffer."Match Details" := MatchJustificationTxt;
                        TempBankStatementMatchingBuffer.Insert();
                        if not StatementLines.Contains(TempBankAccRecAIProposal."Statement Line No.") then
                            StatementLines.Add(TempBankAccRecAIProposal."Statement Line No.");
                    end;
                end;
            until TempBankAccRecAIProposal.Next() = 0;
            MatchBankRecLines.SaveOneToOneMatching(TempBankStatementMatchingBuffer, BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.");
            exit(StatementLines.Count());
        end;
    end;

    procedure BuildBankRecCompletionPrompt(taskPrompt: Text; StatementLine: Text; GLAccounts: Text): Text
    begin
        GLAccounts += '"""\n';
        StatementLine += '"""\n';
        exit(taskPrompt + StatementLine + GLAccounts);
    end;

    procedure FoundInputWithReservedWords(): Boolean
    begin
        exit(InputWithReservedWordsFound)
    end;

    var
        TelemetryNoDirectPostingGLAccountsErr: label 'User has no G/L Account that allows direct posting.', Locked = true;
        NoDirectPostingGLAccountsErr: label 'You must create at least one G/L Account that allows direct posting.';
        MatchJustificationTxt: label 'Applied by Copilot to a new payment based on semantic similarity with the G/L Account name.', Comment = 'Copilot is a Microsoft service acronym and must not be translated';
        TelemetryChatCompletionErr: label 'Chat completion request was unsuccessful. Response code: %1', Locked = true;
        ConstructingPromptFailedErr: label 'There was an error with sending the call to Copilot. Log a Business Central support request about this.', Comment = 'Copilot is a Microsoft service name and must not be translated';
        TelemetryConstructingPromptFailedErr: label 'There was an error with constructing the chat completion prompt from the Key Vault.', Locked = true;
        ChooseGLAccountLbl: label 'Choose G/L Account...';
        InputWithReservedWordsFound: Boolean;
}