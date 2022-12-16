tableextension 40001 "Vendor Ext." extends Vendor
{
    fields
    {
        field(30000; "No. of Hist. Payables Trx."; Integer)
        {
            CalcFormula = Count("Hist. Payables Document" WHERE("Vendor No." = FIELD("No.")));
            Caption = 'No. of GP Payables Transactions';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30001; "No. of Hist. Receivings Trx."; Integer)
        {
            CalcFormula = Count("Hist. Purchase Recv. Header" WHERE("Vendor No." = FIELD("No.")));
            Caption = 'No. of GP Receivings Transactions';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}