codeunit 139626 "E-Doc. Cue Card Test"
{
    Subtype = Test;
    TestPermissions = Disabled;


    var
        Assert: Codeunit Assert;
        IncorrectValueErr: Label 'Incorrect number of E-Document returned.';

    [Test]
    procedure TestWaitingPurchaseEDocCount()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Get E-Documents linked to purchase order or failed to process to purchase order. 

        EDocument.DeleteAll();
        EDocumentServiceStatus.DeleteAll();

        Assert.AreEqual(0, EDocumentProcessing.WaitingPurchaseEDocCount(), IncorrectValueErr);

        EDocument.Status := EDocument.Status::"In Progress";
        EDocument."Document Type" := "E-Document Type"::"Purchase Order";
        EDocument.Insert();

        EDocumentServiceStatus."E-Document Entry No" := EDocument."Entry No";
        EDocumentServiceStatus.Status := EDocumentServiceStatus.Status::Pending;
        EDocumentServiceStatus.Insert();

        Assert.AreEqual(1, EDocumentProcessing.WaitingPurchaseEDocCount(), IncorrectValueErr);

        EDocument."Entry No" := 0;
        EDocument.Status := EDocument.Status::"Error";
        EDocument."Document Type" := "E-Document Type"::"Purchase Order";
        EDocument.Insert();

        EDocumentServiceStatus."E-Document Entry No" := EDocument."Entry No";
        EDocumentServiceStatus.Status := EDocumentServiceStatus.Status::"Imported Document Processing Error";
        EDocumentServiceStatus.Insert();

        Assert.AreEqual(2, EDocumentProcessing.WaitingPurchaseEDocCount(), IncorrectValueErr);
    end;

}