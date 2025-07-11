codeunit 139859 "APIV2 - Accounting Periods E2E"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        ServiceNameTxt: Label 'accountingPeriods', Locked = true;

    [Test]
    procedure TestGetAccountingPeriods()
    var
        AccountingPeriods: array[10] of Record "Accounting Period";
        ResponseText: Text;
        TargetURL: Text;
        i: Integer;
    begin
        // [SCENARIO] Use a GET method to retrieve all accounting periods
        // [GIVEN] Accounting Periods
        for i := 1 to 10 do
            CreateAccountingPeriod(AccountingPeriods[i], FindNextAccountingPeriodStartingDate(), false);
        Commit();
        // [WHEN] GET Accounting Periods
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Accounting Periods", ServiceNameTxt);
        ClearLastError();
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);
        // [THEN] Accounting Periods are retrieved
        VerifyAccountingPeriods(ResponseText, AccountingPeriods, 10);
    end;

    local procedure VerifyAccountingPeriods(ResponseText: Text; AccountingPeriods: array[10] of Record "Accounting Period"; N: Integer)
    var
        ListAccountingPeriodsIds: List of [Text];
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        IdJsonToken: JsonToken;
        JsonArray: JsonArray;
        i: Integer;
    begin
        JsonObject.ReadFrom(ResponseText);
        JsonObject.Get('value', JsonToken);
        JsonArray := JsonToken.AsArray();
        foreach JsonToken in JsonArray do begin
            JsonToken.AsObject().Get('id', IdJsonToken);
            ListAccountingPeriodsIds.Add(IdJsonToken.AsValue().AsText());
            JsonToken.AsObject().Get('startingDate', IdJsonToken);
            JsonToken.AsObject().Get('newFiscalYear', IdJsonToken);
            JsonToken.AsObject().Get('dateLocked', IdJsonToken);
        end;

        for i := 1 to N do
            Assert.IsTrue(ListAccountingPeriodsIds.Contains(LowerCase(AccountingPeriods[i].SystemId).Replace('{', '').Replace('}', '')), 'Created accounting period with id: ' + LowerCase(AccountingPeriods[i].SystemId).Replace('{', '').Replace('}', '') + ' not found');
    end;

    local procedure FindNextAccountingPeriodStartingDate(): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if not AccountingPeriod.FindLast() then
            exit(Today());
        exit(CalcDate('<-CM+1M>', AccountingPeriod."Starting Date"));
    end;

    local procedure CreateAccountingPeriod(var AccountingPeriod: Record "Accounting Period"; StartingDate: Date; IsNewFiscalYear: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        AccountingPeriod."Starting Date" := StartingDate;
        AccountingPeriod."New Fiscal Year" := IsNewFiscalYear;
        AccountingPeriod."Average Cost Calc. Type" := InventorySetup."Average Cost Calc. Type";
        AccountingPeriod."Average Cost Period" := InventorySetup."Average Cost Period";
        AccountingPeriod.Insert(true);
    end;

}