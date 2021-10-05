codeunit 20367 "Tax Json Single Instance"
{
    procedure UpdateReplacedUseCase(TaxUseCase: Record "Tax Use Case")
    var
        UpgradedUseCases: Record "Upgraded Use Cases";
    begin
        if UpgradedUseCases.Get(TaxUseCase.ID) then
            exit;

        UpgradedUseCases.Init();
        UpgradedUseCases."Use Case ID" := TaxUseCase.ID;
        UpgradedUseCases.Insert();
    end;

    procedure UpdateReplacedTaxType(TaxType: Record "Tax Type")
    var
        UpgradedTaxTypes: Record "Upgraded Tax Types";
    begin
        if UpgradedTaxTypes.Get(TaxType.Code) then
            exit;

        UpgradedTaxTypes.Init();
        UpgradedTaxTypes."Tax Type" := TaxType.Code;
        UpgradedTaxTypes.Insert();
    end;

    procedure OpenReplcedTaxUseCases()
    var
        TempTaxUseCase: Record "Tax Use Case" temporary;
        TaxUseCase: Record "Tax Use Case";
        UpgradedUseCases: Record "Upgraded Use Cases";
    begin
        if not GuiAllowed then
            exit;
        if UpgradedUseCases.FindSet() then
            repeat
                TaxUseCase.Get(UpgradedUseCases."Use Case ID");

                TempTaxUseCase.Init();
                TempTaxUseCase := TaxUseCase;
                TempTaxUseCase.Insert();
            until UpgradedUseCases.Next() = 0;

        Commit();
        TempTaxUseCase.Reset();
        if TempTaxUseCase.FindSet() then begin
            if not HideDialog then
                Message(UseCaseReplacedMsg);
            Page.Run(Page::"Use Cases", TempTaxUseCase);
        end;
    end;

    procedure OpenReplacedTaxTypes()
    var
        TempTaxType: Record "Tax Type" temporary;
        TaxType: Record "Tax Type";
        UpgradedTaxTypes: Record "Upgraded Tax Types";
    begin
        if not GuiAllowed then
            exit;
        if UpgradedTaxTypes.FindSet() then
            repeat
                TaxType.Get(UpgradedTaxTypes."Tax Type");

                TempTaxType.Init();
                TempTaxType := TaxType;
                TempTaxType.Insert();
            until UpgradedTaxTypes.Next() = 0;

        Commit();
        TempTaxType.Reset();
        if TempTaxType.FindSet() then
            Page.Run(Page::"Tax Types", TempTaxType);
    end;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;

    var
        HideDialog: Boolean;
        UseCaseReplacedMsg: Label 'We have upgraded some use cases which were modified by you. you can export these use cases and apply your changes manually.';
}