namespace Microsoft.DataMigration.GP;

page 4021 "GP Migration Settings List"
{
    SourceTable = "GP Company Migration Settings";
    SourceTableView = where(Replicate = const(true));
    PageType = ListPart;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Caption = 'Select company settings for data migration';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Companies)
            {
                ShowCaption = false;

                field("Name"; Rec."Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Name of the company';
                    Width = 6;
                }

#if not CLEAN22
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Global Dimension 1';
                    ToolTip = 'Global Dimension 1';
                    Width = 10;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Global Dimension 2';
                    ToolTip = 'Global Dimension 2';
                    Width = 10;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';
                }
                field("Migrate Inactive Customers"; Rec."Migrate Inactive Customers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migrate Inactive Customers';
                    ToolTip = 'Specifies whether to migrate inactive customers.';
                    Width = 8;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';
                }
                field("Migrate Inactive Vendors"; Rec."Migrate Inactive Vendors")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migrate Inactive Vendors';
                    ToolTip = 'Specifies whether to migrate inactive vendors.';
                    Width = 8;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';
                }
                field("Migrate Inactive Checkbooks"; MigrateInactiveCheckbooks)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migrate Inactive Checkbooks';
                    ToolTip = 'Specifies whether to migrate inactive checkbooks.';
                    Width = 8;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';

                    trigger OnValidate()
                    var
                        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
                    begin
                        if not GPCompanyAdditionalSettings.Get(Rec.Name) then begin
                            GPCompanyAdditionalSettings.Name := Rec.Name;
                            GPCompanyAdditionalSettings."Migrate Inactive Checkbooks" := MigrateInactiveCheckbooks;
                            GPCompanyAdditionalSettings.Insert();
                        end else begin
                            GPCompanyAdditionalSettings."Migrate Inactive Checkbooks" := MigrateInactiveCheckbooks;
                            GPCompanyAdditionalSettings.Modify();
                        end;
                    end;
                }
                field("Migrate Vendor Classes"; MigrateVendorClasses)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migrate Vendor Classes';
                    ToolTip = 'Specifies whether to migrate Vendor Classes.';
                    Width = 8;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';

                    trigger OnValidate()
                    var
                        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
                    begin
                        if not GPCompanyAdditionalSettings.Get(Rec.Name) then begin
                            GPCompanyAdditionalSettings.Name := Rec.Name;
                            GPCompanyAdditionalSettings."Migrate Vendor Classes" := MigrateVendorClasses;
                            GPCompanyAdditionalSettings.Insert();
                        end else begin
                            GPCompanyAdditionalSettings."Migrate Vendor Classes" := MigrateVendorClasses;
                            GPCompanyAdditionalSettings.Modify();
                        end;
                    end;
                }
                field("Migrate Customer Classes"; MigrateCustomerClasses)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migrate Customer Classes';
                    ToolTip = 'Specifies whether to migrate Customer Classes.';
                    Width = 8;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';

                    trigger OnValidate()
                    var
                        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
                    begin
                        if not GPCompanyAdditionalSettings.Get(Rec.Name) then begin
                            GPCompanyAdditionalSettings.Name := Rec.Name;
                            GPCompanyAdditionalSettings."Migrate Customer Classes" := MigrateCustomerClasses;
                            GPCompanyAdditionalSettings.Insert();
                        end else begin
                            GPCompanyAdditionalSettings."Migrate Customer Classes" := MigrateCustomerClasses;
                            GPCompanyAdditionalSettings.Modify();
                        end;
                    end;
                }

                field("Migrate Item Classes"; MigrateItemClasses)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migrate Item Classes';
                    ToolTip = 'Specifies whether to migrate Item Classes.';
                    Width = 8;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';

                    trigger OnValidate()
                    var
                        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
                    begin
                        if not GPCompanyAdditionalSettings.Get(Rec.Name) then begin
                            GPCompanyAdditionalSettings.Name := Rec.Name;
                            GPCompanyAdditionalSettings."Migrate Item Classes" := MigrateItemClasses;
                            GPCompanyAdditionalSettings.Insert();
                        end else begin
                            GPCompanyAdditionalSettings."Migrate Item Classes" := MigrateItemClasses;
                            GPCompanyAdditionalSettings.Modify();
                        end;
                    end;
                }
                field("Oldest GL Historical Year to Migrate"; InitialYear)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Initial Historical Year';
                    ToolTip = 'Specifies which Historical year to start with.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    Width = 8;
                    ObsoleteTag = '22.0';

                    trigger OnValidate()
                    var
                        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
                    begin
                        if not GPCompanyAdditionalSettings.Get(Rec.Name) then begin
                            GPCompanyAdditionalSettings.Name := Rec.Name;
                            GPCompanyAdditionalSettings."Oldest GL Year to Migrate" := InitialYear;
                            GPCompanyAdditionalSettings.Insert();
                        end else begin
                            GPCompanyAdditionalSettings."Oldest GL Year to Migrate" := InitialYear;
                            GPCompanyAdditionalSettings.Modify();
                        end;
                    end;
                }
#endif
            }
        }
    }


#if not CLEAN22
    trigger OnAfterGetRecord()
    var
        GPSegmentNames: Record "GP Segment Name";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        GPSegmentNames.SetFilter("Company Name", Rec.Name);
        if Rec."Global Dimension 1" = '' then
            if GPSegmentNames.FindFirst() then
                Rec."Global Dimension 1" := GPSegmentNames."Segment Name";
        if Rec."Global Dimension 2" = '' then begin
            GPSegmentNames.SetFilter("Segment Name", '<> %1', Rec."Global Dimension 1");
            if GPSegmentNames.FindFirst() then
                Rec."Global Dimension 2" := GPSegmentNames."Segment Name";
        end;

        Rec.Modify();

        MigrateInactiveCheckbooks := true;

        if GPCompanyAdditionalSettings.Get(CompanyName()) then begin
            MigrateInactiveCheckbooks := GPCompanyAdditionalSettings."Migrate Inactive Checkbooks";
            MigrateVendorClasses := GPCompanyAdditionalSettings."Migrate Vendor Classes";
            MigrateCustomerClasses := GPCompanyAdditionalSettings."Migrate Customer Classes";
            MigrateItemClasses := GPCompanyAdditionalSettings."Migrate Item Classes";
            InitialYear := GPCompanyAdditionalSettings."Oldest GL Year to Migrate";
        end;
    end;

    var
        MigrateInactiveCheckbooks: Boolean;
        MigrateVendorClasses: Boolean;
        MigrateCustomerClasses: Boolean;
        MigrateItemClasses: Boolean;
        InitialYear: Integer;
#endif
}