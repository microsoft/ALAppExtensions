codeunit 20301 "Tax Document Stats Mgmt."
{
    procedure UpdateTaxComponent(RecordIDList: List of [RecordID]; var ComponentSummary: Record "Tax Component Summary" temporary)
    var
        CaseIDList: List of [Guid];
        i: Integer;
    begin
        ComponentSummary.Reset();
        ComponentSummary.DeleteAll();

        //This is will fill all components calculated on Tax Transaction value in Temp table of RecordID.
        //grouped by CaseID,ComponentID,Percentage
        //RecordIDList contains set of all recordID related to one document.
        for i := 1 to RecordIDList.Count() do
            UpdateComponents(RecordIDList.Get(i), CaseIDList);

        i := 0;

        //This Loop will add a record for use case description to display as a tree view.
        for i := 1 to CaseIDList.Count() do begin
            CreateUseCaseRecord(CaseIDList.Get(i));
            FillComponentSummaryFromBuffer(CaseIDList.Get(i));
        end;

        CopyComponentRecord(ComponentSummary);
    end;

    procedure ClearBuffer()
    begin
        //This is to ensure that Temp variable gets cleared on closing of pages.
        TempTaxComponentSummary.Reset();
        TempTaxComponentSummary2.Reset();
        TempTaxComponentSummary.DeleteAll();
        TempTaxComponentSummary2.DeleteAll();
    end;

    local procedure CopyComponentRecord(var ComponentSummary: Record "Tax Component Summary" temporary)
    begin
        TempTaxComponentSummary.Reset();
        ComponentSummary.Copy(TempTaxComponentSummary, true);
        ComponentSummary.Reset();
        if ComponentSummary.FindSet() then;
    end;

    local procedure UpdateComponents(RecId: RecordId; var CaseIDList: List of [Guid])
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        UseCaseID: Guid;
    begin
        TaxTransactionValue.SetCurrentKey("Case ID", "Tax Record ID", "Value ID");
        TaxTransactionValue.SetRange("Tax Record ID", RecId);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        if TaxTransactionValue.FindSet() then
            repeat
                if UseCaseID <> TaxTransactionValue."Case ID" then
                    UpdateCaseIdList(TaxTransactionValue."Case ID", CaseIDList);

                FillComponentBuffer(TaxTransactionValue);
                UseCaseID := TaxTransactionValue."Case ID";
            until TaxTransactionValue.Next() = 0;
    end;

    local procedure UpdateCaseIdList(CaseId: Guid; var CaseIDList: List of [Guid])
    begin
        if not CaseIDList.Contains(CaseId) then
            CaseIDList.Add(CaseId);
    end;

    local procedure FillComponentBuffer(TaxTransactionValue: Record "Tax Transaction Value")
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
    begin
        LineCounter += 1;
        ScriptSymbolsMgmt.SetContext(TaxTransactionValue."Tax Type", TaxTransactionValue."Case ID", EmptyGuid);

        TempTaxComponentSummary2.Reset();
        TempTaxComponentSummary2.SetRange("Case ID", TaxTransactionValue."Case ID");
        TempTaxComponentSummary2.SetRange("Component ID", TaxTransactionValue."Value ID");
        TempTaxComponentSummary2.SetRange("Component %", TaxTransactionValue.Percent);
        if not TempTaxComponentSummary2.FindSet() then begin
            clear(TempTaxComponentSummary2);
            TempTaxComponentSummary2."Entry No." := LineCounter;
            TempTaxComponentSummary2."Case ID" := TaxTransactionValue."Case ID";
            TempTaxComponentSummary2."Use Case" := GetDescription(TaxTransactionValue."Case ID");
            TempTaxComponentSummary2."Component ID" := TaxTransactionValue."Value ID";
            TempTaxComponentSummary2."Name" := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Component, TaxTransactionValue."Value ID");
            TempTaxComponentSummary2."Component %" := TaxTransactionValue.Percent;

            TempTaxComponentSummary2.Amount := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            TempTaxComponentSummary2."Indentation Level" := 1;
            TempTaxComponentSummary2.Insert();
        end else begin
            TempTaxComponentSummary2.Amount += TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            TempTaxComponentSummary2.Modify();
        end;
    end;

    local procedure CreateUseCaseRecord(CaseID: Guid)
    var
        UseCaseDescription: Text[2000];
    begin
        UseCaseDescription := GetDescription(CaseID);
        LineCounter += 1;
        TempTaxComponentSummary.Init();
        TempTaxComponentSummary."Entry No." := LineCounter;
        TempTaxComponentSummary."Case ID" := CaseID;
        TempTaxComponentSummary."Use Case" := UseCaseDescription;
        TempTaxComponentSummary."Name" := copystr(UseCaseDescription, 1, 250);
        TempTaxComponentSummary."Indentation Level" := 0;
        TempTaxComponentSummary.Amount := 0;
        TempTaxComponentSummary."Base Amount" := 0;
        TempTaxComponentSummary."Component %" := 0;
        TempTaxComponentSummary.Insert();
    end;

    local procedure FillComponentSummaryFromBuffer(CaseID: Guid)
    begin
        TempTaxComponentSummary2.Reset();
        TempTaxComponentSummary2.SetRange("Case ID", CaseID);
        if TempTaxComponentSummary2.FindSet() then
            repeat
                LineCounter += 1;
                TempTaxComponentSummary.Init();
                TempTaxComponentSummary := TempTaxComponentSummary2;
                TempTaxComponentSummary."Entry No." := LineCounter;
                TempTaxComponentSummary.Insert();
                TempTaxComponentSummary2.Delete();
            until TempTaxComponentSummary2.Next() = 0;
    end;

    local procedure GetDescription(CaseID: Guid): Text[2000]
    begin
        if TaxUseCase.ID <> CaseID then
            TaxUseCase.Get(CaseID);

        exit(TaxUseCase.Description);
    end;

    var
        TempTaxComponentSummary2, TempTaxComponentSummary : Record "Tax Component Summary" temporary;
        TaxUseCase: Record "Tax Use Case";
        EmptyGuid: Guid;
        LineCounter: Integer;
}