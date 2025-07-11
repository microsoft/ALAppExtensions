// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.FixedAsset;

codeunit 31234 "FA Insert G/L Acc. Handler CZF"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        ReasonMaintenanceCode: Code[10];

    procedure SetReasonMaintenanceCode(NewReasonMaintenanceCode: Code[10]);
    begin
        ReasonMaintenanceCode := NewReasonMaintenanceCode;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Insert G/L Account", 'OnBeforeGetGLAccNoFromFAPostingGroup', '', false, false)]
    local procedure OnBeforeGetGLAccNoFromFAPostingGroup(FAPostingGroup: Record "FA Posting Group"; FAPostingGroupAccountType: Enum "FA Posting Group Account Type"; var GLAccNo: Code[20]; var IsHandled: Boolean);
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
        NotMoreThan100Err: Label 'must not be more than 100';
    begin
        if IsHandled then
            exit;

        case FAPostingGroupAccountType of
            FAPostingGroupAccountType::Maintenance:
                if not FAPostingGroup.UseStandardMaintenanceCZF(ReasonMaintenanceCode) then begin
                    FAExtendedPostingGroupCZF.Get(FAPostingGroup.Code, FAExtendedPostingGroupCZF."FA Posting Type"::Maintenance, ReasonMaintenanceCode);
                    GLAccNo := FAExtendedPostingGroupCZF.GetExtendedMaintenanceBalanceAccount();
                    FAExtendedPostingGroupCZF.CalcFields("Allocated Maintenance %");
                    if FAExtendedPostingGroupCZF."Allocated Maintenance %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Maintenance %", NotMoreThan100Err);
                end else begin
                    GLAccNo := FAPostingGroup.GetMaintenanceBalanceAccount();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Maintenance %");
                    if FAPostingGroup."Allocated Maintenance %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Maintenance %", NotMoreThan100Err);
                end;
            FAPostingGroupAccountType::"Book Value Gain":
                if not FAPostingGroup.UseStandardDisposalCZF(ReasonMaintenanceCode) then begin
                    FAExtendedPostingGroupCZF.Get(FAPostingGroup.Code, FAExtendedPostingGroupCZF."FA Posting Type"::Disposal, ReasonMaintenanceCode);
                    GLAccNo := FAExtendedPostingGroupCZF.GetBookValueAccountOnDisposalGain();
                    FAExtendedPostingGroupCZF.CalcFields("Allocated Book Value % (Gain)");
                    if FAExtendedPostingGroupCZF."Allocated Book Value % (Gain)" > 100 then
                        FAExtendedPostingGroupCZF.FieldError("Allocated Book Value % (Gain)", NotMoreThan100Err);
                end else begin
                    GLAccNo := FAPostingGroup.GetBookValueAccountOnDisposalGain();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Book Value % (Gain)");
                    if FAPostingGroup."Allocated Book Value % (Gain)" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Book Value % (Gain)", NotMoreThan100Err);
                end;
            FAPostingGroupAccountType::"Book Value Loss":
                if not FAPostingGroup.UseStandardDisposalCZF(ReasonMaintenanceCode) then begin
                    FAExtendedPostingGroupCZF.Get(FAPostingGroup.Code, FAExtendedPostingGroupCZF."FA Posting Type"::Disposal, ReasonMaintenanceCode);
                    GLAccNo := FAExtendedPostingGroupCZF.GetBookValueAccountOnDisposalLoss();
                    FAExtendedPostingGroupCZF.CalcFields("Allocated Book Value % (Loss)");
                    if FAExtendedPostingGroupCZF."Allocated Book Value % (Loss)" > 100 then
                        FAExtendedPostingGroupCZF.FieldError("Allocated Book Value % (Loss)", NotMoreThan100Err);
                end else begin
                    GLAccNo := FAPostingGroup.GetBookValueAccountOnDisposalLoss();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Book Value % (Loss)");
                    if FAPostingGroup."Allocated Book Value % (Loss)" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Book Value % (Loss)", NotMoreThan100Err);
                end;
            else
                exit;
        end;

        IsHandled := true;
    end;
}