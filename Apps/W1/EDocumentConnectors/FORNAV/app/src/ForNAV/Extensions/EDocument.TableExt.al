namespace ForNAV;

using Microsoft.EServices.EDocument;
tableextension 6412 "ForNAV EDocument" extends "E-Document"
{
    fields
    {
        field(6410; "ForNAV Edoc. ID"; Text[80]) // Needs to have same length as "ForNAV Incoming Doc".ID
        {
            Access = Internal;
            DataClassification = CustomerContent;
            Caption = 'ForNAV Edocument ID', Locked = true;
        }
    }
    internal procedure DocumentLog() Log: Record "E-Document Integration Log";
    begin
        Log.SetRange(Log."E-Doc. Entry No", Rec."Entry No");
        if Rec.Direction = Rec.Direction::Outgoing then begin
            Log.SetRange(Method, 'POST');
            Log.SetRange("Request URL", 'https://sendfilepostrequest/');
            if not Log.FindLast() then
                Clear(Log);
        end else begin
            Log.SetRange(Method, 'GET');
            Log.SetRange("Request URL", 'https://gettargetdocumentrequest/');
            if not Log.FindLast() then
                Clear(Log);
        end;
    end;
}