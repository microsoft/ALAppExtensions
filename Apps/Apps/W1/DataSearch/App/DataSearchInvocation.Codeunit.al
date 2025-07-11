namespace Microsoft.Foundation.DataSearch;

using System.Environment;

codeunit 2684 "Data Search Invocation"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'GetDataSearchSetup', '', true, true)]
    local procedure GetDataSearchSetup(var SetupInfo: JsonArray)
    var
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
    begin
        DataSearchObjectMapping.GetDataSearchSetup(SetupInfo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'GetDisplayPageId', '', true, true)]
    local procedure GetDisplayPageId(TableNo: Integer; SystemId: Guid; var DisplayPageId: Integer; var DisplayTableNo: Integer; var DisplaySystemId: Guid)
    var
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
    begin
        DataSearchObjectMapping.GetDisplayPageId(TableNo, SystemId, DisplayPageId, DisplayTableNo, DisplaySystemId);
    end;
}