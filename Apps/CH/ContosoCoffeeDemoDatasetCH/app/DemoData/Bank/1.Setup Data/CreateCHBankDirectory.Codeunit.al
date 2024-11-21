codeunit 11635 "Create CH Bank Directory"
{
    trigger OnRun()
    var
        BankDirectory: Record "Bank Directory";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        NoOfRecsRead, NoOfRecsWritten : Integer;
    begin
        NavApp.GetResource('des_bcbankenstamm.txt', InStream, TextEncoding::Windows);

        OutStream := TempBlob.CreateOutStream(TextEncoding::Windows);
        CopyStream(OutStream, InStream);

        BankDirectory.ImportBankDirectoryFromTempBlob(TempBlob, NoOfRecsRead, NoOfRecsWritten);
    end;
}