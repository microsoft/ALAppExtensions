#pragma warning disable AA0247
codeunit 5255 "Create Sust Item Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertItemCategory(ESG(), ESGBatchDescriptionLbl, '');
    end;

    var
        ESGTok: Label 'ESG', MaxLength = 20;
        ESGBatchDescriptionLbl: Label 'Environmental, Social, and Governance', MaxLength = 100;

    procedure ESG(): Code[20]
    begin
        exit(ESGTok);
    end;
}
