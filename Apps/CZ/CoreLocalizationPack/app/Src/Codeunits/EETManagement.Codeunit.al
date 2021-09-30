codeunit 31118 "EET Management CZL"
{
    Permissions = tabledata "EET Entry CZL" = rimd;

    var
        TempErrorMessage: Record "Error Message" temporary;
        WarningsTxt: Label 'Warnings...';

    procedure IsEETEnabled() EETEnabled: Boolean
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        EETEnabled := EETServiceSetupCZL.Get() and EETServiceSetupCZL.Enabled;
        OnAfterIsEETEnabled(EETEnabled);
    end;

    procedure TrySendEntryToService(EETEntryNo: Integer)
    var
        EETEntryCZL: Record "EET Entry CZL";
    begin
        if not EETEntryCZL.Get(EETEntryNo) then
            exit;

        TrySendEntryToService(EETEntryCZL);
    end;

    procedure TrySendEntryToService(EETEntryCZL: Record "EET Entry CZL")
    begin
        if EETEntryCZL.Status = EETEntryCZL.Status::Created then
            EETEntryCZL.ChangeStatus(EETEntryCZL."Status"::"Send Pending");

        if EETEntryCZL."Sales Regime" = EETEntryCZL."Sales Regime"::Regular then
            SendEntryToService(EETEntryCZL, false);
    end;

    internal procedure SendEntryToService(EETEntryCZL: Record "EET Entry CZL"; VerificationMode: Boolean)
    begin
        EETEntryCZL.TestField("Entry No.");
        TempErrorMessage.ClearLog();
        if not VerificationMode then
            SendEntryToRegister(EETEntryCZL)
        else
            SendEntryToVerification(EETEntryCZL);
    end;

    local procedure SendEntryToRegister(EETEntryCZL: Record "EET Entry CZL")
    var
        EETServiceManagementCZL: Codeunit "EET Service Management CZL";
    begin
        if EETEntryCZL."Status" in [EETEntryCZL."Status"::Sent,
                                    EETEntryCZL."Status"::Success,
                                    EETEntryCZL."Status"::"Success with Warnings"]
        then
            EETEntryCZL.FieldError("Status");

        PrepareEntryToSend(EETEntryCZL);
        EETEntryCZL.ChangeStatus(EETEntryCZL."Status"::Sent);

        if EETServiceManagementCZL.Send(EETEntryCZL) then begin
            EETEntryCZL."Fiscal Identification Code" := EETServiceManagementCZL.GetFIKControlCode();

            if EETServiceManagementCZL.HasWarnings() then begin
                EETServiceManagementCZL.CopyErrorMessageToTemp(TempErrorMessage);
                EETEntryCZL.ChangeStatus(EETEntryCZL."Status"::"Success with Warnings", WarningsTxt, TempErrorMessage);
            end else
                EETEntryCZL.ChangeStatus(EETEntryCZL."Status"::Success);
        end else begin
            EETServiceManagementCZL.CopyErrorMessageToTemp(TempErrorMessage);
            EETEntryCZL.ChangeStatus(EETEntryCZL."Status"::Failure, EETServiceManagementCZL.GetResponseText(), TempErrorMessage);
        end;
    end;

    local procedure SendEntryToVerification(EETEntryCZL: Record "EET Entry CZL")
    var
        EETServiceManagementCZL: Codeunit "EET Service Management CZL";
    begin
        if EETEntryCZL."Status" in [EETEntryCZL."Status"::Sent,
                                    EETEntryCZL."Status"::"Sent to Verification",
                                    EETEntryCZL."Status"::Success,
                                    EETEntryCZL."Status"::"Success with Warnings"]
        then
            EETEntryCZL.FieldError("Status");

        PrepareEntryToSend(EETEntryCZL);
        EETEntryCZL.ChangeStatus(EETEntryCZL."Status"::"Sent to Verification");

        EETServiceManagementCZL.SetVerificationMode(true);
        if EETServiceManagementCZL.Send(EETEntryCZL) then
            if EETServiceManagementCZL.HasWarnings() then begin
                EETServiceManagementCZL.CopyErrorMessageToTemp(TempErrorMessage);
                EETEntryCZL.ChangeStatus(EETEntryCZL."Status"::"Verified with Warnings", WarningsTxt, TempErrorMessage);
            end else
                EETEntryCZL.ChangeStatus(EETEntryCZL."Status"::Verified, EETServiceManagementCZL.GetResponseText())
        else begin
            EETServiceManagementCZL.CopyErrorMessageToTemp(TempErrorMessage);
            EETEntryCZL.ChangeStatus(EETEntryCZL."Status"::Failure, EETServiceManagementCZL.GetResponseText(), TempErrorMessage);
        end;
    end;

    local procedure PrepareEntryToSend(var EETEntryCZL: Record "EET Entry CZL")
    begin
        EETEntryCZL.GenerateControlCodes(false);
        EETEntryCZL."Message UUID" := CreateUUID();
        EETEntryCZL.Modify();
    end;

    procedure CreateUUID(): Text[36]
    begin
        exit(CopyStr(DelChr(LowerCase(Format(CreateGuid())), '=', '{}'), 1, 36));
    end;

    procedure CreateCancelEETEntry(EETEntryCZL: Record "EET Entry CZL"): Integer
    var
        CancelEETEntryNo: Integer;
        IsHandled: Boolean;
    begin
        OnBeforeCreateCancelEETEntry(EETEntryCZL, CancelEETEntryNo, IsHandled);
        if IsHandled then
            exit(CancelEETEntryNo);

        EETEntryCZL.ReverseAmounts();
        exit(CreateSimpleEETEntry(EETEntryCZL));
    end;

    procedure CreateSimpleEETEntry(SourceEETEntryCZL: Record "EET Entry CZL"): Integer
    var
        EETEntryCZL: Record "EET Entry CZL";
    begin
        EETEntryCZL.Init();
        EETEntryCZL.CopyFromEETEntry(SourceEETEntryCZL);
        EETEntryCZL."Receipt Serial No." := '';
        EETEntryCZL."Simple Registration" := true;
        OnCreateSimpleEETEntryOnBeforeInsertEETEntry(EETEntryCZL);
        EETEntryCZL.Insert(true);
        exit(EETEntryCZL."Entry No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsEETEnabled(var EETEnabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCancelEETEntry(EETEntryCZL: Record "EET Entry CZL"; var CancelEETEntryNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSimpleEETEntryOnBeforeInsertEETEntry(var EETEntryCZL: Record "EET Entry CZL")
    begin
    end;
#if not CLEAN18

#pragma warning disable AL0432
    [Obsolete('The temporary subscriber to prevent activation of new and obsolete services at the same time.', '18.0')]
    [EventSubscriber(ObjectType::Table, Database::"EET Service Setup", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure CheckNewEnabledFieldOnAfterValidateObsoleteEnabledField(var Rec: Record "EET Service Setup")
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if Rec.Enabled then begin
            EETServiceSetupCZL.Get();
            EETServiceSetupCZL.TestField(Enabled, false);
        end;
    end;

    [Obsolete('The temporary subscriber to prevent activation of new and obsolete services at the same time.', '18.0')]
    [EventSubscriber(ObjectType::Table, Database::"EET Service Setup CZL", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure CheckObsoleteEnabledFieldOnAfterValidateNewEnabledField(var Rec: Record "EET Service Setup CZL")
    var
        EETServiceSetup: Record "EET Service Setup";
    begin
        if Rec.Enabled then begin
            EETServiceSetup.Get();
            EETServiceSetup.TestField(Enabled, false);
        end;
    end;
#pragma warning restore AL0432
#endif
}

