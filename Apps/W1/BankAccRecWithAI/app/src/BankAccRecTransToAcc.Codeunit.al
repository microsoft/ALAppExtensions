namespace Microsoft.Bank.Reconciliation;

using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using System.Security.User;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.AuditCodes;
using System.AI;
using System.Telemetry;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.Dimension;

codeunit 7251 "Bank Acc. Rec. Trans. to Acc."
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    EventSubscriberInstance = Manual;

    procedure GetMostAppropriateGLAccountNos(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Dictionary of [Integer, Code[20]];
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
        FeatureTelemetry.LogUsage('0000LEX', BankRecAIMatchingImpl.FeatureName(), 'Post Difference to G/L Account proposals');

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
            AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());
            AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Bank Account Reconciliation");
            AOAIChatCompletionParams.SetMaxTokens(BankRecAIMatchingImpl.MaxTokens());
            AOAIChatCompletionParams.SetTemperature(0);
            InputWithReservedWordsFound := false;
            GetCompletionResponse(AOAIChatMessages, BankAccReconciliationLine, TempBankStatementMatchingBuffer, GLAccount, AzureOpenAI, AOAIChatCompletionParams, AOAIOperationResponse);
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

    [NonDebuggable]
    local procedure GetCompletionResponse(var AOAIChatMessages: Codeunit "AOAI Chat Messages"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; var GLAccount: Record "G/L Account"; var AzureOpenAI: Codeunit "Azure OpenAi"; var AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params"; var AOAIOperationResponse: Codeunit "AOAI Operation Response")
    var
        SysMsg: Text;
        UserMsg: Text;
    begin
        SysMsg := BuildMostAppropriateGLAccountPromptTask().Unwrap();
        UserMsg := BuildBankRecPromptUserMessage(BuildBankRecStatementLines(BankAccReconciliationLine, TempBankStatementMatchingBuffer), BuildGLAccounts(GLAccount)).Unwrap();
        AOAIChatMessages.AddSystemMessage(SysMsg);
        AOAIChatMessages.AddUserMessage(UserMsg);
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
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
            LineNoTxt := CopyStr(MatchCoupleTxt, 1, StrPos(MatchCoupleTxt, ',') - 1).Trim().Replace('(', '');
            Evaluate(LineNo, LineNoTxt);
            BestGLAccountNoTxt := CopyStr(MatchCoupleTxt, StrPos(MatchCoupleTxt, ',') + 1).Trim().Replace(')', '');
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
    begin
        if TempBankAccRecAIPropBuf."G/L Account No." = '' then
            exit;

        if not BankAccReconciliationLine.Get(TempBankAccRecAIPropBuf."Statement Type", TempBankAccRecAIPropBuf."Bank Account No.", TempBankAccRecAIPropBuf."Statement No.", TempBankAccRecAIPropBuf."Statement Line No.") then
            exit;

        InsertTextToAccountMapping(BankAccReconciliationLine.Description, TempBankAccRecAIPropBuf."G/L Account No.");
        Commit();

        PAGE.RunModal(PAGE::"Text-to-Account Mapping", TextToAccMapping);
    end;

    procedure InsertTextToAccountMapping(TextToInsert: Text[100]; GLAccountNo: Code[20])
    var
        TextToAccMapping: Record "Text-to-Account Mapping";
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        LastLineNo: Integer;
        MappingText: Text[100];
    begin
        MappingText := TextToInsert;
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
                TextToAccMapping."Debit Acc. No." := GLAccountNo;
                TextToAccMapping."Credit Acc. No." := GLAccountNo;

                if TextToAccMapping."Mapping Text" <> '' then
                    TextToAccMapping.Insert();
            end;
            TextToAccMapping.Reset();
        end;
    end;

    procedure BuildMostAppropriateGLAccountPromptTask(): SecretText
    var
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        CompletionTaskTxt: SecretText;
        CompletionTaskPartTxt: SecretText;
        CompletionTaskBuildingFromKeyVaultFailed: Boolean;
        ConcatSubstrTok: Label '%1%2', Locked = true;
    begin
        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount1') then
            CompletionTaskTxt := CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount2') then
            CompletionTaskTxt := SecretStrSubstNo(ConcatSubstrTok, CompletionTaskTxt, CompletionTaskPartTxt)
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount3') then
            CompletionTaskTxt := SecretStrSubstNo(ConcatSubstrTok, CompletionTaskTxt, CompletionTaskPartTxt)
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount4') then
            CompletionTaskTxt := SecretStrSubstNo(ConcatSubstrTok, CompletionTaskTxt, CompletionTaskPartTxt)
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount5') then
            CompletionTaskTxt := SecretStrSubstNo(ConcatSubstrTok, CompletionTaskTxt, CompletionTaskPartTxt)
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if BankRecAIMatchingImpl.GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAITransToGLAccount6') then
            CompletionTaskTxt := SecretStrSubstNo(ConcatSubstrTok, CompletionTaskTxt, CompletionTaskPartTxt)
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

    procedure BuildBankRecStatementLines(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Text
    var
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        LocalStatementLines: Text;
    begin
        if (LocalStatementLines = '') then
            LocalStatementLines := '**Statement Lines**:\n"""\n';

        BankAccReconciliationLine.Ascending(true);
        if BankAccReconciliationLine.FindSet() then
            repeat
                if not BankRecAIMatchingImpl.HasReservedWords(BankAccReconciliationLine.Description) then begin
                    TempBankStatementMatchingBuffer.Reset();
                    TempBankStatementMatchingBuffer.SetRange("Line No.", BankAccReconciliationLine."Statement Line No.");
                    if TempBankStatementMatchingBuffer.IsEmpty() then begin
                        LocalStatementLines += '#Id: ' + Format(BankAccReconciliationLine."Statement Line No.");
                        LocalStatementLines += ', Description: ' + BankAccReconciliationLine.Description;
                        LocalStatementLines += '\n';
                    end
                end else
                    InputWithReservedWordsFound := true;
            until BankAccReconciliationLine.Next() = 0;

        exit(LocalStatementLines);
    end;

    procedure GenerateTransferToGLAccountProposals(var TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary)
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
                TempBankAccRecAIProposal."Dimension Set ID" := 0;
                TempBankAccRecAIProposal."Bank Account Ledger Entry No." := 0;
                TempBankAccRecAIProposal.Insert();
            end;
        until BankAccReconciliationLine.Next() = 0;
    end;

    procedure PostNewPaymentsToProposedGLAccounts(var TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; var TransToGLAccJnlBatch: Record "Trans. to G/L Acc. Jnl. Batch"): Integer
    var
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlLine: Record "Gen. Journal Line";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
        Dimension: Record Dimension;
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        MatchBankRecLines: Codeunit "Match Bank Rec. Lines";
        BankAccRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        UserSetupManagement: Codeunit "User Setup Management";
        FoundInvalidPostingDates: Boolean;
    begin
        Clear(TempGlobalBankStatementMatchingBuffer);
        Clear(StatementLines);
        TempBankAccRecAIProposal.Reset();
        TempBankAccRecAIProposal.SetFilter("G/L Account No.", '<>''''');
        if TempBankAccRecAIProposal.FindSet() then begin
            repeat
                if BankAccReconciliationLine.Get(TempBankAccRecAIProposal."Statement Type", TempBankAccRecAIProposal."Bank Account No.", TempBankAccRecAIProposal."Statement No.", TempBankAccRecAIProposal."Statement Line No.") then
                    if UserSetupManagement.IsPostingDateValidWithGenJnlTemplate(TempBankAccRecAIProposal."Transaction Date", TransToGLAccJnlBatch."Journal Template Name") then begin
                        GenJnlLine.Init();
                        GenJnlLine.Validate("Journal Template Name", TransToGLAccJnlBatch."Journal Template Name");
                        GenJnlLine.Validate("Journal Batch Name", TransToGLAccJnlBatch."Journal Batch Name");
                        GenJnlLine.Validate("Line No.", GenJnlLine.GetNewLineNo(TransToGLAccJnlBatch."Journal Template Name", TransToGLAccJnlBatch."Journal Batch Name"));
                        GenJnlLine.Validate("Posting Date", TempBankAccRecAIProposal."Transaction Date");
                        SourceCodeSetup.Get();

                        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"Bank Account");
                        GenJnlLine.Validate("Bal. Account No.", TempBankAccRecAIProposal."Bank Account No.");
                        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                        if TempBankAccRecAIProposal."Document No." <> '' then
                            GenJnlLine."Document No." := TempBankAccRecAIProposal."Document No."
                        else
                            if GenJournalBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name") then
                                GenJnlLine."Document No." := GetDocumentNo(GenJournalBatch, GenJnlLine."Posting Date");
                        GenJnlLine.Validate(Amount, -TempBankAccRecAIProposal.Difference);
                        GLAccount.Get(TempBankAccRecAIProposal."G/L Account No.");
                        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                        GenJnlLine.Validate("Account No.", TempBankAccRecAIProposal."G/L Account No.");
                        GenJnlLine.Description := TempBankAccRecAIProposal.Description;
                        GenJnlLine."Keep Description" := true;
                        GenJnlLine."Source Code" := SourceCodeSetup."Trans. Bank Rec. to Gen. Jnl.";
                        GenJnlLine."Source No." := BankAccReconciliationLine."Statement No.";
                        GenJnlLine."Source Line No." := BankAccReconciliationLine."Statement Line No.";
                        if Dimension.Get(GLAccount."Global Dimension 1 Code") then
                            GenJnlLine.Validate("Shortcut Dimension 1 Code", GLAccount."Global Dimension 1 Code");
                        if Dimension.Get(GLAccount."Global Dimension 2 Code") then
                            GenJnlLine.Validate("Shortcut Dimension 2 Code", GLAccount."Global Dimension 2 Code");
                        if TempBankAccRecAIProposal."Dimension Set ID" <> 0 then
                            GenJnlLine.Validate("Dimension Set ID", TempBankAccRecAIProposal."Dimension Set ID");
                        GenJnlLine.Insert(true);
                    end else
                        FoundInvalidPostingDates := true;
            until TempBankAccRecAIProposal.Next() = 0;

            GenJnlLine.Reset();
            GenJnlLine.SetRange("Journal Template Name", TransToGLAccJnlBatch."Journal Template Name");
            GenJnlLine.SetRange("Journal Batch Name", TransToGLAccJnlBatch."Journal Batch Name");
            GenJnlLine.SetRange("Source Code", SourceCodeSetup."Trans. Bank Rec. to Gen. Jnl.");
            GenJnlLine.SetRange("Source No.", BankAccReconciliationLine."Statement No.");
            GenJnlLine.SetRange("Bal. Account Type", GenJnlLine."Account Type"::"Bank Account");
            GenJnlLine.Validate("Bal. Account No.", BankAccReconciliationLine."Bank Account No.");

            Commit();
            BindSubscription(BankAccRecTransToAcc);
            if not GenJnlPostBatch.Run(GenJnlLine) then begin
                BankAccRecTransToAcc.CopyStatementMatchingBuffer(TempBankStatementMatchingBuffer);
                MatchBankRecLines.SaveOneToOneMatching(TempBankStatementMatchingBuffer, BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.");
                Commit();
                if Confirm(ErrorsDuringBatchPostingQst) then begin
                    TransToGLAccJnlBatch."Open Journal Batch" := true;
                    TransToGLAccJnlBatch.Modify()
                end else
                    Error(GetLastErrorText());
            end;
            UnbindSubscription(BankAccRecTransToAcc);
            BankAccRecTransToAcc.CopyStatementMatchingBuffer(TempBankStatementMatchingBuffer);
            MatchBankRecLines.SaveOneToOneMatching(TempBankStatementMatchingBuffer, BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.");
            if FoundInvalidPostingDates then
                Message(GetStatementLinesWithDisallowedDatesLbl());
            exit(StatementLines.Count());
        end;
    end;

    internal procedure CopyStatementMatchingBuffer(var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary)
    begin
        TempGlobalBankStatementMatchingBuffer.Reset();
        if TempGlobalBankStatementMatchingBuffer.FindSet() then
            repeat
                TempBankStatementMatchingBuffer."Line No." := TempGlobalBankStatementMatchingBuffer."Line No.";
                TempBankStatementMatchingBuffer."Entry No." := TempGlobalBankStatementMatchingBuffer."Entry No.";
                TempBankStatementMatchingBuffer."Match Details" := TempGlobalBankStatementMatchingBuffer."Match Details";
                TempBankStatementMatchingBuffer.Insert();
            until TempGlobalBankStatementMatchingBuffer.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterPostGenJournalLine', '', false, false)]
    local procedure InsertStatementMatchingBufferOnAfterPostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();

        if GenJournalLine."Source Code" <> SourceCodeSetup."Trans. Bank Rec. to Gen. Jnl." then
            exit;

        if GenJournalLine."Bal. Account Type" <> GenJournalLine."Account Type"::"Bank Account" then
            exit;

        if GenJournalLine."Bal. Account No." = '' then
            exit;

        BankAccountLedgerEntry.Reset();
        BankAccountLedgerEntry.SetAscending("Entry No.", true);
        BankAccountLedgerEntry.SetRange(Open, true);
        BankAccountLedgerEntry.SetRange("Bank Account No.", GenJournalLine."Bal. Account No.");
        BankAccountLedgerEntry.SetRange("Posting Date", GenJournalLine."Posting Date");
        if BankAccountLedgerEntry.FindLast() then begin
            TempGlobalBankStatementMatchingBuffer."Line No." := GenJournalLine."Source Line No.";
            TempGlobalBankStatementMatchingBuffer."Entry No." := BankAccountLedgerEntry."Entry No.";
            TempGlobalBankStatementMatchingBuffer."Match Details" := MatchJustificationTxt;
            TempGlobalBankStatementMatchingBuffer.Insert();
            if not StatementLines.Contains(GenJournalLine."Source Line No.") then
                StatementLines.Add(GenJournalLine."Source Line No.");
        end;
    end;

    local procedure GetDocumentNo(var GenJournalBatch: Record "Gen. Journal Batch"; PostingDate: Date): Code[20]
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        GenJournalLine: Record "Gen. Journal Line";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        LastDocNo: Code[20];
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetCurrentKey("Document No.");
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        if GenJournalLine.FindLast() then
            LastDocNo := GenJournalLine."Document No."
        else
            LastDocNo := NoSeriesBatch.GetNextNo(GenJournalBatch."No. Series", PostingDate, true);

        exit(LastDocNo);
    end;

    procedure BuildBankRecCompletionPrompt(TaskPrompt: SecretText; StatementLine: Text; GLAccounts: Text): SecretText
    var
        CompletionPrompt: SecretText;
        ConcatSubstrTok: Label '%1%2', Locked = true;
    begin
        GLAccounts += '"""\n';
        StatementLine += '"""\n';
        CompletionPrompt := SecretStrSubstNo(ConcatSubstrTok, TaskPrompt, StatementLine);
        CompletionPrompt := SecretStrSubstNo(ConcatSubstrTok, CompletionPrompt, GLAccounts);
        exit(CompletionPrompt);
    end;

    procedure BuildBankRecPromptUserMessage(StatementLine: Text; GLAccounts: Text): SecretText
    var
        UserMessagePrompt: SecretText;
        EmptyText: SecretText;
        ConcatSubstrTok: Label '%1%2', Locked = true;
    begin
        GLAccounts += '"""\n';
        StatementLine += '"""\n';
        UserMessagePrompt := SecretStrSubstNo(ConcatSubstrTok, EmptyText, StatementLine);
        UserMessagePrompt := SecretStrSubstNo(ConcatSubstrTok, UserMessagePrompt, GLAccounts);
        exit(UserMessagePrompt);
    end;

    procedure FoundInputWithReservedWords(): Boolean
    begin
        exit(InputWithReservedWordsFound)
    end;

    internal procedure GetStatementLinesWithDisallowedDatesLbl(): Text
    begin
        exit(StatementLinesWithDisallowedDatesLbl)
    end;

    var
        TempGlobalBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        StatementLines: List of [Integer];
        TelemetryNoDirectPostingGLAccountsErr: label 'User has no G/L Account that allows direct posting.', Locked = true;
        NoDirectPostingGLAccountsErr: label 'You must create at least one G/L Account that allows direct posting.';
        MatchJustificationTxt: label 'Applied by Copilot to a new payment based on semantic similarity with the G/L Account name.', Comment = 'Copilot is a Microsoft service acronym and must not be translated';
        TelemetryChatCompletionErr: label 'Chat completion request was unsuccessful. Response code: %1', Locked = true;
        ConstructingPromptFailedErr: label 'There was an error with sending the call to Copilot. Log a Business Central support request about this.', Comment = 'Copilot is a Microsoft service name and must not be translated';
        TelemetryConstructingPromptFailedErr: label 'There was an error with constructing the chat completion prompt from the Key Vault.', Locked = true;
        ChooseGLAccountLbl: label 'Choose G/L Account...';
        StatementLinesWithDisallowedDatesLbl: label 'There are statement lines that have transaction dates outside of the allowed posting date range. Payments will not be posted for these statement lines. You must match these lines manually. Alternatively, choose another journal template or adjust the allowed posting dates on the journal template or general ledger setup.';
        ErrorsDuringBatchPostingQst: label 'There were errors while attempting to post the payments. Do you want to open the journal batch with the unposted payments?';
        InputWithReservedWordsFound: Boolean;
}