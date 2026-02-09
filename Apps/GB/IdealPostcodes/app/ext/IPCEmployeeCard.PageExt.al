namespace Microsoft.Foundation.Address.IdealPostcodes;

using Microsoft.HumanResources.Employee;

pageextension 9408 "IPC Employee Card" extends "Employee Card"
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
            group(Control1040007_IdealPostcodes)
            {
                ShowCaption = false;
                Visible = AddressLookupTextEnabled;
                field(LookupAddress_IdealPostcodes; LookupAddressLbl)
                {
                    ApplicationArea = BasicHR;
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
        Employee: Record Employee;
        RecRef: RecordRef;
    begin
        if not IPCAddressLookupHelper.ConfiguredAndSupportedForRecord(Rec."Country/Region Code") then
            exit;

        CurrPage.SaveRecord();
        Employee.Copy(Rec);
        RecRef.GetTable(Employee);
        IPCAddressLookupHelper.LookupAndUpdateAddress(RecRef, Rec.FieldNo(Address), Rec.FieldNo("Address 2"), Rec.FieldNo(City), Rec.FieldNo("Post Code"), Rec.FieldNo(County), Rec.FieldNo("Country/Region Code"));
        RecRef.SetTable(Employee);
        Employee.Modify();

        if UpdatePage then begin
            CurrPage.SetRecord(Employee);
            CurrPage.Update();
        end;
    end;
}