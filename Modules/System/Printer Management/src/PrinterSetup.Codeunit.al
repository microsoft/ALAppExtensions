// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to manage printer settings.
/// </summary>
codeunit 2616 "Printer Setup"
{
    Access = Public;

    /// <summary>
    /// Gets the type of a printer.
    /// </summary>
    /// <param name="Printer">The printer.</param>
    /// <returns>The printer type.</returns>
    [Scope('OnPrem')]
    procedure GetPrinterType(Printer: Record Printer): Enum "Printer Type"
    var
        PrinterSetupImpl: Codeunit "Printer Setup Impl.";
    begin
        exit(PrinterSetupImpl.GetPrinterType(Printer));
    end;

    /// <summary>
    /// Integration event that is called to view and edit the settings of a printer.
    /// Subscribe to this event if you want to introduce user configurable settings for a printer.
    /// </summary>
    /// <param name="PrinterID">A value that determines the printer being drilled down.</param>
    /// <param name="IsHandled">Stores whether the operation was successful.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnOpenPrinterSettings(PrinterID: Text; var IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Integration event that is called to set the default printer for all reports.
    ///  Subscribe to this event to specify a value in the Printer Name field and leave the User ID and Report ID fields blank in Printers Selection.
    /// </summary>
    /// <param name="PrinterID">A value that determines the printer being set as default.</param>
    /// <param name="UserID">A value that determines the user for whom the printer is being set as default. Empty value implies all users.</param>
    /// <param name="IsHandled">Stores whether the operation was successful.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnSetAsDefaultPrinter(PrinterID: Text; UserID: Text; var IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Integration event that is called to get the page ID of the Printer Selection page.
    /// </summary>
    /// <param name="PageID">An out value that determines the id of the Printer Selection page.</param>
    /// <param name="IsHandled">Stores whether the operation was successful.</param>
    [IntegrationEvent(false, false)]
    internal procedure GetPrinterSelectionsPage(var PageID: Integer; var IsHandled: Boolean)
    begin
    end;
}