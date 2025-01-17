// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Automation;

codeunit 31397 "Approvals Management CZL"
{
    var
        UnsupportedRecordTypeErr: Label 'Record type %1 is not supported by this workflow response.', Comment = '%1 = record type; Record type Customer is not supported by this workflow response.';

    procedure SetStatusToApproved(var Variant: Variant)
    var
        ApprovalEntry: Record "Approval Entry";
        TargetRecordRef: RecordRef;
        InputRecordRef: RecordRef;
        IsHandled: Boolean;
    begin
        OnBeforeSetStatusToApproved(Variant);
        InputRecordRef.GetTable(Variant);

        case InputRecordRef.Number of
            Database::"Approval Entry":
                begin
                    ApprovalEntry := Variant;
                    TargetRecordRef.Get(ApprovalEntry."Record ID to Approve");
                    Variant := TargetRecordRef;
                    SetStatusToApproved(Variant);
                end;
            else begin
                IsHandled := false;
                OnSetStatusToApproved(InputRecordRef, Variant, IsHandled);
                if not IsHandled then
                    Error(UnsupportedRecordTypeErr, InputRecordRef.Caption);
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetStatusToApproved(var Variant: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetStatusToApproved(InputRecordRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    begin
    end;
}
