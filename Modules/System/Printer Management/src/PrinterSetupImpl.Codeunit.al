// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Implements functionality to manage printer settings.
/// </summary>
codeunit 2617 "Printer Setup Impl."
{
    Access = Internal;

    var
        PrinterSetup: Codeunit "Printer Setup";
        NetworkPrinterTxt: Label 'Network Printer', Locked = true;
        NoPrinterSettingsMsg: Label 'No configuration is available for this printer.';
        UnableToSetDefaultPrinterErr: Label 'Cannot set this printer as the default printer.';
        SetMyDefaultPrinterSucessMsg: Label 'Printer %1 is set as default printer for all reports. You can open Printer Selections page to see the created entry.', Comment = '%1 = Printer ID';
        SetDefaultPrinterForAllUsersSucessMsg: Label 'Printer %1 is set as default printer for all reports of all users. You can open Printer Selections page to see the created entry.', Comment = '%1 = Printer ID';

    procedure GetPrinterType(Printer: Record Printer): Enum "Printer Type"
    begin
        if Printer.Device = NetworkPrinterTxt then
            exit(Enum::"Printer Type"::"Network Printer")
        else
            exit(Enum::"Printer Type"::"Local Printer");
    end;

    procedure OpenPrinterSettings(PrinterID: Text)
    var
        IsHandled: Boolean;
    begin
        PrinterSetup.OnOpenPrinterSettings(PrinterID, IsHandled);
        if not IsHandled then
            Message(NoPrinterSettingsMsg);
    end;

    procedure GetPrinterSelectionsPage(var PageID: Integer; var IsHandled: Boolean)
    begin
        PrinterSetup.GetPrinterSelectionsPage(PageID, IsHandled);
    end;

    procedure SetDefaultPrinterForCurrentUser(PrinterID: Text)
    var
        IsHandled: Boolean;
    begin
        PrinterSetup.OnSetAsDefaultPrinter(PrinterID, UserId, IsHandled);
        if IsHandled then begin
            Message(SetMyDefaultPrinterSucessMsg, PrinterID);
            exit;
        end;
        Error(UnableToSetDefaultPrinterErr);
    end;

    procedure SetDefaultPrinterForAllUsers(PrinterID: Text)
    var
        IsHandled: Boolean;
    begin
        PrinterSetup.OnSetAsDefaultPrinter(PrinterID, '', IsHandled);
        if IsHandled then begin
            Message(SetDefaultPrinterForAllUsersSucessMsg, PrinterID);
            exit;
        end;
        Error(UnableToSetDefaultPrinterErr);
    end;
}