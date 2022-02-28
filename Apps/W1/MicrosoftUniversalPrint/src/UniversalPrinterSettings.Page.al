// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to manage configuration settings of Universal Print printers.
/// </summary>
page 2750 "Universal Printer Settings"
{
    PageType = Card;
    SourceTable = "Universal Printer Settings";
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            field(Name; Rec.Name)
            {
                Caption = 'Name';
                ApplicationArea = All;
                ToolTip = 'Specifies the unique name of the printer settings.';
                Editable = NewMode;
            }
            field(PrintShareName; Rec."Print Share Name")
            {
                ApplicationArea = All;
                Caption = 'Print Share in Universal Print';
                ToolTip = 'Specifies the name of the print share associated with the printer settings.';
                NotBlank = true;
                Editable = false;
                ShowMandatory = true;
                trigger OnAssistEdit()
                begin
                    UniversalPrinterSetup.LookupPrintShares(Rec);
                    IsSizeCustom := UniversalPrinterSetup.IsPaperSizeCustom(Rec."Paper Size");
                end;
            }
            field(Description; Rec.Description)
            {
                Caption = 'Description';
                ApplicationArea = All;
                ToolTip = 'Specifies the description of the printer.';
            }

            field(PaperKind; Rec."Paper Size")
            {
                Caption = 'Paper Size';
                ApplicationArea = All;
                ToolTip = 'Specifies the printer''s selected paper size.';
                trigger OnValidate()
                begin
                    IsSizeCustom := UniversalPrinterSetup.IsPaperSizeCustom(Rec."Paper Size");

                    if IsSizeCustom and ((Rec."Paper Width" <= 0) or (Rec."Paper Height" <= 0)) then begin
                        // Set default to A4 inches
                        Rec."Paper Height" := 8.3;
                        Rec."Paper Width" := 11.7;
                        Rec."Paper Unit" := Rec."Paper Unit"::Inches;
                    end;
                end;
            }
            group(CustomProperties)
            {
                ShowCaption = false;
                Visible = IsSizeCustom;
                group(Custom)
                {
                    ShowCaption = false;
                    field(PaperHeight; Rec."Paper Height")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the height of the paper.';
                        trigger OnValidate()
                        begin
                            UniversalPrinterSetup.ValidatePaperHeight(Rec."Paper Height");
                        end;
                    }
                    field(PaperWidth; Rec."Paper Width")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the width of the paper.';
                        trigger OnValidate()
                        begin
                            UniversalPrinterSetup.ValidatePaperWidth(Rec."Paper Width");
                        end;
                    }
                    field(PaperUnit; Rec."Paper Unit")
                    {
                        ApplicationArea = All;
                        Caption = 'Paper Units';
                        ToolTip = 'Specifies the unit of measurement for the width and height of the paper.';
                    }
                }
            }
            field(PaperTray; Rec."Paper Tray")
            {
                Caption = 'Paper Tray';
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the printer''s output paper tray.';
                trigger OnAssistEdit()
                begin
                    UniversalPrinterSetup.LookupPaperTrays(Rec);
                end;
            }
            field(Landscape; Landscape)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the paper is in Landscape orientation.';
            }
            group(ManageSettings)
            {
                ShowCaption = false;
                group(ManageSetupInner)
                {
                    ShowCaption = false;
                    label(PrivacyNoticeLabel)
                    {
                        ApplicationArea = All;
                        Caption = 'This feature utilizes Microsoft Universal Print. By continuing you are affirming that you understand that the data handling and compliance standards of Microsoft Universal Print may not be the same as those provided by Microsoft Dynamics 365 Business Central. Please consult the documentation for Universal Print to learn more.';
                    }
                    field(Privacy; PrivacyStatementTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Caption = 'Learn more about how the data is handled.';
                        ToolTip = 'Opens a privacy help article.';
                        trigger OnDrillDown()
                        begin
                            Hyperlink(PrivacyUrlTxt);
                        end;
                    }
                }
            }
        }
    }
    actions
    {
        area(Creation)
        {
            action(NewPrinter)
            {
                ApplicationArea = All;
                Caption = 'Add another Universal Print printer';
                Image = New;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunPageMode = Create;
                PromotedCategory = New;
                RunObject = Page "Universal Printer Settings";
                ToolTip = 'Opens new Universal Print printer card.';
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        NewMode := true;
        InsertDefaults(Rec);
    end;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GFZ', UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), Enum::"Feature Uptake Status"::Discovered, false, true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        UniversalPrinterSetup.DeletePrinterSettings(Rec.Name);
        DeleteMode := true;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsSizeCustom := UniversalPrinterSetup.IsPaperSizeCustom(Rec."Paper Size");
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if DeleteMode then
            exit(true);
        if (CloseAction in [ACTION::OK, ACTION::LookupOK]) then
            exit(UniversalPrinterSetup.OnQueryClosePrinterSettingsPage(Rec));
    end;

    internal procedure InsertDefaults(var UniversalPrinterSettings: Record "Universal Printer Settings")
    var
        PaperSize: Enum "Printer Paper Kind";
    begin
        UniversalPrinterSettings.Validate("Paper Size", PaperSize::A4);
        UniversalPrinterSettings.Validate(Landscape, false);
    end;

    var
        UniversalPrinterSetup: Codeunit "Universal Printer Setup";
        UniversalPrintGraphHelper: Codeunit "Universal Print Graph Helper";
        PrivacyUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=724009', Locked = true;
        IsSizeCustom: Boolean;
        NewMode: Boolean;
        DeleteMode: Boolean;
        PrivacyStatementTxt: Label 'Your privacy is important to us. To learn more read our Privacy Statement.';
}