pageextension 4810 "Intrastat Report ErrMsg. Part" extends "Error Messages Part"
{
    procedure SetContextRecordID(recordID: RecordID)
    var
        ErrorMessage: Record "Error Message";
        TempErrorMessage: Record "Error Message" temporary;
    begin
        ErrorMessage.SetRange("Context Record ID", recordID);
        ErrorMessage.CopyToTemp(TempErrorMessage);
        SetRecords(TempErrorMessage);
        CurrPage.Update();
    end;
}