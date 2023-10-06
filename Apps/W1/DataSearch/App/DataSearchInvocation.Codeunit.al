namespace Microsoft.Foundation.DataSearch;

using System.Environment;

codeunit 2684 "Data Search Invocation"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'GetDataSearchPageId', '', true, true)]
    local procedure GetDataSearchPageId(var PageId: Integer)
    begin
        PageId := Page::"Data Search";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'OpenDataSearchPage', '', true, true)]
    local procedure OpenDataSearchPage(SearchValue: Text)
    var
        DataSearch: Page "Data Search";
    begin
        DataSearch.SetSearchString(SearchValue);
        DataSearch.Run();
    end;
}