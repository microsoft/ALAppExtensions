codeunit 5424 "Create E-Doc DemoData Service"
{
    Access = Internal;

    trigger OnRun()
    begin
        CreateEDocService();
    end;

    local procedure CreateEDocService()
    var
        EDocumentService: Record "E-Document Service";
    begin
        EDocumentService.Init();
        EDocumentService.Code := CopyStr(EDocumentServiceCode(), 1, MaxStrLen(EDocumentService.Code));
        EDocumentService."Import Process" := EDocumentService."Import Process"::"Version 2.0";
        EDocumentService."Automatic Import Processing" := "E-Doc. Automatic Processing"::No;
        EDocumentService.Insert(true);
    end;

    procedure EDocumentServiceCode(): Code[20]
    begin
        exit('E-DOC DEMO DATA');
    end;
}