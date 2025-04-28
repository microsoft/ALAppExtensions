#pragma warning disable AA0247
codeunit 6150 "E-Doc. Get Basic Info"
{
    Access = Internal;
    trigger OnRun()
    begin
        EDocumentInterface.GetBasicInfoFromReceivedDocument(EDocument, TempBlob);
    end;

    procedure SetValues(var EDocumentInterface2: Interface "E-Document"; var EDocument2: Record "E-Document"; var TempBlob2: Codeunit "Temp Blob")
    begin
        EDocumentInterface := EDocumentInterface2;
        EDocument.Copy(EDocument2);
        TempBlob := TempBlob2;
    end;

    procedure GetValues(var EDocumentInterface2: Interface "E-Document"; var EDocument2: Record "E-Document"; var TempBlob2: Codeunit "Temp Blob")
    begin
        EDocumentInterface2 := EDocumentInterface;
        EDocument2.Copy(EDocument);
        TempBlob2 := TempBlob;
    end;

    var
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        EDocumentInterface: Interface "E-Document";
}
