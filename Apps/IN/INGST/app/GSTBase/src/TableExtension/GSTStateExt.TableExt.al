tableextension 18013 "GST State Ext." extends State
{
    fields
    {
        field(18000; "State Code (GST Reg. No.)"; code[10])
        {
            Caption = 'State Code (GST Reg. No.)';
            DataClassification = CustomerContent;
            Numeric = true;
        }
    }
}