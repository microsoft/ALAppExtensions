namespace Microsoft.Finance.VAT.Reporting;

table 13606 "Elec. VAT Decl. Communication"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Transaction ID"; Code[100])
        {

        }
        field(3; "Request Type"; Enum "Elec. VAT Decl. Request Type")
        {

        }
        field(4; "Related VAT Return No."; Code[20])
        {

        }
        field(5; TimeSent; DateTime)
        {

        }
        field(6; "Response Transaction ID"; Code[100])
        {

        }
        field(7; "SKAT Response BLOB"; Blob)
        {

        }
        field(8; "SKAT Request BLOB"; Blob)
        {

        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    internal procedure GetTransactionIDForVATReturn(VATReturnNo: Code[20]) TransactionID: Code[100]
    begin
        Rec.SetRange("Related VAT Return No.", VATReturnNo);
        Rec.SetRange("Request Type", "Elec. VAT Decl. Request Type"::"Submit VAT Return");
        if Rec.FindLast() then
            TransactionID := Rec."Transaction ID";
    end;

    internal procedure SaveRequestToFile()
    var
        InStream: InStream;
        FileName: Text;
    begin
        Rec.CalcFields("SKAT Request BLOB");
        Rec."SKAT Request BLOB".CreateInStream(InStream);
        FileName := Format(Rec."No.") + '_request.xml';
        DownloadFromStream(InStream, Format(Rec."No.") + '_request.xml', '', '*.xml', FileName);
    end;

    internal procedure SaveResponseToFile()
    var
        InStream: InStream;
        FileName: Text;
    begin
        Rec.CalcFields("SKAT Response BLOB");
        Rec."SKAT Response BLOB".CreateInStream(InStream);
        FileName := Format(Rec."No.") + '_response.xml';
        DownloadFromStream(InStream, Format(Rec."No.") + '_response.xml', '', '*.xml', FileName);
    end;
}
