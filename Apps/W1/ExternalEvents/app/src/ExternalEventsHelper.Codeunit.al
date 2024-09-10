namespace Microsoft.Integration.ExternalEvents;

using System.Environment;

codeunit 38500 "External Events Helper"
{
    procedure CreateLink(url: Text; Id: Guid): Text[250]
    var
        Link: Text[250];
    begin
        Link := GetBaseUrl() + StrSubstNo(url, GetCompanyId(), TrimGuid(Id));
        exit(Link);
    end;

    procedure CreateLink(url: Text; Id1: Guid; Id2: Guid): Text[250]
    var
        Link: Text[250];
    begin
        Link := GetBaseUrl() + StrSubstNo(url, GetCompanyId(), TrimGuid(Id1), TrimGuid(Id2));
        exit(Link);
    end;

    local procedure GetBaseUrl(): Text
    begin
        exit(GetUrl(ClientType::Api));
    end;

    local procedure GetCompanyId(): Text
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        exit(TrimGuid(Company.SystemId));
    end;

    local procedure TrimGuid(Id: Guid): Text
    begin
        exit(DelChr(Format(Id), '<>', '{}'));
    end;
}