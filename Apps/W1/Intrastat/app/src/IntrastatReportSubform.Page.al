page 4813 "Intrastat Report Subform"
{
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
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    StyleExpr = LineStyleExpression;
                    ToolTip = 'Specifies whether the item was received or shipped by the company.';
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    StyleExpr = LineStyleExpression;
                    ToolTip = 'Specifies the date the item entry was posted.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    StyleExpr = LineStyleExpression;
                    ToolTip = 'Specifies the document number on the entry.';
                    ShowMandatory = true;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    StyleExpr = LineStyleExpression;
                    ToolTip = 'Specifies the number of the item.';
                }
                field(Name; Rec."Item Name")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    StyleExpr = LineStyleExpression;
                    ToolTip = 'Specifies the name of the item.';
                    Caption = 'Item Name';
                }
                field("Tariff No."; Rec."Tariff No.")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the item''s tariff number.';
                }
                field("Item Description"; Rec."Tariff Description")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the name of the tariff no. that is associated with the item.';
                    Caption = 'Tariff No. Description';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field("Partner VAT ID"; Rec."Partner VAT ID")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the counter party''s VAT number.';
                }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies a code for the country/region where the item was produced or processed.';
                }
                field("Area"; Rec.Area)
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the area of the customer or vendor, for the purpose of reporting to INTRASTAT.';
                    Visible = false;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the type of transaction that the document represents, for the purpose of reporting to INTRASTAT.';
                }
                field("Transaction Specification"; Rec."Transaction Specification")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies a specification of the document''s transaction, for the purpose of reporting to INTRASTAT.';
                    Visible = false;
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the transport method, for the purpose of reporting to INTRASTAT.';
                }
                field("Entry/Exit Point"; Rec."Entry/Exit Point")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the code of either the port of entry where the items passed into your country/region or the port of exit.';
                    Visible = false;
                }
                field("Supplementary Units"; Rec."Supplementary Units")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies if you must report information about quantity and units of measure for this item.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the number of units of the item in the entry.';
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the net weight of one unit of the item.';
                }
                field("Total Weight"; Rec."Total Weight")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the total weight for the items in the item entry.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the total amount of the entry, excluding VAT.';
                }
                field("Statistical Value"; Rec."Statistical Value")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the entry''s statistical value, which must be reported to the statistics authorities.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the entry type.';
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the number that the item entry had in the table it came from.';
                    Editable = false;
                }
                field("Cost Regulation %"; Rec."Cost Regulation %")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies any indirect costs, as a percentage.';
                    Visible = false;
                }
                field("Indirect Cost"; Rec."Indirect Cost")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies an amount that represents the costs for freight and insurance.';
                    Visible = false;
                }
                field("Internal Ref. No."; Rec."Internal Ref. No.")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies a reference number used by the customs and tax authorities.';
                }
                field("Shpt. Method Code"; Rec."Shpt. Method Code")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the item''s shipment method.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the code for the location that the entry is linked to.';
                }
                field("Suppl. Conversion Factor"; Rec."Suppl. Conversion Factor")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the conversion factor of the item on this Intrastat report line.';
                }
                field("Suppl. Unit of Measure"; Rec."Suppl. Unit of Measure")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the unit of measure code for the tariff number on this line.';
                }
                field("Supplementary Quantity"; Rec."Supplementary Quantity")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the quantity of supplementary units on the Intrastat line.';
                }
            }
            group(Control40)
            {
                ShowCaption = false;
                field(StatisticalValue; StatisticalValue + Rec."Statistical Value" - xRec."Statistical Value")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    AutoFormatType = 1;
                    Caption = 'Statistical Value';
                    Editable = false;
                    ToolTip = 'Specifies the statistical value that has accumulated in the Intrastat report.';
                    Visible = StatisticalValueVisible;
                }
                field(TotalStatisticalValue; TotalStatisticalValue + Rec."Statistical Value" - xRec."Statistical Value")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
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
        [InDataSet]
        StatisticalValueVisible: Boolean;

    procedure UpdateMarkedOnly()
    begin
        Rec.MarkedOnly(not Rec.MarkedOnly);
    end;

    local procedure UpdateStatisticalValue()
    begin
        IntrastatReportMgt.CalcStatisticalValue(
          Rec, xRec, StatisticalValue, TotalStatisticalValue,
          ShowStatisticalValue, ShowTotalStatisticalValue);

        StatisticalValueVisible := ShowStatisticalValue;
        StatisticalValueVisible := ShowTotalStatisticalValue;
    end;

    local procedure ErrorsExistOnCurrentLine(): Boolean
    var
        ErrorMessage: Record "Error Message";
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        if IntrastatReportHeader.Get(Rec."Intrastat No.") then begin
            ErrorMessage.SetContext(IntrastatReportHeader);
            exit(ErrorMessage.HasErrorMessagesRelatedTo(Rec));
        end else
            exit(false);
    end;

    local procedure UpdateErrors()
    var
        ErrorMessage: Record "Error Message";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateErrors(IsHandled, Rec);
        if IsHandled then
            exit;

        ErrorMessage.SetRange("Record ID", Rec.RecordId);
        if ErrorMessage.IsEmpty then
            LineStyleExpression := 'None'
        else
            LineStyleExpression := 'Attention';

        Rec.Mark(ErrorsExistOnCurrentLine());
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeUpdateErrors(var IsHandled: boolean; var IntrastatReportLine: Record "Intrastat Report Line")
    begin
    end;
}