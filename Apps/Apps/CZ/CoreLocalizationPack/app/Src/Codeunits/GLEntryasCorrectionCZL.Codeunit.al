// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31158 "G/L Entry as Correction CZL"
{
    Access = Internal;
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        EnableTime: Time;
        EnableDuration: Duration;
        InsertGLEntryCategoryTok: Label 'Insert G/L Entry', Locked = true;
        TimedoutErr: Label 'The manual binding for the OnBeforeInsertGlEntry event subscriber timed out.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGlEntry', '', false, false)]
    local procedure SetCorrectionOnBeforeInsertGlEntry(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if (Time - EnableTime > EnableDuration) then begin
            Disable();
            Session.LogMessage('0000NFW', TimedoutErr, Verbosity::Warning, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', InsertGLEntryCategoryTok);
            exit;
        end;
        GenJnlLine.Correction := true;
    end;

    procedure Enable(): Boolean
    begin
        exit(Enable(DefaultDuration()));
    end;

    procedure Enable(Duration: Duration): Boolean
    begin
        EnableTime := Time;
        EnableDuration := Duration;
        exit(BindSubscription(this));
    end;

    procedure Disable(): Boolean
    begin
        ClearAll();
        exit(UnbindSubscription(this));
    end;

    local procedure DefaultDuration(): Integer
    begin
        exit(5000);
    end;
}