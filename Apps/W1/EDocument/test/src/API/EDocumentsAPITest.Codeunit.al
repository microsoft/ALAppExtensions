codeunit 139501 "E-Documents API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var

        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        EDocumentsServiceNameTok: Label 'eDocuments', Locked = true;


    [Test]
    procedure TestEDocumentsAPI()
    var
        TargetUrl: Text;
        ResponseText: Text;
    begin
        TargetUrl := LibraryGraphMgt.CreateTargetURL('', Page::"E-Documents API", EDocumentsServiceNameTok);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetUrl);
        Error('Response: %1', ResponseText);
    end;
}
