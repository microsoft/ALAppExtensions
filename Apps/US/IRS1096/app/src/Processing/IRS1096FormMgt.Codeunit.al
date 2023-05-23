codeunit 10016 "IRS 1096 Form Mgt."
{
    Permissions = TableData "IRS 1096 Form Header" = imd,
                  TableData "IRS 1096 Form Line" = imd;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ServDeclFormTok: Label 'Service Declaration', Locked = true;
        IRS1096FeatureKeyIdTok: Label 'IRS1096Form', Locked = true;
        InstallFeatureNotificationMsg: Label 'There is a new IRS 1096 form feature. An administrator can enable it on the Feature Management page.';
        DontShowAgainTxt: Label 'Do not show again';
        InstallIRS1096NotificationNameTxt: Label 'IRS 1096 Form - Install feature';
        InstallIRS1096NotificationDescriptionTxt: Label 'This notification is used to let users know about the new IRS 1096 feature . It can be used to open the Feature Management and install the 1096 feature.';
        FeatureNotEnabledMessageTxt: Label 'The %1 page is part of the new IRS 1096 feature, which is not yet enabled in your Business Central. An administrator can enable the feature on the Feature Management page.', Comment = '%1 - page caption';
        NoEntriesToCreateFormsMsg: Label 'No entries have been found by filters specified.';
        FormPerPeriodAlreadyExistsQst: Label 'The form %1 for the period from %2 to %3 already exist. If you want to replace it, use the Replace parameter on the request page. Do you want to stop the creation of forms?', Comment = '%1 - code of the form, %2,%3 - starting and ending dates of the period';
        FormsCreatedMsg: Label 'IRS 1096 forms have been created';
        AssistedSetupTxt: Label 'Set up an IRS 1096 feature';
        AssistedSetupDescriptionTxt: Label 'This feature provides functionality that enables an easy overview and reporting of the 1096 form to IRS.';
        AssistedSetupHelpTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2204541', Locked = true;
        OneOrMoreFormsNotReleasedErr: Label 'One or more forms within the period are not released. You can only print released forms. Open the form card and click Release to release the form.';
        NoFormsHaveBeenCreatedMsg: Label 'No IRS 1096 forms have been created';

    procedure IsFeatureEnabled() IsEnabled: Boolean
    var
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        FeatureMgtFacade: Codeunit "Feature Management Facade";
    begin
        IsEnabled := FeatureMgtFacade.IsEnabled(GetIRS1096FormFeatureKeyId()) and PurchPayablesSetup.Get() and (PurchPayablesSetup."IRS 1096 Form No. Series" <> '');
        OnAfterCheckFeatureEnabled(IsEnabled);
    end;

    internal procedure InstallFeature()
    var
        FeatureKey: Record "Feature Key";
        FeatureMgtFacade: Codeunit "Feature Management Facade";
    begin
        if FeatureMgtFacade.IsEnabled(GetIRS1096FormFeatureKeyId()) then begin
            FeatureKey.Get(GetIRS1096FormFeatureKeyId());
            FeatureKey.Validate(Enabled, FeatureKey.Enabled::None);
            FeatureKey.Modify(true);
        end;
    end;

    procedure ReleaseForm(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    begin
        IRS1096FormHeader.TestField("Starting Date");
        IRS1096FormHeader.TestField("Ending Date");
        IRS1096FormHeader.TestField("IRS Code");
        IRS1096FormHeader.TestField("Total Number Of Forms");
        IRS1096FormHeader.TestField("Total Amount To Report");
        IRS1096FormHeader.Validate(Status, IRS1096FormHeader.Status::Released);
        IRS1096FormHeader.Modify(true);
    end;

    procedure ReopenForm(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    begin
        IRS1096FormHeader.Validate(Status, IRS1096FormHeader.Status::Open);
        IRS1096FormHeader.Modify(true);
    end;

    procedure CreateForms(StartDate: Date; EndDate: Date; Replace: Boolean)
    var
        TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        TempIRS1096FormHeader: Record "IRS 1096 Form Header" temporary;
        TempCreatedIRS1096FormHeader: Record "IRS 1096 Form Header" temporary;
        TempIRS1096FormLine: Record "IRS 1096 Form Line" temporary;
        IRS1096FormHeader: Record "IRS 1096 Form Header";
        IRS1096FormLine: Record "IRS 1096 Form Line";
        EntryApplicationManagement: Codeunit "Entry Application Management";
        PeriodDate: array[2] of Date;
        ConflictResolved: Boolean;
    begin
        PeriodDate[1] := StartDate;
        PeriodDate[2] := EndDate;
        EntryApplicationManagement.GetAppliedVendorEntries(
          TempVendorLedgerEntry, '', PeriodDate, true);
        TempVendorLedgerEntry.SetFilter("Document Type", '%1|%2', TempVendorLedgerEntry."Document Type"::Invoice, TempVendorLedgerEntry."Document Type"::"Credit Memo");
        if not TempVendorLedgerEntry.FindSet() then begin
            Message(NoEntriesToCreateFormsMsg);
            exit;
        end;

        IRS1096FormHeader.SetRange("Starting Date", StartDate);
        IRS1096FormHeader.SetRange("Ending Date", EndDate);
        if IRS1096FormHeader.FindSet() then
            repeat
                TempIRS1096FormHeader := IRS1096FormHeader;
                TempIRS1096FormHeader.Insert();
            until IRS1096FormHeader.Next() = 0;

        IRS1096FormHeader.Reset();
        IRS1096FormHeader.LockTable();
        IRS1096FormLine.LockTable();
        repeat
            AddVendLedgEntryToFormBuffer(TempIRS1096FormLine, TempIRS1096FormHeader, TempCreatedIRS1096FormHeader, ConflictResolved, TempVendorLedgerEntry, PeriodDate, Replace);
        until TempVendorLedgerEntry.Next() = 0;
        InsertFromFormBuffer(TempCreatedIRS1096FormHeader, TempIRS1096FormLine);
        if TempCreatedIRS1096FormHeader.IsEmpty() then begin
            if GuiAllowed() then
                Message(NoFormsHaveBeenCreatedMsg);
            exit;
        end;
        if GuiAllowed() then
            Message(FormsCreatedMsg);
    end;

    procedure PrintSingleForm(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    var
        IRS1096FormHeaderToPrint: Record "IRS 1096 Form Header";
    begin
        IRS1096FormHeader.TestField(Status, IRS1096FormHeader.Status::Released);
        SetPrintingDetails(IRS1096FormHeader);
        IRS1096FormHeaderToPrint := IRS1096FormHeader;
        IRS1096FormHeaderToPrint.SetRecFilter();
        PrintForms(IRS1096FormHeaderToPrint);
    end;

    procedure PrintFormByPeriod(IRS1096FormHeader: Record "IRS 1096 Form Header")
    var
        IRS1096FormHeaderToPrint: Record "IRS 1096 Form Header";
    begin
        IRS1096FormHeaderToPrint.SetRange("Starting Date", IRS1096FormHeader."Starting Date");
        IRS1096FormHeaderToPrint.SetRange("Ending Date", IRS1096FormHeader."Ending Date");
        IRS1096FormHeaderToPrint.SetRange(Status, IRS1096FormHeaderToPrint.Status::Open);
        if not IRS1096FormHeaderToPrint.IsEmpty() then
            error(OneOrMoreFormsNotReleasedErr);

        IRS1096FormHeaderToPrint.SetRange(Status);
        IRS1096FormHeaderToPrint.FindSet();
        repeat
            SetPrintingDetails(IRS1096FormHeaderToPrint);
        until IRS1096FormHeaderToPrint.Next() = 0;
        PrintForms(IRS1096FormHeaderToPrint);
    end;

    local procedure PrintForms(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    var
        IRS1096FormReport: Report "IRS 1096 Form";
    begin
        Commit();
        FeatureTelemetry.LogUptake('0000ISB', ServDeclFormTok, Enum::"Feature Uptake Status"::Used);
        IRS1096FormReport.SetTableView(IRS1096FormHeader);
        IRS1096FormReport.Run();
        FeatureTelemetry.LogUsage('0000ISC', ServDeclFormTok, 'File created');
    end;

    procedure ShowInstallFeatureNotification()
    var
        MyNotifications: Record "My Notifications";
        Install1096FeatureNotification: Notification;
    begin
        if IsFeatureEnabled() then
            exit;
        if not MyNotifications.IsEnabled(GetIRS1096FeatureNotificationId()) then
            exit;

        Install1096FeatureNotification.Id := GetIRS1096FeatureNotificationId();
        Install1096FeatureNotification.Recall();
        Install1096FeatureNotification.Message := InstallFeatureNotificationMsg;
        Install1096FeatureNotification.AddAction(DontShowAgainTxt, Codeunit::"IRS 1096 Form Mgt.", 'DontShowAgainDisableAutomaticNotificationAction');
        Install1096FeatureNotification.Send();
    end;

    procedure DontShowAgainDisableAutomaticNotificationAction(var Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(GetIRS1096FeatureNotificationId()) then
            MyNotifications.InsertDefault(GetIRS1096FeatureNotificationId(), InstallIRS1096NotificationNameTxt, InstallIRS1096NotificationDescriptionTxt, false);
    end;

    procedure ShowNotEnabledMessage(PageCaption: Text)
    begin
        Message(FeatureNotEnabledMessageTxt, PageCaption);
    end;

    procedure ShowRelatedVendorsLedgerEntries(FormNo: Code[20]; FormLineNo: Integer)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        IRS1096FormLineRelation: Record "IRS 1096 Form Line Relation";
    begin
        IRS1096FormLineRelation.SetRange("Form No.", FormNo);
        if FormLineNo <> 0 then
            IRS1096FormLineRelation.SetRange("Line No.", FormLineNo);
        if not IRS1096FormLineRelation.FindSet() then
            exit;

        repeat
            VendorLedgerEntry.Get(IRS1096FormLineRelation."Entry No.");
            TempVendorLedgerEntry := VendorLedgerEntry;
            TempVendorLedgerEntry.Insert();
        until IRS1096FormLineRelation.Next() = 0;
        Page.Run(0, TempVendorLedgerEntry);
    end;

    local procedure GetIRS1096FeatureNotificationId(): Guid
    begin
        exit('dd66a823-fe4b-4010-846d-77209a07ab33');
    end;

    local procedure SetPrintingDetails(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    begin
        IRS1096FormHeader.Validate(Printed, true);
        IRS1096FormHeader.Validate("Printed By", UserId());
        IRS1096FormHeader.Validate("Printed Date-Time", CurrentDateTime());
        IRS1096FormHeader.Modify(true);
    end;

    local procedure AddVendLedgEntryToFormBuffer(var TempIRS1096FormLine: Record "IRS 1096 Form Line" temporary; var TempIRS1096FormHeader: Record "IRS 1096 Form Header" temporary; var TempCreatedIRS1096FormHeader: Record "IRS 1096 Form Header" temporary; var ConflictResolved: Boolean; VendLedgEntry: Record "Vendor Ledger Entry"; PeriodDate: array[2] of Date; Replace: Boolean)
    var
        IRS1096FormHeader: Record "IRS 1096 Form Header";
        IRS1099Adjustment: Record "IRS 1099 Adjustment";
        ConfirmMgt: Codeunit "Confirm Management";
        General1099Code: Code[20];
        LineNo: Integer;
        AddToTotalNumberOfForms: Boolean;
        CalculatedAmount: Decimal;
    begin
        If (VendLedgEntry."IRS 1099 Code" = '') or (VendLedgEntry."IRS 1099 Amount" = 0) then
            exit;

        General1099Code := GetGeneral1099CodeFromVendLedgEntry(VendLedgEntry);
        if General1099Code = '' then
            exit;

        TempIRS1096FormHeader.SetRange("Starting Date", PeriodDate[1]);
        TempIRS1096FormHeader.SetRange("Ending Date", PeriodDate[2]);
        TempIRS1096FormHeader.SetRange("IRS Code", General1099Code);
        if TempIRS1096FormHeader.FindFirst() then
            If Replace then begin
                IRS1096FormHeader.Get(TempIRS1096FormHeader."No.");
                IRS1096FormHeader.Status := IRS1096FormHeader.Status::Open;
                IRS1096FormHeader.Delete(true);
                TempIRS1096FormHeader.Delete();
            end else begin
                if not ConflictResolved then
                    if ConfirmMgt.GetResponse(StrSubstNo(FormPerPeriodAlreadyExistsQst, General1099Code, PeriodDate[1], PeriodDate[2]), false) then
                        Error('');
                ConflictResolved := true;
                exit;
            end;

        IRS1096FormHeader.SetRange("Starting Date", PeriodDate[1]);
        IRS1096FormHeader.SetRange("Ending Date", PeriodDate[2]);
        IRS1096FormHeader.SetRange("IRS Code", General1099Code);
        if not IRS1096FormHeader.FindFirst() then begin
            IRS1096FormHeader.Init();
            IRS1096FormHeader."No." := '';
            IRS1096FormHeader."Starting Date" := PeriodDate[1];
            IRS1096FormHeader."Ending Date" := PeriodDate[2];
            IRS1096FormHeader."IRS Code" := General1099Code;
            IRS1096FormHeader.Insert(true);
            TempCreatedIRS1096FormHeader := IRS1096FormHeader;
            TempCreatedIRS1096FormHeader.Insert();
        end;

        VendLedgEntry.CalcFields(Amount);
        CalculatedAmount := -VendLedgEntry."Amount to Apply" * VendLedgEntry."IRS 1099 Amount" / VendLedgEntry.Amount;
        TempIRS1096FormLine.SetRange("Form No.", IRS1096FormHeader."No.");
        TempIRS1096FormLine.SetRange("Vendor No.", VendLedgEntry."Vendor No.");
        TempIRS1096FormLine.SetRange("IRS Code", VendLedgEntry."IRS 1099 Code");
        if TempIRS1096FormLine.FindLast() then begin
            TempIRS1096FormLine."Calculated Amount" += CalculatedAmount;
            TempIRS1096FormLine.Modify();
            IRS1096FormHeader."Calc. Amount" += CalculatedAmount;
            IRS1096FormHeader."Total Amount To Report" += CalculatedAmount;
            IRS1096FormHeader.Modify();
            InsertLineRelation(TempIRS1096FormLine, VendLedgEntry);
            exit;
        end;

        TempIRS1096FormLine.SetRange("IRS Code");
        AddToTotalNumberOfForms := TempIRS1096FormLine.IsEmpty();
        TempIRS1096FormLine.SetRange("Vendor No.");
        if TempIRS1096FormLine.FindLast() then
            LineNo := TempIRS1096FormLine."Line No.";

        LineNo += 10000;
        TempIRS1096FormLine.Init();
        TempIRS1096FormLine."Form No." := IRS1096FormHeader."No.";
        TempIRS1096FormLine."Line No." := LineNo;
        TempIRS1096FormLine."Vendor No." := VendLedgEntry."Vendor No.";
        TempIRS1096FormLine."IRS Code" := VendLedgEntry."IRS 1099 Code";
        TempIRS1096FormLine."Calculated Amount" := CalculatedAmount;
        IRS1099Adjustment.SetRange(Year, Date2DMY(IRS1096FormHeader."Starting Date", 3), Date2DMY(IRS1096FormHeader."Ending Date", 3));
        IRS1099Adjustment.SetRange("Vendor No.", TempIRS1096FormLine."Vendor No.");
        IRS1099Adjustment.SetRange("IRS 1099 Code", TempIRS1096FormLine."IRS Code");
        IRS1099Adjustment.CalcSums(Amount);
        TempIRS1096FormLine."Calculated Adjustment Amount" := IRS1099Adjustment.Amount;
        TempIRS1096FormLine.Insert();
        InsertLineRelation(TempIRS1096FormLine, VendLedgEntry);

        if AddToTotalNumberOfForms then begin
            IRS1096FormHeader."Calc. Total Number Of Forms" += 1;
            IRS1096FormHeader."Total Number Of Forms" += 1;
        end;
        IRS1096FormHeader."Calc. Amount" += TempIRS1096FormLine."Calculated Amount";
        IRS1096FormHeader."Calc. Adjustment Amount" += TempIRS1096FormLine."Calculated Adjustment Amount";
        IRS1096FormHeader."Total Amount To Report" += TempIRS1096FormLine."Calculated Amount" + TempIRS1096FormLine."Calculated Adjustment Amount";
        IRS1096FormHeader.Modify();
    end;

    local procedure GetGeneral1099CodeFromVendLedgEntry(VendLedgEntry: Record "Vendor Ledger Entry") IRSCode: Code[20]
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetGeneral1099CodeFromVendLedgEntry(VendLedgEntry, IRSCode, IsHandled);
        If IsHandled then
            exit(IRSCode);
#pragma warning disable AA0139
        if StrPos(VendLedgEntry."IRS 1099 Code", '-') = 0 then
            IRSCode := VendLedgEntry."IRS 1099 Code"
        else
            IRSCode := CopyStr(VendLedgEntry."IRS 1099 Code", 1, StrPos(VendLedgEntry."IRS 1099 Code", '-') - 1);
#pragma warning restore AA0139
        if not (UpperCase(IRSCode) in ['DIV', 'MISC', 'INT', 'NEC']) then
            exit('');
        exit(IRSCode);
    end;

    local procedure InsertLineRelation(IRS1096FormLine: Record "IRS 1096 Form Line"; VendLedgEntry: Record "Vendor Ledger Entry")
    var
        IRS1096FormLineRelation: Record "IRS 1096 Form Line Relation";
    begin
        IRS1096FormLineRelation.Validate("Form No.", IRS1096FormLine."Form No.");
        IRS1096FormLineRelation.Validate("Line No.", IRS1096FormLine."Line No.");
        IRS1096FormLineRelation.Validate("Entry No.", VendLedgEntry."Entry No.");
        IRS1096FormLineRelation.Insert(true);
    end;

    local procedure InsertFromFormBuffer(var TempCreatedIRS1096FormHeader: Record "IRS 1096 Form Header" temporary; var TempIRS1096FormLine: Record "IRS 1096 Form Line" temporary)
    var
        IRS1096FormHeader: Record "IRS 1096 Form Header";
        IRS1096FormLine: Record "IRS 1096 Form Line";
        IRS1099FormBox: Record "IRS 1099 Form-Box";
        IncludeLine: Boolean;
        TotalAmount: Decimal;
    begin
        TempIRS1096FormLine.Reset();
        TempIRS1096FormLine.FindSet();
        repeat
            TotalAmount := TempIRS1096FormLine."Calculated Amount" + TempIRS1096FormLine."Calculated Adjustment Amount";
            IRS1099FormBox.Get(TempIRS1096FormLine."IRS Code");
            if IRS1099FormBox."Minimum Reportable" < 0 then
                IncludeLine := TotalAmount <> 0
            else
                IncludeLine := (TotalAmount <> 0) and (TotalAmount >= IRS1099FormBox."Minimum Reportable");
            if IncludeLine then begin
                IRS1096FormLine := TempIRS1096FormLine;
                IRS1096FormLine."Total Amount" := TotalAmount;
                IRS1096FormLine.Insert();
            end;
        until TempIRS1096FormLine.Next() = 0;
        TempCreatedIRS1096FormHeader.FindSet();
        repeat
            IRS1096FormLine.SetRange("Form No.", TempCreatedIRS1096FormHeader."No.");
            if IRS1096FormLine.IsEmpty() then begin
                TempCreatedIRS1096FormHeader.Delete();
                if IRS1096FormHeader.Get(TempCreatedIRS1096FormHeader."No.") then
                    IRS1096FormHeader.Delete(true);
            end;
        until TempCreatedIRS1096FormHeader.Next() = 0;
    end;

    local procedure GetIRS1096FormFeatureKeyId(): Text[50]
    begin
        exit(IRS1096FeatureKeyIdTok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureEnableConfirmed', '', true, true)]
    local procedure OnAfterFeatureEnableConfirmed(var FeatureKey: Record "Feature Key")
    var
        IRS1096SetupWizard: Page "IRS 1096 Setup Wizard";
    begin
        if FeatureKey.ID = GetIRS1096FormFeatureKeyId() then
            if IRS1096SetupWizard.RunModal() = Action::OK then
                if not IRS1096SetupWizard.IsSetupFinished() then
                    Error('');
    end;

    [EventSubscriber(ObjectType::Page, Page::"IRS 1099 Form-Box", 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenIRS1099FormBoxPage()
    begin
        ShowInstallFeatureNotification();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        GuidedExperience.InsertAssistedSetup(AssistedSetupTxt, CopyStr(AssistedSetupTxt, 1, 50), AssistedSetupDescriptionTxt, 5, ObjectType::Page, Page::"IRS 1096 Setup Wizard", AssistedSetupGroup::FinancialReporting,
                                            '', VideoCategory::FinancialReporting, AssistedSetupHelpTxt);
        if IsFeatureEnabled() then
            GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"IRS 1096 Setup Wizard");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetGeneral1099CodeFromVendLedgEntry(VendLedgEntry: Record "Vendor Ledger Entry"; var IRSCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
    end;
}