pageextension 20103 "AMC Bank Bank Account Page Ext" extends "Bank Account Card"
{
    ContextSensitiveHelpPage = '304';

    layout
    {
        addAfter("Creditor No.")
        {
            field("Bank Name format"; "AMC Bank Name")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'Specifies your bank''s data format as required by the AMC Banking when you import and export bank files.';
            }
        }
    }

}