tableextension 10678 "SAF-T Analysis" extends Dimension
{
    fields
    {
        field(10670; "SAF-T Analysis Type"; Code[9])
        {
            DataClassification = CustomerContent;
            Caption = 'SAF-T Analysis Type';
        }
        field(10671; "Export to SAF-T"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Export to SAF-T';
            InitValue = true;
        }
    }

    procedure UpdateSAFTAnalysisTypeFromNoSeries()
    var
        SAFTSetup: Record "SAF-T Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if not SAFTSetup.Get() then
            exit;
        if SAFTSetup."Dimension No. Series Code" = '' then
            exit;
        "SAF-T Analysis Type" :=
            copystr(NoSeriesManagement.GetNextNo(SAFTSetup."Dimension No. Series Code", WorkDate(), TRUE), 1, MaxStrLen("SAF-T Analysis Type"));
    end;

}