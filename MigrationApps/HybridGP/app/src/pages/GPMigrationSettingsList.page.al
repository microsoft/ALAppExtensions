page 4021 "GP Migration Settings List"
{
    SourceTable = "GP Company Migration Settings";
    SourceTableView = where(Replicate = CONST(true));
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

                field("Name"; "Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Name of the company';
                    Width = 6;
                }
                field("Global Dimension 1"; "Global Dimension 1")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Global Dimension 1';
                    ToolTip = 'Global Dimension 1';
                    Width = 10;
                }
                field("Global Dimension 2"; "Global Dimension 2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Global Dimension 2';
                    ToolTip = 'Global Dimension 2';
                    Width = 10;
                }
                field("Migrate Inactive Customers"; "Migrate Inactive Customers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migrate Inactive Customers';
                    ToolTip = 'Specifies whether to migrate inactive customers.';
                    Width = 8;
                }
                field("Migrate Inactive Vendors"; "Migrate Inactive Vendors")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migrate Inactive Vendors';
                    ToolTip = 'Specifies whether to migrate inactive vendors.';
                    Width = 8;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        GPSegmentNames: Record "GP Segment Name";
    begin
        GPSegmentNames.SetFilter("Company Name", Name);
        if "Global Dimension 1" = '' then
            if GPSegmentNames.FindFirst() then
                "Global Dimension 1" := GPSegmentNames."Segment Name";
        if "Global Dimension 2" = '' then begin
            GPSegmentNames.SetFilter("Segment Name", '<> %1', "Global Dimension 1");
            if GPSegmentNames.FindFirst() then
                "Global Dimension 2" := GPSegmentNames."Segment Name";
        end;

        Modify();
    end;
}