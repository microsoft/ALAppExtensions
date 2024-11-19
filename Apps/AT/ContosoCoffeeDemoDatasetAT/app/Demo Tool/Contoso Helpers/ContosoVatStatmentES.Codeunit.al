codeunit 11146 "Contoso Vat Statment ES"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Statement Name" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertVATStatementName(TemplateName: Code[10]; StatementName: Code[10]; StatementDesc: Text[100])
    var
        VATStatementName: Record "VAT Statement Name";
        Exists: Boolean;
    begin
        if VATStatementName.Get(TemplateName, StatementName) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATStatementName.Validate("Statement Template Name", TemplateName);
        VATStatementName.Validate(Name, StatementName);
        VATStatementName.Validate(Description, StatementDesc);

        if Exists then
            VATStatementName.Modify(true)
        else
            VATStatementName.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}