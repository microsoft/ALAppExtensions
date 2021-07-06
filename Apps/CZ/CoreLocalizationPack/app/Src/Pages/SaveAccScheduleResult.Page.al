page 31202 "Save Acc. Schedule Result CZL"
{
    Caption = 'Save Acc. Schedule Result';
    PageType = Card;

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(AccSchedName; AccSchedName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Acc. Schedule Name';
                    Lookup = true;
                    TableRelation = "Acc. Schedule Name";
                    ToolTip = 'Specifies the name of account schedule.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        EnteredSchedName: Text[10];
                        LookupName: Boolean;
                    begin
                        EnteredSchedName := CopyStr(Text, 1, MaxStrLen(EnteredSchedName));
                        LookupName := AccSchedManagement.LookupName(AccSchedName, EnteredSchedName);
                        Text := EnteredSchedName;
                        exit(LookupName);
                    end;

                    trigger OnValidate()
                    begin
                        UpdateColumnLayoutName();
                    end;
                }
                field(ColumnLayoutName; ColumnLayoutName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Column Layout Name';
                    Lookup = true;
                    TableRelation = "Column Layout Name".Name;
                    ToolTip = 'Specifies the name of the column layout that you want to use in the window.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        EnteredColumnName: Text[10];
                        LookupColumnName: Boolean;
                    begin
                        EnteredColumnName := CopyStr(Text, 1, MaxStrLen(EnteredColumnName));
                        LookupColumnName := AccSchedManagement.LookupColumnName(ColumnLayoutName, EnteredColumnName);
                        Text := EnteredColumnName;
                        exit(LookupColumnName);
                    end;

                    trigger OnValidate()
                    begin
                        AccSchedManagement.CheckColumnName(ColumnLayoutName);
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the date filter for G/L accounts entries.';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(DateFilter);
                        AccScheduleLine.SetFilter("Date Filter", DateFilter);
                        DateFilter := AccScheduleLine.GetFilter("Date Filter");
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of account schedule result.';
                }
                field(UseAmtsInAddCurr; UseAmtsInAddCurr)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Amounts in Add. Reporting Currency';
                    MultiLine = true;
                    ToolTip = 'Specifies when the amounts in additional reporting currency is to be show';
                }
            }
        }
    }

    var
        AccScheduleName: Record "Acc. Schedule Name";
        AccScheduleLine: Record "Acc. Schedule Line";
        AccSchedManagement: Codeunit AccSchedManagement;
        AccSchedName: Code[10];
        ColumnLayoutName: Code[10];
        DateFilter: Text;
        Description: Text[50];
        UseAmtsInAddCurr: Boolean;

    procedure UpdateColumnLayoutName()
    begin
        AccSchedManagement.CheckName(AccSchedName);
        AccScheduleName.Get(AccSchedName);
        if AccScheduleName."Default Column Layout" <> '' then
            ColumnLayoutName := AccScheduleName."Default Column Layout";
    end;

    procedure SetParameters(NewAccSchedName: Code[10]; NewColumnLayoutName: Code[10]; NewDateFilter: Text; NewUseAmtsInAddCurr: Boolean)
    begin
        AccSchedName := NewAccSchedName;
        if NewColumnLayoutName = '' then
            UpdateColumnLayoutName()
        else
            ColumnLayoutName := NewColumnLayoutName;
        DateFilter := NewDateFilter;
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
    end;

    procedure GetParameters(var NewAccSchedName: Code[10]; var NewColumnLayoutName: Code[10]; var NewDateFilter: Text; var NewDescription: Text[50]; var NewUseAmtsInAddCurr: Boolean)
    begin
        NewAccSchedName := AccSchedName;
        NewColumnLayoutName := ColumnLayoutName;
        NewDateFilter := DateFilter;
        NewDescription := Description;
        NewUseAmtsInAddCurr := UseAmtsInAddCurr;
    end;
}