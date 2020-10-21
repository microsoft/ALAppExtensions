// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///  Handels the set up of Email Printers and their configuration settings
/// </summary>
codeunit 2650 "Setup Printers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'SetupPrinters', '', true, true)]
    procedure SetSendToEmailPrinter(var Printers: Dictionary of [Text[250], JsonObject])
    var
        EmailPrinterSettings: Record "Email Printer Settings";
        Payload: JsonObject;
        PaperTrays: JsonArray;
        PaperTray: JsonObject;
        PrinterPaperSourceKind: Enum "Printer Paper Source Kind";
    begin
        if EmailPrinterSettings.IsEmpty() then
            InsertDefaultEmailPrinter();
        if EmailPrinterSettings.FindSet() then
            // Create payload for each email printer containing version, papertrays and description
            repeat
                //Ensure Printer Key is not empty as it is not supported by platform
                if EmailPrinterSettings.ID <> '' then begin
                    Clear(PaperTray);
                    Clear(PaperTrays);
                    Clear(Payload);
                    PaperTray.Add('papersourcekind', PrinterPaperSourceKind::AutomaticFeed.AsInteger());

                    PaperTray.Add('paperkind', EmailPrinterSettings."Paper Size".AsInteger());
                    // If paper size is custom and no height and width is specified then set the paper size to A4
                    if IsPaperSizeCustom(EmailPrinterSettings."Paper Size") then begin
                        if (EmailPrinterSettings."Paper Height" <= 0) or (EmailPrinterSettings."Paper Width" <= 0) then begin
                            PaperTray.Replace('paperkind', EmailPrinterSettings."Paper Size"::A4.AsInteger());
                            Session.LogMessage('0000BOZ', CustomSizeErrorTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailPrinterTelemetryCategoryTok);
                        end;
                        ConvertAndAddPrinterPaperDimensions(EmailPrinterSettings, PaperTray);
                    end;

                    PaperTray.Add('landscape', EmailPrinterSettings.Landscape);

                    PaperTrays.Add(PaperTray);

                    Payload.Add('version', 1);
                    Payload.Add('description', EmailPrinterSettings.Description);
                    Payload.Add('papertrays', PaperTrays);

                    Printers.Add(EmailPrinterSettings.ID, Payload);
                end else
                    Session.LogMessage('0000BJQ', PrinterIDMissingTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailPrinterTelemetryCategoryTok);
            until EmailPrinterSettings.Next() = 0;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Printer Setup", 'OnOpenPrinterSettings', '', false, false)]
    internal procedure OnOpenSendToEmailPrinter(PrinterID: Text; var IsHandled: Boolean)
    var
        EmailPrinterSettings: Record "Email Printer Settings";
    begin
        if IsHandled then
            exit;
        if EmailPrinterSettings.Get(CopyStr(PrinterID, 1, MaxStrLen(EmailPrinterSettings.ID))) then begin
            Page.Run(Page::"Email Printer Settings", EmailPrinterSettings);
            IsHandled := true;
        end;
    end;

    local procedure InsertDefaultEmailPrinter()
    var
        EmailPrinterSettings: Record "Email Printer Settings";
    begin
        EmailPrinterSettings.Validate(ID, PrinterIDTxt);
        InsertDefaults(EmailPrinterSettings);
        IF EmailPrinterSettings.Insert(true) THEN;
    end;

    internal procedure InsertDefaults(var EmailPrinterSettings: Record "Email Printer Settings")
    var
        PaperSize: Enum "Printer Paper Kind";
    begin
        EmailPrinterSettings.Validate(Description, DefaultDescriptionTxt);
        EmailPrinterSettings.Validate("Email Subject", DefaultEmailSubjectTxt);
        EmailPrinterSettings.Validate("Paper Size", PaperSize::A4);
        EmailPrinterSettings.Validate(Landscape, false);
    end;

    internal procedure IsPaperSizeCustom("Paper Size": Enum "Printer Paper Kind"): Boolean
    var
    begin
        exit("Paper Size" = "Paper Size"::Custom);
    end;

    internal procedure DeletePrinterSettings(PrinterID: Text[250])
    var
        EmailPrinterSettings: Record "Email Printer Settings";
        PrinterSelection: Record "Printer Selection";
    begin
        if not PrinterSelection.ReadPermission() then
            exit;
        PrinterSelection.SetRange("Printer Name", PrinterID);
        if NOT PrinterSelection.IsEmpty() then
            Error(UsedInPrinterSelectionErr, PrinterID);
        EmailPrinterSettings.FindSet();
        if EmailPrinterSettings.Count() = 1 then
            Error(CannotDeleteOnlyEmailPrinterErr);
    end;

    internal procedure OnQueryClosePrinterSettingsPage(EmailPrinterSettings: Record "Email Printer Settings"): Boolean
    begin
        if EmailPrinterSettings.IsEmpty then
            exit(true);
        if EmailPrinterSettings.ID = '' then
            exit(true);
        if not MailManagement.CheckValidEmailAddress(EmailPrinterSettings."Email Address") then begin
            if Confirm(ClosePageQst, true) then
                exit(true);
            Error('');
        end;
        if IsPaperSizeCustom(EmailPrinterSettings."Paper Size") then begin
            ValidatePaperHeight(EmailPrinterSettings."Paper Height");
            ValidatePaperWidth(EmailPrinterSettings."Paper Width");
        end;
        exit(true);
    end;

    internal procedure ValidatePaperHeight(PaperHeight: Decimal)
    begin
        if PaperHeight <= 0 then
            Error(HeightInputErr);
    end;

    internal procedure ValidatePaperWidth(PaperWidth: Decimal)
    begin
        if PaperWidth <= 0 then
            Error(WidthInputErr);
    end;

    internal procedure ConvertAndAddPrinterPaperDimensions(EmailPrinterSettings: Record "Email Printer Settings"; var PaperTray: JsonObject)
    var
        PrinterUnit: Enum "Printer Unit";
    begin
        //Converting mm/in to hundredths of  a mm/in
        PaperTray.Add('width', EmailPrinterSettings."Paper Height" * 100);
        PaperTray.Add('height', EmailPrinterSettings."Paper Width" * 100);
        if EmailPrinterSettings."Paper Unit" = EmailPrinterSettings."Paper Unit"::Millimeters then
            PaperTray.Add('units', PrinterUnit::HundredthsOfAMillimeter.AsInteger());
        if EmailPrinterSettings."Paper Unit" = EmailPrinterSettings."Paper Unit"::Inches then
            PaperTray.Add('units', PrinterUnit::Display.AsInteger());
    end;

    [Obsolete('SMTP setup is replaced with the Email Module. Please, use EmailAccount.IsAnyAccountRegistered()', '17.0')]
    internal procedure IsSMTPSetup(): Boolean
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
    begin
        exit(SMTPMailSetup.HasSetup() and MailManagement.IsSMTPEnabled())
    end;

    procedure LearnMoreAction(PrivacyNotification: Notification)
    begin
        Hyperlink(PrintPrivacyUrlTxt);
    end;

    var
        MailManagement: Codeunit "Mail Management";
        PrinterIDTxt: Label 'Email Printer';
        DefaultDescriptionTxt: Label 'Sends print jobs to the printer''s email address';
        DefaultEmailSubjectTxt: Label 'Printed Copy';
        CannotDeleteOnlyEmailPrinterErr: Label 'There is only one email printer. Please uninstall the extension to delete this printer.';
        HeightInputErr: Label 'The value in the Paper Height field must be greater than 0.';
        WidthInputErr: Label 'The value in the Paper Width field must be greater than 0.';
        UsedInPrinterSelectionErr: Label 'You cannot delete printer %1. It is used on the Printer Selections page.', Comment = '%1 = Printer ID';
        ClosePageQst: Label 'The email address is not valid. Do you want to exit?';
        EmailPrinterTelemetryCategoryTok: Label 'AL Email Printer', Locked = true;
        PrinterIDMissingTelemetryTxt: Label 'Printer ID is missing during printer setup.', Locked = true;
        CustomSizeErrorTelemetryTxt: Label 'Custom paper size configured with incorrect height or width.', Locked = true;
        PrintPrivacyUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2120728', Locked = true;
}