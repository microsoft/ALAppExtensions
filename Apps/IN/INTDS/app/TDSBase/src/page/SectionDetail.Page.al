page 18688 "Section Detail"
{
    PageType = StandardDialog;
    SourceTable = "TDS Section";

    layout
    {
        area(Content)
        {
            group(Details)
            {
                field(SectionDetail; SectionDetail)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Section Details';
                    MultiLine = true;
                    ToolTip = 'Specify additional details for the TDS section.';
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [Action::OK, Action::LookupOK] then
            TDSEntityManagement.SetDetailTxt(SectionDetail, Rec);
    end;

    trigger OnOpenPage()
    begin
        SectionDetail := TDSEntityManagement.GetDetailTxt(rec);
    end;

    var
        TDSEntityManagement: Codeunit "TDS Entity Management";
        SectionDetail: Text;
}