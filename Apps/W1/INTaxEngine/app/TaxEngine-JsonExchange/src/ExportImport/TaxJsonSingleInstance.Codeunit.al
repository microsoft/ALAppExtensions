codeunit 20367 "Tax Json Single Instance"
{
    SingleInstance = true;
    procedure ClearValues()
    begin
        TempUseCase.Reset();
        if not TempUseCase.IsEmpty() then
            TempUseCase.DeleteAll();
    end;

    procedure UpdateReplacedUseCase(TaxUseCase: Record "Tax Use Case")
    begin
        if TempUseCase.Get(TaxUseCase.ID) then
            exit;
        TempUseCase.Init();
        TempUseCase := TaxUseCase;
        TempUseCase.Insert();
    end;

    procedure OpenReplcedTaxUseCases()
    begin
        if not GuiAllowed then
            exit;
        Commit();
        TempUseCase.Reset();
        if TempUseCase.FindSet() then begin
            Message(UseCaseReplacedMsg);
            Page.Run(Page::"Use Cases", TempUseCase);
        end;
    end;

    var
        TempUseCase: Record "Tax Use Case" temporary;
        UseCaseReplacedMsg: Label 'We have updated some use cases which were modified by you. please export these use cases and apply your changes manually.';

}