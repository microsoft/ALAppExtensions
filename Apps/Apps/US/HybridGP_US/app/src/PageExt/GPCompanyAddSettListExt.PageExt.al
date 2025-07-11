namespace Microsoft.DataMigration.GP;

pageextension 41102 "GP Company Add. Sett. List Ext" extends "GP Company Add. Settings List"
{
    layout
    {
        addlast(General)
        {
            field("Migrate Vendor 1099"; Rec."Migrate Vendor 1099")
            {
                Caption = 'Migrate Vendor 1099';
                ToolTip = 'Specify whether to Migrate Vendor 1099 data.';
                ApplicationArea = All;
            }

            field("1099 Tax Year"; Rec."1099 Tax Year")
            {
                Caption = '1099 Tax Year';
                ToolTip = 'Specify the 1099 tax year to migrate.';
                ApplicationArea = All;
            }
        }
    }
}