// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.VAT.Reporting;
using System.Telemetry;
using System.Utilities;

page 4812 "Intrastat Report"
{
    ApplicationArea = All;
    Caption = 'Intrastat Report';
    PageType = Card;
    SourceTable = "Intrastat Report Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Status; Rec.Status) { }
                field(Description; Rec.Description) { }
                field("Statistics Period"; Rec."Statistics Period") { }
                field("Currency Identifier"; Rec."Currency Identifier") { }
                field("Amounts in Add. Currency"; Rec."Amounts in Add. Currency")
                {
                    Visible = false;
                }
                field(Reported; Rec.Reported) { }
                field("Export Date"; Rec."Export Date") { }
                field("Export Time"; Rec."Export Time") { }
            }
            part(IntrastatLines; "Intrastat Report Subform")
            {
                SubPageLink = "Intrastat No." = field("No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part(ErrorMessagesPart; "Error Messages Part")
            {
                Provider = IntrastatLines;
                SubPageLink = "Record ID" = field(filter("Record ID Filter"));
            }
            systempart(LinksFactBox; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
                Provider = IntrastatLines;
            }
            systempart(NotesFactBox; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
                Provider = IntrastatLines;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(GetEntries)
            {
                Caption = 'Suggest Lines';
                Ellipsis = true;
                Image = SuggestLines;
                ToolTip = 'Suggests Intrastat transactions to be reported and fills in Intrastat Report.';

                trigger OnAction()
                var
                    VATReportsConfiguration: Record "VAT Reports Configuration";
                    IntrastatReportGetLines: Report "Intrastat Report Get Lines";
                begin
                    Rec.CheckStatusOpen();
                    if FindVATReportsConfiguration(VATReportsConfiguration) and
                        (VATReportsConfiguration."Suggest Lines Codeunit ID" <> 0)
                    then begin
                        Commit();
                        Codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", Rec);
                        exit;
                    end;
                    Commit();
                    IntrastatReportGetLines.SetIntrastatReportHeader(Rec);
                    IntrastatReportGetLines.RunModal();
                end;
            }

            action(ChecklistReport)
            {
                Caption = 'Checklist Report';
                Image = PrintChecklistReport;
                ToolTip = 'Validate the Intrastat lines.';

                trigger OnAction()
                var
                    VATReportsConfiguration: Record "VAT Reports Configuration";
                begin
                    if FindVATReportsConfiguration(VATReportsConfiguration) and
                        (VATReportsConfiguration."Validate Codeunit ID" <> 0)
                    then begin
                        Commit();
                        Codeunit.Run(VATReportsConfiguration."Validate Codeunit ID", Rec);
                    end else
                        IntrastatReportMgt.ValidateReportWithAdvancedChecklist(Rec, false);

                    UpdateErrors();
                    CurrPage.Update();
                end;
            }
            action(ToggleErrorFilter)
            {
                Caption = 'Filter Error Lines';
                Image = "Filter";
                ToolTip = 'Show or hide Intrastat lines that do not have errors.';

                trigger OnAction()
                begin
                    CurrPage.IntrastatLines.Page.UpdateMarkedOnly();
                end;
            }
            action(RecalcWeightSupplUOM)
            {
                Caption = 'Recalc. Weight/Suppl. UOM';
                Image = Recalculate;
                ToolTip = 'Recalculate weight and/or supplemental units quantity.';

                trigger OnAction()
                begin
                    Rec.CheckStatusOpen();
                    IntrastatReportMgt.RecalculateWaightAndSupplUOMQty(Rec);
                    CurrPage.Update();
                end;
            }
            group(Action21)
            {
                Caption = 'Release';
                Image = ReleaseDoc;

                action(Release)
                {
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document to the next stage of processing. You must reopen the document before you can make changes to it.';

                    trigger OnAction()
                    var
                        ErrorMessage: Record "Error Message";
                        VATReportsConfiguration: Record "VAT Reports Configuration";
                    begin
                        if FindVATReportsConfiguration(VATReportsConfiguration) and
                            (VATReportsConfiguration."Validate Codeunit ID" <> 0)
                        then begin
                            Commit();
                            Codeunit.Run(VATReportsConfiguration."Validate Codeunit ID", Rec);
                        end else
                            IntrastatReportMgt.ValidateReportWithAdvancedChecklist(Rec, false);
                        UpdateErrors();
                        Commit();

                        ErrorMessage.SetRange("Context Record ID", Rec.recordID);
                        if not ErrorMessage.IsEmpty() then
                            Error(HasErrorsMsg);

                        IntrastatReportMgt.ReleaseIntrastatReport(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(Reopen)
                {
                    Caption = 'Re&open';
                    Enabled = Rec.Status <> Rec.Status::Open;
                    Image = ReOpen;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    begin
                        UpdateErrors();
                        Commit();
                        IntrastatReportMgt.ReopenIntrastatReport(Rec);
                        CurrPage.Update();
                    end;
                }
            }
            action(CreateFile)
            {
                Caption = 'Create File';
                Ellipsis = true;
                Image = MakeDiskette;
                ToolTip = 'Create the Intrastat reporting file.';

                trigger OnAction()
                var
                    VATReportsConfiguration: Record "VAT Reports Configuration";
                    ErrorMessage: Record "Error Message";
                begin
                    FeatureTelemetry.LogUptake('0000I8Z', IntrastatReportTok, Enum::"Feature Uptake Status"::Used);
                    Commit();

                    if FindVATReportsConfiguration(VATReportsConfiguration) and
                        (VATReportsConfiguration."Validate Codeunit ID" <> 0)
                    then begin
                        Commit();
                        Codeunit.Run(VATReportsConfiguration."Validate Codeunit ID", Rec);
                    end else
                        IntrastatReportMgt.ValidateReportWithAdvancedChecklist(Rec, false);

                    UpdateErrors();
                    Commit();

                    ErrorMessage.SetRange("Context Record ID", Rec.recordID);
                    if not ErrorMessage.IsEmpty() then
                        Error(HasErrorsMsg);

                    if FindVATReportsConfiguration(VATReportsConfiguration) and
                        (VATReportsConfiguration."Content Codeunit ID" <> 0)
                    then
                        Codeunit.Run(VATReportsConfiguration."Content Codeunit ID", Rec)
                    else begin
                        IntrastatReportMgt.ReleaseIntrastatReport(Rec);
                        IntrastatReportMgt.ExportWithDataExch(Rec, 0);
                    end;

                    FeatureTelemetry.LogUsage('0000I90', IntrastatReportTok, 'File created');
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(Get_Entries; GetEntries)
                {
                }
                actionref(Checklist_Report; ChecklistReport)
                {
                }
                actionref(Toggle_Error_Filter; ToggleErrorFilter)
                {
                }
                actionref(Recalc_Weight_Suppl_UOM; RecalcWeightSupplUOM)
                {
                }
                actionref(Create_File; CreateFile)
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Release';
                actionref(Release_Promoted; Release)
                {
                }
                actionref(Reopen_Promoted; Reopen)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        UpdateErrors();
    end;

    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HasErrorsMsg: Label 'One or more errors were found. You must resolve all the errors before you can proceed.';
        IntrastatReportTok: Label 'Intrastat Report', Locked = true;

    local procedure FindVATReportsConfiguration(var VATReportsConfiguration: Record "VAT Reports Configuration"): Boolean
    var
        VATReportConfiguration: Enum "VAT Report Configuration";
    begin
        VATReportsConfiguration.SetRange("VAT Report Type", VATReportConfiguration::"Intrastat Report");
        OnBeforeFindVATReportsConfiguration(Rec, VATReportsConfiguration);
        exit(VATReportsConfiguration.FindFirst());
    end;

    protected procedure UpdateErrors()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateErrors(IsHandled, Rec);
        if IsHandled then
            exit;

        CurrPage.ErrorMessagesPart.Page.SetContextRecordID(Rec.RecordId);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindVATReportsConfiguration(var IntrastatReportHeader: Record "Intrastat Report Header"; var VATReportsConfiguration: Record "VAT Reports Configuration")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeUpdateErrors(var IsHandled: boolean; var IntrastatReportHeader: Record "Intrastat Report Header")
    begin
    end;
}