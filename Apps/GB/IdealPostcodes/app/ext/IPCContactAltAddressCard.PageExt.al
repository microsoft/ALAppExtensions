namespace Microsoft.Foundation.Address.IdealPostcodes;

using Microsoft.CRM.Contact;

pageextension 9404 "IPC Contact Alt. Address Card" extends "Contact Alt. Address Card"
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
        addfirst(General)
        {
            group(General_IdealPostCodes)
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
        moveafter("Address 2"; "Post Code", City)
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
        ContactAltAddress: Record "Contact Alt. Address";
        RecRef: RecordRef;
    begin
        if not IPCAddressLookupHelper.ConfiguredAndSupportedForRecord(Rec."Country/Region Code") then
            exit;

        CurrPage.SaveRecord();
        ContactAltAddress.Copy(Rec);
        RecRef.GetTable(ContactAltAddress);
        IPCAddressLookupHelper.LookupAndUpdateAddress(RecRef, Rec.FieldNo(Address), Rec.FieldNo("Address 2"), Rec.FieldNo(City), Rec.FieldNo("Post Code"), Rec.FieldNo(County), Rec.FieldNo("Country/Region Code"));
        RecRef.SetTable(ContactAltAddress);

        if UpdatePage then begin
            CurrPage.SetRecord(ContactAltAddress);
            CurrPage.Update();
        end;
    end;
}