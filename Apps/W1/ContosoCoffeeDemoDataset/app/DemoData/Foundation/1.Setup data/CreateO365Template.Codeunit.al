codeunit 5234 "Create O365 Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        O365HTMLTemplate: Record "O365 HTML Template";
        MediaResourcesMgt: Codeunit "Media Resources Mgt.";
        TemplateInStream: InStream;
        FolderPathTok: Label 'HTMLTemplates', Locked = true;
    begin
        if O365HTMLTemplate.Get(SalesMail()) then
            exit;

        NavApp.GetResource(FolderPathTok + '/' + InvoicingSalesMailTok, TemplateInStream);

        MediaResourcesMgt.InsertMediaFromInstream(InvoicingSalesMailTok, TemplateInStream);

        O365HTMLTemplate.Validate(Code, SalesMail());
        O365HTMLTemplate.Validate(Description, SalesMailDescLbl);
        O365HTMLTemplate.Validate("Media Resources Ref", InvoicingSalesMailTok);
        O365HTMLTemplate.Insert(true);
    end;

    procedure SalesMail(): Code[20]
    begin
        exit(SalesMailTok);
    end;

    var
        SalesMailTok: Label 'SALESEMAIL', Locked = true;
        SalesMailDescLbl: Label 'Invoicing sales mail', MaxLength = 100;
        InvoicingSalesMailTok: Label 'Invoicing - SalesMail.html', Locked = true;
}