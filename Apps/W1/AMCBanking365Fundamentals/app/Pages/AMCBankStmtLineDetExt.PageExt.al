pageextension 20110 "AMC Bank Stmt Line Det. Ext" extends "Bank Statement Line Details"
{

    layout
    {
        modify(Name)
        {
            Visible = false;
        }

        addbefore(Value)
        {
            field(NameAMC; NameFldAMC)
            {
                Visible = true;
                Enabled = false;
                Caption = 'Name xPath';
                ToolTip = 'Specifies the name of a column in the imported bank file.';
                ApplicationArea = Basic, Suite;
            }
        }
    }

    var
        NameFldAMC: Text;

    trigger OnOpenPage()
    begin
        SetCurrentKey("Data Exch. No.", "Line No.", "Column No.", "Node ID");
    end;

    trigger OnAfterGetRecord()
    var
    begin
        NameFldAMC := GetFieldNameAMC();
    end;

    local procedure GetFieldNameAMC(): Text
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExch: Record "Data Exch.";
    begin
        DataExch.Get("Data Exch. No.");
        if DataExchColumnDef.Get(DataExch."Data Exch. Def Code", DataExch."Data Exch. Line Def Code", "Column No.") then
            exit(DataExchColumnDef.Name);

        if rec."Node ID" <> '' then
            exit(rec."Node ID");

        exit('');
    end;
}
