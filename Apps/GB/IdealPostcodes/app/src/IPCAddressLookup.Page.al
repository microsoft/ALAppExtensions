namespace Microsoft.Foundation.Address.IdealPostcodes;

page 9402 "IPC Address Lookup"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "IPC Address Lookup";
    SourceTableTemporary = true;
    Caption = 'Select Address';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Addresses)
            {
                field("Display Text"; Rec."Display Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies address information';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies street address';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies city or town';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies post code';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Select)
            {
                ApplicationArea = All;
                Caption = 'Select';
                Tooltip = 'Select';
                Image = Approve;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    internal procedure SetRecords(var TempIPCAddressLookup: Record "IPC Address Lookup" temporary)
    begin
        if TempIPCAddressLookup.FindSet() then
            repeat
                Rec := TempIPCAddressLookup;
                Rec.Insert();
            until TempIPCAddressLookup.Next() = 0;
    end;

    internal procedure GetSelectedAddress(var SelectedAddress: Record "IPC Address Lookup")
    begin
        SelectedAddress := Rec;
    end;
}