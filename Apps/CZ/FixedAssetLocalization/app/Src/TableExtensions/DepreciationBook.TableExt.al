tableextension 31246 "Depreciation Book CZF" extends "Depreciation Book"
{
    fields
    {
        field(31241; "Check Acq. Appr. bef. Dep. CZF"; Boolean)
        {
            Caption = 'Check Acqusition and Appreciation before Depreciation';
            DataClassification = CustomerContent;
        }
        field(31242; "All Acquisit. in same Year CZF"; Boolean)
        {
            Caption = 'All Acquisition in same Year';
            DataClassification = CustomerContent;
        }
        field(31243; "Check Deprec. on Disposal CZF"; Boolean)
        {
            Caption = 'Check Depreciation on Disposal';
            DataClassification = CustomerContent;
        }
        field(310244; "Deprec. from 1st Year Day CZF"; Boolean)
        {
            Caption = 'Depreciation from 1st Year Day';
            DataClassification = CustomerContent;
        }
        field(31245; "Deprec. from 1st Month Day CZF"; Boolean)
        {
            Caption = 'Depreciation from 1st Month Day';
            DataClassification = CustomerContent;
        }
        field(31250; "Corresp. G/L Entries Disp. CZF"; Boolean)
        {
            Caption = 'Corresp. G/L Entries on Disposal';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Corresp. G/L Entries Disp. CZF" then
                    TestField("Disposal Calculation Method", "Disposal Calculation Method"::Gross)
                else
                    TestField("Corresp. FA Entries Disp. CZF", false);
            end;
        }
        field(31251; "Corresp. FA Entries Disp. CZF"; Boolean)
        {
            Caption = 'Corresp. FA Entries on Disposal';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Corresp. FA Entries Disp. CZF" then
                    TestField("Corresp. G/L Entries Disp. CZF", true);
            end;
        }
    }
}
