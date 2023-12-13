// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Dimension;

using Microsoft.Utilities;
using System.Security.User;
using System.Utilities;

codeunit 31318 "Dimension Mgt. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement, 'OnCheckDimValuePostingOnBeforeExit', '', false, false)]
    local procedure UserChecksAllowedOnCheckDimValuePostingOnBeforeExit(DimSetID: Integer; var LastErrorMessage: Record "Error Message"; var ErrorMessageManagement: Codeunit "Error Message Management";
                                                                        var IsChecked: Boolean; var IsHandled: Boolean)
    var
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        LastErrorID: Integer;
    begin
        if not IsUserDimCheckAllowed(UserSetup) then
            exit;

        if DimSetID <> 0 then
            GetDimBufForDimSetID(DimSetID, TempDimensionBuffer);
        LastErrorID := GetLastDimErrorID(LastErrorMessage, ErrorMessageManagement);
        CheckUserDimensionValues(TempDimensionBuffer, LastErrorMessage, ErrorMessageManagement);
        IsChecked := GetLastDimErrorID(LastErrorMessage, ErrorMessageManagement) = LastErrorID;
        IsHandled := true;
    end;

    local procedure GetLastDimErrorID(var LastErrorMessage: Record "Error Message"; var ErrorMessageManagement: Codeunit "Error Message Management"): Integer
    begin
        if ErrorMessageManagement.IsActive() then
            exit(ErrorMessageManagement.GetCachedLastErrorID());
        exit(LastErrorMessage.ID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement, 'OnCheckValuePostingOnBeforeExit', '', false, false)]
    local procedure UserChecksAllowedOnCheckValuePostingOnBeforeExit(var TempDimensionBuffer: Record "Dimension Buffer"; var LastErrorMessage: Record "Error Message"; var ErrorMessageManagement: Codeunit "Error Message Management")
    begin
        if not IsUserDimCheckAllowed(UserSetup) then
            exit;

        CheckUserDimensionValues(TempDimensionBuffer, LastErrorMessage, ErrorMessageManagement);
    end;

    local procedure CheckUserDimensionValues(var TempDimensionBuffer: Record "Dimension Buffer"; var LastErrorMessage: Record "Error Message"; var ErrorMessageManagement: Codeunit "Error Message Management")
    var
        SelectedDimension: Record "Selected Dimension";
    begin
        SelectedDimension.SetRange("User ID", UserSetup."User ID");
        SelectedDimension.SetRange("Object Type", 1);
        SelectedDimension.SetRange("Object ID", Database::"User Setup");
        if SelectedDimension.FindSet() then
            repeat
                TempDimensionBuffer.SetRange("Dimension Code", SelectedDimension."Dimension Code");
                if TempDimensionBuffer.IsEmpty() then
                    LogError(
                         UserSetup, UserSetup.FieldNo("Check Dimension Values CZL"), StrSubstNo(EnterDimErr, SelectedDimension."Dimension Code"), '', LastErrorMessage, ErrorMessageManagement);

                if SelectedDimension."Dimension Value Filter" <> '' then begin
                    TempDimensionBuffer.SetFilter("Dimension Value Code", SelectedDimension."Dimension Value Filter");
                    if TempDimensionBuffer.IsEmpty() then begin
                        DimErrorText :=
                          StrSubstNo(DimValueErr, TempDimensionBuffer.FieldCaption("Dimension Value Code"),
                            SelectedDimension."Dimension Code", SelectedDimension."Dimension Value Filter");
                        LogError(UserSetup, UserSetup.FieldNo("Check Dimension Values CZL"), DimErrorText, '', LastErrorMessage, ErrorMessageManagement);
                    end;
                    TempDimensionBuffer.SetRange("Dimension Value Code");
                end;
            until SelectedDimension.Next() = 0;
        TempDimensionBuffer.SetRange("Dimension Code");
    end;

    local procedure IsUserDimCheckAllowed(var UserSetup: Record "User Setup"): Boolean
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            if UserId <> '' then
                if UserSetup.Get(UserId) then
                    exit(UserSetup."Check Dimension Values CZL");

        exit(false);
    end;

    local procedure GetDimBufForDimSetID(DimSetID: Integer; var TempDimensionBuffer: Record "Dimension Buffer" temporary)
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        DimensionSetEntry.Reset();
        DimensionSetEntry.SetRange("Dimension Set ID", DimSetID);
        if DimensionSetEntry.FindSet() then
            repeat
                TempDimensionBuffer.Init();
                TempDimensionBuffer."Table ID" := DATABASE::"Dimension Buffer";
                TempDimensionBuffer."Entry No." := 0;
                TempDimensionBuffer."Dimension Code" := DimensionSetEntry."Dimension Code";
                TempDimensionBuffer."Dimension Value Code" := DimensionSetEntry."Dimension Value Code";
                TempDimensionBuffer.Insert();
            until DimensionSetEntry.Next() = 0;
    end;

    local procedure LogError(SourceRecVariant: Variant; SourceFieldNo: Integer; Message: Text; HelpArticleCode: Code[30]; var LastErrorMessage: Record "Error Message"; var ErrorMessageManagement: Codeunit "Error Message Management")
    var
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
    begin
        if ErrorMessageExists(ErrorMessageManagement, Message) then
            exit;

        if ErrorMessageManagement.IsActive() then begin
            if HelpArticleCode = '' then
                HelpArticleCode := ForwardLinkMgt.GetHelpCodeForWorkingWithDimensions();
            ErrorMessageManagement.LogContextFieldError(0, Message, SourceRecVariant, SourceFieldNo, HelpArticleCode);
        end else begin
            LastErrorMessage.Init();
            LastErrorMessage.ID += 1;
            LastErrorMessage."Message" := CopyStr(Message, 1, MaxStrLen(LastErrorMessage."Message"));
        end;
    end;

    local procedure ErrorMessageExists(ErrorMessagemanagement: Codeunit "Error Message Management"; Message: Text): Boolean
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        ErrorMessageManagement.GetErrors(TempErrorMessage);

        TempErrorMessage.SetRange("Message", CopyStr(Message, 1, MaxStrLen(TempErrorMessage."Message")));
        exit(not (TempErrorMessage.IsEmpty()));
    end;

    var
        UserSetup: Record "User Setup";
        DimErrorText: Text;
        EnterDimErr: Label 'You must enter dimension %1.', Comment = '%1 = dimension code';
        DimValueErr: Label '%1 %2 must match the filter %3.', Comment = '%1 = fieldcaption of dimension value code; %2 = dimension code; %3 = dimension value code';
}
