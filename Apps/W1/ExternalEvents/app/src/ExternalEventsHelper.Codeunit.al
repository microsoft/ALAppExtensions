Codeunit 38500 "External Events Helper"
{
    procedure CreateLink(url: Text; Id: Guid): Text[250]
    var
        Link: Text[250];
    begin
        Link := GetBaseUrl() + StrSubstNo(url, GetCompanyId(), TrimGuid(Id));
        Exit(Link);
    end;

    local procedure GetBaseUrl(): text
    begin
        exit(GetUrl(CLIENTTYPE::Api));
    end;

    Local procedure GetCompanyId(): text
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        exit(TrimGuid(Company.SystemId));
    end;

    Local procedure TrimGuid(Id: Guid): Text
    begin
        exit(DelChr(Format(Id), '<>', '{}'));
    end;
}