namespace Microsoft.DataMigration.GP;

pageextension 41104 "GP Company Mig. Settings Ext" extends "GP Company Migration Settings"
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