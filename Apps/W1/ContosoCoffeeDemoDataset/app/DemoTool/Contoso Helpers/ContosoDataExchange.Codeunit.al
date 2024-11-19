codeunit 5308 "Contoso Data Exchange"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure ImportDataExchangeDefinition(FileName: Text)
    var
        InStream: InStream;
    begin
        NavApp.GetResource(FileName, InStream);

        XMLPORT.Import(XMLPORT::"Imp / Exp Data Exch Def & Map", InStream)
    end;

    procedure InsertDataExchangeType(Code: Code[20]; Description: Text[250]; DataExchangeDefinitionCode: Code[20])
    var
        DataExchangeType: Record "Data Exchange Type";
    begin
        DataExchangeType.Validate(Code, Code);
        DataExchangeType.Validate(Description, Description);
        DataExchangeType.Validate("Data Exch. Def. Code", DataExchangeDefinitionCode);
        if DataExchangeType.Insert(false) then;
    end;
}