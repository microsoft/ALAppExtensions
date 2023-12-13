codeunit 139626 "Test Import E-Document Format" implements "E-Document"
{
    procedure Check(var SourceDocumentHeader: RecordRef; EDocService: Record "E-Document Service"; EDocumentProcessingPhase: enum "E-Document Processing Phase");
    begin
    end;

    procedure Create(EDocumentFormat: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
    end;

    procedure CreateBatch(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin
    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        CompanyInformation: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
    begin
        CompanyInformation.Get();
        GLSetup.Get();

        PurchDocTestBuffer.GetTempVariables(TmpPurchHeader, TmpPurchLine);
        if TmpPurchHeader.FindFirst() then begin
            if EDocument."Index In Batch" <> 0 then
                TmpPurchHeader.Next(EDocument."Index In Batch" - 1);

            case TmpPurchHeader."Document Type" of
                TmpPurchHeader."Document Type"::Invoice:
                    begin
                        EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
                        EDocument."Incoming E-Document No." := TmpPurchHeader."Vendor Invoice No.";
                    end;
                TmpPurchHeader."Document Type"::"Credit Memo":
                    begin
                        EDocument."Document Type" := EDocument."Document Type"::"Purchase Credit Memo";
                        EDocument."Incoming E-Document No." := TmpPurchHeader."Vendor Cr. Memo No.";
                    end;
            end;

            EDocument."Bill-to/Pay-to No." := TmpPurchHeader."Pay-to Vendor No.";
            EDocument."Bill-to/Pay-to Name" := TmpPurchHeader."Pay-to Name";
            EDocument."Document Date" := TmpPurchHeader."Document Date";
            EDocument."Due Date" := TmpPurchHeader."Due Date";
            EDocument."Receiving Company VAT Reg. No." := CompanyInformation."VAT Registration No.";
            EDocument."Receiving Company GLN" := CompanyInformation.GLN;
            EDocument."Receiving Company Name" := CompanyInformation.Name;
            EDocument."Receiving Company Address" := CompanyInformation.Address;
            EDocument."Currency Code" := GLSetup."LCY Code";
            TmpPurchHeader.CalcFields(Amount, "Amount Including VAT");
            EDocument."Amount Excl. VAT" := TmpPurchHeader.Amount;
            EDocument."Amount Incl. VAT" := TmpPurchHeader."Amount Including VAT";
        end;
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        TmpPurchHeader2: Record "Purchase Header" temporary;
        TmpPurchLine2: Record "Purchase Line" temporary;
    begin
        PurchDocTestBuffer.GetTempVariables(TmpPurchHeader, TmpPurchLine);
        if TmpPurchHeader.FindFirst() then begin
            if EDocument."Index In Batch" <> 0 then
                TmpPurchHeader.Next(EDocument."Index In Batch" - 1);

            TmpPurchHeader2.Init();
            TmpPurchHeader2.TransferFields(TmpPurchHeader);
            TmpPurchHeader2."Vendor Invoice No." := TmpPurchHeader."No.";
            TmpPurchHeader2.Insert();

            TmpPurchLine.SetRange("Document Type", TmpPurchHeader."Document Type");
            TmpPurchLine.SetRange("Document No.", TmpPurchHeader."No.");
            if TmpPurchLine.FindSet() then
                repeat
                    TmpPurchLine2.Init();
                    TmpPurchLine2.TransferFields(TmpPurchLine);
                    TmpPurchLine2.Insert();
                until TmpPurchLine.Next() = 0;
        end;

        CreatedDocumentHeader.GetTable(TmpPurchHeader2);
        CreatedDocumentLines.GetTable(TmpPurchLine2);
    end;

    var
        TmpPurchHeader: Record "Purchase Header" temporary;
        TmpPurchLine: Record "Purchase Line" temporary;
        PurchDocTestBuffer: Codeunit "Purch. Doc. Test Buffer";
}