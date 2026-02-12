namespace Microsoft.Foundation.Address.IdealPostcodes;

using Microsoft.CRM.Contact;

pageextension 9405 "IPC Contact Card" extends "Contact Card"
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
        addfirst(Control37)
        {
            group(Control1040001_IdealPostcodes)
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
        moveafter("Address 2"; "Country/Region Code")
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
        Contact: Record Contact;
        RecRef: RecordRef;
    begin
        if not IPCAddressLookupHelper.ConfiguredAndSupportedForRecord(Rec."Country/Region Code") then
            exit;

        Contact.Copy(Rec);
        RecRef.GetTable(Contact);
        IPCAddressLookupHelper.LookupAndUpdateAddress(RecRef, Rec.FieldNo(Address), Rec.FieldNo("Address 2"), Rec.FieldNo(City), Rec.FieldNo("Post Code"), Rec.FieldNo(County), Rec.FieldNo("Country/Region Code"));
        RecRef.SetTable(Contact);

        if UpdatePage then begin
            CurrPage.SetRecord(Contact);
            CurrPage.Update();
        end;
    end;
}