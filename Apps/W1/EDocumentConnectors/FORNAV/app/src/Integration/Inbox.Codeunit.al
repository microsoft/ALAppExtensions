namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.EServices.EDocument;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;

codeunit 6417 "ForNAV Inbox"
{
    Access = Internal;

    internal procedure GetEvidence(EDocument: Record "E-Document"; SendContext: Codeunit SendContext): Boolean
    var
        Incoming: Record "ForNAV Incoming E-Document";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        Error: BigText;
        InStr: InStream;
    begin
        Incoming.SetRange(DocType, Incoming.DocType::Evidence);
        Incoming.SetRange(Incoming.ID, EDocument."ForNAV Edoc. ID");
        if Incoming.FindFirst() then begin
            if Incoming.Status = Incoming.Status::Send then
                exit(true);

            Incoming.CalcFields(Message);
            Incoming.Message.CreateInStream(InStr, TextEncoding::UTF8);
            Error.Read(InStr);
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, Format(Error));
        end;
        exit(false);
    end;

    internal procedure DeleteDocs(var DocumentIds: JsonArray; SendContext: Codeunit SendContext): Boolean
    var
        Incoming: Record "ForNAV Incoming E-Document";
        DocumentId: JsonToken;
    begin
        foreach DocumentId in DocumentIds do begin
            Incoming.SetRange(ID, DocumentId.AsValue().AsText());
            Incoming.SetFilter(Status, '%1|%2|%3', Incoming.Status::Received, Incoming.Status::Approved, Incoming.Status::Rejected);
            if Incoming.FindSet() then
                repeat
                    Incoming.Status := Incoming.Status::Processed;
                    Incoming.Modify();
                until Incoming.Next() <> 1;
        end;

        exit(true);
    end;

    local procedure GetIncomingDocs(var Incoming: Record "ForNAV Incoming E-Document"; DocumentsMetadata: Codeunit "Temp Blob List"): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        Incoming.SetFilter(Status, '%1|%2|%3', Incoming.Status::Received, Incoming.Status::Approved, Incoming.Status::Rejected);
        if not Incoming.FindSet() then
            exit(false);

        repeat
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(Incoming.ID);
            DocumentsMetadata.Add(TempBlob);
        until Incoming.Next() = 0;
        exit(true);
    end;

    internal procedure GetIncomingBussinessDocs(DocumentsMetadata: Codeunit "Temp Blob List"): Boolean
    var
        Incoming: Record "ForNAV Incoming E-Document";
    begin
        Incoming.SetFilter(Incoming.DocType, '%1|%2', Incoming.DocType::CreditNote, Incoming.DocType::Invoice);
        exit(GetIncomingDocs(Incoming, DocumentsMetadata));
    end;

    internal procedure GetIncomingAppResponseDocs(EDocument: Record "E-Document"; DocumentsMetadata: Codeunit "Temp Blob List"): Boolean
    var
        Incoming: Record "ForNAV Incoming E-Document";
    begin
        Incoming.SetRange(Incoming.DocType, Incoming.DocType::ApplicationResponse);
        exit(GetIncomingDocs(Incoming, DocumentsMetadata));
    end;

    internal procedure GetIncomingDoc(DocumentId: Text; ReceiveContext: Codeunit ReceiveContext): Boolean
    var
        Incoming: Record "ForNAV Incoming E-Document";
        output: Text;
    begin
        Incoming.SetRange(Incoming.ID, DocumentId);
        if Incoming.FindFirst() then begin
            output := Incoming.GetDoc();
            ReceiveContext.Http().GetHttpResponseMessage().Content.WriteFrom(output);
        end;

        exit(ReceiveContext.Http().GetHttpResponseMessage().IsSuccessStatusCode);
    end;

    internal procedure GetApprovalStatus(EDocument: Record "E-Document"; var StatusDescription: Text) Status: Enum "ForNAV Incoming E-Doc Status"
    var
        Incoming: Record "ForNAV Incoming E-Document";
    begin
        Incoming.SetRange(DocType, Incoming.DocType::ApplicationResponse);
        Incoming.SetRange(Incoming.ID, EDocument."ForNAV Edoc. ID");

        if Incoming.FindFirst() then begin
            Status := Incoming.Status;
            StatusDescription := Incoming.GetComment();
        end;
    end;

    local procedure GetOptionValue(Fref: FieldRef; StringValue: Text): Integer
    var
        Index: Integer;
    begin
        for Index := 1 to Fref.EnumValueCount() do
            if Fref.GetEnumValueName(Index) = StringValue then
                exit(Fref.GetEnumValueOrdinal(Index))
    end;

    local procedure InsertDocFromJson(RecRef: RecordRef; JsonRec: JsonObject)
    var
        TempBlob: Codeunit "Temp Blob";
        BT: BigText;
        Fref: FieldRef;
        i: Integer;
        JToken: JsonToken;
        JValue: JsonValue;
        OutStr: OutStream;
    begin
        for i := 1 to RecRef.FieldCount do begin
            Fref := RecRef.Field(i);
            if JsonRec.Get(Fref.Name, JToken) then begin
                JValue := JToken.AsValue();
                if not JValue.IsNull then
                    case Fref.Type of
                        FieldType::Integer:
                            Fref.Value := JValue.AsInteger();
                        FieldType::Text:
                            Fref.Value := JValue.AsText();
                        FieldType::Option:
                            Fref.Value := GetOptionValue(Fref, JValue.AsText());
                        FieldType::Blob:
                            begin
                                Clear(BT);
                                BT.AddText(JValue.AsText());
                                TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                                BT.Write(OutStr);
                                TempBlob.ToFieldRef(Fref);
                            end;
                    end;
            end;
        end;

        RecRef.SetRecFilter();
        if not RecRef.FindFirst() then
            RecRef.Insert();
    end;

    internal procedure GetDocsFromJson(var RecKeys: JsonArray; JsonRecs: JsonObject) More: Boolean
    var
        RecRef: RecordRef;
        DocId: Text;
        JToken: JsonToken;
    begin
        RecRef.Open(Database::"ForNAV Incoming E-Document");
        foreach DocId in JsonRecs.Keys do
            if DocId = 'Next' then
                More := true
            else begin
                JsonRecs.Get(DocId, JToken);
                RecKeys.Add(DocId);
                InsertDocFromJson(RecRef, JToken.AsObject());
            end;
    end;
}
