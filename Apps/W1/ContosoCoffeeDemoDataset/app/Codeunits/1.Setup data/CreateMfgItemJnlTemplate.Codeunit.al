codeunit 4763 "Create Mfg Item Jnl Template"
{
    Permissions = tabledata "Item Journal Template" = rim,
        tabledata "No. Series" = r,
        tabledata "Source Code Setup" = r;

    trigger OnRun()
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        SourceCodeSetup.Get();

        InsertData(
          XITEMTok, XItemJournalTok, ItemJournalTemplate.Type::Item, false, SourceCodeSetup."Item Journal",
            '', XItemJournalTok, '', '');
        InsertData(
          XCONSUMPTok, XConsumptionJournalTok, ItemJournalTemplate.Type::Consumption, false, SourceCodeSetup."Consumption Journal",
          '', XConsumptionJournalTok, '', '');
        InsertData(
          XOUTPUTTok, XOutputJournalTok, ItemJournalTemplate.Type::Output, false, SourceCodeSetup."Output Journal",
          '', XOutputJournalTok, '', '');
        InsertData(
          XCAPACITYTok, XCapacityJournalTok, ItemJournalTemplate.Type::Capacity, false, SourceCodeSetup."Capacity Journal",
          '', XCapacityJournalTok, '', '');
    end;

    var
        SourceCodeSetup: Record "Source Code Setup";
        CreateMfgNoSeries: Codeunit "Create Mfg No. Series";
        XITEMTok: Label 'ITEM', MaxLength = 10;
        XItemJournalTok: Label 'Item Journal', MaxLength = 30;
        XCONSUMPTok: Label 'CONSUMP', MaxLength = 10;
        XConsumptionJournalTok: Label 'Consumption Journal', MaxLength = 30;
        XOUTPUTTok: Label 'OUTPUT', MaxLength = 10;
        XOutputJournalTok: Label 'Output Journal', MaxLength = 30;
        XCAPACITYTok: Label 'CAPACITY', MaxLength = 10;
        XCapacityJournalTok: Label 'Capacity Journal', MaxLength = 30;

    local procedure InsertData(Name: Code[10]; Description: Text[80]; Type: Enum "Item Journal Template Type"; Recurring: Boolean; SourceCode: Code[10]; NoSeriesCode: Code[20]; NoSeriesDescription: Text[30]; NoSeriesStartNo: Code[20]; NoSeriesEndNo: Code[20])
    var
        ItemJournalTemplate: Record "Item Journal Template";
        NoSeries: Record "No. Series";
    begin
        if ItemJournalTemplate.Get(Name) then
            exit;

        if NoSeriesCode <> '' then
            if not NoSeries.Get(NoSeriesCode) then
                InitBaseSeries(NoSeriesCode, NoSeriesDescription, NoSeriesStartNo, NoSeriesEndNo);

        ItemJournalTemplate.Init();
        ItemJournalTemplate.Validate(Name, Name);
        ItemJournalTemplate.Validate(Description, Description);
        ItemJournalTemplate.Insert(true);
        ItemJournalTemplate.Validate(Type, Type);
        ItemJournalTemplate.Validate(Recurring, Recurring);
        if Recurring then
            ItemJournalTemplate.Validate("Posting No. Series", NoSeriesCode)
        else
            ItemJournalTemplate.Validate("No. Series", NoSeriesCode);
        ItemJournalTemplate.Validate("Source Code", SourceCode);
        ItemJournalTemplate.Modify();
    end;

    local procedure InitBaseSeries(var NoSeriesCode: Code[20]; NoSeriesDescription: Text[30]; NoSeriesStartNo: Code[20]; NoSeriesEndNo: Code[20])
    begin
        OnBeforeInitSeries(NoSeriesCode);
        CreateMfgNoSeries.InitBaseSeries(NoSeriesCode, NoSeriesCode, NoSeriesDescription, NoSeriesStartNo, NoSeriesEndNo, '', '', 1);
        OnAfterInitSeries(NoSeriesCode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSeries(var NoSeriesCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitSeries(var NoSeriesCode: Code[20])
    begin
    end;
}