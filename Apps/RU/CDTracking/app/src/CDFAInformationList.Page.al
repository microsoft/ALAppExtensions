#pragma warning disable AA0247
page 14102 "CD FA Information List"
{
    ApplicationArea = FixedAssets;
    Caption = 'CD FA Information List';
    Editable = false;
    PageType = List;
    SourceTable = "CD FA Information";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("FA No."; Rec."FA No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Visible = false;
                }
                field("CD No."; Rec."CD No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the customs declaration number.';
                }
                field("CD Header Number"; Rec."CD Header Number")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the number of the customs declaration. ';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field("Temporary CD No."; Rec."Temporary CD No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the temporary customs declaration number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FixedAssets;
                    Editable = true;
                    ToolTip = 'Specifies the description associated with this line.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;

    procedure SetSelection(var CDFAInformation: Record "CD FA Information")
    begin
        CurrPage.SetSelectionFilter(CDFAInformation);
    end;

    procedure GetSelectionFilter(): Text
    var
        CDFAInformation: Record "CD FA Information";
    begin
        CurrPage.SetSelectionFilter(CDFAInformation);
        exit(GetSelectionFilterForCDFAInformation(CDFAInformation));
    end;

    local procedure GetSelectionFilterForCDFAInformation(var CDFAInformation: Record "CD FA Information"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        TableRecordRef: RecordRef;
    begin
        TableRecordRef.GetTable(CDFAInformation);
        exit(SelectionFilterManagement.GetSelectionFilter(TableRecordRef, CDFAInformation.FieldNo("CD No.")));
    end;
}

