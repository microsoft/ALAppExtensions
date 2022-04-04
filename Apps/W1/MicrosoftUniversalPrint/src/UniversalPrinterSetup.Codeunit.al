// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///  Handles the set up of Universal Printers and their configuration settings
/// </summary>
codeunit 2750 "Universal Printer Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'SetupPrinters', '', true, true)]
    local procedure SetUniversalPrinter(var Printers: Dictionary of [Text[250], JsonObject])
    var
        UniversalPrinterSettings: Record "Universal Printer Settings";
        PaperTrays: JsonArray;
        PaperTray: JsonObject;
        Payload: JsonObject;
    begin
        if not UniversalPrinterSettings.FindSet() then
            exit;

        // Create payload for each universal printer
        repeat
            //Ensure Printer Key is not empty as it is not supported by platform
            if UniversalPrinterSettings.Name <> '' then begin
                Clear(PaperTray);
                Clear(PaperTrays);
                Clear(Payload);

                PaperTray.Add('papersourcekind', GetPaperTray(UniversalPrinterSettings."Paper Tray").AsInteger());
                PaperTray.Add('paperkind', UniversalPrinterSettings."Paper Size".AsInteger());
                // If paper size is custom and no height and width is specified then set the paper size to A4
                if IsPaperSizeCustom(UniversalPrinterSettings."Paper Size") then begin
                    if (UniversalPrinterSettings."Paper Height" <= 0) or (UniversalPrinterSettings."Paper Width" <= 0) then begin
                        PaperTray.Replace('paperkind', UniversalPrinterSettings."Paper Size"::A4.AsInteger());
                        Session.LogMessage('0000EFY', CustomSizeErrorTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
                    end;
                    ConvertAndAddPrinterPaperDimensions(UniversalPrinterSettings, PaperTray);
                end;

                PaperTray.Add('landscape', UniversalPrinterSettings.Landscape);
                PaperTrays.Add(PaperTray);
                Payload.Add('version', 1);
                Payload.Add('description', UniversalPrinterSettings.Description);
                Payload.Add('papertrays', PaperTrays);
                Printers.Add(UniversalPrinterSettings.Name, Payload);
            end else
                Session.LogMessage('0000EFH', PrinterIDMissingTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
        until UniversalPrinterSettings.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Printer Setup", 'OnOpenPrinterSettings', '', false, false)]
    local procedure OnOpenUniversalPrinter(PrinterID: Text; var IsHandled: Boolean)
    var
        UniversalPrinterSettings: Record "Universal Printer Settings";
    begin
        if IsHandled then
            exit;
        if UniversalPrinterSettings.Get(CopyStr(PrinterID, 1, MaxStrLen(UniversalPrinterSettings.Name))) then begin
            Page.Run(Page::"Universal Printer Settings", UniversalPrinterSettings);
            IsHandled := true;
        end;
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

    internal procedure ConvertAndAddPrinterPaperDimensions(UniversalPrinterSettings: Record "Universal Printer Settings"; var PaperTray: JsonObject)
    var
        PrinterUnit: Enum "Printer Unit";
    begin
        // Converting mm/in to hundredths of a mm/in
        PaperTray.Add('height', UniversalPrinterSettings."Paper Height" * 100);
        PaperTray.Add('width', UniversalPrinterSettings."Paper Width" * 100);
        if UniversalPrinterSettings."Paper Unit" = UniversalPrinterSettings."Paper Unit"::Millimeters then
            PaperTray.Add('units', PrinterUnit::HundredthsOfAMillimeter.AsInteger());
        if UniversalPrinterSettings."Paper Unit" = UniversalPrinterSettings."Paper Unit"::Inches then
            PaperTray.Add('units', PrinterUnit::Display.AsInteger());
    end;

    local procedure IsLandscape(Orientation: Enum "Universal Printer Orientation"): Boolean
    var
    begin
        exit(Orientation = Orientation::landscape);
    end;

    procedure AddAllPrintShares() TotalAddedPrinters: Integer
    var
        UniversalPrinterSettings: Record "Universal Printer Settings";
        PrintSharesArray: JsonArray;
        JArrayElement: JsonToken;
        ErrorMessage: Text;
    begin
        if not UniversalPrintGraphHelper.GetPrintSharesList(PrintSharesArray, ErrorMessage) then
            Error(GetPrintSharesErr, ErrorMessage);

        foreach JArrayElement in PrintSharesArray do
            if not JArrayElement.IsObject() then
                Session.LogMessage('0000EG2', ParseWarningTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory())
            else
                if InsertPrinterSetting(UniversalPrinterSettings, JArrayElement.AsObject()) then
                    TotalAddedPrinters += 1;
    end;

    procedure AddAllPrintSharesToBuffer(var TempUniversalPrintShareBuffer: Record "Universal Print Share Buffer" temporary)
    var
        PrintSharesArray: JsonArray;
        JArrayElement: JsonToken;
        ErrorMessage: Text;
    begin
        if not UniversalPrintGraphHelper.GetPrintSharesList(PrintSharesArray, ErrorMessage) then
            Error(GetPrintSharesErr, ErrorMessage);

        foreach JArrayElement in PrintSharesArray do
            if JArrayElement.IsObject then
                InsertPrintShare(TempUniversalPrintShareBuffer, JArrayElement.AsObject())
            else
                Session.LogMessage('0000EG3', ParseWarningTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
        exit;
    end;

    procedure PrintShareExists(PrintShareID: Text): Boolean
    var
        ErrorMessage: Text;
        PrintShareJsonObject: JsonObject;
    begin
        exit(UniversalPrintGraphHelper.GetPrintShare(PrintShareID, PrintShareJsonObject, ErrorMessage));
    end;

    local procedure InsertPrinterSetting(var UniversalPrinterSettings: Record "Universal Printer Settings"; PrintShareJsonObject: JsonObject): Boolean
    var
        PropertyBag: JsonToken;
        PrintShareNameValue: Text;
        PrintShareIDValue: Text;
        PrinterDefaultsJsonObject: JsonObject;
    begin
        if not UniversalPrintGraphHelper.GetJsonKeyValue(PrintShareJsonObject, 'id', PrintShareIDValue) then
            exit(false);

        if PrintShareIDValue = '' then
            exit(false);

        // exit if printer setting already exist
        UniversalPrinterSettings.SetRange("Print Share ID", PrintShareIDValue);
        If UniversalPrinterSettings.FindFirst() then
            exit(false);

        if not UniversalPrintGraphHelper.GetJsonKeyValue(PrintShareJsonObject, 'displayName', PrintShareNameValue) then
            exit(false);

        if PrintShareNameValue = '' then
            exit(false);

        UniversalPrinterSettings.Reset();
        UniversalPrinterSettings.Validate("Print Share ID", PrintShareIDValue);
        UniversalPrinterSettings.Validate(Name, CopyStr(PrintShareNameValue, 1, MaxStrLen(UniversalPrinterSettings.Name)));
        UniversalPrinterSettings.Validate("Print Share Name", CopyStr(PrintShareNameValue, 1, MaxStrLen(UniversalPrinterSettings."Print Share Name")));
        UniversalPrinterSettings.Validate(Description, StrSubstNo(DefaultDescriptionTxt, UniversalPrinterSettings.Name));

        if PrintShareJsonObject.Get('allowAllUsers', PropertyBag) then
            UniversalPrinterSettings.Validate(AllowAllUsers, PropertyBag.AsValue().AsBoolean());

        if PrintShareJsonObject.Get('defaults', PropertyBag) and PropertyBag.IsObject() then begin
            PrinterDefaultsJsonObject := PropertyBag.AsObject();
            UpdateDefaults(UniversalPrinterSettings, PrinterDefaultsJsonObject);
        end else begin
            // Bug 393946: Universal Print: Default settings for printers are not loaded
            // According to documentation, the Graph APIs for the print share list should return capabilities and defaults, but that is not the case
            // even if the fields are $select-ed explicitly. Getting the defaults for each single printer is slower but works.
            // See docs: https://docs.microsoft.com/en-us/graph/api/print-list-shares?view=graph-rest-1.0&tabs=http
            Session.LogMessage('0000EUQ', NoDefaultsAvailableTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            GetDefaults(UniversalPrinterSettings);
        end;

        exit(UniversalPrinterSettings.Insert(true));
    end;

    procedure GetDefaults(var UniversalPrinterSettings: Record "Universal Printer Settings")
    var
        PropertyBag: JsonToken;
        PrinterDefaultsJsonObject: JsonObject;
        PrintShareJsonObject: JsonObject;
        ErrorMessage: Text;
    begin
        if IsNullGuid(UniversalPrinterSettings."Print Share ID") then
            exit;

        if not UniversalPrintGraphHelper.GetPrintShare(UniversalPrinterSettings."Print Share ID", PrintShareJsonObject, ErrorMessage) then
            Error(GetPrintShareDetailsErr, ErrorMessage);

        if PrintShareJsonObject.Get('defaults', PropertyBag) and PropertyBag.IsObject() then begin
            PrinterDefaultsJsonObject := PropertyBag.AsObject();
            UpdateDefaults(UniversalPrinterSettings, PrinterDefaultsJsonObject);
        end;
    end;

    procedure GetPaperTrayCapabilities(PrintShareID: Guid; var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        PropertyBag: JsonToken;
        PrinterCapabilitiesJsonObject: JsonObject;
        PrintShareJsonObject: JsonObject;
        PrinterTraysArray: JsonArray;
        JArrayElement: JsonToken;
        ErrorMessage: Text;
        I: Integer;
    begin
        if IsNullGuid(PrintShareID) then
            exit;

        if not UniversalPrintGraphHelper.GetPrintShare(PrintShareID, PrintShareJsonObject, ErrorMessage) then
            Error(GetPrintShareDetailsErr, ErrorMessage);

        if not PrintShareJsonObject.Get('capabilities', PropertyBag) then
            exit;

        if not PropertyBag.IsObject() then
            exit;

        PrinterCapabilitiesJsonObject := PropertyBag.AsObject();
        if not PrinterCapabilitiesJsonObject.SelectToken('outputBins', PropertyBag) then
            exit;

        if not PropertyBag.IsArray() then
            exit;

        PrinterTraysArray := PropertyBag.AsArray();
        foreach JArrayElement in PrinterTraysArray do
            if JArrayElement.IsValue then begin
                I += 1;
                TempNameValueBuffer.ID := I;
                TempNameValueBuffer."Value Long" := CopyStr(JArrayElement.AsValue().AsText(), 1, MaxStrLen(TempNameValueBuffer."Value Long"));
                TempNameValueBuffer.Insert();
            end;
        exit;
    end;

    local procedure UpdateDefaults(var UniversalPrinterSettings: Record "Universal Printer Settings"; var PrinterDefaultsJsonObject: JsonObject)
    var
        PrinterPropValue: Text;
    begin
        if UniversalPrintGraphHelper.GetJsonKeyValue(PrinterDefaultsJsonObject, 'orientation', PrinterPropValue) then
            UniversalPrinterSettings.Validate(Landscape, IsLandscape(GetOrientation(PrinterPropValue)));

        if UniversalPrintGraphHelper.GetJsonKeyValue(PrinterDefaultsJsonObject, 'mediaSize', PrinterPropValue) then
            UniversalPrinterSettings.Validate("Paper Size", GetPaperSize(PrinterPropValue));

        if UniversalPrintGraphHelper.GetJsonKeyValue(PrinterDefaultsJsonObject, 'outputBin', PrinterPropValue) then
            UniversalPrinterSettings.Validate("Paper Tray", CopyStr(PrinterPropValue, 1, MaxStrLen(UniversalPrinterSettings."Paper Tray")));
    end;

    local procedure InsertPrintShare(var TempUniversalPrintShareBuffer: Record "Universal Print Share Buffer" temporary; PrintShareJsonObject: JsonObject)
    var
        PrintSharePropValue: Text;
    begin
        if UniversalPrintGraphHelper.GetJsonKeyValue(PrintShareJsonObject, 'displayName', PrintSharePropValue) then
            TempUniversalPrintShareBuffer.Validate(Name, CopyStr(PrintSharePropValue, 1, MaxStrLen(TempUniversalPrintShareBuffer.Name)));

        if UniversalPrintGraphHelper.GetJsonKeyValue(PrintShareJsonObject, 'id', PrintSharePropValue) then
            TempUniversalPrintShareBuffer.Validate(ID, PrintSharePropValue);

        If TempUniversalPrintShareBuffer.Insert(true) then;
    end;

    local procedure GetOrientation(textValue: Text): Enum "Universal Printer Orientation"
    var
        UniversalPrinterOrientation: Enum "Universal Printer Orientation";
        OrdinalValue: Integer;
        Index: Integer;
    begin
        Index := UniversalPrinterOrientation.Names.IndexOf(textValue);
        if Index = 0 then
            exit(Enum::"Universal Printer Orientation"::portrait);

        OrdinalValue := UniversalPrinterOrientation.Ordinals.Get(Index);
        UniversalPrinterOrientation := Enum::"Universal Printer Orientation".FromInteger(OrdinalValue);
        exit(UniversalPrinterOrientation);
    end;

    local procedure GetPaperSize(textValue: Text): Enum "Printer Paper Kind"
    var
        PrinterPaperKind: Enum "Printer Paper Kind";
        OrdinalValue: Integer;
        Index: Integer;
    begin
        Index := PrinterPaperKind.Names.IndexOf(textValue);
        if Index = 0 then
            exit(Enum::"Printer Paper Kind"::A4);

        OrdinalValue := PrinterPaperKind.Ordinals.Get(Index);
        PrinterPaperKind := Enum::"Printer Paper Kind".FromInteger(OrdinalValue);
        exit(PrinterPaperKind);
    end;

    local procedure GetPaperTray(textValue: Text): Enum "Printer Paper Source Kind"
    var
        UniversalPrinterPaperTray: Enum "Printer Paper Source Kind";
        OrdinalValue: Integer;
        Index: Integer;
    begin
        Index := UniversalPrinterPaperTray.Names.IndexOf(textValue);
        if Index = 0 then
            exit(Enum::"Printer Paper Source Kind"::AutomaticFeed);

        OrdinalValue := UniversalPrinterPaperTray.Ordinals.Get(Index);
        UniversalPrinterPaperTray := Enum::"Printer Paper Source Kind".FromInteger(OrdinalValue);
        exit(UniversalPrinterPaperTray);
    end;

    internal procedure IsPaperSizeCustom("Paper Size": Enum "Printer Paper Kind"): Boolean
    var
    begin
        exit("Paper Size" = "Paper Size"::Custom);
    end;

    internal procedure OnQueryClosePrinterSettingsPage(UniversalPrinterSettings: Record "Universal Printer Settings"): Boolean
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if UniversalPrinterSettings.IsEmpty then
            exit(true);

        if UniversalPrinterSettings.Name = '' then
            exit(true);

        if IsNullGuid(UniversalPrinterSettings."Print Share ID") then begin
            if Confirm(InvalidPrintShareClosePageQst, true) then
                exit(true);
            Error('');
        end;

        if IsPaperSizeCustom(UniversalPrinterSettings."Paper Size") then begin
            ValidatePaperHeight(UniversalPrinterSettings."Paper Height");
            ValidatePaperWidth(UniversalPrinterSettings."Paper Width");
        end;

        FeatureTelemetry.LogUptake('0000GG0', UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up");
        exit(true);
    end;

    internal procedure DeletePrinterSettings(Name: Text[250])
    var
        PrinterSelection: Record "Printer Selection";
    begin
        if not PrinterSelection.ReadPermission() then
            exit;

        PrinterSelection.SetRange("Printer Name", Name);
        if NOT PrinterSelection.IsEmpty() then
            Error(UsedInPrinterSelectionErr, Name);
    end;

    internal procedure LookupPaperTrays(var UniversalPrinterSettings: Record "Universal Printer Settings")
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        UniversalPrinterTrayList: Page "Universal Printer Tray List";
    begin
        GetPaperTrayCapabilities(UniversalPrinterSettings."Print Share ID", TempNameValueBuffer);
        UniversalPrinterTrayList.SetPaperTrayBuffer(TempNameValueBuffer);
        UniversalPrinterTrayList.LookupMode(true);
        if UniversalPrinterTrayList.RunModal() = ACTION::LookupOK then begin
            UniversalPrinterTrayList.GetRecord(TempNameValueBuffer);
            UniversalPrinterSettings.Validate("Paper Tray", TempNameValueBuffer."Value Long");
        end;
    end;

    internal procedure LookupPrintShares(var UniversalPrinterSettings: Record "Universal Printer Settings")
    var
        TempUniversalPrintShareBuffer: Record "Universal Print Share Buffer" temporary;
        UniversalPrintSharesList: Page "Universal Print Shares List";
    begin
        UniversalPrintSharesList.LookupMode(true);
        if UniversalPrintSharesList.RunModal() = ACTION::LookupOK then begin
            UniversalPrintSharesList.GetRecord(TempUniversalPrintShareBuffer);
            UniversalPrinterSettings.Validate("Print Share ID", TempUniversalPrintShareBuffer.ID);
            UniversalPrinterSettings.Validate("Print Share Name", TempUniversalPrintShareBuffer.Name);
            GetDefaults(UniversalPrinterSettings);
        end;
    end;

    var
        UniversalPrintGraphHelper: Codeunit "Universal Print Graph Helper";
        DefaultDescriptionTxt: Label 'Sends print jobs to the %1.', Comment = '%1 = Print share name';
        PrinterIDMissingTelemetryTxt: Label 'Printer ID is missing during printer setup.', Locked = true;
        ParseWarningTelemetryTxt: Label 'Cannnot parse response.', Locked = true;
        NoDefaultsAvailableTelemetryTxt: Label 'There are no defaults available from the list of print shares, checking the individual print share.', Locked = true;
        GetPrintSharesErr: Label 'There was an error fetching printers shared to you.\\%1', Comment = '%1 = a more detailed error message';
        GetPrintShareDetailsErr: Label 'There was an error fetching properties for the selected printer.\\%1', Comment = '%1 = a more detailed error message';
        HeightInputErr: Label 'The value in the Paper Height field must be greater than 0.';
        WidthInputErr: Label 'The value in the Paper Width field must be greater than 0.';
        UsedInPrinterSelectionErr: Label 'You cannot delete printer %1. It is used on the Printer Selections page.', Comment = '%1 = Printer ID';
        CustomSizeErrorTelemetryTxt: Label 'Custom paper size configured with incorrect height or width.', Locked = true;
        InvalidPrintShareClosePageQst: Label 'The Universal Print share name is not valid. Do you want to exit?';
}