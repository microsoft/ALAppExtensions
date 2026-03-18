namespace Microsoft.Foundation.Address.IdealPostcodes;

using Microsoft.Foundation.Company;

pageextension 9403 "IPC Company Information" extends "Company Information"
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
                ShowPostcodeLookupForAddress(false);
            end;
        }
        modify("Country/Region Code")
        {
            trigger OnBeforeValidate()
            begin
                HandleAddressLookupVisibility();
            end;
        }
        modify("Ship-to Post Code")
        {
            trigger OnBeforeValidate()
            begin
                IPCAddressLookupHelper.NotifyUserAboutAddressProviderCapabilities();
                ShowPostcodeLookupForShipToAddress(false);
            end;
        }
        modify("Ship-to Country/Region Code")
        {
            trigger OnBeforeValidate()
            begin
                HandleAddressLookupVisibility();
            end;
        }
        modify("Ship-to Address")
        {
            trigger OnBeforeValidate()
            begin
                IPCAddressLookupHelper.NotifyUserAboutAddressProviderCapabilities();
            end;
        }
        addfirst(Shipping)
        {
            group(Control1040016_GB)
            {
                ShowCaption = false;
                Visible = ShipToAddressLookupTextEnabled;
                field(LookupShipToAddress_IdealPostcodes; LookupShipToAddressLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        ShowPostcodeLookupForShipToAddress(true);
                    end;
                }
            }
        }
        addfirst(Communication)
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
                        ShowPostcodeLookupForAddress(true);
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
                    ShowPostcodeLookupForAddress(true);
                end;
            }
            action(LookupShipToPostcode)
            {
                ApplicationArea = All;
                Image = Find;
                Enabled = ShipToAddressLookupTextEnabled;
                Caption = 'Lookup Ship-to Address';
                ToolTip = 'Search for ship-to address using postcode provider';

                trigger OnAction()
                begin
                    ShowPostcodeLookupForShipToAddress(true);
                end;
            }
        }
    }

    var
        IPCAddressLookupHelper: Codeunit "IPC Address Lookup Helper";
        AddressLookupTextEnabled: Boolean;
        ShipToAddressLookupTextEnabled: Boolean;
        LookupAddressLbl: Label 'Lookup address from postcode';
        LookupShipToAddressLbl: Label 'Lookup ship-to address from postcode';

    trigger OnAfterGetCurrRecord()
    begin
        HandleAddressLookupVisibility();
    end;

    local procedure HandleAddressLookupVisibility()
    begin
        AddressLookupTextEnabled := CurrPage.Editable() and IPCAddressLookupHelper.ConfiguredAndSupportedForRecord(Rec."Country/Region Code");
        ShipToAddressLookupTextEnabled := CurrPage.Editable() and IPCAddressLookupHelper.ConfiguredAndSupportedForRecord(Rec."Ship-to Country/Region Code");
    end;

    local procedure ShowPostcodeLookupForAddress(UpdatePage: Boolean)
    var
        CompanyInformation: Record "Company Information";
        RecRef: RecordRef;
    begin
        if not IPCAddressLookupHelper.ConfiguredAndSupportedForRecord(Rec."Country/Region Code") then
            exit;

        CurrPage.SaveRecord();
        CompanyInformation.Copy(Rec);
        RecRef.GetTable(CompanyInformation);
        IPCAddressLookupHelper.LookupAndUpdateAddress(RecRef, Rec.FieldNo(Address), Rec.FieldNo("Address 2"), Rec.FieldNo(City), Rec.FieldNo("Post Code"), Rec.FieldNo(County), Rec.FieldNo("Country/Region Code"));
        RecRef.SetTable(CompanyInformation);

        if UpdatePage then begin
            CurrPage.SetRecord(CompanyInformation);
            CurrPage.Update();
        end;
    end;

    local procedure ShowPostcodeLookupForShipToAddress(UpdatePage: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not IPCAddressLookupHelper.ConfiguredAndSupportedForRecord(Rec."Ship-to Country/Region Code") then
            exit;
        CurrPage.SaveRecord();
        RecRef.GetTable(Rec);
        IPCAddressLookupHelper.LookupAndUpdateAddress(RecRef, Rec.FieldNo("Ship-to Address"), Rec.FieldNo("Ship-to Address 2"), Rec.FieldNo("Ship-to City"), Rec.FieldNo("Ship-to Post Code"), Rec.FieldNo("Ship-to County"), Rec.FieldNo("Ship-to Country/Region Code"));
        RecRef.SetTable(Rec);

        if UpdatePage then begin
            Rec.Modify();
            CurrPage.Update(true);
        end;
    end;
}