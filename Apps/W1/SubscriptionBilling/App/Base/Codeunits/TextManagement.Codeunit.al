namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using System.Reflection;

codeunit 8021 "Text Management"
{
    Access = Internal;

    var
        ProcessingAbortedErr: Label 'Processing aborted.';

    procedure GetProcessingAbortedErr(): Text
    begin
        exit(ProcessingAbortedErr);
    end;

    procedure AppendText(var ExistingText: Text; NewText: Text; Separator: Text)
    begin
        if NewText = '' then
            exit;

        if ExistingText = '' then
            ExistingText := CopyStr(NewText, 1, MaxStrLen(ExistingText))
        else
            ExistingText += CopyStr(Separator + NewText, 1, MaxStrLen(ExistingText) - StrLen(ExistingText));
    end;

    procedure ReplaceInvalidFilterChar(var BaseText: Text)
    begin
        BaseText := ConvertStr(BaseText, '()', '??');
        BaseText := ConvertStr(BaseText, '<>', '??');
    end;

    procedure ShowFieldText(var RRef: RecordRef; FieldNo: Integer)
    var
        FRef: FieldRef;
        BlobText: Text;
        PageCaption: Text;
    begin
        PageCaption := RRef.Caption();
        FRef := RRef.Field(FieldNo);
        BlobText := ReadBlobText(RRef, FieldNo);

        ShowTextViewer(BlobText, PageCaption);
    end;

    local procedure ShowTextViewer(var Content: Text; PageCaption: Text): Boolean
    var
        TextEditor: Page "Text Viewer";
    begin
        TextEditor.SetPageCaption(PageCaption);
        TextEditor.SetReadOnly(true);
        TextEditor.SetContent(Content);
        TextEditor.SetSize(100, 100);
        TextEditor.SetAutoResize(true);
    end;

    procedure ReadBlobText(RecRef: RecordRef; FieldNo: Integer): Text
    var
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        TempBlob.FromRecordRef(RecRef, FieldNo);
        if not TempBlob.HasValue() then
            exit;
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    procedure WriteBlobText(var RRef: RecordRef; FieldNo: Integer; BlobText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(BlobText);
        TempBlob.ToRecordRef(RRef, FieldNo);
    end;
}