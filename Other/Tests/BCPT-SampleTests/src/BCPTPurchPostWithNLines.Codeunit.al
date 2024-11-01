codeunit 149119 "BCPT Purch. Post with N Lines" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun();
    var
        PurchHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
        PurchHeaderId: Guid;
    begin
        If not IsInitialized or true then begin
            InitTest();
            IsInitialized := true;
        end;
        PurchHeaderId := CreatePurchaseOrder(BCPTTestContext);
        PurchHeader.GetBySystemId(PurchHeaderId);
        PurchHeader.Validate(Receive, true);
        PurchHeader.Validate(Invoice, true);
        PurchHeader.Validate("Vendor Invoice No.", PurchHeader."No.");
        PurchPost.Run(PurchHeader);
    end;

    var
        BCPTTestContext: Codeunit "BCPT Test Context";
        IsInitialized: Boolean;
        NoOfLinesParamLbl: Label 'Lines';
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"';
        NoOfLinesToCreate: Integer;

    local procedure InitTest();
    var
        PurchaseSetup: Record "Purchases & Payables Setup";
        NoSeriesLine: Record "No. Series Line";
    begin
        PurchaseSetup.Get();
        PurchaseSetup.TestField("Order Nos.");
        NoSeriesLine.SetRange("Series Code", PurchaseSetup."Order Nos.");
        NoSeriesLine.findset(true, true);
        repeat
            if NoSeriesLine."Ending No." <> '' then begin
                NoSeriesLine."Ending No." := '';
                NoSeriesLine.Validate("Allow Gaps in Nos.", true);
                NoSeriesLine.Modify(true);
            end;
        until NoSeriesLine.Next() = 0;
        commit();

        if Evaluate(NoOfLinesToCreate, BCPTTestContext.GetParameter(NoOfLinesParamLbl)) then;
    end;

    local procedure CreatePurchaseOrder(Var BCPTTestContext: Codeunit "BCPT Test Context"): Guid
    var
        Vendor: Record Vendor;
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        i: Integer;
    begin
        if not Vendor.get('10000') then
            Vendor.FindFirst();
        if not Item.get('70000') then
            Item.FindFirst();
        if NoOfLinesToCreate < 0 then
            NoOfLinesToCreate := 0;
        if NoOfLinesToCreate > 10000 then
            NoOfLinesToCreate := 10000;
        BCPTTestContext.StartScenario('Add Order');
        PurchaseHeader.init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Insert(true);
        BCPTTestContext.EndScenario('Add Order');
        BCPTTestContext.UserWait();
        BCPTTestContext.StartScenario('Enter Account No.');
        PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.Modify(true);
        Commit();
        BCPTTestContext.EndScenario('Enter Account No.');
        BCPTTestContext.UserWait();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        for i := 1 to NoOfLinesToCreate do begin
            PurchaseLine."Line No." += 10000;
            PurchaseLine.Init();
            PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
            PurchaseLine.Insert(true);
            BCPTTestContext.UserWait();
            if i = 10 then
                BCPTTestContext.StartScenario('Enter Line Item No.');
            PurchaseLine.Validate("No.", Item."No.");
            if i = 10 then
                BCPTTestContext.EndScenario('Enter Line Item No.');
            BCPTTestContext.UserWait();
            if i = 10 then
                BCPTTestContext.StartScenario('Enter Line Quantity');
            PurchaseLine.Validate(Quantity, 1);
            if i = 10 then
                BCPTTestContext.EndScenario('Enter Line Quantity');
            PurchaseLine.Modify(true);
            Commit();
            BCPTTestContext.UserWait();
        end;
        exit(PurchaseHeader.SystemId);
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(copystr(NoOfLinesParamLbl + '=' + Format(10), 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
        if StrPos(Parameters, NoOfLinesParamLbl) > 0 then begin
            Parameters := DelStr(Parameters, 1, StrLen(NoOfLinesParamLbl + '='));
            if Evaluate(NoOfLinesToCreate, Parameters) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultParameters());
    end;
}