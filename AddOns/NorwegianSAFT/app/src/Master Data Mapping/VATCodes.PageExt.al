pageextension 10676 "SAF-T VAT Code" extends "VAT Codes"
{
    layout
    {
        addlast(Control1080000)
        {
            field(Compensation; Compensation)
            {
                Caption = 'Compensation';
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies if the tax code is used for compensation.';
            }
        }
    }
}
