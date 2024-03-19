namespace Microsoft.Bank.Reconciliation;

using Microsoft.Bank.Ledger;
using Microsoft.Upgrade;
using System.AI;
using System.Azure.KeyVault;
using System.Environment;
using System.Telemetry;
using System.Upgrade;

codeunit 7250 "Bank Rec. AI Matching Impl."
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;

    [NonDebuggable]
    procedure BuildBankRecCompletionTask(IncludeFewShotExample: Boolean): Text
    var
        CompletionTaskTxt: Text;
        CompletionTaskPartTxt: Text;
        CompletionTaskBuildingFromKeyVaultFailed: Boolean;
    begin
        if GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAIMatching1') then
            CompletionTaskTxt := CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAIMatching2') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAIMatching3') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAIMatching4') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAIMatching5') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if GetAzureKeyVaultSecret(CompletionTaskPartTxt, 'BankAccRecAIMatching6') then
            CompletionTaskTxt += CompletionTaskPartTxt
        else
            CompletionTaskBuildingFromKeyVaultFailed := true;

        if CompletionTaskBuildingFromKeyVaultFailed then begin
            Session.LogMessage('0000LFJ', TelemetryConstructingPromptFailedErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
            Error(ConstructingPromptFailedErr);
        end;

        if (IncludeFewShotExample) then begin
            CompletionTaskTxt += '\n**Example 1**:\n';
            CompletionTaskTxt += 'Statement Line: Id: 1, Description: A, Amount: 100, Date: 2023-07-01\n';
            CompletionTaskTxt += 'Ledger Entry: Id: 11, DocumentNo: 111, Description: A, Amount: 100, Date: 2023-07-01\n';
            CompletionTaskTxt += 'Matches: (1, [11])\n';
            CompletionTaskTxt += '\n**Example 2**:\n';
            CompletionTaskTxt += 'Statement Line: Id: 2, Description: B, Amount: 200, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Ledger Entry: Id: 22, DocumentNo: 222, Description: B, Amount: 100, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Ledger Entry: Id: 23, DocumentNo: 223, Description: B, Amount: 100, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Matches: (2, [22, 23])\n\n';
            CompletionTaskTxt += '\n**Example 3**:\n';
            CompletionTaskTxt += 'Statement Line: Id: 3, Description: C, Amount: 237, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Ledger Entry: Id: 32, DocumentNo: 322, Description: D, Amount: 205, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Ledger Entry: Id: 33, DocumentNo: 323, Description: E, Amount: 237, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Matches: (3, [33])\n\n';
            CompletionTaskTxt += '\n**Example 4**:\n';
            CompletionTaskTxt += 'Statement Line: Id: 4, Description: F, Amount: 248, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Ledger Entry: Id: 42, DocumentNo: 422, Description: G, Amount: 248, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Ledger Entry: Id: 43, DocumentNo: 423, Description: H, Amount: 248, Date: 2023-07-03\n';
            CompletionTaskTxt += '\n**Example 5**:\n';
            CompletionTaskTxt += 'Statement Line: Id: 5, Description: I 522, Amount: 248, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Statement Line: Id: 6, Description: I 522, Amount: 100, Date: 2023-07-05\n';
            CompletionTaskTxt += 'Ledger Entry: Id: 52, DocumentNo: 522, Description: J, Amount: 348, Date: 2023-07-02\n';
            CompletionTaskTxt += 'Matches: (5, [52]), (6, [52])\n\n';
        end;
        CompletionTaskTxt += '\n\n';
        exit(CompletionTaskTxt);
    end;

    procedure BuildBankRecCompletionPrompt(taskPrompt: Text; StatementLines: Text; LedgerLines: Text): Text
    begin
        LedgerLines += '"""\n**Matches**:'; // close the ledger lines section
        StatementLines += '"""\n'; // close the statement lines section
        exit(taskPrompt + StatementLines + LedgerLines);
    end;

    procedure BuildBankRecLedgerEntries(var LedgerLines: Text; var TempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary): Text
    begin
        if (LedgerLines = '') then
            LedgerLines := '**Ledger Entries**:\n"""\n';

        repeat
            if not HasReservedWords(TempBankAccLedgerEntryMatchingBuffer.Description) then begin
                LedgerLines += '#Id: ' + Format(TempBankAccLedgerEntryMatchingBuffer."Entry No.");
                if TempBankAccLedgerEntryMatchingBuffer."Document No." <> '' then
                    LedgerLines += ', DocumentNo: ' + TempBankAccLedgerEntryMatchingBuffer."Document No.";
                LedgerLines += ', Description: ' + TempBankAccLedgerEntryMatchingBuffer.Description;
                if TempBankAccLedgerEntryMatchingBuffer."Payment Reference" <> '' then
                    LedgerLines += ', PaymentReference: ' + TempBankAccLedgerEntryMatchingBuffer."Payment Reference";
                if TempBankAccLedgerEntryMatchingBuffer."External Document No." <> '' then
                    LedgerLines += ', ExtDocNo: ' + TempBankAccLedgerEntryMatchingBuffer."External Document No.";
                LedgerLines += ', Amount: ' + Format(TempBankAccLedgerEntryMatchingBuffer."Remaining Amount", 0, 9);
                LedgerLines += ', Date: ' + Format(TempBankAccLedgerEntryMatchingBuffer."Posting Date", 0, 9);
                LedgerLines += '\n';
            end else
                InputWithReservedWordsFound := true;
        until (TempBankAccLedgerEntryMatchingBuffer.Next() = 0);
    end;

    procedure BuildBankRecStatementLines(var StatementLines: Text; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"): Text
    begin
        if (StatementLines = '') then
            StatementLines := '**Statement Lines**:\n"""\n';

        repeat
            if not HasReservedWords(BankAccReconciliationLine.Description) then begin
                StatementLines += '#Id: ' + Format(BankAccReconciliationLine."Statement Line No.");
                if BankAccReconciliationLine."Document No." <> '' then
                    StatementLines += ', DocumentNo: ' + BankAccReconciliationLine."Document No.";
                StatementLines += ', Description: ' + BankAccReconciliationLine.Description;
                if BankAccReconciliationLine."Additional Transaction Info" <> '' then
                    StatementLines += ' ' + BankAccReconciliationLine."Additional Transaction Info";
                if BankAccReconciliationLine."Payment Reference No." <> '' then
                    StatementLines += ', PaymentReference: ' + BankAccReconciliationLine."Payment Reference No.";
                StatementLines += ', Amount: ' + Format(BankAccReconciliationLine.Difference, 0, 9);
                StatementLines += ', Date: ' + Format(BankAccReconciliationLine."Transaction Date", 0, 9);
                StatementLines += '\n';
            end else
                InputWithReservedWordsFound := true;
        until (BankAccReconciliationLine.Next() = 0);
    end;

    procedure ApproximateTokenCount(TextInput: Text): Decimal
    var
        AverageWordsPerToken: Decimal;
        TokenCount: Integer;
        WordsInInput: Integer;
    begin
        AverageWordsPerToken := 0.6; // Based on OpenAI estimate
        WordsInInput := TextInput.Split(' ', ',', '.', '!', '?', ';', ':', '/n').Count;
        TokenCount := Round(WordsInInput / AverageWordsPerToken, 1);
        exit(TokenCount);
    end;

    procedure RemoveShortWords(Text: Text[250]): Text[250];
    var
        Words: List of [Text];
        Word: Text[250];
        Result: Text[250];
    begin
        Words := Text.Split(' '); // split the text by spaces into a list of words
        foreach Word in Words do // loop through each word in the list
            if StrLen(Word) >= 3 then // check if the word length is at least 3
                Result += Word + ' '; // append the word and a space to the result
        Result := CopyStr(Result.TrimEnd(), 1, MaxStrLen(Result)); // remove the trailing space from the result
        Text := Result; // assign the result back to the text parameter
        exit(Text);
    end;

    procedure ComputeStringNearness(String1: Text[250]; String2: Text[250]): Decimal
    var
        RecordMatchMng: Codeunit "Record Match Mgt.";
        Score: Decimal;
    begin
        String1 := RemoveShortWords(String1);
        String2 := RemoveShortWords(String2);
        Score := RecordMatchMng.CalculateStringNearness(String1, String2, 1, 100) / 100.0;
        exit(Score);
    end;

    procedure PromptSizeThreshold(): Integer
    begin
        // this is because we are using GPT4 which has a 32K token limit
        // on top of that, we are setting aside a number of tokens for the response in MaxTokens())
        exit(18000);
    end;

    procedure MaxTokens(): Integer
    begin
        // this is specifying how many tokens of the AI Model token limit are set aside (reserved) for the response
        exit(4000);
    end;

    [NonDebuggable]
    internal procedure GetAzureKeyVaultSecret(var SecretValue: Text; SecretName: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(SecretName, SecretValue) then
            exit(false);

        if SecretValue = '' then
            exit(false);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Match Bank Rec. Lines", 'OnFindBestMatches', '', false, false)]
    local procedure HandleOnFindBestMatches(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; DaysTolerance: Integer; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; var RemovedPreviouslyAssigned: Boolean; var Handled: Boolean)
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        BankAccRecProposal: Page "Bank Acc. Rec. AI Proposal";
    begin
        if not GuiAllowed() then
            exit;

        if not BankAccReconciliationLine.FindSet() then
            exit;

        TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliationLine."Bank Account No.";
        TempBankAccRecAIProposal."Statement No." := BankAccReconciliationLine."Statement No.";
        TempBankAccRecAIProposal."Statement Type" := BankAccReconciliationLine."Statement Type";
        TempBankAccRecAIProposal.Insert();
        if TempBankAccRecAIProposal.Count() > 0 then begin
            Commit();
            BankAccRecProposal.SetRecord(TempBankAccRecAIProposal);
            BankAccRecProposal.SetStatementNo(BankAccReconciliationLine."Statement No.");
            BankAccRecProposal.SetBankAccountNo(BankAccReconciliationLine."Bank Account No.");
            if BankAccReconciliation.Get(BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.") then begin
                BankAccRecProposal.SetStatementDate(BankAccReconciliation."Statement Date");
                BankAccRecProposal.SetBalanceLastStatement(BankAccReconciliation."Balance Last Statement");
                BankAccRecProposal.SetStatementEndingBalance(BankAccReconciliation."Statement Ending Balance");
                BankAccRecProposal.SetPageCaption(StrSubstNo(ContentAreaCaptionTxt, BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.", BankAccReconciliation."Statement Date"));
            end;
            BankAccRecProposal.SetBankAccReconciliationLines(BankAccReconciliationLine);
            BankAccRecProposal.SetTempBankAccLedgerEntryMatchingBuffer(TempBankAccLedgerEntryMatchingBuffer);
            BankAccRecProposal.SetDaysTolerance(DaysTolerance);
            BankAccRecProposal.SetDisableAttachItButton(true);
            BankAccRecProposal.SetSkipNativeAutoMatchingAlgorithm(true);
            BankAccRecProposal.SetGenerateMode();
            BankAccRecProposal.LookupMode(true);
            if BankAccRecProposal.RunModal() = Action::OK then
                Handled := true;
        end;
    end;

    procedure BuildLedgerEntriesFilter(TopLedgerEntries: array[5] of Record "Ledger Entry Matching Buffer"; TopSimilarityScore: array[5] of Decimal): Text;
    var
        TopBankLedgerEntriesFilterTxt: Text;
        MatchThreshold: Decimal;
        i: Integer;
    begin
        MatchThreshold := 0.5;
        for i := 1 to 5 do
            if TopSimilarityScore[i] >= MatchThreshold then begin
                if TopBankLedgerEntriesFilterTxt = '' then
                    TopBankLedgerEntriesFilterTxt := '='
                else
                    TopBankLedgerEntriesFilterTxt += '|';
                TopBankLedgerEntriesFilterTxt += Format(TopLedgerEntries[i]."Entry No.");
            end;
        exit(TopBankLedgerEntriesFilterTxt);
    end;

    procedure CreateCompletionAndMatch(CompletionPromptTxt: Text; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; DaysTolerance: Integer): Integer
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        CompletionAnswerTxt: Text;
        NumberOfFoundMatches: Integer;
    begin
        NumberOfFoundMatches := 0;

        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Bank Account Reconciliation") then
            exit;

        // Generate OpenAI Completion
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT4Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Bank Account Reconciliation");
        AOAIChatCompletionParams.SetMaxTokens(MaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);
        AOAIChatMessages.AddSystemMessage(CompletionPromptTxt);
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        if AOAIOperationResponse.IsSuccess() then
            CompletionAnswerTxt := AOAIOperationResponse.GetResult()
        else begin
            Session.LogMessage('0000LF7', StrSubstNo(TelemetryChatCompletionErr, AOAIOperationResponse.GetStatusCode()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
            Error(AOAIOperationResponse.GetError());
        end;

        ProcessCompletionAnswer(CompletionAnswerTxt, BankAccReconciliationLine, TempBankAccLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer, NumberOfFoundMatches);
        exit(NumberOfFoundMatches);
    end;

    procedure ProcessCompletionAnswer(var CompletionAnswerTxt: Text; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; var NumberOfFoundMatches: Integer)
    var
        MatchedLedgerEntryNoTxt: Text;
        MatchedStatementLineNoTxt: Text;
        MatchJustificationTxt: Text;
        MatchedEntryNo: Integer;
        MatchedLineNo: Integer;
        MatchTripleTxt: Text;
        FirstOpenParenthesisPos: Integer;
        FirstClosedParenthesisPos: Integer;
        CommaPosition: Integer;
    begin
        if CompletionAnswerTxt = '' then
            exit;

        FirstOpenParenthesisPos := StrPos(CompletionAnswerTxt, '(');
        FirstClosedParenthesisPos := StrPos(CompletionAnswerTxt, ')');
        while (FirstOpenParenthesisPos > 0) and (FirstClosedParenthesisPos > FirstOpenParenthesisPos) do begin
            MatchedLedgerEntryNoTxt := '';
            MatchedStatementLineNoTxt := '';
            MatchTripleTxt := CopyStr(CompletionAnswerTxt, FirstOpenParenthesisPos + 1, FirstClosedParenthesisPos - FirstOpenParenthesisPos - 1);
            CompletionAnswerTxt := CopyStr(CompletionAnswerTxt, FirstClosedParenthesisPos + 1);
            FirstOpenParenthesisPos := StrPos(CompletionAnswerTxt, '(');
            FirstClosedParenthesisPos := StrPos(CompletionAnswerTxt, ')');
            if StrPos(MatchTripleTxt, ', [') - 1 > 0 then begin

                MatchedStatementLineNoTxt := CopyStr(MatchTripleTxt, 1, StrPos(MatchTripleTxt, ', [') - 1);
                MatchTripleTxt := CopyStr(MatchTripleTxt, StrPos(MatchTripleTxt, '[') + 1, StrLen(MatchTripleTxt) - StrPos(MatchTripleTxt, '[') - 1);

                while StrLen(MatchTripleTxt) > 0 do begin
                    CommaPosition := StrPos(MatchTripleTxt, ',');
                    if CommaPosition = 0 then begin
                        MatchedLedgerEntryNoTxt := MatchTripleTxt;
                        MatchedLedgerEntryNoTxt := CopyStr(MatchedLedgerEntryNoTxt, 1, StrLen(MatchedLedgerEntryNoTxt));
                        MatchTripleTxt := '';
                    end else begin
                        MatchedLedgerEntryNoTxt := CopyStr(MatchTripleTxt, 1, CommaPosition - 1);
                        MatchTripleTxt := CopyStr(MatchTripleTxt, CommaPosition + 1);
                    end;

                    MatchedLedgerEntryNoTxt := MatchedLedgerEntryNoTxt.Trim();
                    MatchedStatementLineNoTxt := MatchedStatementLineNoTxt.Trim();

                    if MatchIsAcceptable(BankAccReconciliationLine, TempBankAccLedgerEntryMatchingBuffer, MatchedStatementLineNoTxt, MatchedLedgerEntryNoTxt) then begin
                        Evaluate(MatchedEntryNo, MatchedLedgerEntryNoTxt);
                        Evaluate(MatchedLineNo, MatchedStatementLineNoTxt);
                        MatchJustificationTxt := MatchedByCopilotTxt;
                        TempBankStatementMatchingBuffer.Reset();
                        TempBankStatementMatchingBuffer."Entry No." := MatchedEntryNo;
                        TempBankStatementMatchingBuffer."Line No." := MatchedLineNo;
                        TempBankStatementMatchingBuffer."Match Details" := CopyStr(MatchJustificationTxt, 1, MaxStrLen(TempBankStatementMatchingBuffer."Match Details"));
                        if not TempBankStatementMatchingBuffer.Insert() then
                            exit
                        else
                            NumberOfFoundMatches += 1;
                    end;
                end;
            end;
        end;
    end;

    procedure GenerateMatchProposals(var TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; DaysTolerance: Integer)
    var
        BankAccReconciliationLineCopy: Record "Bank Acc. Reconciliation Line";
        TopLedgerEntries: array[5] of Record "Ledger Entry Matching Buffer";
        LocalBankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CompletionTaskTxt: Text;
        CompletionPromptTxt: Text;
        BankRecLedgerEntriesTxt: Text;
        BankRecStatementLinesTxt: Text;
        TopBankLedgerEntriesFilterTxt: Text;
        NewLineChar: Char;
        i, j, CompletePromptTokenCount, TaskPromptTokenCount : Integer;
        SimilarityScore: Decimal;
        TopSimilarityScore: array[5] of Decimal;
        BankRecLineDescription: Text;
        AmountEquals: Boolean;
        EntryAddedToTop5: Boolean;
    begin
        NewLineChar := 10;
        TempBankAccLedgerEntryMatchingBuffer.RESET();
        TempBankStatementMatchingBuffer.RESET();
        BankAccReconciliationLine.SetFilter(Difference, '<>0');

        if not TempBankAccLedgerEntryMatchingBuffer.IsEmpty() then begin
            FeatureTelemetry.LogUptake('0000LF5', FeatureName(), Enum::"Feature Uptake Status"::Used);
            FeatureTelemetry.LogUsage('0000LF6', FeatureName(), 'Match proposals');
            // Initialize the counts
            CompletionTaskTxt := BuildBankRecCompletionTask(true);
            TaskPromptTokenCount := ApproximateTokenCount(CompletionTaskTxt);

            // Iterate through each statement line
            BankAccReconciliationLine.FindSet();
            repeat
                // Find the top 5 ledger entries closest to the statement line
                TempBankAccLedgerEntryMatchingBuffer.RESET();
                TempBankAccLedgerEntryMatchingBuffer.FindSet();

                // Initialize TopLedgerEntries and TopSimilarityScore
                for i := 1 to 5 do begin
                    TopLedgerEntries[i].RESET();
                    TopSimilarityScore[i] := 0;
                end;

                repeat
                    BankRecLineDescription := BankAccReconciliationLine.Description;
                    if BankAccReconciliationLine."Additional Transaction Info" <> '' then
                        BankRecLineDescription += (' ' + BankAccReconciliationLine."Additional Transaction Info");

                    EntryAddedToTop5 := false;
                    SimilarityScore := ComputeStringNearness(TempBankAccLedgerEntryMatchingBuffer."Description" + ' ' + TempBankAccLedgerEntryMatchingBuffer."Document No.", CopyStr(BankRecLineDescription, 1, 250));
                    AmountEquals := (TempBankAccLedgerEntryMatchingBuffer."Remaining Amount" = BankAccReconciliationLine.Difference);

                    for i := 1 to 5 do
                        if (SimilarityScore > TopSimilarityScore[i]) then begin
                            // Shift the entries down to make room for the new entry
                            for j := 5 downto i + 1 do begin
                                TopLedgerEntries[j] := TopLedgerEntries[j - 1];
                                TopSimilarityScore[j] := TopSimilarityScore[j - 1];
                            end;

                            // Add the new entry
                            TopLedgerEntries[i] := TempBankAccLedgerEntryMatchingBuffer;
                            TopSimilarityScore[i] := SimilarityScore;
                            EntryAddedToTop5 := true;
                            break;
                        end;

                    // make sure to add the entry with equal amount either in the middle or at least as the worst similar of the top 5
                    if not EntryAddedToTop5 and AmountEquals then
                        for i := 1 to 5 do
                            if (TopSimilarityScore[i] = 0) or (i = 5) then begin
                                // Add the new entry
                                TopLedgerEntries[i] := TempBankAccLedgerEntryMatchingBuffer;
                                TopSimilarityScore[i] := SimilarityScore;
                                EntryAddedToTop5 := true;
                                break;
                            end;

                until (TempBankAccLedgerEntryMatchingBuffer.Next() = 0);

                InputWithReservedWordsFound := false;

                // Generate Prompt using the Statement Line and the Top 5 Ledger Entries
                BankAccReconciliationLineCopy.Copy(BankAccReconciliationLine);
                BankAccReconciliationLineCopy.SetFilter("Statement Line No.", '=%1', BankAccReconciliationLine."Statement Line No.");
                BankAccReconciliationLineCopy.FindSet();
                BuildBankRecStatementLines(BankRecStatementLinesTxt, BankAccReconciliationLineCopy);

                // Apply filters to the ledger entries (TempBankAccLedgerEntryMatchingBuffer) from the top 5 ledger entries.
                TopBankLedgerEntriesFilterTxt := BuildLedgerEntriesFilter(TopLedgerEntries, TopSimilarityScore);
                TempBankAccLedgerEntryMatchingBuffer.SetFilter("Entry No.", TopBankLedgerEntriesFilterTxt);
                TempBankAccLedgerEntryMatchingBuffer.FindSet();
                BuildBankRecLedgerEntries(BankRecLedgerEntriesTxt, TempBankAccLedgerEntryMatchingBuffer);

                CompletePromptTokenCount := TaskPromptTokenCount + ApproximateTokenCount(BankRecStatementLinesTxt) + ApproximateTokenCount(BankRecLedgerEntriesTxt);
                if (CompletePromptTokenCount >= PromptSizeThreshold()) then begin
                    Session.LogMessage('0000LFK', TelemetryApproximateTokenCountExceedsLimitTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
                    CompletionPromptTxt := BuildBankRecCompletionPrompt(CompletionTaskTxt, BankRecStatementLinesTxt, BankRecLedgerEntriesTxt);
                    CompletionPromptTxt := CompletionPromptTxt.Replace('\n', NewLineChar);
                    CreateCompletionAndMatch(CompletionPromptTxt, BankAccReconciliationLine, TempBankAccLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer, DaysTolerance);
                    BankRecStatementLinesTxt := '';
                    BankRecLedgerEntriesTxt := '';
                end;
            until (BankAccReconciliationLine.Next() = 0);

            // If BankRecStatementLinesTxt and BankRecLedgerEntriesTxt are not empty, then we need to generate a prompt for the remaining records
            if (BankRecStatementLinesTxt <> '') and (BankRecLedgerEntriesTxt <> '') then begin
                CompletionPromptTxt := BuildBankRecCompletionPrompt(CompletionTaskTxt, BankRecStatementLinesTxt, BankRecLedgerEntriesTxt);
                CompletionPromptTxt := CompletionPromptTxt.Replace('\n', NewLineChar);
                CreateCompletionAndMatch(CompletionPromptTxt, BankAccReconciliationLine, TempBankAccLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer, DaysTolerance);
            end;

            TempBankStatementMatchingBuffer.Reset();
            if TempBankStatementMatchingBuffer.FindSet() then
                repeat
                    if LocalBankAccountLedgerEntry.Get(TempBankStatementMatchingBuffer."Entry No.") then
                        if BankAccReconciliationLineCopy.Get(BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.", TempBankStatementMatchingBuffer."Line No.") then
                            if BankAccReconciliationLineCopy.Difference <> 0 then begin
                                TempBankAccRecAIProposal."Statement Type" := BankAccReconciliationLineCopy."Statement Type"::"Bank Reconciliation";
                                TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliationLineCopy."Bank Account No.";
                                TempBankAccRecAIProposal."Statement No." := BankAccReconciliationLineCopy."Statement No.";
                                TempBankAccRecAIProposal."Statement Line No." := TempBankStatementMatchingBuffer."Line No.";
                                TempBankAccRecAIProposal.Description := BankAccReconciliationLineCopy.Description;
                                TempBankAccRecAIProposal."Transaction Date" := BankAccReconciliationLineCopy."Transaction Date";
                                TempBankAccRecAIProposal.Difference := BankAccReconciliationLineCopy.Difference;
                                TempBankAccRecAIProposal.Validate("Bank Account Ledger Entry No.", TempBankStatementMatchingBuffer."Entry No.");
                                TempBankAccRecAIProposal."G/L Account No." := '';
                                TempBankAccRecAIProposal.Insert();
                            end;
                until TempBankStatementMatchingBuffer.Next() = 0;
        end;
    end;

    procedure HasReservedWords(Input: Text): Boolean
    begin
        if StrPos(LowerCase(Input), '<|im_start|>') > 0 then
            exit(true);

        if StrPos(LowerCase(Input), '<|im_end|>') > 0 then
            exit(true);

        if StrPos(LowerCase(Input), '<|start|>') > 0 then
            exit(true);

        if StrPos(LowerCase(Input), '<|end|>') > 0 then
            exit(true);

        exit(false)
    end;

    procedure ApplyToProposedLedgerEntries(var TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary; var TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Integer
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        MatchBankRecLines: Codeunit "Match Bank Rec. Lines";
        StatementLines: List of [Integer];
    begin
        TempBankStatementMatchingBuffer.DeleteAll();
        TempBankAccRecAIProposal.Reset();
        TempBankAccRecAIProposal.SetFilter("Bank Account Ledger Entry No.", '<>0');
        if TempBankAccRecAIProposal.FindSet() then begin
            repeat
                if BankAccReconciliationLine.Get(TempBankAccRecAIProposal."Statement Type", TempBankAccRecAIProposal."Bank Account No.", TempBankAccRecAIProposal."Statement No.", TempBankAccRecAIProposal."Statement Line No.") then
                    if BankAccountLedgerEntry.Get(TempBankAccRecAIProposal."Bank Account Ledger Entry No.") then begin
                        TempBankStatementMatchingBuffer."Entry No." := BankAccountLedgerEntry."Entry No.";
                        TempBankStatementMatchingBuffer."Line No." := BankAccReconciliationLine."Statement Line No.";
                        TempBankStatementMatchingBuffer."Match Details" := CopyStr(MatchedByCopilotTxt, 1, MaxStrLen(TempBankStatementMatchingBuffer."Match Details"));
                        TempBankStatementMatchingBuffer.Insert();
                        if not StatementLines.Contains(TempBankAccRecAIProposal."Statement Line No.") then
                            StatementLines.Add(TempBankAccRecAIProposal."Statement Line No.");
                    end;
            until TempBankAccRecAIProposal.Next() = 0;
            MatchBankRecLines.SaveManyToOneMatching(TempBankStatementMatchingBuffer, BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.");
            MatchBankRecLines.SaveOneToOneMatching(TempBankStatementMatchingBuffer, BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.");
            exit(StatementLines.Count());
        end;
    end;

    procedure FeatureName(): Text
    begin
        exit('Bank Account Reconciliation with AI');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", 'OnRegisterCopilotCapability', '', false, false)]
    local procedure HandleOnRegisterCopilotCapability()
    begin
        RegisterCapability();
    end;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;

        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetRegisterBankAccRecCopilotCapabilityUpgradeTag()) then
            exit;

        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Bank Account Reconciliation") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Bank Account Reconciliation", LearnMoreUrlTxt);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetRegisterBankAccRecCopilotCapabilityUpgradeTag());
    end;

    local procedure MatchIsAcceptable(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; MatchedLineNoTxt: Text; MatchedEntryNoTxt: Text): Boolean
    var
        LocalBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        MatchedEntryNo: Integer;
        MatchedLineNo: Integer;
    begin
        if not Evaluate(MatchedEntryNo, MatchedEntryNoTxt) then
            exit(false);

        if not Evaluate(MatchedLineNo, MatchedLineNoTxt) then
            exit(false);

        TempLedgerEntryMatchingBuffer.Reset();
        TempLedgerEntryMatchingBuffer.SetRange("Entry No.", MatchedEntryNo);
        if not TempLedgerEntryMatchingBuffer.FindFirst() then
            exit(false);

        if not LocalBankAccReconciliationLine.Get(BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.", MatchedLineNo) then
            exit(false);

        if not SameSign(LocalBankAccReconciliationLine.Difference, TempLedgerEntryMatchingBuffer."Remaining Amount") then
            exit(false);

        exit(true)
    end;

    local procedure SameSign(Amount1: Decimal; Amount2: Decimal): Boolean
    begin
        if (Amount1 = 0) or (Amount2 = 0) then
            exit(false);
        exit((Amount1 div Abs(Amount1)) = (Amount2 div Abs(Amount2)));
    end;

    procedure FoundInputWithReservedWords(): Boolean
    begin
        exit(InputWithReservedWordsFound)
    end;

    var
        MatchedByCopilotTxt: label 'Matched by Copilot based on semantic similarity.', Comment = 'Copilot is a Microsoft service name and must not be translated';
        ConstructingPromptFailedErr: label 'There was an error with sending the call to Copilot. Log a Business Central support request about this.', Comment = 'Copilot is a Microsoft service name and must not be translated';
        TelemetryConstructingPromptFailedErr: label 'There was an error with constructing the chat completion prompt from the Key Vault.', Locked = true;
        TelemetryApproximateTokenCountExceedsLimitTxt: label 'The approximate token count for the Copilot request exceeded the limit. Sending request in chunks.', Locked = true;
        TelemetryChatCompletionErr: label 'Chat completion request was unsuccessful. Response code: %1', Locked = true;
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2248547', Locked = true;
        ContentAreaCaptionTxt: label 'Reconciling %1 statement %2 for %3', Comment = '%1 - bank account code, %2 - statement number, %3 - statement date';
        InputWithReservedWordsFound: Boolean;
}