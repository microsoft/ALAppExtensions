// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using System.Utilities;
using System.Telemetry;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.Dimension;
codeunit 7905 ErrorMessagesActionHandlerImpl
{
    Access = Internal;

    var
        ConfirmationPrefixQuestionLbl: Label '%1?', Comment = '%1 = Set value to HOME';
        AcceptRecommendationTok: Label 'The recommendations will be applied to %1 error messages. \\Do you want to continue?', Comment = '%1 - selected count';
        AcceptRecommendationPartialTok: Label 'The recommendations will be applied to %1 out of %2 selected error messages. \\Do you want to continue?', Comment = '%1 - count of actionable error messages, %2 = Total selected count';
        FixedAllAckLbl: Label 'All of your selections were processed.';
        FixedPartialAckLbl: Label 'Recommendations applied: %1 \Failed to apply the recommendation: %2', Comment = '%1=Fixed Count, %2=Failed to fix count';

    internal procedure GetFeatureTelemetryName(): Text
    begin
        exit('Error Messages with Recommended Actions');
    end;

    local procedure IsActionable(var TempErrorMessage: Record "Error Message"): Boolean
    begin
        if (TempErrorMessage."Message Status" = TempErrorMessage."Message Status"::Fixed) then
            exit(false);

        if TempErrorMessage."Error Msg. Fix Implementation" = TempErrorMessage."Error Msg. Fix Implementation"::" " then
            exit(false);

        exit(true);
    end;

    procedure OnRecommendedActionDrillDown(var ErrorMessage: Record "Error Message")
    begin
        if IsActionable(ErrorMessage) then
            InvokeErrorConfirmDialog(ErrorMessage);
    end;

    local procedure InvokeErrorConfirmDialog(var ErrorMessage: Record "Error Message")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000LH5', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up");
        if Dialog.Confirm(StrSubstNo(ConfirmationPrefixQuestionLbl, ErrorMessage."Recommended Action Caption") + '\\' + ErrorMessage.Message) then begin
            FeatureTelemetry.LogUptake('0000LH6', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
            ExecuteAction(ErrorMessage, true);

            // Log usage telemetry, ExecuteAction(...) logs the error
            if ErrorMessage."Message Status" = ErrorMessage."Message Status"::Fixed then
                FeatureTelemetry.LogUsage('0000KDA', GetFeatureTelemetryName(), 'Execute action using drilldown');
        end
    end;

    procedure ExecuteActions(var SelectedErrorMessage: Record "Error Message" temporary)
    var
        TempErrorMessageFilters: Record "Error Message" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CustomDimensions: Dictionary of [Text, Text];
        ErrorsToFixCount: Integer;
        TotalSelectedCount: Integer;
        xFixedCount: Integer;
        FixedCount: Integer;
        FailedToFixCount: Integer;
        ConfirmationMsg: Text;
        AckLabel: Text;
    begin
        TempErrorMessageFilters.CopyFilters(SelectedErrorMessage);
        TotalSelectedCount := SelectedErrorMessage.Count();

        SelectedErrorMessage.SetFilter("Error Msg. Fix Implementation", '<>%1', Enum::"Error Msg. Fix Implementation"::" ");
        SelectedErrorMessage.SetRange("Message Status", SelectedErrorMessage."Message Status"::Fixed);
        xFixedCount := SelectedErrorMessage.Count();

        SelectedErrorMessage.SetFilter("Message Status", '<>%1', SelectedErrorMessage."Message Status"::Fixed);
        ErrorsToFixCount := SelectedErrorMessage.Count();

        LogSetupStateForBulkFixToTelemetry(CustomDimensions, SelectedErrorMessage, TotalSelectedCount, ErrorsToFixCount);

        if SelectedErrorMessage.FindSet() then begin
            if ErrorsToFixCount < TotalSelectedCount then
                ConfirmationMsg := StrSubstNo(AcceptRecommendationPartialTok, ErrorsToFixCount, TotalSelectedCount)
            else
                ConfirmationMsg := StrSubstNo(AcceptRecommendationTok, ErrorsToFixCount);

            if Dialog.Confirm(ConfirmationMsg, true) then begin
                FeatureTelemetry.LogUptake('0000LH9', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used, CustomDimensions);
                repeat
                    ExecuteAction(SelectedErrorMessage, false);
                until SelectedErrorMessage.Next() = 0;

                SelectedErrorMessage.SetRange("Message Status", SelectedErrorMessage."Message Status"::Fixed);
                FixedCount := SelectedErrorMessage.Count();

                FailedToFixCount := ErrorsToFixCount - (FixedCount - xFixedCount);

                if FailedToFixCount = 0 then //Everything is fixed.
                    AckLabel := FixedAllAckLbl
                else //Some of the errors are fixed.
                    AckLabel := StrSubstNo(FixedPartialAckLbl, FixedCount - xFixedCount, FailedToFixCount);

                // Log usage telemetry when at least of one of the errors were fixed. ExecuteAction(...) logs the error
                if FixedCount > xFixedCount then begin
                    CustomDimensions.Add('FixedErrors', Format(FixedCount - xFixedCount));
                    FeatureTelemetry.LogUsage('0000KDB', GetFeatureTelemetryName(), 'Accept recommended actions', CustomDimensions);
                end;

                Message(AckLabel);
            end;
        end;
        SelectedErrorMessage.CopyFilters(TempErrorMessageFilters);
    end;

    local procedure ExecuteAction(var TempErrorMessage: Record "Error Message" temporary; ShowMsg: Boolean)
    var
        ErrorMessage: Record "Error Message";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Telemetry: Codeunit Telemetry;
        ErrorMessageFixProvider: Interface ErrorMessageFix;
        ErrorMessageFixImplementationName: Text;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        // Execute the recommended action. If the action fails, continue to the next error message by updating the error message status.
        ErrorMessageFixProvider := TempErrorMessage."Error Msg. Fix Implementation";
        ErrorMessageFixImplementationName := TempErrorMessage."Error Msg. Fix Implementation".Names.Get(TempErrorMessage."Error Msg. Fix Implementation".Ordinals.IndexOf(TempErrorMessage."Error Msg. Fix Implementation".AsInteger()));
        Telemetry.LogMessage('0000LHH', 'Error Msg. Fix Implementation: ' + ErrorMessageFixImplementationName, Verbosity::Normal, DataClassification::SystemMetadata);
        if ExecuteActionWithCollectErr(TempErrorMessage, ErrorMessageFixProvider) then begin
            TempErrorMessage."Message Status" := TempErrorMessage."Message Status"::Fixed;
            TempErrorMessage.Modify();
            if ShowMsg then
                Message(ErrorMessageFixProvider.OnSuccessMessage());
        end
        else begin
            CustomDimensions.Add('Error Msg. Fix Implementation', ErrorMessageFixImplementationName);
            FeatureTelemetry.LogError('0000KD9', GetFeatureTelemetryName(), 'Execute action', GetLastErrorText(true), GetLastErrorCallStack(), CustomDimensions);
            TempErrorMessage."Message Status" := TempErrorMessage."Message Status"::"Failed to fix";
            TempErrorMessage.Modify();
        end;

        // Transfer the changes to the registered error message if it exists.
        if ErrorMessage.GetBySystemId(TempErrorMessage."Reg. Err. Msg. System ID") then begin
            ErrorMessage."Message Status" := TempErrorMessage."Message Status";
            ErrorMessage.Modify();
        end;
    end;

    local procedure LogSetupStateForBulkFixToTelemetry(var CustomDimensions: Dictionary of [Text, Text]; var SelectedErrorMessage: Record "Error Message" temporary; TotalSelectedCount: Integer; ErrorsToFixCount: Integer)
    var
        TempTotalErrorsOnPage: Record "Error Message" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        TempTotalErrorsOnPage.Copy(SelectedErrorMessage, true);
        TempTotalErrorsOnPage.Reset();
        CustomDimensions.Add('TotalErrorsOnPage', Format(TempTotalErrorsOnPage.Count()));
        TempTotalErrorsOnPage.SetFilter("Error Msg. Fix Implementation", '<>%1', Enum::"Error Msg. Fix Implementation"::" ");
        TempTotalErrorsOnPage.SetFilter("Message Status", '<>%1', TempTotalErrorsOnPage."Message Status"::Fixed);
        CustomDimensions.Add('TotalFixableErrorsOnPage', Format(TempTotalErrorsOnPage.Count()));
        CustomDimensions.Add('SelectedErrors', Format(TotalSelectedCount));
        CustomDimensions.Add('SelectedFixableErrors', Format(ErrorsToFixCount));
        FeatureTelemetry.LogUptake('0000LH8', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up", CustomDimensions);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    [CommitBehavior(CommitBehavior::Ignore)]
    local procedure ExecuteActionWithCollectErr(var TempErrorMessage: Record "Error Message" temporary; var IErrorMessageFixProvider: Interface ErrorMessageFix): Boolean
    var
        ExecuteErrorAction: Codeunit "Execute Error Action";
    begin
        ExecuteErrorAction.SetErrorMessageFixImplementation(IErrorMessageFixProvider);
        if ExecuteErrorAction.Run(TempErrorMessage) then
            exit(true);

        if HasCollectedErrors then
            ClearCollectedErrors();
    end;

    local procedure GetJsonKeyValue(var JObject: JsonObject; KeyName: Text): Text
    var
        JToken: JsonToken;
    begin
        if JObject.Get(KeyName, JToken) then
            exit(JToken.AsValue().AsText());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Error Message Management", OnAddToJsonFromErrorMessage, '', false, false)]
    local procedure OnAddToJsonFromErrorMessageHandler(var JObject: JsonObject; var ErrorMessage: Record "Error Message" temporary)
    begin
        JObject.Add(ErrorMessage.FieldName(Title), ErrorMessage.Title);
        JObject.Add(ErrorMessage.FieldName("Recommended Action Caption"), ErrorMessage."Recommended Action Caption");
        JObject.Add(ErrorMessage.FieldName("Error Msg. Fix Implementation"), ErrorMessage."Error Msg. Fix Implementation".AsInteger());
        JObject.Add(ErrorMessage.FieldName("Message Status"), ErrorMessage."Message Status".AsInteger());

        JObject.Add(ErrorMessage.FieldName("Sub-Context Record ID"), Format(ErrorMessage."Sub-Context Record ID"));
        JObject.Add(ErrorMessage.FieldName("Sub-Context Field Number"), ErrorMessage."Sub-Context Field Number");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Error Message Management", OnAddToErrorMessageFromJson, '', false, false)]
    local procedure OnAddToErrorMessageFromJsonHandler(var ErrorMessage: Record "Error Message" temporary; var JObject: JsonObject)
    begin
        ErrorMessage.Title := CopyStr(GetJsonKeyValue(JObject, ErrorMessage.FieldName(Title)), 1, MaxStrLen(ErrorMessage.Title));
        ErrorMessage."Recommended Action Caption" := CopyStr(GetJsonKeyValue(JObject, ErrorMessage.FieldName("Recommended Action Caption")), 1, MaxStrLen(ErrorMessage."Recommended Action Caption"));
        Evaluate(ErrorMessage."Error Msg. Fix Implementation", GetJsonKeyValue(JObject, ErrorMessage.FieldName("Error Msg. Fix Implementation")));
        Evaluate(ErrorMessage."Message Status", GetJsonKeyValue(JObject, ErrorMessage.FieldName("Message Status")));

        Evaluate(ErrorMessage."Sub-Context Record ID", GetJsonKeyValue(JObject, ErrorMessage.FieldName("Sub-Context Record ID")));
        Evaluate(ErrorMessage."Sub-Context Field Number", GetJsonKeyValue(JObject, ErrorMessage.FieldName("Sub-Context Field Number")));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Error Message", OnDrillDownSource, '', false, false)]
    local procedure OnErrorMessageDrillDown(ErrorMessage: Record "Error Message"; SourceFieldNo: Integer; var IsHandled: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        CheckDimensions: Codeunit "Check Dimensions";
        RecRef: RecordRef;
    begin
        if not IsHandled then
            //When drill down on the sub-context for Dimension Set Entry then open the dimension set entry for the context record.
            if (SourceFieldNo = ErrorMessage.FieldNo("Sub-Context Record ID")) and (ErrorMessage."Sub-Context Record ID".TableNo = Database::"Dimension Set Entry") then
                case ErrorMessage."Context Table Number" of
                    Database::"Gen. Journal Line":
                        if RecRef.Get(ErrorMessage."Context Record ID") then begin
                            RecRef.SetTable(GenJournalLine);
                            if GenJournalLine.ShowDimensions() then
                                GenJournalLine.Modify();
                            IsHandled := true;
                        end;
                    else
                        IsHandled := CheckDimensions.ShowContextDimensions(ErrorMessage."Context Record ID");
                end;
    end;
}