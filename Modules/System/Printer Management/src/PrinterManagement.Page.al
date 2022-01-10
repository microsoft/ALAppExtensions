// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes the list of available printers.
/// </summary>
page 2616 "Printer Management"
{
    Caption = 'Printer Management';
    PageType = List;
    SourceTable = Printer;
    UsageCategory = Administration;
    ApplicationArea = All;
    Editable = false;
    Extensible = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;
    PromotedActionCategories = 'New,Process,Report,Manage';
    Permissions = tabledata Printer = r;

    layout
    {
        area(content)
        {
            repeater(Printers)
            {
                ShowCaption = false;
                field(ID; ID)
                {
                    ApplicationArea = All;
                    Caption = 'Printer ID';
                    ToolTip = 'Specifies the ID of the printer.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the printer.';
                }
                field(PrinterType; PrinterType)
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of the printer.';
                }
                field(Device; Device)
                {
                    ApplicationArea = All;
                    Visible = false;
                    Caption = 'Device';
                    ToolTip = 'Specifies the printer device.';
                }
                field(Driver; Driver)
                {
                    ApplicationArea = All;
                    Visible = false;
                    Caption = 'Driver';
                    ToolTip = 'Specifies the driver of the printer.';
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(OpenPrinterSelections)
            {
                ApplicationArea = All;
                Caption = 'Printer Selections';
                Image = Open;
                ToolTip = 'Open the Printer Selections page.';
                Visible = IsPrinterSelectionsPageAvailable;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                var
                begin
                    if IsPrinterSelectionsPageAvailable then
                        Page.Run(PrinterSelectionPageId);
                end;
            }
            action(EditPrinterSettings)
            {
                ApplicationArea = All;
                Caption = 'Edit printer settings';
                Image = Edit;
                Scope = Repeater;
                ShortCutKey = 'Return';
                ToolTip = 'View or edit the settings of the selected printer.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    PrinterSetupImpl.OpenPrinterSettings(ID);
                    CurrPage.Update();
                end;
            }
            action(DefaultPrinterForCurrentUser)
            {
                ApplicationArea = All;
                Caption = 'Set as my default printer';
                Image = PrintReport;
                Scope = Repeater;
                ToolTip = 'Create a Printer Selection entry with your user name in User ID field and the printer name in the Printer Name field, leaving the Report ID field blank.';
                Visible = IsPrinterSelectionsPageAvailable;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    PrinterSetupImpl.SetDefaultPrinterForCurrentUser(ID);
                end;
            }
            action(DefaultPrinterForAllUsers)
            {
                ApplicationArea = All;
                Caption = 'Set as default printer for all users';
                Image = PrintReport;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Scope = Repeater;
                ToolTip = 'Create a Printer Selection entry with the printer name in the Printer Name field, leaving the User ID and Report ID fields blank.';
                Visible = IsPrinterSelectionsPageAvailable;
                trigger OnAction()
                begin
                    PrinterSetupImpl.SetDefaultPrinterForAllUsers(ID);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        PrinterType := PrinterSetupImpl.GetPrinterType(Rec);
    end;

    trigger OnOpenPage()
    var
        IsHandled: Boolean;
    begin
        PrinterSetupImpl.GetPrinterSelectionsPage(PrinterSelectionPageId, IsHandled);
        IsPrinterSelectionsPageAvailable := IsHandled;
    end;

    var
        PrinterSetupImpl: Codeunit "Printer Setup Impl.";
        IsPrinterSelectionsPageAvailable: Boolean;
        PrinterSelectionPageId: Integer;
        PrinterType: Enum "Printer Type";
}