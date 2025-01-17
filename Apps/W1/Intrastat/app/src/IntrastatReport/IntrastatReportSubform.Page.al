// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.Environment;
using System.Utilities;

page 4813 "Intrastat Report Subform"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Intrastat Report Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    StyleExpr = LineStyleExpression;
                }
                field(Date; Rec.Date)
                {
                    StyleExpr = LineStyleExpression;
                }
                field("Document No."; Rec."Document No.")
                {
                    StyleExpr = LineStyleExpression;
                    ShowMandatory = true;
                }
                field("Item No."; Rec."Item No.")
                {
                    StyleExpr = LineStyleExpression;
                }
                field(Name; Rec."Item Name")
                {
                    StyleExpr = LineStyleExpression;
                }
                field("Tariff No."; Rec."Tariff No.") { }
                field("Item Description"; Rec."Tariff Description") { }
                field("Country/Region Code"; Rec."Country/Region Code") { }
                field("Partner VAT ID"; Rec."Partner VAT ID") { }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code") { }
                field("Area"; Rec.Area)
                {
                    Visible = false;
                }
                field("Transaction Type"; Rec."Transaction Type") { }
                field("Transaction Specification"; Rec."Transaction Specification")
                {
                    Visible = false;
                }
                field("Transport Method"; Rec."Transport Method") { }
                field("Entry/Exit Point"; Rec."Entry/Exit Point")
                {
                    Visible = false;
                }
                field("Supplementary Units"; Rec."Supplementary Units") { }
                field(Quantity; Rec.Quantity) { }
                field("Net Weight"; Rec."Net Weight") { }
                field("Total Weight"; Rec."Total Weight") { }
                field(Amount; Rec.Amount) { }
                field("Statistical Value"; Rec."Statistical Value") { }
                field("Source Type"; Rec."Source Type") { }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    Editable = false;
                }
                field("Cost Regulation %"; Rec."Cost Regulation %")
                {
                    Visible = false;
                }
                field("Indirect Cost"; Rec."Indirect Cost")
                {
                    Visible = false;
                }
                field("Internal Ref. No."; Rec."Internal Ref. No.") { }
                field("Shpt. Method Code"; Rec."Shpt. Method Code") { }
                field("Location Code"; Rec."Location Code") { }
                field("Suppl. Conversion Factor"; Rec."Suppl. Conversion Factor") { }
                field("Suppl. Unit of Measure"; Rec."Suppl. Unit of Measure") { }
                field("Supplementary Quantity"; Rec."Supplementary Quantity") { }
            }
            group(Control40)
            {
                ShowCaption = false;
                field(StatisticalValue; StatisticalValue + Rec."Statistical Value" - xRec."Statistical Value")
                {
                    AutoFormatType = 1;
                    Caption = 'Statistical Value';
                    Editable = false;
                    ToolTip = 'Specifies the statistical value that has accumulated in the Intrastat report.';
                    Visible = StatisticalValueVisible;
                }
                field(TotalStatisticalValue; TotalStatisticalValue + Rec."Statistical Value" - xRec."Statistical Value")
                {
                    AutoFormatType = 1;
                    Caption = 'Total Stat. Value';
                    Editable = false;
                    ToolTip = 'Specifies the total statistical value in the Intrastat report.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateErrors();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if ClientTypeManagement.GetCurrentClientType() <> ClientType::ODataV4 then
            UpdateStatisticalValue();
        UpdateErrors();
    end;

    trigger OnInit()
    begin
        StatisticalValueVisible := true;
    end;

    trigger OnOpenPage()
    begin
        if ClientTypeManagement.GetCurrentClientType() = ClientType::ODataV4 then
            exit;
        LineStyleExpression := 'Standard';
    end;

    var
        ClientTypeManagement: Codeunit "Client Type Management";
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        LineStyleExpression: Text;
        StatisticalValue: Decimal;
        TotalStatisticalValue: Decimal;
        ShowStatisticalValue: Boolean;
        ShowTotalStatisticalValue: Boolean;
        StatisticalValueVisible: Boolean;

    procedure UpdateMarkedOnly()
    begin
        if Rec.FindSet() then
            repeat
                Rec.Mark(ErrorsExistOnCurrentLine(Rec));
            until Rec.Next() = 0;

        Rec.MarkedOnly(not Rec.MarkedOnly());

        if Rec.FindFirst() then
            CurrPage.Update(false);
    end;

    local procedure UpdateStatisticalValue()
    begin
        IntrastatReportMgt.CalcStatisticalValue(
          Rec, xRec, StatisticalValue, TotalStatisticalValue,
          ShowStatisticalValue, ShowTotalStatisticalValue);

        StatisticalValueVisible := ShowStatisticalValue;
        StatisticalValueVisible := ShowTotalStatisticalValue;
    end;

    local procedure ErrorsExistOnCurrentLine(IntrastatReportLine: Record "Intrastat Report Line"): Boolean
    var
        ErrorMessage: Record "Error Message";
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        if IntrastatReportHeader.Get(IntrastatReportLine."Intrastat No.") then begin
            ErrorMessage.SetContext(IntrastatReportHeader);
            exit(ErrorMessage.HasErrorMessagesRelatedTo(IntrastatReportLine));
        end else
            exit(false);
    end;

    local procedure UpdateErrors()
    var
        IsHandled, ErrorExists : Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateErrors(IsHandled, Rec);
        if IsHandled then
            exit;

        ErrorExists := ErrorsExistOnCurrentLine(Rec);

        if ErrorExists then
            LineStyleExpression := 'Attention'
        else
            LineStyleExpression := 'None';

        Rec.Mark(ErrorExists);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeUpdateErrors(var IsHandled: boolean; var IntrastatReportLine: Record "Intrastat Report Line")
    begin
    end;
}