namespace Microsoft.Foundation.Address.IdealPostcodes;

using Microsoft.Sales.Customer;

pageextension 9411 "IPC Ship-to Address" extends "Ship-to Address"
{
    layout
    {
        modify(Address)
        {
            trigger OnBeforeValidate()
            begin
                IPCAddressLookupHelper.NotifyUserAboutAddressProviderCapabilities();
            end;
        }
        modify("Post Code")
        {
            trigger OnBeforeValidate()
            begin
                IPCAddressLookupHelper.NotifyUserAboutAddressProviderCapabilities();
            end;
        }
        modify("Country/Region Code")
        {
            trigger OnBeforeValidate()
            begin
                HandleAddressLookupVisibility();
            end;
        }
        addfirst(Control13)
        {
            group(Control1040006_IdealPostcodes)
            {
                ShowCaption = false;
                Visible = AddressLookupTextEnabled;
                field(LookupAddress_IdealPostcodes; LookupAddressLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        ShowPostcodeLookup(true);
                    end;
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(LookupPostcode)
            {
                ApplicationArea = All;
                Image = Find;
                Enabled = AddressLookupTextEnabled;
                Caption = 'Lookup Address';
                ToolTip = 'Search for address using postcode provider';

                trigger OnAction()
                begin
                    ShowPostcodeLookup(true);
                end;
            }
        }
    }

    var
        IPCAddressLookupHelper: Codeunit "IPC Address Lookup Helper";
        AddressLookupTextEnabled: Boolean;
        LookupAddressLbl: Label 'Lookup address from postcode';

    trigger OnAfterGetCurrRecord()
    begin
        HandleAddressLookupVisibility();
    end;

    local procedure HandleAddressLookupVisibility()
    begin
        AddressLookupTextEnabled := CurrPage.Editable() and IPCAddressLookupHelper.ConfiguredAndSupportedForRecord(Rec."Country/Region Code");
    end;

    local procedure ShowPostcodeLookup(UpdatePage: Boolean)
    var
        ShipToAddress: Record "Ship-to Address";
        RecRef: RecordRef;
    begin
        if not IPCAddressLookupHelper.ConfiguredAndSupportedForRecord(Rec."Country/Region Code") then
            exit;

        CurrPage.SaveRecord();
        ShipToAddress.Copy(Rec);
        RecRef.GetTable(ShipToAddress);
        IPCAddressLookupHelper.LookupAndUpdateAddress(RecRef, Rec.FieldNo(Address), Rec.FieldNo("Address 2"), Rec.FieldNo(City), Rec.FieldNo("Post Code"), Rec.FieldNo(County), Rec.FieldNo("Country/Region Code"));
        RecRef.SetTable(ShipToAddress);

        if UpdatePage then begin
            CurrPage.SetRecord(ShipToAddress);
            CurrPage.Update();
        end;
    end;
}