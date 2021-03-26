page 10677 "SAF-T G/L Mapping Subpage"
{
    PageType = ListPart;
    SourceTable = "SAF-T G/L Account Mapping";
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'G/L Account Mapping';

    layout
    {
        area(Content)
        {
            repeater(SAFTGLAccountMapping)
            {
                field(GLAccNo; "G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the account that is used to map the SAF-T standard account or grouping code.';
                    StyleExpr = GLAccStyleExpr;
                    Editable = false;
                }
                field(GLAccName; "G/L Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the account that is used to map the SAF-T standard account or grouping code.';
                }
                field(CategoryNo; "Category No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the category of the SAF-T standard account or grouping code that is used for mapping.';
                }
                field(No; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the SAF-T standard account or grouping code that is used for mapping.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateGLEntriesExists)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Update G/L Entry Availability';
                ToolTip = 'Mark G/L accounts that have posted G/L entries in green. If option Include Incoming Balance enabled then all posted G/L entries are considered for calculation. Otherwise only G/L entries of the reporting period are considered.';
                Image = PostingEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction();
                var
                    SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
                begin
                    SAFTMappingHelper.UpdateGLEntriesExistStateForGLAccMapping("Mapping Range Code");
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
    begin
        if SAFTMappingRange.FindFirst() then begin
            FilterGroup(4);
            SetRange("Mapping Range Code", SAFTMappingRange.Code);
            FilterGroup(0);
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateGLAccStyleExpr();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateGLAccStyleExpr();
    end;

    local procedure UpdateGLAccStyleExpr()
    begin
        if "G/L Entries Exists" then
            GLAccStyleExpr := 'Favorable'
        else
            GLAccStyleExpr := '';
    end;

    var
        GLAccStyleExpr: Text;
}
