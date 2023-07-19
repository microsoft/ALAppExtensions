codeunit 31476 "Calc. And Post VAT Handler CZZ"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Report, Report::"Calc. and Post VAT Settl. CZL", 'OnClosingGLAndVATEntryOnAfterGetRecordOnAfterSetVATEntryFilters', '', false, false)]
    local procedure FilterAdvancesOnClosingGLAndVATEntryOnAfterGetRecordOnAfterSetVATEntryFilters(var VATEntry: Record "VAT Entry")
    begin
        if AdvanceNumberRun = 1 then
            VATEntry.SetFilter("Advance Letter No. CZZ", '=''''');
        if AdvanceNumberRun = 2 then
            VATEntry.SetFilter("Advance Letter No. CZZ", '<>''''');
    end;

    procedure SetAdvanceNumberRun(AdvanceNumberRunSet: Integer)
    begin
        AdvanceNumberRun := AdvanceNumberRunSet;
    end;

    var
        AdvanceNumberRun: Integer;
}