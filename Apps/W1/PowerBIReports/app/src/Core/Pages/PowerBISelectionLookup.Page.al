namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 36963 "Power BI Selection Lookup"
{
    Caption = 'Select Power BI Element';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    Editable = false;
    PageType = List;
    SourceTable = "Power BI Selection Element";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(ElementsRepeater)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the Power BI report or workspace.';
                    Style = Strong;
                }
                field(ID; Rec.ID)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'ID';
                    Editable = false;
                    ToolTip = 'Specifies the ID of the Power BI report or workspace.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Type';
                    Editable = false;
                    ToolTip = 'Specifies the type of the line (e.g. workspace or report).';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        PowerBISelectionElement: Record "Power BI Selection Element";
        SelectTxt: Label 'Select Power BI %1', Comment = '%1 = Type';
    begin
        if Evaluate(PowerBISelectionElement.Type, Rec.GetFilter(Type)) then
            CurrPage.Caption := StrSubstNo(SelectTxt, PowerBISelectionElement.Type);
    end;
}