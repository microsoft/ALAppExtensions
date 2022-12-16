tableextension 40000 "Customer Ext." extends Customer
{
    fields
    {
        field(30000; "No. of Hist. Sales Trx."; Integer)
        {
            CalcFormula = Count("Hist. Sales Trx. Header" WHERE("Customer No." = FIELD("No.")));
            Caption = 'No. of GP Sales Transactions';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30001; "No. of Hist. Recv. Trx."; Integer)
        {
            CalcFormula = Count("Hist. Receivables Document" WHERE("Customer No." = FIELD("No.")));
            Caption = 'No. of GP Receivables Transactions';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}