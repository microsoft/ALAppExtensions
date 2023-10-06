namespace Microsoft.DataMigration.GP;

pageextension 41103 "GP Migration Configuration Ext" extends "GP Migration Configuration"
{
    layout
    {
        addafter(Classes)
        {
            group(Vendor1099)
            {
                Caption = 'Vendor 1099';
                InstructionalText = 'Choose whether Vendor 1099 information from GP should be migrated to Business Central.';

                field("Migrate Vendor 1099"; Rec."Migrate Vendor 1099")
                {
                    Caption = 'Migrate Vendor 1099';
                    ToolTip = 'Specify whether to Migrate Vendor 1099.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
                    begin
                        GPCompanyAdditionalSettings.SetFilter("Name", '<>%1', '');
                        if GPCompanyAdditionalSettings.FindSet() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Vendor 1099", Rec."Migrate Vendor 1099");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }

                field("1099 Tax Year"; Rec."1099 Tax Year")
                {
                    Caption = '1099 Tax Year';
                    ToolTip = 'Specify whether to 1099 Tax Year.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
                    begin
                        GPCompanyAdditionalSettings.SetFilter("Name", '<>%1', '');
                        if GPCompanyAdditionalSettings.FindSet() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("1099 Tax Year", Rec."1099 Tax Year");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."1099 Tax Year" = 0 then begin
            Rec.Validate("1099 Tax Year", Date2DMY(Today(), 3));
            Rec.Modify();
        end;
    end;
}