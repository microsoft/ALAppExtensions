page 20293 "Available Use Cases"
{
    Caption = 'Available Rules';
    PageType = List;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;
    SourceTableTemporary = true;
    SourceTable = "Tax Use Case";
    SourceTableView = SORTING(Enable) ORDER(Descending);

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Enable; Enable)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether use case is enabled for usage.';
                }
                field(Name; Description)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the use case.';
                }
            }
        }
    }

    procedure GetRuleBtuffer(var NewTempAvailableUseCase: Record "Tax Use Case" Temporary);
    begin
        NewTempAvailableUseCase.DeleteAll();
        TempUseCase.Reset();
        if TempUseCase.FindSet() then
            repeat
                NewTempAvailableUseCase.Init();
                NewTempAvailableUseCase := TempUseCase;
                NewTempAvailableUseCase.Insert();
            until TempUseCase.Next() = 0;
    end;

    procedure SetRuleBuffer(var NewTempAvailableUseCase: Record "Tax Use Case" Temporary);
    begin
        NewTempAvailableUseCase.Reset();
        if NewTempAvailableUseCase.FindSet() then
            repeat
                TempUseCase.Init();
                TempUseCase := NewTempAvailableUseCase;
                TempUseCase.Insert();
            until NewTempAvailableUseCase.Next() = 0;
    end;

    trigger OnOpenPage();
    begin
        TempUseCase.Reset();
        if TempUseCase.FindSet() then
            repeat
                Init();
                Rec := TempUseCase;
                Insert();
            until TempUseCase.Next() = 0;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    begin
        TempUseCase.Reset();
        TempUseCase.DeleteAll();
        Reset();
        if FindSet() then
            repeat
                TempUseCase.Init();
                TempUseCase := Rec;
                TempUseCase.Insert();
            until Next() = 0;
    end;

    var
        TempUseCase: Record "Tax Use Case" Temporary;
}