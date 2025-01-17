namespace Microsoft.SubscriptionBilling;

codeunit 8009 "Price Update Management"
{
    Access = Internal;

    var
        LastGroupByValue: Code[20];
        LastGroupEntryNo: Integer;

    internal procedure InitTempTable(var TempContractPriceUpdateLine: Record "Contract Price Update Line" temporary; GroupBy: Enum "Contract Billing Grouping")
    var
        ContractPriceUpdateLine: Record "Contract Price Update Line";
        TempContractPriceUpdateLine2: Record "Contract Price Update Line" temporary;
    begin
        TempContractPriceUpdateLine2.CopyFilters(TempContractPriceUpdateLine);
        ContractPriceUpdateLine.CopyFilters(TempContractPriceUpdateLine);
        TempContractPriceUpdateLine.Reset();
        TempContractPriceUpdateLine.DeleteAll(false);
        LastGroupEntryNo := 0;

        SetKeysForGrouping(ContractPriceUpdateLine, TempContractPriceUpdateLine, GroupBy);

        if ContractPriceUpdateLine.FindSet() then
            repeat
                CreateGroupingLine(TempContractPriceUpdateLine, ContractPriceUpdateLine, GroupBy);
                TempContractPriceUpdateLine := ContractPriceUpdateLine;
                TempContractPriceUpdateLine.Indent := 1;
                TempContractPriceUpdateLine.Insert(false);
            until ContractPriceUpdateLine.Next() = 0;
        TempContractPriceUpdateLine.CopyFilters(TempContractPriceUpdateLine2);
    end;

    local procedure SetKeysForGrouping(var ContractPriceUpdateLine: Record "Contract Price Update Line"; var TempContractPriceUpdateLine: Record "Contract Price Update Line" temporary; GroupBy: Enum "Contract Billing Grouping")
    begin
        case GroupBy of
            GroupBy::Contract:
                begin
                    ContractPriceUpdateLine.SetCurrentKey(Partner, "Contract No.");
                    TempContractPriceUpdateLine.SetCurrentKey(Partner, "Contract No.");
                end;
            GroupBy::"Contract Partner":
                begin
                    ContractPriceUpdateLine.SetCurrentKey(Partner, "Partner No.");
                    TempContractPriceUpdateLine.SetCurrentKey(Partner, "Partner No.");
                end;
            GroupBy::None:
                TempContractPriceUpdateLine.SetCurrentKey("Entry No.");
        end;
        LastGroupByValue := '';
    end;

    local procedure CreateGroupingLine(var TempContractPriceUpdateLine: Record "Contract Price Update Line" temporary; ContractPriceUpdateLine: Record "Contract Price Update Line"; GroupBy: Enum "Contract Billing Grouping")
    begin
        if GroupingLineShouldBeInserted(ContractPriceUpdateLine, GroupBy) then begin
            TempContractPriceUpdateLine.Init();
            TempContractPriceUpdateLine."Entry No." := LastGroupEntryNo - 1;
            LastGroupEntryNo := TempContractPriceUpdateLine."Entry No.";
            TempContractPriceUpdateLine.Partner := ContractPriceUpdateLine.Partner;
            TempContractPriceUpdateLine."Partner No." := ContractPriceUpdateLine."Partner No.";
            TempContractPriceUpdateLine."Partner Name" := ContractPriceUpdateLine."Partner Name";
            TempContractPriceUpdateLine."Contract Description" := ContractPriceUpdateLine."Contract Description";
            if GroupBy = GroupBy::Contract then
                TempContractPriceUpdateLine."Contract No." := ContractPriceUpdateLine."Contract No.";
            TempContractPriceUpdateLine.Indent := 0;
            TempContractPriceUpdateLine.Insert(false);
        end;
    end;

    local procedure GroupingLineShouldBeInserted(ContractPriceUpdateLine: Record "Contract Price Update Line"; GroupBy: Enum "Contract Billing Grouping") InsertLine: Boolean
    var
        NewGroupByValue: Code[20];
    begin
        case GroupBy of
            GroupBy::Contract:
                NewGroupByValue := ContractPriceUpdateLine."Contract No.";
            GroupBy::"Contract Partner":
                NewGroupByValue := ContractPriceUpdateLine."Partner No.";
        end;

        InsertLine := LastGroupByValue <> NewGroupByValue;
        if InsertLine then
            LastGroupByValue := NewGroupByValue;
    end;

    internal procedure CreatePriceUpdateProposal(PriceUpdateTemplateCode: Code[20]; IncludeServiceCommitmentUpToDate: Date; PerformUpdateOnDate: Date)
    var
        PriceUpdateTemplate: Record "Price Update Template";
        PriceUpdateProposalCannotBeCreateWithoutTemplateErr: Label 'Price Update Proposals cannot be created without a Price Update Template. Please select a template before.';
        ContractPriceUpdate: Interface "Contract Price Update";
    begin
        if PriceUpdateTemplateCode = '' then
            Error(PriceUpdateProposalCannotBeCreateWithoutTemplateErr);

        PriceUpdateTemplate.Get(PriceUpdateTemplateCode);
        ContractPriceUpdate := PriceUpdateTemplate."Price Update Method";
        ContractPriceUpdate.SetPriceUpdateParameters(PriceUpdateTemplate, IncludeServiceCommitmentUpToDate, PerformUpdateOnDate);
        ContractPriceUpdate.ApplyFilterOnServiceCommitments();
        ContractPriceUpdate.CreatePriceUpdateProposal();
    end;

    internal procedure TestIncludeServiceCommitmentUpToDate(IncludeServiceCommitmentUpToDate: Date)
    var
        NoIncludeContractLinesUpToDateErr: Label 'Please enter the Include Contract Lines up to Date.';
    begin
        if IncludeServiceCommitmentUpToDate = 0D then
            Error(NoIncludeContractLinesUpToDateErr);
    end;

    internal procedure GetAndApplyFiltersOnServiceCommitment(var ServiceCommitment: Record "Service Commitment"; PriceUpdateTemplate: Record "Price Update Template"; IncludeServiceCommitmentUpToDate: Date)
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
        ServiceObjectFilterText: Text;
        ServiceCommitmentFilterText: Text;
        ContractFilterText: Text;
    begin
        ApplyDefaultFiltering(ServiceCommitment, PriceUpdateTemplate, IncludeServiceCommitmentUpToDate);
        InitTempServiceCommitmentTable(ServiceCommitment, TempServiceCommitment);

        if PriceUpdateTemplate."Contract Filter".HasValue() then
            ContractFilterText := PriceUpdateTemplate.ReadFilter(PriceUpdateTemplate.FieldNo("Contract Filter"));
        if PriceUpdateTemplate."Service Object Filter".HasValue() then
            ServiceObjectFilterText := PriceUpdateTemplate.ReadFilter(PriceUpdateTemplate.FieldNo("Service Object Filter"));
        if PriceUpdateTemplate."Service Commitment Filter".HasValue() then
            ServiceCommitmentFilterText := PriceUpdateTemplate.ReadFilter(PriceUpdateTemplate.FieldNo("Service Commitment Filter"));

        if ServiceCommitmentFilterText <> '' then begin
            ServiceCommitment.SetView(ServiceCommitmentFilterText);
            ApplyDefaultFiltering(ServiceCommitment, PriceUpdateTemplate, IncludeServiceCommitmentUpToDate);
            FindAndMarkMatchedAndDeleteUnmarkedServiceCommitment(ServiceCommitment, TempServiceCommitment);
        end;
        if ServiceObjectFilterText <> '' then begin
            FilterAndMarkServiceCommitmentOnServiceObject(ServiceCommitment, ServiceObjectFilterText, PriceUpdateTemplate, IncludeServiceCommitmentUpToDate);
            FindAndMarkMatchedAndDeleteUnmarkedServiceCommitment(ServiceCommitment, TempServiceCommitment);
        end;
        if ContractFilterText <> '' then begin
            FilterAndMarkServiceCommitmentOnContract(ServiceCommitment, ContractFilterText, PriceUpdateTemplate, IncludeServiceCommitmentUpToDate);
            FindAndMarkMatchedAndDeleteUnmarkedServiceCommitment(ServiceCommitment, TempServiceCommitment);
        end;

        MarkServiceCommitmentsFromTempTable(ServiceCommitment, TempServiceCommitment);
        OnAfterFilterServiceCommitmentOnAfterGetAndApplyFiltersOnServiceCommitment(ServiceCommitment);
    end;

    local procedure ApplyDefaultFiltering(var ServiceCommitment: Record "Service Commitment"; PriceUpdateTemplate: Record "Price Update Template"; IncludeServiceCommitmentUpToDate: Date)
    begin
        ServiceCommitment.SetRange(Partner, PriceUpdateTemplate.Partner);
        ServiceCommitment.SetRange("Exclude from Price Update", false);
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetFilter("Next Price Update", '<=%1|%2', IncludeServiceCommitmentUpToDate, 0D);
        ServiceCommitment.SetRange("Planned Serv. Comm. exists", false);
        ServiceCommitment.SetRange("Usage Based Billing", false);
        ServiceCommitment.SetRange(Closed, false);
    end;

    local procedure InitTempServiceCommitmentTable(ServiceCommitment: Record "Service Commitment"; var TempServiceCommitment: Record "Service Commitment" temporary)
    begin
        TempServiceCommitment.Reset();
        TempServiceCommitment.DeleteAll(false);
        if ServiceCommitment.FindSet() then
            repeat
                TempServiceCommitment := ServiceCommitment;
                TempServiceCommitment.Insert(false);
            until ServiceCommitment.Next() = 0;
    end;

    local procedure FindAndMarkMatchedAndDeleteUnmarkedServiceCommitment(var ServiceCommitment: Record "Service Commitment"; var TempServiceCommitment: Record "Service Commitment" temporary)
    begin
        if ServiceCommitment.FindSet() then
            repeat
                if TempServiceCommitment.Get(ServiceCommitment."Entry No.") then
                    TempServiceCommitment.Mark(true);
            until ServiceCommitment.Next() = 0;
        DeleteUnmarkedTempServiceCommitment(TempServiceCommitment);
    end;

    local procedure DeleteUnmarkedTempServiceCommitment(var TempServiceCommitment: Record "Service Commitment" temporary)
    begin
        if TempServiceCommitment.FindSet() then
            repeat
                if not TempServiceCommitment.Mark() then
                    TempServiceCommitment.Delete(false);
            until TempServiceCommitment.Next() = 0;
        TempServiceCommitment.Reset();
    end;

    local procedure FilterAndMarkServiceCommitmentOnServiceObject(var ServiceCommitment: Record "Service Commitment"; ServiceObjectFilterText: Text; PriceUpdateTemplate: Record "Price Update Template"; IncludeServiceCommitmentUpToDate: Date)
    var
        ServiceObject: Record "Service Object";
    begin
        ServiceCommitment.Reset();
        ServiceObject.SetView(ServiceObjectFilterText);
        ServiceObject.SetLoadFields("No.");
        if ServiceObject.FindSet() then
            repeat
                ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
                ApplyDefaultFiltering(ServiceCommitment, PriceUpdateTemplate, IncludeServiceCommitmentUpToDate);
                if ServiceCommitment.FindSet() then
                    repeat
                        ServiceCommitment.Mark(true);
                    until ServiceCommitment.Next() = 0;
            until ServiceObject.Next() = 0;
        ServiceCommitment.SetRange("Service Object No.");
        ServiceCommitment.MarkedOnly(true);
    end;

    local procedure FilterAndMarkServiceCommitmentOnContract(var ServiceCommitment: Record "Service Commitment"; ContractFilterText: Text; PriceUpdateTemplate: Record "Price Update Template"; IncludeServiceCommitmentUpToDate: Date)
    var
        VendorContract: Record "Vendor Contract";
        CustomerContract: Record "Customer Contract";
    begin
        ServiceCommitment.Reset();
        case PriceUpdateTemplate.Partner of
            "Service Partner"::Customer:
                begin
                    CustomerContract.SetView(ContractFilterText);
                    if CustomerContract.FindSet() then
                        repeat
                            ApplyContractFilterAndMarkServiceCommitment(ServiceCommitment, CustomerContract."No.", PriceUpdateTemplate, IncludeServiceCommitmentUpToDate)
                        until CustomerContract.Next() = 0;
                end;
            "Service Partner"::Vendor:
                begin
                    VendorContract.SetView(ContractFilterText);
                    if VendorContract.FindSet() then
                        repeat
                            ApplyContractFilterAndMarkServiceCommitment(ServiceCommitment, VendorContract."No.", PriceUpdateTemplate, IncludeServiceCommitmentUpToDate)
                        until VendorContract.Next() = 0;
                end;
        end;
        ServiceCommitment.SetRange(Partner);
        ServiceCommitment.SetRange("Contract No.");
        ServiceCommitment.MarkedOnly(true);
    end;

    local procedure ApplyContractFilterAndMarkServiceCommitment(var ServiceCommitment: Record "Service Commitment"; ContractNo: Code[20]; PriceUpdateTemplate: Record "Price Update Template"; IncludeServiceCommitmentUpToDate: Date)
    begin
        ServiceCommitment.FilterOnContract(PriceUpdateTemplate.Partner, ContractNo);
        ApplyDefaultFiltering(ServiceCommitment, PriceUpdateTemplate, IncludeServiceCommitmentUpToDate);
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment.Mark(true);
            until ServiceCommitment.Next() = 0;
    end;

    local procedure MarkServiceCommitmentsFromTempTable(var ServiceCommitment: Record "Service Commitment"; var TempServiceCommitment: Record "Service Commitment" temporary)
    begin
        ServiceCommitment.Reset();
        if TempServiceCommitment.FindSet() then
            repeat
                ServiceCommitment.Get(TempServiceCommitment."Entry No.");
                ServiceCommitment.Mark(true);
            until TempServiceCommitment.Next() = 0;
        ServiceCommitment.MarkedOnly(true);
    end;

    internal procedure DeleteProposal(PriceUpdateTemplateCode: Code[20])
    var
        ContractPriceUpdateLine: Record "Contract Price Update Line";
        ClearContractPriceUpdateProposalOptionsTxt: Label 'All Price Update Lines, Only current Price Update Template';
        ClearContractPriceUpdateProposalQst: Label 'Which Price Update lines(s) should be deleted?';
        StrMenuResponse: Integer;
    begin
        StrMenuResponse := Dialog.StrMenu(ClearContractPriceUpdateProposalOptionsTxt, 1, ClearContractPriceUpdateProposalQst);
        case StrMenuResponse of
            0:
                Error('');
            1:
                ContractPriceUpdateLine.DeleteAll(true);
            2:
                begin
                    ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCode);
                    DeleteContractPriceUpdateLines(ContractPriceUpdateLine);
                end;
        end;
    end;

    internal procedure DeleteContractPriceUpdateLines(var ContractPriceUpdateLine: Record "Contract Price Update Line")
    begin
        if not ContractPriceUpdateLine.IsEmpty() then
            ContractPriceUpdateLine.DeleteAll(true)
    end;

    internal procedure PerformPriceUpdate()
    var
        ContractPriceUpdateLine: Record "Contract Price Update Line";
    begin
        if ContractPriceUpdateLine.FindSet() then
            repeat
                Commit(); // Commit before if Codeunit.Run
                if Codeunit.Run(Codeunit::"Process Price Update", ContractPriceUpdateLine) then
                    ContractPriceUpdateLine.Delete(false);
            until ContractPriceUpdateLine.Next() = 0;
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterFilterServiceCommitmentOnAfterGetAndApplyFiltersOnServiceCommitment(var ServiceCommitment: Record "Service Commitment")
    begin
    end;
}